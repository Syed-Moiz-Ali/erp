import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/result.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/domain/entities/auth_context.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/leave_models.dart';
import '../../domain/leave_repository.dart';

/// Read-only Leave/Holiday overlay for the attendance module. It never writes
/// attendance; it only explains that today is approved leave or a holiday.
class LeaveTodayBanner extends StatelessWidget {
  const LeaveTodayBanner({super.key, required this.repository});
  final LeaveRepository repository;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<AuthBloc, AuthState, AuthContext?>(
        selector: (state) => state.context,
        builder: (context, account) {
          final employeeId = account?.employeeReference?.id;
          if (account == null || employeeId == null) {
            return const SizedBox.shrink();
          }
          return FutureBuilder<Result<LeaveWorkdayOverlay?>>(
            future: repository.dayOverride(
              account,
              employeeId,
              DateTime.now().toUtc(),
            ),
            builder: (context, snapshot) {
              final overlay = snapshot.data is Success<LeaveWorkdayOverlay?>
                  ? (snapshot.data as Success<LeaveWorkdayOverlay?>).value
                  : null;
              if (overlay == null) return const SizedBox.shrink();
              final l = context.l10n;
              final holiday =
                  overlay.classification == WorkdayClassification.holiday;
              return AppNotice(
                title: holiday ? l.workdayHoliday : l.workdayOnLeave,
                message: overlay.text.isEmpty ? null : overlay.text,
                status: holiday ? AppStatus.success : AppStatus.brand,
                icon: holiday
                    ? Icons.beach_access_outlined
                    : Icons.event_available_outlined,
              );
            },
          );
        },
      );
}
