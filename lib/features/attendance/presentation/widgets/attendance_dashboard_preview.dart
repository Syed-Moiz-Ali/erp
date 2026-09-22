import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/localization/app_formatters.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/attendance_engine.dart';
import '../../domain/attendance_models.dart';
import '../attendance_presentation.dart';
import '../bloc/attendance_bloc.dart';

/// Hero "Today" workday card for the employee dashboard.
///
/// Structure mirrors the approved reference: status + context + action row,
/// a divider, then four compact metrics (label / value / supporting).
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
        return const AppSkeleton(height: 64);
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 340;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isCompact) ...[
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (workState != null)
                    AppStatusBadge(
                      label: AttendancePresentation.state(context, workState),
                      status: AttendancePresentation.status(workState),
                      icon: workState == AttendanceWorkdayState.completed
                          ? Icons.check_rounded
                          : null,
                      showDot: workState != AttendanceWorkdayState.completed,
                    ),
                  _action(
                    context,
                    completed: workState == AttendanceWorkdayState.completed,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                contextLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (workState != null) ...[
                    AppStatusBadge(
                      label: AttendancePresentation.state(context, workState),
                      status: AttendancePresentation.status(workState),
                      icon: workState == AttendanceWorkdayState.completed
                          ? Icons.check_rounded
                          : null,
                      showDot: workState != AttendanceWorkdayState.completed,
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: Text(
                      contextLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodySmall.copyWith(
                        color: AppColors.textSecondary,
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
            ],
            if (summary != null && workState != null) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Divider(height: 1),
              ),
              _TodayMetrics(attendance: attendance, summary: summary),
            ],
          ],
        );
      },
    );
  }
}

class _TodayMetrics extends StatelessWidget {
  const _TodayMetrics({required this.attendance, required this.summary});
  final AttendanceContext attendance;
  final AttendanceSummary summary;

  String _time(BuildContext context, DateTime? instant) =>
      AttendancePresentation.time(context, attendance, instant);
  String _duration(BuildContext context, Duration d) => AppTimeFormatter(
    Localizations.localeOf(context),
  ).duration(d, context.l10n);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final snapshot = attendance.snapshot;
    final grace = snapshot.shift.gracePeriodMinutes;
    final target = snapshot.shift.expectedWorkMinutes;
    final punchIn = summary.punchInTime;
    final late =
        punchIn != null &&
        punchIn.isAfter(snapshot.scheduledStart.add(Duration(minutes: grace)));
    final punchSupporting = punchIn == null
        ? null
        : '${late ? l.historyLate : l.attendanceOnTime} · '
              '${l.attendanceGrace} ${_duration(context, Duration(minutes: grace))}';
    final targetSupporting =
        '${l.attendanceTarget}: ${_duration(context, Duration(minutes: target))}';
    final remaining = snapshot.scheduledEnd.difference(attendance.currentTime);
    final remainingSupporting = remaining > Duration.zero
        ? '${l.attendanceShiftRemaining}: ${_duration(context, remaining)}'
        : null;
    final scheduledOut = _time(context, snapshot.scheduledEnd);

    final columns = switch (summary.currentState) {
      AttendanceWorkdayState.working => [
        _Metric(
          label: l.attendancePunchIn,
          value: _time(context, punchIn),
          supporting: punchSupporting,
        ),
        _Metric(
          label: l.attendanceWorked,
          value: _duration(context, summary.workDuration),
          supporting: targetSupporting,
        ),
        _Metric(
          label: l.attendanceBreak,
          value: _duration(context, summary.breakDuration),
        ),
        _Metric(
          label: l.attendancePunchOut,
          value: scheduledOut,
          supporting: remainingSupporting,
        ),
      ],
      AttendanceWorkdayState.onBreak => [
        _Metric(
          label: l.attendancePunchIn,
          value: _time(context, punchIn),
          supporting: punchSupporting,
        ),
        _Metric(
          label: l.attendanceWorked,
          value: _duration(context, summary.workDuration),
          supporting: targetSupporting,
        ),
        _Metric(
          label: l.attendanceCurrentBreak,
          value: _duration(context, summary.openBreakDuration),
        ),
        _Metric(
          label: l.attendancePunchOut,
          value: scheduledOut,
          supporting: remainingSupporting,
        ),
      ],
      AttendanceWorkdayState.completed => [
        _Metric(
          label: l.attendancePunchIn,
          value: _time(context, punchIn),
          supporting: punchSupporting,
        ),
        _Metric(
          label: l.attendanceWorked,
          value: _duration(context, summary.workDuration),
          supporting: targetSupporting,
        ),
        _Metric(
          label: l.attendanceBreak,
          value: _duration(context, summary.breakDuration),
        ),
        _Metric(
          label: l.attendancePunchOut,
          value: _time(context, summary.punchOutTime),
        ),
      ],
      AttendanceWorkdayState.notStarted => [
        _Metric(
          label: l.attendanceStartsAt,
          value: _time(context, snapshot.scheduledStart),
        ),
      ],
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < columns.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.lg),
          Expanded(child: columns[i]),
        ],
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.supporting});
  final String label, value;
  final String? supporting;

  @override
  Widget build(BuildContext context) {
    final theme = AppTypography.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.caption.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.displaySmall.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -0.6,
            color: AppColors.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (supporting != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            supporting!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.caption.copyWith(
              fontSize: 11.5,
              color: AppColors.textMuted,
            ),
          ),
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
