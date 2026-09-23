import 'package:modular_erp/modules/hr/module/hr_routes.dart';

/// Centralized legacy-route mapper.
///
/// Phase 0.3 moved HR destinations under the canonical `/app/hr` namespace.
/// Old URLs may still exist in notifications, bookmarks and browser history, so
/// they are rewritten (never duplicated as canonical routes) while preserving
/// dynamic path segments and query parameters.
///
/// Rules are ordered; the first segment-aware match wins. `/app/settings` and
/// its platform subpaths (`/app/settings/notifications`, `/app/settings/sync`)
/// are intentionally absent — they remain platform-global.
abstract final class LegacyRoutes {
  static const rules = <(String, String)>[
    // HR configuration.
    ('/app/settings/shifts', HrRoutes.shifts),
    ('/app/settings/work-locations', HrRoutes.workLocations),
    ('/app/settings/attendance-policies', HrRoutes.attendancePolicies),
    ('/app/settings/leave-types', HrRoutes.leaveTypes),
    ('/app/settings/leave-policies', HrRoutes.leavePolicies),
    ('/app/settings/holidays', HrRoutes.holidays),
    // HR module roots.
    ('/app/dashboard', HrRoutes.root),
    ('/app/employees', HrRoutes.employees),
    ('/app/attendance', HrRoutes.attendance),
    ('/app/leave', HrRoutes.leave),
    ('/app/reports', HrRoutes.reports),
  ];

  /// Returns the canonical location for a legacy [uri], or null when the URI is
  /// not a legacy route. Query parameters and dynamic segments are preserved.
  static String? rewrite(Uri uri) {
    for (final (from, to) in rules) {
      if (uri.path == from || uri.path.startsWith('$from/')) {
        final path = '$to${uri.path.substring(from.length)}';
        return Uri(
          path: path,
          queryParameters: uri.queryParameters.isEmpty
              ? null
              : uri.queryParameters,
        ).toString();
      }
    }
    return null;
  }
}
