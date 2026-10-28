import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/security/access_scope_resolver.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_scope_resolver.dart';
import 'package:modular_erp/modules/hr/attendance/domain/workforce_attendance.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_models.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_scope_resolver.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_access.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

AuthContext _context(PermissionSet permissions) => AuthContext(
  user: UserAccount(
    id: 'u1',
    displayName: 'User',
    email: 'u@erp.demo',
    companyId: 'c1',
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

}
