// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:io';

import 'package:hive_mirror/src/datasource/file.dart';

import 'type.dart';

abstract class TestFileDescriptorBase implements FileDescriptorInterface {
  @override
  final etag;

  final String _filePath;
  final FileDecode _decode;
  final FileDecodeKey _decodeKey;

  TestFileDescriptorBase._(
      this.etag, this._filePath, this._decode, this._decodeKey);

  @override
  Stream<List<int>> open(String _) => File(_filePath).openRead();

  @override
  dynamic decode(String line) => _decode(line);

  @override
  dynamic decodeKey(String line) => _decodeKey(line);
}

class Load2FileDescriptor extends TestFileDescriptorBase {
  Load2FileDescriptor.primitive()
      : super._(etagValue, filePath, _decodePrimitive, _decodeKey);
  Load2FileDescriptor.testType()
      : super._(etagValue, filePath, _decodeTestType, _decodeKey);

  static const filePath = 'test/assets/load2.yaml';
  static const etagValue = 'etag_value';
  static const loadMap = {'key1': 'value1', 'key2': 'value2'};
}

String _decodePrimitive(String line) {
  final tupple = line.split(':');
  return tupple[1].trim();
}

TestType _decodeTestType(String line) {
  final tupple = line.split(':');
  return TestType(tupple[0].trim(), tupple[1].trim());
}

String _decodeKey(String line) {
  final tupple = line.split(':');
  return tupple[0].trim();
}
