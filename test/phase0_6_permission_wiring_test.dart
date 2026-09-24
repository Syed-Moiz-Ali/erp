import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/app/access/erp_access_catalog.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/platform/access/application/user_grants_controller.dart';
import 'package:modular_erp/platform/access/data/access_user_directory.dart';
import 'package:modular_erp/platform/access/data/local_access_repository.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/user_permission_grant.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/data/repositories/demo_auth_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/shared/transactions/data/local_activity_repository.dart';
import 'support/memory_session_storage.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _FakeDirectory implements AccessUserDirectory {
  @override
  Stream<List<AccessUserListItem>> watchUsers({required String companyId}) =>
      Stream.value(const []);
}

class _FakeGrants implements UserGrantsController {
  _FakeGrants(this.initial);
  final _controller = StreamController<PermissionSet>.broadcast();
  PermissionSet initial;
  @override
  Future<PermissionSet> permissionsFor(AuthContext context) async => initial;
  @override
  Stream<PermissionSet> watch(AuthContext context) => _controller.stream;
  void emit(PermissionSet permissions) => _controller.add(permissions);
  Future<void> close() => _controller.close();
}

AuthContext _context({
  String companyId = 'c1',
  String userId = 'u1',
  PermissionSet? permissions,
}) => AuthContext(
  user: UserAccount(
    id: userId,
    displayName: 'User',
    email: 'u@erp.demo',
    companyId: companyId,
    permissions: permissions ?? PermissionSet(const []),
    status: AccountStatus.active,
  ),
  company: CompanyContext(
    id: companyId,
    name: 'Company',
    code: 'C',
    timezone: 'UTC',
    defaultLocale: 'en',
    enabledModules: const {'employees', 'attendance', 'leave', 'reports'},
  ),
);

void main() {
  setUpAll(() {
    registerFallbackValue(AuthIdentifier.parse('a@b.c')!);
  });

  test('session permissions come from grants and refresh live', () async {
    final repository = _MockAuthRepository();
    when(
      () => repository.sessionChanges,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => repository.login(any(), any()),
    ).thenAnswer((_) async => Success(_context()));
    final grants = _FakeGrants(
      PermissionSet([AppPermission.attendanceViewSelf]),
    );
    final bloc = AuthBloc(repository, grants: grants);
    addTearDown(() async {
      await bloc.close();
      await grants.close();
    });

    bloc.add(const AuthLoginRequested('a@b.c', 'x'));
    await Future<void>.delayed(Duration.zero);
    expect(
      bloc.state.context!.user.permissions.contains(
        AppPermission.attendanceViewSelf,
      ),
      isTrue,
    );

    // Grant added live: navigation/permissions update without re-login.
    grants.emit(PermissionSet([AppPermission.leaveViewAll]));
    await Future<void>.delayed(Duration.zero);
    expect(
      bloc.state.context!.user.permissions.contains(AppPermission.leaveViewAll),
      isTrue,
    );
    expect(
      bloc.state.context!.user.permissions.contains(
        AppPermission.attendanceViewSelf,
      ),
      isFalse,
    );
  });

  test('effective permissions always come from grants', () async {
    final repository = _MockAuthRepository();
    when(
      () => repository.sessionChanges,
    ).thenAnswer((_) => const Stream.empty());
    final permissions = PermissionSet([AppPermission.leaveRequest]);
    when(
      () => repository.login(any(), any()),
    ).thenAnswer((_) async => Success(_context(permissions: permissions)));
    final grants = _FakeGrants(permissions);
    final bloc = AuthBloc(repository, grants: grants);
    addTearDown(() async {
      await bloc.close();
      await grants.close();
    });
    bloc.add(const AuthLoginRequested('a@b.c', 'x'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.context!.user.permissions.values, permissions.values);
  });

  group('LocalUserGrantsController', () {
    late AppDatabase db;
    late LocalAccessRepository repository;
    late LocalUserGrantsController controller;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = LocalAccessRepository(
        db,
        const SystemAppClock(),
        LocalActivityRepository(db),
        _FakeDirectory(),
      );
      controller = LocalUserGrantsController(
        repository,
        erpAccessCatalog,
        const SystemAppClock(),
      );
    });
    tearDown(() => db.close());

    test('maps grants to permissions and is company scoped', () async {
      await repository.replaceGrants(
        companyId: 'c1',
        actorUserId: 'admin',
        targetUserId: 'u1',
        requestId: 'r1',
        grants: const [
          PermissionGrantInput(
            key: 'hr.leave.records.view',
            scope: PermissionScope.all,
          ),
        ],
      );
      final c1 = await controller.permissionsFor(_context(companyId: 'c1'));
      expect(c1.contains(AppPermission.leaveViewAll), isTrue);
      final c2 = await controller.permissionsFor(_context(companyId: 'c2'));
      expect(c2.values, isEmpty);
    });

    test('excludes expired grants', () async {
      final now = const SystemAppClock().now();
      await db
          .into(db.userPermissionGrants)
          .insert(
            UserPermissionGrantsCompanion.insert(
              id: 'expired',
              companyId: 'c1',
              userId: 'u1',
              permissionKey: 'hr.leave.records.view',
              scopeKey: 'all',
              grantedByUserId: 'admin',
              grantedAt: now,
              updatedAt: now,
              syncStatus: 'synced',
              expiresAt: Value(now.subtract(const Duration(days: 1))),
            ),
          );
      final permissions = await controller.permissionsFor(_context());
      expect(permissions.values, isEmpty);
    });
  });

  test('effective permissions are persisted back to the session', () async {
    final repository = DemoAuthRepository(
      MemorySessionStorage(),
      source: DemoAuthSource(),
    );
    addTearDown(repository.dispose);
    await repository.login(
      AuthIdentifier.parse('employee@erp.demo')!,
      'Employee@123',
    );
    await repository.applyEffectivePermissions(
      PermissionSet([AppPermission.leaveViewAll]),
    );
    final session = await repository.checkSession();
    final context = (session as Success<AuthContext?>).value!;
    expect(
      context.user.permissions.contains(AppPermission.leaveViewAll),
      isTrue,
    );
    expect(
      context.user.permissions.contains(AppPermission.attendanceViewSelf),
      isFalse,
    );
  });

  test('demo repository still works without a grants controller', () async {
    final repository = DemoAuthRepository(
      MemorySessionStorage(),
      source: DemoAuthSource(),
    );
    addTearDown(repository.dispose);
    final bloc = AuthBloc(repository);
    addTearDown(bloc.close);
    bloc.add(const AuthLoginRequested('employee@erp.demo', 'Employee@123'));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(bloc.state.isAuthenticated, isTrue);
    expect(
      bloc.state.context!.user.permissions.contains(
        AppPermission.attendanceViewSelf,
      ),
      isTrue,
    );
  });
}
