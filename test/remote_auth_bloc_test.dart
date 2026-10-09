import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/session_endpoint.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/data/repositories/remote_auth_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

import 'support/auth_test_doubles.dart';
import 'support/memory_session_storage.dart';

Matcher authStatus(AuthStatus status) =>
    isA<AuthState>().having((state) => state.status, 'status', status);

void main() {
  late FakeAuthRemoteDataSource dataSource;
  late MemorySessionStorage storage;
  late SessionEndpoint endpoint;
  late RemoteAuthRepository repository;

  setUp(() {
    dataSource = FakeAuthRemoteDataSource();
    storage = MemorySessionStorage();
    endpoint = SessionEndpoint();
    repository = RemoteAuthRepository(
      dataSource: dataSource,
      storage: storage,
      sessionEndpoint: endpoint,
    );
  });

  tearDown(() async {
    await repository.dispose();
    await endpoint.dispose();
  });

  blocTest<AuthBloc, AuthState>(
    'login success emits authenticating then authenticated',
    build: () => AuthBloc(repository),
    act: (bloc) => bloc.add(const AuthLoginRequested('Admin', 'secret')),
    expect: () => [
      authStatus(AuthStatus.authenticating),
      isA<AuthState>().having(
        (s) => s.isAuthenticated,
        'isAuthenticated',
        true,
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'login failure emits authenticating then unauthenticated with a failure',
    setUp: () {
      dataSource.onLogin = (_) async => const Failed(
        Failure(
          code: 'AUTH_INVALID_CREDENTIALS',
          kind: FailureKind.invalidCredentials,
        ),
      );
    },
    build: () => AuthBloc(repository),
    act: (bloc) => bloc.add(const AuthLoginRequested('Admin', 'bad')),
    expect: () => [
      authStatus(AuthStatus.authenticating),
      isA<AuthState>()
          .having((s) => s.status, 'status', AuthStatus.unauthenticated)
          .having(
            (s) => s.failure?.kind,
            'kind',
            FailureKind.invalidCredentials,
          ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'restore emits bootstrapping then authenticated',
    setUp: () async {
      await repository.login(AuthIdentifier.parse('Admin')!, 'secret');
    },
    build: () => AuthBloc(repository),
    act: (bloc) => bloc.add(const AuthBootstrapRequested()),
    expect: () => [
      authStatus(AuthStatus.bootstrapping),
      isA<AuthState>().having(
        (s) => s.isAuthenticated,
        'isAuthenticated',
        true,
      ),
    ],
  );

  test('logout returns to unauthenticated and clears local access', () async {
    await repository.login(AuthIdentifier.parse('Admin')!, 'secret');
    final bloc = AuthBloc(repository);
    addTearDown(bloc.close);

    bloc.add(const AuthBootstrapRequested());
    await bloc.stream.firstWhere((state) => state.isAuthenticated);

    bloc.add(const AuthLogoutRequested());
    await bloc.stream.firstWhere(
      (state) =>
          state.status == AuthStatus.unauthenticated && state.failure == null,
    );
    expect(bloc.state.isAuthenticated, isFalse);
    expect(storage.value, isNull);
  });

  test(
    'server-driven invalidation redirects the session to unauthenticated',
    () async {
      await repository.login(AuthIdentifier.parse('Admin')!, 'secret');
      final bloc = AuthBloc(repository);
      addTearDown(bloc.close);

      bloc.add(const AuthBootstrapRequested());
      await bloc.stream.firstWhere((state) => state.isAuthenticated);

      endpoint.notify('AUTH_UNAUTHORIZED');
      await bloc.stream.firstWhere(
        (state) => state.status == AuthStatus.unauthenticated,
      );
      expect(bloc.state.isAuthenticated, isFalse);
    },
  );
}
