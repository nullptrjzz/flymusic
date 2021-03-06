import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flymusic/theme/theme.dart';
import 'package:flymusic/util/config.dart';
import 'package:flymusic/util/play_list.dart';
import 'package:flymusic/util/player.dart';

Player globalPlayer = Player();

class PlayHandler extends StatefulWidget {
  final Function togglePlayListTranslate;

  PlayHandler(this.togglePlayListTranslate);

  @override
  State createState() => _PlayHandlerState();
}

class _PlayHandlerState extends State<PlayHandler> {
  double _position = 0;
  double _duration = 0;

  int _volume = 0;
  bool _mute = false;

  /// 防止进度条闪烁
  bool _drag = false;
  String _curName = 'FlyMusic';

  @override
  void initState() {
    super.initState();
    _volume = globalPlayer.volume;
    globalPlayer.listen((name) {
      setState(() {
        _curName = name;
      });
    }, (p, d) {
      if (!_drag) {
        setState(() {
          _position = p < 0 ? 0 : p;
          _duration = d < 0 ? 0 : d;
        });
      }
    }, (lo, pl, pa, st) {
      if (st) {
        setState(() {
          _curName = 'FlyMusic';
        });
      }
    });
  }

  void _updatePosition(double position) {
    setState(() {
      _position = position;
    });
    globalPlayer.setPosition(position);
    globalPlayer.play();
  }

  void _updateVolume(double v, [bool mute]) {
    if (mute != null) {
      setState(() {
        _mute = mute;
      });
    } else {
      setState(() {
        _mute = false;
        _volume = v.toInt();
      });
    }
    globalPlayer.setVolume(_mute ? 0 : _volume);
  }

  @override
  Widget build(BuildContext context) {
    Duration duration = Duration(seconds: _duration.toInt());
    Duration position = Duration(seconds: _position.toInt());

    var posText = '${position.inMinutes < 10 ? '0' : ''}${position.inMinutes}:'
        '${(position.inSeconds % 60) < 10 ? '0' : ''}${(position.inSeconds % 60)}';
    var durText = '${duration.inMinutes < 10 ? '0' : ''}${duration.inMinutes}:'
        '${(duration.inSeconds % 60) < 10 ? '0' : ''}${(duration.inSeconds % 60)}';

    // cover
    File coverFile;
    if (globalPlayer.playList.isNotEmpty &&
        globalPlayer.playList.current > -1 &&
        globalPlayer.playList[globalPlayer.playList.current] != null) {
      String fileLoc = globalPlayer.playList[globalPlayer.playList.current].cover;
      if (fileLoc != null && fileLoc.isNotEmpty) coverFile = File(fileLoc);
    }

    return Material(
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // play buttons
                IconButton(
                  onPressed: () {
                    globalPlayer.prev();
                  },
                  icon: Icon(Icons.skip_previous),
                  iconSize: 24,
                  splashRadius: 20,
                ),
                IconButton(
                  onPressed: globalPlayer.isPlaying()
                      ? () {
                          globalPlayer.pause();
                        }
                      : () {
                          globalPlayer.play();
                        },
                  icon: Icon(
                      globalPlayer.isPlaying() ? Icons.pause : Icons.play_arrow),
                  iconSize: 36,
                  splashRadius: 24,
                ),
                IconButton(
                  onPressed: () {
                    globalPlayer.next();
                  },
                  icon: Icon(Icons.skip_next),
                  iconSize: 24,
                  splashRadius: 20,
                ),

                // progress indicator
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(_curName),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('$posText/$durText'),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                    Slider(
                      min: 0,
                      max: max(_duration, 0),
                      value: min(max(_position, 0), _duration),
                      onChanged: (pos) {
                        setState(() {
                          _position = pos;
                        });
                      },
                      onChangeStart: (pos) {
                        _drag = true;
                        globalPlayer.pause();
                      },
                      onChangeEnd: (pos) {
                        _drag = false;
                        _updatePosition(pos);
                      },
                    )
                  ],
                )),
                // other control buttons

                // 循环/单曲/不循环
                IconButton(
                  onPressed: () {
                    setState(() {
                      globalPlayer.loopMode =
                          LoopMode.values[(globalPlayer.loopMode.index + 1) % 2];
                    });
                  },
                  icon: Icon(globalPlayer.loopMode == LoopMode.Loop
                      ? Icons.sync
                      : Icons.sync_disabled),
                  tooltip: globalPlayer.loopMode == LoopMode.Loop
                      ? i18nConfig.get('player.repeat')
                      : i18nConfig.get('player.no_repeat'),
                  iconSize: 24,
                  splashRadius: 20,
                ),
                // 顺序播放/随机播放
                IconButton(
                  onPressed: () {
                    setState(() {
                      globalPlayer.playMode =
                          PlayMode.values[(globalPlayer.playMode.index + 1) % 3];
                    });
                  },
                  icon: Icon(globalPlayer.playMode == PlayMode.InOrder
                      ? Icons.menu
                      : globalPlayer.playMode == PlayMode.Random
                          ? Icons.shuffle
                          : Icons.looks_one_outlined),
                  tooltip: globalPlayer.playMode == PlayMode.InOrder
                      ? i18nConfig.get('player.sequence_play')
                      : globalPlayer.playMode == PlayMode.Random
                          ? i18nConfig.get('player.random_play')
                          : i18nConfig.get('player.single_play'),
                  iconSize: 24,
                  splashRadius: 20,
                ),
                IconButton(
                  onPressed: () {
                    _updateVolume(0, !_mute);
                  },
                  icon: Icon((_mute || _volume == 0)
                      ? Icons.volume_mute
                      : Icons.volume_up),
                  iconSize: 24,
                  splashRadius: 20,
                ),
                Theme(
                  data: ThemeData(sliderTheme: FlyMusicVolumeSliderTheme()),
                  child: Container(
                    width: 100,
                    child: Slider(
                        min: 0,
                        max: 100,
                        value: _volume.toDouble(),
                        label: '$_volume%',
                        onChanged: (v) => _updateVolume(v)),
                  ),
                ),

                // 播放列表
                IconButton(
                  onPressed: () {
                    widget.togglePlayListTranslate();
                  },
                  icon: Icon(Icons.list_alt),
                  tooltip: i18nConfig.get('player.playlist'),
                  iconSize: 24,
                  splashRadius: 20,
                  // minWidth: 60,
                ),
              ],
            ),
          ),
        ],
      ),
      elevation: 8,
    );
  }
}
