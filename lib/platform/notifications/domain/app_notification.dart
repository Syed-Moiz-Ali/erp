/// Strongly typed notification taxonomy. Extensible for future modules.
enum AppNotificationType {
  shiftStartingSoon,
  punchOutReminder,
  correctionApproved,
  correctionRejected,
  attendanceSyncFailed,
  attendanceConflict,
  pendingCorrectionReview,
  leaveRequestSubmitted,
  leaveRequestApproved,
  leaveRequestRejected,
  leaveRequestCancelled,
  leaveApprovalRequired,
  serviceWorkAssigned,
  unknown;

  static AppNotificationType fromName(String? name) => values.firstWhere(
    (t) => t.name == name,
    orElse: () => AppNotificationType.unknown,
  );
}

enum AppNotificationPriority { low, normal, high }

enum AppNotificationSource { local, system, remote }

/// Domain record for the in-app notification center. Content is stored
/// semantically (type + payload) and localized at render time.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.type,
    required this.createdAt,
    this.payload = const {},
    this.priority = AppNotificationPriority.normal,
    this.source = AppNotificationSource.local,
    this.route,
    this.dedupeKey,
    this.readAt,
  });

  final String id;
  final String companyId;
  final String userId;
  final AppNotificationType type;
  final Map<String, dynamic> payload;
  final AppNotificationPriority priority;
  final AppNotificationSource source;
  final String? route;
  final String? dedupeKey;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  AppNotification copyWith({DateTime? readAt}) => AppNotification(
    id: id,
    companyId: companyId,
    userId: userId,
    type: type,
    payload: payload,
    priority: priority,
    source: source,
    route: route,
    dedupeKey: dedupeKey,
    createdAt: createdAt,
    readAt: readAt ?? this.readAt,
  );
}
