import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../attendance_presentation.dart';
import '../bloc/attendance_bloc.dart';
import 'attendance_location_status.dart';

class AttendanceContextPanel extends StatelessWidget {
  const AttendanceContextPanel({super.key, required this.state});
  final AttendanceBlocState state;
  @override
  Widget build(BuildContext context) {
    final a = state.context!,
        s = a.snapshot,
        l = context.l10n,
        location = s.workLocation;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.attendanceTodayShift,
            style: AppTypography.of(context).caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(s.shift.name, style: AppTypography.of(context).cardTitle),
          Text(
            '${AttendancePresentation.time(context, a, s.scheduledStart)} – ${AttendancePresentation.time(context, a, s.scheduledEnd)}',
            style: AppTypography.of(context).body,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.xxl,
            runSpacing: AppSpacing.md,
            children: [
              AppDetailField(
                label: l.attendanceExpectedHours,
                value: AttendancePresentation.duration(
                  context,
                  Duration(minutes: s.shift.expectedWorkMinutes),
                ),
              ),
              AppDetailField(
                label: l.attendanceGrace,
                value: AttendancePresentation.duration(
                  context,
                  Duration(minutes: s.shift.gracePeriodMinutes),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Divider(),
          ),
          Text(
            l.attendanceWorkLocation,
            style: AppTypography.of(context).caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            location?.name ?? l.attendanceNoLocation,
            style: AppTypography.of(context).cardTitle,
          ),
          if (location != null)
            Text(
              '${l.attendanceRadius}: ${AttendancePresentation.meters(context, location.allowedRadiusMeters)}',
              style: AppTypography.of(context).caption,
            ),
          const SizedBox(height: AppSpacing.lg),
          AttendanceLocationStatus(state: state),
        ],
      ),
    );
  }
}
