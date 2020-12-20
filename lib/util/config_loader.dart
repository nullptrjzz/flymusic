import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

/// Save the config in memory
class Config {
  Map _items;

  Config();

  Config.fromItems({Map items}) {
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
          if (int.parse(s) >= (cur as List).length) return null;
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

  static Config merge(Config old, Config theNew) {
    // Add only the different part
    if (old._items == null || old._items.isEmpty) {
      return theNew;
    }

    Queue q = Queue();
    q.addAll(theNew._items.keys);
    while (q.isNotEmpty) {
      dynamic key = q.removeFirst();
      dynamic theOldItem = old.get(key);
      dynamic theNewItem = theNew.get(key);
      if (theOldItem == null) {
        old.set(key, theNewItem);
        continue;
      }

      if (theNewItem is Map) {
        // add all keys
        for (var k in theNewItem.keys) {
          q.add('$key.$k');
        }
      } else if (theNewItem is List) {
        // add all indexes
        for (var i = 0; i < theNewItem.length; i++) {
          q.add('$key.$i');
        }
      } else {
        if (old.get(key) == null) {
          old.set(key, theNewItem);
        }
      }
    }

    return old;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Config &&
          runtimeType == other.runtimeType &&
          _items == other._items;

  @override
  int get hashCode => _items.hashCode;
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
        _config = Config.fromItems(items: {});
      } else {
        dynamic decoded;
        try {
          decoded = jsonDecode(fileContent);
        } catch (err) {
          throw err;
        }

        if (decoded is Map) {
          _config = Config.fromItems(items: decoded);
        } else {
          _config = Config.fromItems(items: {});
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

  int lastWriteTime = 0;
  int writeLimit = 3000; // 3s
  Config writeQueue;
  bool timer = false;

  @override
  Future<String> _loadConfigFile() {
    var f = File(file);
    if (f.existsSync()) {
      return f.readAsString(encoding: Encoding.getByName(encoding));
    } else {
      return Future.value("");
    }
  }

  Future<dynamic> saveConfigFile(Config cfg) {
    var f = File(file);
    if (!f.existsSync()) {
      f.createSync(recursive: true);
    }
    f.writeAsString(jsonEncode(cfg._items), flush: true);
    return null;
  }

  /// 通过令牌桶方式限制写入频率
  void saveConfigFileAsync(Config cfg) {
    if (DateTime.now().millisecondsSinceEpoch - lastWriteTime > writeLimit) {
      writeQueue = null;
      lastWriteTime = DateTime.now().millisecondsSinceEpoch;
      saveConfigFile(cfg);
    } else {
      // 加入待写入队列，防止最后一次修改被抛弃
      writeQueue = cfg;
      if (!timer) {
        timer = true;
        Timer(Duration(milliseconds: writeLimit), () {
          if (writeQueue != null) {
            saveConfigFileAsync(writeQueue);
          }
          timer = false;
        });
      }
    }
  }
}

