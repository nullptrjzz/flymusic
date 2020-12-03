import 'dart:async';

import 'package:flutter_audio_desktop/flutter_audio_desktop.dart';

AudioPlayer audioPlayer;

Future initAudioPlayer() async {
  audioPlayer = AudioPlayer(debug: true);
  audioPlayer.setDevice(deviceIndex: (await audioPlayer.getDevices())['default']);
}

/// 开发时应使用Player类进行控制，屏蔽具体实现细节
/// flutter_audio_desktop可以被替换为其他插件
class Player {
  dynamic _loadListener;
  dynamic _playListener;

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
  }

  bool isPlaying() => audioPlayer.isPlaying;
  bool isPaused() => audioPlayer.isPaused;
  bool isStopped() => audioPlayer.isStopped;

  Future load(String uri) async {
    if (_loadListener == null || _playListener == null) {
      throw ArgumentError('method listen() must be called first');
    }
    bool value = await audioPlayer.load(uri);
    if (_loadListener != null) {
      _loadListener(value.toString());
    }
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
      print('play: $value');
      Timer.periodic(Duration(milliseconds: 50), (timer) async {
        if (!audioPlayer.isPlaying) {
          timer.cancel();
        }

        int duration = await _getDuration();
        int position = await _getPosition();

        if (_playListener != null) {
          _playListener(position, duration);
          if (position == duration) {
            stop();
          }
        }
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