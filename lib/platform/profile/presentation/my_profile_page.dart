import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/domain/policies/user_capability.dart';
import 'package:modular_erp/platform/auth/presentation/auth_localization.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/employees/presentation/employee_localization.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location.dart';
import 'package:modular_erp/platform/profile/application/my_profile_cubit.dart';
import 'package:modular_erp/platform/profile/domain/my_profile_view_model.dart';

/// Unified self-service profile. Combines the account with the linked employee
/// when one exists; never shows fake employment data for unlinked accounts.
class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MyProfileCubit, MyProfileState>(
        builder: (context, state) {
          final l = context.l10n;
          final viewModel = state.data;
          if (state.loading || viewModel == null) {
            return AppPage(
              maxWidth: AppDimensions.content,
              header: AppPageHeader(title: l.profileMyProfile),
              child: const _ProfileSkeleton(),
            );
          }
          final compact = AppBreakpoints.of(context) == AppSize.compact;
          final main = _mainSections(context, viewModel);
          final side = _sideSections(context, viewModel);
          return AppPage(
            maxWidth: AppDimensions.content,
            header: AppPageHeader(title: l.profileMyProfile),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _identityHeader(context, viewModel),
                const SizedBox(height: AppSpacing.xl),
                if (compact) ...[
                  ...main,
                  const SizedBox(height: AppSpacing.xl),
                  ...side,
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: main,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: side,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      );

  // ----- header -------------------------------------------------------------

  Widget _identityHeader(BuildContext context, MyProfileViewModel vm) {
    final l = context.l10n;
    final employee = vm.employee;
    final subtitle = employee != null
        ? [
            vm.referenceName(
              vm.references?.designations,
              employee.designationId,
            ),
            vm.referenceName(vm.references?.departments, employee.departmentId),
          ].whereType<String>().where((s) => s.isNotEmpty).join(' Â· ')
        : vm.account.user.role.label(l);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppAvatar(name: vm.displayName, radius: 30),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.displayName,
                  style: AppTypography.of(context).pageTitle,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: AppTypography.of(context).bodySecondary,
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    if (employee != null)
                      AppStatusBadge(
                        label: employee.status == EmploymentStatus.active
                            ? l.active
                            : l.inactive,
                        status: employee.status == EmploymentStatus.active
                            ? AppStatus.success
                            : AppStatus.neutral,
                        showDot: true,
                      ),
                    if (employee != null)
                      AppStatusBadge(
                        label: employee.employeeCode,
                        status: AppStatus.neutral,
                      ),
                    AppStatusBadge(
                      label: vm.account.user.role.label(l),
                      status: AppStatus.brand,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----- main column --------------------------------------------------------

  List<Widget> _mainSections(BuildContext context, MyProfileViewModel vm) {
    final l = context.l10n;
    final employee = vm.employee;
    final account = vm.account;
    final sections = <Widget>[
      AppDetailsSection(
        title: l.profileOverview,
        details: {
          l.fullName: vm.displayName,
          l.profileLoginEmail: account.user.email,
          if (account.user.phone != null && account.user.phone!.isNotEmpty)
            l.phone: account.user.phone!,
          l.authAccountStatus: account.user.status.label(l),
        },
      ),
    ];
    if (employee != null) {
      sections.addAll([
        AppDetailsSection(
          title: l.empEmployment,
          details: {
            l.workforceCode: employee.employeeCode,
            l.empDepartment:
                vm.referenceName(
                  vm.references?.departments,
                  employee.departmentId,
                ) ??
                'â€”',
            l.empDesignation:
                vm.referenceName(
                  vm.references?.designations,
                  employee.designationId,
                ) ??
                'â€”',
            l.empManager:
                vm.referenceName(vm.references?.managers, employee.managerId) ??
                'â€”',
            l.empJoined: AppDateFormatter(
              Localizations.localeOf(context),
            ).date(employee.joiningDate),
            l.empType: employmentTypeLabel(employee.employmentType, l),
            l.profileEmploymentStatus:
                employee.status == EmploymentStatus.active
                ? l.active
                : l.inactive,
          },
        ),
        AppDetailsSection(
          title: l.profileWorkInformation,
          details: {
            l.workforceShift:
                _shiftName(vm.references?.shifts, employee.shiftId) ?? 'â€”',
            l.attendanceWorkLocation:
                _locationName(
                  vm.references?.workLocations,
                  employee.workLocationId,
                ) ??
                'â€”',
            l.cfgPolicies:
                _policyName(
                  vm.references?.attendancePolicies,
                  employee.attendancePolicyId,
                ) ??
                'â€”',
          },
        ),
      ]);
    } else if (vm.employeeUnavailable) {
      sections.add(
        AppNotice(
          title: l.profileEmploymentUnavailable,
          status: AppStatus.warning,
        ),
      );
    }
    if (vm.capabilities.has(UserCapability.selfAttendanceHistory)) {
      sections.add(
        AppFormSection(
          title: l.profileMyAttendance,
          card: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.attendanceTodayTitle,
                style: AppTypography.of(context).body,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  AppSecondaryButton(
                    label: l.attendanceOpenAttendance,
                    onPressed: () => context.push(AppRoutes.attendance),
                  ),
                  AppSecondaryButton(
                    label: l.historyNav,
                    onPressed: () => context.push(AppRoutes.attendanceHistory),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    if (vm.capabilities.has(UserCapability.manageEmployees) &&
        employee != null) {
      sections.add(
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppTextButton(
            label: l.profileViewEmployeeRecord,
            onPressed: () =>
                context.push(AppRoutes.employeeDetails(employee.id)),
          ),
        ),
      );
    }
    return [
      for (var i = 0; i < sections.length; i++) ...[
        if (i > 0) const SizedBox(height: AppSpacing.xl),
        sections[i],
      ],
    ];
  }

  // ----- side column --------------------------------------------------------

  List<Widget> _sideSections(BuildContext context, MyProfileViewModel vm) {
    final l = context.l10n;
    final account = vm.account;
    final capabilities = vm.capabilities;
    return [
      AppDetailsSection(
        title: l.profileAccountAccess,
        details: {
          l.profileLoginEmail: account.user.email,
          l.authAccountStatus: account.user.status.label(l),
          l.profileCurrentCompany: account.company.name,
          l.profileRoles: account.user.role.label(l),
        },
      ),
      const SizedBox(height: AppSpacing.xl),
      AppFormSection(
        title: l.profileAccess,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _accessSummary(context, vm),
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
      AppFormSection(
        title: l.profileSecurity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSettingsTile(
              title: l.authChangePassword,
              description: l.authAccount,
              icon: Icons.lock_outline,
              onPressed: () => context.push(AppRoutes.changePassword),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
      AppFormSection(
        title: l.profilePreferences,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSettingsTile(
              title: l.language,
              description: account.company.defaultLocale.toUpperCase(),
              icon: Icons.translate_outlined,
              onPressed: () => AppDialog.show<void>(
                context,
                (dialogContext) => AppDialog(
                  title: dialogContext.l10n.language,
                  actions: [
                    AppTextButton(
                      label: dialogContext.l10n.close,
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                  child: const AppLanguageSelector(),
                ),
              ),
            ),
            if (capabilities.hasLinkedEmployee)
              AppSettingsTile(
                title: l.notificationsReminders,
                description: l.reminderPermissionHint,
                icon: Icons.notifications_active_outlined,
                onPressed: () => context.push(AppRoutes.reminderSettings),
              ),
            AppSettingsTile(
              title: l.syncDataAndSync,
              description: l.syncStatusTitle,
              icon: Icons.sync_outlined,
              onPressed: () => context.push(AppRoutes.syncSettings),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _accessSummary(BuildContext context, MyProfileViewModel vm) {
    final l = context.l10n;
    final capabilities = vm.capabilities;
    final rows = <MapEntry<String, String>>[];
    if (capabilities.has(UserCapability.manageEmployees)) {
      rows.add(MapEntry(l.shellEmployees, l.profileManage));
    }
    final attendance = <String>[
      if (capabilities.has(UserCapability.selfAttendance)) l.reportScopeTeam,
      if (capabilities.has(UserCapability.teamAttendance)) l.workforceTeam,
      if (capabilities.has(UserCapability.companyAttendance))
        l.reportScopeCompany,
      if (capabilities.has(UserCapability.approveAttendanceCorrections))
        l.correctionReviewQueue,
    ];
    if (attendance.isNotEmpty) {
      rows.add(MapEntry(l.shellAttendance, attendance.join(' Â· ')));
    }
    if (capabilities.has(UserCapability.viewAttendanceReports)) {
      rows.add(MapEntry(l.shellReports, l.cfgView));
    }
    if (capabilities.has(UserCapability.manageAttendanceConfiguration)) {
      rows.add(MapEntry(l.cfgConfiguration, l.profileManage));
    }
    if (capabilities.has(UserCapability.manageUsers) ||
        capabilities.has(UserCapability.manageRoles) ||
        capabilities.has(UserCapability.manageCompany)) {
      final admin = <String>[
        if (capabilities.has(UserCapability.manageUsers)) l.shellAdministration,
        if (capabilities.has(UserCapability.manageRoles)) l.profileRoles,
        if (capabilities.has(UserCapability.manageCompany))
          l.profileCurrentCompany,
      ];
      rows.add(MapEntry(l.profileAdministrativeAccess, admin.join(' Â· ')));
    }
    if (rows.isEmpty) {
      rows.add(MapEntry(l.profileAccess, l.profileMyProfile));
    }
    return [
      for (final row in rows)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(row.key)),
              Expanded(
                child: Text(
                  row.value,
                  style: AppTypography.of(context).bodySecondary,
                ),
              ),
            ],
          ),
        ),
    ];
  }

  String? _shiftName(List<Shift>? shifts, String? id) {
    if (id == null || shifts == null) return null;
    for (final shift in shifts) {
      if (shift.id == id) return shift.name;
    }
    return null;
  }

  String? _locationName(List<WorkLocation>? locations, String? id) {
    if (id == null || locations == null) return null;
    for (final location in locations) {
      if (location.id == id) return location.name;
    }
    return null;
  }

  String? _policyName(List<AttendancePolicy>? policies, String? id) {
    if (id == null || policies == null) return null;
    for (final policy in policies) {
      if (policy.id == id) return policy.name;
    }
    return null;
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const AppSkeleton(height: 96),
      const SizedBox(height: AppSpacing.xl),
      const AppSkeleton(height: 160),
      const SizedBox(height: AppSpacing.xl),
      const AppSkeleton(height: 160),
    ],
  );
}
