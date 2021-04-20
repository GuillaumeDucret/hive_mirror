// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:hive/hive.dart';
import 'package:hive_mirror/hive_mirror.dart';
import 'package:test/test.dart';

import '../patches.dart';
import '../type.dart';

void main() {
  group('Mirror with', () {
    HiveMirror.init('.hive');
    HiveMirror.registerAdapter(TestTypeAdapter());
    test('type adapter', () async {
      await Hive.deleteBoxFromDisk('box');

      final source = Add2Remove1Patch.testType();
      await HiveMirror.mirror(source, BoxMirrorHandler<TestType>('box'));

      final box = await Hive.openBox<TestType>('box');
      expect(box.get('key1')?.value, equals('value1'));
      expect(box.get('key2')?.value, equals('value2'));
    });
  });
}
