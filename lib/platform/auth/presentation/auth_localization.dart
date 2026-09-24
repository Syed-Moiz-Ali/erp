import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/core/security/app_permission.dart';

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
  };
}
