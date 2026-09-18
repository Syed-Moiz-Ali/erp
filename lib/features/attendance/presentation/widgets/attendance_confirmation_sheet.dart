import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../application/execute_attendance_action.dart';
import '../../domain/attendance_models.dart';
import '../../domain/attendance_summary_calculator.dart';
import '../../../../core/errors/result.dart';
import '../attendance_localization.dart';
import '../attendance_presentation.dart';

class AttendanceConfirmationSheet extends StatelessWidget {
  const AttendanceConfirmationSheet({super.key, required this.prepared});
  final PreparedAttendanceAction prepared;
  static Future<bool?> show(BuildContext c, PreparedAttendanceAction p) =>
      AppBottomSheet.show<bool>(
        c,
        builder: (_) => AttendanceConfirmationSheet(prepared: p),
      );
  @override
  Widget build(BuildContext context) {
    final l = context.l10n,
        a = prepared.context,
        out = prepared.type == AttendanceEventType.punchOut;
    final result = const AttendanceSummaryCalculator().calculate(
      a.events,
      a.currentTime,
    );
    final summary = result is Success<AttendanceSummary> ? result.value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(
          title: out ? l.attendanceEndWorkday : l.attendanceConfirmAction,
          subtitle: l.attendanceWarningNote,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (out && summary != null)
          AppDetailsGrid(
            fields: [
              AppDetailField(
                label: l.attendancePunchInTime,
                value: AttendancePresentation.time(
                  context,
                  a,
                  summary.punchInTime,
                ),
              ),
              AppDetailField(
                label: l.attendanceCurrentTime,
                value: AttendancePresentation.time(context, a, a.currentTime),
              ),
              AppDetailField(
                label: l.attendanceWorkedTime,
                value: AttendancePresentation.duration(
                  context,
                  summary.workDuration,
                ),
              ),
              AppDetailField(
                label: l.attendanceTotalBreak,
                value: AttendancePresentation.duration(
                  context,
                  summary.breakDuration,
                ),
              ),
              AppDetailField(
                label: l.attendanceWorkLocation,
                value: a.snapshot.workLocation?.name ?? l.attendanceNoLocation,
              ),
            ],
          ),
        if (out && summary?.currentState == AttendanceWorkdayState.onBreak) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            l.attendanceCloseBreakNote,
            style: AppTypography.of(context).body,
          ),
        ],
        for (final w in prepared.decision.warnings) ...[
          const SizedBox(height: AppSpacing.md),
          AppNotice(
            title: attendanceWarningLabel(l, w),
            status: AppStatus.warning,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            AppSecondaryButton(
              label: l.cancel,
              onPressed: () => Navigator.pop(context, false),
            ),
            AppPrimaryButton(
              key: const ValueKey('attendance-confirm'),
              label: out ? l.attendancePunchOut : l.attendanceContinue,
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ],
    );
  }
}
