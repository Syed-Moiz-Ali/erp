import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/router/app_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/app/shell/app_shell_cubit.dart';
import 'package:modular_erp/app/shell/pages/route_status_pages.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/backend_access_policy.dart';
import 'package:modular_erp/design_system/theme/app_theme.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

class _MockAuthBloc extends Mock implements AuthBloc {}

class _MockAuthRepository extends Mock implements AuthRepository {}

PermissionSet _permissions(Set<String> keys) => PermissionSet({
  for (final key in keys) ...?BackendAccessPolicy.keyPermissions[key],
});

AuthState _state(Set<String> keys) {
  final user = UserAccount(
    id: 'user-1',
    displayName: 'Test User',
    email: 'test@example.com',
    companyId: 'company-1',
    permissions: _permissions(keys),
    status: AccountStatus.active,
  );
  return AuthState(
    AuthStatus.authenticated,
    context: AuthContext(
      user: user,
      company: const CompanyContext(
        id: 'company-1',
        name: 'Company',
        code: 'C',
        timezone: 'Asia/Dubai',
        defaultLocale: 'en',
        enabledModules: {'employees'},
      ),
    ),
    permissionsLoaded: true,
  );
}

ModuleRegistry _registry() => ModuleRegistry.fromModules([
  AppModule(
    id: AppModuleIds.employees,
    alwaysAvailable: true,
    destinations: [
      RegisteredDestination(
        navigation: ErpModule(
          id: 'live-employees',
          moduleId: AppModuleIds.employees,
          name: (l) => l.employees,
          icon: Icons.people,
          route: AppRoutes.liveEmployees,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.liveEmployees,
            builder: (context, state) => const Text('employees-screen'),
          ),
        ],
      ),
    ],
  ),
]);

Future<GoRouter> _router(
  WidgetTester tester,
  AuthState state,
  String location,
) async {
  final authBloc = _MockAuthBloc();
  when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
  when<AuthState>(() => authBloc.state).thenReturn(state);
  final refresh = ChangeNotifier();
  final shellCubit = AppShellCubit();
  addTearDown(refresh.dispose);
  addTearDown(shellCubit.close);
  final router = createAppRouter(
    authBloc: authBloc,
    authRepository: _MockAuthRepository(),
    refresh: refresh,
    registry: _registry(),
    initialLocation: location,
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<AppShellCubit>.value(value: shellCubit),
      ],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(locale: const Locale('en')),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('deep link without the view key renders the no-permission page', (
    tester,
  ) async {
    await _router(tester, _state({}), AppRoutes.liveEmployees);

    expect(find.byType(UnauthorizedPage), findsOneWidget);
    expect(find.textContaining('hr.employees.view'), findsOneWidget);
    expect(find.text('employees-screen'), findsNothing);
  });

  testWidgets('deep link with the view key opens the screen', (tester) async {
    await _router(
      tester,
      _state({'hr.employees.view'}),
      AppRoutes.liveEmployees,
    );

    expect(find.text('employees-screen'), findsOneWidget);
    expect(find.byType(UnauthorizedPage), findsNothing);
  });

  testWidgets('create deep link requires the create action key', (
    tester,
  ) async {
    await _router(
      tester,
      _state({'hr.employees.view'}),
      '/app/hr/employees/new',
    );

    expect(find.byType(UnauthorizedPage), findsOneWidget);
    expect(find.textContaining('hr.employees.create'), findsOneWidget);
  });
}
