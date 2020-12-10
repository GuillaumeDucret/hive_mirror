import 'dart:convert';

import '../../handlers/dynamic_mirror_handler.dart';
import '../../handlers/handler_holder.dart';
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

  static GitMirrorManager withHandler<T>(
      MirrorHandler<T> handler, Metadata metadata) {
    return GitMirrorManager(DynamicMirrorHandler<T>(handler), metadata);
  }

  Future<void> mirror(dynamic patch) => applyPatch(patch);

  Future<void> applyPatch(GitPatchInterface patch) async {
    final head = _metadata.get(metaHead);
    final commits = patch
        .format(head)
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

  Future<void> _applyDiff(Diff diff, Decode decode, DecodeKey decodeKey) async {
    MapEntry decodeAddLine(String line) {
      final key = decodeKey(diff.path, line);
      if (key != null) {
        final object = decode(diff.path, line);
        return MapEntry(key, object);
      }
      return null;
    }

    dynamic decodeRemoveLine(String line) => decodeKey(diff.path, line);

    final putEntries = Map.fromEntries(
        diff.addLines.map(decodeAddLine).where((e) => e != null));
    final deleteOrPutKeys = Set.from(
        diff.removeLines.map(decodeRemoveLine).where((e) => e != null));
    final deleteKeys = deleteOrPutKeys.difference(Set.from(putEntries.keys));

    if (putEntries.isNotEmpty) {
      await (await _handler.use()).putAll(putEntries);
    }

    if (deleteKeys.isNotEmpty) {
      await (await _handler.use()).deleteAll(deleteKeys);
    }
  }

  static const metaHead = 'head';
}
