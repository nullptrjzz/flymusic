
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flymusic/ui/play_handler.dart';
import 'package:flymusic/util/config.dart';
import 'package:menubar/menubar.dart' as menuBar;

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _controller = TextEditingController();
  void _buildMenuBar() {
    menuBar.setApplicationMenu([
      menuBar.Submenu(label: i18nConfig.get('menu.file'),children: [
        menuBar.MenuItem(label: i18nConfig.get('menu.exit'), onClicked: () {
          SystemNavigator.pop(animated: true);
        })
      ]),
      menuBar.Submenu(label: i18nConfig.get('menu.edit'),children: [
        menuBar.MenuDivider(),
        menuBar.MenuItem(label: i18nConfig.get('menu.options'), onClicked: () {
        })
      ]),
      menuBar.Submenu(label: i18nConfig.get('menu.library'),children: [
      ]),
      menuBar.Submenu(label: i18nConfig.get('menu.control'),children: [
        menuBar.MenuItem(label: i18nConfig.get('menu.skip_previous'), onClicked: () {
        }),
        menuBar.MenuItem(label: i18nConfig.get('menu.play_pause'), onClicked: () {
        }),
        menuBar.MenuItem(label: i18nConfig.get('menu.skip_next'), onClicked: () {
        }),
        menuBar.MenuDivider(),
        menuBar.MenuItem(label: i18nConfig.get('menu.stop'), onClicked: () {
        })
      ]),
      menuBar.Submenu(label: i18nConfig.get('menu.help'), children: [
        menuBar.MenuItem(label: i18nConfig.get('menu.about'), onClicked: () {
          showAboutDialog(context: context, applicationName: i18nConfig.get('app_name'), applicationVersion: '1.0');
        }),
      ]),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _buildMenuBar();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
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
                            label: Text('选择文件...'),
                            icon: Icon(Icons.more_horiz),
                            onPressed: () {
                              FilePickerCross.importFromStorage(type: FileTypeCross.audio)
                                  .then((value) {
                                _controller.text = value.path;
                              });
                            },
                          ),

                          RaisedButton.icon(
                            label: Text('加载音频'),
                            icon: Icon(Icons.download_done_sharp),
                            onPressed: () {
                              audioPlayer.load(_controller.text.toString());
                            },
                          ),
                        ],
                      ),

                    )
                  ]
                ),
              ),
            ),
          ),

          PlayHandler()
        ],
      ),
    );
  }
//** to be deleted **
}
