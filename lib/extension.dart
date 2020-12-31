// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:hive_mirror/src/handlers/box_mirror_handler.dart';

import 'hive_mirror.dart';

extension Mirror on HiveInterface {
  Future<Box<E>> openMirrorBox<E>(
    String name, {
    HiveCipher encryptionCipher,
    KeyComparator keyComparator,
    CompactionStrategy compactionStrategy,
    bool crashRecovery = true,
    String path,
    Uint8List bytes,
    @deprecated List<int> encryptionKey,
    dynamic mirrorSource,
  }) async {
    final handler = BoxMirrorHandler<E>(name, path: path);
    await HiveMirror.mirror(mirrorSource, handler);

    if (keyComparator != null && compactionStrategy != null) {
      return openBox(
        name,
        encryptionCipher: encryptionCipher,
        keyComparator: keyComparator,
        compactionStrategy: compactionStrategy,
        crashRecovery: crashRecovery,
        path: path,
        bytes: bytes,
        encryptionKey: encryptionKey,
      );
    }

    if (keyComparator != null) {
      return openBox(
        name,
        encryptionCipher: encryptionCipher,
        keyComparator: keyComparator,
        crashRecovery: crashRecovery,
        path: path,
        bytes: bytes,
        encryptionKey: encryptionKey,
      );
    }

    if (compactionStrategy != null) {
      return openBox(
        name,
        encryptionCipher: encryptionCipher,
        compactionStrategy: compactionStrategy,
        crashRecovery: crashRecovery,
        path: path,
        bytes: bytes,
        encryptionKey: encryptionKey,
      );
    }

    return openBox(
      name,
      encryptionCipher: encryptionCipher,
      crashRecovery: crashRecovery,
      path: path,
      bytes: bytes,
      encryptionKey: encryptionKey,
    );
  }

  Future<LazyBox<E>> openLazyMirrorBox<E>(
    String name, {
    HiveCipher encryptionCipher,
    KeyComparator keyComparator,
    CompactionStrategy compactionStrategy,
    bool crashRecovery,
    String path,
    List<int> encryptionKey,
    dynamic mirrorSource,
  }) async {
    final handler = BoxMirrorHandler<E>(name, path: path);
    await HiveMirror.mirror(mirrorSource, handler);

    if (keyComparator != null && compactionStrategy != null) {
      return openLazyBox(
        name,
        encryptionCipher: encryptionCipher,
        keyComparator: keyComparator,
        compactionStrategy: compactionStrategy,
        crashRecovery: crashRecovery,
        path: path,
        encryptionKey: encryptionKey,
      );
    }

    if (keyComparator != null) {
      return openLazyBox(
        name,
        encryptionCipher: encryptionCipher,
        keyComparator: keyComparator,
        crashRecovery: crashRecovery,
        path: path,
        encryptionKey: encryptionKey,
      );
    }

    if (compactionStrategy != null) {
      return openLazyBox(
        name,
        encryptionCipher: encryptionCipher,
        compactionStrategy: compactionStrategy,
        crashRecovery: crashRecovery,
        path: path,
        encryptionKey: encryptionKey,
      );
    }

    return openLazyBox(
      name,
      encryptionCipher: encryptionCipher,
      crashRecovery: crashRecovery,
      path: path,
      encryptionKey: encryptionKey,
    );
  }
}
