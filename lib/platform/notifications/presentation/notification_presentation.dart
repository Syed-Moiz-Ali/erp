import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/module/services_routes.dart';
import 'package:modular_erp/platform/notifications/domain/app_notification.dart';

class NotificationContent {
  const NotificationContent(this.title, this.body);
  final String title, body;
}

/// Resolves localized copy at render time so language changes re-render.
NotificationContent notificationContent(
  AppNotification notification,
  AppLocalizations l,
) => switch (notification.type) {
  AppNotificationType.shiftStartingSoon => NotificationContent(
    l.notifShiftSoonTitle,
    l.notifShiftSoonBody,
  ),
  AppNotificationType.punchOutReminder => NotificationContent(
    l.notifPunchOutTitle,
    notification.payload['onBreak'] == true
        ? l.notifShiftEndingOnBreakBody
        : l.notifPunchOutBody,
  ),
  AppNotificationType.correctionApproved => NotificationContent(
    l.notifCorrectionApprovedTitle,
    l.notifCorrectionApprovedBody,
  ),
  AppNotificationType.correctionRejected => NotificationContent(
    l.notifCorrectionRejectedTitle,
    l.notifCorrectionRejectedBody,
  ),
  AppNotificationType.attendanceSyncFailed => NotificationContent(
    l.notifSyncFailedTitle,
    l.notifSyncFailedBody,
  ),
  AppNotificationType.attendanceConflict => NotificationContent(
    l.notifConflictTitle,
    l.notifConflictBody,
  ),
  AppNotificationType.pendingCorrectionReview => NotificationContent(
    l.notifPendingReviewTitle,
    l.notifPendingReviewBody,
  ),
  AppNotificationType.leaveRequestSubmitted => NotificationContent(
    l.notifLeaveSubmittedTitle,
    l.notifLeaveSubmittedBody,
  ),
  AppNotificationType.leaveRequestApproved => NotificationContent(
    l.notifLeaveApprovedTitle,
    l.notifLeaveApprovedBody,
  ),
  AppNotificationType.leaveRequestRejected => NotificationContent(
    l.notifLeaveRejectedTitle,
    l.notifLeaveRejectedBody,
  ),
  AppNotificationType.leaveRequestCancelled => NotificationContent(
    l.notifLeaveCancelledTitle,
    l.notifLeaveCancelledBody,
  ),
  AppNotificationType.leaveApprovalRequired => NotificationContent(
    l.notifLeaveApprovalRequiredTitle,
    l.notifLeaveApprovalRequiredBody,
  ),
  AppNotificationType.serviceWorkAssigned => NotificationContent(
    l.notifServiceWorkAssignedTitle,
    l.notifServiceWorkAssignedBody,
  ),
  AppNotificationType.unknown => NotificationContent(
    l.notifUnknownTitle,
    l.notifUnknownBody,
  ),
};

/// Deep links still pass through the router guards, so an unauthorized user
/// lands on the existing access-denied / module-unavailable pages.
String? notificationRoute(AppNotification notification) =>
    switch (notification.type) {
      AppNotificationType.correctionApproved ||
      AppNotificationType.correctionRejected =>
        _correctionId(notification) != null
            ? AppRoutes.attendanceCorrectionDetails(
                _correctionId(notification)!,
              )
            : AppRoutes.attendanceHistory,
      AppNotificationType.pendingCorrectionReview =>
        _correctionId(notification) != null
            ? AppRoutes.attendanceReviewDetails(_correctionId(notification)!)
            : AppRoutes.attendanceRequests,
      AppNotificationType.shiftStartingSoon ||
      AppNotificationType.punchOutReminder => AppRoutes.attendance,
      AppNotificationType.attendanceSyncFailed ||
      AppNotificationType.attendanceConflict => AppRoutes.attendanceHistory,
      AppNotificationType.leaveRequestSubmitted ||
      AppNotificationType.leaveRequestApproved ||
      AppNotificationType.leaveRequestRejected ||
      AppNotificationType.leaveRequestCancelled ||
      AppNotificationType.leaveApprovalRequired =>
        _leaveRequestId(notification) != null
            ? AppRoutes.leaveRequestDetails(_leaveRequestId(notification)!)
            : AppRoutes.leave,
      AppNotificationType.serviceWorkAssigned =>
        _assignmentId(notification) != null
            ? ServicesRoutes.assignment(_assignmentId(notification)!)
            : ServicesRoutes.assignments,
      AppNotificationType.unknown => notification.route,
    };

String? _assignmentId(AppNotification notification) {
  final value = notification.payload['assignmentId'];
  return value is String && value.isNotEmpty ? value : null;
}

String? _correctionId(AppNotification notification) {
  final value = notification.payload['correctionId'];
  return value is String && value.isNotEmpty ? value : null;
}

String? _leaveRequestId(AppNotification notification) {
  final value = notification.payload['requestId'];
  return value is String && value.isNotEmpty ? value : null;
}
