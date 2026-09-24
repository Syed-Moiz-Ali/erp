import 'package:modular_erp/core/security/app_permission.dart';

/// Demo/test fixture only. **Not** an authorization concept: it is used solely to
/// seed distinct permission grant sets for the built-in demo accounts. Runtime
/// authorization always evaluates the resulting grants, never this label.
enum DemoScenario { platformAdmin, companyAdmin, hr, manager, employee }

/// Explicit grant fixture for a demo scenario. A scenario only means
/// "select these permissions for me"; it never confers authority by name.
PermissionSet demoScenarioGrants(DemoScenario scenario) {
  const selfService = {
    AppPermission.employeeViewSelf,
    AppPermission.attendanceViewSelf,
    AppPermission.attendancePunchIn,
    AppPermission.attendancePunchOut,
    AppPermission.attendanceBreak,
    AppPermission.attendanceRequestCorrection,
    AppPermission.leaveViewSelf,
    AppPermission.leaveRequest,
    AppPermission.leaveCancelSelf,
    AppPermission.leaveBalanceViewSelf,
  };
  const platformOnly = {
    AppPermission.companyManage,
    AppPermission.platformModulesManage,
  };
  if (scenario == DemoScenario.platformAdmin) {
    return PermissionSet(
      AppPermission.values.where((p) => !selfService.contains(p)),
    );
  }
  if (scenario == DemoScenario.companyAdmin) {
    // Company admin manages company access but not platform-only permissions.
    return PermissionSet(
      AppPermission.values.where(
        (p) => !selfService.contains(p) && !platformOnly.contains(p),
      ),
    );
  }
  final base = {...selfService};
  return PermissionSet(switch (scenario) {
    DemoScenario.employee => base,
    DemoScenario.manager => {
      ...base,
      AppPermission.employeeViewTeam,
      AppPermission.attendanceViewTeam,
      AppPermission.attendanceApprove,
      AppPermission.attendanceReportView,
      AppPermission.leaveViewTeam,
      AppPermission.leaveApproveTeam,
      AppPermission.leaveBalanceViewTeam,
      // View-only Services access (demonstrates view vs manage wiring).
      AppPermission.serviceCustomerView,
    },
    DemoScenario.hr => {
      ...base,
      AppPermission.employeeViewAll,
      AppPermission.employeeCreate,
      AppPermission.employeeUpdate,
      AppPermission.employeeDeactivate,
      AppPermission.attendanceViewAll,
      AppPermission.attendanceCorrect,
      AppPermission.attendanceApprove,
      AppPermission.shiftView,
      AppPermission.shiftManage,
      AppPermission.workLocationView,
      AppPermission.workLocationManage,
      AppPermission.attendancePolicyView,
      AppPermission.attendancePolicyManage,
      AppPermission.attendanceReportView,
      AppPermission.leaveViewAll,
      AppPermission.leaveApproveAll,
      AppPermission.leaveManage,
      AppPermission.leaveBalanceViewAll,
      AppPermission.leaveBalanceAdjust,
      AppPermission.leaveTypeView,
      AppPermission.leaveTypeManage,
      AppPermission.leavePolicyView,
      AppPermission.leavePolicyManage,
      AppPermission.holidayView,
      AppPermission.holidayManage,
      AppPermission.leaveReportView,
      // Full Services Phase 1 management.
      AppPermission.serviceCustomerView,
      AppPermission.serviceCustomerCreate,
      AppPermission.serviceCustomerEdit,
      AppPermission.serviceCustomerDeactivate,
      AppPermission.serviceSiteView,
      AppPermission.serviceSiteCreate,
      AppPermission.serviceSiteEdit,
      AppPermission.serviceSiteDeactivate,
      AppPermission.serviceTeamView,
      AppPermission.serviceTeamManage,
      AppPermission.serviceTypeView,
      AppPermission.serviceTypeManage,
      AppPermission.complaintTypeView,
      AppPermission.complaintTypeManage,
      AppPermission.servicePriorityView,
      AppPermission.servicePriorityManage,
      AppPermission.serviceTicketTypeView,
      AppPermission.serviceTicketTypeManage,
    },
    _ => <AppPermission>{},
  });
}
