import '../../../../core/security/app_permission.dart';
import '../entities/auth_context.dart';

/// Product-level capabilities derived from permissions + linked employee +
/// company context. These are **not** permissions: they never replace
/// [AppPermission]; they express what a persona can actually do in the product.
///
/// Admin authority does not imply employee self-service: a capability that
/// describes self work requires a linked employee.
enum UserCapability {
  selfAttendance,
  selfAttendanceHistory,
  requestAttendanceCorrection,
  teamAttendance,
  companyAttendance,
  approveAttendanceCorrections,
  manageEmployees,
  manageAttendanceConfiguration,
  viewAttendanceReports,
  manageUsers,
  manageRoles,
  manageCompany,
  platformAdministration,
}

class UserCapabilityContext {
  UserCapabilityContext(
    Set<UserCapability> granted, {
    required this.hasLinkedEmployee,
  }) : _granted = Set.unmodifiable(granted);

  final Set<UserCapability> _granted;
  final bool hasLinkedEmployee;

  bool has(UserCapability capability) => _granted.contains(capability);
  bool hasAny(Iterable<UserCapability> capabilities) =>
      capabilities.any(_granted.contains);

  Set<UserCapability> get granted => _granted;

  static UserCapabilityContext none() =>
      UserCapabilityContext(const {}, hasLinkedEmployee: false);
}

/// Central capability resolver. Every consumer (navigation, route guards,
/// dashboard, profile, reminders) must use this instead of checking roles.
class UserCapabilityResolver {
  const UserCapabilityResolver();

  UserCapabilityContext resolve({
    required CompanyContext company,
    required PermissionSet permissions,
    EmployeeReference? employee,
  }) {
    final p = PermissionChecker(permissions);
    final linked = employee != null;
    final granted = <UserCapability>{};
    if (linked && p.can(AppPermission.attendanceViewSelf)) {
      granted
        ..add(UserCapability.selfAttendance)
        ..add(UserCapability.selfAttendanceHistory);
    }
    if (linked && p.can(AppPermission.attendanceRequestCorrection)) {
      granted.add(UserCapability.requestAttendanceCorrection);
    }
    // Team scope is resolved from the actor's own employee identity, so an
    // unlinked manager cannot have a meaningful team.
    if (linked && p.can(AppPermission.attendanceViewTeam)) {
      granted.add(UserCapability.teamAttendance);
    }
    if (p.can(AppPermission.attendanceViewAll)) {
      granted.add(UserCapability.companyAttendance);
    }
    if (p.can(AppPermission.attendanceApprove) &&
        (p.can(AppPermission.attendanceViewTeam) ||
            p.can(AppPermission.attendanceViewAll))) {
      granted.add(UserCapability.approveAttendanceCorrections);
    }
    if (p.canAny([
      AppPermission.employeeViewTeam,
      AppPermission.employeeViewAll,
      AppPermission.employeeCreate,
      AppPermission.employeeUpdate,
    ])) {
      granted.add(UserCapability.manageEmployees);
    }
    if (p.canAny([
      AppPermission.shiftView,
      AppPermission.workLocationView,
      AppPermission.attendancePolicyView,
    ])) {
      granted.add(UserCapability.manageAttendanceConfiguration);
    }
    if (p.can(AppPermission.attendanceReportView) &&
        (p.can(AppPermission.attendanceViewTeam) ||
            p.can(AppPermission.attendanceViewAll))) {
      granted.add(UserCapability.viewAttendanceReports);
    }
    if (p.can(AppPermission.userManage)) {
      granted.add(UserCapability.manageUsers);
    }
    if (p.can(AppPermission.roleManage)) {
      granted.add(UserCapability.manageRoles);
    }
    if (p.can(AppPermission.companyManage)) {
      granted.add(UserCapability.manageCompany);
    }
    if (p.can(AppPermission.companyManage) &&
        p.can(AppPermission.userManage) &&
        p.can(AppPermission.roleManage)) {
      granted.add(UserCapability.platformAdministration);
    }
    final context = UserCapabilityContext(granted, hasLinkedEmployee: linked);
    return context;
  }

  UserCapabilityContext forAuthContext(AuthContext account) => resolve(
    company: account.company,
    permissions: account.user.permissions,
    employee: account.employeeReference,
  );
}
