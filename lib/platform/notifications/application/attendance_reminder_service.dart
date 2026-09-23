import 'package:flutter/widgets.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/preferences/app_preferences_repository.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/l10n/generated/app_localizations.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/platform/notifications/domain/device_notification_service.dart';
import 'reminder_context.dart';

/// Reconciles OS-level attendance reminders with the current employee, shift,
/// attendance state and preferences. Idempotent: always cancels managed ids
/// before rescheduling so stale reminders never survive a shift/config change.
class AttendanceReminderService {
  const AttendanceReminderService({
    required this.preferences,
    required this.source,
    required this.device,
    required this.clock,
  });

  static const shiftReminderId = 'attendance.shiftReminder';
  static const punchOutReminderId = 'attendance.punchOutReminder';

  final AppPreferencesRepository preferences;
  final ReminderContextSource source;
  final DeviceNotificationService device;
  final AppClock clock;

  Future<Result<void>> reconcile({Locale locale = const Locale('en')}) async {
    await device.cancel(shiftReminderId);
    await device.cancel(punchOutReminderId);
    final prefsResult = await preferences.readReminderPreferences();
    if (prefsResult case Failed<ReminderPreferences>(:final failure)) {
      return Failed(failure);
    }
    final prefs = (prefsResult as Success<ReminderPreferences>).value;
    if (!prefs.shiftReminderEnabled && !prefs.punchOutReminderEnabled) {
      return const Success(null);
    }
    // Never pretend a reminder will fire when the OS permission is missing.
    if (await device.permissionStatus() !=
        DeviceNotificationPermission.granted) {
      return const Success(null);
    }
    final loaded = await source.load();
    if (loaded case Failed<ReminderContext?>(:final failure)) {
      return Failed(failure);
    }
    final context = (loaded as Success<ReminderContext?>).value;
    if (context == null) return const Success(null);
    final l = lookupAppLocalizations(locale);
    final now = clock.now().toUtc();
    if (prefs.shiftReminderEnabled &&
        context.scheduled &&
        context.state == AttendanceWorkdayState.notStarted) {
      final at = context.scheduledStart.subtract(
        Duration(minutes: prefs.shiftReminderMinutesBefore),
      );
      if (at.isAfter(now)) {
        await device.schedule(
          DeviceNotificationRequest(
            id: shiftReminderId,
            title: l.notifShiftSoonTitle,
            body: l.notifShiftSoonBody,
            scheduledAt: at,
            route: AppRoutes.attendance,
          ),
        );
      }
    }
    if (prefs.punchOutReminderEnabled &&
        (context.state == AttendanceWorkdayState.working ||
            context.state == AttendanceWorkdayState.onBreak)) {
      final onBreak = context.state == AttendanceWorkdayState.onBreak;
      final at = context.scheduledEnd.isAfter(now)
          ? context.scheduledEnd
          : now.add(const Duration(minutes: 1));
      await device.schedule(
        DeviceNotificationRequest(
          id: punchOutReminderId,
          title: l.notifPunchOutTitle,
          body: onBreak ? l.notifShiftEndingOnBreakBody : l.notifPunchOutBody,
          scheduledAt: at,
          route: AppRoutes.attendance,
        ),
      );
    }
    return const Success(null);
  }
}
