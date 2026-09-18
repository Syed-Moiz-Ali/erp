import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_formatters.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/attendance_models.dart';
import '../attendance_ticker_cubit.dart';
import '../attendance_presentation.dart';
import '../bloc/attendance_bloc.dart';
import 'attendance_action_section.dart';

class AttendanceStateCard extends StatelessWidget {
  const AttendanceStateCard({super.key, required this.state});
  final AttendanceBlocState state;
  @override
  Widget build(BuildContext context) {
    final s = state.summary!, a = state.context!, l = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l.attendanceWorkday,
                style: AppTypography.of(context).caption,
              ),
              AppStatusBadge(
                label: AttendancePresentation.state(context, s.currentState),
                status: AttendancePresentation.status(s.currentState),
              ),
              if (state.currentDay?.status == AttendanceDayStatus.late)
                AppStatusBadge(
                  label: l.attendanceLate,
                  status: AppStatus.warning,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(switch (s.currentState) {
            AttendanceWorkdayState.notStarted => l.attendanceStartNote,
            AttendanceWorkdayState.working => l.attendanceWorkingNote,
            AttendanceWorkdayState.onBreak => l.attendanceBreakNote,
            AttendanceWorkdayState.completed => l.attendanceCompleteNote,
          }, style: AppTypography.of(context).body),
          if (s.currentState != AttendanceWorkdayState.notStarted) ...[
            const SizedBox(height: AppSpacing.xl),
            BlocBuilder<AttendanceTickerCubit, AttendanceSummary?>(
              builder: (c, t) {
                final live = t ?? s,
                    onBreak =
                        live.currentState == AttendanceWorkdayState.onBreak;
                final label = onBreak
                    ? l.attendanceCurrentBreak
                    : l.attendanceWorkTime;
                final duration = onBreak
                    ? live.openBreakDuration
                    : live.workDuration;
                final liveLabel =
                    '$label, ${AttendancePresentation.duration(c, duration)}';
                return Semantics(
                  label: liveLabel,
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: AppTypography.of(c).label),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          AppTimeFormatter(
                            Localizations.localeOf(c),
                          ).digitalDuration(duration),
                          key: const ValueKey('attendance-live-timer'),
                          textDirection: TextDirection.ltr,
                          style: AppTypography.of(c).timer,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.xxl,
              runSpacing: AppSpacing.md,
              children: [
                AppDetailField(
                  label: l.attendancePunchInTime,
                  value: AttendancePresentation.time(context, a, s.punchInTime),
                ),
                if (s.punchOutTime != null)
                  AppDetailField(
                    label: l.attendancePunchOutTime,
                    value: AttendancePresentation.time(
                      context,
                      a,
                      s.punchOutTime,
                    ),
                  ),
                if (s.currentState == AttendanceWorkdayState.onBreak)
                  AppDetailField(
                    label: l.attendanceBreakStartedLabel,
                    value: AttendancePresentation.time(
                      context,
                      a,
                      s.breaks.last.startedAt,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AttendanceActionSection(state: state),
        ],
      ),
    );
  }
}
