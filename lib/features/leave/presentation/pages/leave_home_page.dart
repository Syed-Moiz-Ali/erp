import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/presentation/configuration_localization.dart';
import '../bloc/leave_blocs.dart';

class LeaveHomePage extends StatelessWidget {
  const LeaveHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppPage(
      header: AppPageHeader(
        title: l.leaveMyLeave,
        actions: [
          AppPrimaryButton(
            icon: Icons.add_rounded,
            label: l.leaveNewRequest,
            onPressed: () => context.push(AppRoutes.leaveNew),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QuickActions(
            row: [
              (
                icon: Icons.event_note_outlined,
                label: l.leaveMyRequests,
                route: AppRoutes.leaveRequests,
              ),
              (
                icon: Icons.account_balance_wallet_outlined,
                label: l.leaveBalancesNav,
                route: AppRoutes.leaveBalances,
              ),
              (
                icon: Icons.calendar_month_outlined,
                label: l.leaveCalendarNav,
                route: AppRoutes.leaveCalendar,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          BlocBuilder<LeaveBalancesCubit, LeaveBalancesState>(
            builder: (c, s) {
              if (s.loading) return const AppLoadingState();
              if (s.failure != null) {
                return AppErrorState(
                  message: configurationFailure(s.failure!, c.l10n),
                  onRetry: () => c.read<LeaveBalancesCubit>().load(),
                );
              }
              if (s.balances.isEmpty) {
                return AppCard(
                  child: AppEmptyState(
                    title: c.l10n.leaveNoBalance,
                    message: c.l10n.leaveNoBalance,
                  ),
                );
              }
              return Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: [
                  for (final balance in s.balances)
                    SizedBox(
                      width: 220,
                      child: AppMetricCard(
                        label: balance.leaveTypeName,
                        value: '${balance.available}',
                        detail: c.l10n.leaveAvailable,
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

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.row});
  final List<({IconData icon, String label, String route})> row;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.lg,
    runSpacing: AppSpacing.lg,
    children: [
      for (final action in row)
        SizedBox(
          width: 200,
          child: AppCard(
            variant: AppCardVariant.interactive,
            onTap: () => context.push(action.route),
            child: Row(
              children: [
                Icon(action.icon, color: AppColors.brandPrimary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    action.label,
                    style: AppTypography.of(context).body,
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
