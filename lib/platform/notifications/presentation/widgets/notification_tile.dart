import 'package:flutter/material.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/notifications/domain/app_notification.dart';
import 'package:modular_erp/platform/notifications/presentation/notification_presentation.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });
  final AppNotification notification;
  final VoidCallback onTap;

  IconData get _icon => switch (notification.type) {
    AppNotificationType.shiftStartingSoon => Icons.schedule_outlined,
    AppNotificationType.punchOutReminder => Icons.logout_outlined,
    AppNotificationType.correctionApproved => Icons.check_circle_outline,
    AppNotificationType.correctionRejected => Icons.cancel_outlined,
    AppNotificationType.attendanceSyncFailed => Icons.sync_problem_outlined,
    AppNotificationType.attendanceConflict => Icons.report_problem_outlined,
    AppNotificationType.pendingCorrectionReview => Icons.fact_check_outlined,
    AppNotificationType.leaveRequestSubmitted => Icons.event_available_outlined,
    AppNotificationType.leaveRequestApproved => Icons.event_available_outlined,
    AppNotificationType.leaveRequestRejected => Icons.event_busy_outlined,
    AppNotificationType.leaveRequestCancelled => Icons.event_busy_outlined,
    AppNotificationType.leaveApprovalRequired => Icons.event_note_outlined,
    AppNotificationType.serviceWorkAssigned => Icons.assignment_ind_outlined,
    AppNotificationType.unknown => Icons.notifications_none_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final content = notificationContent(notification, l);
    final relative = AppDateFormatter(
      Localizations.localeOf(context),
    ).relative(notification.createdAt, l);
    final semanticsLabel = !notification.isRead
        ? '${l.notificationsUnread}: ${content.title}'
        : content.title;
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: AppCard(
        variant: AppCardVariant.interactive,
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, size: 20, color: AppColors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          content.title,
                          style: AppTypography.of(context).cardTitle,
                        ),
                      ),
                      if (!notification.isRead)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: AppSpacing.sm,
                          ),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.brandPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    content.body,
                    style: AppTypography.of(
                      context,
                    ).caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    relative,
                    style: AppTypography.of(
                      context,
                    ).caption.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
