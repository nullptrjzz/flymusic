import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flymusic/theme/theme.dart';
import 'package:flymusic/util/player.dart';

class PlayHandler extends StatefulWidget {

  @override
  State createState() => _PlayHandlerState();
}

class _PlayHandlerState extends State<PlayHandler> {
  bool _playing = false;
  double _position = 0;
  double _duration = (601 * 1000).toDouble();

  int _volume = 0;
  bool _mute = false;
  String _curName = 'FlyMusic';

  @override
  void initState() {
    super.initState();

    _volume = (audioPlayer.volume * 100).toInt();
  }

  void _updatePosition(double position) {
    setState(() {
      _position = position.roundToDouble();
    });
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
  }

  @override
  Widget build(BuildContext context) {
    Duration duration = Duration(milliseconds: _duration.toInt());
    Duration position = Duration(milliseconds: _position.toInt());

    var posText = '${position.inMinutes < 10 ? '0' : ''}${position.inMinutes}:'
        '${(position.inSeconds % 60) < 10 ? '0' : ''}${(position.inSeconds % 60)}';
    var durText = '${duration.inMinutes < 10 ? '0' : ''}${duration.inMinutes}:'
        '${(duration.inSeconds % 60) < 10 ? '0' : ''}${(duration.inSeconds % 60)}';

    return Material(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // play buttons
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.skip_previous),
              iconSize: 24,
              splashRadius: 20,
              // minWidth: 60,
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
              iconSize: 36,
              splashRadius: 24,
              // minWidth: 60,
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.skip_next),
              iconSize: 24,
              splashRadius: 20,
              // minWidth: 60,
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
                      max: _duration,
                      value: _position,
                      onChanged: _updatePosition,
                    )
                  ],
                )
            ),

            // other control buttons
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.repeat),
              iconSize: 24,
              splashRadius: 20,
            ),
            IconButton(
              onPressed: () {
                _updateVolume(0, !_mute);
              },
              icon: Icon((_mute || _volume == 0) ? Icons.volume_mute : Icons.volume_up),
              iconSize: 24,
              splashRadius: 20,
            ),
            Theme(
              data: ThemeData(
                sliderTheme: FlyMusicVolumeSliderTheme()
              ),
              child: Container(
                width: 100,
                child: Slider(
                    min: 0,
                    max: 100,
                    value: _volume.toDouble(),
                    label: '$_volume%',
                    onChanged: (v) => _updateVolume(v)
                ),
              ),
            ),

          ],
        ),
      ),
      elevation: 4,
    );
  }
}