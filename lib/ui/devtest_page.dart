import 'dart:io';

import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:flymusic/util/play_list.dart';

class DevTestPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(40),
    child: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
              labelText: '音频文件路径',
              border:
              OutlineInputBorder(borderSide: BorderSide())),
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
                      addDirectory(Directory(value.paths.first));
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
                  PlayListItem(
                      fileLocation:
                      _controller.text.toString(),
                      listId: 'playing');
                },
              ),
            ],
          ),
        )
      ]),
    ),
  );
}