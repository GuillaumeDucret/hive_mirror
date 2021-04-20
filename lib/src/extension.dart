// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:hive/hive.dart';

import '../hive_mirror.dart';
import 'handlers/box.dart';

extension Mirror on HiveInterface {
  Future<Box<E>> openMirrorBox<E>(
    String name, {
    HiveCipher? encryptionCipher,
    KeyComparator? keyComparator,
    CompactionStrategy? compactionStrategy,
    bool crashRecovery = true,
    String? path,
    Uint8List? bytes,
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
      );
    }

    return openBox(
      name,
      encryptionCipher: encryptionCipher,
      crashRecovery: crashRecovery,
      path: path,
      bytes: bytes,
    );
  }

  Future<LazyBox<E>> openLazyMirrorBox<E>(
    String name, {
    HiveCipher? encryptionCipher,
    KeyComparator? keyComparator,
    CompactionStrategy? compactionStrategy,
    bool crashRecovery = true,
    String? path,
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
      );
    }

    if (keyComparator != null) {
      return openLazyBox(
        name,
        encryptionCipher: encryptionCipher,
        keyComparator: keyComparator,
        crashRecovery: crashRecovery,
        path: path,
      );
    }

    if (compactionStrategy != null) {
      return openLazyBox(
        name,
        encryptionCipher: encryptionCipher,
        compactionStrategy: compactionStrategy,
        crashRecovery: crashRecovery,
        path: path,
      );
    }

    return openLazyBox(
      name,
      encryptionCipher: encryptionCipher,
      crashRecovery: crashRecovery,
      path: path,
    );
  }
}
