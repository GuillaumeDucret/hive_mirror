import 'dart:io';

import 'package:hive_mirror/src/backend/git/git_patch.dart';

import 'type.dart';

abstract class TestPatchBase implements GitPatchInterface {
  final String _filePath;
  final Filter _filter;
  final Decode _decode;
  final DecodeKey _decodeKey;

  TestPatchBase(this._filePath, this._decode, this._decodeKey, [Filter filter])
      : this._filter = filter ?? (() => true);

  @override
  Stream<List<int>> format(String revision) => File(_filePath).openRead();

  @override
  bool filter(String fileName) => _filter(fileName);

  @override
  dynamic decode(String fileName, String line) => _decode(fileName, line);

  @override
  dynamic decodeKey(String fileName, String line) => _decodeKey(fileName, line);
}

class Add2Remove1Patch extends TestPatchBase {
  Add2Remove1Patch.primitive() : super(filePath, _decodePrimitive, _decodeKey);
  Add2Remove1Patch.testType() : super(filePath, _decodeTestType, _decodeKey);

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
  Update1Patch.primitive() : super(filePath, _decodePrimitive, _decodeKey);
  Update1Patch.testType() : super(filePath, _decodeTestType, _decodeKey);

  static const filePath = 'test/assets/update1.patch';
  static const revision = '0000000000000000000000000000000000000000';
  static const addMap = {'key1': 'value2'};
  static const removeKeys = [];
}

class Diff2Patch extends TestPatchBase {
  Diff2Patch.primitive({Filter filter})
      : super(filePath, _decodePrimitive, _decodeKey, filter);
  Diff2Patch.testType({Filter filter})
      : super(filePath, _decodeTestType, _decodeKey, filter);

  static const filePath = 'test/assets/diff2.patch';
  static const revision = '0000000000000000000000000000000000000000';
  static const fileName1 = '/file1';
  static const fileName2 = '/file2';
  static const addMap1 = {'key1': 'value1', 'key2': 'value2'};
  static const addMap2 = {'key3': 'value3', 'key4': 'value4'};
  static const removeKeys = [];
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
