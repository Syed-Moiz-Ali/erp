import '../../../../core/security/app_permission.dart';
import '../entities/auth_context.dart';

/// Explicit local grant templates. A role label never authorizes an operation.
///
/// Self-service permissions (attendance/leave self actions) are deliberately
/// **not** granted to Super Admin / Company Admin by template: admin authority
/// does not imply an employee link. A linked admin can be granted them
/// explicitly.
PermissionSet permissionsForRole(AppRole role) {
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
  if (role == AppRole.superAdmin || role == AppRole.companyAdmin) {
    return PermissionSet(
      AppPermission.values.where((p) => !selfService.contains(p)),
    );
  }
  // Everyone can see their own leave and the holiday calendar through the
  // Leave module; holiday *configuration* stays administrative.
  final base = {...selfService};
  return PermissionSet(switch (role) {
    AppRole.employee => base,
    AppRole.manager => {
      ...base,
      AppPermission.employeeViewTeam,
      AppPermission.attendanceViewTeam,
      AppPermission.attendanceApprove,
      AppPermission.attendanceReportView,
      AppPermission.leaveViewTeam,
      AppPermission.leaveApproveTeam,
      AppPermission.leaveBalanceViewTeam,
    },
    AppRole.hr => {
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
    },
    _ => <AppPermission>{},
  });
}
