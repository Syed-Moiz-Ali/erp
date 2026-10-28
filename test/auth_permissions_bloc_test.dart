import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/access_endpoint.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/backend_access_policy.dart';
import 'package:modular_erp/platform/access/domain/effective_access.dart';
import 'package:modular_erp/platform/access/domain/effective_access_source.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

AuthContext _context({String userId = '8'}) => AuthContext(
  user: UserAccount(
    id: userId,
    displayName: 'Test User',
    email: 'test',
    companyId: '1',
    permissions: PermissionSet(const []),
    status: AccountStatus.active,
  ),
  company: const CompanyContext(
    id: '1',
    name: 'Company',
    code: 'ORG-1',
    timezone: 'Asia/Dubai',
    defaultLocale: 'en',
    enabledModules: <String>{},
  ),
);

class _FakeAuthRepository implements AuthRepository, SessionAccessSink {
  _FakeAuthRepository(this.context);
  final AuthContext context;
  PermissionSet? appliedPermissions;
  Set<String>? appliedModules;

  @override
  Future<Result<AuthContext>> login(
    AuthIdentifier identifier,
    String password,
  ) async => Success(context);

  @override
  Future<Result<AuthContext?>> restoreSession() async => Success(context);

  @override
  Future<Result<AuthContext?>> checkSession() async => Success(context);

  @override
  Future<Result<void>> logout() async => const Success(null);

  @override
  Future<Result<void>> requestPasswordReset(AuthIdentifier identifier) async =>
      const Success(null);

  @override
  Future<Result<void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async => const Success(null);

  @override
  Stream<AuthContext?> get sessionChanges => const Stream.empty();

  @override
  Future<void> applyEffectiveAccess(
    PermissionSet permissions, {
    Set<String>? enabledModules,
  }) async {
    appliedPermissions = permissions;
    appliedModules = enabledModules;
  }

  @override
  Future<void> dispose() async {}
}

class _FakeAccessSource implements EffectiveAccessSource {
  _FakeAccessSource(this.result);
  Result<EffectiveAccess> result;

  @override
  Future<Result<EffectiveAccess>> load(AuthContext context) async => result;
}

Matcher _authenticated() => isA<AuthState>().having(
  (state) => state.status,
  'status',
  AuthStatus.authenticated,
);

void main() {
  test('login loads backend permissions and modules', () async {
    final repository = _FakeAuthRepository(_context());
    final source = _FakeAccessSource(
      Success(BackendAccessPolicy.resolve(['hr.employees.view'])),
    );
    final bloc = AuthBloc(repository, effectiveAccess: source);

    bloc.add(const AuthLoginRequested('Admin', 'secret'));
    final state = await bloc.stream.firstWhere((s) => s.isAuthenticated);
    expect(state.context!.user.permissions.contains(AppPermission.employeeViewAll), isTrue);
    expect(state.context!.company.enabledModules, contains('employees'));
    expect(state.permissionsLoaded, isTrue);
    expect(state.permissionsFailure, isNull);
    expect(repository.appliedModules, contains('employees'));
    await bloc.close();
  });

  test('permission load failure fails closed', () async {
    final repository = _FakeAuthRepository(_context());
    final source = _FakeAccessSource(
      const Failed(
        Failure(code: 'offline', kind: FailureKind.offline, retryable: true),
      ),
    );
    final bloc = AuthBloc(repository, effectiveAccess: source);

    bloc.add(const AuthLoginRequested('Admin', 'secret'));
    final state = await bloc.stream.firstWhere((s) => s.isAuthenticated);
    expect(state.context!.user.permissions.values, isEmpty);
    expect(state.context!.company.enabledModules, isEmpty);
    expect(state.permissionsLoaded, isFalse);
    expect(state.permissionsFailure?.code, 'offline');
    await bloc.close();
  });

  test('access denied signal reloads permissions on the same token', () async {
    final repository = _FakeAuthRepository(_context());
    final source = _FakeAccessSource(
      Success(BackendAccessPolicy.resolve(['hr.employees.view'])),
    );
    final endpoint = AccessEndpoint();
    final bloc = AuthBloc(
      repository,
      effectiveAccess: source,
      accessEndpoint: endpoint,
    );

    bloc.add(const AuthLoginRequested('Admin', 'secret'));
    await bloc.stream.firstWhere((s) => s.isAuthenticated);
    source.result = Success(
      BackendAccessPolicy.resolve([
        'hr.employees.view',
        'hr.employees.create',
      ]),
    );

    endpoint.notify('ACCESS_DENIED');
    final refreshed = await bloc.stream.firstWhere(
      (s) => s.context?.user.permissions.contains(AppPermission.employeeCreate) ?? false,
    );
    expect(refreshed.isAuthenticated, isTrue);
    await endpoint.dispose();
    await bloc.close();
  });

  test('reload failure clears permissions instead of using a stale set', () async {
    final repository = _FakeAuthRepository(_context());
    final source = _FakeAccessSource(
      Success(BackendAccessPolicy.resolve(['hr.employees.view'])),
    );
    final bloc = AuthBloc(repository, effectiveAccess: source);

    bloc.add(const AuthLoginRequested('Admin', 'secret'));
    await bloc.stream.firstWhere((s) => s.isAuthenticated);
    source.result = const Failed(
      Failure(code: 'server', kind: FailureKind.server, retryable: true),
    );

    bloc.add(const AuthPermissionsReloadRequested());
    final failed = await bloc.stream.firstWhere(
      (s) => s.permissionsFailure?.code == 'server',
    );
    expect(failed.context!.user.permissions.values, isEmpty);
    expect(failed.context!.company.enabledModules, isEmpty);
    await bloc.close();
  });

  blocTest<AuthBloc, AuthState>(
    'login still emits authenticating then authenticated',
    build: () {
      final repository = _FakeAuthRepository(_context());
      return AuthBloc(
        repository,
        effectiveAccess: _FakeAccessSource(
          Success(BackendAccessPolicy.resolve(['hr.employees.view'])),
        ),
      );
    },
    act: (bloc) => bloc.add(const AuthLoginRequested('Admin', 'secret')),
    expect: () => [
      isA<AuthState>().having(
        (s) => s.status,
        'status',
        AuthStatus.authenticating,
      ),
      _authenticated(),
    ],
    tearDown: () async {},
  );
}
