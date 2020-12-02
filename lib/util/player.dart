import 'dart:async';

import 'package:flutter_audio_desktop/flutter_audio_desktop.dart';

AudioPlayer audioPlayer;

Future initAudioPlayer() async {
  audioPlayer = AudioPlayer();
  audioPlayer.setDevice(deviceIndex: 1);
}

class Player {
  dynamic _loadListener;
  dynamic _playListener;

  factory Player() => _getInstance();
  Player get instance => _getInstance();

  static Player _instance;

  static Player _getInstance() {
    if (_instance == null) {
      _instance = Player._internal();
    }
    return _instance;
  }

  Player._internal() {
  }

  bool isPlaying() => audioPlayer.isPlaying;
  bool isPaused() => audioPlayer.isPaused;
  bool isStopped() => audioPlayer.isStopped;

  void load(String uri) {
    audioPlayer.load(uri).then((value) => _loadListener(value.toString()));
  }

  void setPosition(int pos) {
    audioPlayer.setPosition(Duration(milliseconds: pos));
  }

  Future<int> _getPosition() async {
    dynamic position = await audioPlayer.getPosition();
    return position == false ? 0 : (position as Duration).inMilliseconds;
  }

  Future<int> _getDuration() async {
    dynamic duration = await audioPlayer.getDuration();
    return duration == false ? 0 : (duration as Duration).inMilliseconds;
  }

  int get volume => _getVolume();
  int _getVolume() {
    return (audioPlayer.volume * 100).toInt();
  }

  Future play() async {
    return audioPlayer.play().then((value) {
      Timer.periodic(Duration(milliseconds: 50), (timer) async {
        if (!audioPlayer.isPlaying) {
          timer.cancel();
        }

        int duration = await _getDuration();
        int position = await _getPosition();

        _playListener(position, duration);
      });
    });
  }

  Future pause() async {
    return audioPlayer.pause();
  }

  Future stop() async {
    return audioPlayer.stop();
  }

  void setVolume(int v) {
    audioPlayer.setVolume(v / 100);
  }

  void listen(dynamic loadListener, dynamic playListener) {
    this._loadListener = loadListener;
    this._playListener = playListener;
  }
}