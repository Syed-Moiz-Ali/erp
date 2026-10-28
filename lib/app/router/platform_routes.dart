import 'package:modular_erp/app/router/route_segments.dart';

/// Platform (cross-module) routes.
///
/// Application/account concerns that are not owned by a business module stay
/// outside module prefixes. Business modules must not nest these
/// (no `/app/hr/profile`, `/app/hr/notifications`).
///
/// This is the single owner of these path values; [AppRoutes] and any other
/// caller must reference these constants instead of repeating literals.
abstract final class PlatformRoutes {
  /// Application root.
  static const root = '/';

  /// Authentication entry points (unauthenticated).
  static const bootstrap = '/bootstrap';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';

  /// Authenticated application shell.
  static const app = '/${RouteSegments.app}';
  static const dashboard = '$app/dashboard';
  static const profile = '$app/profile';
  static const changePassword = '$app/change-password';
  static const settings = '$app/settings';
  static const access = '$settings/access';
  static const modules = '$settings/modules';
  static const notifications = '$app/notifications';
  static const reminderSettings = '$settings/notifications';
  static const syncSettings = '$settings/sync';

  /// Utility / status destinations.
  static const more = '$app/more';
  static const syncInspector = '$app/sync-inspector';
  static const unauthorized = '$app/access-denied';
  static const unavailable = '$app/module-unavailable';
  static const notFound = '$app/not-found';
  static const noDestinations = '$app/no-destinations';

  /// Internal design-system preview (authenticated + demo-gated).
  static const designSystem = '/design-system';
}
