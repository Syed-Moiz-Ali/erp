import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/presentation/bloc/leave_operations_blocs.dart';
import 'package:modular_erp/modules/hr/leave/presentation/leave_localization.dart';
import 'package:modular_erp/modules/hr/leave/presentation/widgets/leave_operations_widgets.dart';

class LeaveApprovalsPage extends StatefulWidget {
  const LeaveApprovalsPage({super.key});
  @override
  State<LeaveApprovalsPage> createState() => _LeaveApprovalsPageState();
}

class _LeaveApprovalsPageState extends State<LeaveApprovalsPage> {
  String _search = '';
  String? _leaveTypeId;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppPage(
      header: AppPageHeader(
        title: l.leaveApprovalsTitle,
        subtitle: l.leaveApprovalsSubtitle,
      ),
      child: BlocBuilder<LeaveApprovalsBloc, LeaveApprovalsState>(
        builder: (c, s) {
          if (s.loading) return const AppLoadingState();
          if (s.failure != null) {
            return AppErrorState(
              message: configurationFailure(s.failure!, c.l10n),
              onRetry: () => c.read<LeaveApprovalsBloc>().add(
                const LeaveApprovalsStarted(),
              ),
            );
          }
          final bloc = c.read<LeaveApprovalsBloc>();
          final today = bloc.repository.companyToday(bloc.context);
          final startingSoon = s.items
              .where(
                (i) =>
                    !i.row.request.startDate.isBefore(today) &&
                    i.row.request.startDate.isBefore(
                      today.add(const Duration(days: 7)),
                    ),
              )
              .length;
          final query = _search.trim().toLowerCase();
          final items = s.items.where((item) {
            if (_leaveTypeId != null &&
                item.row.request.typeSnapshot.typeId != _leaveTypeId) {
              return false;
            }
            if (query.isEmpty) return true;
            return item.row.employeeName.toLowerCase().contains(query) ||
                item.row.employeeCode.toLowerCase().contains(query) ||
                item.row.department.toLowerCase().contains(query);
          }).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: [
                  AppMetricCard(
                    label: l.leavePendingRequests,
                    value: '${s.items.length}',
                    variant: AppMetricVariant.secondary,
                  ),
                  AppMetricCard(
                    label: l.leaveStartingSoon,
                    value: '$startingSoon',
                    variant: AppMetricVariant.secondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    child: AppTextField(
                      label: l.leaveSearchEmployee,
                      hint: l.leaveSearchEmployee,
                      prefixIcon: Icons.search_rounded,
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: StreamBuilder<Result<List<LeaveType>>>(
                      stream: bloc.repository.watchLeaveTypes(bloc.context),
                      builder: (c, snapshot) {
                        final types = snapshot.data is Success<List<LeaveType>>
                            ? (snapshot.data as Success<List<LeaveType>>).value
                            : const <LeaveType>[];
                        return AppSelectField<String>(
                          label: l.leaveType,
                          value: _leaveTypeId ?? '',
                          options: [
                            AppSelectOption('', l.leaveAllTypes),
                            for (final type in types)
                              AppSelectOption(type.id, type.name),
                          ],
                          onChanged: (v) => setState(
                            () => _leaveTypeId = v == null || v.isEmpty
                                ? null
                                : v,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (items.isEmpty)
                AppEmptyState(
                  title: l.leaveApprovalsEmptyQueue,
                  message: l.leaveApprovalsEmptyQueue,
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact =
                        AppBreakpoints.classify(constraints.maxWidth) ==
                        AppSize.compact;
                    return compact ? _cards(c, items) : _table(c, items);
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _table(BuildContext context, List<LeaveApprovalItem> items) {
    final l = context.l10n;
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: AppDataTable(
          columns: [
            DataColumn(label: Text(l.leaveEmployee)),
            DataColumn(label: Text(l.leaveDepartment)),
            DataColumn(label: Text(l.leaveType)),
            DataColumn(label: Text(l.leaveRequestedPeriod)),
            DataColumn(label: Text(l.days)),
            DataColumn(label: Text(l.leaveAvailableBalance)),
            DataColumn(label: Text(l.leaveSubmittedOn)),
            DataColumn(label: Text(l.cfgActions)),
          ],
          rows: [
            for (final item in items)
              DataRow(
                onSelectChanged: (_) => context.push(
                  AppRoutes.leaveRequestDetails(item.row.request.id),
                ),
                cells: [
                  DataCell(
                    Text(
                      item.row.employeeName,
                      style: AppTypography.of(
                        context,
                      ).body.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(Text(item.row.department)),
                  DataCell(Text(item.row.request.typeSnapshot.name)),
                  DataCell(
                    Text(
                      leaveDateRange(
                        context,
                        item.row.request.startDate,
                        item.row.request.endDate,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      configurationNumber(
                        context,
                        item.row.request.requestedDays,
                      ),
                    ),
                  ),
                  DataCell(Text(configurationNumber(context, item.available))),
                  DataCell(
                    Text(
                      item.row.request.submittedAt == null
                          ? '—'
                          : configurationDate(
                              context,
                              item.row.request.submittedAt!,
                            ),
                    ),
                  ),
                  DataCell(
                    AppPrimaryButton(
                      label: l.leaveReviewRequest,
                      size: AppButtonSize.small,
                      onPressed: () => context.push(
                        AppRoutes.leaveRequestDetails(item.row.request.id),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _cards(BuildContext context, List<LeaveApprovalItem> items) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              variant: AppCardVariant.interactive,
              onTap: () => context.push(
                AppRoutes.leaveRequestDetails(item.row.request.id),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppAvatar(name: item.row.employeeName),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          item.row.employeeName,
                          style: AppTypography.of(context).cardTitle,
                        ),
                      ),
                      LeaveStatusBadge(status: item.row.request.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    item.row.request.typeSnapshot.name,
                    style: AppTypography.of(
                      context,
                    ).bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  Text(
                    leavePeriodDays(
                      context,
                      item.row.request.startDate,
                      item.row.request.endDate,
                      item.row.request.requestedDays,
                    ),
                    style: AppTypography.of(
                      context,
                    ).caption.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppInlineStats(
                    stats: [
                      (
                        label: l.leaveAvailableBalance,
                        value: '${item.available}',
                      ),
                      (
                        label: l.leaveBalanceAfterApproval,
                        value: '${item.afterApproval}',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: AppPrimaryButton(
                      label: l.leaveReviewRequest,
                      size: AppButtonSize.small,
                      onPressed: () => context.push(
                        AppRoutes.leaveRequestDetails(item.row.request.id),
                      ),
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
