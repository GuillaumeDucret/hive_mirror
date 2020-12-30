import '../hive_mirror.dart';

class DynamicMirrorHandler<T> implements MirrorHandler {
  final MirrorHandler<T> _delegate;

  DynamicMirrorHandler(MirrorHandler<T> handler) : _delegate = handler;

  @override
  String get id => _delegate.id;

  @override
  Future<void> init() => _delegate.init();

  @override
  Future<void> putAll(Map<dynamic, dynamic> entries) {
    final typedEntries = entries.cast<dynamic, T>();
    return _delegate.putAll(typedEntries);
  }

  @override
  Future<void> deleteAll(Iterable keys) => _delegate.deleteAll(keys);

  @override
  Future<void> clear() => _delegate.clear();

  @override
  Future<void> dispose() => _delegate.dispose();
}
