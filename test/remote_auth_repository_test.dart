import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/session_endpoint.dart';
import 'package:modular_erp/core/api/token_refresher.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/data/dto/auth_remote_dtos.dart';
import 'package:modular_erp/platform/auth/data/repositories/remote_auth_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

import 'support/auth_test_doubles.dart';
import 'support/memory_session_storage.dart';

void main() {
  late FakeAuthRemoteDataSource dataSource;
  late MemorySessionStorage storage;
  final now = DateTime.utc(2026, 10, 9, 12);

  RemoteAuthRepository buildRepo({SessionEndpoint? endpoint}) =>
      RemoteAuthRepository(
        dataSource: dataSource,
        storage: storage,
        sessionEndpoint: endpoint,
        now: () => now,
      );

  setUp(() {
    dataSource = FakeAuthRemoteDataSource();
    storage = MemorySessionStorage();
  });

  AuthIdentifier loginId([String value = 'Admin']) =>
      AuthIdentifier.parse(value)!;

  Map<String, dynamic> stored() =>
      jsonDecode(storage.value!) as Map<String, dynamic>;

  group('login', () {
    test(
      'authenticates and persists a session with stable integer ids',
      () async {
        final repo = buildRepo();
        final result = await repo.login(loginId(), 'secret');
        expect(result, isA<Success<AuthContext>>());
        final context = (result as Success<AuthContext>).value;
        expect(dataSource.lastLogin!.loginId, 'Admin');
        expect(context.user.id, '5');
        expect(context.company.id, '3');
        expect(context.employeeReference?.id, '7');
        expect(context.settings['userType'], 'Director');
        expect(stored()['accessToken'], 'access-1');
        expect(stored()['refreshToken'], 'refresh-1');
        await repo.dispose();
      },
    );

    test(
      'grants no permissions and no modules from the login contract',
      () async {
        final repo = buildRepo();
        final result = await repo.login(loginId(), 'secret');
        final context = (result as Success<AuthContext>).value;
        expect(context.user.permissions.length, 0);
        expect(context.company.enabledModules, isEmpty);
        await repo.dispose();
      },
    );

    test('maps invalid credentials without persisting', () async {
      dataSource.onLogin = (_) async => const Failed(
        Failure(
          code: 'AUTH_INVALID_CREDENTIALS',
          kind: FailureKind.invalidCredentials,
        ),
      );
      final repo = buildRepo();
      final result = await repo.login(loginId(), 'bad');
      expect((result as Failed).failure.kind, FailureKind.invalidCredentials);
      expect(storage.value, isNull);
      await repo.dispose();
    });

    test('propagates an offline failure', () async {
      dataSource.onLogin = (_) async => const Failed(
        Failure(code: 'offline', kind: FailureKind.offline, retryable: true),
      );
      final repo = buildRepo();
      final result = await repo.login(loginId(), 'secret');
      expect((result as Failed).failure.kind, FailureKind.offline);
      await repo.dispose();
    });

    test('reports a storage failure without authenticating', () async {
      storage.failWrite = true;
      final repo = buildRepo();
      final result = await repo.login(loginId(), 'secret');
      expect((result as Failed).failure.kind, FailureKind.sessionStorage);
      await repo.dispose();
    });
  });

  group('restore', () {
    test('restores a persisted session', () async {
      final first = buildRepo();
      await first.login(loginId(), 'secret');
      await first.dispose();

      final second = buildRepo();
      final result = await second.restoreSession();
      expect(result, isA<Success<AuthContext?>>());
      expect((result as Success).value?.user.id, '5');
      await second.dispose();
    });

    test('keeps refresh token usable after access-token expiry', () async {
      final first = buildRepo();
      dataSource.onLogin = (_) async => Success(
        sampleLoginResponse(
          accessExpiry: now.subtract(const Duration(hours: 1)),
          refreshExpiry: now.add(const Duration(days: 30)),
        ),
      );
      await first.login(loginId(), 'secret');
      await first.dispose();

      expect(await storage.readRefreshToken(), 'refresh-1');
      final second = buildRepo();
      final result = await second.restoreSession();
      expect((result as Success).value, isNotNull);
      await second.dispose();
    });

    test('clears a session whose refresh token expired', () async {
      final first = buildRepo();
      dataSource.onLogin = (_) async => Success(
        sampleLoginResponse(
          accessExpiry: now.subtract(const Duration(days: 40)),
          refreshExpiry: now.subtract(const Duration(days: 1)),
        ),
      );
      await first.login(loginId(), 'secret');
      await first.dispose();

      final second = buildRepo();
      final result = await second.restoreSession();
      expect((result as Success).value, isNull);
      expect(storage.value, isNull);
      await second.dispose();
    });

    test('clears a corrupt envelope', () async {
      storage.value = '{not json';
      final repo = buildRepo();
      final result = await repo.restoreSession();
      expect((result as Success).value, isNull);
      expect(storage.value, isNull);
      await repo.dispose();
    });
  });

  group('logout', () {
    test('clears local access and calls the server', () async {
      final repo = buildRepo();
      await repo.login(loginId(), 'secret');
      final result = await repo.logout();
      expect(result, isA<Success<void>>());
      expect(storage.value, isNull);
      expect(dataSource.logoutCalls, 1);
      expect(dataSource.lastLogout!.refreshToken, 'refresh-1');
      await repo.dispose();
    });

    test('still clears locally when the server logout fails', () async {
      dataSource.onLogout = (_) async =>
          const Failed(Failure(code: 'offline', kind: FailureKind.offline));
      final repo = buildRepo();
      await repo.login(loginId(), 'secret');
      final result = await repo.logout();
      expect(result, isA<Success<void>>());
      expect(storage.value, isNull);
      await repo.dispose();
    });

    test('reports a local storage failure', () async {
      final repo = buildRepo();
      await repo.login(loginId(), 'secret');
      storage.failClear = true;
      final result = await repo.logout();
      expect((result as Failed).failure.kind, FailureKind.sessionStorage);
      await repo.dispose();
    });
  });

  group('refresh rotation', () {
    test(
      'rotates and persists both tokens, emitting the new context',
      () async {
        final repo = buildRepo();
        await repo.login(loginId(), 'secret');
        final events = <AuthContext?>[];
        final sub = repo.sessionChanges.listen(events.add);

        dataSource.onRefresh = (_) async => Success(
          sampleLoginResponse(access: 'access-2', refresh: 'refresh-2'),
        );
        final outcome = await repo.refresh();

        expect(outcome, TokenRefreshOutcome.refreshed);
        expect(dataSource.refreshCalls, 1);
        expect(dataSource.lastRefresh!.refreshToken, 'refresh-1');
        expect(stored()['accessToken'], 'access-2');
        expect(stored()['refreshToken'], 'refresh-2');
        await Future<void>.delayed(Duration.zero);
        expect(events, isNotEmpty);
        expect(events.last!.user.id, '5');
        await sub.cancel();
        await repo.dispose();
      },
    );

    test(
      'invalidates the session when the refresh token is rejected',
      () async {
        final repo = buildRepo();
        await repo.login(loginId(), 'secret');
        final events = <AuthContext?>[];
        final sub = repo.sessionChanges.listen(events.add);

        dataSource.onRefresh = (_) async => const Failed(
          Failure(
            code: 'AUTH_REFRESH_REUSED',
            kind: FailureKind.sessionExpired,
          ),
        );
        final outcome = await repo.refresh();

        expect(outcome, TokenRefreshOutcome.invalidated);
        expect(storage.value, isNull);
        await Future<void>.delayed(Duration.zero);
        expect(events, contains(null));
        await sub.cancel();
        await repo.dispose();
      },
    );

    test('keeps tokens on a transient network failure', () async {
      final repo = buildRepo();
      await repo.login(loginId(), 'secret');
      dataSource.onRefresh = (_) async => const Failed(
        Failure(code: 'offline', kind: FailureKind.offline, retryable: true),
      );
      final outcome = await repo.refresh();
      expect(outcome, TokenRefreshOutcome.unavailable);
      expect(stored()['accessToken'], 'access-1');
      expect(stored()['refreshToken'], 'refresh-1');
      await repo.dispose();
    });

    test('invalidates when there is no session', () async {
      final repo = buildRepo();
      expect(await repo.refresh(), TokenRefreshOutcome.invalidated);
      await repo.dispose();
    });

    test('discards a refresh that resolves after logout', () async {
      final repo = buildRepo();
      await repo.login(loginId(), 'secret');
      final gate = Completer<Result<LoginResponseDto>>();
      dataSource.onRefresh = (_) => gate.future;
      final pending = repo.refresh();
      final logout = repo.logout(); // advances generation synchronously
      gate.complete(
        Success(sampleLoginResponse(access: 'stale', refresh: 'stale')),
      );
      expect(await pending, TokenRefreshOutcome.invalidated);
      await logout;
      expect(storage.value, isNull);
      await repo.dispose();
    });

    test('invalidates when a rotated pair cannot be persisted', () async {
      final repo = buildRepo();
      await repo.login(loginId(), 'secret');
      dataSource.onRefresh = (_) async => Success(
        sampleLoginResponse(access: 'access-2', refresh: 'refresh-2'),
      );
      storage.failWrite = true;
      final outcome = await repo.refresh();
      expect(outcome, TokenRefreshOutcome.invalidated);
      await repo.dispose();
    });
  });

  group('server-driven invalidation', () {
    test(
      'clears the session when the guard reports a session ending',
      () async {
        final endpoint = SessionEndpoint();
        final repo = buildRepo(endpoint: endpoint);
        await repo.login(loginId(), 'secret');
        final events = <AuthContext?>[];
        final sub = repo.sessionChanges.listen(events.add);

        endpoint.notify('AUTH_UNAUTHORIZED');
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(storage.value, isNull);
        expect(events, contains(null));
        await sub.cancel();
        await endpoint.dispose();
        await repo.dispose();
      },
    );
  });

  group('unsupported operations', () {
    test('password reset and change are reported as unsupported', () async {
      final repo = buildRepo();
      await repo.login(loginId(), 'secret');
      expect(
        (await repo.requestPasswordReset(loginId()) as Failed).failure.kind,
        FailureKind.request,
      );
      expect(
        (await repo.changePassword('a', 'b') as Failed).failure.code,
        'unsupported',
      );
      await repo.dispose();
    });
  });
}
