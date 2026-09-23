import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'workforce_attendance.dart';

class AttendanceScopeResolver {
  const AttendanceScopeResolver();
  AttendanceScope resolve(AuthContext context) {
    final p = PermissionChecker(context.user.permissions);
    if (p.can(AppPermission.attendanceViewAll)) return AttendanceScope.company;
    if (p.can(AppPermission.attendanceViewTeam)) return AttendanceScope.team;
    if (p.can(AppPermission.attendanceViewSelf)) return AttendanceScope.self;
    return AttendanceScope.self;
  }
}
