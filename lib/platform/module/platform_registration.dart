import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/router/app_route_transitions.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_repository.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/password_bloc.dart';
import 'package:modular_erp/platform/auth/presentation/pages/change_password_page.dart';
import 'package:modular_erp/platform/dashboard/domain/dashboard_repository.dart';
import 'package:modular_erp/platform/dashboard/presentation/dashboard_page.dart';
import 'package:modular_erp/platform/profile/application/my_profile_cubit.dart';
import 'package:modular_erp/platform/profile/presentation/my_profile_page.dart';

/// Platform (cross-module) destination composition: Dashboard and the Account
/// utilities. HR/Services destinations are composed separately.
List<AppModule> buildPlatformModules({
  required ModuleRegistry Function() registry,
  required AuthRepository authRepository,
  required DashboardRepository dashboard,
  EmployeeRepository? employeeRepository,
}) {
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

  return [
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
          (_) => DashboardPage(repository: dashboard, registry: registry()),
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
                BlocProvider(
                  create: (_) =>
                      MyProfileCubit(authRepository, employeeRepository)
                        ..start(),
                  child: const MyProfilePage(),
                ),
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
  ];
}