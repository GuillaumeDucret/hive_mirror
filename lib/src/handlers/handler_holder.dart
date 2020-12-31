// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import '../hive_mirror.dart';

class MirrorHandlerHolder {
  final MirrorHandler _held;
  Future<MirrorHandler> _handler;

  MirrorHandlerHolder(MirrorHandler handler) : _held = handler;

  Future<MirrorHandler> use() => _handler ??= _initHandler();

  Future<void> dispose() async {
    if (_handler != null) {
      try {
        return _handler.then((handler) => handler.dispose());
      } finally {
        _handler = null;
      }
    }
  }

  Future<MirrorHandler> _initHandler() async {
    await _held.init();
    return _held;
  }
}
