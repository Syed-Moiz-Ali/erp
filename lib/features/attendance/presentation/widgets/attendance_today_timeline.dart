import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/attendance_models.dart';
import '../../domain/attendance_summary_calculator.dart';
import '../attendance_presentation.dart';
import '../bloc/attendance_bloc.dart';

class AttendanceTodayTimeline extends StatelessWidget {
  const AttendanceTodayTimeline({super.key, required this.state});
  final AttendanceBlocState state;
  @override
  Widget build(BuildContext context) {
    final a = state.context!, l = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(title: l.attendanceTodayActivity),
          const SizedBox(height: AppSpacing.xl),
          if (a.events.isEmpty)
            AppEmptyState(
              title: l.attendanceNoActivity,
              message: l.attendanceActivityNote,
              icon: Icons.event_note_outlined,
            )
          else
            AppTimeline(
              items: [
                for (final e in const AttendanceSummaryCalculator().ordered(
                  a.events,
                ))
                  AppTimelineItem(
                    id: e.id,
                    title: AttendancePresentation.event(context, e.eventType),
                    time: AttendancePresentation.time(
                      context,
                      a,
                      e.effectiveTimestamp,
                    ),
                    icon: switch (e.eventType) {
                      AttendanceEventType.punchIn => Icons.login,
                      AttendanceEventType.breakStart => Icons.coffee_outlined,
                      AttendanceEventType.breakEnd => Icons.play_arrow_outlined,
                      AttendanceEventType.punchOut =>
                        Icons.check_circle_outline,
                    },
                    detail: [
                      if (e.workLocationId != null)
                        a.snapshot.workLocation?.name ??
                            l.attendanceWorkLocation,
                      for (final b in state.summary!.breaks.where(
                        (b) => !b.isOpen && b.endEventId == e.id,
                      ))
                        '${l.attendanceTotalBreak}: ${AttendancePresentation.duration(context, b.duration)}',
                    ].join(' · '),
                    status: e.eventType == AttendanceEventType.breakStart
                        ? AppStatus.warning
                        : AppStatus.neutral,
                    trailing: e.syncStatus == AttendanceSyncStatus.synced
                        ? null
                        : AppStatusBadge(
                            label: AttendancePresentation.sync(
                              context,
                              e.syncStatus,
                            ),
                            status: e.syncStatus == AttendanceSyncStatus.pending
                                ? AppStatus.info
                                : AppStatus.danger,
                          ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
