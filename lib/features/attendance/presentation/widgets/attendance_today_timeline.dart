import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import 'attendance_timeline.dart';
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
            AttendanceTimeline(
              day: a.day!,
              events: a.events,
              breaks: state.summary!.breaks,
            ),
        ],
      ),
    );
  }
}
