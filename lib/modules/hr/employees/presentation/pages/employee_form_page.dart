import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/shared/presentation/configuration_localization.dart';
import 'package:modular_erp/app/shell/pages/route_status_pages.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/shared/navigation/form_navigation_guard.dart';
import 'package:modular_erp/shared/navigation/app_navigation.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_access.dart';
import 'package:modular_erp/modules/hr/employees/presentation/bloc/employee_form_bloc.dart';
import 'package:modular_erp/modules/hr/employees/presentation/employee_localization.dart';
import 'employee_list_page.dart';

class EmployeeFormPage extends StatefulWidget {
  const EmployeeFormPage({super.key, required this.guard});
  final FormNavigationGuard guard;
  @override
  State<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

double? _finite(AppNumericInput input) {
  final value = input.optional;
  return value != null && value.isFinite ? value : null;
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  final first = TextEditingController(),
      middle = TextEditingController(),
      last = TextEditingController(),
      email = TextEditingController(),
      phone = TextEditingController();
  bool preloaded = false;
  @override
  void initState() {
    super.initState();
    widget.guard.attach(this, context.read<EmployeeFormBloc>().context);
  }

  @override
  void dispose() {
    for (final c in [first, middle, last, email, phone]) {
      c.dispose();
    }
    widget.guard.detach(this);
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<EmployeeFormBloc, EmployeeFormState>(
    listener: (context, state) {
      if (identical(widget.guard.owner, this)) {
        widget.guard.dirty = state.dirty;
        widget.guard.saving = state.saving;
      }
      if (!state.loading && !preloaded) {
        preloaded = true;
        first.text = state.draft.firstName;
        middle.text = state.draft.middleName;
        last.text = state.draft.lastName;
        email.text = state.draft.email;
        phone.text = state.draft.phone;
      }
      if (state.savedId != null) {
        final edit = context.read<EmployeeFormBloc>().id != null;
        AppFeedback.showMessage(
          context,
          message: (l) => edit ? l.empUpdated : l.empCreated,
        );
        final scope = const EmployeeScopeResolver().resolve(
              context.read<EmployeeFormBloc>().context,
            ),
            own = context
                .read<EmployeeFormBloc>()
                .context
                .employeeReference
                ?.id;
        final mayRead =
            scope == EmployeeScope.all ||
            state.savedId == own && scope != EmployeeScope.none ||
            scope == EmployeeScope.team && state.draft.managerId == own;
        context.go(
          mayRead
              ? AppRoutes.employeeDetails(state.savedId!)
              : AppRoutes.dashboard,
        );
      }
    },
    builder: (context, state) {
      final l = context.l10n,
          bloc = context.read<EmployeeFormBloc>(),
          d = state.draft,
          refs = state.references;
      if (state.loading) return const AppPage(child: AppEmployeeSkeleton());
      if (state.failure?.code == 'denied' && state.references == null) {
        return const UnauthorizedPage(landing: AppRoutes.profile);
      }
      if (state.references == null && state.failure != null) {
        return AppPage(
          child: state.failure!.code == 'notFound'
              ? AppEmptyState(
                  title: l.empNotFound,
                  message: l.empNotFoundMessage,
                )
              : AppErrorState(
                  message: employeeFailure(state.failure!, l),
                  onRetry: () => bloc.add(const EmployeeFormInitialized()),
                ),
        );
      }
      void change(EmployeeDraft Function(EmployeeDraft) patch) =>
          bloc.add(EmployeeDraftChanged(patch));
      String? fieldError(String key) {
        final code = state.fieldErrors[key];
        return code == null ? null : employeeFailure(Failure(code: code), l);
      }

      return AppPage(
        header: AppPageHeader(
          title: bloc.id == null ? l.empAdd : l.empEdit,
          actions: [
            AppTextButton(
              label: l.cancel,
              onPressed: state.saving
                  ? null
                  : () {
                      final scope = const EmployeeScopeResolver().resolve(
                        bloc.context,
                      );
                      context.popOrGo(
                        scope == EmployeeScope.all ||
                                scope == EmployeeScope.team
                            ? AppRoutes.employees
                            : AppRoutes.dashboard,
                      );
                    },
            ),
            AppPrimaryButton(
              label: l.empSave,
              loading: state.saving,
              onPressed: () => bloc.add(const EmployeeSubmitted()),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.failure != null) ...[
              Semantics(
                liveRegion: true,
                child: AppAlert(
                  message: employeeFailure(state.failure!, l),
                  status: AppStatus.warning,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            AppFormSection(
              title: l.empPersonal,
              child: AppFormGrid(
                children: [
                  AppTextField(
                    label: l.empFirst,
                    errorText: fieldError("firstName"),
                    controller: first,
                    enabled: !state.saving,
                    textInputAction: TextInputAction.next,
                    onChanged: (v) => change((d) => d.copyWith(firstName: v)),
                  ),
                  AppTextField(
                    label: l.empLast,
                    controller: last,
                    enabled: !state.saving,
                    textInputAction: TextInputAction.next,
                    onChanged: (v) => change((d) => d.copyWith(lastName: v)),
                  ),
                  AppTextField(
                    label: l.empMiddle,
                    controller: middle,
                    enabled: !state.saving,
                    textInputAction: TextInputAction.next,
                    onChanged: (v) => change((d) => d.copyWith(middleName: v)),
                  ),
                  AppTextField(
                    label: l.email,
                    errorText: fieldError("email"),
                    controller: email,
                    enabled: !state.saving,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (v) => change((d) => d.copyWith(email: v)),
                  ),
                  AppTextField(
                    label: l.phone,
                    errorText: fieldError("phone"),
                    controller: phone,
                    enabled: !state.saving,
                    autocorrect: false,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onChanged: (v) => change((d) => d.copyWith(phone: v)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppFormSection(
              title: l.empEmployment,
              child: AppFormGrid(
                children: [
                  AppDetailField(
                    label: l.empCode,
                    value: state.employeeCode ?? l.empGenerated,
                    identifier: state.employeeCode != null,
                  ),
                  AppSelectField<String>(
                    label: l.empDepartment,
                    errorText: fieldError("departmentId"),
                    value: d.departmentId,
                    enabled: !state.saving,
                    options: [
                      for (final r
                          in refs?.departments ?? <WorkforceReference>[])
                        AppSelectOption(r.id, r.name),
                    ],
                    onChanged: (v) =>
                        change((d) => d.copyWith(departmentId: v)),
                  ),
                  AppSelectField<String>(
                    label: l.empDesignation,
                    errorText: fieldError("designationId"),
                    value: d.designationId,
                    enabled: !state.saving,
                    options: [
                      for (final r
                          in refs?.designations ?? <WorkforceReference>[])
                        AppSelectOption(r.id, r.name),
                    ],
                    onChanged: (v) =>
                        change((d) => d.copyWith(designationId: v)),
                  ),
                  AppSelectField<String>(
                    label: l.empManager,
                    errorText: fieldError("managerId"),
                    value: d.managerId,
                    enabled: !state.saving,
                    options: [
                      for (final r in refs?.managers ?? <WorkforceReference>[])
                        AppSelectOption(r.id, r.name),
                    ],
                    onChanged: (v) => change((d) => d.copyWith(managerId: v)),
                  ),
                  AppDateField(
                    label: l.empJoined,
                    errorText: fieldError("joiningDate"),
                    value: d.joiningDate,
                    lastDate: DateTime.now(),
                    enabled: !state.saving,
                    onChanged: (v) => change((d) => d.copyWith(joiningDate: v)),
                  ),
                  AppDropdown<EmploymentType>(
                    label: l.empType,
                    value: d.employmentType,
                    items: [
                      for (final t in EmploymentType.values)
                        DropdownMenuItem(
                          value: t,
                          child: Text(employmentTypeLabel(t, l)),
                        ),
                    ],
                    onChanged: state.saving
                        ? null
                        : (v) {
                            if (v != null) {
                              change((d) => d.copyWith(employmentType: v));
                            }
                          },
                  ),
                  if (PermissionChecker(
                    bloc.context.user.permissions,
                  ).can(AppPermission.employeeDeactivate))
                    AppDropdown<EmploymentStatus>(
                      label: l.status,
                      value: d.status,
                      items: [
                        for (final s in EmploymentStatus.values)
                          DropdownMenuItem(
                            value: s,
                            child: Text(
                              s == EmploymentStatus.active
                                  ? l.empActive
                                  : l.empInactive,
                            ),
                          ),
                      ],
                      onChanged: state.saving
                          ? null
                          : (v) {
                              if (v != null) {
                                change((d) => d.copyWith(status: v));
                              }
                            },
                    ),
                ],
              ),
            ),
            if (refs != null && refs.hasBackendProfileLookups) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppFormSection(
                title: l.empBackendProfile,
                child: AppFormGrid(
                  children: [
                    AppSelectField<String>(
                      label: l.empBranch,
                      errorText: fieldError("branchId"),
                      value: d.branchId,
                      enabled: !state.saving,
                      options: [
                        for (final r in refs.branches)
                          AppSelectOption(r.id, r.name),
                      ],
                      onChanged: (v) => change((d) => d.copyWith(branchId: v)),
                    ),
                    AppSelectField<String>(
                      label: l.empNationality,
                      errorText: fieldError("nationalityId"),
                      value: d.nationalityId,
                      enabled: !state.saving,
                      options: [
                        for (final r in refs.nationalities)
                          AppSelectOption(r.id, r.name),
                      ],
                      onChanged: (v) =>
                          change((d) => d.copyWith(nationalityId: v)),
                    ),
                    AppDateField(
                      label: l.empDateOfBirth,
                      value: d.dateOfBirth,
                      lastDate: DateTime.now(),
                      enabled: !state.saving,
                      onChanged: (v) =>
                          change((d) => d.copyWith(dateOfBirth: v)),
                    ),
                    AppSelectField<String>(
                      label: l.empMaritalStatus,
                      value: d.maritalStatus,
                      enabled: !state.saving,
                      options: [
                        for (final value in refs.maritalStatuses)
                          AppSelectOption(value, value),
                      ],
                      onChanged: (v) =>
                          change((d) => d.copyWith(maritalStatus: v)),
                    ),
                    AppSelectField<String>(
                      label: l.empGratuity,
                      value: d.gratuity,
                      enabled: !state.saving,
                      options: [
                        for (final value in refs.gratuityTypes)
                          AppSelectOption(value, value),
                      ],
                      onChanged: (v) => change((d) => d.copyWith(gratuity: v)),
                    ),
                    AppNumberField(
                      label: l.empWorkingHours,
                      initialValue: d.workingHours,
                      enabled: !state.saving,
                      onChanged: (v) =>
                          change((d) => d.copyWith(workingHours: _finite(v))),
                    ),
                    AppNumberField(
                      label: l.empBasicSalary,
                      initialValue: d.basicSalary,
                      enabled: !state.saving,
                      onChanged: (v) =>
                          change((d) => d.copyWith(basicSalary: _finite(v))),
                    ),
                    AppNumberField(
                      label: l.empTransportation,
                      initialValue: d.transportation,
                      enabled: !state.saving,
                      onChanged: (v) =>
                          change((d) => d.copyWith(transportation: _finite(v))),
                    ),
                    AppNumberField(
                      label: l.empAccommodation,
                      initialValue: d.accommodation,
                      enabled: !state.saving,
                      onChanged: (v) =>
                          change((d) => d.copyWith(accommodation: _finite(v))),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            AppFormSection(
              title: l.empAttendanceConfig,
              child: AppFormGrid(
                children: [
                  AppSelectField<String>(
                    label: l.dashboardShift,
                    value: d.shiftId,
                    enabled: !state.saving,
                    errorText: fieldError('shiftId'),
                    options: [
                      for (final item in refs!.shifts)
                        AppSelectOption(
                          item.id,
                          item.name,
                          subtitle: item.status == ConfigurationStatus.inactive
                              ? l.cfgInactiveAssignment
                              : configurationStatusLabel(item.status, l),
                          enabled: item.status == ConfigurationStatus.active,
                        ),
                    ],
                    onChanged: (v) => change((d) => d.copyWith(shiftId: v)),
                  ),
                  AppSelectField<String>(
                    label: l.dashboardLocation,
                    value: d.workLocationId,
                    enabled: !state.saving,
                    errorText: fieldError('workLocationId'),
                    options: [
                      for (final item in refs.workLocations)
                        AppSelectOption(
                          item.id,
                          item.name,
                          subtitle: item.status == ConfigurationStatus.inactive
                              ? l.cfgInactiveAssignment
                              : configurationStatusLabel(item.status, l),
                          enabled: item.status == ConfigurationStatus.active,
                        ),
                    ],
                    onChanged: (v) =>
                        change((d) => d.copyWith(workLocationId: v)),
                  ),
                  AppSelectField<String>(
                    label: l.empPolicy,
                    value: d.attendancePolicyId,
                    enabled: !state.saving,
                    errorText: fieldError('attendancePolicyId'),
                    options: [
                      for (final item in refs.attendancePolicies)
                        AppSelectOption(
                          item.id,
                          item.name,
                          subtitle: item.status == ConfigurationStatus.inactive
                              ? l.cfgInactiveAssignment
                              : configurationStatusLabel(item.status, l),
                          enabled: item.status == ConfigurationStatus.active,
                        ),
                    ],
                    onChanged: (v) =>
                        change((d) => d.copyWith(attendancePolicyId: v)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppFormSection(
              title: l.empAccountAccess,
              subtitle: refs.hasBackendProfileLookups
                  ? l.empLoginNoticeBackend
                  : l.empLoginNotice,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppBooleanSettingRow(
                    label: l.empLogin,
                    value: d.loginEnabled,
                    onChanged: state.saving
                        ? null
                        : (v) => change((d) => d.copyWith(loginEnabled: v)),
                  ),
                  if (d.loginEnabled) ...[
                    if (refs.hasBackendProfileLookups) ...[
                      const SizedBox(height: AppSpacing.lg),
                      AppFormGrid(
                        children: [
                          AppTextField(
                            label: l.empLoginId,
                            initialValue: d.loginId,
                            errorText: fieldError("login.loginId"),
                            enabled: !state.saving,
                            autocorrect: false,
                            textInputAction: TextInputAction.next,
                            onChanged: (v) =>
                                change((d) => d.copyWith(loginId: v)),
                          ),
                          AppTextField(
                            label: l.empLoginMobile,
                            initialValue: d.loginMobile,
                            errorText: fieldError("login.mobileNo"),
                            enabled: !state.saving,
                            autocorrect: false,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            onChanged: (v) =>
                                change((d) => d.copyWith(loginMobile: v)),
                          ),
                          AppTextField(
                            label: l.empLoginPassword,
                            initialValue: d.loginPassword,
                            helperText: l.empLoginPasswordHint,
                            errorText: fieldError("login.password"),
                            enabled: !state.saving,
                            autocorrect: false,
                            obscureText: true,
                            onChanged: (v) =>
                                change((d) => d.copyWith(loginPassword: v)),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l.empLoginBranches,
                        style: AppTypography.of(context).label,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          for (final branch in refs.branches)
                            AppSelectionChip(
                              label: branch.name,
                              selected: d.loginBranchIds.contains(branch.id),
                              enabled: !state.saving,
                              onSelected: (selected) => change((d) {
                                final ids = [...d.loginBranchIds];
                                if (selected) {
                                  if (!ids.contains(branch.id)) {
                                    ids.add(branch.id);
                                  }
                                } else {
                                  ids.remove(branch.id);
                                }
                                return d.copyWith(loginBranchIds: ids);
                              }),
                            ),
                        ],
                      ),
                      if (fieldError("login.branchIds") case final error?) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          error,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ] else ...[
                      AppDetailField(
                        label: l.email,
                        value: state.account?.credentialPending == false
                            ? state.account!.user.email
                            : d.email,
                        identifier: true,
                      ),
                      AppDetailField(
                        label: l.phone,
                        value: state.account?.credentialPending == false
                            ? state.account!.user.phone ?? l.empUnassigned
                            : d.phone,
                        identifier: true,
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AppPrimaryButton(
                label: l.empSave,
                loading: state.saving,
                onPressed: () => bloc.add(const EmployeeSubmitted()),
              ),
            ),
          ],
        ),
      );
    },
  );
}
