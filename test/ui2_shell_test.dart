import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/module_registry/navigation_resolver.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/app/shell/app_shell.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/data/repositories/demo_auth_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

import 'auth_widget_test.dart' as harness;
import 'support/memory_session_storage.dart';

void main() {
  final source = DemoAuthSource();
  AuthContext account(DemoScenario role) =>
      source.accounts.firstWhere((a) => a.scenario == role).context;

  NavigationResolver resolver() => NavigationResolver(
    createErpRegistry(
      DemoAuthRepository(MemorySessionStorage(), source: source),
    ),
  );

  group('UI-2 navigation model', () {
    test('Dashboard appears exactly once and no module owns a dashboard', () {
      final nav = resolver().resolve(
        account(DemoScenario.platformAdmin).company,
        account(DemoScenario.platformAdmin).user.permissions,
        employee: account(DemoScenario.platformAdmin).employeeReference,
      );
      expect(nav.destinations.where((d) => d.id == 'dashboard'), hasLength(1));
      expect(
        nav.destinations.where((d) => d.section == NavigationSection.dashboard),
        hasLength(1),
      );
      // HR / Services never register a competing dashboard.
      expect(
        nav.destinations.where(
          (d) =>
              d.section != NavigationSection.dashboard &&
              d.route.contains('dashboard'),
        ),
        isEmpty,
      );
    });

    test('canonical section order is fixed and empty groups vanish', () {
      expect(NavigationSection.values, [
        NavigationSection.dashboard,
        NavigationSection.hr,
        NavigationSection.services,
        NavigationSection.settings,
        NavigationSection.account,
      ]);
      final ctx = account(DemoScenario.platformAdmin);
      final onlyDashboard = resolver().resolve(
        ctx.company.copyWith(enabledModules: {'dashboard'}),
        ctx.user.permissions,
        employee: ctx.employeeReference,
      );
      final grouped = onlyDashboard.sectionsFor(onlyDashboard.desktop);
      expect(grouped.keys, [
        NavigationSection.dashboard,
        NavigationSection.account,
      ]);
      expect(grouped.containsKey(NavigationSection.hr), isFalse);
      expect(grouped.containsKey(NavigationSection.services), isFalse);
    });

    test('company switch recomputes navigation and the selected owner', () {
      final ctx = account(DemoScenario.platformAdmin);
      final full = resolver().resolve(
        ctx.company,
        ctx.user.permissions,
        employee: ctx.employeeReference,
      );
      final limited = resolver().resolve(
        ctx.company.copyWith(enabledModules: {'dashboard'}),
        ctx.user.permissions,
        employee: ctx.employeeReference,
      );
      expect(full.desktop.map((d) => d.id), contains('employees'));
      expect(limited.desktop.map((d) => d.id), isNot(contains('employees')));
      // A stale selection from the prior company cannot resolve to an owner.
      final owner = limited.desktop
          .where((m) => m.owns(AppRoutes.employees))
          .toList();
      expect(owner, isEmpty);
    });
  });

  group('UI-2 shell widgets', () {
    testWidgets(
      'desktop sidebar has hierarchy, one Dashboard and group labels',
      (tester) async {
        harness.viewport(tester, 1600);
        final h = await harness.mount(
          tester,
          AppLanguage.english,
          withServices: true,
        );
        h.auth.add(const AuthLoginRequested('admin@erp.demo', 'Admin@123'));
        await harness.pump(tester);
        expect(find.byType(AppShell), findsOneWidget);
        final ctx = tester.element(find.byType(AppShell));

        final sidebar = tester.widget<AppSidebar>(find.byType(AppSidebar));
        expect(sidebar.modules.where((m) => m.id == 'dashboard'), hasLength(1));
        expect(
          find.byWidgetPredicate(
            (w) => w is AppSidebarItem && w.item.id == 'dashboard',
          ),
          findsOneWidget,
        );
        expect(find.text(ctx.l10n.navSectionHr), findsOneWidget);
        expect(find.text(ctx.l10n.navSectionServices), findsOneWidget);
        // The sidebar consumes centralized width.
        expect(
          tester.getSize(find.byType(AppSidebar)).width,
          AppDimensions.sidebar,
        );
        expect(tester.takeException(), isNull);
        await harness.unmount(tester, h);
      },
    );

    testWidgets('notification control and profile menu are real, not fake', (
      tester,
    ) async {
      harness.viewport(tester, 1280);
      final h = await harness.mount(tester, AppLanguage.english);
      h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await harness.pump(tester);
      final ctx = tester.element(find.byType(AppShell));

      // Notification control with tooltip; no decorative global search.
      expect(find.byType(AppNotificationButton), findsOneWidget);
      expect(find.byTooltip(ctx.l10n.shellNotifications), findsOneWidget);
      expect(find.byTooltip(ctx.l10n.shellSearchTitle), findsNothing);

      await tester.tap(find.byType(AppUserMenu));
      await harness.pump(tester);
      expect(
        find.widgetWithText(
          PopupMenuItem<AppUserMenuAction>,
          ctx.l10n.shellProfile,
        ),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(PopupMenuItem<AppUserMenuAction>, ctx.l10n.logout),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await harness.pump(tester);
      expect(tester.takeException(), isNull);
      await harness.unmount(tester, h);
    });

    testWidgets('mobile More sheet keeps company context and grouping', (
      tester,
    ) async {
      harness.viewport(tester, 390);
      final h = await harness.mount(tester, AppLanguage.english);
      h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await harness.pump(tester);
      final ctx = tester.element(find.byType(AppShell));
      await tester.tap(
        find.descendant(
          of: find.byType(AppBottomNavigation),
          matching: find.text(ctx.l10n.shellMore),
        ),
      );
      await harness.pump(tester);
      expect(find.byType(AppMobileNavigation), findsOneWidget);
      expect(find.byType(AppCompanySwitcher), findsOneWidget);
      expect(find.text(ctx.l10n.shellReports), findsOneWidget);
      expect(tester.takeException(), isNull);
      await harness.unmount(tester, h);
    });

    testWidgets('shell holds at maximum allowed text scale 1.3', (
      tester,
    ) async {
      harness.viewport(tester, 1024);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final h = await harness.mount(tester, AppLanguage.arabic);
      h.auth.add(const AuthLoginRequested('admin@erp.demo', 'Admin@123'));
      await harness.pump(tester);
      expect(find.byType(AppShell), findsOneWidget);
      expect(tester.takeException(), isNull);
      await harness.unmount(tester, h);
    });
  });
}
