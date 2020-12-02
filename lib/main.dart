import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flymusic/theme/theme.dart';
import 'package:flymusic/ui/home_page.dart';
import 'package:flymusic/util/config.dart';
import 'package:window_size/window_size.dart' as windowSize;
import 'dart:math' as math;

Future initialize() async {
  await initI18nConfig();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  windowSize.getWindowInfo().then((window) {
    windowSize.setWindowTitle('FlyMusic');
    if (window.screen != null) {
      final screenFrame = window.screen.visibleFrame;
      final width = math.max((screenFrame.width / 2).roundToDouble(), 1400.0);
      final height = math.max((screenFrame.height / 2).roundToDouble(), 900.0);
      final left = ((screenFrame.width - width) / 2).roundToDouble();
      final top = ((screenFrame.height - height) / 3).roundToDouble();
      final frame = Rect.fromLTWH(left, top, width, height);
      windowSize.setWindowFrame(frame);

      windowSize.setWindowMinSize(Size(800, 600));
    }

  });

  initialize().then((value) {
    runApp(FlyMusicApp());
  });
}

class FlyMusicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlyMusic',
      theme: themeData,
      home: Scaffold(
        body: HomePage(),
      ),
    );
  }
}
