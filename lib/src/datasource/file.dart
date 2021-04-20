// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:io';

import 'package:async/async.dart';

abstract class FileDescriptorInterface {
  Stream<List<int>> open(String? eTag);
  String get etag;
  dynamic decode(String line);
  dynamic decodeKey(String line);
}

class FileDescriptor implements FileDescriptorInterface {
  final File? _file;
  final Uri? _uri;
  final FileDecode _decode;
  final FileDecodeKey _decodeKey;
  String? _eTag;

  FileDescriptor.file(
    File file, {
    required FileDecode decode,
    required FileDecodeKey decodeKey,
  })   : _file = file,
        _uri = null,
        _decode = decode,
        _decodeKey = decodeKey;

  FileDescriptor.uri(
    Uri uri, {
    required FileDecode decode,
    required FileDecodeKey decodeKey,
  })   : _file = null,
        _uri = uri,
        _decode = decode,
        _decodeKey = decodeKey;

  Stream<List<int>> open(String? eTag) {
    if (_file != null) {
      return LazyStream(() async {
        _eTag = (await _file!.lastModified()).millisecondsSinceEpoch.toString();
        return _file!.openRead();
      });
    }

    if (_uri != null) {
      return LazyStream(() async {
        final request = await HttpClient().getUrl(_uri!);
        if (eTag != null) {
          request.headers.set(HttpHeaders.ifNoneMatchHeader, eTag);
        }

        final response = await request.close();
        _eTag = response.headers.value(HttpHeaders.etagHeader);
        return response;
      });
    }

    throw StateError('Invalid FileDescriptor');
  }

  String get etag {
    if (_eTag != null) return _eTag!;
    throw StateError('etag must be called after open()');
  }

  dynamic decode(String line) => _decode(line);
  dynamic decodeKey(String line) => _decodeKey(line);
}

typedef dynamic FileDecode(String line);
typedef dynamic FileDecodeKey(String line);
