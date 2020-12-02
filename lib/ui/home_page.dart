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
  void _buildMenuBar() {
    menuBar.setApplicationMenu([
      menuBar.Submenu(label: i18nConfig.get('menu.file'), children: [
        menuBar.MenuItem(label: i18nConfig.get('menu.exit'), onClicked: () {
          SystemNavigator.pop(animated: true);
        })
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
            child: Container(),
          ),

          PlayHandler()
        ],
      ),
    );
  }
//** to be deleted **
}
