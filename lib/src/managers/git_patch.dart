// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:convert';

import '../convert/git_patch_parser.dart';
import '../datasource/git_patch.dart';
import '../handlers/dynamic.dart';
import '../handlers/handler_holder.dart';
import '../hive_mirror.dart';
import '../metadata.dart';
import 'mirror_manager.dart';

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

  Future<void> mirror(dynamic patch) => applyPatch(patch as GitPatchInterface);

  Future<void> applyPatch(GitPatchInterface patch) async {
    final head = _metadata.get(headMeta);
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
      Commit commit, PatchDecode decode, PatchDecodeKey decodeKey) async {
    for (Diff diff in commit.diffs) {
      await _applyDiff(diff, decode, decodeKey);
    }
    await _metadata.put(headMeta, commit.revision);
  }

  Future<void> _applyDiff(
      Diff diff, PatchDecode decode, PatchDecodeKey decodeKey) async {
    MapEntry<dynamic, dynamic> decodeAddLine(String line) {
      final dynamic key = decodeKey(diff.path, line);

      if (key != null) {
        final dynamic object = decode(diff.path, line);
        return MapEntry<dynamic, dynamic>(key, object);
      }
      return null;
    }

    dynamic decodeRemoveLine(String line) => decodeKey(diff.path, line);

    final putEntries = Map<dynamic, dynamic>.fromEntries(
        diff.addLines.map(decodeAddLine).where((e) => e != null));
    final deleteOrPutKeys = Set<dynamic>.from(diff.removeLines
        .map<dynamic>(decodeRemoveLine)
        .where((dynamic e) => e != null));
    final deleteKeys = deleteOrPutKeys.difference(Set.from(putEntries.keys));

    if (putEntries.isNotEmpty) {
      await (await _handler.use()).putAll(putEntries);
    }

    if (deleteKeys.isNotEmpty) {
      await (await _handler.use()).deleteAll(deleteKeys);
    }
  }

  static const headMeta = 'git_head';
}
