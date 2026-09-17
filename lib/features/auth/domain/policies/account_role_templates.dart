import '../../../../core/security/app_permission.dart';
import '../entities/auth_context.dart';

/// Explicit local grant templates. A role label never authorizes an operation.
PermissionSet permissionsForRole(AppRole role) {
  if (role == AppRole.superAdmin || role == AppRole.companyAdmin) {
    return PermissionSet(AppPermission.values);
  }
  final self = {
    AppPermission.employeeViewSelf,
    AppPermission.attendanceViewSelf,
    AppPermission.attendancePunchIn,
    AppPermission.attendancePunchOut,
    AppPermission.attendanceBreak,
    AppPermission.attendanceRequestCorrection,
  };
  return PermissionSet(switch (role) {
    AppRole.employee => self,
    AppRole.manager => {
      ...self,
      AppPermission.employeeViewTeam,
      AppPermission.attendanceViewTeam,
      AppPermission.attendanceApprove,
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
