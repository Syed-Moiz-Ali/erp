import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/employees/live/data/dto/live_employee_dtos.dart';
import 'package:modular_erp/modules/hr/employees/live/domain/live_employee.dart';
import 'package:modular_erp/modules/hr/employees/live/presentation/bloc/live_employee_cubit.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class LiveEmployeesPage extends StatelessWidget {
  const LiveEmployeesPage({super.key, required this.cubit});
  final LiveEmployeeCubit cubit;

  @override
  Widget build(BuildContext context) =>
      BlocProvider.value(value: cubit..start(), child: const _EmployeesBody());
}

class _EmployeesBody extends StatelessWidget {
  const _EmployeesBody();

  bool _can(AuthContext? account, AppPermission permission) =>
      account != null &&
      PermissionChecker(account.user.permissions).can(permission);

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthBloc, AuthState>(
    builder: (context, auth) {
      final account = auth.context;
      final canView =
          _can(account, AppPermission.employeeViewAll) ||
          _can(account, AppPermission.employeeViewTeam) ||
          _can(account, AppPermission.employeeViewSelf);
      if (!canView) {
        return AppPage(
          header: AppPageHeader(title: context.l10n.employees),
          child: AppPermissionDeniedState(
            onGoBack: () => Navigator.of(context).maybePop(),
          ),
        );
      }
      final canManage =
          _can(account, AppPermission.employeeCreate) ||
          _can(account, AppPermission.employeeUpdate);
      final canDeactivate = _can(account, AppPermission.employeeDeactivate);
      final canManageLogin = _can(account, AppPermission.userManage);
      return BlocBuilder<LiveEmployeeCubit, LiveEmployeeState>(
        builder: (context, state) {
          final l = context.l10n;
          final cubit = context.read<LiveEmployeeCubit>();
          return AppPage(
            header: AppPageHeader(
              title: l.employees,
              actions: [
                if (_can(account, AppPermission.employeeCreate))
                  AppPrimaryButton(
                    label: l.empAdd,
                    onPressed: () => _edit(
                      context,
                      cubit,
                      null,
                      canManageLogin: canManageLogin,
                    ),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCollectionToolbar(
                  search: AppSearchField(
                    label: l.search,
                    hint: l.search,
                    onChanged: cubit.searchChanged,
                  ),
                  secondary: [
                    AppFilterBar(
                      children: [
                        AppFilterChip(
                          label: l.accessFilterAll,
                          selected: state.statusId == null,
                          onSelected: (_) => cubit.statusChanged(null),
                        ),
                        AppFilterChip(
                          label: l.active,
                          selected: state.statusId == 1,
                          onSelected: (_) => cubit.statusChanged(1),
                        ),
                        AppFilterChip(
                          label: l.inactive,
                          selected: state.statusId == 2,
                          onSelected: (_) => cubit.statusChanged(2),
                        ),
                      ],
                    ),
                  ],
                  resultCount: AppResultCount(
                    filtered: state.items.length,
                    total: state.totalItems,
                    label: state.totalItems.toString(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
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
                    icon: Icons.groups_outlined,
                  )
                else if (AppBreakpoints.of(context) == AppSize.compact)
                  Column(
                    children: [
                      for (final employee in state.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppMobileRecordCard(
                            title: employee.name,
                            subtitle: employee.code,
                            tertiary: employee.designation,
                            status: employee.isActive
                                ? AppStatus.success
                                : AppStatus.neutral,
                            statusLabel: employee.isActive
                                ? l.active
                                : l.inactive,
                            trailing: _actions(
                              context,
                              cubit,
                              employee,
                              canManage: canManage,
                              canDeactivate: canDeactivate,
                              canManageLogin: canManageLogin,
                            ),
                          ),
                        ),
                    ],
                  )
                else
                  AppCollectionSurface(
                    child: AppDataTable(
                      columns: [
                        DataColumn(label: Text(l.empCode)),
                        DataColumn(label: Text(l.cfgName)),
                        DataColumn(label: Text(l.empDepartment)),
                        DataColumn(label: Text(l.status)),
                        DataColumn(label: Text(l.actions)),
                      ],
                      rows: [
                        for (final employee in state.items)
                          DataRow(
                            cells: [
                              DataCell(Text(employee.code)),
                              DataCell(Text(employee.name)),
                              DataCell(Text(employee.departmentName ?? '')),
                              DataCell(
                                AppStatusBadge(
                                  label: employee.isActive
                                      ? l.active
                                      : l.inactive,
                                  status: employee.isActive
                                      ? AppStatus.success
                                      : AppStatus.neutral,
                                  isPill: true,
                                ),
                              ),
                              DataCell(
                                _actions(
                                  context,
                                  cubit,
                                  employee,
                                  canManage: canManage,
                                  canDeactivate: canDeactivate,
                                  canManageLogin: canManageLogin,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                if (state.totalPages > 1) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppPagination(
                    page: state.page - 1,
                    pageSize: state.pageSize,
                    total: state.totalItems,
                    onPageChanged: (page) => cubit.pageChanged(page + 1),
                  ),
                ],
              ],
            ),
          );
        },
      );
    },
  );

  Widget _actions(
    BuildContext context,
    LiveEmployeeCubit cubit,
    LiveEmployee employee, {
    required bool canManage,
    required bool canDeactivate,
    required bool canManageLogin,
  }) => AppActionMenu(
    tooltip: context.l10n.actions,
    actions: [
      AppMenuAction(
        label: (l) => l.empDetails,
        onPressed: () => _details(context, employee),
      ),
      if (canManage)
        AppMenuAction(
          label: (l) => l.empEdit,
          onPressed: () =>
              _edit(context, cubit, employee, canManageLogin: canManageLogin),
        ),
      if (canManage && !employee.loginEnabled && canManageLogin)
        AppMenuAction(
          label: (l) => l.empEnableLogin,
          onPressed: () => _edit(
            context,
            cubit,
            employee,
            canManageLogin: canManageLogin,
            enableLogin: true,
          ),
        ),
      if (canDeactivate)
        AppMenuAction(
          label: (l) => employee.isActive ? l.inactive : l.active,
          onPressed: () async {
            final failure = await cubit.toggle(employee);
            if (failure != null && context.mounted) {
              AppFeedback.showMessage(
                context,
                message: (l) => failure.serverMessage ?? l.failureRequest,
              );
            }
          },
        ),
    ],
  );

  void _details(BuildContext context, LiveEmployee employee) {
    final l = context.l10n;
    AppDialog.show<void>(
      context,
      (dialogContext) => AppDialog(
        title: l.empDetails,
        actions: [
          AppTextButton(
            label: l.close,
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
        child: AppDetailsSection(
          title: employee.name,
          details: {
            l.empCode: employee.code,
            l.empBranch: employee.branchName ?? '',
            l.empDepartment: employee.departmentName ?? '',
            l.empNationality: employee.nationalityName ?? '',
            l.empDesignation: employee.designation ?? '',
            l.empJoiningDate: employee.joiningDate ?? '',
            l.email: employee.email ?? '',
            l.phone: employee.phone ?? '',
            l.status: employee.isActive ? l.active : l.inactive,
            l.empLogin: employee.loginEnabled ? l.active : l.inactive,
            l.empLoginId: employee.loginId ?? '',
          },
        ),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    LiveEmployeeCubit cubit,
    LiveEmployee? employee, {
    required bool canManageLogin,
    bool enableLogin = false,
  }) async {
    final lookups = cubit.state.lookups;
    if (lookups == null) return;
    final initial = employee == null
        ? LiveEmployeeDraft(
            branchId: lookups.branches.isEmpty
                ? null
                : lookups.branches.first.id,
            departmentId: lookups.departments.isEmpty
                ? null
                : lookups.departments.first.id,
            nationalityId: lookups.nationalities.isEmpty
                ? null
                : lookups.nationalities.first.id,
            statusId: 1,
            loginEnabled: false,
            loginBranchIds: lookups.branches.isEmpty
                ? const []
                : [lookups.branches.first.id],
          )
        : LiveEmployeeDto(employee.raw).toDraft();
    final saved = await AppDialog.show<bool>(
      context,
      (dialogContext) => _EmployeeEditor(
        lookups: lookups,
        initial: enableLogin ? _withLogin(initial, employee!) : initial,
        raw: employee?.raw ?? const {},
        title: employee == null
            ? dialogContext.l10n.empAdd
            : dialogContext.l10n.empEdit,
        canManageLogin: canManageLogin,
        onSave: (draft) => cubit.save(employee, draft),
      ),
    );
    if (saved == true && context.mounted) {
      AppFeedback.showMessage(context, message: (l) => l.cfgSaved);
    }
  }

  LiveEmployeeDraft _withLogin(
    LiveEmployeeDraft draft,
    LiveEmployee employee,
  ) => LiveEmployeeDraft(
    name: draft.name,
    branchId: draft.branchId,
    departmentId: draft.departmentId,
    nationalityId: draft.nationalityId,
    statusId: draft.statusId,
    designation: draft.designation,
    joiningDate: draft.joiningDate,
    email: draft.email,
    phone: draft.phone,
    basicSalary: draft.basicSalary,
    loginEnabled: true,
    loginId: employee.loginId ?? draft.email,
    loginMobile: employee.loginMobile ?? draft.phone,
    loginBranchIds: draft.loginBranchIds,
  );
}

class _EmployeeEditor extends StatefulWidget {
  const _EmployeeEditor({
    required this.lookups,
    required this.initial,
    required this.raw,
    required this.title,
    required this.canManageLogin,
    required this.onSave,
  });
  final LiveEmployeeLookups lookups;
  final LiveEmployeeDraft initial;
  final Map<String, dynamic> raw;
  final String title;
  final bool canManageLogin;
  final Future<Failure?> Function(LiveEmployeeDraft) onSave;

  @override
  State<_EmployeeEditor> createState() => _EmployeeEditorState();
}

class _EmployeeEditorState extends State<_EmployeeEditor> {
  late LiveEmployeeDraft _draft = widget.initial;
  late final _name = TextEditingController(text: _draft.name);
  late final _designation = TextEditingController(text: _draft.designation);
  late final _joining = TextEditingController(text: _draft.joiningDate ?? '');
  late final _dob = TextEditingController(text: _draft.dateOfBirth);
  late final _email = TextEditingController(text: _draft.email);
  late final _phone = TextEditingController(text: _draft.phone);
  late final _salary = TextEditingController(
    text: _draft.basicSalary == 0 ? '' : _draft.basicSalary.toString(),
  );
  late final _workingHours = TextEditingController(
    text: _draft.workingHours == 0 ? '' : _draft.workingHours.toString(),
  );
  late final _transportation = TextEditingController(
    text: _draft.transportation == 0 ? '' : _draft.transportation.toString(),
  );
  late final _accommodation = TextEditingController(
    text: _draft.accommodation == 0 ? '' : _draft.accommodation.toString(),
  );
  late final _loginId = TextEditingController(text: _draft.loginId);
  late final _loginMobile = TextEditingController(text: _draft.loginMobile);
  late final _password = TextEditingController();
  Map<String, String> _errors = const {};
  bool _saving = false;
  String? _generalError;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _designation,
      _joining,
      _dob,
      _email,
      _phone,
      _salary,
      _workingHours,
      _transportation,
      _accommodation,
      _loginId,
      _loginMobile,
      _password,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  List<AppSelectOption<int>> _options(List<Lookup> values) => [
    for (final item in values) AppSelectOption(item.id, item.name),
  ];

  String? _errorText(String field) {
    final value = _errors[field];
    if (value == null) return null;
    if (value == 'required') return context.l10n.fieldRequired;
    if (value == 'password') return context.l10n.authPasswordConstraints;
    return value;
  }

  double _number(TextEditingController controller) =>
      double.tryParse(controller.text.trim()) ?? 0;

  Future<void> _submit() async {
    final draft = LiveEmployeeDraft(
      name: _name.text,
      branchId: _draft.branchId,
      departmentId: _draft.departmentId,
      nationalityId: _draft.nationalityId,
      statusId: _draft.statusId,
      designation: _designation.text,
      joiningDate: _joining.text.trim().isEmpty ? null : _joining.text.trim(),
      dateOfBirth: _dob.text,
      maritalStatus: _draft.maritalStatus,
      employeeType: _draft.employeeType,
      gratuity: _draft.gratuity,
      email: _email.text,
      phone: _phone.text,
      basicSalary: _number(_salary),
      workingHours: _number(_workingHours),
      transportation: _number(_transportation),
      accommodation: _number(_accommodation),
      loginEnabled: _draft.loginEnabled,
      loginId: _loginId.text,
      loginMobile: _loginMobile.text,
      loginPassword: _password.text,
      loginBranchIds: _draft.loginBranchIds,
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
    final field = failure.field;
    setState(() {
      _saving = false;
      if (field != null) {
        _errors = {field: failure.serverMessage ?? failure.code};
      } else if (failure.code == 'USER_DUPLICATE_LOGINID') {
        _errors = {'login.loginId': failure.serverMessage ?? failure.code};
      } else if (failure.code == 'USER_DUPLICATE_MOBILE') {
        _errors = {'login.mobileNo': failure.serverMessage ?? failure.code};
      } else {
        _generalError = failure.serverMessage ?? context.l10n.failureRequest;
      }
    });
  }

  LiveEmployeeDraft _copy({
    int? branchId,
    int? departmentId,
    int? nationalityId,
    int? statusId,
    bool? loginEnabled,
    String? maritalStatus,
    String? employeeType,
    String? gratuity,
    List<int>? loginBranchIds,
  }) => LiveEmployeeDraft(
    name: _draft.name,
    branchId: branchId ?? _draft.branchId,
    departmentId: departmentId ?? _draft.departmentId,
    nationalityId: nationalityId ?? _draft.nationalityId,
    statusId: statusId ?? _draft.statusId,
    designation: _draft.designation,
    joiningDate: _draft.joiningDate,
    dateOfBirth: _draft.dateOfBirth,
    maritalStatus: maritalStatus ?? _draft.maritalStatus,
    employeeType: employeeType ?? _draft.employeeType,
    gratuity: gratuity ?? _draft.gratuity,
    email: _draft.email,
    phone: _draft.phone,
    basicSalary: _draft.basicSalary,
    workingHours: _draft.workingHours,
    transportation: _draft.transportation,
    accommodation: _draft.accommodation,
    loginEnabled: loginEnabled ?? _draft.loginEnabled,
    loginId: _draft.loginId,
    loginMobile: _draft.loginMobile,
    loginPassword: _draft.loginPassword,
    loginBranchIds: loginBranchIds ?? _draft.loginBranchIds,
  );

  List<MapEntry<String, Object?>> get _rawExtras {
    const known = {
      'employeeId',
      'employeeCode',
      'employeeName',
      'designation',
      'departmentId',
      'departmentName',
      'branchId',
      'branchName',
      'nationalityId',
      'nationalityName',
      'statusId',
      'statusName',
      'joiningDate',
      'dateOfBirth',
      'maritalStatus',
      'employeeType',
      'gratuity',
      'uaeContactNumber',
      'email',
      'workingHours',
      'basicSalary',
      'transportation',
      'accommodation',
      'login',
      'photoPath',
    };
    return [
      for (final entry in widget.raw.entries)
        if (!known.contains(entry.key)) entry,
    ];
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
            AppTextField(
              label: l.cfgName,
              controller: _name,
              required: true,
              enabled: !_saving,
              errorText: _errorText('employeeName'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSelectField<int>(
              label: l.empBranch,
              required: true,
              enabled: !_saving,
              value: _draft.branchId,
              errorText: _errorText('branchId'),
              options: _options(widget.lookups.branches),
              onChanged: (value) =>
                  setState(() => _draft = _copy(branchId: value)),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSelectField<int>(
              label: l.empDepartment,
              required: true,
              enabled: !_saving,
              value: _draft.departmentId,
              errorText: _errorText('departmentId'),
              options: _options(widget.lookups.departments),
              onChanged: (value) =>
                  setState(() => _draft = _copy(departmentId: value)),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSelectField<int>(
              label: l.empNationality,
              required: true,
              enabled: !_saving,
              value: _draft.nationalityId,
              errorText: _errorText('nationalityId'),
              options: _options(widget.lookups.nationalities),
              onChanged: (value) =>
                  setState(() => _draft = _copy(nationalityId: value)),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.empDesignation,
              controller: _designation,
              enabled: !_saving,
              errorText: _errorText('designation'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.empJoiningDate,
              controller: _joining,
              enabled: !_saving,
              errorText: _errorText('joiningDate'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.dateOfBirth,
              controller: _dob,
              enabled: !_saving,
              errorText: _errorText('dateOfBirth'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSelectField<String>(
              label: l.empMaritalStatus,
              enabled: !_saving,
              value: _draft.maritalStatus.isEmpty ? null : _draft.maritalStatus,
              errorText: _errorText('maritalStatus'),
              options: [
                for (final value in widget.lookups.maritalStatuses)
                  AppSelectOption(value, value),
              ],
              onChanged: (value) =>
                  setState(() => _draft = _copy(maritalStatus: value ?? '')),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSelectField<String>(
              label: l.empEmployeeType,
              enabled: !_saving,
              value: _draft.employeeType.isEmpty ? null : _draft.employeeType,
              errorText: _errorText('employeeType'),
              options: [
                for (final value in widget.lookups.employeeTypes)
                  AppSelectOption(value, value),
              ],
              onChanged: (value) =>
                  setState(() => _draft = _copy(employeeType: value ?? '')),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSelectField<String>(
              label: l.empGratuity,
              enabled: !_saving,
              value: _draft.gratuity.isEmpty ? null : _draft.gratuity,
              errorText: _errorText('gratuity'),
              options: [
                for (final value in widget.lookups.gratuityTypes)
                  AppSelectOption(value, value),
              ],
              onChanged: (value) =>
                  setState(() => _draft = _copy(gratuity: value ?? '')),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.email,
              controller: _email,
              enabled: !_saving,
              errorText: _errorText('email'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.phone,
              controller: _phone,
              enabled: !_saving,
              errorText: _errorText('uaeContactNumber'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.empBasicSalary,
              controller: _salary,
              enabled: !_saving,
              keyboardType: TextInputType.number,
              errorText: _errorText('basicSalary'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.empWorkingHours,
              controller: _workingHours,
              enabled: !_saving,
              keyboardType: TextInputType.number,
              errorText: _errorText('workingHours'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.empTransportation,
              controller: _transportation,
              enabled: !_saving,
              keyboardType: TextInputType.number,
              errorText: _errorText('transportation'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.empAccommodation,
              controller: _accommodation,
              enabled: !_saving,
              keyboardType: TextInputType.number,
              errorText: _errorText('accommodation'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSelectField<int>(
              label: l.status,
              enabled: !_saving,
              value: _draft.statusId,
              errorText: _errorText('statusId'),
              options: _options(widget.lookups.statuses),
              onChanged: (value) =>
                  setState(() => _draft = _copy(statusId: value)),
            ),
            if (_rawExtras.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              AppDetailsSection(
                title: l.detailsLabel,
                details: {
                  for (final entry in _rawExtras) entry.key: '${entry.value}',
                },
              ),
            ],
            if (widget.canManageLogin) ...[
              const SizedBox(height: AppSpacing.lg),
              AppBooleanSettingRow(
                label: l.empLogin,
                value: _draft.loginEnabled,
                onChanged: _saving
                    ? null
                    : (value) =>
                          setState(() => _draft = _copy(loginEnabled: value)),
              ),
              if (_draft.loginEnabled) ...[
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l.empLoginId,
                  controller: _loginId,
                  enabled: !_saving,
                  errorText: _errorText('login.loginId'),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l.empLoginMobile,
                  controller: _loginMobile,
                  enabled: !_saving,
                  errorText: _errorText('login.mobileNo'),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l.empLoginPassword,
                  controller: _password,
                  enabled: !_saving,
                  errorText: _errorText('login.password'),
                ),
                const SizedBox(height: AppSpacing.md),
                AppSelectField<int>(
                  label: l.empLoginBranch,
                  enabled: !_saving,
                  value: _draft.loginBranchIds.isEmpty
                      ? null
                      : _draft.loginBranchIds.first,
                  errorText: _errorText('login.branchIds'),
                  options: _options(widget.lookups.branches),
                  onChanged: (value) => setState(
                    () => _draft = _copy(
                      loginBranchIds: value == null ? const [] : [value],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
