import 'dart:async';

import 'package:flutter_audio_plugin/flutter_audio_plugin.dart';
import 'package:flymusic/util/config.dart';
import 'package:flymusic/util/play_list.dart';

AudioPlayer audioPlayer;

Future initAudioPlayer() async {
  audioPlayer = AudioPlayer(debug: true);
}

enum PlayMode {
  InOrder, Random, Single
}

enum LoopMode {
  Loop, Disabled
}

/// 开发时应使用Player类进行控制，屏蔽具体实现细节
/// flutter_audio_plugin可以被替换为其他插件
class Player {
  final _uriTitlePattern = RegExp('[/\\\\]');
  final _artistPattern = RegExp('( )+');
  dynamic _loadListener;
  dynamic _playListener;
  final defaultVolume = 50;
  PlayMode playMode = PlayMode.InOrder;
  LoopMode loopMode = LoopMode.Loop;

  PlayList playList;

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
    setVolume(sysConfig.get('inner.default_volume'));
    loopMode = LoopMode.values[sysConfig.get('inner.list_loop_mode')];
    playMode = PlayMode.values[sysConfig.get('inner.list_play_mode')];
    playList = PlayList();
    playList.onChange = (index, item) {
      load(item);
    };
    audioPlayer.setFinishListener(() {
      print('finish');
      if (playMode == PlayMode.Single) {
        if (loopMode == LoopMode.Loop) {
          // 单曲循环在播放停止后自动开始重播
          setPosition(0);
        } else {
          stop();
        }
      } else {
        stop();
        next();
      }
    });
  }

  bool isPlaying() => audioPlayer.isPlaying;
  bool isPaused() => audioPlayer.isPaused;
  bool isStopped() => audioPlayer.isStopped;

  void load(PlayListItem playListItem) {
    if (_loadListener == null || _playListener == null) {
      throw ArgumentError('method listen() must be called first');
    }

    if (playListItem == null) {
      stop();
    }

    int value = audioPlayer.load(playListItem.fileLocation);
    if (value == 0) {
      playListItem.valid = true;
      if (_loadListener != null) {
        _loadListener('${playListItem.title ?? playListItem.fileLocation.split(_uriTitlePattern).last} - '
            '${playListItem.artist == null ? i18nConfig.get('player.unknown')
            : playListItem.artist.replaceAll(_artistPattern, '/')}');
      }
    } else {
      playListItem.valid = false;
      if (_loadListener != null) {
        _loadListener(i18nConfig.get('player.error_while_loading_file'));
      }
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

  void prev() {
    load(playList.prev(loopMode == LoopMode.Loop));
  }

  void next() {
    if (playMode == PlayMode.InOrder) {
      load(playList.next(loopMode == LoopMode.Loop));
    } else {
      load(playList.random(loopMode == LoopMode.Loop));
    }
  }

  void setVolume(int v) {
    audioPlayer.setVolume(v);
    // 记录到配置中
    sysConfig.set('inner.default_volume', v);
    sysConfigLoader.saveConfigFileAsync(sysConfig);
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