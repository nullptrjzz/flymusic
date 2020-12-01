import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flymusic/ui/home_page.dart';
import 'package:flymusic/util/config.dart';
import 'package:window_size/window_size.dart' as windowSize;

Future initialize() async {
  await initI18nConfig();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  windowSize.getWindowInfo().then((window) {
    windowSize.setWindowTitle('FlyMusic');
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
