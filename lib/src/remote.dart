// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:hive/hive.dart';

import 'managers/mirror_manager.dart';
import 'hive_mirror.dart';
import 'metadata.dart';

abstract class Remote {
  static Future<void> mirror(MirrorMessage message) async {
    Hive.init(message.homePath);
    message.adapters.forEach((a) => a.register());

    final metadata = await Metadata.open(message.handler);
    final manager = MirrorManager.fromSource(message.source,
        handler: message.handler, metadata: metadata);

    await manager.mirror(message.source);
  }
}

class MirrorMessage {
  const MirrorMessage(
    this.source,
    this.handler, {
    required this.homePath,
    required this.adapters,
  });

  final dynamic source;
  final MirrorHandler handler;
  final String homePath;
  final Set<RemoteTypeAdapter> adapters;
}

class RemoteTypeAdapter<T> {
  const RemoteTypeAdapter(this.delegate);

  final TypeAdapter<T> delegate;

  void register() => Hive.registerAdapter(delegate);
}
