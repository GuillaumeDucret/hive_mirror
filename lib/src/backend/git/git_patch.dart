import 'dart:io';

import 'package:async/async.dart';

abstract class GitPatchInterface {
  Stream<List<int>> format(String revision);
  bool filter(String fileName);
  dynamic decode(String fileName, String line);
  dynamic decodeKey(String fileName, String line);
}

class GitPatch implements GitPatchInterface {
  final String _uriTemplate;
  final File _file;
  final Filter _filter;
  final Decode _decode;
  final DecodeKey _decodeKey;

  GitPatch.file(File file, {Filter filter, Decode decode, DecodeKey decodeKey})
      : _file = file,
        _uriTemplate = null,
        _filter = filter ?? (() => true),
        _decode = decode,
        _decodeKey = decodeKey;

  GitPatch.uri(String uriTemplate,
      {Filter filter, Decode decode, DecodeKey decodeKey})
      : _file = null,
        _uriTemplate = uriTemplate,
        _filter = filter ?? (() => true),
        _decode = decode,
        _decodeKey = decodeKey;

  factory GitPatch.githubCompareView(String userName, String repoName,
      {Filter filter, Decode decode, DecodeKey decodeKey}) {
    final _uriTemplate =
        'https://github.com/$userName/$repoName/compare/\$revision..master.patch';
    return GitPatch.uri(_uriTemplate,
        filter: filter, decode: decode, decodeKey: decodeKey);
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
        return request.close();
      });
    }

    throw StateError('Invalid GitPatch');
  }

  @override
  bool filter(String fileName) => _filter(fileName);

  @override
  dynamic decode(String fileName, String line) => _decode(fileName, line);

  @override
  dynamic decodeKey(String fileName, String line) => _decodeKey(fileName, line);
}

typedef Filter = bool Function(String fileName);
typedef Decode = dynamic Function(String fileName, String line);
typedef DecodeKey = dynamic Function(String fileName, String line);
