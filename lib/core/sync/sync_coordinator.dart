import 'dart:async';
import 'package:modular_erp/core/connectivity/connectivity_service.dart';
import 'package:modular_erp/core/errors/result.dart';

abstract interface class ModuleSyncHandler {
  String get moduleId;
  Future<Result<void>> synchronize();
}

class SyncCoordinator {
  SyncCoordinator(this.connectivity);
  final ConnectivityService connectivity;
  final Map<String, ModuleSyncHandler> _handlers = {};
  StreamSubscription<bool>? _subscription;
  Future<List<Failure>>? _running;
  void register(ModuleSyncHandler handler) {
    if (_handlers.containsKey(handler.moduleId)) {
      throw StateError('Duplicate sync handler');
    }
    _handlers[handler.moduleId] = handler;
  }

  void start() {
    _subscription ??= connectivity.changes.listen((online) {
      if (online) unawaited(synchronize());
    });
  }

  Future<List<Failure>> synchronize() =>
      _running ??= _run().whenComplete(() => _running = null);
  Future<List<Failure>> _run() async {
    final failures = <Failure>[];
    if (!await connectivity.isConnected) return failures;
    for (final handler in _handlers.values) {
      try {
        final result = await handler.synchronize();
        if (result case Failed<void>(:final failure)) failures.add(failure);
      } catch (_) {
        failures.add(
          const Failure(code: 'sync', kind: FailureKind.sync, retryable: true),
        );
      }
    }
    return failures;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
