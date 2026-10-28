import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift.dart';
import 'package:modular_erp/modules/hr/employee_shifts/presentation/employee_shifts_cubit.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class EmployeeShiftsPage extends StatefulWidget {
  const EmployeeShiftsPage({super.key, required this.cubit});
  final EmployeeShiftsCubit cubit;

  @override
  State<EmployeeShiftsPage> createState() => _EmployeeShiftsPageState();
}

class _EmployeeShiftsPageState extends State<EmployeeShiftsPage> {
  List<ShiftOption> employees = const [];
  List<ShiftOption> shifts = const [];
  bool loadingOptions = true;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final employeesResult = await widget.cubit.api.employees();
    final shiftsResult = await widget.cubit.api.shifts();
    if (!mounted) return;
    setState(() {
      if (employeesResult is Success<List<ShiftOption>>) {
        employees = employeesResult.value;
      }
      if (shiftsResult is Success<List<ShiftOption>>) {
        shifts = shiftsResult.value;
      }
      loadingOptions = false;
    });
    await widget.cubit.load();
  }

  bool _can(AuthContext? account, AppPermission permission) =>
      account != null &&
      PermissionChecker(account.user.permissions).can(permission);

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: widget.cubit,
    child: BlocBuilder<AuthBloc, AuthState>(
      builder: (context, auth) {
        final canView = _can(auth.context, AppPermission.shiftView);
        final canManage = _can(auth.context, AppPermission.shiftManage);
        if (!canView && !canManage) {
          return AppPage(
            header: AppPageHeader(title: context.l10n.employeeShiftsTitle),
            child: const AppPermissionDeniedState(),
          );
        }
        return BlocBuilder<EmployeeShiftsCubit, EmployeeShiftsState>(
          builder: (context, state) {
            final l = context.l10n;
            final cubit = context.read<EmployeeShiftsCubit>();
            return AppPage(
              header: AppPageHeader(
                title: l.employeeShiftsTitle,
                actions: [
                  if (canManage)
                    AppPrimaryButton(
                      label: l.employeeShiftAdd,
                      onPressed: loadingOptions
                          ? null
                          : () => _create(context, cubit),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.loading)
                    const AppLoadingState()
                  else if (state.failure != null)
                    AppErrorState(
                      message:
                          state.failure!.serverMessage ?? l.failureRequest,
                      onRetry: cubit.load,
                    )
                  else if (state.items.isEmpty)
                    AppEmptyState(
                      title: l.noRecords,
                      message: l.noRecords,
                      icon: Icons.event_available_outlined,
                    )
                  else
                    AppCollectionSurface(
                      child: AppDataTable(
                        columns: [
                          DataColumn(label: Text(l.employeeShiftEmployee)),
                          DataColumn(label: Text(l.employeeShiftShift)),
                          DataColumn(label: Text(l.employeeShiftFrom)),
                          DataColumn(label: Text(l.employeeShiftTo)),
                          DataColumn(label: Text(l.status)),
                          DataColumn(label: Text(l.actions)),
                        ],
                        rows: [
                          for (final item in state.items)
                            DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    item.employeeName ??
                                        item.employeeCode ??
                                        '${item.employeeId}',
                                  ),
                                ),
                                DataCell(Text(item.shiftName ?? '')),
                                DataCell(Text(item.fromDate)),
                                DataCell(Text(item.toDate)),
                                DataCell(
                                  AppStatusBadge(
                                    label: item.isActive
                                        ? l.active
                                        : l.inactive,
                                    status: item.isActive
                                        ? AppStatus.success
                                        : AppStatus.neutral,
                                    isPill: true,
                                  ),
                                ),
                                DataCell(
                                  canManage && item.isActive
                                      ? AppTextButton(
                                          label: l.employeeShiftRemove,
                                          onPressed: () async {
                                            final failure = await cubit
                                                .deactivate(item.id);
                                            if (failure != null &&
                                                context.mounted) {
                                              AppFeedback.showMessage(
                                                context,
                                                message: (l) =>
                                                    failure.serverMessage ??
                                                    l.failureRequest,
                                              );
                                            }
                                          },
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    ),
  );

  Future<void> _create(
    BuildContext context,
    EmployeeShiftsCubit cubit,
  ) async {
    if (employees.isEmpty || shifts.isEmpty) return;
    final draft = await AppDialog.show<EmployeeShiftDraft>(
      context,
      (dialogContext) => _AssignmentEditor(
        employees: employees,
        shifts: shifts,
        title: dialogContext.l10n.employeeShiftAdd,
      ),
    );
    if (draft == null) return;
    final failure = await cubit.create(draft);
    if (failure != null && context.mounted) {
      AppFeedback.showMessage(
        context,
        message: (l) => failure.serverMessage ?? l.failureRequest,
      );
    }
  }
}

class _AssignmentEditor extends StatefulWidget {
  const _AssignmentEditor({
    required this.employees,
    required this.shifts,
    required this.title,
  });
  final List<ShiftOption> employees, shifts;
  final String title;

  @override
  State<_AssignmentEditor> createState() => _AssignmentEditorState();
}

class _AssignmentEditorState extends State<_AssignmentEditor> {
  int? employeeId;
  int? shiftId;
  final _from = TextEditingController();
  final _to = TextEditingController();
  final _zone = TextEditingController();
  Map<String, String> _errors = const {};

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _zone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppDialog(
      title: widget.title,
      actions: [
        AppTextButton(
          label: l.cancel,
          onPressed: () => Navigator.pop(context),
        ),
        AppPrimaryButton(
          label: l.save,
          onPressed: () {
            final draft = EmployeeShiftDraft(
              employeeId: employeeId,
              shiftId: shiftId,
              fromDate: _from.text.trim(),
              toDate: _to.text.trim(),
              timeZoneId: _zone.text.trim().isEmpty ? null : _zone.text.trim(),
            );
            final errors = draft.validate();
            if (errors.isNotEmpty) {
              setState(() => _errors = errors);
              return;
            }
            Navigator.pop(context, draft);
          },
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSelectField<int>(
              label: l.employeeShiftEmployee,
              required: true,
              value: employeeId,
              options: [
                for (final item in widget.employees)
                  AppSelectOption(item.id, item.name),
              ],
              errorText: _errors['employeeId'],
              onChanged: (value) => setState(() => employeeId = value),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSelectField<int>(
              label: l.employeeShiftShift,
              required: true,
              value: shiftId,
              options: [
                for (final item in widget.shifts)
                  AppSelectOption(item.id, item.name),
              ],
              errorText: _errors['shiftId'],
              onChanged: (value) => setState(() => shiftId = value),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.employeeShiftFrom,
              controller: _from,
              errorText: _errors['fromDate'],
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.employeeShiftTo,
              controller: _to,
              errorText: _errors['toDate'],
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.employeeShiftTimezone,
              controller: _zone,
            ),
          ],
        ),
      ),
    );
  }
}
