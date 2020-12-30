import 'package:hive/hive.dart';
import 'package:hive_mirror/hive_mirror.dart';
import 'package:test/test.dart';

import '../file_descriptors.dart';
import '../patches.dart';

void main() {
  group('Mirror', () {
    test('patch', () async {
      HiveMirror.init('.hive');
      await Hive.deleteBoxFromDisk('box');

      final source = Add2Remove1Patch.primitive();
      await HiveMirror.mirror(source, BoxMirrorHandler('box'));

      final box = await Hive.openBox<String>('box');
      expect(box.get('key1'), equals('value1'));
      expect(box.get('key2'), equals('value2'));
    });

    test('file', () async {
      HiveMirror.init('.hive');
      await Hive.deleteBoxFromDisk('box');

      final source = Load2FileDescriptor.primitive();
      await HiveMirror.mirror(source, BoxMirrorHandler('box'));

      final box = await Hive.openBox<String>('box');
      expect(box.get('key1'), equals('value1'));
      expect(box.get('key2'), equals('value2'));
    });
  });
}
