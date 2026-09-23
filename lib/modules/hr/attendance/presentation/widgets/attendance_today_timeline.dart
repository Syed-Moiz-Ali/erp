import 'package:flutter/material.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'attendance_timeline.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_bloc.dart';

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
          const SizedBox(height: AppSpacing.md),
          if (a.events.isEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.event_note_outlined,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.attendanceNoActivity,
                        style: AppTypography.of(context).bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        l.attendanceActivityNote,
                        style: AppTypography.of(context).caption,
                      ),
                    ],
                  ),
                ),
              ],
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
