import 'dart:io';

import 'package:hive_mirror/src/backend/git/git_patch.dart';

import 'type.dart';

abstract class TestPatchBase implements GitPatchInterface {
  final String _filePath;
  final Decode _decode;
  final DecodeKey _decodeKey;

  TestPatchBase(
      String this._filePath, Decode this._decode, DecodeKey this._decodeKey);

  @override
  Stream<List<int>> format(String revision) => File(_filePath).openRead();

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
