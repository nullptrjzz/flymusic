import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'config_loader.dart';

Config i18nConfig;
Config sysConfig;
FileConfigLoader sysConfigLoader;

Directory docDir;
final _cfgPath = '.flymusic/config.json';

Future initI18nConfig() async {
  return AssetsConfigLoader('assets/i18n/zh_CN.json').getConfig().then((value) {
    i18nConfig = value;
  });
}

Future initSysConfig() async {
  docDir = await getApplicationDocumentsDirectory();
  File cfgFile = File('${docDir.path}/$_cfgPath');

  if (!cfgFile.parent.existsSync()) {
    cfgFile.parent.createSync(recursive: true);
  }
  if (!cfgFile.existsSync()) {
    cfgFile.createSync();
  }

  sysConfigLoader = FileConfigLoader(cfgFile.path);
  sysConfig = await sysConfigLoader.getConfig();
  Config innerConfig = await AssetsConfigLoader('assets/config.json').getConfig();
  if (sysConfig != innerConfig) {
    sysConfig = Config.merge(sysConfig, innerConfig);
    sysConfigLoader.saveConfigFile(sysConfig);
  }
  return;
}