import '../../features/attendance/domain/attendance_repository.dart';
import '../../features/attendance/presentation/bloc/attendance_history_bloc.dart';
import '../../features/attendance/presentation/bloc/attendance_day_details_bloc.dart';
import '../../features/attendance/presentation/pages/attendance_history_page.dart';
import '../../features/attendance/presentation/pages/attendance_day_details_page.dart';
import '../../features/attendance/presentation/pages/attendance_today_page.dart';
import '../../features/attendance/presentation/bloc/attendance_bloc.dart';
import '../../core/location/location_service.dart';
import '../../shared/presentation/configuration_landing_page.dart';
import '../../features/shifts/domain/shift_repository.dart';
import '../../features/shifts/presentation/bloc/shift_list_bloc.dart';
import '../../features/shifts/presentation/pages/shift_list_page.dart';
import '../../features/shifts/presentation/bloc/shift_details_bloc.dart';
import '../../features/shifts/presentation/pages/shift_details_page.dart';
import '../../features/shifts/presentation/bloc/shift_form_bloc.dart';
import '../../features/shifts/presentation/pages/shift_form_page.dart';
import '../../features/shifts/domain/shift.dart';
import '../../features/work_locations/domain/work_location_repository.dart';
import '../../features/work_locations/presentation/bloc/work_location_list_bloc.dart';
import '../../features/work_locations/presentation/pages/work_location_list_page.dart';
import '../../features/work_locations/presentation/bloc/work_location_details_bloc.dart';
import '../../features/work_locations/presentation/pages/work_location_details_page.dart';
import '../../features/work_locations/presentation/bloc/work_location_form_bloc.dart';
import '../../features/work_locations/presentation/pages/work_location_form_page.dart';
import '../../features/work_locations/domain/work_location.dart';
import '../../features/attendance_policies/domain/attendance_policy_repository.dart';
import '../../features/attendance_policies/presentation/bloc/attendance_policy_list_bloc.dart';
import '../../features/attendance_policies/presentation/pages/attendance_policy_list_page.dart';
import '../../features/attendance_policies/presentation/bloc/attendance_policy_details_bloc.dart';
import '../../features/attendance_policies/presentation/pages/attendance_policy_details_page.dart';
import '../../features/attendance_policies/presentation/bloc/attendance_policy_form_bloc.dart';
import '../../features/attendance_policies/presentation/pages/attendance_policy_form_page.dart';
import '../../features/attendance_policies/domain/attendance_policy.dart';
import '../../features/employees/domain/employee_repository.dart';
import '../../features/employees/presentation/bloc/employee_list_bloc.dart';
import '../../features/employees/presentation/bloc/employee_details_bloc.dart';
import '../../features/employees/presentation/bloc/employee_form_bloc.dart';
import '../../features/employees/presentation/pages/employee_list_page.dart';
import '../../features/employees/presentation/pages/employee_details_page.dart';
import '../../features/employees/presentation/pages/employee_form_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/domain/entities/auth_context.dart';
import '../../shared/navigation/form_navigation_guard.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../../features/dashboard/domain/dashboard_repository.dart';
import '../../features/dashboard/data/local_dashboard_repository.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/security/app_permission.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/password_bloc.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../shell/pages/module_placeholder_page.dart';
import '../shell/pages/profile_placeholder_page.dart';
import '../router/app_routes.dart';
import '../router/app_route_transitions.dart';
import 'module_registry.dart';

ModuleRegistry createErpRegistry(
  AuthRepository authRepository, {
  DashboardRepository? dashboardRepository,
  EmployeeRepository? employeeRepository,
  ShiftRepository? shiftRepository,
  WorkLocationRepository? workLocationRepository,
  AttendancePolicyRepository? attendancePolicyRepository,
  LocationService? locationService,
  AttendanceRepository? attendanceRepository,
}) {
  final dashboard =
      dashboardRepository ??
      LocalDashboardRepository(demoEnabled: AppConfig.demoAuthEnabled);
  late final ModuleRegistry registry;
  final formGuard = FormNavigationGuard();
  RegisteredDestination destination(
    ErpModule navigation,
    WidgetBuilder builder,
  ) => RegisteredDestination(
    navigation: navigation,
    routes: [
      GoRoute(
        path: navigation.route,
        name: navigation.id,
        pageBuilder: (context, state) =>
            AppRouteTransitions.page(context, state, builder(context)),
      ),
    ],
  );
  RegisteredDestination shiftsDestination() {
    final guard = FormNavigationGuard();
    return RegisteredDestination(
      navigation: ErpModule(
        id: 'shifts',
        moduleId: AppModuleIds.settings,
        name: (l) => l.cfgShifts,
        icon: Icons.schedule_outlined,
        route: AppRoutes.shifts,
        requiredPermissions: {AppPermission.shiftView},
        navigationGroup: NavigationGroup.configuration,
        order: 41,
      ),
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              BlocSelector<AuthBloc, AuthState, AuthContext?>(
                selector: (s) => s.context,
                builder: (context, auth) {
                  if (auth == null) return const SizedBox.shrink();
                  if (shiftRepository == null) {
                    return AppPage(
                      child: AppErrorState(
                        message: context.l10n.cfgStorageError,
                      ),
                    );
                  }
                  return BlocProvider(
                    key: ValueKey(auth),
                    create: (_) =>
                        ShiftListBloc(shiftRepository, auth)
                          ..add(const RecordListStarted()),
                    child: child,
                  );
                },
              ),
          routes: [
            GoRoute(
              path: AppRoutes.shifts,
              name: 'shifts',
              builder: (c, s) => const ShiftListPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  onExit: (c, s) => guard.onExit(c),
                  builder: (c, s) => BlocProvider(
                    create: (_) => ShiftFormBloc(
                      shiftRepository!,
                      c.read<ShiftListBloc>().context,
                      id: null,
                    )..add(const RecordFormInitialized<ShiftDraft>()),
                    child: ShiftFormPage(guard: guard),
                  ),
                ),
                GoRoute(
                  path: ':id',
                  builder: (c, s) => BlocProvider(
                    create: (_) => ShiftDetailsBloc(
                      shiftRepository!,
                      c.read<ShiftListBloc>().context,
                      s.pathParameters['id']!,
                    )..add(const RecordDetailsStarted()),
                    child: const ShiftDetailsPage(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      onExit: (c, s) => guard.onExit(c),
                      builder: (c, s) => BlocProvider(
                        create: (_) => ShiftFormBloc(
                          shiftRepository!,
                          c.read<ShiftListBloc>().context,
                          id: s.pathParameters['id'],
                        )..add(const RecordFormInitialized<ShiftDraft>()),
                        child: ShiftFormPage(guard: guard),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  RegisteredDestination workLocationsDestination() {
    final guard = FormNavigationGuard();
    return RegisteredDestination(
      navigation: ErpModule(
        id: 'work-locations',
        moduleId: AppModuleIds.settings,
        name: (l) => l.cfgLocations,
        icon: Icons.location_on_outlined,
        route: AppRoutes.workLocations,
        requiredPermissions: {AppPermission.workLocationView},
        navigationGroup: NavigationGroup.configuration,
        order: 42,
      ),
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              BlocSelector<AuthBloc, AuthState, AuthContext?>(
                selector: (s) => s.context,
                builder: (context, auth) {
                  if (auth == null) return const SizedBox.shrink();
                  if (workLocationRepository == null) {
                    return AppPage(
                      child: AppErrorState(
                        message: context.l10n.cfgStorageError,
                      ),
                    );
                  }
                  return BlocProvider(
                    key: ValueKey(auth),
                    create: (_) =>
                        WorkLocationListBloc(workLocationRepository, auth)
                          ..add(const RecordListStarted()),
                    child: child,
                  );
                },
              ),
          routes: [
            GoRoute(
              path: AppRoutes.workLocations,
              name: 'work-locations',
              builder: (c, s) => const WorkLocationListPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  onExit: (c, s) => guard.onExit(c),
                  builder: (c, s) => BlocProvider(
                    create: (_) => WorkLocationFormBloc(
                      workLocationRepository!,
                      c.read<WorkLocationListBloc>().context,
                      locationService ?? DeviceLocationService(),
                      id: null,
                    )..add(const RecordFormInitialized<WorkLocationDraft>()),
                    child: WorkLocationFormPage(guard: guard),
                  ),
                ),
                GoRoute(
                  path: ':id',
                  builder: (c, s) => BlocProvider(
                    create: (_) => WorkLocationDetailsBloc(
                      workLocationRepository!,
                      c.read<WorkLocationListBloc>().context,
                      s.pathParameters['id']!,
                    )..add(const RecordDetailsStarted()),
                    child: const WorkLocationDetailsPage(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      onExit: (c, s) => guard.onExit(c),
                      builder: (c, s) => BlocProvider(
                        create: (_) =>
                            WorkLocationFormBloc(
                              workLocationRepository!,
                              c.read<WorkLocationListBloc>().context,
                              locationService ?? DeviceLocationService(),
                              id: s.pathParameters['id'],
                            )..add(
                              const RecordFormInitialized<WorkLocationDraft>(),
                            ),
                        child: WorkLocationFormPage(guard: guard),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  RegisteredDestination attendancePoliciesDestination() {
    final guard = FormNavigationGuard();
    return RegisteredDestination(
      navigation: ErpModule(
        id: 'attendance-policies',
        moduleId: AppModuleIds.settings,
        name: (l) => l.cfgPolicies,
        icon: Icons.rule_outlined,
        route: AppRoutes.attendancePolicies,
        requiredPermissions: {AppPermission.attendancePolicyView},
        navigationGroup: NavigationGroup.configuration,
        order: 43,
      ),
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              BlocSelector<AuthBloc, AuthState, AuthContext?>(
                selector: (s) => s.context,
                builder: (context, auth) {
                  if (auth == null) return const SizedBox.shrink();
                  if (attendancePolicyRepository == null) {
                    return AppPage(
                      child: AppErrorState(
                        message: context.l10n.cfgStorageError,
                      ),
                    );
                  }
                  return BlocProvider(
                    key: ValueKey(auth),
                    create: (_) => AttendancePolicyListBloc(
                      attendancePolicyRepository,
                      auth,
                    )..add(const RecordListStarted()),
                    child: child,
                  );
                },
              ),
          routes: [
            GoRoute(
              path: AppRoutes.attendancePolicies,
              name: 'attendance-policies',
              builder: (c, s) => const AttendancePolicyListPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  onExit: (c, s) => guard.onExit(c),
                  builder: (c, s) => BlocProvider(
                    create: (_) =>
                        AttendancePolicyFormBloc(
                          attendancePolicyRepository!,
                          c.read<AttendancePolicyListBloc>().context,
                          id: null,
                        )..add(
                          const RecordFormInitialized<AttendancePolicyDraft>(),
                        ),
                    child: AttendancePolicyFormPage(guard: guard),
                  ),
                ),
                GoRoute(
                  path: ':id',
                  builder: (c, s) => BlocProvider(
                    create: (_) => AttendancePolicyDetailsBloc(
                      attendancePolicyRepository!,
                      c.read<AttendancePolicyListBloc>().context,
                      s.pathParameters['id']!,
                    )..add(const RecordDetailsStarted()),
                    child: const AttendancePolicyDetailsPage(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      onExit: (c, s) => guard.onExit(c),
                      builder: (c, s) => BlocProvider(
                        create: (_) =>
                            AttendancePolicyFormBloc(
                              attendancePolicyRepository!,
                              c.read<AttendancePolicyListBloc>().context,
                              id: s.pathParameters['id'],
                            )..add(
                              const RecordFormInitialized<
                                AttendancePolicyDraft
                              >(),
                            ),
                        child: AttendancePolicyFormPage(guard: guard),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  registry = ModuleRegistry.fromModules([
    AppModule(
      id: AppModuleIds.dashboard,
      destinations: [
        destination(
          ErpModule(
            id: 'dashboard',
            moduleId: AppModuleIds.dashboard,
            name: (l) => l.shellDashboard,
            icon: Icons.space_dashboard_outlined,
            selectedIcon: Icons.space_dashboard,
            route: AppRoutes.dashboard,
            navigationGroup: NavigationGroup.general,
            order: 0,
            mobilePriority: 0,
          ),
          (_) => DashboardPage(repository: dashboard, registry: registry),
        ),
      ],
    ),
    AppModule(
      id: AppModuleIds.employees,
      destinations: [
        RegisteredDestination(
          navigation: ErpModule(
            id: 'employees',
            moduleId: AppModuleIds.employees,
            name: (l) => l.shellEmployees,
            icon: Icons.people_outline,
            selectedIcon: Icons.people,
            route: AppRoutes.employees,
            navigationGroup: NavigationGroup.people,
            order: 10,
            mobilePriority: 1,
            anyPermissions: {
              AppPermission.employeeViewTeam,
              AppPermission.employeeViewAll,
            },
          ),
          routes: [
            ShellRoute(
              builder: (context, state, child) =>
                  BlocSelector<AuthBloc, AuthState, AuthContext?>(
                    selector: (s) => s.context,
                    builder: (context, auth) {
                      if (auth == null) return const SizedBox.shrink();
                      if (employeeRepository == null) {
                        return AppPage(
                          child: AppErrorState(
                            message: context.l10n.empStorageError,
                          ),
                        );
                      }
                      return BlocProvider(
                        key: ValueKey(auth),
                        create: (_) =>
                            EmployeeListBloc(employeeRepository, auth)
                              ..add(const EmployeeListStarted()),
                        child: child,
                      );
                    },
                  ),
              routes: [
                GoRoute(
                  path: AppRoutes.employees,
                  name: 'employees',
                  builder: (context, state) => const EmployeeListPage(),
                  routes: [
                    GoRoute(
                      path: 'new',
                      name: 'employee-new',
                      onExit: (context, state) => formGuard.onExit(context),
                      builder: (context, state) => BlocProvider(
                        create: (_) => EmployeeFormBloc(
                          employeeRepository!,
                          context.read<EmployeeListBloc>().context,
                        )..add(const EmployeeFormInitialized()),
                        child: EmployeeFormPage(guard: formGuard),
                      ),
                    ),
                    GoRoute(
                      path: ':employeeId',
                      name: 'employee-details',
                      builder: (context, state) => BlocProvider(
                        create: (_) => EmployeeDetailsBloc(
                          employeeRepository!,
                          context.read<EmployeeListBloc>().context,
                          state.pathParameters['employeeId']!,
                        )..add(const EmployeeDetailsStarted()),
                        child: EmployeeDetailsPage(registry: registry),
                      ),
                      routes: [
                        GoRoute(
                          path: 'edit',
                          name: 'employee-edit',
                          onExit: (context, state) => formGuard.onExit(context),
                          builder: (context, state) => BlocProvider(
                            create: (_) => EmployeeFormBloc(
                              employeeRepository!,
                              context.read<EmployeeListBloc>().context,
                              id: state.pathParameters['employeeId'],
                            )..add(const EmployeeFormInitialized()),
                            child: EmployeeFormPage(guard: formGuard),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    AppModule(
      id: AppModuleIds.attendance,
      destinations: [
        destination(
          ErpModule(
            id: 'attendance',
            moduleId: AppModuleIds.attendance,
            name: (l) => l.shellAttendance,
            icon: Icons.schedule_outlined,
            selectedIcon: Icons.schedule,
            route: AppRoutes.attendance,
            navigationGroup: NavigationGroup.workforce,
            order: 20,
            mobilePriority: 2,
            requiredPermissions: {AppPermission.attendanceViewSelf},
          ),
          (c) => c.read<AttendanceBloc?>() == null
              ? AppPage(
                  child: AppErrorState(
                    message: c.l10n.attendanceUnavailableTitle,
                  ),
                )
              : const AttendanceTodayPage(),
        ),
        RegisteredDestination(
          navigation: ErpModule(
            id: 'attendance-history',
            moduleId: AppModuleIds.attendance,
            name: (l) => l.historyNav,
            icon: Icons.history_outlined,
            selectedIcon: Icons.history,
            route: AppRoutes.attendanceHistory,
            navigationGroup: NavigationGroup.workforce,
            order: 21,
            mobilePriority: 3,
            requiredPermissions: {AppPermission.attendanceViewSelf},
          ),
          routes: [
            ShellRoute(
              builder: (context, state, child) =>
                  BlocSelector<AuthBloc, AuthState, AuthContext?>(
                    selector: (s) => s.context,
                    builder: (context, actor) {
                      if (actor == null) return const SizedBox.shrink();
                      final repository =
                          attendanceRepository ??
                          context.read<AttendanceBloc?>()?.repository;
                      if (repository == null) {
                        return AppPage(
                          child: AppErrorState(
                            message: context.l10n.attendanceUnavailableTitle,
                          ),
                        );
                      }
                      return BlocProvider(
                        key: ValueKey(actor),
                        create: (_) =>
                            AttendanceHistoryBloc(repository)
                              ..add(const AttendanceHistoryStarted()),
                        child: child,
                      );
                    },
                  ),
              routes: [
                GoRoute(
                  path: AppRoutes.attendanceHistory,
                  name: 'attendance-history',
                  builder: (c, s) => const AttendanceHistoryPage(),
                  routes: [
                    GoRoute(
                      path: ':attendanceDayId',
                      name: 'attendance-day-details',
                      builder: (c, s) => BlocProvider(
                        create: (_) => AttendanceDayDetailsBloc(
                          c.read<AttendanceHistoryBloc>().repository,
                          s.pathParameters['attendanceDayId']!,
                        )..add(const AttendanceDayDetailsStarted()),
                        child: const AttendanceDayDetailsPage(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    AppModule(
      id: AppModuleIds.reports,
      destinations: [
        destination(
          ErpModule(
            id: 'reports',
            moduleId: AppModuleIds.reports,
            name: (l) => l.shellReports,
            icon: Icons.assessment_outlined,
            selectedIcon: Icons.assessment,
            route: AppRoutes.reports,
            navigationGroup: NavigationGroup.insights,
            order: 30,
            requiredPermissions: {AppPermission.attendanceReportView},
          ),
          (_) => const ReportsPlaceholderPage(),
        ),
      ],
    ),
    AppModule(
      id: AppModuleIds.settings,
      destinations: [
        destination(
          ErpModule(
            id: 'settings',
            moduleId: AppModuleIds.settings,
            name: (l) => l.cfgConfiguration,
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            route: AppRoutes.settings,
            navigationGroup: NavigationGroup.configuration,
            order: 40,
            anyPermissions: {
              AppPermission.shiftView,
              AppPermission.workLocationView,
              AppPermission.attendancePolicyView,
              AppPermission.companyManage,
              AppPermission.userManage,
              AppPermission.roleManage,
            },
          ),
          (_) => ConfigurationLandingPage(
            shiftRepository: shiftRepository,
            workLocationRepository: workLocationRepository,
            attendancePolicyRepository: attendancePolicyRepository,
          ),
        ),
        shiftsDestination(),
        workLocationsDestination(),
        attendancePoliciesDestination(),
      ],
    ),
    AppModule(
      id: AppModuleIds.account,
      alwaysAvailable: true,
      destinations: [
        RegisteredDestination(
          navigation: ErpModule(
            id: 'profile',
            moduleId: AppModuleIds.account,
            name: (l) => l.shellProfile,
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            route: AppRoutes.profile,
            navigationGroup: NavigationGroup.account,
            order: 90,
            routeAliases: {AppRoutes.changePassword},
          ),
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              name: 'profile',
              pageBuilder: (context, state) => AppRouteTransitions.page(
                context,
                state,
                ProfilePlaceholderPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.changePassword,
              name: 'change-password',
              pageBuilder: (context, state) => AppRouteTransitions.page(
                context,
                state,
                BlocProvider(
                  create: (_) => PasswordBloc(authRepository),
                  child: const ChangePasswordPage(embedded: true),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ]);
  return registry;
}
