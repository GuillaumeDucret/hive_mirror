import 'dart:convert';

import '../../handler_holder.dart';
import '../../hive_mirror.dart';
import '../../metadata.dart';
import '../mirror_manager.dart';
import 'git_patch.dart';
import 'git_patch_parser.dart';

class GitMirrorManager implements MirrorManager {
  final MirrorHandlerHolder _handler;
  final Metadata _metadata;

  GitMirrorManager(MirrorHandler handler, Metadata metadata)
      : _handler = MirrorHandlerHolder(handler),
        _metadata = metadata;

  Future<void> mirror(dynamic patch) => applyPatch(patch);

  Future<void> applyPatch(GitPatchInterface patch) async {
    final revision = _metadata.get(metaHead) ?? initialRevision;
    final commits = patch
        .format(revision)
        .transform(Utf8Decoder())
        .transform(LineSplitter())
        .transform(GitPatchParser(filter: patch.filter));

    try {
      await for (Commit commit in commits) {
        await _applyCommit(commit, patch.decode, patch.decodeKey);
      }
    } finally {
      await _handler.dispose();
    }
  }

  Future<void> _applyCommit(
      Commit commit, Decode decode, DecodeKey decodeKey) async {
    for (Diff diff in commit.diffs) {
      await _applyDiff(diff, decode, decodeKey);
    }
    await _metadata.put(metaHead, commit.revision);
  }

  Future<void> _applyDiff<T>(
      Diff diff, Decode decode, DecodeKey decodeKey) async {
    MapEntry decodeAddLine(String line) {
      final object = decode(diff.path, line);
      final key = decodeKey(diff.path, line);
      return MapEntry(key, object);
    }

    dynamic decodeRemoveLine(String line) => decodeKey(diff.path, line);

    final putEntries = Map.fromEntries(diff.addLines.map(decodeAddLine));
    final deleteOrPutKeys = Set.from(diff.removeLines.map(decodeRemoveLine));
    final deleteKeys = deleteOrPutKeys.difference(Set.from(putEntries.keys));

    if (putEntries.isNotEmpty) {
      await (await _handler.use()).putAll(putEntries);
    }

    if (deleteKeys.isNotEmpty) {
      await (await _handler.use()).deleteAll(deleteKeys);
    }
  }

  static const metaHead = 'head';
  static const initialRevision = 'initial';
}
