import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/attendance_models.dart';
import '../../domain/attendance_summary_calculator.dart';
import '../attendance_presentation.dart';
import '../attendance_history_presentation.dart';

class AttendanceTimeline extends StatelessWidget {
  const AttendanceTimeline({
    super.key,
    required this.day,
    required this.events,
    required this.breaks,
    this.includeDates = false,
  });
  final AttendanceDay day;
  final List<AttendanceEvent> events;
  final List<BreakSession> breaks;
  final bool includeDates;
  @override
  Widget build(BuildContext context) => AppTimeline(
    items: [
      for (final e in const AttendanceSummaryCalculator().ordered(events))
        AppTimelineItem(
          id: e.id,
          title: AttendancePresentation.event(context, e.eventType),
          time: AttendanceHistoryPresentation.time(
            context,
            day,
            e.effectiveTimestamp,
            includeDate: includeDates,
          ),
          icon: switch (e.eventType) {
            AttendanceEventType.punchIn => Icons.login,
            AttendanceEventType.breakStart => Icons.coffee_outlined,
            AttendanceEventType.breakEnd => Icons.play_arrow_outlined,
            AttendanceEventType.punchOut => Icons.check_circle_outline,
          },
          detail: [
            if (e.workLocationId != null)
              day.snapshot.workLocation?.name ??
                  context.l10n.attendanceWorkLocation,
            for (final b in breaks.where(
              (b) => !b.isOpen && b.endEventId == e.id,
            ))
              '${context.l10n.attendanceTotalBreak}: ${AttendancePresentation.duration(context, b.duration)}',
          ].join(' · '),
          status: e.eventType == AttendanceEventType.breakStart
              ? AppStatus.warning
              : AppStatus.neutral,
          trailing: e.syncStatus == AttendanceSyncStatus.synced
              ? null
              : AppStatusBadge(
                  label: AttendancePresentation.sync(context, e.syncStatus),
                  status: e.syncStatus == AttendanceSyncStatus.pending
                      ? AppStatus.info
                      : AppStatus.danger,
                ),
        ),
    ],
  );
}
