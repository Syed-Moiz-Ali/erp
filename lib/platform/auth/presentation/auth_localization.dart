import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/core/security/app_permission.dart';

extension DemoScenarioLocalization on DemoScenario {
  /// Demo persona label. Fixture copy only — never authorization.
  String personaLabel(AppLocalizations l) => switch (this) {
    DemoScenario.platformAdmin => l.demoPersonaPlatformAdmin,
    DemoScenario.companyAdmin => l.demoPersonaCompanyAdmin,
    DemoScenario.hr => l.demoPersonaHr,
    DemoScenario.manager => l.demoPersonaManager,
    DemoScenario.employee => l.demoPersonaEmployee,
  };

  /// Human description of what the seeded grants allow.
  String accessSummary(AppLocalizations l) => switch (this) {
    DemoScenario.platformAdmin => l.demoAccessPlatformAdmin,
    DemoScenario.companyAdmin => l.demoAccessCompanyAdmin,
    DemoScenario.hr => l.demoAccessHr,
    DemoScenario.manager => l.demoAccessManager,
    DemoScenario.employee => l.demoAccessEmployee,
  };
}

extension AccountStatusLocalization on AccountStatus {
  String label(AppLocalizations l10n) => switch (this) {
    AccountStatus.active => l10n.authStatusActive,
    AccountStatus.suspended => l10n.authStatusSuspended,
    AccountStatus.inactive => l10n.authStatusInactive,
  };
}

extension AppPermissionLocalization on AppPermission {
  String label(AppLocalizations l10n) => switch (this) {
    AppPermission.employeeViewSelf => l10n.permissionEmployeeViewSelf,
    AppPermission.employeeViewTeam => l10n.permissionEmployeeViewTeam,
    AppPermission.employeeViewAll => l10n.permissionEmployeeViewAll,
    AppPermission.employeeCreate => l10n.permissionEmployeeCreate,
    AppPermission.employeeUpdate => l10n.permissionEmployeeUpdate,
    AppPermission.employeeDeactivate => l10n.permissionEmployeeDeactivate,
    AppPermission.attendanceViewSelf => l10n.permissionAttendanceViewSelf,
    AppPermission.attendanceViewTeam => l10n.permissionAttendanceViewTeam,
    AppPermission.attendanceViewAll => l10n.permissionAttendanceViewAll,
    AppPermission.attendancePunchIn => l10n.permissionAttendancePunchIn,
    AppPermission.attendancePunchOut => l10n.permissionAttendancePunchOut,
    AppPermission.attendanceBreak => l10n.permissionAttendanceBreak,
    AppPermission.attendanceRequestCorrection =>
      l10n.permissionAttendanceRequestCorrection,
    AppPermission.attendanceCorrect => l10n.permissionAttendanceCorrect,
    AppPermission.attendanceApprove => l10n.permissionAttendanceApprove,
    AppPermission.shiftView => l10n.permissionShiftView,
    AppPermission.shiftManage => l10n.permissionShiftManage,
    AppPermission.workLocationView => l10n.permissionWorkLocationView,
    AppPermission.workLocationManage => l10n.permissionWorkLocationManage,
    AppPermission.attendancePolicyView => l10n.permissionAttendancePolicyView,
    AppPermission.attendancePolicyManage =>
      l10n.permissionAttendancePolicyManage,
    AppPermission.companyManage => l10n.permissionCompanyManage,
    AppPermission.userManage => l10n.permissionUserManage,
    AppPermission.attendanceReportView => l10n.permissionAttendanceReportView,
    AppPermission.leaveViewSelf => l10n.permissionLeaveViewSelf,
    AppPermission.leaveRequest => l10n.permissionLeaveRequest,
    AppPermission.leaveCancelSelf => l10n.permissionLeaveCancelSelf,
    AppPermission.leaveViewTeam => l10n.permissionLeaveViewTeam,
    AppPermission.leaveApproveTeam => l10n.permissionLeaveApproveTeam,
    AppPermission.leaveViewAll => l10n.permissionLeaveViewAll,
    AppPermission.leaveApproveAll => l10n.permissionLeaveApproveAll,
    AppPermission.leaveManage => l10n.permissionLeaveManage,
    AppPermission.leaveBalanceViewSelf => l10n.permissionLeaveBalanceViewSelf,
    AppPermission.leaveBalanceViewTeam => l10n.permissionLeaveBalanceViewTeam,
    AppPermission.leaveBalanceViewAll => l10n.permissionLeaveBalanceViewAll,
    AppPermission.leaveBalanceAdjust => l10n.permissionLeaveBalanceAdjust,
    AppPermission.leaveTypeView => l10n.permissionLeaveTypeView,
    AppPermission.leaveTypeManage => l10n.permissionLeaveTypeManage,
    AppPermission.leavePolicyView => l10n.permissionLeavePolicyView,
    AppPermission.leavePolicyManage => l10n.permissionLeavePolicyManage,
    AppPermission.holidayView => l10n.permissionHolidayView,
    AppPermission.holidayManage => l10n.permissionHolidayManage,
    AppPermission.leaveReportView => l10n.permissionLeaveReportView,
    AppPermission.accessUsersView => l10n.permissionAccessUsersView,
    AppPermission.accessPermissionsManage =>
      l10n.permissionAccessPermissionsManage,
    AppPermission.companyModulesView => l10n.permissionCompanyModulesView,
    AppPermission.platformModulesManage => l10n.permissionPlatformModulesManage,
    AppPermission.serviceCustomerView => l10n.permissionServiceCustomerView,
    AppPermission.serviceCustomerCreate => l10n.permissionServiceCustomerCreate,
    AppPermission.serviceCustomerEdit => l10n.permissionServiceCustomerEdit,
    AppPermission.serviceCustomerDeactivate =>
      l10n.permissionServiceCustomerDeactivate,
    AppPermission.serviceSiteView => l10n.permissionServiceSiteView,
    AppPermission.serviceSiteCreate => l10n.permissionServiceSiteCreate,
    AppPermission.serviceSiteEdit => l10n.permissionServiceSiteEdit,
    AppPermission.serviceSiteDeactivate => l10n.permissionServiceSiteDeactivate,
    AppPermission.serviceTeamView => l10n.permissionServiceTeamView,
    AppPermission.serviceTeamManage => l10n.permissionServiceTeamManage,
    AppPermission.serviceTypeView => l10n.permissionServiceTypeView,
    AppPermission.serviceTypeManage => l10n.permissionServiceTypeManage,
    AppPermission.complaintTypeView => l10n.permissionComplaintTypeView,
    AppPermission.complaintTypeManage => l10n.permissionComplaintTypeManage,
    AppPermission.servicePriorityView => l10n.permissionServicePriorityView,
    AppPermission.servicePriorityManage => l10n.permissionServicePriorityManage,
    AppPermission.serviceTicketTypeView => l10n.permissionServiceTicketTypeView,
    AppPermission.serviceTicketTypeManage =>
      l10n.permissionServiceTicketTypeManage,
    AppPermission.serviceEnquiryView => l10n.permissionServiceEnquiryView,
    AppPermission.serviceEnquiryCreate => l10n.permissionServiceEnquiryCreate,
    AppPermission.serviceEnquiryEdit => l10n.permissionServiceEnquiryEdit,
    AppPermission.serviceEnquiryCancel => l10n.permissionServiceEnquiryCancel,
    AppPermission.serviceJobAssignmentViewAssigned ||
    AppPermission.serviceJobAssignmentViewTeam ||
    AppPermission.serviceJobAssignmentViewAll =>
      l10n.permissionServiceJobAssignmentView,
    AppPermission.serviceJobAssignmentCreate =>
      l10n.permissionServiceJobAssignmentCreate,
    AppPermission.serviceJobAssignmentEdit =>
      l10n.permissionServiceJobAssignmentEdit,
    AppPermission.serviceJobAssignmentCancel =>
      l10n.permissionServiceJobAssignmentCancel,
  };
}
