import 'package:modular_erp/shared/presentation/configuration_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/localization/app_formatters.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/app/shell/pages/route_status_pages.dart';
import 'package:modular_erp/platform/auth/presentation/auth_localization.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee.dart';
import 'package:modular_erp/modules/hr/employees/presentation/bloc/employee_details_bloc.dart';
import 'package:modular_erp/modules/hr/employees/presentation/employee_localization.dart';
import 'employee_list_page.dart';

class EmployeeDetailsPage extends StatelessWidget {
  const EmployeeDetailsPage({super.key, required this.registry});
  final ModuleRegistry registry;
  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<EmployeeDetailsBloc, EmployeeDetailsState>(
    listenWhen: (a, b) => b.saved,
    listener: (c, s) =>
        AppFeedback.showMessage(c, message: (l) => l.empStatusSaved),
    builder: (context, state) {
      final l = context.l10n,
          bloc = context.read<EmployeeDetailsBloc>(),
          can = PermissionChecker(bloc.context.user.permissions).can;
      if (state.loading) return const AppPage(child: AppEmployeeSkeleton());
      if (state.failure?.code == 'denied') {
        return UnauthorizedPage(landing: AppRoutes.profile);
      }
      if (state.employee == null) {
        return AppPage(
          child: state.failure != null
              ? AppErrorState(
                  message: employeeFailure(state.failure!, l),
                  onRetry: () => bloc.add(const EmployeeDetailsStarted()),
                )
              : AppEmptyState(
                  title: l.empNotFound,
                  message: l.empNotFoundMessage,
                  actionLabel: l.empBack,
                  onAction: () => context.go(AppRoutes.employees),
                ),
        );
      }
      final e = state.employee!,
          refs = state.references,
          a = state.account?.user;
      final navigation = NavigationResolver(registry);
      return AppPage(
        header: AppPageHeader(
          title: e.displayName,
          subtitle: [
            e.employeeCode,
            referenceLabel(refs?.designations, e.designationId, l),
          ].join(' · '),
          breadcrumbs: AppBreadcrumbs(
            items: [
              AppBreadcrumbItem(
                label:
                    navigation.routeAccess(AppRoutes.employees, bloc.context) ==
                        RouteAccess.allowed
                    ? l.shellEmployees
                    : l.shellProfile,
                route:
                    navigation.routeAccess(AppRoutes.employees, bloc.context) ==
                        RouteAccess.allowed
                    ? AppRoutes.employees
                    : AppRoutes.profile,
              ),
              AppBreadcrumbItem(label: l.empDetails),
            ],
            onNavigate: (route) => context.go(route),
          ),
          actions: [
            if (can(AppPermission.employeeUpdate))
              AppSecondaryButton(
                label: l.empEdit,
                icon: Icons.edit_outlined,
                onPressed: () => context.push(AppRoutes.employeeEdit(e.id)),
              ),
            if (can(AppPermission.employeeDeactivate))
              AppSecondaryButton(
                label: e.status == EmploymentStatus.active
                    ? l.empDeactivate
                    : l.empActivate,
                onPressed: state.busy
                    ? null
                    : () async {
                        if (await AppConfirmationDialog.show(
                              context,
                              title: (l) => l.empStatusConfirm,
                              message: (l) => l.empStatusMessage,
                              confirmLabel: (l) =>
                                  e.status == EmploymentStatus.active
                                  ? l.empDeactivate
                                  : l.empActivate,
                            ) &&
                            context.mounted) {
                          bloc.add(
                            EmployeeDetailsStatusRequested(
                              e.status != EmploymentStatus.active,
                            ),
                          );
                        }
                      },
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.failure != null) ...[
              AppAlert(
                message: employeeFailure(state.failure!, l),
                status: AppStatus.warning,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Row(
              children: [
                AppAvatar(name: e.displayName, radius: 24),
                const SizedBox(width: AppSpacing.lg),
                employeeBadge(e, l),
                const SizedBox(width: AppSpacing.sm),
                if (e.syncStatus != EmployeeSyncStatus.synced)
                  Expanded(
                    child: Text(
                      l.empPending,
                      style: AppTypography.of(context).caption,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (state.failure != null) ...[
              AppAlert(
                message: employeeFailure(state.failure!, l),
                status: AppStatus.warning,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            AppDashboardTwoColumn(
              primary: AppFormSection(
                title: l.empPersonal,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(label: l.fullName, value: e.displayName),
                    AppDetailField(
                      label: l.email,
                      value: e.email,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.phone,
                      value: e.phone,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.empCode,
                      value: e.employeeCode,
                      identifier: true,
                    ),
                  ],
                ),
              ),
              secondary: AppFormSection(
                title: l.empEmployment,
                child: AppDetailsGrid(
                  fields: [
                    AppDetailField(
                      label: l.empDepartment,
                      value: referenceLabel(
                        refs?.departments,
                        e.departmentId,
                        l,
                      ),
                    ),
                    AppDetailField(
                      label: l.empDesignation,
                      value: referenceLabel(
                        refs?.designations,
                        e.designationId,
                        l,
                      ),
                    ),
                    AppDetailField(
                      label: l.empManager,
                      value: referenceLabel(
                        refs?.managerLabels,
                        e.managerId,
                        l,
                      ),
                    ),
                    AppDetailField(
                      label: l.empJoined,
                      value: AppDateFormatter(
                        Localizations.localeOf(context),
                      ).date(e.joiningDate),
                    ),
                    AppDetailField(
                      label: l.empType,
                      value: employmentTypeLabel(e.employmentType, l),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppFormSection(
              title: l.empAttendanceConfig,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppDetailsGrid(
                    fields: [
                      AppDetailField(
                        label: l.dashboardShift,
                        value:
                            refs?.shifts
                                .where((r) => r.id == e.shiftId)
                                .firstOrNull
                                ?.name ??
                            l.empUnassigned,
                      ),
                      AppDetailField(
                        label: l.dashboardLocation,
                        value:
                            refs?.workLocations
                                .where((r) => r.id == e.workLocationId)
                                .firstOrNull
                                ?.name ??
                            l.empUnassigned,
                      ),
                      AppDetailField(
                        label: l.empPolicy,
                        value:
                            refs?.attendancePolicies
                                .where((r) => r.id == e.attendancePolicyId)
                                .firstOrNull
                                ?.name ??
                            l.empUnassigned,
                      ),
                    ],
                  ),
                  if (refs?.shifts.where((r) => r.id == e.shiftId).firstOrNull
                      case final shift?)
                    AppDetailField(
                      label: l.cfgSchedule,
                      value: shiftSummary(context, shift),
                    ),
                  if (refs?.workLocations
                          .where((r) => r.id == e.workLocationId)
                          .firstOrNull
                      case final location?)
                    AppDetailField(
                      label: l.cfgRadius,
                      value: [
                        configurationNumber(
                          context,
                          location.allowedRadiusMeters,
                        ),
                        l.cfgMeters,
                      ].join(' '),
                    ),
                  if (refs?.attendancePolicies
                          .where((r) => r.id == e.attendancePolicyId)
                          .firstOrNull
                      case final policy?)
                    AppDetailField(
                      label: l.cfgLocationRules,
                      value: policyLocationSummary(policy, l),
                    ),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      if (e.shiftId != null &&
                          navigation.routeAccess(
                                AppRoutes.shiftsDetails(e.shiftId!),
                                bloc.context,
                              ) ==
                              RouteAccess.allowed)
                        AppTextButton(
                          label: l.cfgShifts,
                          onPressed: () =>
                              context.go(AppRoutes.shiftsDetails(e.shiftId!)),
                        ),
                      if (e.workLocationId != null &&
                          navigation.routeAccess(
                                AppRoutes.workLocationsDetails(
                                  e.workLocationId!,
                                ),
                                bloc.context,
                              ) ==
                              RouteAccess.allowed)
                        AppTextButton(
                          label: l.cfgLocations,
                          onPressed: () => context.go(
                            AppRoutes.workLocationsDetails(e.workLocationId!),
                          ),
                        ),
                      if (e.attendancePolicyId != null &&
                          navigation.routeAccess(
                                AppRoutes.attendancePoliciesDetails(
                                  e.attendancePolicyId!,
                                ),
                                bloc.context,
                              ) ==
                              RouteAccess.allowed)
                        AppTextButton(
                          label: l.cfgPolicies,
                          onPressed: () => context.go(
                            AppRoutes.attendancePoliciesDetails(
                              e.attendancePolicyId!,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppFormSection(
              title: l.empAccountAccess,
              child: AppDetailsGrid(
                fields: [
                  AppDetailField(
                    label: l.empLogin,
                    value: e.loginEnabled ? l.empActive : l.empInactive,
                  ),
                  AppDetailField(
                    label: l.empAccountAccess,
                    value: a?.displayName ?? l.empNoLogin,
                  ),
                  if (a != null) ...[
                    AppDetailField(
                      label: l.email,
                      value: a.email,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.phone,
                      value: a.phone ?? l.empUnassigned,
                      identifier: true,
                    ),
                    AppDetailField(
                      label: l.authAccountStatus,
                      value: a.status.label(l),
                    ),
                  ],
                  if (state.account?.credentialPending == true)
                    AppDetailField(
                      label: l.empAccountAccess,
                      value: l.empCredentialPending,
                    ),
                  AppDetailField(label: l.empPreview, value: l.empLoginNotice),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (navigation.routeAccess(AppRoutes.attendance, bloc.context) ==
                RouteAccess.allowed)
              AppRelatedAction(
                label: l.shellAttendance,
                icon: Icons.schedule,
                onPressed: () => context.go(AppRoutes.attendance),
              ),
            if (navigation.routeAccess(
                  AppRoutes.leaveEmployee(bloc.id),
                  bloc.context,
                ) ==
                RouteAccess.allowed)
              AppRelatedAction(
                label: l.leaveViewEmployeeLeave,
                icon: Icons.event_available,
                onPressed: () => context.go(AppRoutes.leaveEmployee(bloc.id)),
              ),
          ],
        ),
      );
    },
  );
}
