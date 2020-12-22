import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flymusic/ui/play_handler.dart';
import 'package:flymusic/util/config.dart';
import 'package:flymusic/util/play_list.dart';
import 'package:menubar/menubar.dart' as menuBar;

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _controller = TextEditingController();
  bool playListOpen = true;

  void _buildMenuBar() {
    menuBar.setApplicationMenu([
      menuBar.Submenu(label: i18nConfig.get('menu.file'), children: [
        menuBar.MenuItem(label: i18nConfig.get('menu.exit'), onClicked: () {
          SystemNavigator.pop(animated: true);
        })
      ]),
      menuBar.Submenu(label: i18nConfig.get('menu.edit'), children: [
        menuBar.MenuDivider(),
        menuBar.MenuItem(
            label: i18nConfig.get('menu.options'), onClicked: () {})
      ]),
      menuBar.Submenu(label: i18nConfig.get('menu.library'), children: [
      ]),
      menuBar.Submenu(label: i18nConfig.get('menu.control'), children: [
        menuBar.MenuItem(
            label: i18nConfig.get('menu.skip_previous'), onClicked: () {}),
        menuBar.MenuItem(
            label: i18nConfig.get('menu.play_pause'), onClicked: () {}),
        menuBar.MenuItem(
            label: i18nConfig.get('menu.skip_next'), onClicked: () {}),
        menuBar.MenuDivider(),
        menuBar.MenuItem(label: i18nConfig.get('menu.stop'), onClicked: () {})
      ]),
      menuBar.Submenu(label: i18nConfig.get('menu.help'), children: [
        menuBar.MenuItem(label: i18nConfig.get('menu.about'), onClicked: () {
          showAboutDialog(context: context,
              applicationName: i18nConfig.get('app_name'),
              applicationVersion: '1.0');
        }),
      ]),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _buildMenuBar();
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
                  child: Container(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                  labelText: '音频文件路径',
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide()
                                  )
                              ),
                            ),

                            Container(
                              height: 100,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RaisedButton.icon(
                                    label: Text('选择目录...'),
                                    icon: Icon(Icons.more_horiz),
                                    onPressed: () {
                                      showOpenPanel(canSelectDirectories: true)
                                          .then((value) {
                                        if (!value.canceled) {
                                          Directory dir = Directory(
                                              value.paths.first);
                                          final allowedExt = [
                                            '.mp3',
                                            '.flac',
                                            '.ape',
                                            '.wav',
                                            '.ogg'
                                          ];
                                          setState(() {
                                            audioPlayer.playList.addAll(
                                                dir.listSync(recursive: true)
                                                    .map((element) {
                                                  if (allowedExt.contains(
                                                      element.path.substring(
                                                          max(element.path
                                                              .lastIndexOf('.'), 0))
                                                          .toLowerCase())) {
                                                    return PlayListItem(
                                                        fileLocation: element
                                                            .path);
                                                  }
                                                }).toList());
                                          });
                                          ;
                                        }
                                      });
                                    },
                                  ),
                                  RaisedButton.icon(
                                    label: Text('选择文件...'),
                                    icon: Icon(Icons.more_horiz),
                                    onPressed: () {
                                      showOpenPanel().then((value) {
                                        if (!value.canceled)
                                          _controller.text = value.paths.first;
                                      });
                                    },
                                  ),

                                  RaisedButton.icon(
                                    label: Text('加载音频'),
                                    icon: Icon(Icons.download_done_sharp),
                                    onPressed: () {
                                      setState(() {
                                        audioPlayer.playList.addFirst(
                                            PlayListItem(
                                                fileLocation: _controller.text
                                                    .toString()));
                                      });
                                    },
                                  ),
                                ],
                              ),

                            )
                          ]
                      ),
                    ),
                  ),),

                PlayListView(audioPlayer.playList, playListOpen),
              ],
            ),
          ),

          PlayHandler(togglePlayList)
        ],
      ),
    );
  }
}
