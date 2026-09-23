import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/attendance_ticker_cubit.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/attendance_presentation.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_bloc.dart';
import 'attendance_action_section.dart';

/// Hero workday card: live logged work timer with status badges and the
/// contextual attendance actions. The timer ticks via [AttendanceTickerCubit]
/// and only this value rebuilds each second.
class AttendanceStateCard extends StatelessWidget {
  const AttendanceStateCard({super.key, required this.state});
  final AttendanceBlocState state;

  @override
  Widget build(BuildContext context) {
    final s = state.summary!, a = state.context!, l = context.l10n;
    final notStarted = s.currentState == AttendanceWorkdayState.notStarted;
    final validation = state.lastLocationValidation;
    final locationName = a.snapshot.workLocation?.name;
    final hero = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppStatusBadge(
              label: AttendancePresentation.state(context, s.currentState),
              status: AttendancePresentation.status(s.currentState),
            ),
            if (state.currentDay?.status == AttendanceDayStatus.late)
              AppStatusBadge(
                label: l.attendanceLate,
                status: AppStatus.warning,
              ),
            if (validation?.distanceMeters != null && locationName != null)
              AppStatusBadge(
                label: l.attendanceInsideGeofence(
                  locationName,
                  AttendancePresentation.meters(
                    context,
                    validation!.distanceMeters!,
                  ),
                ),
                status: AppStatus.success,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        BlocBuilder<AttendanceTickerCubit, AttendanceSummary?>(
          builder: (c, t) {
            final live = t ?? s,
                onBreak = live.currentState == AttendanceWorkdayState.onBreak;
            final label = onBreak
                ? l.attendanceCurrentBreak
                : l.attendanceCurrentLoggedWorkTime;
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
                    Text(
                      label,
                      style: AppTypography.of(
                        c,
                      ).bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
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
        if (notStarted) ...[
          const SizedBox(height: AppSpacing.md),
          Text(l.attendanceStartNote, style: AppTypography.of(context).body),
        ] else ...[
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
      ],
    );
    final actions = AttendanceActionSection(state: state);
    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 620;
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: hero),
                const SizedBox(width: AppSpacing.xxl),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: actions,
                ),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              hero,
              const SizedBox(height: AppSpacing.xl),
              actions,
            ],
          );
        },
      ),
    );
  }
}
