import 'package:modular_erp/core/security/access_scope_resolver.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_scope.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'workforce_attendance.dart';

class AttendanceScopeResolver {
  const AttendanceScopeResolver();
  AttendanceScope resolve(AuthContext context) =>
      switch (const AccessScopeResolver().resolve(
        context.user.permissions,
        all: AppPermission.attendanceViewAll,
        team: AppPermission.attendanceViewTeam,
        self: AppPermission.attendanceViewSelf,
      )) {
        PermissionScope.all => AttendanceScope.company,
        PermissionScope.team => AttendanceScope.team,
        _ => AttendanceScope.self,
      };
}
