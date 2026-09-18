import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../attendance_presentation.dart';
import '../bloc/attendance_bloc.dart';

/// "Today" content for the employee dashboard. Presentation only: it reads
/// the session [AttendanceBloc] and never duplicates attendance logic.
class AttendanceDashboardPreview extends StatelessWidget {
  const AttendanceDashboardPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AttendanceBloc?>();
    final theme = AppTypography.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (bloc == null)
          Text(
            context.l10n.attendanceUnavailableTitle,
            style: theme.bodySmall.copyWith(color: AppColors.textSecondary),
          )
        else
          BlocBuilder<AttendanceBloc, AttendanceBlocState>(
            builder: (c, s) => _TodayContent(state: s),
          ),
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppSecondaryButton(
            key: const ValueKey('dashboard-action-attendance'),
            label: context.l10n.attendanceOpenAttendance,
            icon: Icons.schedule_outlined,
            onPressed: () => context.go(AppRoutes.attendance),
          ),
        ),
      ],
    );
  }
}

class _TodayContent extends StatelessWidget {
  const _TodayContent({required this.state});
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
        ],
      );
    }
    final snapshot = attendance.snapshot;
    final summary = state.summary;
    final workLocation = snapshot.workLocation;
    final schedule =
        '${AttendancePresentation.time(context, attendance, snapshot.scheduledStart)} – ${AttendancePresentation.time(context, attendance, snapshot.scheduledEnd)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary != null) ...[
          AppStatusBadge(
            label: AttendancePresentation.state(context, summary.currentState),
            status: AttendancePresentation.status(summary.currentState),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        AppDetailField(
          label: l.attendanceTodayShift,
          value: snapshot.shift.name,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(schedule, style: theme.caption),
        const SizedBox(height: AppSpacing.md),
        AppDetailField(
          label: l.attendanceWorkLocation,
          value: workLocation?.name ?? l.attendanceNoLocation,
        ),
        if (summary != null) ...[
          if (summary.punchInTime != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppDetailField(
              label: l.attendancePunchInTime,
              value: AttendancePresentation.time(
                context,
                attendance,
                summary.punchInTime,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xxl,
            runSpacing: AppSpacing.sm,
            children: [
              AppDetailField(
                label: l.attendanceWorkedTime,
                value: AttendancePresentation.duration(
                  context,
                  summary.workDuration,
                ),
              ),
              if (summary.breakDuration > Duration.zero ||
                  summary.openBreakDuration > Duration.zero)
                AppDetailField(
                  label: l.attendanceBreakTime,
                  value: AttendancePresentation.duration(
                    context,
                    summary.breakDuration + summary.openBreakDuration,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
