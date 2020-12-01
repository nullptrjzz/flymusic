import 'config_loader.dart';

Config i18nConfig;

Future initI18nConfig() async {
  return AssetsConfigLoader('assets/i18n/zh_CN.json').getConfig().then((value) {
    i18nConfig = value;
  });
}