import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/attendance_ticker_cubit.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/attendance_presentation.dart';

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
