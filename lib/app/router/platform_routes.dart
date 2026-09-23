/// Platform (cross-module) routes.
///
/// Application/account concerns that are not owned by a business module stay
/// outside module prefixes. Business modules must not nest these
/// (no `/app/hr/profile`, `/app/hr/notifications`).
abstract final class PlatformRoutes {
  static const app = '/app';
  static const profile = '/app/profile';
  static const changePassword = '/app/change-password';
  static const settings = '/app/settings';
  static const notifications = '/app/notifications';
  static const reminderSettings = '$settings/notifications';
  static const syncSettings = '$settings/sync';
}
