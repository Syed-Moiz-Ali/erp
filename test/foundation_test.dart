import 'package:modular_erp/core/security/app_permission.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/connectivity/connectivity_service.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/sync/sync_coordinator.dart';
import 'package:modular_erp/core/sync/outbox_repository.dart';
import 'package:modular_erp/core/sync/pending_mutation.dart';
import 'package:modular_erp/features/design_system_preview/presentation/preview_cubit.dart';

class MockConnectivity extends Mock implements ConnectivityService {}

class Handler implements ModuleSyncHandler {
  final gate = Completer<Result<void>>();
  int calls = 0;
  @override
  String get moduleId => 'test';
  @override
  Future<Result<void>> synchronize() {
    calls++;
    return gate.future;
  }
}

void main() {
  test('Registry gates disabled and permission-protected modules', () {
    final registry = ModuleRegistry([
      ErpModule(
        id: 'a',
        name: (l10n) => l10n.home,
        icon: Icons.add,
        route: '/a',
        order: 2,
      ),
      ErpModule(
        id: 'b',
        name: (l10n) => l10n.home,
        icon: Icons.add,
        route: '/b',
        requiredPermissions: {AppPermission.userManage},
        order: 1,
      ),
      ErpModule(
        id: 'c',
        name: (l10n) => l10n.home,
        icon: Icons.add,
        route: '/c',
        enabled: false,
      ),
    ]);
    expect(registry.visible({}).map((m) => m.id), ['a']);
    expect(registry.visible({AppPermission.userManage}).map((m) => m.id), [
      'b',
      'a',
    ]);
    expect(
      () => ModuleRegistry([
        ErpModule(
          id: 'a',
          name: (l10n) => l10n.home,
          icon: Icons.add,
          route: '/',
        ),
        ErpModule(
          id: 'a',
          name: (l10n) => l10n.home,
          icon: Icons.add,
          route: '/b',
        ),
      ]),
      throwsArgumentError,
    );
  });
  test('API mapper exposes safe retryable timeout', () {
    final failure = ApiErrorMapper.map(
      DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionTimeout,
      ),
    );
    expect(failure.retryable, true);
    expect(failure.code, 'timeout');
  });
  test(
    'Outbox persists, deduplicates, streams and acknowledges mutations',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = LocalOutboxRepository(OutboxLocalDataSource(db));
      final mutation = PendingMutation(
        id: 'request-1',
        moduleId: 'future-module',
        entityId: 'record-1',
        operation: 'upsert',
        payload: {'name': 'Example'},
        createdAt: DateTime.utc(2026),
      );
      expect(PendingMutation.fromJson(mutation.toJson()), mutation);
      expect(await repo.enqueue(mutation), isA<Success<void>>());
      await repo.enqueue(mutation);
      expect(await repo.watchPending().first, [mutation]);
      await repo.acknowledge(mutation.id);
      expect(await repo.watchPending().first, isEmpty);
    },
  );
  test('Sync skips offline and coalesces concurrent runs', () async {
    final connectivity = MockConnectivity();
    when(() => connectivity.isConnected).thenAnswer((_) async => false);
    final sync = SyncCoordinator(connectivity);
    final handler = Handler();
    sync.register(handler);
    await sync.synchronize();
    expect(handler.calls, 0);
    when(() => connectivity.isConnected).thenAnswer((_) async => true);
    final first = sync.synchronize();
    final second = sync.synchronize();
    expect(identical(first, second), true);
    await Future<void>.delayed(Duration.zero);
    expect(handler.calls, 1);
    handler.gate.complete(const Success(null));
    expect(await first, isEmpty);
    await sync.dispose();
  });
  blocTest<PreviewCubit, PreviewState>(
    'Presentation filter retains other field values',
    build: PreviewCubit.new,
    act: (c) {
      c.location(PreviewLocation.remote);
      c.filter(true);
    },
    verify: (c) {
      expect(c.state.location, PreviewLocation.remote);
      expect(c.state.activeOnly, true);
    },
  );
}
