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
            anyPermissions: {
              AppPermission.attendanceViewSelf,
              AppPermission.attendanceViewTeam,
              AppPermission.attendanceViewAll,
            },
          ),
          (_) => const AttendancePlaceholderPage(),
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
            name: (l) => l.shellSettings,
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            route: AppRoutes.settings,
            navigationGroup: NavigationGroup.administration,
            order: 40,
            anyPermissions: {
              AppPermission.companyManage,
              AppPermission.userManage,
              AppPermission.roleManage,
            },
          ),
          (_) => const SettingsPlaceholderPage(),
        ),
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
