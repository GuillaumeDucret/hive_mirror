import 'package:hive/hive.dart';

import '../hive_mirror.dart';

class BoxMirrorHandler<T> implements MirrorHandler<T> {
  final String name;
  final String path;
  LazyBox<T> _box;

  BoxMirrorHandler(this.name, {this.path});

  @override
  String get id => name;

  @override
  Future<void> init() async {
    _box = await Hive.openLazyBox<T>(name, path: path);
  }

  @override
  Future<void> putAll(Map<dynamic, T> entries) => _box.putAll(entries);

  @override
  Future<void> deleteAll(Iterable keys) => _box.deleteAll(keys);

  @override
  Future<void> clear() => _box.clear();

  @override
  Future<void> dispose() => _box.close();
}
