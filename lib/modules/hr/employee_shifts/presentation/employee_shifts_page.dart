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
  List<String> timeZones = const [];
  bool loadingOptions = true;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final employeesResult = await widget.cubit.api.employees();
    final shiftsResult = await widget.cubit.api.shifts();
    final zonesResult = await widget.cubit.api.timeZones();
    if (!mounted) return;
    setState(() {
      if (employeesResult is Success<List<ShiftOption>>) {
        employees = employeesResult.value;
      }
      if (shiftsResult is Success<List<ShiftOption>>) {
        shifts = shiftsResult.value;
      }
      if (zonesResult is Success<List<String>>) {
        timeZones = zonesResult.value;
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
                          : () => _openEditor(context, cubit),
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
                      message: state.failure!.serverMessage ?? l.failureRequest,
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
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AppTextButton(
                                              label: l.edit,
                                              onPressed: () => _openEditor(
                                                context,
                                                cubit,
                                                initial: item,
                                              ),
                                            ),
                                            AppTextButton(
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
                                            ),
                                          ],
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

  Future<void> _openEditor(
    BuildContext context,
    EmployeeShiftsCubit cubit, {
    EmployeeShift? initial,
  }) async {
    if (employees.isEmpty || shifts.isEmpty) return;
    final saved = await AppDialog.show<bool>(
      context,
      (dialogContext) => _AssignmentEditor(
        employees: employees,
        shifts: shifts,
        timeZones: timeZones,
        initial: initial,
        title: initial == null
            ? dialogContext.l10n.employeeShiftAdd
            : dialogContext.l10n.employeeShiftEdit,
        onSave: (draft) => initial == null
            ? cubit.create(draft)
            : cubit.update(initial.id, draft),
      ),
    );
    if (saved == true && context.mounted) {
      AppFeedback.showMessage(context, message: (l) => l.cfgSaved);
    }
  }
}

class _AssignmentEditor extends StatefulWidget {
  const _AssignmentEditor({
    required this.employees,
    required this.shifts,
    required this.timeZones,
    required this.title,
    required this.onSave,
    this.initial,
  });
  final List<ShiftOption> employees, shifts;
  final List<String> timeZones;
  final String title;
  final EmployeeShift? initial;
  final Future<Failure?> Function(EmployeeShiftDraft) onSave;

  @override
  State<_AssignmentEditor> createState() => _AssignmentEditorState();
}

class _AssignmentEditorState extends State<_AssignmentEditor> {
  late int? employeeId = widget.initial?.employeeId;
  late int? shiftId = widget.initial?.shiftId;
  late final _from = TextEditingController(text: widget.initial?.fromDate);
  late final _to = TextEditingController(text: widget.initial?.toDate);
  late final _zone = TextEditingController(text: widget.initial?.timeZoneId);
  Map<String, String> _errors = const {};
  bool _saving = false;
  String? _generalError;

  bool get _editing => widget.initial != null;

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _zone.dispose();
    super.dispose();
  }

  String? _errorText(String field) {
    final value = _errors[field];
    if (value == null) return null;
    if (value == 'required') return context.l10n.fieldRequired;
    if (value == 'range') return context.l10n.employeeShiftDateRange;
    return value;
  }

  Future<void> _submit() async {
    final draft = EmployeeShiftDraft(
      employeeId: employeeId,
      shiftId: shiftId,
      fromDate: _from.text.trim(),
      toDate: _to.text.trim(),
      timeZoneId: _zone.text.trim().isEmpty ? null : _zone.text.trim(),
    );
    final local = draft.validate();
    if (local.isNotEmpty) {
      setState(() => _errors = local);
      return;
    }
    setState(() {
      _saving = true;
      _errors = const {};
      _generalError = null;
    });
    final failure = await widget.onSave(draft);
    if (!mounted) return;
    if (failure == null) {
      Navigator.pop(context, true);
      return;
    }
    final mapped = mapEmployeeShiftError(failure);
    setState(() {
      _saving = false;
      if (mapped.isNotEmpty) {
        _errors = mapped;
      } else {
        _generalError = failure.serverMessage ?? context.l10n.failureRequest;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppDialog(
      title: widget.title,
      actions: [
        AppTextButton(
          label: l.cancel,
          onPressed: _saving ? null : () => Navigator.pop(context),
        ),
        AppPrimaryButton(
          label: l.save,
          loading: _saving,
          onPressed: _saving ? null : _submit,
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_generalError != null) ...[
              Text(
                _generalError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            AppSelectField<int>(
              label: l.employeeShiftEmployee,
              required: true,
              enabled: !_saving && !_editing,
              value: employeeId,
              options: [
                for (final item in widget.employees)
                  AppSelectOption(item.id, item.name),
              ],
              errorText: _errorText('employeeId'),
              onChanged: (value) => setState(() => employeeId = value),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSelectField<int>(
              label: l.employeeShiftShift,
              required: true,
              enabled: !_saving,
              value: shiftId,
              options: [
                for (final item in widget.shifts)
                  AppSelectOption(item.id, item.name),
              ],
              errorText: _errorText('shiftId'),
              onChanged: (value) => setState(() => shiftId = value),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.employeeShiftFrom,
              controller: _from,
              enabled: !_saving,
              errorText: _errorText('fromDate'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.employeeShiftTo,
              controller: _to,
              enabled: !_saving,
              errorText: _errorText('toDate'),
            ),
            const SizedBox(height: AppSpacing.md),
            if (widget.timeZones.isEmpty)
              AppTextField(
                label: l.employeeShiftTimezone,
                controller: _zone,
                enabled: !_saving,
                errorText: _errorText('timeZoneId'),
              )
            else
              AppSelectField<String>(
                label: l.employeeShiftTimezone,
                enabled: !_saving,
                value: _zone.text.isEmpty ? null : _zone.text,
                options: [
                  for (final zone in widget.timeZones)
                    AppSelectOption(zone, zone),
                ],
                errorText: _errorText('timeZoneId'),
                onChanged: (value) => setState(() {
                  _zone.text = value ?? '';
                }),
              ),
          ],
        ),
      ),
    );
  }
}
