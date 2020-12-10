import 'package:hive_mirror/src/backend/git/git_mirror_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../patches.dart';
import '../../mocks.dart';

const metaHead = GitMirrorManager.metaHead;

void main() {
  group('GitMirrorManager applyPatch()', () {
    test('with addition and removal', () async {
      final handler = MirrorHandlerMock();
      final metadata = MetadataMock();
      final manager = GitMirrorManager.withHandler(handler, metadata);

      await manager.applyPatch(Add2Remove1Patch.primitive());

      verify(metadata.get(metaHead));
      verify(handler.putAll(argThat(equals(Add2Remove1Patch.addMap))));
      verify(handler.deleteAll(argThat(equals(Add2Remove1Patch.removeKeys))));
      verify(metadata.put(metaHead, Add2Remove1Patch.revision));
    });
    test('with update', () async {
      final handler = MirrorHandlerMock();
      final metadata = MetadataMock();
      final manager = GitMirrorManager.withHandler(handler, metadata);

      await manager.applyPatch(Update1Patch.primitive());

      verify(metadata.get(metaHead));
      verify(handler.putAll(argThat(equals(Update1Patch.addMap))));
      verifyNever(handler.deleteAll(any));
      verify(metadata.put(metaHead, Add2Remove1Patch.revision));
    });
    test('with several diffs', () async {
      final handler = MirrorHandlerMock();
      final metadata = MetadataMock();
      final manager = GitMirrorManager.withHandler(handler, metadata);

      await manager.applyPatch(Diff2Patch.primitive());

      verify(metadata.get(metaHead));
      verify(handler.putAll(argThat(equals(Diff2Patch.addMap1))));
      verify(handler.putAll(argThat(equals(Diff2Patch.addMap2))));
      verify(metadata.put(metaHead, Diff2Patch.revision));
    });

    test('with skipped diff', () async {
      final handler = MirrorHandlerMock();
      final metadata = MetadataMock();
      final manager = GitMirrorManager.withHandler(handler, metadata);

      await manager.applyPatch(
          Diff2Patch.primitive(filter: (fn) => fn != Diff2Patch.fileName2));

      verify(metadata.get(metaHead));
      verify(handler.putAll(argThat(equals(Diff2Patch.addMap1))));
      verifyNever(handler.putAll(argThat(equals(Diff2Patch.addMap2))));
      verify(metadata.put(metaHead, Diff2Patch.revision));
    });
  });
}
