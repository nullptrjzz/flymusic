import 'package:flutter_test/flutter_test.dart';
import 'package:flymusic/util/config_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('测试Config()类对配置文件的加载和解析', () {
    Config config = new Config.fromItems(items: {
      'a': {
        'b': 1,
        'c': [0, 1, 2]
      }
    });
    expect(config.get('a.b'), 1);
    expect(config.get('a.c.2'), 2);
    expect(config.get('a.d'), null);
    expect(config.get('a.c.2.0'), null);
  });
  test('测试Config()类的set()函数', () {
    expect(
        Config.fromItems(items: {
          'a': {
            'b': 1,
            'c': [0, 1, 2]
          }
        }).set('a.b', 'theFirst'),
        {
          'a': {
            'b': 'theFirst',
            'c': [0, 1, 2]
          }
        });
    expect(
        Config.fromItems(items: {
          'a': {
            'b': 1,
            'c': [0, 1, 2]
          }
        }).set('a.c.3', 6),
        {
          'a': {
            'b': 1,
            'c': [0, 1, 2, 6]
          }
        });
    expect(
        Config.fromItems(items: {
          'a': {
            'b': 1,
            'c': [0, 1, 2]
          }
        }).set('a.c.2', 6),
        {
          'a': {
            'b': 1,
            'c': [0, 1, 6]
          }
        });
    expect(
        Config.fromItems(items: {
          'a': {
            'b': 1,
            'c': [0, 1, 2]
          }
        }).set('a.d', 6),
        {
          'a': {
            'b': 1,
            'c': [0, 1, 2],
            'd': 6
          }
        });
    expect(
        Config.fromItems(items: {
          'a': {
            'b': 1,
            'c': [0, 1, 2]
          }
        }).set('e', {'t': 'a'}),
        {
          'a': {
            'b': 1,
            'c': [0, 1, 2]
          },
          'e': {'t': 'a'}
        });
    try {
      expect(
          Config.fromItems(items: {
            'a': {
              'b': 1,
              'c': [0, 1, 2]
            }
          }).set('a.c.0.w', [1]),
          {});
    } catch (err) {
      expect(err is Error, true);
    }
  });
  test('测试ConfigLoader()的正常工作', () {
    FileConfigLoader('./test/assets/a.json').getConfig().then((value) {
      expect(value.getAll(), {'a': 'yes'});
    });
    AssetsConfigLoader('test/assets/a.json').getConfig().then((value) {
      expect(value.getAll(), {'a': 'yes'});
    });
  });
  test('测试Config()类对配置文件的合并', () {
    Config config = new Config.fromItems(items: {
      'a': {
        'b': 1,
        'c': [0, 1, 2]
      }
    });
    Config newCfg = new Config.fromItems(items: {
      'a': {
        'b': 2,
        'c': [0, 1, 2, 3],
        'd': [0]
      }
    });
    expect(Config.merge(config, newCfg).getAll(), {
      'a': {
        'b': 1,
        'c': [0, 1, 2, 3],
        'd': [0]
      }
    });
  });
}
