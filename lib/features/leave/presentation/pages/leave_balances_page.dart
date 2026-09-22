import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/security/app_permission.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/presentation/configuration_localization.dart';
import '../../../auth/domain/entities/auth_context.dart';
import '../../../employees/domain/employee.dart';
import '../../../employees/domain/employee_repository.dart';
import '../../domain/leave_models.dart';
import '../../domain/leave_repository.dart';
import '../bloc/leave_blocs.dart';
import '../leave_localization.dart';

class LeaveBalancesPage extends StatefulWidget {
  const LeaveBalancesPage({
    super.key,
    required this.repository,
    required this.account,
    this.employeeRepository,
  });
  final LeaveRepository repository;
  final AuthContext account;
  final EmployeeRepository? employeeRepository;
  @override
  State<LeaveBalancesPage> createState() => _LeaveBalancesPageState();
}

class _LeaveBalancesPageState extends State<LeaveBalancesPage> {
  String? _employeeId;
  String _employeeLabel = '';

  bool get _canViewAll => PermissionChecker(
    widget.account.user.permissions,
  ).can(AppPermission.leaveBalanceViewAll);

  @override
  void initState() {
    super.initState();
    _employeeId = widget.account.employeeReference?.id;
    _employeeLabel = widget.account.user.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final repository = widget.repository;
    final account = widget.account;
    return AppPage(
      header: AppPageHeader(
        title: l.leaveBalancesTitle,
        subtitle: _employeeLabel.isEmpty ? null : _employeeLabel,
        actions: [
          if (_canViewAll && widget.employeeRepository != null)
            AppSecondaryButton(
              label: l.leaveSelectEmployee,
              icon: Icons.person_search_outlined,
              onPressed: () => _pickEmployee(context),
            ),
        ],
      ),
      child: _employeeId == null
          ? AppEmptyState(title: l.leaveNoEmployee, message: l.leaveNoEmployee)
          : BlocProvider(
              key: ValueKey(_employeeId),
              create: (_) =>
                  LeaveBalancesCubit(repository, account, _employeeId!),
              child: _BalancesBody(
                repository: repository,
                account: account,
                employeeId: _employeeId!,
              ),
            ),
    );
  }

  Future<void> _pickEmployee(BuildContext context) async {
    final repository = widget.employeeRepository;
    if (repository == null) return;
    final selected = await showModalBottomSheet<Employee>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: 420,
          child: StreamBuilder<Result<EmployeePageData>>(
            stream: repository.watchEmployees(widget.account, pageSize: 100),
            builder: (c, snapshot) {
              final data = snapshot.data;
              final items = data is Success<EmployeePageData>
                  ? data.value.employees
                  : const <Employee>[];
              if (items.isEmpty) {
                return Center(child: Text(c.l10n.cfgEmpty));
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (c, index) {
                  final employee = items[index];
                  return ListTile(
                    title: Text(employee.displayName),
                    subtitle: Text(employee.employeeCode),
                    onTap: () => Navigator.of(sheetContext).pop(employee),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
    if (selected != null) {
      setState(() {
        _employeeId = selected.id;
        _employeeLabel = selected.displayName;
      });
    }
  }
}

class _BalancesBody extends StatelessWidget {
  const _BalancesBody({
    required this.repository,
    required this.account,
    required this.employeeId,
  });
  final LeaveRepository repository;
  final AuthContext account;
  final String employeeId;
  @override
  Widget build(BuildContext context) =>
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
            return AppEmptyState(
              title: c.l10n.leaveNoBalance,
              message: c.l10n.leaveNoBalance,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final balance in s.balances)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _BalanceCard(
                    balance: balance,
                    repository: repository,
                    account: account,
                    employeeId: employeeId,
                  ),
                ),
            ],
          );
        },
      );
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.repository,
    required this.account,
    required this.employeeId,
  });
  final LeaveBalanceSummary balance;
  final LeaveRepository repository;
  final AuthContext account;
  final String employeeId;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final canAdjust = PermissionChecker(
      account.user.permissions,
    ).can(AppPermission.leaveBalanceAdjust);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      balance.leaveTypeName,
                      style: AppTypography.of(context).cardTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      leaveCompensationLabel(balance.compensation, l),
                      style: AppTypography.of(
                        context,
                      ).caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              if (canAdjust)
                AppSecondaryButton(
                  label: l.leaveAdjustBalance,
                  size: AppButtonSize.small,
                  onPressed: () => _adjust(context),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppInlineStats(
            stats: [
              (label: l.leaveEntitlement, value: '${balance.entitlement}'),
              (label: l.leaveUsed, value: '${balance.used}'),
              (label: l.leavePendingBalance, value: '${balance.pending}'),
              (label: l.leaveAvailable, value: '${balance.available}'),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _adjust(BuildContext context) async {
    final l = context.l10n;
    final controller = TextEditingController();
    final reasonController = TextEditingController();
    var add = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(l.leaveAdjustBalance),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSwitchField(
                label: l.leaveAdjustAdd,
                value: add,
                onChanged: (v) => setState(() => add = v),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l.leaveAdjustQuantity,
                controller: controller,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l.leaveAdjustReason,
                controller: reasonController,
              ),
            ],
          ),
          actions: [
            AppTextButton(
              label: l.cancel,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            AppPrimaryButton(
              label: l.confirm,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    final quantity = double.tryParse(controller.text.trim());
    if (quantity == null || quantity <= 0) return;
    final result = await repository.adjustBalance(
      account,
      LeaveBalanceAdjustment(
        employeeId: employeeId,
        leaveTypeId: balance.leaveTypeId,
        add: add,
        quantityDays: quantity,
        effectiveDate: DateTime.now().toUtc(),
        reason: reasonController.text.trim(),
      ),
    );
    if (result is Failed<void> && context.mounted) {
      AppFeedback.showMessage(
        context,
        message: (l) => configurationFailure(result.failure, l),
      );
    } else if (context.mounted) {
      context.read<LeaveBalancesCubit>().load();
      AppFeedback.showMessage(context, message: (l) => l.cfgSaved);
    }
    controller.dispose();
    reasonController.dispose();
  }
}
