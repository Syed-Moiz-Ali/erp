import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/attendance_presentation.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_bloc.dart';

class AttendanceSyncBanner extends StatelessWidget {
  const AttendanceSyncBanner({super.key, required this.state});
  final AttendanceBlocState state;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n, day = state.currentDay;
    if (day == null || day.syncStatus == AttendanceSyncStatus.synced) {
      return const SizedBox.shrink();
    }
    final rejected = day.syncStatus == AttendanceSyncStatus.rejected,
        failed = day.syncStatus == AttendanceSyncStatus.failed;
    return AppNotice(
      title: rejected
          ? l.attendanceRejectedTitle
          : failed
          ? l.attendanceFailedTitle
          : l.attendancePendingTitle,
      message: rejected
          ? l.attendanceRejectedNote
          : failed
          ? l.attendanceFailedNote
          : l.attendancePendingNote,
      status: rejected
          ? AppStatus.danger
          : failed
          ? AppStatus.warning
          : AppStatus.info,
      icon: rejected || failed
          ? Icons.cloud_off_outlined
          : Icons.cloud_upload_outlined,
      action: failed
          ? Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final e in state.context!.events.where(
                  (e) => e.syncStatus == AttendanceSyncStatus.failed,
                ))
                  Builder(
                    builder: (context) {
                      final retryLabel =
                          '${l.attendanceRetrySync} · ${AttendancePresentation.event(context, e.eventType)} · ${AttendancePresentation.time(context, state.context!, e.effectiveTimestamp)}';
                      return AppTextButton(
                        key: ValueKey('attendance-retry-${e.requestId}'),
                        label: retryLabel,
                        onPressed: state.busy
                            ? null
                            : () => context.read<AttendanceBloc>().add(
                                PendingOperationRetryRequested(e.requestId),
                              ),
                      );
                    },
                  ),
              ],
            )
          : null,
    );
  }
}
