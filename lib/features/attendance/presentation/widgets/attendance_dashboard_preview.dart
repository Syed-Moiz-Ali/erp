import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../attendance_presentation.dart';
import '../bloc/attendance_bloc.dart';

class AttendanceDashboardPreview extends StatelessWidget {
  const AttendanceDashboardPreview({super.key});
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AttendanceBloc?>();
    if (bloc == null) {
      return Text(
        context.l10n.attendanceUnavailableTitle,
        style: AppTypography.of(context).bodySmall,
      );
    }
    return BlocBuilder<AttendanceBloc, AttendanceBlocState>(
      builder: (c, s) {
        final l = c.l10n;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (s.summary != null) ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AppStatusBadge(
                  label: AttendancePresentation.state(
                    c,
                    s.summary!.currentState,
                  ),
                  status: AttendancePresentation.status(
                    s.summary!.currentState,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (s.summary!.punchInTime != null)
                AppDetailField(
                  label: l.attendancePunchInTime,
                  value: AttendancePresentation.time(
                    c,
                    s.context!,
                    s.summary!.punchInTime,
                  ),
                ),
              if (s.context != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  s.context!.snapshot.shift.name,
                  style: AppTypography.of(c).bodySmall,
                ),
              ],
            ] else if (s.failure != null)
              Text(
                AttendancePresentation.failure(c, s.failure!),
                style: AppTypography.of(c).bodySmall,
              )
            else
              const AppSkeleton(height: 40),
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppSecondaryButton(
                label: l.attendanceOpenAttendance,
                icon: Icons.schedule_outlined,
                onPressed: () => c.go(AppRoutes.attendance),
              ),
            ),
          ],
        );
      },
    );
  }
}
