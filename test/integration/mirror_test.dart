// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:hive/hive.dart';
import 'package:hive_mirror/hive_mirror.dart';
import 'package:test/test.dart';

import '../file_descriptors.dart';
import '../patches.dart';

void main() {
  group('Mirror', () {
    HiveMirror.init('.hive');
    test('patch', () async {
      await Hive.deleteBoxFromDisk('box');

      final source = Add2Remove1Patch.primitive();
      await HiveMirror.mirror(source, BoxMirrorHandler<String>('box'));

      final box = await Hive.openBox<String>('box');
      expect(box.get('key1'), equals('value1'));
      expect(box.get('key2'), equals('value2'));
    });

    test('file', () async {
      await Hive.deleteBoxFromDisk('box');
      await Hive.deleteBoxFromDisk('.hive_mirror');

      final source = Load2FileDescriptor.primitive();
      await HiveMirror.mirror(source, BoxMirrorHandler<String>('box'));

      final box = await Hive.openBox<String>('box');
      expect(box.get('key1'), equals('value1'));
      expect(box.get('key2'), equals('value2'));
    });
  });
}
