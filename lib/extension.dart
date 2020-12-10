import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:hive_mirror/src/handlers/box_mirror_handler.dart';

import 'hive_mirror.dart';

extension Mirror on HiveInterface {
  Future<Box<E>> openMirrorBox<E>(String name,
      {HiveCipher encryptionCipher,
      KeyComparator keyComparator,
      CompactionStrategy compactionStrategy,
      bool crashRecovery,
      String path,
      Uint8List bytes,
      dynamic mirrorSource}) async {
    await HiveMirror.mirror(mirrorSource, BoxMirrorHandler(name, path: path));

    return openBox(name,
        encryptionCipher: encryptionCipher,
        keyComparator: keyComparator,
        compactionStrategy: compactionStrategy,
        crashRecovery: crashRecovery,
        path: path,
        bytes: bytes);
  }
}
