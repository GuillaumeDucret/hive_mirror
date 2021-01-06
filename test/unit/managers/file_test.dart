// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:hive_mirror/src/managers/file.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../file_descriptors.dart';
import '../mocks.dart';

const etagMeta = FileMirrorManager.etagMeta;

void main() {
  group('FileMirrorManager load()', () {
    test('file with new etag', () async {
      final handler = MirrorHandlerMock<String>();
      final metadata = MetadataMock();
      final manager = FileMirrorManager.withHandler(handler, metadata);

      await manager.loadFile(Load2FileDescriptor.primitive());

      verify(metadata.get(etagMeta));
      verify(handler.clear());
      verify(handler.putAll(argThat(equals(Load2FileDescriptor.loadMap))));
      verify(metadata.put(etagMeta, Load2FileDescriptor.etagValue));
    });

    test('file with previous etag', () async {
      final handler = MirrorHandlerMock<String>();
      final metadata = MetadataMock();
      final manager = FileMirrorManager.withHandler(handler, metadata);

      when(metadata.get(etagMeta)).thenReturn(Load2FileDescriptor.etagValue);

      await manager.loadFile(Load2FileDescriptor.primitive());

      verify(metadata.get(etagMeta));
      verifyNever(handler.clear());
      verifyNever(handler.putAll(any));
      verifyNever(metadata.put(any, any));
    });
  });
}
