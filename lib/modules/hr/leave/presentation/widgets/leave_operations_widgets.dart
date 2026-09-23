import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/presentation/leave_localization.dart';

AppStatus leaveStatusAppStatus(LeaveRequestStatus status) => switch (status) {
  LeaveRequestStatus.pending => AppStatus.warning,
  LeaveRequestStatus.approved => AppStatus.success,
  LeaveRequestStatus.rejected => AppStatus.danger,
  LeaveRequestStatus.cancelled => AppStatus.neutral,
};

class LeaveStatusBadge extends StatelessWidget {
  const LeaveStatusBadge({super.key, required this.status});
  final LeaveRequestStatus status;
  @override
  Widget build(BuildContext context) => AppStatusBadge(
    label: leaveRequestStatusLabel(status, context.l10n),
    status: leaveStatusAppStatus(status),
  );
}

class LeaveSummaryMetrics extends StatelessWidget {
  const LeaveSummaryMetrics({
    super.key,
    required this.summary,
    this.showTeamMembers = false,
  });
  final LeaveOperationsSummary summary;
  final bool showTeamMembers;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final metrics = <({String label, String value})>[
      (label: l.leaveOnLeaveToday, value: '${summary.onLeaveToday}'),
      (label: l.leaveUpcoming, value: '${summary.upcoming}'),
      (label: l.leavePendingApproval, value: '${summary.pending}'),
      (label: l.leaveApprovedThisMonth, value: '${summary.approvedThisMonth}'),
      if (showTeamMembers)
        (label: l.leaveTeamMembers, value: '${summary.teamMembers}'),
    ];
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.lg,
      children: [
        for (final metric in metrics)
          SizedBox(
            width: 190,
            child: AppMetricCard(
              label: metric.label,
              value: metric.value,
              variant: AppMetricVariant.secondary,
            ),
          ),
      ],
    );
  }
}

class LeaveTodaySection extends StatelessWidget {
  const LeaveTodaySection({super.key, required this.items});
  final List<LeaveTodayItem> items;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (items.isEmpty) {
      return AppEmptyState(
        title: l.leaveNoEmployeesOnLeave,
        message: l.leaveNoEmployeesOnLeave,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              variant: AppCardVariant.interactive,
              onTap: () => context.push(
                AppRoutes.leaveRequestDetails(item.row.request.id),
              ),
              child: Row(
                children: [
                  AppAvatar(name: item.row.employeeName),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.row.employeeName,
                          style: AppTypography.of(
                            context,
                          ).body.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (item.designation.isNotEmpty)
                          Text(
                            item.designation,
                            style: AppTypography.of(
                              context,
                            ).caption.copyWith(color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.row.request.typeSnapshot.name,
                          style: AppTypography.of(context).bodySmall,
                        ),
                        Text(
                          item.isHalfDay ? l.leaveHalfDay : l.leaveFullDay,
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
                      LeaveStatusBadge(status: item.row.request.status),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        leaveReturnLabel(context, item.returnDate),
                        style: AppTypography.of(
                          context,
                        ).caption.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class LeaveUpcomingSection extends StatelessWidget {
  const LeaveUpcomingSection({super.key, required this.items});
  final List<UpcomingLeaveItem> items;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (items.isEmpty) {
      return AppEmptyState(
        title: l.leaveNoUpcoming,
        message: l.leaveNoUpcoming,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              variant: AppCardVariant.interactive,
              onTap: () => context.push(
                AppRoutes.leaveRequestDetails(item.row.request.id),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.row.employeeName,
                      style: AppTypography.of(
                        context,
                      ).body.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.row.request.typeSnapshot.name,
                      style: AppTypography.of(context).bodySmall,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      leaveDateRange(
                        context,
                        item.row.request.startDate,
                        item.row.request.endDate,
                      ),
                      style: AppTypography.of(context).caption,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class LeaveRequestTable extends StatelessWidget {
  const LeaveRequestTable({
    super.key,
    required this.rows,
    this.showEmployee = true,
    this.canReview = false,
    this.emptyTitle,
  });
  final List<LeaveRequestRow> rows;
  final bool showEmployee, canReview;
  final String? emptyTitle;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (rows.isEmpty) {
      return AppEmptyState(
        title: emptyTitle ?? l.leaveRequestsEmpty,
        message: emptyTitle ?? l.leaveRequestsEmpty,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            AppBreakpoints.classify(constraints.maxWidth) == AppSize.compact;
        if (compact) return _cards(context);
        return AppCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: AppDataTable(
              columns: [
                if (showEmployee) DataColumn(label: Text(l.leaveEmployee)),
                DataColumn(label: Text(l.leaveType)),
                DataColumn(label: Text(l.leaveFrom)),
                DataColumn(label: Text(l.leaveTo)),
                DataColumn(label: Text(l.days)),
                DataColumn(label: Text(l.leaveStatusField)),
                DataColumn(label: Text(l.leaveSubmittedOn)),
                DataColumn(label: Text(l.cfgActions)),
              ],
              rows: [
                for (final row in rows)
                  DataRow(
                    onSelectChanged: (_) => context.push(
                      AppRoutes.leaveRequestDetails(row.request.id),
                    ),
                    cells: [
                      if (showEmployee)
                        DataCell(
                          Text(
                            row.employeeName,
                            style: AppTypography.of(
                              context,
                            ).body.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      DataCell(Text(row.request.typeSnapshot.name)),
                      DataCell(
                        Text(configurationDate(context, row.request.startDate)),
                      ),
                      DataCell(
                        Text(configurationDate(context, row.request.endDate)),
                      ),
                      DataCell(
                        Text(
                          configurationNumber(
                            context,
                            row.request.requestedDays,
                          ),
                        ),
                      ),
                      DataCell(LeaveStatusBadge(status: row.request.status)),
                      DataCell(
                        Text(
                          row.request.submittedAt == null
                              ? '—'
                              : configurationDate(
                                  context,
                                  row.request.submittedAt!,
                                ),
                        ),
                      ),
                      DataCell(
                        AppActionMenu(
                          tooltip: l.cfgActions,
                          actions: [
                            AppMenuAction(
                              label: (l) => l.leaveViewDetails,
                              onPressed: () => context.push(
                                AppRoutes.leaveRequestDetails(row.request.id),
                              ),
                            ),
                            if (canReview && row.request.isPending)
                              AppMenuAction(
                                label: (l) => l.leaveReviewRequest,
                                onPressed: () => context.push(
                                  AppRoutes.leaveRequestDetails(row.request.id),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cards(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              variant: AppCardVariant.interactive,
              onTap: () =>
                  context.push(AppRoutes.leaveRequestDetails(row.request.id)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (showEmployee) ...[
                        AppAvatar(name: row.employeeName),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Expanded(
                        child: Text(
                          showEmployee
                              ? row.employeeName
                              : row.request.typeSnapshot.name,
                          style: AppTypography.of(context).cardTitle,
                        ),
                      ),
                      LeaveStatusBadge(status: row.request.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    showEmployee
                        ? row.request.typeSnapshot.name
                        : '${row.request.requestedDays} ${l.days}',
                    style: AppTypography.of(
                      context,
                    ).bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  Text(
                    leavePeriodDays(
                      context,
                      row.request.startDate,
                      row.request.endDate,
                      row.request.requestedDays,
                    ),
                    style: AppTypography.of(
                      context,
                    ).caption.copyWith(color: AppColors.textMuted),
                  ),
                  if (canReview && row.request.isPending) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: AppSecondaryButton(
                        label: l.leaveReviewRequest,
                        size: AppButtonSize.small,
                        onPressed: () => context.push(
                          AppRoutes.leaveRequestDetails(row.request.id),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
