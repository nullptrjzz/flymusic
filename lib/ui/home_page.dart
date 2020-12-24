import 'dart:io';

import 'package:act_like_desktop/act_like_desktop.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:flymusic/ui/devtest_page.dart';
import 'package:flymusic/ui/play_handler.dart';
import 'package:flymusic/util/play_list.dart';

import 'menu.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool playListOpen = true;

  @override
  void initState() {
    super.initState();
    buildMenuBar(context);
  }

  void togglePlayList() {
    setState(() {
      playListOpen = !playListOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 1,
                  child: TabPage(
                    tabNames: [
                      'DevTest',
                      'Empty'
                    ],
                    pages: [
                      DevTestPage(),
                      Container()
                    ],
                  ),
                ),
                PlayListView(globalPlayer.playList, playListOpen),
              ],
            ),
          ),
          PlayHandler(togglePlayList)
        ],
      ),
    );
  }
}
