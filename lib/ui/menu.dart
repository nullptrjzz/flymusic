import 'package:flutter/material.dart';
import 'package:flymusic/main.dart';
import 'package:flymusic/ui/play_handler.dart';
import 'package:flymusic/util/config.dart';
import 'package:menubar/menubar.dart' as menuBar;

void buildMenuBar(BuildContext context) {
  menuBar.setApplicationMenu([
    menuBar.Submenu(label: i18nConfig.get('menu.file'), children: [
      menuBar.MenuItem(
          label: i18nConfig.get('menu.exit'),
          onClicked: () {
            exitApp();
          })
    ]),
    menuBar.Submenu(label: i18nConfig.get('menu.edit'), children: [
      menuBar.MenuDivider(),
      menuBar.MenuItem(
          label: i18nConfig.get('menu.options'), onClicked: () {})
    ]),
    menuBar.Submenu(label: i18nConfig.get('menu.library'), children: []),
    menuBar.Submenu(label: i18nConfig.get('menu.control'), children: [
      menuBar.MenuItem(
          label: i18nConfig.get('menu.skip_previous'), onClicked: () {
            globalPlayer.prev();
      }),
      menuBar.MenuItem(
          label: i18nConfig.get('menu.play_pause'), onClicked: () {
            if (globalPlayer.isPlaying()) {
              globalPlayer.pause();
            } else {
              globalPlayer.play();
            }
      }),
      menuBar.MenuItem(
          label: i18nConfig.get('menu.skip_next'), onClicked: () {
            globalPlayer.next();
      }),
      menuBar.MenuDivider(),
      menuBar.MenuItem(label: i18nConfig.get('menu.stop'), onClicked: () {
        globalPlayer.stop();
      })
    ]),
    menuBar.Submenu(label: i18nConfig.get('menu.help'), children: [
      menuBar.MenuItem(
          label: i18nConfig.get('menu.about'),
          onClicked: () {
            showAboutDialog(
                context: context,
                applicationName: i18nConfig.get('app_name'),
                applicationVersion: '1.0');
          }),
    ]),
  ]);
}