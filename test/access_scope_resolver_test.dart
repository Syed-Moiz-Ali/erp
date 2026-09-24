import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/access/erp_access_catalog.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/security/access_scope_resolver.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_scope_resolver.dart';
import 'package:modular_erp/modules/hr/attendance/domain/workforce_attendance.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_models.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_scope_resolver.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_access.dart';
import 'package:modular_erp/platform/access/application/user_grants_controller.dart';
import 'package:modular_erp/platform/access/data/access_user_directory.dart';
import 'package:modular_erp/platform/access/data/local_access_repository.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/user_permission_grant.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/transactions/data/local_activity_repository.dart';

class _FakeDirectory implements AccessUserDirectory {
  @override
  Stream<List<AccessUserListItem>> watchUsers({required String companyId}) =>
      Stream.value(const []);
}

AuthContext _context(PermissionSet permissions) => AuthContext(
  user: UserAccount(
    id: 'u1',
    displayName: 'User',
    email: 'u@erp.demo',
    companyId: 'c1',
    role: AppRole.employee,
    permissions: permissions,
    status: AccountStatus.active,
  ),
  company: const CompanyContext(
    id: 'c1',
    name: 'Company',
    code: 'C',
    timezone: 'UTC',
    defaultLocale: 'en',
    enabledModules: {'employees', 'attendance', 'leave', 'reports'},
  ),
);

void main() {
  const resolver = AccessScopeResolver();
  PermissionScope employeeScope(Set<AppPermission> permissions) =>
      resolver.resolve(
        PermissionSet(permissions),
        all: AppPermission.employeeViewAll,
        team: AppPermission.employeeViewTeam,
        self: AppPermission.employeeViewSelf,
      );

  group('AccessScopeResolver precedence', () {
    test('broadest granted scope wins regardless of order', () {
      expect(
        employeeScope({
          AppPermission.employeeViewSelf,
          AppPermission.employeeViewTeam,
          AppPermission.employeeViewAll,
        }),
        PermissionScope.all,
      );
      expect(
        employeeScope({
          AppPermission.employeeViewSelf,
          AppPermission.employeeViewTeam,
        }),
        PermissionScope.team,
      );
      expect(
        employeeScope({AppPermission.employeeViewSelf}),
        PermissionScope.self,
      );
      expect(employeeScope(const {}), PermissionScope.none);
    });

    test('assigned sits between team and self', () {
      expect(
        resolver.resolve(
          PermissionSet([AppPermission.attendanceViewTeam]),
          assigned: AppPermission.attendanceViewTeam,
          self: AppPermission.attendanceViewSelf,
        ),
        PermissionScope.assigned,
      );
    });
  });

  group('module resolvers delegate to the unified resolver', () {
    test('employee scope', () {
      expect(
        const EmployeeScopeResolver().resolve(
          _context(PermissionSet([AppPermission.employeeViewTeam])),
        ),
        EmployeeScope.team,
      );
      expect(
        const EmployeeScopeResolver().resolve(
          _context(
            PermissionSet([
              AppPermission.employeeViewAll,
              AppPermission.employeeViewTeam,
            ]),
          ),
        ),
        EmployeeScope.all,
      );
    });

    test('attendance scope defaults to self', () {
      expect(
        const AttendanceScopeResolver().resolve(
          _context(PermissionSet([AppPermission.attendanceViewTeam])),
        ),
        AttendanceScope.team,
      );
      expect(
        const AttendanceScopeResolver().resolve(_context(PermissionSet([]))),
        AttendanceScope.self,
      );
    });

    test('dashboard scope', () {
      expect(
        const DashboardScopeResolver().resolve(
          _context(PermissionSet([AppPermission.attendanceViewAll])),
        ),
        DashboardScope.company,
      );
      expect(
        const DashboardScopeResolver().resolve(_context(PermissionSet([]))),
        DashboardScope.none,
      );
    });
  });

  group('grants carry their scope', () {
    test('PermissionSet exposes the granted scope', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = LocalAccessRepository(
        db,
        const SystemAppClock(),
        LocalActivityRepository(db),
        _FakeDirectory(),
      );
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
      final controller = LocalUserGrantsController(
        repository,
        erpAccessCatalog,
        const SystemAppClock(),
      );
      final permissions = await controller.permissionsFor(
        _context(PermissionSet([])),
      );
      expect(
        permissions.scopeFor(AppPermission.leaveViewAll),
        PermissionScope.all,
      );
    });
  });
}
