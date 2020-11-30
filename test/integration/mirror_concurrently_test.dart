import 'package:hive/hive.dart';
import 'package:hive_mirror/hive_mirror.dart';
import 'package:test/test.dart';

import '../patches.dart';

void main() {
  group('Mirror concurrently', () {
    test('same box', () async {
      HiveMirror.init('.hive');
      await Hive.deleteBoxFromDisk('box');

      final source = Add2Remove1Patch.primitive();

      final future1 = HiveMirror.mirror(source, BoxMirrorHandler('box'));
      final future2 = HiveMirror.mirror(source, BoxMirrorHandler('box'));

      expect(future1, equals(future2));
      await Future.wait([future1, future2]);
    });

    test('different boxes', () async {
      HiveMirror.init('.hive');
      await Hive.deleteBoxFromDisk('box1');
      await Hive.deleteBoxFromDisk('box2');

      final source = Add2Remove1Patch.primitive();

      final future1 = HiveMirror.mirror(source, BoxMirrorHandler('box1'));
      final future2 = HiveMirror.mirror(source, BoxMirrorHandler('box2'));

      expect(future1, isNot(equals(future2)));
      await Future.wait([future1, future2]);
    });
  });
}