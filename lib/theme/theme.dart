
import 'package:flutter/material.dart';

var themeData = ThemeData(
    platform: TargetPlatform.windows,
    sliderTheme: FlyMusicSliderTheme()
);

class FlyMusicSliderTheme extends SliderThemeData {
  FlyMusicSliderTheme() : super(
      trackHeight: 1,
      thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: 6
      ),
      overlayShape: RoundSliderOverlayShape(
          overlayRadius: 12
      )
  );
}

class FlyMusicVolumeSliderTheme extends SliderThemeData {
  FlyMusicVolumeSliderTheme() : super(
      trackHeight: 1,
      thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: 4
      ),
      overlayShape: RoundSliderOverlayShape(
          overlayRadius: 8
      ),
      showValueIndicator: ShowValueIndicator.always
  );
}