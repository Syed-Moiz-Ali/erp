import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/security/app_permission.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/presentation/configuration_localization.dart';
import '../../domain/leave_models.dart';
import '../../domain/leave_repository.dart';
import '../bloc/leave_blocs.dart';
import '../leave_localization.dart';
import '../widgets/leave_operations_widgets.dart';

AppStatus leaveStatusColor(LeaveRequestStatus status) => switch (status) {
  LeaveRequestStatus.pending => AppStatus.warning,
  LeaveRequestStatus.approved => AppStatus.success,
  LeaveRequestStatus.rejected => AppStatus.danger,
  LeaveRequestStatus.cancelled => AppStatus.neutral,
};

class LeaveRequestListPage extends StatefulWidget {
  const LeaveRequestListPage({
    super.key,
    required this.title,
    required this.emptyMessage,
  });
  final String title, emptyMessage;
  @override
  State<LeaveRequestListPage> createState() => _LeaveRequestListPageState();
}

class _LeaveRequestListPageState extends State<LeaveRequestListPage> {
  LeaveRequestStatus? _status;

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<LeaveRequestListBloc, LeaveRequestListState>(
        listener: (c, s) {
          if (s.failure != null) {
            AppFeedback.showMessage(
              c,
              message: (l) => configurationFailure(s.failure!, l),
            );
          }
        },
        builder: (c, s) {
          final l = c.l10n;
          final bloc = c.read<LeaveRequestListBloc>();
          final canRequest =
              bloc.scope != LeaveRequestScope.approvals &&
              bloc.context.user.permissions.contains(
                AppPermission.leaveRequest,
              );
          final rows = _status == null
              ? s.rows
              : s.rows.where((r) => r.request.status == _status).toList();
          return AppPage(
            header: AppPageHeader(
              title: widget.title,
              actions: [
                if (canRequest)
                  AppPrimaryButton(
                    icon: Icons.add_rounded,
                    label: l.leaveNewRequest,
                    onPressed: () => c.push(AppRoutes.leaveRequest),
                  ),
              ],
            ),
            child: s.loading
                ? const AppLoadingState()
                : s.failure != null
                ? AppErrorState(
                    message: configurationFailure(s.failure!, l),
                    onRetry: () => bloc.add(const LeaveRequestListStarted()),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 220,
                        child: AppSelectField<String>(
                          label: l.leaveStatusField,
                          value: _status?.name ?? '',
                          options: [
                            AppSelectOption('', l.leaveAllStatuses),
                            for (final status in LeaveRequestStatus.values)
                              AppSelectOption(
                                status.name,
                                leaveRequestStatusLabel(status, l),
                              ),
                          ],
                          onChanged: (v) => setState(
                            () => _status = v == null || v.isEmpty
                                ? null
                                : LeaveRequestStatus.values.byName(v),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      LeaveRequestTable(
                        rows: rows,
                        showEmployee: bloc.scope != LeaveRequestScope.self,
                        emptyTitle: widget.emptyMessage,
                      ),
                    ],
                  ),
          );
        },
      );
}
