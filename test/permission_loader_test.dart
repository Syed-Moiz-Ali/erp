import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/access_endpoint.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/backend_access_policy.dart';
import 'package:modular_erp/platform/access/domain/effective_access.dart';
import 'package:modular_erp/platform/access/domain/effective_access_source.dart';
import 'package:modular_erp/platform/auth/application/permission_loader.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';

List<String> fixtureKeys(String name) {
  final envelope =
      jsonDecode(File('test/fixtures/permissions/$name').readAsStringSync())
          as Map<String, dynamic>;
  final data = envelope['data'] as Map<String, dynamic>;
  return (data['permissions'] as List).map((value) => '$value').toList();
}

AuthContext contextFor({
  Set<AppPermission> permissions = const <AppPermission>{},
  Set<String> modules = const <String>{},
  String userId = '8',
}) => AuthContext(
  user: UserAccount(
    id: userId,
    displayName: 'Test User',
    email: 'test',
    companyId: '1',
    permissions: PermissionSet(permissions),
    status: AccountStatus.active,
  ),
  company: CompanyContext(
    id: '1',
    name: 'Company',
    code: 'ORG-1',
    timezone: 'Asia/Dubai',
    defaultLocale: 'en',
    enabledModules: modules,
  ),
);

class _FakeSource implements EffectiveAccessSource {
  _FakeSource(this.result);
  Result<EffectiveAccess> result;
  int loads = 0;

  @override
  Future<Result<EffectiveAccess>> load(AuthContext context) async {
    loads++;
    return result;
  }
}

class _FakeAuthRepository implements AuthRepository, SessionAccessSink {
  AuthContext? current;
  final _contexts = StreamController<AuthContext?>.broadcast();
  final applications = <({PermissionSet permissions, Set<String> modules})>[];

  @override
  Future<void> applyEffectiveAccess(
    PermissionSet permissions, {
    Set<String> enabledModules = const <String>{},
  }) async {
    applications.add((permissions: permissions, modules: enabledModules));
    final context = current;
    if (context == null) return;
    final updated = context.copyWith(
      user: context.user.copyWith(permissions: permissions),
      company: context.company.copyWith(enabledModules: enabledModules),
    );
    current = updated;
    _contexts.add(updated);
  }

  Future<void> waitForApplications(int count) async {
    final deadline = DateTime.now().add(const Duration(seconds: 2));
    while (applications.length < count) {
      if (DateTime.now().isAfter(deadline)) {
        fail('Timed out waiting for $count permission applications');
      }
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  Stream<AuthContext?> get contexts => _contexts.stream;

  void emit(AuthContext context) {
    current = context;
    _contexts.add(context);
  }

  @override
  Stream<AuthContext?> get sessionChanges => const Stream.empty();

  @override
  Future<Result<AuthContext?>> restoreSession() async => const Success(null);

  @override
  Future<Result<AuthContext?>> checkSession() async => const Success(null);

  @override
  Future<Result<AuthContext>> login(
    AuthIdentifier identifier,
    String password,
  ) async => const Failed<AuthContext>(
    Failure(code: 'unsupported', kind: FailureKind.request),
  );

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
  Future<void> dispose() async {}

  Future<void> close() async {
    await _contexts.close();
  }
}

void main() {
  test('loads me/permissions after login and adds settings', () async {
    final source = _FakeSource(
      Success(BackendAccessPolicy.resolve(fixtureKeys('me_permissions_admin.json'))),
    );
    final repository = _FakeAuthRepository();
    final endpoint = AccessEndpoint();
    final loader = BackendPermissionLoader(
      repository: repository,
      source: source,
      accessEndpoint: endpoint,
      contexts: repository.contexts,
      currentContext: () => repository.current,
    );
    addTearDown(() async {
      await loader.dispose();
      await endpoint.dispose();
      await repository.close();
    });

    await loader.start();
    repository.emit(contextFor());
    await repository.waitForApplications(1);

    final applied = repository.applications.first;
    expect(applied.permissions.contains(AppPermission.employeeViewAll), isTrue);
    expect(applied.permissions.contains(AppPermission.employeeCreate), isTrue);
    expect(applied.permissions.contains(AppPermission.shiftView), isTrue);
    expect(applied.permissions.contains(AppPermission.accessUsersView), isTrue);
    expect(applied.modules, containsAll(['employees', 'attendance', 'settings']));

    // The repository echoes the updated session; it must not apply twice.
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(repository.applications, hasLength(1));
  });

  test('fails closed with empty permissions and only settings enabled', () async {
    final source = _FakeSource(
      const Failed<EffectiveAccess>(
        Failure(code: 'offline', kind: FailureKind.offline, retryable: true),
      ),
    );
    final repository = _FakeAuthRepository();
    final endpoint = AccessEndpoint();
    final loader = BackendPermissionLoader(
      repository: repository,
      source: source,
      accessEndpoint: endpoint,
      contexts: repository.contexts,
      currentContext: () => repository.current,
    );
    addTearDown(() async {
      await loader.dispose();
      await endpoint.dispose();
      await repository.close();
    });

    await loader.start();
    repository.emit(
      contextFor(permissions: {AppPermission.employeeViewAll}),
    );
    await repository.waitForApplications(1);

    final applied = repository.applications.first;
    expect(applied.permissions.values, isEmpty);
    expect(applied.modules, {'settings'});
  });

  test('reloads after 403 ACCESS_DENIED', () async {
    final source = _FakeSource(
      Success(BackendAccessPolicy.resolve(fixtureKeys('me_permissions_employee.json'))),
    );
    final repository = _FakeAuthRepository();
    final endpoint = AccessEndpoint();
    final loader = BackendPermissionLoader(
      repository: repository,
      source: source,
      accessEndpoint: endpoint,
      contexts: repository.contexts,
      currentContext: () => repository.current,
    );
    addTearDown(() async {
      await loader.dispose();
      await endpoint.dispose();
      await repository.close();
    });

    await loader.start();
    repository.emit(contextFor());
    await repository.waitForApplications(1);
    expect(
      repository.applications.first.permissions.contains(
        AppPermission.employeeUpdate,
      ),
      isTrue,
    );

    source.result = Success(
      BackendAccessPolicy.resolve(<String>['company.access.users.view']),
    );
    endpoint.notify('ACCESS_DENIED');
    await repository.waitForApplications(2);

    final applied = repository.applications.last;
    expect(
      applied.permissions.contains(AppPermission.accessUsersView),
      isTrue,
    );
    expect(
      applied.permissions.contains(AppPermission.employeeUpdate),
      isFalse,
    );
  });

  test('reloads permissions when a token refresh replaces the context', () async {
    final source = _FakeSource(
      Success(BackendAccessPolicy.resolve(fixtureKeys('me_permissions_employee.json'))),
    );
    final repository = _FakeAuthRepository();
    final endpoint = AccessEndpoint();
    final loader = BackendPermissionLoader(
      repository: repository,
      source: source,
      accessEndpoint: endpoint,
      contexts: repository.contexts,
      currentContext: () => repository.current,
    );
    addTearDown(() async {
      await loader.dispose();
      await endpoint.dispose();
      await repository.close();
    });

    await loader.start();
    repository.emit(contextFor());
    await repository.waitForApplications(1);
    expect(
      repository.applications.first.permissions.contains(
        AppPermission.employeeCreate,
      ),
      isFalse,
    );

    // A refresh response carries no permissions; the loader must reload them.
    source.result = Success(
      BackendAccessPolicy.resolve(fixtureKeys('me_permissions_admin.json')),
    );
    repository.emit(contextFor());
    await repository.waitForApplications(2);
    expect(
      repository.applications.last.permissions.contains(
        AppPermission.employeeCreate,
      ),
      isTrue,
    );
  });
  test('refresh reloads effective access on app resume', () async {
    final source = _FakeSource(
      Success(BackendAccessPolicy.resolve(fixtureKeys('me_permissions_employee.json'))),
    );
    final repository = _FakeAuthRepository();
    final endpoint = AccessEndpoint();
    final loader = BackendPermissionLoader(
      repository: repository,
      source: source,
      accessEndpoint: endpoint,
      contexts: repository.contexts,
      currentContext: () => repository.current,
    );
    addTearDown(() async {
      await loader.dispose();
      await endpoint.dispose();
      await repository.close();
    });

    await loader.start();
    repository.emit(contextFor());
    await repository.waitForApplications(1);
    final before = source.loads;

    await loader.refresh();
    expect(source.loads, greaterThan(before));
  });
}
