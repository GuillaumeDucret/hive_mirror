// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:hive/hive.dart';
import 'package:hive_mirror/hive_mirror.dart';
import 'package:test/test.dart';

import '../patches.dart';
import '../type.dart';

void main() {
  group('Extension', () {
    HiveMirror.init('.hive');
    HiveMirror.registerAdapter(TestTypeAdapter());
    test('openMirrorBox()', () async {
      await Hive.deleteBoxFromDisk('box');

      final source = Add2Remove1Patch.testType();
      final box =
          await Hive.openMirrorBox<TestType>('box', mirrorSource: source);

      expect(box.get('key1')?.value, equals('value1'));
      expect(box.get('key2')?.value, equals('value2'));
    });

    test('openLazyMirrorBox()', () async {
      await Hive.deleteBoxFromDisk('box');

      final source = Add2Remove1Patch.testType();
      final box =
          await Hive.openLazyMirrorBox<TestType>('box', mirrorSource: source);

      expect((await box.get('key1'))?.value, equals('value1'));
      expect((await box.get('key2'))?.value, equals('value2'));
    });
  });
}
