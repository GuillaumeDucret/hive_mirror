import 'package:hive_mirror/src/backend/git/git_mirror_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../patches.dart';
import '../../mocks.dart';

const metaHead = GitMirrorManager.metaHead;

void main() {
  group('GitMirrorManager mirror()', () {
    test('patch with addition and removal', () async {
      final handler = MirrorHandlerMock();
      final metadata = MetadataMock();
      final manager = GitMirrorManager(handler, metadata);

      await manager.applyPatch(Add2Remove1Patch.primitive());

      verify(handler.putAll(argThat(equals(Add2Remove1Patch.addMap))));
      verify(handler.deleteAll(argThat(equals(Add2Remove1Patch.removeKeys))));
      verify(metadata.put(metaHead, Add2Remove1Patch.revision));
    });
    test('patch with update', () async {
      final handler = MirrorHandlerMock();
      final metadata = MetadataMock();
      final manager = GitMirrorManager(handler, metadata);

      await manager.applyPatch(Update1Patch.primitive());

      verify(handler.putAll(argThat(equals(Update1Patch.addMap))));
      verifyNever(handler.deleteAll(any));
      verify(metadata.put(metaHead, Add2Remove1Patch.revision));
    });
  });
}
