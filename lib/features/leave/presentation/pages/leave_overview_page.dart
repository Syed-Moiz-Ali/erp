import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/security/app_permission.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/presentation/configuration_localization.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/leave_models.dart';
import '../bloc/leave_operations_blocs.dart';
import '../leave_localization.dart';
import '../widgets/leave_operations_widgets.dart';

/// Persona-aware operational Leave workspace for manager/company scope.
class LeaveOverviewPage extends StatelessWidget {
  const LeaveOverviewPage({super.key, required this.company});
  final bool company;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final account = context.read<AuthBloc>().state.context;
    if (account == null) return const SizedBox.shrink();
    final p = PermissionChecker(account.user.permissions);
    final canApprove =
        p.can(AppPermission.leaveApproveTeam) ||
        p.can(AppPermission.leaveApproveAll);
    final canBalances = p.canAny([
      AppPermission.leaveBalanceViewTeam,
      AppPermission.leaveBalanceViewAll,
    ]);
    final canManageHolidays = p.can(AppPermission.holidayManage);
    return AppPage(
      header: AppPageHeader(
        title: company ? l.leaveCompanyOverview : l.leaveTeamOverview,
        subtitle: l.leaveOverviewSubtitle,
        actions: [
          if (canApprove)
            AppPrimaryButton(
              icon: Icons.fact_check_outlined,
              label: l.reviewRequests,
              onPressed: () => context.push(AppRoutes.leaveApprovals),
            ),
          if (company)
            AppSecondaryButton(
              label: l.leaveViewAllLeave,
              onPressed: () => context.push(AppRoutes.leaveAll),
            ),
          if (canBalances)
            AppSecondaryButton(
              icon: Icons.account_balance_wallet_outlined,
              label: l.leaveBalancesNav,
              onPressed: () => context.push(AppRoutes.leaveBalances),
            ),
          if (canManageHolidays)
            AppSecondaryButton(
              icon: Icons.beach_access_outlined,
              label: l.manageHolidays,
              onPressed: () => context.push(AppRoutes.holidays),
            ),
        ],
      ),
      child: BlocBuilder<LeaveOperationsBloc, LeaveOperationsState>(
        builder: (c, s) {
          if (s.loading) return const AppLoadingState();
          if (s.failure != null) {
            return AppErrorState(
              message: configurationFailure(s.failure!, l),
              onRetry: () => c.read<LeaveOperationsBloc>().add(
                const LeaveOperationsStarted(),
              ),
            );
          }
          final data = s.data;
          if (data == null) return const SizedBox.shrink();
          final pending =
              data.requests.where((r) => r.request.isPending).toList()..sort(
                (a, b) => a.request.startDate.compareTo(b.request.startDate),
              );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LeaveSummaryMetrics(
                summary: data.summary,
                showTeamMembers: !company,
              ),
              const SizedBox(height: AppSpacing.xl),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 1000;
                  final todayCard = _Panel(
                    title: l.leaveOnLeaveToday,
                    child: LeaveTodaySection(items: data.today),
                  );
                  final pendingCard = _Panel(
                    title: l.leavePendingApprovals,
                    child: _PendingList(
                      rows: pending,
                      onReview: () => context.push(AppRoutes.leaveApprovals),
                    ),
                  );
                  if (!wide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        pendingCard,
                        const SizedBox(height: AppSpacing.lg),
                        todayCard,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: todayCard),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(flex: 2, child: pendingCard),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _Panel(
                title: company ? l.leaveUpcoming : l.leaveUpcomingTeamLeave,
                child: LeaveUpcomingSection(items: data.upcoming),
              ),
              if (company) ...[
                const SizedBox(height: AppSpacing.lg),
                const _HolidayStatusPanel(),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTypography.of(context).sectionTitle),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    ),
  );
}

class _PendingList extends StatelessWidget {
  const _PendingList({required this.rows, required this.onReview});
  final List<LeaveRequestRow> rows;
  final VoidCallback onReview;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (rows.isEmpty) {
      return Text(
        l.leaveNoPendingApprovals,
        style: AppTypography.of(
          context,
        ).bodySmall.copyWith(color: AppColors.textMuted),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final row in rows.take(5))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: InkWell(
              onTap: () =>
                  context.push(AppRoutes.leaveRequestDetails(row.request.id)),
              child: Row(
                children: [
                  AppAvatar(name: row.employeeName),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.employeeName,
                          style: AppTypography.of(
                            context,
                          ).body.copyWith(fontWeight: FontWeight.w600),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: AppTextButton(label: l.reviewRequests, onPressed: onReview),
        ),
      ],
    );
  }
}

class _HolidayStatusPanel extends StatelessWidget {
  const _HolidayStatusPanel();
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bloc = context.read<LeaveOperationsBloc>();
    final year = bloc.repository.leaveYearFor(
      bloc.repository.companyToday(bloc.context),
    );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.holidayCalendarStatus,
            style: AppTypography.of(context).sectionTitle,
          ),
          const SizedBox(height: AppSpacing.md),
          StreamBuilder<Result<List<Holiday>>>(
            stream: bloc.repository.watchHolidaysForYear(bloc.context, year),
            builder: (context, snapshot) {
              final holidays = snapshot.data is Success<List<Holiday>>
                  ? (snapshot.data as Success<List<Holiday>>).value
                  : const <Holiday>[];
              final today = bloc.repository.companyToday(bloc.context);
              final next =
                  holidays
                      .where((h) => !(h.endDate ?? h.date).isBefore(today))
                      .toList()
                    ..sort((a, b) => a.date.compareTo(b.date));
              final yearLabel = '$year';
              final activeLabel = '${l.activeHolidays}: ${holidays.length}';
              final nextLabel = next.isEmpty
                  ? '${year + 1}: ${l.holidayNotConfigured}'
                  : '${l.nextHoliday}: ${next.first.name} · '
                        '${configurationDate(context, next.first.date)}';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    yearLabel,
                    style: AppTypography.of(
                      context,
                    ).body.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    activeLabel,
                    style: AppTypography.of(
                      context,
                    ).bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  Text(
                    nextLabel,
                    style: AppTypography.of(
                      context,
                    ).caption.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: AppTextButton(
                      label: l.manageHolidays,
                      onPressed: () => context.push(AppRoutes.holidays),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
