import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/attendance_models.dart';
import '../attendance_ticker_cubit.dart';
import '../attendance_presentation.dart';

class AttendanceDurationSummary extends StatelessWidget {
  const AttendanceDurationSummary({super.key, required this.summary});
  final AttendanceSummary summary;
  @override
  Widget build(BuildContext context) => AppCard(
    child: BlocBuilder<AttendanceTickerCubit, AttendanceSummary?>(
      builder: (c, t) {
        final s = t ?? summary, l = c.l10n;
        return AppResponsiveGrid(
          maxColumns: 3,
          minItemWidth: 110,
          children: [
            for (final metric in [
              (l.attendanceWorkedTime, s.workDuration),
              (l.attendanceTotalBreak, s.breakDuration),
              (l.attendanceElapsedTime, s.elapsedDuration),
            ])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(metric.$1, style: AppTypography.of(c).caption),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AttendancePresentation.duration(c, metric.$2),
                    style: AppTypography.of(c).cardTitle,
                  ),
                ],
              ),
          ],
        );
      },
    ),
  );
}
