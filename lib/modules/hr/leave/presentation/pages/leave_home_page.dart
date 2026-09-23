import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/presentation/bloc/leave_blocs.dart';
import 'package:modular_erp/modules/hr/leave/presentation/leave_localization.dart';
import 'package:modular_erp/modules/hr/leave/presentation/widgets/leave_operations_widgets.dart';

class LeaveHomePage extends StatelessWidget {
  const LeaveHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cubit = context.read<LeaveHomeCubit>();
    final canRequest = PermissionChecker(
      cubit.context.user.permissions,
    ).can(AppPermission.leaveRequest);
    final today = cubit.repository.companyToday(cubit.context);
    return AppPage(
      header: AppPageHeader(
        title: l.leaveMyLeave,
        subtitle: l.leaveOverviewSubtitle,
        actions: [
          if (canRequest)
            AppPrimaryButton(
              icon: Icons.add_rounded,
              label: l.leaveNewRequest,
              onPressed: () => context.push(AppRoutes.leaveRequest),
            ),
        ],
      ),
      child: BlocBuilder<LeaveHomeCubit, LeaveHomeState>(
        builder: (c, s) {
          if (s.loading) return const AppLoadingState();
          if (s.failure != null) {
            return AppErrorState(
              message: configurationFailure(s.failure!, l),
              onRetry: cubit.load,
            );
          }
          final upcoming =
              s.requests
                  .where(
                    (r) =>
                        r.request.status == LeaveRequestStatus.approved &&
                        r.request.startDate.isAfter(today),
                  )
                  .toList()
                ..sort(
                  (a, b) => a.request.startDate.compareTo(b.request.startDate),
                );
          final pending = s.requests.where((r) => r.request.isPending).toList()
            ..sort(
              (a, b) => a.request.startDate.compareTo(b.request.startDate),
            );
          final recent = s.requests.toList()
            ..sort(
              (a, b) => (b.request.submittedAt ?? b.request.createdAt)
                  .compareTo(a.request.submittedAt ?? a.request.createdAt),
            );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionTitle(title: l.leaveBalancesTitle),
              const SizedBox(height: AppSpacing.md),
              if (s.balances.isEmpty)
                AppEmptyState(
                  title: l.leaveNoBalance,
                  message: l.leaveNoBalance,
                )
              else
                AppResponsiveGrid(
                  children: [
                    for (final balance in s.balances)
                      _BalanceCard(balance: balance),
                  ],
                ),
              const SizedBox(height: AppSpacing.xl),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 900;
                  final upcomingCard = _UpcomingCard(
                    title: l.upcomingLeave,
                    rows: upcoming,
                    emptyText: l.leaveNoUpcoming,
                    showDays: true,
                  );
                  final sideCard = pending.isNotEmpty
                      ? _PendingCard(rows: pending)
                      : _NextHolidayCard(holiday: s.nextHoliday);
                  if (!wide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        upcomingCard,
                        const SizedBox(height: AppSpacing.lg),
                        sideCard,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: upcomingCard),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(flex: 2, child: sideCard),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionTitle(title: l.leaveRecentRequests),
              const SizedBox(height: AppSpacing.md),
              LeaveRequestTable(rows: recent, showEmployee: false),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) =>
      Text(title, style: AppTypography.of(context).sectionTitle);
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});
  final LeaveBalanceSummary balance;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ratio = balance.entitlement <= 0
        ? 0.0
        : (balance.used / balance.entitlement).clamp(0.0, 1.0);
    final availableLabel =
        '${leaveDaysValue(context, balance.available)} '
        '${l.leaveBalanceAvailableLabel}';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            balance.leaveTypeName,
            style: AppTypography.of(context).cardTitle,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            availableLabel,
            style: AppTypography.of(context).body.copyWith(
              color: AppColors.brandPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (balance.entitlement > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: AppColors.surfaceSubtle,
                color: AppColors.brandPrimary,
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          AppInlineStats(
            stats: [
              (label: l.leaveBalanceUsedLabel, value: '${balance.used}'),
              (label: l.leaveBalancePendingLabel, value: '${balance.pending}'),
              (
                label: l.leaveBalanceEntitlementLabel,
                value: '${balance.entitlement}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({
    required this.title,
    required this.rows,
    required this.emptyText,
    this.showDays = false,
  });
  final String title, emptyText;
  final List<LeaveRequestRow> rows;
  final bool showDays;
  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTypography.of(context).sectionTitle),
        const SizedBox(height: AppSpacing.md),
        if (rows.isEmpty)
          Text(
            emptyText,
            style: AppTypography.of(
              context,
            ).bodySmall.copyWith(color: AppColors.textMuted),
          )
        else
          for (final row in rows.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                onTap: () =>
                    context.push(AppRoutes.leaveRequestDetails(row.request.id)),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        row.request.typeSnapshot.name,
                        style: AppTypography.of(context).body,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        leaveDateRange(
                          context,
                          row.request.startDate,
                          row.request.endDate,
                        ),
                        style: AppTypography.of(context).caption,
                      ),
                    ),
                    if (showDays)
                      Text(
                        leaveDaysCount(context, row.request.requestedDays),
                        style: AppTypography.of(context).caption,
                      ),
                  ],
                ),
              ),
            ),
      ],
    ),
  );
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.rows});
  final List<LeaveRequestRow> rows;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.hourglass_bottom, color: AppColors.warning, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l.pendingRequest,
                style: AppTypography.of(context).sectionTitle,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final row in rows.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                onTap: () =>
                    context.push(AppRoutes.leaveRequestDetails(row.request.id)),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.request.typeSnapshot.name,
                        style: AppTypography.of(context).body,
                      ),
                    ),
                    Text(
                      leaveDateRange(
                        context,
                        row.request.startDate,
                        row.request.endDate,
                      ),
                      style: AppTypography.of(context).caption,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NextHolidayCard extends StatelessWidget {
  const _NextHolidayCard({required this.holiday});
  final Holiday? holiday;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final holiday = this.holiday;
    if (holiday == null) return const SizedBox.shrink();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.beach_access_outlined, color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l.nextHoliday,
                style: AppTypography.of(context).sectionTitle,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            holiday.name,
            style: AppTypography.of(
              context,
            ).body.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            holidayTypeLabel(holiday.type, l),
            style: AppTypography.of(
              context,
            ).caption.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            configurationDate(context, holiday.date),
            style: AppTypography.of(context).caption,
          ),
        ],
      ),
    );
  }
}
