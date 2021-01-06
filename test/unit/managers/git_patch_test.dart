// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:hive_mirror/src/managers/git_patch.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../patches.dart';
import '../mocks.dart';

const headMeta = GitMirrorManager.headMeta;

void main() {
  group('GitMirrorManager applyPatch()', () {
    test('with addition and removal', () async {
      final handler = MirrorHandlerMock<String>();
      final metadata = MetadataMock();
      final manager = GitMirrorManager.withHandler(handler, metadata);

      await manager.applyPatch(Add2Remove1Patch.primitive());

      verify(metadata.get(headMeta));
      verify(handler.putAll(argThat(equals(Add2Remove1Patch.addMap))));
      verify(handler.deleteAll(argThat(equals(Add2Remove1Patch.removeKeys))));
      verify(metadata.put(headMeta, Add2Remove1Patch.revision));
    });
    test('with update', () async {
      final handler = MirrorHandlerMock<String>();
      final metadata = MetadataMock();
      final manager = GitMirrorManager.withHandler(handler, metadata);

      await manager.applyPatch(Update1Patch.primitive());

      verify(metadata.get(headMeta));
      verify(handler.putAll(argThat(equals(Update1Patch.addMap))));
      verifyNever(handler.deleteAll(any));
      verify(metadata.put(headMeta, Add2Remove1Patch.revision));
    });
    test('with several diffs', () async {
      final handler = MirrorHandlerMock<String>();
      final metadata = MetadataMock();
      final manager = GitMirrorManager.withHandler(handler, metadata);

      await manager.applyPatch(Diff2Patch.primitive());

      verify(metadata.get(headMeta));
      verify(handler.putAll(argThat(equals(Diff2Patch.addMap1))));
      verify(handler.putAll(argThat(equals(Diff2Patch.addMap2))));
      verify(metadata.put(headMeta, Diff2Patch.revision));
    });

    test('with skipped diff', () async {
      final handler = MirrorHandlerMock<String>();
      final metadata = MetadataMock();
      final manager = GitMirrorManager.withHandler(handler, metadata);

      await manager.applyPatch(
          Diff2Patch.primitive(filter: (fn) => fn != Diff2Patch.fileName2));

      verify(metadata.get(headMeta));
      verify(handler.putAll(argThat(equals(Diff2Patch.addMap1))));
      verifyNever(handler.putAll(argThat(equals(Diff2Patch.addMap2))));
      verify(metadata.put(headMeta, Diff2Patch.revision));
    });
  });
}
