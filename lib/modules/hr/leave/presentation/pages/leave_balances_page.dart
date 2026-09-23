import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_repository.dart';
import 'package:modular_erp/modules/hr/leave/presentation/bloc/leave_blocs.dart';
import 'package:modular_erp/modules/hr/leave/presentation/bloc/leave_operations_blocs.dart';
import 'package:modular_erp/modules/hr/leave/presentation/leave_localization.dart';

class LeaveBalancesPage extends StatelessWidget {
  const LeaveBalancesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocSelector<AuthBloc, AuthState, AuthContext?>(
      selector: (s) => s.context,
      builder: (context, account) {
        final canTable = account != null
            ? PermissionChecker(account.user.permissions).canAny([
                AppPermission.leaveBalanceViewAll,
                AppPermission.leaveBalanceViewTeam,
              ])
            : false;
        return AppPage(
          header: AppPageHeader(title: l.leaveBalancesTitle),
          child: canTable ? const _BalanceTable() : const _SelfBalances(),
        );
      },
    );
  }
}

class _SelfBalances extends StatelessWidget {
  const _SelfBalances();
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocBuilder<LeaveBalancesCubit, LeaveBalancesState>(
      builder: (c, s) {
        if (s.loading) return const AppLoadingState();
        if (s.failure != null) {
          return AppErrorState(
            message: configurationFailure(s.failure!, c.l10n),
            onRetry: () => c.read<LeaveBalancesCubit>().load(),
          );
        }
        if (s.balances.isEmpty) {
          return AppEmptyState(
            title: l.leaveNoBalance,
            message: l.leaveNoBalance,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final balance in s.balances)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        balance.leaveTypeName,
                        style: AppTypography.of(context).cardTitle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppInlineStats(
                        stats: [
                          (
                            label: l.leaveEntitlement,
                            value: '${balance.entitlement}',
                          ),
                          (label: l.leaveUsed, value: '${balance.used}'),
                          (
                            label: l.leavePendingBalance,
                            value: '${balance.pending}',
                          ),
                          (
                            label: l.leaveAvailable,
                            value: '${balance.available}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BalanceTable extends StatelessWidget {
  const _BalanceTable();
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bloc = context.read<LeaveBalanceTableBloc>();
    final p = PermissionChecker(bloc.context.user.permissions);
    final canAdjust = p.can(AppPermission.leaveBalanceAdjust);
    return BlocBuilder<LeaveBalanceTableBloc, LeaveBalanceTableState>(
      builder: (c, s) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: AppFormGrid(
                children: [
                  AppTextField(
                    label: l.leaveSearchEmployee,
                    hint: l.leaveSearchEmployee,
                    initialValue: s.search,
                    prefixIcon: Icons.search_rounded,
                    onChanged: (v) => bloc.add(
                      LeaveBalanceTableFilterChanged(
                        search: v,
                        departmentId: s.departmentId,
                        leaveTypeId: s.leaveTypeId,
                        year: s.year,
                      ),
                    ),
                  ),
                  StreamBuilder<Result<List<LeaveDepartmentOption>>>(
                    stream: bloc.repository.watchDepartments(bloc.context),
                    builder: (c, snapshot) {
                      final departments =
                          snapshot.data is Success<List<LeaveDepartmentOption>>
                          ? (snapshot.data
                                    as Success<List<LeaveDepartmentOption>>)
                                .value
                          : const <LeaveDepartmentOption>[];
                      return AppSelectField<String>(
                        label: l.leaveDepartment,
                        value: s.departmentId,
                        hint: l.leavePeriodAll,
                        options: [
                          for (final department in departments)
                            AppSelectOption(department.id, department.name),
                        ],
                        onChanged: (v) => bloc.add(
                          LeaveBalanceTableFilterChanged(
                            search: s.search,
                            departmentId: v,
                            leaveTypeId: s.leaveTypeId,
                            year: s.year,
                          ),
                        ),
                      );
                    },
                  ),
                  StreamBuilder<Result<List<LeaveType>>>(
                    stream: bloc.repository.watchLeaveTypes(bloc.context),
                    builder: (c, snapshot) {
                      final types = snapshot.data is Success<List<LeaveType>>
                          ? (snapshot.data as Success<List<LeaveType>>).value
                          : const <LeaveType>[];
                      return AppSelectField<String>(
                        label: l.leaveType,
                        value: s.leaveTypeId,
                        hint: l.leavePeriodAll,
                        options: [
                          for (final type in types)
                            AppSelectOption(type.id, type.name),
                        ],
                        onChanged: (v) => bloc.add(
                          LeaveBalanceTableFilterChanged(
                            search: s.search,
                            departmentId: s.departmentId,
                            leaveTypeId: v,
                            year: s.year,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (s.loading)
              const AppLoadingState()
            else if (s.failure != null)
              AppErrorState(
                message: configurationFailure(s.failure!, c.l10n),
                onRetry: () => bloc.add(const LeaveBalanceTableStarted()),
              )
            else if (s.rows.isEmpty)
              AppEmptyState(
                title: l.leaveNoBalanceForFilters,
                message: l.leaveNoBalanceForFilters,
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact =
                      AppBreakpoints.classify(constraints.maxWidth) ==
                      AppSize.compact;
                  return compact
                      ? _cards(c, s.rows, canAdjust)
                      : _table(c, s.rows, canAdjust);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _table(
    BuildContext context,
    List<LeaveBalanceRow> rows,
    bool canAdjust,
  ) {
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
            DataColumn(label: Text(l.leaveEntitlement)),
            DataColumn(label: Text(l.leaveUsed)),
            DataColumn(label: Text(l.leavePendingBalance)),
            DataColumn(label: Text(l.leaveAvailable)),
            DataColumn(label: Text(l.cfgActions)),
          ],
          rows: [
            for (final row in rows)
              DataRow(
                onSelectChanged: (_) =>
                    context.push(AppRoutes.leaveEmployee(row.employeeId)),
                cells: [
                  DataCell(
                    Text(
                      row.employeeName,
                      style: AppTypography.of(
                        context,
                      ).body.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(Text(row.department)),
                  DataCell(Text(row.leaveTypeName)),
                  DataCell(Text(configurationNumber(context, row.entitlement))),
                  DataCell(Text(configurationNumber(context, row.used))),
                  DataCell(Text(configurationNumber(context, row.pending))),
                  DataCell(Text(configurationNumber(context, row.available))),
                  DataCell(
                    AppActionMenu(
                      tooltip: l.cfgActions,
                      actions: [
                        AppMenuAction(
                          label: (l) => l.leaveViewEmployeeLeave,
                          onPressed: () => context.push(
                            AppRoutes.leaveEmployee(row.employeeId),
                          ),
                        ),
                        if (canAdjust)
                          AppMenuAction(
                            label: (l) => l.leaveAdjustBalance,
                            onPressed: () => _adjust(context, row),
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
  }

  Widget _cards(
    BuildContext context,
    List<LeaveBalanceRow> rows,
    bool canAdjust,
  ) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppAvatar(name: row.employeeName),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.employeeName,
                              style: AppTypography.of(context).cardTitle,
                            ),
                            Text(
                              leaveDepartmentType(
                                row.department,
                                row.leaveTypeName,
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
                  const SizedBox(height: AppSpacing.sm),
                  AppInlineStats(
                    stats: [
                      (label: l.leaveAvailable, value: '${row.available}'),
                      (label: l.leaveUsed, value: '${row.used}'),
                      (label: l.leavePendingBalance, value: '${row.pending}'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    alignment: WrapAlignment.end,
                    children: [
                      AppSecondaryButton(
                        label: l.leaveViewEmployeeLeave,
                        size: AppButtonSize.small,
                        onPressed: () => context.push(
                          AppRoutes.leaveEmployee(row.employeeId),
                        ),
                      ),
                      if (canAdjust)
                        AppSecondaryButton(
                          label: l.leaveAdjustBalance,
                          size: AppButtonSize.small,
                          onPressed: () => _adjust(context, row),
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

  Future<void> _adjust(BuildContext context, LeaveBalanceRow row) async {
    final bloc = context.read<LeaveBalanceTableBloc>();
    final changed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _AdjustDialog(
        repository: bloc.repository,
        account: bloc.context,
        row: row,
      ),
    );
    if (changed == true) {
      bloc.add(const LeaveBalanceTableStarted());
      if (context.mounted) {
        AppFeedback.showMessage(context, message: (l) => l.cfgSaved);
      }
    }
  }
}

class _AdjustDialog extends StatefulWidget {
  const _AdjustDialog({
    required this.repository,
    required this.account,
    required this.row,
  });
  final LeaveRepository repository;
  final AuthContext account;
  final LeaveBalanceRow row;
  @override
  State<_AdjustDialog> createState() => _AdjustDialogState();
}

class _AdjustDialogState extends State<_AdjustDialog> {
  bool _add = true;
  double _days = 1;
  final _reason = TextEditingController();
  bool _saving = false;
  Failure? _failure;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final preview = _add
        ? widget.row.available + _days
        : widget.row.available - _days;
    return AlertDialog(
      title: Text(l.leaveAdjustBalance),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              leaveDepartmentType(
                widget.row.employeeName,
                widget.row.leaveTypeName,
              ),
              style: AppTypography.of(context).bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            AppInlineStats(
              stats: [
                (
                  label: l.leaveCurrentAvailable,
                  value: '${widget.row.available}',
                ),
                (label: l.leavePreviewNewAvailable, value: '$preview'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppSwitchField(
              label: _add ? l.leaveAdjustAdd : l.leaveAdjustRemove,
              value: _add,
              onChanged: _saving ? null : (v) => setState(() => _add = v),
            ),
            AppNumberField(
              label: l.leaveAdjustQuantity,
              initialValue: _days,
              enabled: !_saving,
              suffix: l.days,
              onChanged: (v) => setState(() => _days = v.value ?? 0),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: l.leaveAdjustReason,
              controller: _reason,
              enabled: !_saving,
            ),
            if (_failure != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                configurationFailure(_failure!, l),
                style: TextStyle(color: AppColors.danger, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        AppTextButton(
          label: l.cancel,
          onPressed: _saving ? null : () => Navigator.pop(context, false),
        ),
        AppPrimaryButton(
          label: l.confirm,
          loading: _saving,
          onPressed: _saving ? null : _submit,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_days <= 0 || _reason.text.trim().isEmpty) {
      setState(() => _failure = const Failure(code: 'leaveInvalidQuantity'));
      return;
    }
    setState(() {
      _saving = true;
      _failure = null;
    });
    final result = await widget.repository.adjustBalance(
      widget.account,
      LeaveBalanceAdjustment(
        employeeId: widget.row.employeeId,
        leaveTypeId: widget.row.leaveTypeId,
        add: _add,
        quantityDays: _days,
        effectiveDate: widget.repository.companyToday(widget.account),
        reason: _reason.text.trim(),
      ),
    );
    if (!mounted) return;
    if (result is Failed<void>) {
      setState(() {
        _saving = false;
        _failure = result.failure;
      });
      return;
    }
    Navigator.pop(context, true);
  }
}
