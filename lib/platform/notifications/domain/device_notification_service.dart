/// Status of the OS-level notification permission.
enum DeviceNotificationPermission { granted, denied, unsupported }

/// A scheduled OS-level reminder. Content is generated at scheduling time in
/// the active locale; deep links are enforced later by the router guards.
class DeviceNotificationRequest {
  const DeviceNotificationRequest({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    this.route,
  });
  final String id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String? route;
}

/// Boundary around the platform notification plugin. The attendance domain
/// never calls a plugin directly, and tests use a fake implementation.
abstract interface class DeviceNotificationService {
  Future<DeviceNotificationPermission> permissionStatus();
  Future<DeviceNotificationPermission> requestPermission();
  Future<void> schedule(DeviceNotificationRequest request);
  Future<void> cancel(String id);
  Future<void> cancelAll();

  /// Opens the platform settings so the user can grant permission manually.
  Future<void> openSettings();
}

/// Safe default used before a platform implementation is configured.
/// It never claims that a reminder was scheduled.
class NoopDeviceNotificationService implements DeviceNotificationService {
  const NoopDeviceNotificationService();

  @override
  Future<DeviceNotificationPermission> permissionStatus() async =>
      DeviceNotificationPermission.unsupported;

  @override
  Future<DeviceNotificationPermission> requestPermission() async =>
      DeviceNotificationPermission.unsupported;

  @override
  Future<void> schedule(DeviceNotificationRequest request) async {}

  @override
  Future<void> cancel(String id) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> openSettings() async {}
}
