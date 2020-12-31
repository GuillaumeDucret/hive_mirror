// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:io';

import 'package:async/async.dart';

abstract class GitPatchInterface {
  Stream<List<int>> format([String baseRevision]);
  bool filter(String filePath);
  dynamic decode(String filePath, String line);
  dynamic decodeKey(String filePath, String line);
}

class GitPatch implements GitPatchInterface {
  final File _file;
  final String _uriTemplate;
  final String _initialBaseRevision;
  final Filter _filter;
  final Decode _decode;
  final DecodeKey _decodeKey;

  GitPatch.file(File file, {Filter filter, Decode decode, DecodeKey decodeKey})
      : _file = file,
        _uriTemplate = null,
        _initialBaseRevision = null,
        _filter = filter,
        _decode = decode,
        _decodeKey = decodeKey;

  GitPatch.uri(String uriTemplate,
      {String initialBaseRevision = 'initial',
      Filter filter,
      Decode decode,
      DecodeKey decodeKey})
      : _file = null,
        _uriTemplate = uriTemplate,
        _initialBaseRevision = initialBaseRevision,
        _filter = filter,
        _decode = decode,
        _decodeKey = decodeKey;

  factory GitPatch.githubCompareView(String userName, String repoName,
      {String initialBaseRevision = 'initial',
      String compareRevision = 'master',
      Filter filter,
      Decode decode,
      DecodeKey decodeKey}) {
    final _uriTemplate =
        'https://github.com/$userName/$repoName/compare/\$baseRevision..$compareRevision.patch';
    return GitPatch.uri(_uriTemplate,
        initialBaseRevision: initialBaseRevision,
        filter: filter,
        decode: decode,
        decodeKey: decodeKey);
  }

  @override
  Stream<List<int>> format([String baseRevision]) {
    baseRevision ??= _initialBaseRevision;

    if (_file != null) {
      return _file.openRead();
    }

    if (_uriTemplate != null) {
      return LazyStream(() async {
        final uri =
            Uri.parse(_uriTemplate.replaceAll('\$baseRevision', baseRevision));
        final request = await HttpClient().getUrl(uri);
        return request.close();
      });
    }

    throw StateError('Invalid GitPatch');
  }

  @override
  bool filter(String filePath) => _filter?.call(filePath) ?? true;

  @override
  dynamic decode(String filePath, String line) => _decode(filePath, line);

  @override
  dynamic decodeKey(String filePath, String line) => _decodeKey(filePath, line);
}

typedef bool Filter(String filePath);
typedef dynamic Decode(String filePath, String line);
typedef dynamic DecodeKey(String filePath, String line);
