// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:hive/hive.dart';

import 'backend/mirror_manager.dart';
import 'hive_mirror.dart';
import 'metadata.dart';

abstract class Remote {
  static void init(InitMessage message) {
    Hive.init(message.homePath);
  }

  static void registerAdapter(RegisterAdapterMessage message) {
    message.adapters.forEach(Hive.registerAdapter);
  }

  static Future<void> mirror(MirrorMessage message) async {
    final metadata = await Metadata.open(message.handler);
    final manager = MirrorManager.fromSource(message.source,
        handler: message.handler, metadata: metadata);

    await manager.mirror(message.source);
  }
}

class InitMessage {
  final String homePath;

  InitMessage(this.homePath);
}

class RegisterAdapterMessage {
  final Set<TypeAdapter> adapters;

  RegisterAdapterMessage(this.adapters);
}

class MirrorMessage {
  final dynamic source;
  final MirrorHandler handler;

  MirrorMessage(this.source, this.handler);
}
