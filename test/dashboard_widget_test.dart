import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/app/shell/app_shell.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contribution.dart';
import 'package:modular_erp/platform/workspace/dashboard/domain/dashboard_contributor.dart';
import 'package:modular_erp/platform/workspace/dashboard/presentation/bloc/universal_dashboard_bloc.dart';
import 'package:modular_erp/platform/workspace/dashboard/presentation/universal_dashboard_page.dart';
import 'auth_widget_test.dart' as ui_test;

class _FakeContributor implements DashboardContributor {
  const _FakeContributor();
  @override
  String get id => 'hr';
  @override
  String get moduleId => 'hr';
  @override
  int get order => 10;
  @override
  bool isVisible(DashboardCapabilityContext context) => true;
  @override
  Future<DashboardContribution> load(DashboardCapabilityContext context) async {
    return DashboardContribution(
      moduleId: 'hr',
      kpis: [
        DashboardKpi(
          id: 'hr-present',
          moduleId: 'hr',
          label: context.l10n.dashboardPresent,
          value: '73',
          icon: Icons.check_circle_outline,
          tone: DashboardTone.success,
        ),
      ],
      attention: [
        DashboardAttentionItem(
          id: 'hr-a1',
          moduleId: 'hr',
          type: 'late',
          title: context.l10n.dashboardLateAlert('5'),
          subtitle: context.l10n.dashboardLateAlertDetail,
          icon: Icons.schedule,
          priority: 40,
          tone: DashboardTone.warning,
          route: AppRoutes.attendance,
        ),
      ],
    );
  }
}

class _ThrowingCoordinator extends UniversalDashboardCoordinator {
  const _ThrowingCoordinator() : super(const []);
  @override
  Future<UniversalDashboardSnapshot> load(
    DashboardCapabilityContext context,
  ) async => throw StateError('coordinator failure');
}

AuthContext _auth() {
  final source = DemoAuthSource();
  return source.findByScenario(DemoScenario.hr)!.context;
}

Widget _app(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

const _accounts = {
  'employee': 'Employee@123',
  'manager': 'Manager@123',
  'hr': 'Hr@123',
  'admin': 'Admin@123',
  'company': 'Company@123',
};

const _widths = [
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
];

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    for (final font in {
      'Manrope': 'assets/fonts/Manrope-SemiBold.ttf',
      'IBMPlexSansArabic': 'assets/fonts/IBMPlexSansArabic-Regular.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      await (FontLoader(font.key)..addFont(rootBundle.load(font.value))).load();
    }
  });

  Future<AppLocalizations> l10n(Locale locale) =>
      AppLocalizations.delegate.load(locale);

  testWidgets('shows a skeleton while loading', (tester) async {
    final context = _auth();
    final english = await l10n(const Locale('en'));
    final bloc = UniversalDashboardBloc(
      const UniversalDashboardCoordinator([_FakeContributor()]),
      context,
      english,
    );
    addTearDown(bloc.close);
    await tester.pumpWidget(
      _app(
        BlocProvider.value(value: bloc, child: const UniversalDashboardView()),
      ),
    );
    await tester.pump();
    expect(find.byType(AppDashboardSkeleton), findsOneWidget);
  });

  testWidgets('renders ready contributions and Arabic RTL', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final context = _auth();
    final arabic = await l10n(const Locale('ar'));
    final bloc = UniversalDashboardBloc(
      const UniversalDashboardCoordinator([_FakeContributor()]),
      context,
      arabic,
    );
    addTearDown(bloc.close);
    await tester.pumpWidget(
      _app(
        BlocProvider.value(value: bloc, child: const UniversalDashboardView()),
        locale: const Locale('ar'),
      ),
    );
    bloc.add(const UniversalDashboardStarted());
    await ui_test.pump(tester);
    expect(
      find.byKey(const ValueKey('universal-kpi-hr-present')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('universal-attention-hr-a1')),
      findsOneWidget,
    );
    expect(
      Directionality.of(tester.element(find.byType(UniversalDashboardView))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('surfaces a recoverable error state', (tester) async {
    final context = _auth();
    final english = await l10n(const Locale('en'));
    final bloc = UniversalDashboardBloc(
      const _ThrowingCoordinator(),
      context,
      english,
    );
    addTearDown(bloc.close);
    await tester.pumpWidget(
      _app(
        BlocProvider.value(value: bloc, child: const UniversalDashboardView()),
      ),
    );
    bloc.add(const UniversalDashboardStarted());
    await ui_test.pump(tester);
    expect(find.byType(AppErrorState), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final language in AppLanguage.values) {
    for (final account in _accounts.entries) {
      for (final width in _widths) {
        testWidgets('${account.key} ${language.name} dashboard at $width', (
          tester,
        ) async {
          ui_test.viewport(tester, width);
          final h = await ui_test.mount(tester, language);
          h.auth.add(
            AuthLoginRequested('${account.key}@erp.demo', account.value),
          );
          await ui_test.pump(tester);
          expect(find.byType(UniversalDashboardView), findsOneWidget);
          expect(find.byType(AppShell), findsOneWidget);
          expect(
            ui_test.router(tester).routeInformationProvider.value.uri.path,
            AppRoutes.dashboard,
          );
          expect(
            Directionality.of(
              tester.element(find.byType(UniversalDashboardView)),
            ),
            language == AppLanguage.arabic
                ? TextDirection.rtl
                : TextDirection.ltr,
          );
          expect(tester.takeException(), isNull);
          await ui_test.unmount(tester, h);
        });
      }
    }
    for (final account in _accounts.entries) {
      testWidgets('${account.key} ${language.name} enlarged text', (
        tester,
      ) async {
        ui_test.viewport(tester, 360);
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final h = await ui_test.mount(tester, language);
        h.auth.add(
          AuthLoginRequested('${account.key}@erp.demo', account.value),
        );
        await ui_test.pump(tester);
        expect(find.byType(UniversalDashboardView), findsOneWidget);
        expect(tester.takeException(), isNull);
        await ui_test.unmount(tester, h);
      });
    }
  }

  testWidgets('legacy module dashboard URLs redirect to the canonical route', (
    tester,
  ) async {
    ui_test.viewport(tester, 1280);
    final h = await ui_test.mount(tester, AppLanguage.english);
    h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
    await ui_test.pump(tester);
    ui_test.router(tester).go('/app/hr/dashboard');
    await ui_test.pump(tester);
    expect(
      ui_test.router(tester).routeInformationProvider.value.uri.path,
      AppRoutes.dashboard,
    );
    ui_test.router(tester).go('/app/services/dashboard');
    await ui_test.pump(tester);
    expect(
      ui_test.router(tester).routeInformationProvider.value.uri.path,
      AppRoutes.dashboard,
    );
    ui_test.router(tester).go('/app/services');
    await ui_test.pump(tester);
    expect(tester.takeException(), isNull);
    ui_test.router(tester).go('/app/hr');
    await ui_test.pump(tester);
    expect(tester.takeException(), isNull);
    await ui_test.unmount(tester, h);
  });
}
