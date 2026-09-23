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
  leaveViewSelf,
  leaveRequest,
  leaveCancelSelf,
  leaveViewTeam,
  leaveApproveTeam,
  leaveViewAll,
  leaveApproveAll,
  leaveManage,
  leaveBalanceViewSelf,
  leaveBalanceViewTeam,
  leaveBalanceViewAll,
  leaveBalanceAdjust,
  leaveTypeView,
  leaveTypeManage,
  leavePolicyView,
  leavePolicyManage,
  holidayView,
  holidayManage,
  leaveReportView,
}

/// Manage authority implies the matching view authority so a manage-only grant
/// can never hide the screen it administers. Centralized here so no widget,
/// route or template needs to special-case view/manage pairs.
const Map<AppPermission, AppPermission> permissionViewDependencies = {
  AppPermission.shiftManage: AppPermission.shiftView,
  AppPermission.workLocationManage: AppPermission.workLocationView,
  AppPermission.attendancePolicyManage: AppPermission.attendancePolicyView,
  AppPermission.leaveTypeManage: AppPermission.leaveTypeView,
  AppPermission.leavePolicyManage: AppPermission.leavePolicyView,
  AppPermission.holidayManage: AppPermission.holidayView,
};

/// Expands a raw grant set so that every `*Manage` grant carries its `*View`
/// dependency. This is the single normalization point for all permission sets.
Set<AppPermission> normalizePermissionGrants(Iterable<AppPermission> values) {
  final set = values.toSet();
  for (final entry in permissionViewDependencies.entries) {
    if (set.contains(entry.key)) set.add(entry.value);
  }
  return set;
}

/// Immutable explicit grants; roles never confer implicit authorization.
class PermissionSet {
  PermissionSet(Iterable<AppPermission> values)
    : values = Set.unmodifiable(normalizePermissionGrants(values));
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
