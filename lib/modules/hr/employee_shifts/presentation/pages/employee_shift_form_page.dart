import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift.dart';
import 'package:modular_erp/modules/hr/employee_shifts/presentation/bloc/employee_shift_form_bloc.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_repository.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift_repository.dart';
import 'package:modular_erp/shared/navigation/form_navigation_guard.dart';
import 'package:modular_erp/shared/presentation/configuration_form_binding.dart';
import 'package:modular_erp/shared/presentation/configuration_layouts.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';

class EmployeeShiftFormPage extends StatefulWidget {
  const EmployeeShiftFormPage({
    super.key,
    required this.guard,
    required this.employeeRepository,
    required this.shiftRepository,
  });

  final FormNavigationGuard guard;
  final EmployeeRepository? employeeRepository;
  final ShiftRepository? shiftRepository;

  @override
  State<EmployeeShiftFormPage> createState() => _EmployeeShiftFormPageState();
}

class _EmployeeShiftFormPageState extends State<EmployeeShiftFormPage> {
  late Future<Result<_EmployeeShiftLookups>> _lookups;

  @override
  void initState() {
    super.initState();
    _lookups = _load();
  }

  Future<Result<_EmployeeShiftLookups>> _load() async {
    final employees = widget.employeeRepository;
    final shifts = widget.shiftRepository;
    if (employees == null || shifts == null) {
      return const Failed(
        Failure(code: 'notConfigured', kind: FailureKind.notConfigured),
      );
    }
    final account = context.read<EmployeeShiftFormBloc>().context;
    final employeeResult = await employees.searchAssignableCompanyEmployees(
      account,
      limit: 100,
    );
    if (employeeResult is Failed<List<Employee>>) {
      return Failed(employeeResult.failure);
    }
    Result<List<Shift>> shiftResult;
    try {
      final page = await shifts.watchList(account, pageSize: 100).first;
      shiftResult = switch (page) {
        Success<ConfigurationPageData<Shift>>(:final value) => Success(
          value.items.map((item) => item.record).toList(growable: false),
        ),
        Failed<ConfigurationPageData<Shift>>(:final failure) => Failed(failure),
      };
    } on Object {
      shiftResult = const Failed(Failure(code: 'databaseFailure'));
    }
    if (shiftResult is Failed<List<Shift>>) {
      return Failed(shiftResult.failure);
    }
    return Success(
      _EmployeeShiftLookups(
        employees: (employeeResult as Success<List<Employee>>).value,
        shifts: (shiftResult as Success<List<Shift>>).value,
      ),
    );
  }

  void _retryLookups() {
    setState(() => _lookups = _load());
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<EmployeeShiftFormBloc, EmployeeShiftFormState>(
        listener: (c, s) {
          if (s.savedId != null) {
            widget.guard.dirty = false;
            widget.guard.saving = false;
            AppFeedback.showMessage(c, message: (l) => l.cfgSaved);
            c.go(
              c.read<EmployeeShiftFormBloc>().context.user.permissions.contains(
                    AppPermission.shiftView,
                  )
                  ? AppRoutes.employeeShiftsDetails(s.savedId!)
                  : AppRoutes.dashboard,
            );
          }
        },
        builder: (c, s) {
          final l = c.l10n, bloc = c.read<EmployeeShiftFormBloc>(), d = s.draft;
          void change(EmployeeShiftDraft Function(EmployeeShiftDraft) update) =>
              bloc.add(RecordDraftChanged<EmployeeShiftDraft>(update));
          String? error(String field) => s.fieldErrors[field] == null
              ? null
              : configurationFailure(Failure(code: s.fieldErrors[field]!), l);
          return ConfigurationFormBinding(
            guard: widget.guard,
            account: bloc.context,
            dirty: s.dirty,
            saving: s.saving,
            child: ConfigurationFormLayout(
              title: [
                l.cfgEmployeeShifts,
                bloc.id == null ? l.cfgNew : l.cfgEdit,
              ].join(' · '),
              loading: s.loading,
              ready: s.ready,
              saving: s.saving,
              failure: s.failure,
              onSave: () {
                bloc.add(const RecordSubmitted<EmployeeShiftDraft>());
              },
              onCancel: () => c.go(
                bloc.context.user.permissions.contains(AppPermission.shiftView)
                    ? AppRoutes.employeeShifts
                    : AppRoutes.dashboard,
              ),
              onRetry: () => bloc.add(
                s.validationRequested
                    ? const RecordSubmitted<EmployeeShiftDraft>()
                    : const RecordFormInitialized<EmployeeShiftDraft>(),
              ),
              content: FutureBuilder<Result<_EmployeeShiftLookups>>(
                future: _lookups,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const AppLoadingState();
                  }
                  final result = snapshot.data;
                  if (result is Failed<_EmployeeShiftLookups>) {
                    return AppErrorState(
                      message: configurationFailure(result.failure, l),
                      onRetry: _retryLookups,
                    );
                  }
                  final lookups =
                      (result as Success<_EmployeeShiftLookups>).value;
                  final employeeLabel = _employeeLabel(lookups, d);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppFormSection(
                        title: l.cfgEmployeeShiftAssignment,
                        child: AppFormGrid(
                          children: [
                            if (bloc.id == null)
                              AppSelectField<int>(
                                label: l.cfgEmployeeShiftEmployee,
                                value: d.employeeId,
                                required: true,
                                enabled: !s.saving,
                                errorText: error('employeeId'),
                                options: [
                                  for (final employee in lookups.employees)
                                    if (_intId(employee.id) != null)
                                      AppSelectOption(
                                        _intId(employee.id)!,
                                        employee.displayName,
                                        subtitle: employee.employeeCode,
                                      ),
                                ],
                                onChanged: (v) =>
                                    change((d) => d.copyWith(employeeId: v)),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppDetailField(
                                    label: l.cfgEmployeeShiftEmployee,
                                    value: employeeLabel,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    l.cfgEmployeeShiftImmutableEmployee,
                                    style: AppTypography.of(c).caption,
                                  ),
                                ],
                              ),
                            AppSelectField<int>(
                              label: l.cfgEmployeeShiftShift,
                              value: d.shiftId,
                              required: true,
                              enabled: !s.saving,
                              errorText: error('shiftId'),
                              options: [
                                for (final shift in lookups.shifts)
                                  if (_intId(shift.id) != null)
                                    AppSelectOption(
                                      _intId(shift.id)!,
                                      shift.name,
                                      subtitle:
                                          shift.status ==
                                              ConfigurationStatus.inactive
                                          ? l.cfgInactiveAssignment
                                          : null,
                                      enabled:
                                          shift.status ==
                                          ConfigurationStatus.active,
                                    ),
                              ],
                              onChanged: (v) =>
                                  change((d) => d.copyWith(shiftId: v)),
                            ),
                            AppTextField(
                              label: l.cfgBranchTimeZone,
                              initialValue: d.timeZoneId,
                              enabled: !s.saving,
                              helperText: l.cfgEmployeeShiftTimeZoneHelp,
                              errorText: error('timeZoneId'),
                              onChanged: (v) => change(
                                (d) => d.copyWith(
                                  timeZoneId: v,
                                  clearTimeZoneId: v.trim().isEmpty,
                                ),
                              ),
                            ),
                            AppDateField(
                              label: l.cfgEmployeeShiftFrom,
                              value: _parseDate(d.fromDate),
                              required: true,
                              enabled: !s.saving,
                              errorText: error('fromDate'),
                              onChanged: (v) =>
                                  change((d) => d.copyWith(fromDate: _iso(v))),
                            ),
                            AppDateField(
                              label: l.cfgEmployeeShiftTo,
                              value: _parseDate(d.toDate),
                              required: true,
                              enabled: !s.saving,
                              errorText: error('toDate'),
                              onChanged: (v) =>
                                  change((d) => d.copyWith(toDate: _iso(v))),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  );
                },
              ),
            ),
          );
        },
      );

  static String _employeeLabel(
    _EmployeeShiftLookups lookups,
    EmployeeShiftDraft draft,
  ) {
    final employee = lookups.employees
        .where((item) => item.id == draft.employeeId?.toString())
        .firstOrNull;
    final name = draft.employeeName ?? employee?.displayName;
    final code = draft.employeeCode ?? employee?.employeeCode;
    if (name == null || name.trim().isEmpty) {
      return draft.employeeId?.toString() ?? '';
    }
    return code == null || code.trim().isEmpty ? name : '$name · $code';
  }

  static int? _intId(String value) => int.tryParse(value.trim());

  static DateTime? _parseDate(String? value) =>
      value == null ? null : DateTime.tryParse(value.trim());

  static String _iso(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

class _EmployeeShiftLookups {
  const _EmployeeShiftLookups({required this.employees, required this.shifts});

  final List<Employee> employees;
  final List<Shift> shifts;
}
