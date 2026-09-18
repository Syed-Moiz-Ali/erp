import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../../../core/errors/result.dart';
import '../../domain/attendance_models.dart';
import '../attendance_presentation.dart';
import '../bloc/attendance_bloc.dart';

class AttendanceActionSection extends StatelessWidget {
  const AttendanceActionSection({super.key, required this.state});
  final AttendanceBlocState state;
  @override
  Widget build(BuildContext context) {
    final actions = state.actions;
    if (actions == null) return const SizedBox.shrink();
    final allowed = AttendanceEventType.values
        .where((t) => actions.decisions[t]!.allowed)
        .toList();
    final primary = allowed
        .where(
          (t) =>
              t == AttendanceEventType.punchIn ||
              t == AttendanceEventType.breakEnd,
        )
        .firstOrNull;
    String loading(AttendanceEventType t) =>
        state.actionStatus == AttendanceActionStatus.checkingLocation
        ? context.l10n.attendanceLocationChecking
        : switch (t) {
            AttendanceEventType.punchIn => context.l10n.attendancePunchingIn,
            AttendanceEventType.breakStart =>
              context.l10n.attendanceStartingBreak,
            AttendanceEventType.breakEnd => context.l10n.attendanceResumingWork,
            AttendanceEventType.punchOut => context.l10n.attendancePunchingOut,
          };
    void request(AttendanceEventType type) =>
        context.read<AttendanceBloc>().add(switch (type) {
          AttendanceEventType.punchIn => const PunchInRequested(),
          AttendanceEventType.breakStart => const BreakStartRequested(),
          AttendanceEventType.breakEnd => const BreakEndRequested(),
          AttendanceEventType.punchOut => const PunchOutRequested(),
        });
    final buttons = [
      for (final t in allowed)
        Semantics(
          button: true,
          label: AttendancePresentation.action(context, t),
          child: t == primary || state.busy && state.operation == t
              ? AppPrimaryButton(
                  key: ValueKey('attendance-action-${t.name}'),
                  label: state.busy && state.operation == t
                      ? loading(t)
                      : AttendancePresentation.action(context, t),
                  icon: t == AttendanceEventType.punchIn
                      ? Icons.login
                      : t == AttendanceEventType.breakEnd
                      ? Icons.play_arrow_outlined
                      : Icons.coffee_outlined,
                  loading: state.busy && state.operation == t,
                  onPressed: state.busy ? null : () => request(t),
                )
              : AppSecondaryButton(
                  key: ValueKey('attendance-action-${t.name}'),
                  label: AttendancePresentation.action(context, t),
                  icon: t == AttendanceEventType.punchOut
                      ? Icons.logout
                      : Icons.coffee_outlined,
                  onPressed: state.busy ? null : () => request(t),
                ),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: buttons,
        ),
        for (final code in {
          for (final type in switch (state.summary?.currentState) {
            AttendanceWorkdayState.notStarted => [AttendanceEventType.punchIn],
            AttendanceWorkdayState.working => [
              AttendanceEventType.breakStart,
              AttendanceEventType.punchOut,
            ],
            AttendanceWorkdayState.onBreak => [
              AttendanceEventType.breakEnd,
              AttendanceEventType.punchOut,
            ],
            _ => <AttendanceEventType>[],
          })
            if (actions.decisions[type]?.failure != null &&
                (allowed.isEmpty ||
                    actions.decisions[type]!.failure !=
                        AttendanceFailureCode.permissionDenied) &&
                actions.decisions[type]!.failure!.name != state.failure?.code)
              actions.decisions[type]!.failure!,
        }) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            AttendancePresentation.failure(context, Failure(code: code.name)),
            style: AppTypography.of(context).caption,
          ),
        ],
      ],
    );
  }
}
