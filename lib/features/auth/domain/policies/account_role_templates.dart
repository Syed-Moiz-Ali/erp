import '../../../../core/security/app_permission.dart';
import '../entities/auth_context.dart';

/// Explicit local grant templates. A role label never authorizes an operation.
///
/// Self-service attendance permissions are deliberately **not** granted to
/// Super Admin / Company Admin by template: admin authority does not imply an
/// employee link. A linked admin can be granted these explicitly.
PermissionSet permissionsForRole(AppRole role) {
  final self = {
    AppPermission.employeeViewSelf,
    AppPermission.attendanceViewSelf,
    AppPermission.attendancePunchIn,
    AppPermission.attendancePunchOut,
    AppPermission.attendanceBreak,
    AppPermission.attendanceRequestCorrection,
  };
  if (role == AppRole.superAdmin || role == AppRole.companyAdmin) {
    return PermissionSet(AppPermission.values.where((p) => !self.contains(p)));
  }
  return PermissionSet(switch (role) {
    AppRole.employee => self,
    AppRole.manager => {
      ...self,
      AppPermission.employeeViewTeam,
      AppPermission.attendanceViewTeam,
      AppPermission.attendanceApprove,
      AppPermission.attendanceReportView,
    },
    AppRole.hr => {
      ...self,
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
    },
    _ => <AppPermission>{},
  });
}
