import '../../../l10n/l10n.dart';
import '../domain/entities/auth_context.dart';
import '../../../core/security/app_permission.dart';

extension AppRoleLocalization on AppRole {
  String label(AppLocalizations l10n) => switch (this) {
    AppRole.superAdmin => l10n.authRoleSuperAdmin,
    AppRole.companyAdmin => l10n.authRoleCompanyAdmin,
    AppRole.hr => l10n.authRoleHr,
    AppRole.manager => l10n.authRoleManager,
    AppRole.employee => l10n.authRoleEmployee,
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
    AppPermission.roleManage => l10n.permissionRoleManage,
    AppPermission.attendanceReportView => l10n.permissionAttendanceReportView,
  };
}
