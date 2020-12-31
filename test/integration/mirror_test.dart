// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:hive/hive.dart';
import 'package:hive_mirror/hive_mirror.dart';
import 'package:test/test.dart';

import '../patches.dart';

void main() {
  group('Mirror', () {
    test('box', () async {
      HiveMirror.init('.hive');
      await Hive.deleteBoxFromDisk('box');

      final source = Add2Remove1Patch.primitive();
      await HiveMirror.mirror(source, BoxMirrorHandler('box'));

      final box = await Hive.openBox<String>('box');
      expect(box.get('key1'), equals('value1'));
      expect(box.get('key2'), equals('value2'));
    });
  });
}
