import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_audio_desktop/flutter_audio_desktop.dart';
import 'package:flymusic/util/config.dart';
import 'package:menubar/menubar.dart' as menuBar;

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //** to be deleted **
  bool _play = false;
  bool _tick = false;

  dynamic duration;
  Duration position;
  AudioPlayer audioPlayer;

  void _buildMenuBar() {
    menuBar.setApplicationMenu([
      menuBar.Submenu(label: i18nConfig.get('menu.file'), children: [
        menuBar.MenuItem(label: i18nConfig.get('menu.exit'), onClicked: () {})
      ]),
    ]);
  }

  void _changeState() {
    setState(() {
      _play = !_play;
      _tick = false;
    });
  }

  void _loadFile(String file) async {
    await audioPlayer.load(file);
    duration = await audioPlayer.getDuration();
    if (duration is bool) {
      duration = null;
    }
  }

  @override
  void initState() {
    audioPlayer = new AudioPlayer(debug: true);
    _play = audioPlayer.isPlaying;
    audioPlayer.setDevice(deviceIndex: 1);

    _loadFile('D:\\Music\\Hotel California-The Eagles.wav');

    _buildMenuBar();
  }

  @override
  Widget build(BuildContext context) {
    if (!_tick) {
      _tick = true;
      if (_play) {
        Timer.periodic(Duration(milliseconds: 50), (timer) async {
          position = await audioPlayer.getPosition();
          if (!_play) {
            timer.cancel();
          }
          setState(() {});
        });
        audioPlayer.play();
      } else {
        audioPlayer.pause();
      }
    }
    print((duration?.inMilliseconds ?? 0) );

    return Center(
      child: Column(
        children: [
          Flexible(
            child: Container(),
          ),

          Padding(
            child: LinearProgressIndicator(
              value: (position?.inMilliseconds ?? 0) / (duration?.inMilliseconds ?? 1),
            ),
            padding: EdgeInsets.all(16),
          ),
        ],
      ),
    );
  }
//** to be deleted **
}
