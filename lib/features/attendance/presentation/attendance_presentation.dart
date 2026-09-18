import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/result.dart';
import '../../../core/localization/app_formatters.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../domain/attendance_engine.dart';
import '../domain/attendance_models.dart';
import '../domain/shift_workday_resolver.dart';
import 'attendance_localization.dart';

abstract final class AttendancePresentation {
  static String failure(BuildContext c, Failure f) {
    final matches = AttendanceFailureCode.values.where((v) => v.name == f.code);
    return matches.isEmpty
        ? c.l10n.attendancePersistenceFailure
        : attendanceFailureLabel(c.l10n, matches.single);
  }

  static String state(BuildContext c, AttendanceWorkdayState s) => switch (s) {
    AttendanceWorkdayState.notStarted => c.l10n.attendanceNotPunchedIn,
    AttendanceWorkdayState.working => c.l10n.attendanceWorking,
    AttendanceWorkdayState.onBreak => c.l10n.attendanceOnBreak,
    AttendanceWorkdayState.completed => c.l10n.attendanceCompleteTitle,
  };
  static AppStatus status(AttendanceWorkdayState s) => switch (s) {
    AttendanceWorkdayState.working => AppStatus.success,
    AttendanceWorkdayState.onBreak => AppStatus.warning,
    AttendanceWorkdayState.completed => AppStatus.info,
    _ => AppStatus.neutral,
  };
  static String action(BuildContext c, AttendanceEventType type) =>
      switch (type) {
        AttendanceEventType.punchIn => c.l10n.attendancePunchIn,
        AttendanceEventType.breakStart => c.l10n.attendanceTakeBreak,
        AttendanceEventType.breakEnd => c.l10n.attendanceResumeWork,
        AttendanceEventType.punchOut => c.l10n.attendancePunchOut,
      };
  static String event(BuildContext c, AttendanceEventType type) =>
      switch (type) {
        AttendanceEventType.breakStart => c.l10n.attendanceBreakStartedLabel,
        AttendanceEventType.breakEnd => c.l10n.attendanceWorkResumedLabel,
        _ => action(c, type),
      };
  static String sync(BuildContext c, AttendanceSyncStatus s) => switch (s) {
    AttendanceSyncStatus.pending => c.l10n.attendancePending,
    AttendanceSyncStatus.failed => c.l10n.attendanceFailed,
    AttendanceSyncStatus.rejected => c.l10n.attendanceRejected,
    _ => c.l10n.attendanceSynced,
  };
  static String time(BuildContext c, AttendanceContext a, DateTime? instant) {
    if (instant == null) return '—';
    final time =
        c.read<CompanyTimeService?>() ?? const FixedOffsetCompanyTimeService();
    final wall = time.localWallTime(instant, a.snapshot.timezone);
    return wall is Success<DateTime>
        ? AppTimeFormatter(Localizations.localeOf(c)).time(wall.value)
        : c.l10n.attendanceUnsupportedTimezone;
  }

  static String duration(BuildContext c, Duration d) =>
      AppTimeFormatter(Localizations.localeOf(c)).duration(d, c.l10n);
  static String meters(BuildContext c, double value) => c.l10n.attendanceMeters(
    AppNumberFormatter(
      Localizations.localeOf(c),
    ).decimal(value, decimalDigits: 0),
  );
}
