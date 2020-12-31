// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:hive/hive.dart';

abstract class HiveMirrorInterface {
  void init(String path);
  void registerAdapter<T>(TypeAdapter<T> adapter);
  Future<void> mirror<T>(dynamic source, MirrorHandler<T> handler);
}

abstract class MirrorHandler<T> {
  String get id;
  Future<void> init();
  Future<void> putAll(Map<dynamic, T> entries);
  Future<void> deleteAll(Iterable<dynamic> keys);
  Future<void> dispose();
}
