import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Save the config in memory
class Config {
  Map _items;

  Config({Map items}) {
    this._items = items;
  }

  dynamic get(String key) {
    if (key == null || key == "") {
      return null;
    }

    List<String> splits = key.split(".");
    dynamic cur = _items;
    for (String s in splits) {
      // items has no sub levels
      if (cur == null) {
        return null;
      }

      if (cur is Map) {
        cur = cur[s];
      } else if (cur is List) {
        if (int.tryParse(s) != null) {
          cur = cur[int.parse(s)];
        } else {
          cur = null;
        }
      } else {
        cur = null;
      }
    }

    return cur;
  }

  dynamic set(String key, dynamic content) {
    if (get(key) == null) {

    } else {

    }
  }
}

/// Load .json config file and parse it
abstract class ConfigLoader {
  String file;
  Config _config;
  bool _loadComplete = false;

  ConfigLoader(this.file) {
    if (file != null && file != "" && !file.endsWith(".json")) {
      file = file + ".json";
    }

    _loadConfigFile().then((fileContent) {
      if (fileContent == "") {
        _config = Config(items: {});
      } else {
        dynamic decoded;
        try {
          decoded = jsonDecode(fileContent);
        } on Error {
          // do nothing
        }

        if (decoded is Map) {
          _config = Config(items: {});
        } else {
          _config = Config(items: {});
        }
      }

      _loadComplete = true;
    });

  }

  Future<String> _loadConfigFile();

  Future<Config> getConfig() {
    Future.doWhile(() => !_loadComplete);
    return Future.value(_config);
  }
}

/// Load config file from inner assets
class AssetsConfigLoader extends ConfigLoader {
  AssetsConfigLoader(String file) : super(file);

  @override
  Future<String> _loadConfigFile() {
    return rootBundle.loadString(file);
  }

}
