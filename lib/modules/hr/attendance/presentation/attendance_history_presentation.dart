import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_history.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';

abstract final class AttendanceHistoryPresentation {
  static String label(BuildContext c, AttendanceHistoryStatus s) => switch (s) {
    AttendanceHistoryStatus.present => c.l10n.historyPresent,
    AttendanceHistoryStatus.late => c.l10n.historyLate,
    AttendanceHistoryStatus.working => c.l10n.attendanceWorking,
    AttendanceHistoryStatus.incomplete => c.l10n.historyIncomplete,
  };
  static AppStatus color(AttendanceHistoryStatus s) => switch (s) {
    AttendanceHistoryStatus.present => AppStatus.success,
    AttendanceHistoryStatus.late ||
    AttendanceHistoryStatus.incomplete => AppStatus.warning,
    AttendanceHistoryStatus.working => AppStatus.info,
  };
  static Widget badge(BuildContext c, AttendanceHistoryStatus s) =>
      AppStatusBadge(
        label: label(c, s),
        status: color(s),
        icon: switch (s) {
          AttendanceHistoryStatus.present => Icons.check_circle_outline,
          AttendanceHistoryStatus.late => Icons.schedule,
          AttendanceHistoryStatus.working => Icons.play_circle_outline,
          AttendanceHistoryStatus.incomplete => Icons.warning_amber_outlined,
        },
      );
  static String time(
    BuildContext c,
    AttendanceDay day,
    DateTime? value, {
    bool includeDate = false,
  }) {
    return _time(
      c,
      day.snapshot.timezone,
      day.attendanceDate,
      value,
      includeDate,
    );
  }

  static String range(BuildContext c, String start, String end) =>
      AppTimeFormatter(Localizations.localeOf(c)).range(start, end, c.l10n);
  static String itemTime(
    BuildContext c,
    AttendanceHistoryItem item,
    DateTime? value, {
    bool includeDate = false,
  }) => _time(c, item.timezone, item.attendanceDate, value, includeDate);
  static String _time(
    BuildContext c,
    String timezone,
    DateTime date,
    DateTime? value,
    bool includeDate,
  ) {
    if (value == null) return c.l10n.historyNotRecorded;
    final service =
        c.read<CompanyTimeService?>() ?? const FixedOffsetCompanyTimeService();
    final result = service.localWallTime(value, timezone);
    if (result case Failed<DateTime>()) {
      return c.l10n.attendanceUnsupportedTimezone;
    }
    final wall = (result as Success<DateTime>).value;
    final locale = Localizations.localeOf(c);
    final time = AppTimeFormatter(locale).time(wall);
    return includeDate &&
            (wall.year != date.year ||
                wall.month != date.month ||
                wall.day != date.day)
        ? c.l10n.dateTimeValue(AppDateFormatter(locale).date(wall), time)
        : time;
  }
}
