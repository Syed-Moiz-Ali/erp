import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/attendance_presentation.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_bloc.dart';

/// Contextual attendance actions for the dashboard header: take/resume break
/// (secondary) and punch out (primary). Decisions come from the session
/// [AttendanceBloc]; no attendance logic is duplicated here.
class AttendanceHeaderActions extends StatelessWidget {
  const AttendanceHeaderActions({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AttendanceBloc?>();
    if (bloc == null) return const SizedBox.shrink();
    return BlocBuilder<AttendanceBloc, AttendanceBlocState>(
      builder: (context, s) {
        final actions = s.actions;
        if (actions == null || s.summary == null) {
          return const SizedBox.shrink();
        }
        final onBreak =
            s.summary!.currentState == AttendanceWorkdayState.onBreak;
        final breakType = onBreak
            ? AttendanceEventType.breakEnd
            : AttendanceEventType.breakStart;
        final showBreak = actions.decisions[breakType]?.allowed ?? false;
        final showOut =
            actions.decisions[AttendanceEventType.punchOut]?.allowed ?? false;
        if (!showBreak && !showOut) return const SizedBox.shrink();
        void request(AttendanceEventType type) => bloc.add(switch (type) {
          AttendanceEventType.punchIn => const PunchInRequested(),
          AttendanceEventType.breakStart => const BreakStartRequested(),
          AttendanceEventType.breakEnd => const BreakEndRequested(),
          AttendanceEventType.punchOut => const PunchOutRequested(),
        });
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showBreak)
              AppSecondaryButton(
                key: ValueKey('attendance-action-${breakType.name}'),
                label: AttendancePresentation.action(context, breakType),
                icon: onBreak
                    ? Icons.play_arrow_outlined
                    : Icons.coffee_outlined,
                loading: s.busy && s.operation == breakType,
                onPressed: s.busy ? null : () => request(breakType),
              ),
            if (showBreak && showOut) const SizedBox(width: AppSpacing.sm),
            if (showOut)
              AppPrimaryButton(
                key: const ValueKey('attendance-action-punchOut'),
                label: context.l10n.attendancePunchOut,
                icon: Icons.logout,
                loading: s.busy && s.operation == AttendanceEventType.punchOut,
                onPressed: s.busy
                    ? null
                    : () => request(AttendanceEventType.punchOut),
              ),
          ],
        );
      },
    );
  }
}
