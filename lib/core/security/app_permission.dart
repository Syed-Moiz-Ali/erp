import 'package:flutter/foundation.dart';
import 'package:modular_erp/core/security/permission_scope.dart';

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
  // Platform / company access administration.
  accessUsersView,
  accessPermissionsManage,
  companyModulesView,
  platformModulesManage,
  // Services Phase 1 (directory, teams, configuration).
  serviceCustomerView,
  serviceCustomerCreate,
  serviceCustomerEdit,
  serviceCustomerDeactivate,
  serviceSiteView,
  serviceSiteCreate,
  serviceSiteEdit,
  serviceSiteDeactivate,
  serviceTeamView,
  serviceTeamManage,
  serviceTypeView,
  serviceTypeManage,
  complaintTypeView,
  complaintTypeManage,
  servicePriorityView,
  servicePriorityManage,
  serviceTicketTypeView,
  serviceTicketTypeManage,
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
  AppPermission.serviceTeamManage: AppPermission.serviceTeamView,
  AppPermission.serviceTypeManage: AppPermission.serviceTypeView,
  AppPermission.complaintTypeManage: AppPermission.complaintTypeView,
  AppPermission.servicePriorityManage: AppPermission.servicePriorityView,
  AppPermission.serviceTicketTypeManage: AppPermission.serviceTicketTypeView,
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
///
/// [scopes] optionally records the granted record scope per permission (used by
/// the access editor and record-scope checks). Legacy construction without
/// scopes keeps working; `scopeFor` then returns null.
class PermissionSet {
  PermissionSet(
    Iterable<AppPermission> values, {
    Map<AppPermission, PermissionScope> scopes = const {},
  }) : values = Set.unmodifiable(normalizePermissionGrants(values)),
       scopes = Map.unmodifiable(scopes);
  final Set<AppPermission> values;
  final Map<AppPermission, PermissionScope> scopes;
  bool contains(AppPermission permission) => values.contains(permission);
  PermissionScope? scopeFor(AppPermission permission) => scopes[permission];
  int get length => values.length;

  @override
  bool operator ==(Object other) =>
      other is PermissionSet && setEquals(other.values, values);
  @override
  int get hashCode => Object.hashAllUnordered(values);
}

class PermissionChecker {
  const PermissionChecker(this.permissions);
  final PermissionSet permissions;
  bool can(AppPermission permission) => permissions.contains(permission);
  bool canAll(Iterable<AppPermission> required) => required.every(can);
  bool canAny(Iterable<AppPermission> required) => required.any(can);
}
