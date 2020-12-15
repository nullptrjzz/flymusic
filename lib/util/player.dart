import 'dart:async';

import 'package:flutter_audio_plugin/flutter_audio_plugin.dart';

AudioPlayer audioPlayer;

Future initAudioPlayer() async {
  audioPlayer = AudioPlayer(debug: true);
}

/// 开发时应使用Player类进行控制，屏蔽具体实现细节
/// flutter_audio_plugin可以被替换为其他插件
class Player {
  dynamic _loadListener;
  dynamic _playListener;
  final defaultVolume = 50;

  /// 使用单例模式构建播放器
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
    setVolume(defaultVolume);
  }

  bool isPlaying() => audioPlayer.isPlaying;
  bool isPaused() => audioPlayer.isPaused;
  bool isStopped() => audioPlayer.isStopped;

  void load(String uri) {
    if (_loadListener == null || _playListener == null) {
      throw ArgumentError('method listen() must be called first');
    }
    int value = audioPlayer.load(uri);
    // audioPlayer.setDevice(deviceIndex: (audioPlayer.getDevices())['default']);
    if (_loadListener != null) {
      _loadListener((value == 0).toString());
    }
  }

  void setPosition(double pos) {
    audioPlayer.setPosition(pos);
  }

  double getPosition() {
    return audioPlayer.getPosition();
  }

  double getDuration() {
    return audioPlayer.getDuration();
  }

  int get volume => _getVolume();
  int _getVolume() {
    return audioPlayer.volume;
  }

  void play() {
    audioPlayer.play();
  }

  void pause() {
    audioPlayer.pause();
  }

  void stop() {
    audioPlayer.stop();
  }

  void setVolume(int v) {
    audioPlayer.setVolume(v);
  }

  void listen(dynamic loadListener, dynamic playListener, dynamic stateListener) {
    this._loadListener = loadListener;
    this._playListener = playListener;
    audioPlayer.setPositionListener(_playListener);
    audioPlayer.setStateListener(stateListener);
  }

  void close() {
    audioPlayer.close();
  }
}