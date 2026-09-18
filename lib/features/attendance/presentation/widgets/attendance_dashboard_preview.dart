import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/attendance_engine.dart';
import '../../domain/attendance_models.dart';
import '../attendance_presentation.dart';
import '../bloc/attendance_bloc.dart';

/// Compact "Today" workday summary for the employee dashboard.
///
/// Three levels only: status + action, one context line, and 2-4 compact
/// metrics. Detailed attendance belongs in the Attendance module.
class AttendanceDashboardPreview extends StatelessWidget {
  const AttendanceDashboardPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AttendanceBloc?>();
    if (bloc == null) return const _Unavailable();
    return BlocBuilder<AttendanceBloc, AttendanceBlocState>(
      builder: (context, s) => _TodayCard(state: s),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.attendanceUnavailableTitle,
        style: AppTypography.of(
          context,
        ).bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      const SizedBox(height: AppSpacing.md),
      _action(context, completed: false),
    ],
  );
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.state});
  final AttendanceBlocState state;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = AppTypography.of(context);
    final attendance = state.context;
    if (attendance == null) {
      if (state.contextStatus == AttendanceContextStatus.loading) {
        return const AppSkeleton(height: 44);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.dashboardNoShiftTitle,
            style: theme.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l.dashboardNoShiftMessage,
            style: theme.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          _action(context, completed: false),
        ],
      );
    }
    final snapshot = attendance.snapshot;
    final summary = state.summary;
    final workState = summary?.currentState;
    final schedule =
        '${AttendancePresentation.time(context, attendance, snapshot.scheduledStart)}–${AttendancePresentation.time(context, attendance, snapshot.scheduledEnd)}';
    final location = snapshot.workLocation?.name ?? l.attendanceNoLocation;
    final contextLine = '${snapshot.shift.name} · $schedule · $location';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: workState == null
                  ? Text(
                      contextLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  : Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AppStatusBadge(
                        label: AttendancePresentation.state(context, workState),
                        status: AttendancePresentation.status(workState),
                        icon: workState == AttendanceWorkdayState.completed
                            ? Icons.check_rounded
                            : null,
                        showDot: workState != AttendanceWorkdayState.completed,
                      ),
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            _action(
              context,
              completed: workState == AttendanceWorkdayState.completed,
            ),
          ],
        ),
        if (summary != null && workState != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            contextLine,
            style: theme.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          _TodayMetrics(attendance: attendance, summary: summary),
        ],
      ],
    );
  }
}

class _TodayMetrics extends StatelessWidget {
  const _TodayMetrics({required this.attendance, required this.summary});
  final AttendanceContext attendance;
  final AttendanceSummary summary;

  String _time(BuildContext context, DateTime? instant) =>
      AttendancePresentation.time(context, attendance, instant);
  String _duration(BuildContext context, Duration d) =>
      AttendancePresentation.duration(context, d);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final rows = switch (summary.currentState) {
      AttendanceWorkdayState.notStarted => [
        AppMetricTile(
          label: l.attendanceStartsAt,
          value: _time(context, attendance.snapshot.scheduledStart),
        ),
      ],
      AttendanceWorkdayState.working => [
        AppMetricTile(
          label: l.attendancePunchIn,
          value: _time(context, summary.punchInTime),
        ),
        AppMetricTile(
          label: l.attendanceWorked,
          value: _duration(context, summary.workDuration),
        ),
        AppMetricTile(
          label: l.attendanceBreak,
          value: _duration(context, summary.breakDuration),
        ),
      ],
      AttendanceWorkdayState.onBreak => [
        AppMetricTile(
          label: l.attendanceWorked,
          value: _duration(context, summary.workDuration),
        ),
        AppMetricTile(
          label: l.attendanceCurrentBreak,
          value: _duration(context, summary.openBreakDuration),
        ),
        AppMetricTile(
          label: l.attendanceBreak,
          value: _duration(context, summary.breakDuration),
        ),
      ],
      AttendanceWorkdayState.completed => [
        AppMetricTile(
          label: l.attendancePunchIn,
          value: _time(context, summary.punchInTime),
        ),
        AppMetricTile(
          label: l.attendancePunchOut,
          value: _time(context, summary.punchOutTime),
        ),
        AppMetricTile(
          label: l.attendanceWorked,
          value: _duration(context, summary.workDuration),
        ),
        AppMetricTile(
          label: l.attendanceBreak,
          value: _duration(context, summary.breakDuration),
        ),
      ],
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0)
            Container(
              width: 1,
              height: 34,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              color: AppColors.borderSubtle,
            ),
          Expanded(child: rows[i]),
        ],
      ],
    );
  }
}

Widget _action(BuildContext context, {required bool completed}) {
  final l = context.l10n;
  return AppSecondaryButton(
    key: const ValueKey('dashboard-action-attendance'),
    label: completed ? l.attendanceViewAttendance : l.attendanceOpenAttendance,
    icon: Icons.schedule_outlined,
    size: AppButtonSize.small,
    onPressed: () => context.go(AppRoutes.attendance),
  );
}
