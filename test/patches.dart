// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:io';

import 'package:hive_mirror/src/backend/git/git_patch.dart';

import 'type.dart';

abstract class TestPatchBase implements GitPatchInterface {
  final String _filePath;
  final Filter _filter;
  final Decode _decode;
  final DecodeKey _decodeKey;

  TestPatchBase._(this._filePath, this._decode, this._decodeKey,
      [this._filter]);

  @override
  Stream<List<int>> format([String _]) => File(_filePath).openRead();

  @override
  bool filter(String filePath) => _filter?.call(filePath) ?? true;

  @override
  dynamic decode(String filePath, String line) => _decode(filePath, line);

  @override
  dynamic decodeKey(String filePath, String line) => _decodeKey(filePath, line);
}

class Add2Remove1Patch extends TestPatchBase {
  Add2Remove1Patch.primitive()
      : super._(filePath, _decodePrimitive, _decodeKey);
  Add2Remove1Patch.testType() : super._(filePath, _decodeTestType, _decodeKey);

  static const filePath = 'test/assets/add2_remove1.patch';
  static const revision = '0000000000000000000000000000000000000000';
  static const addMap = {'key1': 'value1', 'key2': 'value2'};
  static const removeKeys = ['key3'];

  // parser fields
  static const path = '/file';
  static const addLines = ['key1=value1', 'key2=value2'];
  static const removeLines = ['key3=value3'];
}

class Update1Patch extends TestPatchBase {
  Update1Patch.primitive() : super._(filePath, _decodePrimitive, _decodeKey);
  Update1Patch.testType() : super._(filePath, _decodeTestType, _decodeKey);

  static const filePath = 'test/assets/update1.patch';
  static const revision = '0000000000000000000000000000000000000000';
  static const addMap = {'key1': 'value2'};
  static const removeKeys = <dynamic>[];
}

class Diff2Patch extends TestPatchBase {
  Diff2Patch.primitive({Filter filter})
      : super._(filePath, _decodePrimitive, _decodeKey, filter);
  Diff2Patch.testType({Filter filter})
      : super._(filePath, _decodeTestType, _decodeKey, filter);

  static const filePath = 'test/assets/diff2.patch';
  static const revision = '0000000000000000000000000000000000000000';
  static const fileName1 = '/file1';
  static const fileName2 = '/file2';
  static const addMap1 = {'key1': 'value1', 'key2': 'value2'};
  static const addMap2 = {'key3': 'value3', 'key4': 'value4'};
  static const removeKeys = <dynamic>[];
}

String _decodePrimitive(String filePath, String line) {
  final tupple = line.split('=');
  return tupple[1];
}

TestType _decodeTestType(String filePath, String line) {
  final tupple = line.split('=');
  return TestType(tupple[0], tupple[1]);
}

String _decodeKey(String filePath, String line) {
  final tupple = line.split('=');
  return tupple[0];
}
