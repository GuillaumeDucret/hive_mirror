// Copyright 2020 Guillaume Ducret. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:hive/hive.dart';

import 'hive_mirror.dart';

class Metadata {
  final String _handlerId;
  final Box<String> _db;

  Metadata._(this._handlerId, this._db);

  String get(String key) => _db.get(_dbKey(key));
  Future<void> put(String key, String value) => _db.put(_dbKey(key), value);

  String _dbKey(String key) => '$_handlerId:$key';

  static Future<Metadata> open(MirrorHandler handler) async {
    final db = await Hive.openBox<String>('.hive_mirror_metadata');
    return Metadata._(handler.id, db);
  }

  static Future<void> close() async {
    final db = Hive.box<String>('.hive_mirror_metadata');
    await db?.close();
  }
}
