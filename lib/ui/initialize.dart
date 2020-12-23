import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flymusic/data/event_bus.dart';
import 'package:flymusic/util/config.dart';
import 'package:flymusic/util/isolate_pool.dart';
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
    eventBus.fire(AppInitEvent('', false));
    await initI18nConfig();
    eventBus.fire(AppInitEvent(i18nConfig.get('splash_screen.read_system_config'), false));
    await initSysConfig();
    eventBus.fire(AppInitEvent(i18nConfig.get('splash_screen.init_audio_player'), false));
    await initAudioPlayer();
    eventBus.fire(AppInitEvent(i18nConfig.get('splash_screen.init_isolate_pool'), false));
    await initLoadBalancer();
    eventBus.fire(AppInitEvent('', true));
  }

  @override
  void initState() {
    super.initState();
    initialize();

    // 订阅EventBus的消息结束该页面
    eventBus.on<AppInitEvent>().listen((event) {
      if (!event.finished) {
        setState(() {
          _stateText = event.state;
        });
      } else {
        _finish();
      }
    });
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