import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/attendance/live/presentation/attendance_cubit.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class LiveAttendancePage extends StatefulWidget {
  const LiveAttendancePage({super.key, required this.cubit});
  final AttendanceCubit cubit;

  @override
  State<LiveAttendancePage> createState() => _LiveAttendancePageState();
}

class _LiveAttendancePageState extends State<LiveAttendancePage> {
  @override
  void initState() {
    super.initState();
    widget.cubit.load();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: widget.cubit,
    child: BlocBuilder<AuthBloc, AuthState>(
      builder: (context, auth) {
        final permissions = auth.context?.user.permissions;
        final canView =
            permissions?.contains(AppPermission.attendanceViewSelf) ?? false;
        final canPunch =
            permissions != null &&
            PermissionChecker(permissions).canAny([
              AppPermission.attendancePunchIn,
              AppPermission.attendancePunchOut,
              AppPermission.attendanceBreak,
            ]);
        if (!canView && !canPunch) {
          return AppPage(
            header: AppPageHeader(title: context.l10n.attendanceTodayTitle),
            child: const AppPermissionDeniedState(),
          );
        }
        return BlocBuilder<AttendanceCubit, AttendanceState>(
          builder: (context, state) {
            final l = context.l10n;
            final day = state.day;
            return AppPage(
              header: AppPageHeader(
                title: l.attendanceTodayTitle,
                actions: [
                  AppSecondaryButton(
                    label: l.refresh,
                    onPressed: state.busy ? null : widget.cubit.load,
                  ),
                ],
              ),
              child: state.loading
                  ? const AppLoadingState()
                  : state.failure != null
                  ? AppErrorState(
                      message: _failureMessage(l, state.failure!),
                      onRetry: widget.cubit.load,
                    )
                  : day == null
                  ? AppEmptyState(
                      title: l.noRecords,
                      message: l.failureRequest,
                      icon: Icons.event_busy_outlined,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                [
                                  _stateLabel(l, day.state),
                                  day.timeZone,
                                ].join(' · '),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                [l.attendanceTodayShift, day.date].join(': '),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                [
                                  l.attendanceWorkedTime,
                                  day.workedMinutes,
                                  l.attendanceBreakTime,
                                  day.breakMinutes,
                                ].join(' · '),
                              ),
                              if (day.currentShiftNo != null ||
                                  day.nextShiftNo != null) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  [
                                    l.attendanceCurrentNextShift,
                                    '${day.currentShiftNo ?? '-'} / '
                                        '${day.nextShiftNo ?? '-'}',
                                  ].join(': '),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.sm),
                              Text(day.serverTime),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (day.shifts.isEmpty)
                          AppEmptyState(
                            title: l.noRecords,
                            message: l.attendanceTodayShift,
                            icon: Icons.event_busy_outlined,
                          )
                        else
                          for (final shift in day.shifts)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: AppCard(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      [
                                        shift.shiftNo,
                                        shift.shiftName,
                                        shift.status,
                                      ].join('. '),
                                    ),
                                    Text(
                                      [
                                        shift.plannedStart,
                                        shift.plannedEnd,
                                      ].join(' - '),
                                    ),
                                    if (shift.punchIn != null)
                                      Text(
                                        [
                                          l.attendancePunchInTime,
                                          shift.punchIn,
                                        ].join(': '),
                                      ),
                                    if (shift.punchOut != null)
                                      Text(
                                        [
                                          l.attendancePunchOutTime,
                                          shift.punchOut,
                                        ].join(': '),
                                      ),
                                    if (shift.timeZone.isNotEmpty)
                                      Text(shift.timeZone),
                                    if (shift.lateMinutes > 0)
                                      Text(
                                        [
                                          l.attendanceLate,
                                          '${shift.lateMinutes}',
                                        ].join(' '),
                                      ),
                                    if (shift.earlyLeaveMinutes > 0)
                                      Text(
                                        [
                                          l.attendanceEarlyLeave,
                                          '${shift.earlyLeaveMinutes}',
                                        ].join(' '),
                                      ),
                                    for (final b in shift.breaks)
                                      Text(
                                        [
                                          b.start,
                                          b.end ?? '-',
                                          '(${b.minutes})',
                                        ].join(' '),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                        if (canPunch && day.allowedActions.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              for (final action in day.allowedActions)
                                if (action == 'punchIn')
                                  AppPrimaryButton(
                                    label: l.attendancePunchIn,
                                    loading: state.busy,
                                    onPressed: () => _punch(action),
                                  )
                                else if (action == 'break')
                                  AppSecondaryButton(
                                    label: l.attendanceBreakStart,
                                    onPressed: state.busy
                                        ? null
                                        : () => _punch(action),
                                  )
                                else if (action == 'resume')
                                  AppSecondaryButton(
                                    label: l.attendanceBreakEnd,
                                    onPressed: state.busy
                                        ? null
                                        : () => _punch(action),
                                  )
                                else if (action == 'punchOut')
                                  AppSecondaryButton(
                                    label: l.attendancePunchOut,
                                    onPressed: state.busy
                                        ? null
                                        : () => _punch(action),
                                  ),
                            ],
                          ),
                        ],
                      ],
                    ),
            );
          },
        );
      },
    ),
  );

  Future<void> _punch(String action) async {
    final failure = await widget.cubit.punch(action);
    if (failure != null && mounted) {
      AppFeedback.showMessage(
        context,
        message: (l) => _failureMessage(l, failure),
      );
    }
  }

  String _stateLabel(AppLocalizations l, String state) => switch (state) {
    'working' => l.attendanceWorking,
    'onBreak' => l.attendanceOnBreak,
    'completed' => l.attendanceCompleted,
    'readyToPunchIn' || 'waitingForShift' => l.attendanceNotStarted,
    'noShift' => l.attendanceShiftNotAssigned,
    _ => state,
  };

  String _failureMessage(AppLocalizations l, Failure failure) {
    final message = failure.serverMessage;
    return switch (failure.code) {
      'DAY_COMPLETE' => l.attendanceAlreadyCompleted,
      'ATTENDANCE_NO_SHIFT' => l.attendanceShiftNotAssigned,
      'ATTENDANCE_EMPLOYEE_INACTIVE' ||
      'ATTENDANCE_NO_EMPLOYEE' => l.attendanceEmployeeInactive,
      'BRANCH_TIMEZONE_MISSING' => l.attendanceUnsupportedTimezone,
      _ => message ?? l.failureRequest,
    };
  }
}
