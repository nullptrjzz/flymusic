
import 'package:flutter_test/flutter_test.dart';
import 'package:flymusic/util/config_loader.dart';

void main() {
  Config config = new Config(items: {
    'a': {
      'b': 1,
      'c': [0, 1, 2]
    }
  });

  test('测试Config()类对配置文件的加载和解析', () {
    expect(config.get('a.b'), 1);
    expect(config.get('a.c.2'), 2);
    expect(config.get('a.d'), null);
    expect(config.get('a.c.2.0'), null);
  });

  var i = 1;
  Future.doWhile(() {
    i++;
    print('i = $i');
    return i < 5;
  });
}