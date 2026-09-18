import 'package:modular_erp/features/employees/presentation/pages/employee_list_page.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/router/app_router.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/app/shell/app_shell.dart';
import 'package:modular_erp/app/shell/app_shell_cubit.dart';
import 'package:modular_erp/app/shell/pages/more_page.dart';
import 'package:modular_erp/app/shell/pages/route_status_pages.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/core/preferences/app_preferences_repository.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/features/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/features/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/features/auth/data/repositories/demo_auth_repository.dart';
import 'package:modular_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/features/auth/presentation/pages/login_page.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'auth_widget_test.dart' as ui_test;
import 'support/memory_preferences.dart';
import 'support/memory_session_storage.dart';

void main() {
  final source = DemoAuthSource();
  AuthContext account(AppRole role) =>
      source.accounts.firstWhere((a) => a.context.user.role == role).context;
  late DemoAuthRepository repository;
  late ModuleRegistry registry;
  late NavigationResolver resolver;
  setUp(() {
    repository = DemoAuthRepository(MemorySessionStorage(), source: source);
    registry = createErpRegistry(repository);
    resolver = NavigationResolver(registry);
  });
  tearDown(() => repository.dispose());
  setUpAll(() async {
    for (final font in {
      'Inter': 'assets/fonts/InterVariable.ttf',
      'NotoSansArabic': 'assets/fonts/NotoSansArabicVariable.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      await (FontLoader(font.key)..addFont(rootBundle.load(font.value))).load();
    }
  });
  test('one module registry supplies typed routes and descriptors', () {
    expect(registry.modules.map((m) => m.id).toSet(), {
      'dashboard',
      'employees',
      'attendance',
      'reports',
      'settings',
      'account',
    });
    expect(registry.registrations.length, 9);
    expect(
      () => ModuleRegistry.fromModules([
        ...registry.modules,
        registry.modules.first,
      ]),
      throwsArgumentError,
    );
    expect(
      () => registry.destinations.add(registry.destinations.first),
      throwsUnsupportedError,
    );
  });
  test('registration rejects a typed route outside its permission owner', () {
    final nav = registry.destinations.firstWhere((d) => d.id == 'employees');
    expect(
      () => ModuleRegistry.fromModules([
        AppModule(
          id: nav.moduleId,
          destinations: [
            RegisteredDestination(
              navigation: nav,
              routes: [
                GoRoute(
                  path: '/app/unguarded',
                  builder: (context, state) => const SizedBox(),
                ),
              ],
            ),
          ],
        ),
      ]),
      throwsArgumentError,
    );
  });
  test('permission-filtered navigation differs across all five demo roles', () {
    final expected = {
      AppRole.employee: ['dashboard', 'attendance', 'profile'],
      AppRole.manager: ['dashboard', 'employees', 'attendance', 'profile'],
      AppRole.hr: [
        'dashboard',
        'employees',
        'attendance',
        'reports',
        'settings',
        'shifts',
        'work-locations',
        'attendance-policies',
        'profile',
      ],
      AppRole.companyAdmin: [
        'dashboard',
        'employees',
        'attendance',
        'reports',
        'settings',
        'shifts',
        'work-locations',
        'attendance-policies',
        'profile',
      ],
      AppRole.superAdmin: [
        'dashboard',
        'employees',
        'attendance',
        'reports',
        'settings',
        'shifts',
        'work-locations',
        'attendance-policies',
        'profile',
      ],
    };
    for (final role in expected.keys) {
      final ctx = account(role);
      expect(
        resolver
            .resolve(ctx.company, ctx.user.permissions)
            .destinations
            .map((d) => d.id),
        expected[role],
      );
    }
    final hrWithoutGrants = account(AppRole.hr).copyWith(
      user: account(AppRole.hr).user.copyWith(permissions: PermissionSet([])),
    );
    expect(
      resolver
          .resolve(hrWithoutGrants.company, hrWithoutGrants.user.permissions)
          .destinations
          .map((d) => d.id),
      ['dashboard', 'profile'],
    );
  });
  test(
    'company module enablement and registry enablement precede permissions',
    () {
      final ctx = account(AppRole.superAdmin);
      final company = ctx.company.copyWith(enabledModules: {'attendance'});
      expect(
        resolver
            .resolve(company, ctx.user.permissions)
            .destinations
            .map((d) => d.id),
        ['attendance', 'profile'],
      );
      expect(
        resolver.routeAccess(
          AppRoutes.employees,
          ctx.copyWith(company: company),
        ),
        RouteAccess.moduleUnavailable,
      );
      final disabled = ModuleRegistry.fromModules([
        for (final m in registry.modules)
          AppModule(
            id: m.id,
            destinations: m.destinations,
            alwaysAvailable: m.alwaysAvailable,
            enabled: m.id != 'attendance',
          ),
      ]);
      expect(
        NavigationResolver(disabled).routeAccess(AppRoutes.attendance, ctx),
        RouteAccess.moduleUnavailable,
      );
    },
  );
  test(
    'permission gate applies to nested paths, aliases and strict boundaries',
    () {
      final employee = account(AppRole.employee);
      expect(
        resolver.routeAccess('/app/employees/123', employee),
        RouteAccess.unauthorized,
      );
      expect(
        resolver.routeAccess(AppRoutes.changePassword, employee),
        RouteAccess.allowed,
      );
      expect(registry.ownerOf('/app/employees/123')!.id, 'employees');
      expect(registry.ownerOf('/app/employees-extra'), isNull);
    },
  );
  test(
    'mobile primary destinations use explicit priorities and reserve More',
    () {
      final ctx = account(AppRole.superAdmin),
          nav = resolver.resolve(
            account(AppRole.superAdmin).company,
            ctx.user.permissions,
          );
      expect(nav.mobilePrimary.map((d) => d.id), [
        'dashboard',
        'employees',
        'attendance',
      ]);
      expect(nav.mobileMore.map((d) => d.id), [
        'reports',
        'settings',
        'shifts',
        'work-locations',
        'attendance-policies',
        'profile',
      ]);
      expect(nav.groupsFor(nav.mobileMore).keys, [
        NavigationGroup.insights,
        NavigationGroup.configuration,
        NavigationGroup.account,
      ]);
      expect(() => nav.mobileMore.clear(), throwsUnsupportedError);
    },
  );
  test(
    'default landing chooses an enabled permitted destination and handles no access',
    () {
      final ctx = account(AppRole.employee);
      expect(
        DefaultLandingResolver(resolver).resolve(ctx),
        AppRoutes.dashboard,
      );
      expect(
        DefaultLandingResolver(resolver).resolve(
          ctx.copyWith(
            company: ctx.company.copyWith(
              enabledModules: {'employees', 'attendance'},
            ),
          ),
        ),
        AppRoutes.attendance,
      );
      expect(
        DefaultLandingResolver(resolver).resolve(
          ctx.copyWith(company: ctx.company.copyWith(enabledModules: {})),
        ),
        AppRoutes.profile,
      );
      expect(
        DefaultLandingResolver(
          NavigationResolver(ModuleRegistry.fromModules([])),
        ).resolve(ctx),
        AppRoutes.noDestinations,
      );
    },
  );
  test(
    'authentication and module guards preserve deep-link query and reject external redirects',
    () {
      final employee = AuthState(
        AuthStatus.authenticated,
        context: account(AppRole.employee),
      );
      expect(
        authRedirect(
          const AuthState(AuthStatus.unauthenticated),
          Uri.parse('/app/employees?view=team'),
          navigation: resolver,
        ),
        '/login?from=%2Fapp%2Femployees%3Fview%3Dteam',
      );
      expect(
        Uri.parse(
          authRedirect(
            employee,
            Uri.parse(AppRoutes.employees),
            navigation: resolver,
          )!,
        ).path,
        AppRoutes.unauthorized,
      );
      expect(
        authRedirect(
          employee,
          Uri.parse('/login?from=//bad.example/app/dashboard'),
          navigation: resolver,
        ),
        AppRoutes.dashboard,
      );
      expect(
        authRedirect(
          employee,
          Uri.parse('/login?from=/app/attendance?view=history'),
          navigation: resolver,
        ),
        '/app/attendance?view=history',
      );
    },
  );
  test(
    'sidebar preference persists without touching session storage and recovers from failures',
    () async {
      final local = MemoryPreferences(),
          prefs = LocalAppPreferencesRepository(MemoryPreferences());
      final cubit = AppShellCubit(LocalAppPreferencesRepository(local));
      await cubit.toggle();
      expect(local.sidebarCollapsed, true);
      final second = AppShellCubit(LocalAppPreferencesRepository(local));
      await second.restore();
      expect(second.state.collapsed, true);
      local.failWrites = true;
      await cubit.toggle();
      expect(cubit.state.failure!.kind, FailureKind.preferencesWrite);
      await cubit.close();
      await second.close();
      expect(
        (await prefs.readSidebarCollapsed() as Success<bool?>).value,
        isNull,
      );
    },
  );
  for (final language in AppLanguage.values) {
    for (final width in [
      360.0,
      390.0,
      430.0,
      600.0,
      768.0,
      900.0,
      1024.0,
      1280.0,
      1440.0,
      1920.0,
    ]) {
      for (final username in ['employee', 'hr', 'admin']) {
        testWidgets('$username ${language.name} shell at $width', (
          tester,
        ) async {
          ui_test.viewport(tester, width);
          final h = await ui_test.mount(tester, language);
          final password = username == 'employee'
              ? 'Employee@123'
              : username == 'hr'
              ? 'Hr@123'
              : 'Admin@123';
          h.auth.add(AuthLoginRequested('$username@erp.demo', password));
          await ui_test.pump(tester);
          expect(find.byType(AppShell), findsOneWidget);
          final ctx = tester.element(find.byType(AppShell));
          expect(
            Directionality.of(ctx),
            language == AppLanguage.arabic
                ? TextDirection.rtl
                : TextDirection.ltr,
          );
          if (width < 600) {
            expect(find.byType(AppBottomNavigation), findsOneWidget);
            expect(find.byType(AppSidebar), findsNothing);
            expect(find.byType(AppNavigationRail), findsNothing);
            final bottom = tester.widget<AppBottomNavigation>(
              find.byType(AppBottomNavigation),
            );
            expect(bottom.modules.length, lessThanOrEqualTo(4));
            expect(
              bottom.modules.map((m) => m.id),
              username == 'employee'
                  ? ['dashboard', 'attendance', 'more']
                  : ['dashboard', 'employees', 'attendance', 'more'],
            );
          } else if (width < 1000) {
            expect(find.byType(AppNavigationRail), findsOneWidget);
            expect(find.byType(NavigationRail), findsOneWidget);
            expect(find.byType(AppBottomNavigation), findsNothing);
          } else {
            expect(find.byType(AppSidebar), findsOneWidget);
            expect(find.byType(AppBottomNavigation), findsNothing);
            final rect = tester.getRect(find.byType(AppSidebar));
            expect(
              rect.center.dx,
              language == AppLanguage.arabic
                  ? greaterThan(width / 2)
                  : lessThan(width / 2),
            );
            final items = tester
                .widget<AppSidebar>(find.byType(AppSidebar))
                .modules
                .map((m) => m.id)
                .toList();
            expect(items.contains('employees'), username != 'employee');
            expect(
              items.contains('settings'),
              username == 'admin' || username == 'hr',
            );
            expect(items.contains('reports'), username != 'employee');
          }
          expect(tester.takeException(), isNull);
          if ((width == 390 || width == 1280) && username != 'admin' ||
              width == 1280 && username == 'admin') {
            await ui_test.screenshot(
              tester,
              h.key,
              'phase2_${username}_${language.name}_${width.toInt()}',
            );
          }
          await ui_test.unmount(tester, h);
        });
      }
    }
    testWidgets(
      '${language.name} More, account language, empty panels and collapse',
      (tester) async {
        ui_test.viewport(tester, 390);
        final h = await ui_test.mount(tester, language);
        h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
        await ui_test.pump(tester);
        final r = ui_test.router(tester);
        final context = tester.element(find.byType(AppShell));
        await tester.tap(
          find.descendant(
            of: find.byType(AppBottomNavigation),
            matching: find.text(context.l10n.shellMore),
          ),
        );
        await ui_test.pump(tester);
        expect(find.byType(MorePage), findsOneWidget);
        expect(find.text(context.l10n.shellReports), findsOneWidget);
        expect(find.text(context.l10n.cfgConfiguration), findsWidgets);
        await ui_test.screenshot(tester, h.key, 'phase2_more_${language.name}');
        await tester.tap(find.byType(AppUserMenu));
        await ui_test.pump(tester);
        await ui_test.screenshot(
          tester,
          h.key,
          'phase2_user_menu_${language.name}',
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await ui_test.pump(tester);
        expect(find.byType(PopupMenuItem<AppUserMenuAction>), findsNothing);
        await tester.tap(find.byTooltip(context.l10n.shellSearchTitle));
        await ui_test.pump(tester);
        expect(find.text(context.l10n.shellSearchMessage), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await ui_test.pump(tester);
        await tester.tap(find.byTooltip(context.l10n.shellNotifications));
        await ui_test.pump(tester);
        expect(find.text(context.l10n.shellNoNotifications), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await ui_test.pump(tester);
        tester.view.physicalSize = const Size(1280, 900);
        await ui_test.pump(tester);
        await tester.tap(find.byTooltip(context.l10n.shellCollapseSidebar));
        await ui_test.pump(tester);
        expect(
          tester.getSize(find.byType(AppSidebar)).width,
          AppDimensions.sidebarCollapsed,
        );
        expect(find.byTooltip(context.l10n.shellEmployees), findsOneWidget);
        await ui_test.screenshot(
          tester,
          h.key,
          'phase2_collapsed_${language.name}',
        );
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(
          tester.getCenter(find.byTooltip(context.l10n.shellAttendance)),
        );
        await ui_test.pump(tester);
        await mouse.removePointer();
        expect(tester.takeException(), isNull);
        expect(identical(ui_test.router(tester), r), true);
        await ui_test.unmount(tester, h);
      },
    );
  }
  testWidgets(
    'manual routes enforce authentication, permissions, enablement and 404',
    (tester) async {
      ui_test.viewport(tester, 1280);
      final h = await ui_test.mount(tester, AppLanguage.english),
          r = ui_test.router(tester);
      r.go(AppRoutes.employees);
      await ui_test.pump(tester);
      expect(find.byType(LoginPage), findsOneWidget);
      h.auth.add(const AuthLoginRequested('employee@erp.demo', 'Employee@123'));
      await ui_test.pump(tester);
      expect(find.byType(UnauthorizedPage), findsOneWidget);
      expect(find.byType(EmployeeListPage), findsNothing);
      r.go('/app/employees/123');
      await ui_test.pump(tester);
      expect(find.byType(UnauthorizedPage), findsOneWidget);
      final ctx = h.auth.state.context!;
      h.auth.add(
        AuthSessionUpdated(
          ctx.copyWith(
            company: ctx.company.copyWith(enabledModules: {'dashboard'}),
          ),
        ),
      );
      await ui_test.pump(tester);
      r.go(AppRoutes.attendance);
      await ui_test.pump(tester);
      expect(find.byType(ModuleUnavailablePage), findsOneWidget);
      r.go('/app/unknown-route');
      await ui_test.pump(tester);
      expect(find.byType(NotFoundPage), findsOneWidget);
      h.auth.add(const AuthLogoutRequested());
      await ui_test.pump(tester);
      h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await ui_test.pump(tester);
      r.go(AppRoutes.employees);
      await ui_test.pump(tester);
      expect(find.byType(EmployeeListPage), findsOneWidget);
      h.auth.add(
        AuthSessionUpdated(
          h.auth.state.context!.copyWith(
            user: h.auth.state.context!.user.copyWith(
              permissions: PermissionSet([]),
            ),
          ),
        ),
      );
      await ui_test.pump(tester);
      expect(find.byType(UnauthorizedPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      await ui_test.unmount(tester, h);
    },
  );
  testWidgets(
    'nested branch route, form state and highlighting survive navigation and resize',
    (tester) async {
      ui_test.viewport(tester, 1280);
      final h = await ui_test.mount(
        tester,
        AppLanguage.english,
        registryFactory: (repo) {
          final normal = createErpRegistry(repo);
          return ModuleRegistry.fromModules([
            for (final m in normal.modules)
              m.id != AppModuleIds.employees
                  ? m
                  : AppModule(
                      id: m.id,
                      destinations: [
                        RegisteredDestination(
                          navigation: m.destinations.first.navigation,
                          routes: [
                            GoRoute(
                              path: AppRoutes.employees,
                              builder: (context, state) => const SizedBox(),
                              routes: [
                                GoRoute(
                                  path: ':id',
                                  builder: (context, state) =>
                                      const _BranchForm(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
          ]);
        },
      );
      h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await ui_test.pump(tester);
      final r = ui_test.router(tester);
      r.go('/app/employees/preview');
      await ui_test.pump(tester);
      await tester.enterText(find.byType(TextFormField), 'retained draft');
      Finder item(String id) =>
          find.byWidgetPredicate((w) => w is AppSidebarItem && w.item.id == id);
      expect(tester.widget<AppSidebarItem>(item('employees')).selected, true);
      await tester.tap(item('attendance'));
      await ui_test.pump(tester);
      await tester.tap(item('employees'));
      await ui_test.pump(tester);
      expect(
        r.routeInformationProvider.value.uri.path,
        '/app/employees/preview',
      );
      expect(find.text('retained draft'), findsOneWidget);
      tester.view.physicalSize = const Size(390, 900);
      await ui_test.pump(tester);
      final saved = h.locale.changeLanguage(AppLanguage.arabic);
      await ui_test.pump(tester);
      await saved;
      expect(find.text('retained draft'), findsOneWidget);
      final bottom = tester.widget<AppBottomNavigation>(
        find.byType(AppBottomNavigation),
      );
      expect(bottom.modules[bottom.index].id, 'employees');
      h.auth.add(const AuthLogoutRequested());
      await ui_test.pump(tester);
      h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await ui_test.pump(tester);
      r.go('/app/employees/preview');
      await ui_test.pump(tester);
      expect(find.text('retained draft'), findsNothing);
      expect(tester.takeException(), isNull);
      await ui_test.unmount(tester, h);
    },
  );
  testWidgets(
    'open account menu tracks locale changes and keeps route selection',
    (tester) async {
      ui_test.viewport(tester, 1280);
      final h = await ui_test.mount(tester, AppLanguage.english);
      h.auth.add(const AuthLoginRequested('admin@erp.demo', 'Admin@123'));
      await ui_test.pump(tester);
      final r = ui_test.router(tester);
      r.go(AppRoutes.employees);
      await ui_test.pump(tester);
      await tester.tap(find.byType(AppUserMenu));
      await ui_test.pump(tester);
      final saved = h.locale.changeLanguage(AppLanguage.arabic);
      await ui_test.pump(tester);
      await saved;
      final ctx = tester.element(find.byType(AppShell));
      expect(
        find.descendant(
          of: find.byType(PopupMenuItem<AppUserMenuAction>),
          matching: find.text(ctx.l10n.authChangePassword),
        ),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await ui_test.pump(tester);
      expect(r.routeInformationProvider.value.uri.path, AppRoutes.employees);
      expect(tester.takeException(), isNull);
      await ui_test.unmount(tester, h);
    },
  );
  testWidgets('Arabic shell supports large text and short tablet height', (
    tester,
  ) async {
    ui_test.viewport(tester, 360);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final h = await ui_test.mount(tester, AppLanguage.arabic);
    h.auth.add(const AuthLoginRequested('admin@erp.demo', 'Admin@123'));
    await ui_test.pump(tester);
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(768, 420);
    await ui_test.pump(tester);
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(1280, 600);
    await ui_test.pump(tester);
    expect(tester.takeException(), isNull);
    await ui_test.unmount(tester, h);
  });
}

/// Test-only branch content demonstrates preservation without adding business screens.
class _BranchForm extends StatefulWidget {
  const _BranchForm();
  @override
  State<_BranchForm> createState() => _BranchFormState();
}

class _BranchFormState extends State<_BranchForm> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppPage(
    child: AppTextField(label: context.l10n.fullName, controller: controller),
  );
}
