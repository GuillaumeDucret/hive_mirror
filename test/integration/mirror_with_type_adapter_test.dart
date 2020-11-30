import 'package:hive/hive.dart';
import 'package:hive_mirror/hive_mirror.dart';
import 'package:test/test.dart';

import '../patches.dart';
import '../type.dart';

void main() {
  group('Mirror with', () {
    test('type adapter', () async {
      HiveMirror.init('.hive');
      HiveMirror.registerAdapter(TestTypeAdapter());
      await Hive.deleteBoxFromDisk('box');

      final source = Add2Remove1Patch.testType();

      await HiveMirror.mirror(source, BoxMirrorHandler('box'));

      final box = await Hive.openBox<TestType>('box');
      expect(box.get('key1').value, equals('value1'));
      expect(box.get('key2').value, equals('value2'));
    });
  });
}
