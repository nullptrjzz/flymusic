import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flymusic/util/config.dart';
import 'package:flymusic/util/player.dart';

import 'home_page.dart';

/// Do some initialization works
class InitializePage extends StatefulWidget {

  @override
  State createState() => _InitializePageState();
}

class _InitializePageState extends State<InitializePage> {
  String _stateText = '';

  void _finish() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Scaffold(body: HomePage(),)));
  }

  Future initialize() async {
    setState(() {
      _stateText = 'Loading configs...';
    });
    await initI18nConfig();
    await initSysConfig();
    await initAudioPlayer();
  }

  @override
  void initState() {
    super.initState();
    initialize().then((value) => _finish());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(_stateText, style: TextStyle(color: Colors.black26, fontSize: 18),),
              ),
              Container(
                constraints: BoxConstraints(maxWidth: 160),
                child: LinearProgressIndicator(),
              )
            ],
          ),
        ),
      ),
    );
  }

}