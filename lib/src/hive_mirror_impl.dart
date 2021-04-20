// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:async';

import 'package:hive/hive.dart';
import 'package:hive_mirror/src/isolates.dart';

import 'handlers/dynamic.dart';
import 'hive_mirror.dart';
import 'remote.dart';

class HiveMirrorImpl implements HiveMirrorInterface {
  final _runningHandlers = <String, Future<void>>{};
  final _typeAdapters = <RemoteTypeAdapter>{};
  late String _homePath;

  @override
  void init(String path) {
    Hive.init(path);
    _homePath = path;
  }

  @override
  void registerAdapter<T>(TypeAdapter<T> adapter) async {
    Hive.registerAdapter(adapter);
    _typeAdapters.add(RemoteTypeAdapter<T>(adapter));
  }

  @override
  Future<void> mirror<T>(dynamic source, MirrorHandler<T> handler) {
    if (_runningHandlers[handler.id] == null) {
      _runningHandlers[handler.id] = _mirror(source, handler).whenComplete(() {
        _runningHandlers.remove(handler.id);
      });
    }
    return _runningHandlers[handler.id]!;
  }

  Future<void> _mirror<T>(dynamic source, MirrorHandler<T> handler) async {
    final message = MirrorMessage(
      source,
      DynamicMirrorHandler<T>(handler),
      homePath: _homePath,
      adapters: _typeAdapters,
    );

    return compute(Remote.mirror, message);
  }
}
