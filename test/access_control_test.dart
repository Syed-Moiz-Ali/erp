import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/access/erp_access_catalog.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/platform/access/data/access_user_directory.dart';
import 'package:modular_erp/platform/access/data/local_access_repository.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/user_permission_grant.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/account_role_templates.dart';
import 'package:modular_erp/platform/auth/domain/policies/user_capability.dart';
import 'package:modular_erp/shared/transactions/data/local_activity_repository.dart';

class _FakeDirectory implements AccessUserDirectory {
  @override
  Stream<List<AccessUserListItem>> watchUsers({required String companyId}) =>
      Stream.value(const []);
}

void main() {
  group('permission catalog', () {
    test('every runtime permission is catalogued', () {
      for (final permission in AppPermission.values) {
        expect(
          erpAccessCatalog.forPermission(permission),
          isNotNull,
          reason: '${permission.name} has no PermissionDefinition',
        );
      }
    });

    test('grant round-trips through (key, scope)', () {
      for (final definition in erpAccessCatalog.definitions) {
        for (final scope in definition.supportedScopes) {
          final permission = definition.permissionFor(scope)!;
          final grants = erpAccessCatalog.grantsFor([permission]);
          expect(grants, contains((key: definition.key, scope: scope)));
          expect(erpAccessCatalog.permissionsFor(grants), contains(permission));
        }
      }
    });

    test('manage/view dependencies stay centralized', () {
      expect(
        normalizePermissionGrants([AppPermission.shiftManage]),
        containsAll([AppPermission.shiftManage, AppPermission.shiftView]),
      );
      final definition = erpAccessCatalog.byKey('hr.attendance.shifts.manage');
      expect(definition, isNotNull);
      expect(definition!.supportedScopes, {PermissionScope.none});
    });
  });

  group('access repository', () {
    late AppDatabase db;
    late LocalAccessRepository repository;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = LocalAccessRepository(
        db,
        const SystemAppClock(),
        LocalActivityRepository(db),
        _FakeDirectory(),
      );
    });
    tearDown(() => db.close());

    Future<void> replace(
      List<PermissionGrantInput> grants, {
      String companyId = 'c1',
      String userId = 'u1',
      String requestId = 'r1',
    }) async {
      final result = await repository.replaceGrants(
        companyId: companyId,
        actorUserId: 'admin',
        targetUserId: userId,
        requestId: requestId,
        grants: grants,
      );
      expect(result, isA<Success<void>>());
    }

    test('adds, updates and removes grants with audit events', () async {
      await replace(const [
        PermissionGrantInput(
          key: 'hr.leave.records.view',
          scope: PermissionScope.team,
        ),
      ]);
      var grants = await repository.getGrants(companyId: 'c1', userId: 'u1');
      expect((grants as Success).value, hasLength(1));

      await replace(const [
        PermissionGrantInput(
          key: 'hr.leave.records.view',
          scope: PermissionScope.all,
        ),
        PermissionGrantInput(
          key: 'hr.holidays.manage',
          scope: PermissionScope.none,
        ),
      ]);
      grants = await repository.getGrants(companyId: 'c1', userId: 'u1');
      expect((grants as Success).value, hasLength(2));

      final history = await repository
          .watchHistory(companyId: 'c1', userId: 'u1')
          .first;
      final types = history.map((e) => e.eventType).toSet();
      expect(types, contains('access.permission.added'));
      expect(types, contains('access.permission.updated'));
      final updated = history.firstWhere(
        (e) => e.eventType == 'access.permission.updated',
      );
      expect(updated.metadata['oldScope'], 'team');
      expect(updated.metadata['newScope'], 'all');
    });

    test('one effective grant per permission key', () async {
      await replace(const [
        PermissionGrantInput(
          key: 'hr.leave.records.view',
          scope: PermissionScope.team,
        ),
      ]);
      await replace(const [
        PermissionGrantInput(
          key: 'hr.leave.records.view',
          scope: PermissionScope.team,
        ),
      ]);
      final rows = await db.select(db.userPermissionGrants).get();
      expect(rows, hasLength(1));
    });

    test('grants are company scoped', () async {
      await replace(const [
        PermissionGrantInput(
          key: 'hr.holidays.manage',
          scope: PermissionScope.none,
        ),
      ]);
      final other = await repository.getGrants(companyId: 'c2', userId: 'u1');
      expect((other as Success).value, isEmpty);
    });

    test('removal records an audit event', () async {
      await replace(const [
        PermissionGrantInput(
          key: 'hr.holidays.manage',
          scope: PermissionScope.none,
        ),
      ]);
      await replace(const []);
      final history = await repository
          .watchHistory(companyId: 'c1', userId: 'u1')
          .first;
      expect(
        history.map((e) => e.eventType),
        contains('access.permission.removed'),
      );
    });
  });

  group('role independence', () {
    CompanyContext company() => const CompanyContext(
      id: 'c1',
      name: 'Company',
      code: 'C',
      timezone: 'UTC',
      defaultLocale: 'en',
      enabledModules: {'employees', 'attendance', 'leave'},
    );
    AuthContext account(AppRole role, PermissionSet permissions) => AuthContext(
      user: UserAccount(
        id: 'u1',
        displayName: 'User',
        email: 'u@erp.demo',
        companyId: 'c1',
        role: role,
        permissions: permissions,
        status: AccountStatus.active,
      ),
      company: company(),
    );

    test('changing the legacy role label does not change capabilities', () {
      final permissions = PermissionSet([
        AppPermission.attendanceViewSelf,
        AppPermission.leaveViewSelf,
        AppPermission.leaveRequest,
      ]);
      const resolver = UserCapabilityResolver();
      final asAdmin = resolver.forAuthContext(
        account(AppRole.superAdmin, permissions),
      );
      final asEmployee = resolver.forAuthContext(
        account(AppRole.employee, permissions),
      );
      expect(asAdmin.granted, asEmployee.granted);
      // Unlinked users get no self-service capability regardless of role label.
      expect(asAdmin.has(UserCapability.selfAttendance), isFalse);
      expect(asAdmin.has(UserCapability.viewCompanyLeave), isFalse);
    });

    test('ALL records access does not imply SELF actions', () {
      final unlinked = account(
        AppRole.manager,
        PermissionSet([
          AppPermission.leaveViewAll,
          AppPermission.leaveApproveAll,
        ]),
      );
      final capabilities = const UserCapabilityResolver().forAuthContext(
        unlinked,
      );
      expect(capabilities.has(UserCapability.viewCompanyLeave), isTrue);
      expect(capabilities.has(UserCapability.requestLeave), isFalse);
      expect(capabilities.hasLinkedEmployee, isFalse);
    });

    test('role templates are demo seed fixtures only', () {
      // A role template is explicit grants; it never implies authority by name.
      final template = permissionsForRole(AppRole.employee);
      expect(template.contains(AppPermission.leaveRequest), isTrue);
      expect(template.contains(AppPermission.employeeViewAll), isFalse);
    });
  });
}
