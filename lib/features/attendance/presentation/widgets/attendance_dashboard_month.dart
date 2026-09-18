import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_history_bloc.dart';
import 'attendance_history_components.dart';

class AttendanceDashboardMonth extends StatelessWidget {
  const AttendanceDashboardMonth({super.key});
  @override
  Widget build(BuildContext context) {
    final attendance = context.read<AttendanceBloc?>();
    if (attendance == null) return const SizedBox.shrink();
    return BlocProvider(
      create: (_) =>
          AttendanceHistoryBloc(attendance.repository)
            ..add(const AttendanceHistoryStarted()),
      child: BlocBuilder<AttendanceHistoryBloc, AttendanceHistoryState>(
        builder: (context, s) {
          if (s.data == null || s.data!.summary.records == 0) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSectionHeader(title: context.l10n.historyMonthlySummary),
              const SizedBox(height: AppSpacing.lg),
              AttendanceMonthlySummary(summary: s.data!.summary),
            ],
          );
        },
      ),
    );
  }
}
