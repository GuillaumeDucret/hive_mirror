import 'package:hive_mirror/src/backend/file/file_mirror_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../file_descriptors.dart';
import '../../mocks.dart';

const metaETag = FileMirrorManager.metaEtag;

void main() {
  group('FileMirrorManager load()', () {
    test('file with new etag', () async {
      final handler = MirrorHandlerMock();
      final metadata = MetadataMock();
      final manager = FileMirrorManager.withHandler(handler, metadata);

      await manager.loadFile(Load2FileDescriptor.primitive());

      verify(metadata.get(metaETag));
      verify(handler.clear());
      verify(handler.putAll(argThat(equals(Load2FileDescriptor.loadMap))));
      verify(metadata.put(metaETag, Load2FileDescriptor.etagValue));
    });

    test('file with previous etag', () async {
      final handler = MirrorHandlerMock();
      final metadata = MetadataMock();
      final manager = FileMirrorManager.withHandler(handler, metadata);

      when(metadata.get(metaETag)).thenReturn(Load2FileDescriptor.etagValue);

      await manager.loadFile(Load2FileDescriptor.primitive());

      verify(metadata.get(metaETag));
      verifyNever(handler.clear());
      verifyNever(handler.putAll(any));
      verifyNever(metadata.put(any, any));
    });
  });
}
