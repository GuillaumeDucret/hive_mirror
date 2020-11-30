import 'dart:io';

import 'package:async/async.dart';

abstract class GitPatchInterface {
  Stream<List<int>> format(String revision);
  dynamic decode(String fileName, String line);
  dynamic decodeKey(String fileName, String line);
}

class GitPatch implements GitPatchInterface {
  final String _uriTemplate;
  final File _file;
  final Decode _decode;
  final DecodeKey _decodeKey;

  GitPatch.file(File file, {Decode decode, DecodeKey decodeKey})
      : _file = file,
        _uriTemplate = null,
        _decode = decode,
        _decodeKey = decodeKey;

  GitPatch.uri(String uriTemplate, {Decode decode, DecodeKey decodeKey})
      : _file = null,
        _uriTemplate = uriTemplate,
        _decode = decode,
        _decodeKey = decodeKey;

  factory GitPatch.githubCompareView(String userName, String repoName,
      {Decode decode, DecodeKey decodeKey}) {
    final _uriTemplate = '$userName/$repoName';
    return GitPatch.uri(_uriTemplate, decode: decode, decodeKey: decodeKey);
  }

  @override
  Stream<List<int>> format(String revision) {
    if (_file != null) {
      return _file.openRead();
    }

    if (_uriTemplate != null) {
      return LazyStream(() async {
        final uri = Uri.parse(_uriTemplate.replaceAll('\$revision', revision));
        final request = await HttpClient().getUrl(uri);
        final response = await request.close();
        return response;
      });
    }

    throw StateError('Invalid GitPatch');
  }

  @override
  dynamic decode(String fileName, String line) => _decode(fileName, line);

  @override
  dynamic decodeKey(String fileName, String line) => _decodeKey(fileName, line);
}

typedef Decode = dynamic Function(String fileName, String line);
typedef DecodeKey = dynamic Function(String fileName, String line);
