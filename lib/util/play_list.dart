import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:act_like_desktop/act_like_desktop.dart';
import 'package:crypto/crypto.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_audio_plugin/flutter_audio_plugin.dart';
import 'package:flymusic/util/config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'file_util.dart';

final _cachePath = '.flymusic/cache';

class PlayListItem {
  String fileLocation = "";
  bool valid = true;
  Map tags = {};
  AudioMeta meta = AudioMeta.empty();
  List<String> covers = [];

  PlayListItem({this.fileLocation}) {
    checkValid();
    if (valid) {
      loadInfo();
    }
  }

  void loadInfo([bool refresh = false]) {
    tags = audioTags(fileLocation);
    if (tags == null || tags.isEmpty) {
      tags = {
        'TITLE': fileNameWithoutExt(fileLocation)
      };
    }
    meta = audioMeta(fileLocation);
    Directory dir = Directory(docDir.path + '/' + _cachePath);
    if (!dir.existsSync()) dir.createSync(recursive: true);

    String filePrefix = md5
        .convert(Platform.isWindows
            ? gbk.encode(fileLocation)
            : fileLocation.codeUnits)
        .toString().toLowerCase();
    if (!refresh) {
      dir.listSync().forEach((element) {
        if (fileName(element.path).toLowerCase().startsWith(filePrefix)) {
          covers.add(element.uri.toFilePath(windows: Platform.isWindows));
        }
      });
    } else {
      dir.listSync().forEach((element) {
        if (element.path.split(RegExp('[/\\\\]')).last.startsWith(filePrefix)) {
          element.deleteSync();
        }
      });
    }

    if (covers.isEmpty) {
      var arts = audioArts(fileLocation, dir.path, 0);
      if (arts == null || arts['count'] == 0) {
        // 寻找本地封面
        Directory fileDir = File(fileLocation).parent;
        fileDir.listSync().forEach((element) {
          if (isPicture(element.path)) {
            // use it as a cover
            covers = [element.path];

            if (match(element.path, fileLocation))
              return;
          }
        });
      } else {
        for (int i = 0; i < arts['count']; i++) {
          covers.add(arts['list'][i]['file']);
        }
      }
    }
  }

  String get title => tags['TITLE'] ?? '';

  String get artist => tags['ARTIST'] ?? '';

  String get cover => covers.isEmpty ? '' : covers.first;

  int get duration => meta.length;

  bool checkValid() {
    if (fileLocation != null && fileLocation.isNotEmpty) {
      valid = File(fileLocation).existsSync();
    } else {
      valid = false;
    }
    return valid;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayListItem &&
          runtimeType == other.runtimeType &&
          fileLocation == other.fileLocation;

  @override
  int get hashCode => fileLocation.hashCode;
}

class PlayList {
  List<PlayListItem> _list;
  int current = -1;
  HashSet<PlayListItem> played;
  Function(int index, PlayListItem item) onChange;

  PlayList() {
    _list = [];
    played = HashSet.identity();
  }

  PlayList.import(String fileLocation) {
    File file = File(fileLocation);
    String content = file.readAsStringSync();
    for (String s in content.split(RegExp('[\\r\\n]+'))) {
      if (s.isNotEmpty) {
        PlayListItem item = PlayListItem(fileLocation: s);
        _list.add(item);
      }
    }
  }

  int get size => _list.length;

  bool get isEmpty => _list.isEmpty;

  bool get isNotEmpty => _list.isNotEmpty;

  PlayListItem get first => isEmpty ? null : setTo(0);

  PlayListItem prev([bool loop = true]) {
    if (isEmpty) {
      return null;
    }
    if ((current == 0) && !loop) {
      return null;
    }

    return setTo(current == 0 ? size - 1 : current - 1);
  }

  PlayListItem next([bool loop = true]) {
    if (isEmpty) {
      return null;
    }
    if ((current == size - 1) && !loop) {
      return null;
    }

    return setTo((current + 1) % size);
  }

  PlayListItem random([bool canSame = false]) {
    if (size == 0) return null;
    if (size == 1) return _list[0];

    if (canSame) {
      // just random
      return _list[Random().nextInt(size)];
    }

    var unPlayed = <PlayListItem>[];
    for (PlayListItem item in _list) {
      if (!played.contains(item)) {
        unPlayed.add(item);
      }
    }

    if (unPlayed.isEmpty) {
      played.clear();
      unPlayed.addAll(_list);
    }

    int index = Random().nextInt(unPlayed.length);
    played.add(unPlayed[index]);
    return setTo(_list.indexOf(unPlayed[index]));
  }

  String export() {
    StringBuffer sb = StringBuffer();
    for (PlayListItem item in _list) {
      sb..write(item.fileLocation)..write('\n');
    }
    return sb.toString();
  }

  PlayListItem setTo(int index) {
    if (index >= size) {
      throw ArgumentError.value(index, 'index', 'out of bound');
    }
    current = index;
    if (onChange != null) onChange(current, _list[current]);
    return _list[current];
  }

  void add(PlayListItem item) {
    if (item == null) return;
    _list.remove(item);
    _list.add(item);
  }

  void addFirst(PlayListItem item) {
    if (item == null) return;
    if (_list.isEmpty || _list.first != item) {
      _list.remove(item);
      _list = [item]..addAll(_list);
    }
  }

  void addAll(List<PlayListItem> list) {
    list.forEach((element) {add(element);});
  }

  void addAllFirst(List<PlayListItem> list) {
    list.forEach((element) {addFirst(element);});
  }

  PlayListItem operator [](int i) => _list[i];

  operator []=(int index, PlayListItem value) => _list[index] = value;
}

class PlayListView extends StatelessWidget {
  final PlayList playList;
  final bool playListOpen;
  final double imageSize = 64;

  PlayListView(this.playList, this.playListOpen);

  @override
  Widget build(BuildContext context) {
    if (!playListOpen)
      return Container();
    return Material(
      child: DraggablePanel(
        size: Size.fromWidth(300),
        minSize: Size.fromWidth(200),
        maxSize: Size.fromWidth(500),
        draggableSides: DraggableSides(left: true),
        child: ListView.builder(
            itemCount: playList.size + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // header
                return Padding(
                  child: Text(
                    i18nConfig.get('player.playlist') + ' (${playList?.size ?? 0})',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.normal
                    ),
                  ),
                  padding: EdgeInsets.all(16),
                );
              }
              PlayListItem item = playList[index - 1];
              Duration duration = Duration(milliseconds: item.duration ?? 0);
              File coverFile = File(item.cover);
              return FlatButton(
                onPressed: () {
                  playList.setTo(index - 1);
                },
                padding: EdgeInsets.symmetric(vertical: 1),
                height: imageSize,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 专辑封面
                    coverFile.existsSync()
                        ? Image(
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.contain,
                      image: FileImage(coverFile),
                    )
                        : Container(
                      color: Colors.grey,
                      width: imageSize,
                      height: imageSize,
                    ),

                    Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          height: imageSize,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Text(
                                      '${duration.inMinutes < 10 ? '0' : ''}${duration.inMinutes}:'
                                          '${(duration.inSeconds % 60) < 10 ? '0' : ''}${(duration.inSeconds % 60)}'),
                                ],
                              ),

                              Text(
                                item.artist,
                                style: TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )
                            ],
                          ),
                        )
                    ),
                  ],
                ),
              );
            }),
      ),
      elevation: 8,
    );
  }
}
