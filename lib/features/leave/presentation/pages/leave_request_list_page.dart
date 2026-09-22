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

AppStatus leaveStatusColor(LeaveRequestStatus status) => switch (status) {
  LeaveRequestStatus.pending => AppStatus.warning,
  LeaveRequestStatus.approved => AppStatus.success,
  LeaveRequestStatus.rejected => AppStatus.danger,
  LeaveRequestStatus.cancelled => AppStatus.neutral,
};

class LeaveRequestListPage extends StatelessWidget {
  const LeaveRequestListPage({
    super.key,
    required this.title,
    required this.emptyMessage,
  });
  final String title, emptyMessage;
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
          final bloc = c.read<LeaveRequestListBloc>();
          final canRequest =
              bloc.scope != LeaveRequestScope.approvals &&
              bloc.context.user.permissions.contains(
                AppPermission.leaveRequest,
              );
          return AppPage(
            header: AppPageHeader(
              title: title,
              actions: [
                if (canRequest)
                  AppPrimaryButton(
                    icon: Icons.add_rounded,
                    label: c.l10n.leaveNewRequest,
                    onPressed: () => c.push(AppRoutes.leaveNew),
                  ),
              ],
            ),
            child: s.loading
                ? const AppLoadingState()
                : s.failure != null
                ? AppErrorState(
                    message: configurationFailure(s.failure!, c.l10n),
                    onRetry: () => bloc.add(const LeaveRequestListStarted()),
                  )
                : s.rows.isEmpty
                ? AppEmptyState(title: emptyMessage, message: emptyMessage)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final row in s.rows)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _RequestCard(
                            row: row,
                            showEmployee: bloc.scope != LeaveRequestScope.self,
                          ),
                        ),
                    ],
                  ),
          );
        },
      );
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.row, required this.showEmployee});
  final LeaveRequestRow row;
  final bool showEmployee;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final request = row.request;
    final title = showEmployee && row.employeeName.isNotEmpty
        ? row.employeeName
        : request.typeSnapshot.name;
    final subtitle = showEmployee && row.employeeName.isNotEmpty
        ? request.typeSnapshot.name
        : '${configurationDate(context, request.startDate)} - '
              '${configurationDate(context, request.endDate)}';
    final detail =
        '${configurationDate(context, request.startDate)} - '
        '${configurationDate(context, request.endDate)}';
    final dayCountLabel = '${request.requestedDays} ${l.days}';
    return AppCard(
      variant: AppCardVariant.interactive,
      onTap: () => context.push(AppRoutes.leaveRequestDetails(request.id)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.of(context).cardTitle),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.of(
                    context,
                  ).bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: AppTypography.of(
                    context,
                  ).caption.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppStatusBadge(
                label: leaveRequestStatusLabel(request.status, l),
                status: leaveStatusColor(request.status),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                dayCountLabel,
                style: AppTypography.of(
                  context,
                ).caption.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
