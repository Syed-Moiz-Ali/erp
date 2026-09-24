import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/app/access/erp_access_catalog.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/location/location_service.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/modules/hr/attendance/data/workforce_attendance_read_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_correction_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_repository.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy_repository.dart';
import 'package:modular_erp/modules/hr/dashboard/data/local_dashboard_repository.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_models.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_repository.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_repository.dart';
import 'package:modular_erp/modules/hr/reports/data/attendance_report_export_service.dart';
import 'package:modular_erp/modules/hr/reports/domain/attendance_report_repository.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift_repository.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location_repository.dart';
import 'package:modular_erp/platform/access/application/user_access_cubit.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/grant_authority.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';

class _MockAuth extends Mock implements AuthRepository {}

class _MockEmployee extends Mock implements EmployeeRepository {}

class _MockShift extends Mock implements ShiftRepository {}

class _MockLocation extends Mock implements WorkLocationRepository {}

class _MockPolicy extends Mock implements AttendancePolicyRepository {}

class _MockAttendance extends Mock implements AttendanceRepository {}

class _MockCorrection extends Mock implements AttendanceCorrectionRepository {}

class _MockWorkforce extends Mock
    implements WorkforceAttendanceReadRepository {}

class _MockReport extends Mock implements AttendanceReportRepository {}

class _MockExport extends Mock implements AttendanceReportExportService {}

class _MockLeave extends Mock implements LeaveRepository {}

class _MockLocationService extends Mock implements LocationService {}

class _MockAccessRepository extends Mock implements AccessRepository {}

const _allModules = {
  'dashboard',
  'employees',
  'attendance',
  'leave',
  'reports',
  'settings',
};

AuthContext _context({
  required Set<AppPermission> permissions,
  Set<String> enabledModules = _allModules,
  String? employeeId,
}) => AuthContext(
  user: UserAccount(
    id: 'u1',
    displayName: 'User',
    email: 'u@erp.demo',
    companyId: 'c1',
    permissions: PermissionSet(permissions),
    status: AccountStatus.active,
  ),
  company: CompanyContext(
    id: 'c1',
    name: 'Company',
    code: 'C',
    timezone: 'UTC',
    defaultLocale: 'en',
    enabledModules: enabledModules,
  ),
  employeeReference: employeeId == null
      ? null
      : EmployeeReference(id: employeeId, userAccountId: 'u1', companyId: 'c1'),
);

ModuleRegistry _registry() => createErpRegistry(
  _MockAuth(),
  dashboardRepository: const LocalDashboardRepository(),
  employeeRepository: _MockEmployee(),
  shiftRepository: _MockShift(),
  workLocationRepository: _MockLocation(),
  attendancePolicyRepository: _MockPolicy(),
  locationService: _MockLocationService(),
  attendanceRepository: _MockAttendance(),
  correctionRepository: _MockCorrection(),
  workforceAttendanceRepository: _MockWorkforce(),
  attendanceReportRepository: _MockReport(),
  attendanceReportExportService: _MockExport(),
  leaveRepository: _MockLeave(),
);

List<String> _destinations(AuthContext context) {
  final resolver = NavigationResolver(_registry());
  return resolver
      .resolve(
        context.company,
        context.user.permissions,
        employee: context.employeeReference,
      )
      .destinations
      .map((d) => d.id)
      .toList();
}

void main() {
  group('self-service only grants', () {
    final context = _context(
      employeeId: 'e1',
      permissions: {
        AppPermission.employeeViewSelf,
        AppPermission.attendanceViewSelf,
        AppPermission.attendancePunchIn,
        AppPermission.attendancePunchOut,
        AppPermission.attendanceBreak,
        AppPermission.leaveViewSelf,
        AppPermission.leaveRequest,
        AppPermission.leaveBalanceViewSelf,
      },
    );
    test('sees only self destinations', () {
      final ids = _destinations(context);
      expect(ids, contains('attendance'));
      expect(ids, contains('leave'));
      expect(ids, isNot(contains('employees')));
      expect(ids, isNot(contains('reports')));
      expect(ids, isNot(contains('settings')));
      expect(ids, isNot(contains('attendance-team')));
      expect(ids, isNot(contains('attendance-all')));
      expect(ids, isNot(contains('leave-team')));
      expect(ids, isNot(contains('leave-all')));
      expect(ids, isNot(contains('leave-approvals')));
      // Self balance view is legitimate for a linked employee.
      expect(ids, contains('leave-balances'));
    });

    test('cannot reach organizational routes directly', () {
      final resolver = NavigationResolver(_registry());
      expect(
        resolver.routeAccess(AppRoutes.employees, context),
        RouteAccess.unauthorized,
      );
      expect(
        resolver.routeAccess(AppRoutes.reports, context),
        RouteAccess.unauthorized,
      );
      expect(
        resolver.routeAccess(AppRoutes.attendanceTeam, context),
        RouteAccess.unauthorized,
      );
    });
  });

  group('team vs all scopes', () {
    test('TEAM leave records do not grant All Leave or Approvals', () {
      final context = _context(
        employeeId: 'e1',
        permissions: {AppPermission.leaveViewSelf, AppPermission.leaveViewTeam},
      );
      final ids = _destinations(context);
      expect(ids, contains('leave-team'));
      expect(ids, isNot(contains('leave-all')));
      expect(ids, isNot(contains('leave-approvals')));
    });

    test('TEAM review grants Approvals but not company-wide leave', () {
      final context = _context(
        employeeId: 'e1',
        permissions: {
          AppPermission.leaveViewSelf,
          AppPermission.leaveViewTeam,
          AppPermission.leaveApproveTeam,
        },
      );
      final ids = _destinations(context);
      expect(ids, contains('leave-approvals'));
      expect(ids, isNot(contains('leave-all')));
    });

    test('ALL attendance requires the all grant, not team', () {
      final team = _context(
        employeeId: 'e1',
        permissions: {
          AppPermission.attendanceViewSelf,
          AppPermission.attendanceViewTeam,
        },
      );
      expect(_destinations(team), contains('attendance-team'));
      expect(_destinations(team), isNot(contains('attendance-all')));

      final all = _context(
        employeeId: 'e1',
        permissions: {
          AppPermission.attendanceViewSelf,
          AppPermission.attendanceViewAll,
        },
      );
      expect(_destinations(all), contains('attendance-all'));
    });
  });

  group('module enablement overrides grants', () {
    test('disabled employees feature hides Employees despite grant', () {
      final context = _context(
        permissions: {AppPermission.employeeViewAll},
        enabledModules: {'dashboard', 'attendance'},
      );
      expect(_destinations(context), isNot(contains('employees')));
      expect(
        NavigationResolver(
          _registry(),
        ).routeAccess(AppRoutes.employees, context),
        RouteAccess.moduleUnavailable,
      );
    });

    test('enabled module with zero grants stays hidden', () {
      final context = _context(permissions: const {});
      final ids = _destinations(context);
      expect(ids, isNot(contains('employees')));
      expect(ids, isNot(contains('attendance')));
      expect(ids, isNot(contains('leave')));
      expect(ids, isNot(contains('reports')));
    });
  });

  group('configuration view vs manage', () {
    test('view-only cannot reach new/edit configuration routes', () {
      final context = _context(permissions: {AppPermission.shiftView});
      final resolver = NavigationResolver(_registry());
      expect(
        resolver.routeAccess(AppRoutes.shifts, context),
        RouteAccess.allowed,
      );
      expect(
        resolver.routeAccess(AppRoutes.shiftsNew, context),
        RouteAccess.unauthorized,
      );
    });
  });

  group('access view vs manage', () {
    test('view-only access editor is read-only', () async {
      final viewOnly = UserAccessCubit(
        catalog: erpAccessCatalog,
        repository: _MockAccessRepository(),
        authority: const GrantAuthorityResolver(),
        actor: _context(permissions: {AppPermission.accessUsersView}),
        userId: 'u2',
      );
      addTearDown(viewOnly.close);
      expect(viewOnly.canManage, isFalse);

      final manager = UserAccessCubit(
        catalog: erpAccessCatalog,
        repository: _MockAccessRepository(),
        authority: const GrantAuthorityResolver(),
        actor: _context(permissions: {AppPermission.accessPermissionsManage}),
        userId: 'u2',
      );
      addTearDown(manager.close);
      expect(manager.canManage, isTrue);
    });
  });

  group('dashboard metric scope', () {
    test('self scope does not expose company employee metrics', () async {
      final context = _context(
        employeeId: 'e1',
        permissions: {
          AppPermission.attendanceViewSelf,
          AppPermission.attendancePunchIn,
        },
      );
      final result = await const LocalDashboardRepository().load(context);
      final metrics = result is Success<DashboardSummary>
          ? result.value.metrics
          : const <DashboardMetric>[];
      final kinds = metrics.map((m) => m.kind).toSet();
      expect(kinds, isNot(contains(DashboardMetricKind.employees)));
      expect(kinds, isNot(contains(DashboardMetricKind.teamSize)));
    });
  });
}
