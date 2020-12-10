import 'dart:async';

import 'package:hive/hive.dart';
import 'package:isolate/isolate.dart';

import 'handlers/dynamic_mirror_handler.dart';
import 'hive_mirror.dart';
import 'remote.dart';

class HiveMirrorImpl implements HiveMirrorInterface {
  final _runningHandlers = <String, Future<void>>{};
  final _typeAdapters = <TypeAdapter>{};

  Future<IsolateRunner> _runner;
  String _homePath;

  @override
  void init(String path) {
    Hive.init(path);
    _homePath = path;
  }

  @override
  void registerAdapter<T>(TypeAdapter<T> adapter) async {
    Hive.registerAdapter(adapter);
    _typeAdapters.add(adapter);

    if (_isRunning) {
      final runner = await _useRunner();
      runner.run(Remote.registerAdapter, RegisterAdapterMessage({adapter}));
    }
  }

  @override
  Future<void> mirror<T>(dynamic source, MirrorHandler<T> handler) {
    if (_runningHandlers[handler.id] == null) {
      _runningHandlers[handler.id] = _mirror(source, handler).whenComplete(() {
        _runningHandlers.remove(handler.id);
        _closeRunnerIfComplete();
      });
    }
    return _runningHandlers[handler.id];
  }

  Future<void> _mirror<T>(dynamic source, MirrorHandler<T> handler) async {
    final runner = await _useRunner();
    await runner.run(
        Remote.mirror, MirrorMessage(source, DynamicMirrorHandler<T>(handler)));
  }

  bool get _isRunning => _runner != null;

  Future<IsolateRunner> _useRunner() => _runner ??= _spawnRunner();

  Future<IsolateRunner> _spawnRunner() async {
    final adapters = Set<TypeAdapter>.from(_typeAdapters);
    final runner = await IsolateRunner.spawn();

    await runner.run(Remote.init, InitMessage(_homePath));
    await runner.run(Remote.registerAdapter, RegisterAdapterMessage(adapters));
    return runner;
  }

  void _closeRunnerIfComplete() {
    if (_runningHandlers.isEmpty) {
      _runner.then((runner) => runner.close());
      _runner = null;
    }
  }
}
