import 'package:flutter/material.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/attendance/data/workforce_attendance_read_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_history.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_summary_calculator.dart';
import 'package:modular_erp/modules/hr/attendance/domain/workforce_attendance.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/widgets/attendance_timeline.dart';

class WorkforceAttendanceDetailsPage extends StatelessWidget {
  const WorkforceAttendanceDetailsPage({
    super.key,
    required this.repository,
    required this.employeeId,
    required this.dayId,
    required this.scope,
  });
  final WorkforceAttendanceReadRepository repository;
  final String employeeId, dayId;
  final AttendanceScope scope;
  @override
  Widget build(BuildContext context) =>
      FutureBuilder<Result<AttendanceDayDetails?>>(
        future: repository.readDay(
          employeeId: employeeId,
          dayId: dayId,
          scope: scope,
        ),
        builder: (context, snapshot) {
          final l = context.l10n;
          if (!snapshot.hasData) {
            return AppPage(
              header: AppPageHeader(title: l.historyDetails),
              child: const AppLoadingState(),
            );
          }
          final result = snapshot.data;
          if (result is! Success<AttendanceDayDetails?> ||
              result.value == null) {
            return AppPage(
              header: AppPageHeader(title: l.historyDetails),
              child: AppEmptyState(
                title: l.historyNotFound,
                message: l.historyNotFoundNote,
              ),
            );
          }
          final details = result.value!, day = details.day;
          final calculated = const AttendanceSummaryCalculator().calculate(
            details.events,
            details.asOf,
          );
          final summary = calculated is Success<AttendanceSummary>
              ? calculated.value
              : null;
          final time = AppTimeFormatter(Localizations.localeOf(context));
          final date = AppDateFormatter(Localizations.localeOf(context));
          return AppPage(
            header: AppPageHeader(title: l.historyDetails),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppDetailsSection(
                  title: date.fullDate(day.attendanceDate),
                  details: {
                    l.workforceShift: day.snapshot.shift.name,
                    l.attendancePunchInTime: summary?.punchInTime == null
                        ? '—'
                        : time.time(summary!.punchInTime!),
                    l.attendancePunchOutTime: summary?.punchOutTime == null
                        ? '—'
                        : time.time(summary!.punchOutTime!),
                    l.attendanceWorkedTime: summary == null
                        ? '—'
                        : time.duration(summary.workDuration, l),
                    l.attendanceBreakTime: summary == null
                        ? '—'
                        : time.duration(summary.breakDuration, l),
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppFormSection(
                  title: l.historyTimeline,
                  child: AttendanceTimeline(
                    day: day,
                    events: details.events,
                    breaks: summary?.breaks ?? <BreakSession>[],
                    includeDates: true,
                  ),
                ),
                if (details.corrections.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppDetailsSection(
                    title: l.correctionApproved,
                    details: {
                      for (var i = 0; i < details.corrections.length; i++)
                        '${i + 1}. ${details.corrections[i].requestType.name}':
                            details.corrections[i].reason,
                    },
                  ),
                ],
              ],
            ),
          );
        },
      );
}
