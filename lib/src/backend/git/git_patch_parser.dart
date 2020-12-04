import 'dart:async';

import 'git_patch.dart';

class Commit {
  final String revision;
  final diffs = <Diff>[];

  Commit(this.revision);
}

class Diff {
  final String path;
  final addLines = <String>[];
  final removeLines = <String>[];

  Diff(this.path);
}

class Chunk {
  final addLines = <String>[];
  final removeLines = <String>[];
}

class _GitPatchParserSink implements EventSink<String> {
  final EventSink<Commit> _sink;
  final Filter _filter;

  Commit _commit;
  Diff _diff;
  Chunk _chunk;

  _GitPatchParserSink(EventSink<Commit> sink, {Filter filter})
      : _sink = sink,
        _filter = filter ?? (() => true);

  void add(String line) {
    if (line.startsWith('From ')) {
      _exitChunk();
      _exitDiff();
      _exitCommit();
      _enterCommit(line);
    } else if (line.startsWith("diff ")) {
      _exitChunk();
      _exitDiff();
      _enterDiff(line);
    } else if (line.startsWith("@@ ")) {
      _exitChunk();
      _enterChunk(line);
    } else if (line.startsWith("+")) {
      _addLine(line);
    } else if (line.startsWith("-")) {
      _removeLine(line);
    }
  }

  void addError(e, [st]) {
    _sink.addError(e, st);
  }

  void close() {
    _exitChunk();
    _exitDiff();
    _exitCommit();

    _sink.close();
  }

  void _enterCommit(String line) {
    final match = _commitRegExp.firstMatch(line);

    if (match != null) {
      final revision = match.group(1);
      _commit = Commit(revision);
    }
  }

  void _exitCommit() {
    if (_commit != null) {
      _sink.add(_commit);
      _commit = null;
    }
  }

  void _enterDiff(String line) {
    if (_commit != null) {
      final match = _diffRegExp.firstMatch(line);

      if (match != null) {
        final path = match.group(1);
        if (_filter(path)) {
          _diff = Diff(path);
        }
      }
    }
  }

  void _exitDiff() {
    if (_diff != null) {
      _commit.diffs.add(_diff);
      _diff = null;
    }
  }

  void _enterChunk(String line) {
    if (_diff != null) {
      _chunk = Chunk();
    }
  }

  void _exitChunk() {
    if (_chunk != null) {
      _diff.addLines.addAll(_chunk.addLines);
      _diff.removeLines.addAll(_chunk.removeLines);
      _chunk = null;
    }
  }

  void _addLine(String line) {
    if (_chunk != null) {
      _chunk.addLines.add(line.substring(1));
    }
  }

  void _removeLine(String line) {
    if (_chunk != null) {
      _chunk.removeLines.add(line.substring(1));
    }
  }

  static final _commitRegExp = RegExp('From ([a-f0-9]{40})');
  static final _diffRegExp = RegExp('diff --git a(/[^\\s]+)');
}

class GitPatchParser extends StreamTransformerBase<String, Commit> {
  final Filter filter;

  GitPatchParser({this.filter});

  Stream<Commit> bind(Stream<String> stream) => Stream<Commit>.eventTransformed(
      stream,
      (EventSink<Commit> sink) => _GitPatchParserSink(sink, filter: filter));
}
