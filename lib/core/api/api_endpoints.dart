import 'package:modular_erp/core/api/api_path.dart';

/// Central registry of every backend route path.
///
/// Features must reference these constants (or the parameterised helpers, which
/// route through [ApiPath] for safe encoding) instead of hardcoding path
/// strings. Add a new `...Endpoints` group here when a module gains remote
/// endpoints, and expose it as a `static const` field on [ApiEndpoints].
abstract final class ApiEndpoints {
  const ApiEndpoints._();

  /// Root prefix shared by all backend routes.
  static const String root = '/api';

  static const AuthEndpoints auth = AuthEndpoints();
  static const MeEndpoints me = MeEndpoints();
  static const PermissionEndpoints permissions = PermissionEndpoints();
  static const UserPermissionEndpoints userPermissions =
      UserPermissionEndpoints();
  static const EmployeeEndpoints employees = EmployeeEndpoints();
  static const BranchEndpoints branches = BranchEndpoints();
  static const DepartmentEndpoints departments = DepartmentEndpoints();
  static const ShiftEndpoints shifts = ShiftEndpoints();
  static const EmployeeShiftEndpoints employeeShifts = EmployeeShiftEndpoints();
  static const AttendanceEndpoints attendance = AttendanceEndpoints();
}

/// Authentication: `/api/auth/*`.
final class AuthEndpoints {
  const AuthEndpoints();

  String get login => '${ApiEndpoints.root}/auth/login';
  String get refresh => '${ApiEndpoints.root}/auth/refresh';
  String get logout => '${ApiEndpoints.root}/auth/logout';
}

/// Current-session endpoints: `/api/me/*`.
final class MeEndpoints {
  const MeEndpoints();

  String get permissions => '${ApiEndpoints.root}/me/permissions';
}

/// Permission masters: `/api/permissions/*`.
final class PermissionEndpoints {
  const PermissionEndpoints();

  String get list => '${ApiEndpoints.root}/permissions';
  String byId(Object id) =>
      ApiPath.resolve('${ApiEndpoints.root}/permissions/{id}', {'id': id});
}

/// User permission grants: `/api/user-permissions/*`.
final class UserPermissionEndpoints {
  const UserPermissionEndpoints();

  String get list => '${ApiEndpoints.root}/user-permissions';
  String byId(Object id) => ApiPath.resolve(
    '${ApiEndpoints.root}/user-permissions/{id}',
    {'id': id},
  );
  String forUser(Object userId) => ApiPath.resolve(
    '${ApiEndpoints.root}/user-permissions/users/{userId}',
    {'userId': userId},
  );
}

/// Employees: `/api/employees/*`.
final class EmployeeEndpoints {
  const EmployeeEndpoints();

  String get list => '${ApiEndpoints.root}/employees';
  String get lookups => '${ApiEndpoints.root}/employees/lookups';
  String byId(Object id) =>
      ApiPath.resolve('${ApiEndpoints.root}/employees/{id}', {'id': id});
  String deactivate(Object id) => ApiPath.resolve(
    '${ApiEndpoints.root}/employees/{id}/deactivate',
    {'id': id},
  );
  String activate(Object id) => ApiPath.resolve(
    '${ApiEndpoints.root}/employees/{id}/activate',
    {'id': id},
  );
}

/// Branches (companies): `/api/branches/*`.
final class BranchEndpoints {
  const BranchEndpoints();

  String get list => '${ApiEndpoints.root}/branches';
  String get lookups => '${ApiEndpoints.root}/branches/lookups';
  String byId(Object id) =>
      ApiPath.resolve('${ApiEndpoints.root}/branches/{id}', {'id': id});
  String deactivate(Object id) => ApiPath.resolve(
    '${ApiEndpoints.root}/branches/{id}/deactivate',
    {'id': id},
  );
  String activate(Object id) => ApiPath.resolve(
    '${ApiEndpoints.root}/branches/{id}/activate',
    {'id': id},
  );
}

/// Departments: `/api/departments/*`.
final class DepartmentEndpoints {
  const DepartmentEndpoints();

  String get list => '${ApiEndpoints.root}/departments';
  String byId(Object id) =>
      ApiPath.resolve('${ApiEndpoints.root}/departments/{id}', {'id': id});
  String deactivate(Object id) => ApiPath.resolve(
    '${ApiEndpoints.root}/departments/{id}/deactivate',
    {'id': id},
  );
}

/// Shifts: `/api/shifts/*`.
final class ShiftEndpoints {
  const ShiftEndpoints();

  String get list => '${ApiEndpoints.root}/shifts';
  String byId(Object id) =>
      ApiPath.resolve('${ApiEndpoints.root}/shifts/{id}', {'id': id});
  String deactivate(Object id) => ApiPath.resolve(
    '${ApiEndpoints.root}/shifts/{id}/deactivate',
    {'id': id},
  );
  String activate(Object id) =>
      ApiPath.resolve('${ApiEndpoints.root}/shifts/{id}/activate', {'id': id});
}

/// Employee shift assignments: `/api/employee-shifts/*`.
final class EmployeeShiftEndpoints {
  const EmployeeShiftEndpoints();

  String get list => '${ApiEndpoints.root}/employee-shifts';
  String byId(Object id) =>
      ApiPath.resolve('${ApiEndpoints.root}/employee-shifts/{id}', {'id': id});
  String deactivate(Object id) => ApiPath.resolve(
    '${ApiEndpoints.root}/employee-shifts/{id}/deactivate',
    {'id': id},
  );
}

/// Self-service attendance: `/api/attendance/*`.
final class AttendanceEndpoints {
  const AttendanceEndpoints();

  String get today => '${ApiEndpoints.root}/attendance/today';
  String get punch => '${ApiEndpoints.root}/attendance/punch';
}
