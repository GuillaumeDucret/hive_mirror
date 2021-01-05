// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:convert';

import '../../handlers/dynamic_mirror_handler.dart';
import '../../handlers/handler_holder.dart';
import '../../hive_mirror.dart';
import '../../metadata.dart';
import '../mirror_manager.dart';
import 'file_descriptor.dart';

class FileMirrorManager implements MirrorManager {
  final MirrorHandlerHolder _handler;
  final Metadata _metadata;

  FileMirrorManager(MirrorHandler handler, Metadata metadata)
      : _handler = MirrorHandlerHolder(handler),
        _metadata = metadata;

  static FileMirrorManager withHandler<T>(
      MirrorHandler<T> handler, Metadata metadata) {
    return FileMirrorManager(DynamicMirrorHandler<T>(handler), metadata);
  }

  Future<void> mirror(dynamic fileDescriptor) =>
      loadFile(fileDescriptor as FileDescriptorInterface);

  Future<void> loadFile(FileDescriptorInterface fileDescriptor) async {
    final etag = _metadata.get(metaEtag);
    final fileData = fileDescriptor.open(etag);

    if (fileDescriptor.etag != etag) {
      final lines = fileData.transform(Utf8Decoder()).transform(LineSplitter());

      try {
        await _applyLines(fileDescriptor.etag, await lines.toList(),
            fileDescriptor.decode, fileDescriptor.decodeKey);
      } finally {
        await _handler.dispose();
      }
    }
  }

  Future<void> _applyLines(String etag, Iterable<String> lines, Decode decode,
      DecodeKey decodeKey) async {
    MapEntry<dynamic, dynamic> decodeLine(String line) {
      final dynamic key = decodeKey(line);
      if (key != null) {
        final dynamic object = decode(line);
        return MapEntry<dynamic, dynamic>(key, object);
      }
      return null;
    }

    final putEntries = Map<dynamic, dynamic>.fromEntries(
        lines.map(decodeLine).where((e) => e != null));

    await (await _handler.use()).clear();

    if (putEntries.isNotEmpty) {
      await (await _handler.use()).putAll(putEntries);
    }

    await _metadata.put(metaEtag, etag);
  }

  static const metaEtag = 'etag';
}
