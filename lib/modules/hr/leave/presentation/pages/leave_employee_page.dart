import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/presentation/bloc/leave_operations_blocs.dart';
import 'package:modular_erp/modules/hr/leave/presentation/leave_localization.dart';
import 'package:modular_erp/modules/hr/leave/presentation/widgets/leave_operations_widgets.dart';

class EmployeeLeavePage extends StatelessWidget {
  const EmployeeLeavePage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocBuilder<EmployeeLeaveBloc, EmployeeLeaveState>(
      builder: (c, s) {
        final bloc = c.read<EmployeeLeaveBloc>();
        if (s.loading) return const AppPage(child: AppLoadingState());
        final summary = s.summary;
        if (summary == null) {
          return AppPage(
            child: s.failure == null
                ? AppEmptyState(
                    title: l.leaveEmployeeUnavailable,
                    message: l.leaveEmployeeUnavailable,
                  )
                : AppErrorState(
                    message: configurationFailure(s.failure!, l),
                    onRetry: () => bloc.add(const EmployeeLeaveStarted()),
                  ),
          );
        }
        final p = PermissionChecker(bloc.context.user.permissions);
        final canSeeLedger = p.canAny([
          AppPermission.leaveBalanceViewAll,
          AppPermission.leaveBalanceViewTeam,
        ]);
        return AppPage(
          header: AppPageHeader(title: l.leaveEmployeeLeave),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Row(
                  children: [
                    AppAvatar(name: summary.employeeName, radius: 24),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summary.employeeName,
                            style: AppTypography.of(context).sectionTitle,
                          ),
                          Text(
                            [
                              summary.employeeCode,
                              if (summary.designation.isNotEmpty)
                                summary.designation,
                              if (summary.department.isNotEmpty)
                                summary.department,
                            ].join(' · '),
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
              const SizedBox(height: AppSpacing.xl),
              _SectionTitle(title: l.leaveBalanceSection),
              const SizedBox(height: AppSpacing.md),
              if (summary.balances.isEmpty)
                AppEmptyState(
                  title: l.leaveNoBalance,
                  message: l.leaveNoBalance,
                )
              else
                AppResponsiveGrid(
                  minItemWidth: 240,
                  maxColumns: 3,
                  children: [
                    for (final balance in summary.balances)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    balance.leaveTypeName,
                                    style: AppTypography.of(context).cardTitle,
                                  ),
                                ),
                                if (canSeeLedger)
                                  AppTextButton(
                                    label: l.leaveBalanceLedger,
                                    onPressed: () => _showLedger(
                                      context,
                                      bloc,
                                      summary.employeeId,
                                      balance.leaveTypeId,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppInlineStats(
                              stats: [
                                (
                                  label: l.leaveEntitlement,
                                  value: configurationNumber(
                                    context,
                                    balance.entitlement,
                                  ),
                                ),
                                (
                                  label: l.leaveUsed,
                                  value: configurationNumber(
                                    context,
                                    balance.used,
                                  ),
                                ),
                                (
                                  label: l.leavePendingBalance,
                                  value: configurationNumber(
                                    context,
                                    balance.pending,
                                  ),
                                ),
                                (
                                  label: l.leaveAvailable,
                                  value: configurationNumber(
                                    context,
                                    balance.available,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: AppSpacing.xl),
              _SectionTitle(title: l.leaveUpcoming),
              const SizedBox(height: AppSpacing.md),
              if (summary.upcoming.isEmpty)
                AppEmptyState(
                  title: l.leaveNoUpcoming,
                  message: l.leaveNoUpcoming,
                )
              else
                for (final row in summary.upcoming)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      variant: AppCardVariant.interactive,
                      onTap: () => context.push(
                        AppRoutes.leaveRequestDetails(row.request.id),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              row.request.typeSnapshot.name,
                              style: AppTypography.of(context).body,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              leaveDateRange(
                                context,
                                row.request.startDate,
                                row.request.endDate,
                              ),
                              style: AppTypography.of(context).caption,
                            ),
                          ),
                          Text(
                            leaveDaysCount(context, row.request.requestedDays),
                            style: AppTypography.of(context).caption,
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: AppSpacing.xl),
              _SectionTitle(title: l.leaveRecentRequests),
              const SizedBox(height: AppSpacing.md),
              LeaveRequestTable(rows: summary.recent, showEmployee: false),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showLedger(
    BuildContext context,
    EmployeeLeaveBloc bloc,
    String employeeId,
    String leaveTypeId,
  ) async {
    final year = bloc.repository.leaveYearFor(
      bloc.repository.companyToday(bloc.context),
    );
    final result = await bloc.repository.balanceLedger(
      bloc.context,
      employeeId,
      leaveTypeId,
      year,
    );
    if (!context.mounted) return;
    final entries = result is Success<List<LeaveBalanceTransaction>>
        ? result.value
        : const <LeaveBalanceTransaction>[];
    await AppDialog.show<void>(
      context,
      (dialogContext) => AppDialog(
        title: dialogContext.l10n.leaveBalanceLedger,
        actions: [
          AppTextButton(
            label: dialogContext.l10n.close,
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
        child: SizedBox(
          width: 420,
          child: entries.isEmpty
              ? Text(dialogContext.l10n.leaveNoBalance)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final entry in entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                leaveBalanceTypeLabel(
                                  entry.type,
                                  dialogContext.l10n,
                                ),
                                style: AppTypography.of(
                                  dialogContext,
                                ).bodySmall,
                              ),
                            ),
                            Text(
                              configurationNumber(
                                dialogContext,
                                entry.quantityDays,
                              ),
                              style: AppTypography.of(dialogContext).caption,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              configurationDate(
                                dialogContext,
                                entry.effectiveDate,
                              ),
                              style: AppTypography.of(
                                dialogContext,
                              ).caption.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
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
