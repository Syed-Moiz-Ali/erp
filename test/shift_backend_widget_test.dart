import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/app/app_environment.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/shifts/presentation/pages/shift_details_page.dart';
import 'package:modular_erp/modules/hr/shifts/presentation/pages/shift_form_page.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';

import 'auth_widget_test.dart' as h;
import 'employee_widget_test.dart' show settleDb;

void main() {
  setUp(AppConfig.reset);
  tearDown(AppConfig.reset);

  testWidgets(
    'backend shift forms hide local-only fields and show early punch',
    (t) async {
      h.viewport(t, 390);
      final app = await h.mount(t, AppLanguage.english);
      final account = DemoAuthSource().findByScenario(DemoScenario.hr)!;
      app.auth.add(
        AuthLoginRequested(account.context.user.email, account.password),
      );
      await h.pump(t);

      AppConfig.configure(
        const AppEnvironment(
          name: EnvironmentConfig.developmentName,
          apiBaseUrl: 'https://dev.example.test',
          authMode: AuthMode.backend,
          allowInsecureHttp: false,
        ),
      );

      h.router(t).go(AppRoutes.shiftsNew);
      await settleDb(t);
      final form = t.element(find.byType(ShiftFormPage));
      expect(find.text(form.l10n.cfgEarlyPunch), findsOneWidget);
      expect(find.text(form.l10n.cfgCode), findsNothing);
      expect(find.text(form.l10n.cfgMinimumWork), findsNothing);
      expect(find.text(form.l10n.cfgBreakRules), findsNothing);
      expect(find.byType(AppWeekdaySelector), findsNothing);

      h.router(t).go(AppRoutes.shiftsDetails('shift-night'));
      await settleDb(t);
      final details = t.element(find.byType(ShiftDetailsPage));
      expect(find.text(details.l10n.cfgEarlyPunch), findsOneWidget);
      expect(find.text(details.l10n.cfgCode), findsNothing);
      expect(find.text(details.l10n.cfgDays), findsNothing);
      expect(find.text(details.l10n.cfgExpectedWork), findsNothing);
      expect(find.text(details.l10n.cfgBreakMode), findsNothing);

      await h.unmount(t, app);
    },
  );

  testWidgets('demo shift forms keep the local-only fields', (t) async {
    h.viewport(t, 390);
    final app = await h.mount(t, AppLanguage.english);
    final account = DemoAuthSource().findByScenario(DemoScenario.hr)!;
    app.auth.add(
      AuthLoginRequested(account.context.user.email, account.password),
    );
    await h.pump(t);

    h.router(t).go(AppRoutes.shiftsNew);
    await settleDb(t);
    final form = t.element(find.byType(ShiftFormPage));
    expect(find.text(form.l10n.cfgCode), findsWidgets);
    expect(find.text(form.l10n.cfgMinimumWork), findsWidgets);
    expect(find.text(form.l10n.cfgBreakRules), findsWidgets);
    expect(find.byType(AppWeekdaySelector), findsOneWidget);
    expect(find.text(form.l10n.cfgEarlyPunch), findsNothing);

    h.router(t).go(AppRoutes.shiftsDetails('shift-night'));
    await settleDb(t);
    final details = t.element(find.byType(ShiftDetailsPage));
    expect(find.text(details.l10n.cfgCode), findsWidgets);
    expect(find.text(details.l10n.cfgDays), findsWidgets);
    expect(find.text(details.l10n.cfgExpectedWork), findsWidgets);
    expect(find.text(details.l10n.cfgBreakMode), findsWidgets);
    expect(find.text(details.l10n.cfgEarlyPunch), findsNothing);

    await h.unmount(t, app);
  });
}
