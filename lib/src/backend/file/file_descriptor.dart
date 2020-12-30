import 'dart:io';

import 'package:async/async.dart';

abstract class FileDescriptorInterface {
  Stream<List<int>> open(String eTag);
  String get etag;
  dynamic decode(String line);
  dynamic decodeKey(String line);
}

class FileDescriptor implements FileDescriptorInterface {
  final File _file;
  final Uri _uri;
  final Decode _decode;
  final DecodeKey _decodeKey;
  String _eTag;

  FileDescriptor.file(File file, {Decode decode, DecodeKey decodeKey})
      : _file = file,
        _uri = null,
        _decode = decode,
        _decodeKey = decodeKey;

  FileDescriptor.uri(Uri uri, {Decode decode, DecodeKey decodeKey})
      : _file = null,
        _uri = uri,
        _decode = decode,
        _decodeKey = decodeKey;

  Stream<List<int>> open(String eTag) {
    if (_file != null) {
      return LazyStream(() async {
        _eTag = (await _file.lastModified()).millisecondsSinceEpoch.toString();
        return _file.openRead();
      });
    }

    if (_uri != null) {
      return LazyStream(() async {
        final request = await HttpClient().getUrl(_uri);
        request.headers.set(HttpHeaders.ifNoneMatchHeader, eTag);

        final response = await request.close();
        _eTag = response.headers.value(HttpHeaders.etagHeader);
        return response;
      });
    }

    throw StateError('Invalid FileDescriptor');
  }

  String get etag {
    if (_eTag != null) return _eTag;
    throw StateError('etag must be called after open()');
  }

  dynamic decode(String line) => _decode(line);
  dynamic decodeKey(String line) => _decodeKey(line);
}

typedef dynamic Decode(String line);
typedef dynamic DecodeKey(String line);
