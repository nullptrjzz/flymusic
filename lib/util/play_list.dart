import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_audio_plugin/library.dart' as lib;
import 'package:flutter_audio_plugin/flutter_audio_plugin.dart';
import 'package:flymusic/util/config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final _cachePath = '.flymusic/cache';
class PlayListItem {
  String fileLocation;
  double duration;
  bool valid = true;
  Map tags;
  List<String> covers;

  PlayListItem({this.fileLocation}) {
    checkValid();
    if (valid) {
      loadInfo();
    }
  }

  void loadInfo([bool refresh = false]) {
    covers = [];
    tags = audioTags(fileLocation);
    Directory dir = Directory(docDir.path + '/' + _cachePath);
    if (!dir.existsSync()) dir.createSync(recursive: true);

    String filePrefix = md5.convert(Platform.isWindows
        ? gbk.encode(fileLocation) : fileLocation.codeUnits).toString();
    if (!refresh) {
      dir.listSync().forEach((element) {
        if (element.path.split(RegExp('[/\\\\]')).last.startsWith(filePrefix)) {
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
      if (arts == null) {
        return;
      }
      for (int i = 0; i < arts['count']; i++) {
        covers.add(arts['list'][i]['file']);
      }
    }
  }

  String get title => tags['TITLE'];
  String get artist => tags['ARTIST'];
  String get cover => covers.isEmpty ? '' : covers.first;

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
      sb..write(item.fileLocation)
          ..write('\n');
    }
    return sb.toString();
  }

  PlayListItem setTo(int index) {
    if (index >= size) {
      throw ArgumentError.value(index, 'index', 'out of bound');
    }
    current = index;
    if (onChange != null)
      onChange(current, _list[current]);
    return _list[current];
  }

  void add(PlayListItem item) {
    _list.remove(item);
    _list.add(item);
  }

  void addFirst(PlayListItem item) {
    if (_list.isEmpty || _list.first != item) {
      _list.remove(item);
      _list = [item]..addAll(_list);
    }
  }
}