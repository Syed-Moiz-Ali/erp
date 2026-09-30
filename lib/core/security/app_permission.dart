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
  // Services Phase 2 (service enquiry transaction).
  serviceEnquiryView,
  serviceEnquiryCreate,
  serviceEnquiryEdit,
  serviceEnquiryCancel,
  // Services Phase 3 (job assignment & scheduling transaction).
  serviceJobAssignmentViewAssigned,
  serviceJobAssignmentViewTeam,
  serviceJobAssignmentViewAll,
  serviceJobAssignmentCreate,
  serviceJobAssignmentEdit,
  serviceJobAssignmentCancel,
  // Services Phase 4 (inspection + configuration masters).
  serviceRootCauseView,
  serviceRootCauseManage,
  serviceChargeResponsibilityView,
  serviceChargeResponsibilityManage,
  serviceInspectionViewAssigned,
  serviceInspectionViewTeam,
  serviceInspectionViewAll,
  serviceInspectionCreate,
  serviceInspectionEdit,
  serviceInspectionComplete,
  serviceInspectionCancel,
  // Services Phase 5 (request for material + purpose master).
  serviceMaterialRequestPurposeView,
  serviceMaterialRequestPurposeManage,
  serviceMaterialRequestViewAssigned,
  serviceMaterialRequestViewTeam,
  serviceMaterialRequestViewAll,
  serviceMaterialRequestCreate,
  serviceMaterialRequestEdit,
  serviceMaterialRequestCancel,
  serviceMaterialRequestPrint,
  // Services Phase 6 (work execution).
  serviceWorkExecutionViewAssigned,
  serviceWorkExecutionViewTeam,
  serviceWorkExecutionViewAll,
  serviceWorkExecutionCreate,
  serviceWorkExecutionEdit,
  serviceWorkExecutionPerform,
  serviceWorkExecutionComplete,
  serviceWorkExecutionCancel,
}

/// Manage authority implies the matching view authority so a manage-only grant
/// can never hide the screen it administers. Centralized here so no widget,
/// route or template needs to special-case view/manage pairs.
///
/// HARD INVARIANT: **an action permission NEVER upgrades the View scope.**
///
/// Only `*Manage`-style structural configuration permissions (whose View grant
/// is scope-less, `PermissionScope.none`) may imply their View. Scoped
/// transaction actions (create/edit/complete/cancel/print/perform) deliberately
/// imply **no** View permission at all: record visibility is resolved solely
/// from the explicitly granted `*ViewAssigned`/`*ViewTeam`/`*ViewAll`
/// permission. A record-targeted action is therefore usable only when a real
/// View grant exists *and* the record lies inside that actual scope, so
/// `ASSIGNED` can never silently become `ALL` because a user also holds
/// `perform`/`edit`/`complete`/`print`.
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
  AppPermission.serviceRootCauseManage: AppPermission.serviceRootCauseView,
  AppPermission.serviceChargeResponsibilityManage:
      AppPermission.serviceChargeResponsibilityView,
  AppPermission.serviceMaterialRequestPurposeManage:
      AppPermission.serviceMaterialRequestPurposeView,
  // Enquiry actions need record visibility to target an Enquiry; the Enquiry
  // view grant is scope-less (company-wide), so this cannot widen a scope.
  // Create deliberately does NOT imply View (create-only stays usable through
  // the restricted reference lookups + Overview New Enquiry action).
  AppPermission.serviceEnquiryEdit: AppPermission.serviceEnquiryView,
  AppPermission.serviceEnquiryCancel: AppPermission.serviceEnquiryView,
  // The four scoped Services transaction actions below intentionally have NO
  // dependency. Their record visibility comes exclusively from the real View
  // grant resolved by the module scope resolvers:
  //   serviceJobAssignments.{create,edit,cancel}
  //   serviceInspections.{create,edit,complete,cancel}
  //   serviceMaterialRequests.{create,edit,cancel,print}
  //   serviceWorkExecutions.{create,edit,perform,complete,cancel}
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
