import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

/// Save the config in memory
class Config {
  Map _items;

  Config({Map items}) {
    this._items = Map()..addAll(items);
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

  dynamic getAll() {
    return _items;
  }

  dynamic set(String key, dynamic content) {
    if (key == null || key == "") {
      if (!content is Map) {
        throw ArgumentError('The config root must be a Map');
      }
      _items = content;
    }

    List<String> splits = key.split(".");
    dynamic cur = _items;

    // go to the position in _items
    for (var i = 0; i < splits.length - 1; i++) {
      String s = splits[i];

      if (cur == null) {
        // create a node

      } else if (cur is Map) {
        if (cur[s] == null) {
          cur[s] = {};
        }
        cur = cur[s];
      } else if (cur is List) {
        var index = int.parse(s);
        if (index > (cur as List).length) {
          throw RangeError.value(index, 'List', cur.toString());
        } else if (index == (cur as List).length) {
          (cur as List).add(Map());
        }
        cur = cur[index];
      } else {
        // cannot go deeper
        throw ArgumentError('Cannot reach key [$key] in config');
      }
    }

    if (cur is Map) {
      cur[splits.last] = content;
    } else if (cur is List) {
      var index = int.parse(splits.last);
      if (index > cur.length) {
        throw RangeError.value(index, 'List', cur.toString());
      } else if (index == cur.length) {
        cur.add(content);
      } else {
        cur[index] = content;
      }
    } else {
      throw ArgumentError('Cannot reach key [$key] in config');
    }

    return _items;
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
  }

  Future _init() {
    return _loadConfigFile().then((fileContent) {
      if (fileContent == "") {
        _config = Config(items: {});
      } else {
        dynamic decoded;
        try {
          decoded = jsonDecode(fileContent);
        } catch (err) {
          throw err;
        }

        if (decoded is Map) {
          _config = Config(items: decoded);
        } else {
          _config = Config(items: {});
        }
      }

      _loadComplete = true;
    });
  }

  Future<String> _loadConfigFile();

  Future<Config> getConfig() {
    if (!_loadComplete) {
      return _init().then((value) => _config);
    }
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

/// Load config file from local file system
class FileConfigLoader extends ConfigLoader {
  String encoding;
  FileConfigLoader(String file, {this.encoding = 'utf-8'}) : super(file);

  @override
  Future<String> _loadConfigFile() {
    var f = File(file);
    if (f.existsSync()) {
      return f.readAsString(encoding: Encoding.getByName(encoding));
    } else {
      return Future.value("");
    }
  }
}

