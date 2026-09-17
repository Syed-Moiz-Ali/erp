enum AppPermission {
  employeeViewSelf,
  employeeViewTeam,
  employeeViewAll,
  employeeCreate,
  employeeUpdate,
  employeeDeactivate,
  attendanceViewSelf,
  attendanceViewTeam,
  attendanceViewAll,
  attendancePunchIn,
  attendancePunchOut,
  attendanceBreak,
  attendanceRequestCorrection,
  attendanceCorrect,
  attendanceApprove,
  shiftView,
  shiftManage,
  workLocationView,
  workLocationManage,
  attendancePolicyView,
  attendancePolicyManage,
  companyManage,
  userManage,
  roleManage,
  attendanceReportView,
}

/// Immutable explicit grants; roles never confer implicit authorization.
class PermissionSet {
  PermissionSet(Iterable<AppPermission> values)
    : values = Set.unmodifiable(values);
  final Set<AppPermission> values;
  bool contains(AppPermission permission) => values.contains(permission);
  int get length => values.length;
}

class PermissionChecker {
  const PermissionChecker(this.permissions);
  final PermissionSet permissions;
  bool can(AppPermission permission) => permissions.contains(permission);
  bool canAll(Iterable<AppPermission> required) => required.every(can);
  bool canAny(Iterable<AppPermission> required) => required.any(can);
}
