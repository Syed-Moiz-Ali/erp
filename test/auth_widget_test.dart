import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/core/location/location_service.dart';
import 'package:modular_erp/modules/hr/demo/demo_configuration_seed.dart';
import 'package:modular_erp/modules/hr/shifts/data/local_shift_repository.dart';
import 'package:modular_erp/modules/hr/work_locations/data/local_work_location_repository.dart';
import 'package:modular_erp/modules/hr/attendance_policies/data/local_attendance_policy_repository.dart';
import 'package:drift/native.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/modules/hr/employees/data/employee_seed.dart';
import 'package:modular_erp/modules/hr/employees/data/employee_dao.dart';
import 'package:modular_erp/modules/hr/employees/data/local_employee_repository.dart';
import 'package:modular_erp/modules/hr/employees/data/account_provisioning_repository.dart';
import 'package:modular_erp/modules/hr/module/workforce_directory_adapter.dart';
import 'package:modular_erp/modules/services/configuration/data/local_service_master_repository.dart';
import 'package:modular_erp/modules/services/customers/data/local_service_customer_repository.dart';
import 'package:modular_erp/modules/services/demo/services_demo_seed.dart';
import 'package:modular_erp/modules/services/sites/data/local_service_site_repository.dart';
import 'package:modular_erp/modules/services/teams/data/local_service_team_repository.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/shared/transactions/data/local_activity_repository.dart';
import 'package:modular_erp/shared/transactions/data/local_document_number_service.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/shell/app_shell_cubit.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/erp_app.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/core/localization/locale_cubit.dart';
import 'package:modular_erp/core/preferences/app_preferences_repository.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/auth/auth_identifier.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/platform/access/application/user_grants_controller.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/data/repositories/demo_auth_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/platform/auth/presentation/pages/bootstrap_page.dart';
import 'package:modular_erp/platform/auth/presentation/pages/login_page.dart';
import 'package:modular_erp/platform/auth/presentation/pages/forgot_password_page.dart';
import 'package:modular_erp/platform/auth/presentation/pages/change_password_page.dart';
import 'package:modular_erp/app/shell/app_shell.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'support/memory_preferences.dart';
import 'support/memory_session_storage.dart';

class MockAuth extends Mock implements AuthRepository {}

Future<void> pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

class Harness {
  Harness(this.auth, this.locale, this.repository, this.key, this.database);
  final AppDatabase? database;
  final AuthBloc auth;
  final LocaleCubit locale;
  final AuthRepository repository;
  final GlobalKey key;
  bool disposed = false;
}

Future<Harness> mount(
  WidgetTester tester,
  AppLanguage language, {
  AuthRepository? repository,
  bool bootstrap = true,
  ModuleRegistry Function(AuthRepository)? registryFactory,
  AppShellCubit? shellCubit,
  LocationService? locationService,
  AttendanceBloc Function(AuthRepository, AppDatabase)? createAttendanceBloc,
  AppClock? attendanceClock,
  UserGrantsController? grants,
  bool withServices = false,
}) async {
  final locale = LocaleCubit(
    LocalAppPreferencesRepository(
      MemoryPreferences(code: language.locale.languageCode),
    ),
  );
  await locale.restore([const Locale('en')]);
  final source = DemoAuthSource();
  final repo =
      repository ?? DemoAuthRepository(MemorySessionStorage(), source: source);
  final auth = AuthBloc(repo, grants: grants), key = GlobalKey();
  AppDatabase? database;
  ModuleRegistry? registry;
  if (registryFactory == null) {
    database = AppDatabase(NativeDatabase.memory());
    await tester.runAsync(() async {
      await seedEmployees(database!);
      await seedAttendanceConfiguration(database);
    });
    final employees = LocalEmployeeRepository(
      EmployeeDao(database),
      LocalAccountProvisioningRepository(database),
    );
    if (withServices) {
      final clock = const SystemAppClock();
      final numbers = LocalDocumentNumberService(database, clock);
      final activity = LocalActivityRepository(database);
      await tester.runAsync(
        () => seedServicesDemoData(
          database!,
          source.findByScenario(DemoScenario.platformAdmin)!.context,
          clock,
        ),
      );
      registry = createErpRegistry(
        repo,
        locationService: locationService,
        shiftRepository: LocalShiftRepository(database),
        workLocationRepository: LocalWorkLocationRepository(database),
        attendancePolicyRepository: LocalAttendancePolicyRepository(database),
        employeeRepository: employees,
        serviceCustomerRepository: LocalServiceCustomerRepository(
          database,
          clock,
          numbers,
          activity,
        ),
        serviceSiteRepository: LocalServiceSiteRepository(
          database,
          clock,
          numbers,
          activity,
        ),
        serviceTeamRepository: LocalServiceTeamRepository(
          database,
          clock,
          numbers,
          activity,
          HrWorkforceDirectory(repo, employees),
        ),
        serviceMasterRepository: LocalServiceMasterRepository(
          database,
          clock,
          activity,
        ),
        workforceDirectory: HrWorkforceDirectory(repo, employees),
        activityRepository: activity,
      );
    } else {
      registry = createErpRegistry(
        repo,
        locationService: locationService,
        shiftRepository: LocalShiftRepository(database),
        workLocationRepository: LocalWorkLocationRepository(database),
        attendancePolicyRepository: LocalAttendancePolicyRepository(database),
        employeeRepository: employees,
      );
    }
  } else {
    registry = registryFactory(repo);
  }
  final h = Harness(auth, locale, repo, key, database);
  addTearDown(() async {
    if (!h.disposed) await unmount(tester, h);
  });
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: ErpApp(
        localeCubit: locale,
        authBloc: auth,
        moduleRegistry: registry,
        shellCubit: shellCubit,
        attendanceClock: attendanceClock,
        attendanceBlocFactory: createAttendanceBloc == null
            ? null
            : () => createAttendanceBloc(repo, database!),
        demoAccounts: source.credentials,
      ),
    ),
  );
  await pump(tester);
  if (bootstrap) {
    auth.add(const AuthBootstrapRequested());
    await pump(tester);
  }
  return h;
}

Future<void> unmount(WidgetTester tester, Harness h) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await pump(tester);
  final repositoryClosing = h.repository.dispose();
  await pump(tester);
  await repositoryClosing;
  await tester.runAsync(h.auth.close);
  final localeClosing = h.locale.close();
  await pump(tester);
  await localeClosing;
  await tester.runAsync(() async {
    await h.database?.close();
  });
  h.disposed = true;
}

GoRouter router(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(Scaffold).first));
void viewport(WidgetTester tester, double width) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 900);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Future<void> screenshot(WidgetTester tester, GlobalKey key, String name) async {
  await pump(tester);
  await tester.runAsync(() async {
    final image =
        await (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
            .toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('artifacts/auth_$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await pump(tester);
  await tester.tap(finder);
  await pump(tester);
}

void main() {
  setUpAll(() async {
    registerFallbackValue(AuthIdentifier.parse('hr@erp.demo')!);
    const fontFiles = <String, List<String>>{
      'Manrope': [
        'assets/fonts/Manrope-Regular.ttf',
        'assets/fonts/Manrope-Medium.ttf',
        'assets/fonts/Manrope-SemiBold.ttf',
        'assets/fonts/Manrope-Bold.ttf',
        'assets/fonts/Manrope-ExtraBold.ttf',
      ],
      'IBMPlexSansArabic': [
        'assets/fonts/IBMPlexSansArabic-Regular.ttf',
        'assets/fonts/IBMPlexSansArabic-Medium.ttf',
        'assets/fonts/IBMPlexSansArabic-SemiBold.ttf',
        'assets/fonts/IBMPlexSansArabic-Bold.ttf',
      ],
      'MaterialIcons': ['fonts/MaterialIcons-Regular.otf'],
    };
    for (final entry in fontFiles.entries) {
      final loader = FontLoader(entry.key);
      for (final path in entry.value) {
        loader.addFont(rootBundle.load(path));
      }
      await loader.load();
    }
  });
  testWidgets('demo persona picker lists access and signs in with one tap', (
    tester,
  ) async {
    final h = await mount(tester, AppLanguage.english);
    await tester.tap(find.byKey(const ValueKey('login-demo-accounts')));
    await pump(tester);
    expect(find.text('Super admin'), findsOneWidget);
    expect(find.text('Company admin'), findsOneWidget);
    expect(find.text('HR'), findsOneWidget);
    expect(find.text('Manager'), findsOneWidget);
    expect(find.text('Employee'), findsOneWidget);
    expect(find.text('Every company module and access'), findsOneWidget);
    final managerCard = find.byKey(const ValueKey('demo-persona-manager'));
    await tester.ensureVisible(managerCard);
    await pump(tester);
    await tester.tap(managerCard);
    await pump(tester);
    await pump(tester);
    expect(find.text('Super admin'), findsNothing);
    expect(h.auth.state.isAuthenticated, isTrue);
    await unmount(tester, h);
  });

  for (final language in AppLanguage.values) {
    for (final width in [
      360.0,
      390.0,
      430.0,
      600.0,
      768.0,
      1024.0,
      1280.0,
      1440.0,
      1920.0,
    ]) {
      testWidgets('${language.name} all authentication pages fit $width', (
        tester,
      ) async {
        viewport(tester, width);
        final h = await mount(tester, language, bootstrap: false);
        expect(find.byType(BootstrapPage), findsOneWidget);
        expect(tester.takeException(), isNull);
        h.auth.add(const AuthBootstrapRequested());
        await pump(tester);
        final context = tester.element(find.byType(LoginPage));
        expect(find.text(context.l10n.authWelcomeBack), findsOneWidget);
        expect(
          Directionality.of(context),
          language == AppLanguage.arabic
              ? TextDirection.rtl
              : TextDirection.ltr,
        );
        expect(
          tester.getSize(find.byKey(const ValueKey('login-identifier'))).width,
          lessThanOrEqualTo(460),
        );
        expect(tester.takeException(), isNull);
        if (width == 390 || width == 1280) {
          await screenshot(
            tester,
            h.key,
            '${language.name}_${width.toInt()}_login',
          );
        }
        final r = router(tester);
        r.go('/forgot-password');
        await pump(tester);
        expect(find.byType(ForgotPasswordPage), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (width == 390 || width == 1280) {
          await screenshot(
            tester,
            h.key,
            '${language.name}_${width.toInt()}_forgot',
          );
        }
        h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
        await pump(tester);
        expect(find.byType(AppShell), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (width == 390 || width == 1280) {
          await screenshot(
            tester,
            h.key,
            '${language.name}_${width.toInt()}_home',
          );
        }
        r.go('/app/change-password');
        await pump(tester);
        expect(find.byType(ChangePasswordPage), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (width == 390 || width == 1280) {
          await screenshot(
            tester,
            h.key,
            '${language.name}_${width.toInt()}_change',
          );
        }
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -700),
        );
        await pump(tester);
        expect(tester.takeException(), isNull);
        await unmount(tester, h);
      });
    }
    testWidgets(
      '${language.name} login validation, reveal and retained failure input',
      (tester) async {
        viewport(tester, 390);
        final h = await mount(tester, language);
        var context = tester.element(find.byType(LoginPage));
        await tapVisible(tester, find.byKey(const ValueKey('login-submit')));
        expect(find.text(context.l10n.authIdentifierRequired), findsOneWidget);
        expect(find.text(context.l10n.authPasswordRequired), findsOneWidget);
        await tester.enterText(
          find.descendant(
            of: find.byKey(const ValueKey('login-identifier')),
            matching: find.byType(TextFormField),
          ),
          'hr@erp.demo',
        );
        await tester.enterText(
          find.descendant(
            of: find.byKey(const ValueKey('login-password')),
            matching: find.byType(TextFormField),
          ),
          'wrong',
        );
        final password = find.descendant(
          of: find.byKey(const ValueKey('login-password')),
          matching: find.byType(TextFormField),
        );
        expect(
          tester
              .widget<EditableText>(
                find.descendant(
                  of: password,
                  matching: find.byType(EditableText),
                ),
              )
              .obscureText,
          true,
        );
        await tapVisible(tester, find.byTooltip(context.l10n.showPassword));
        expect(
          tester
              .widget<EditableText>(
                find.descendant(
                  of: password,
                  matching: find.byType(EditableText),
                ),
              )
              .obscureText,
          false,
        );
        await tapVisible(tester, find.byKey(const ValueKey('login-submit')));
        context = tester.element(find.byType(LoginPage));
        expect(find.text(context.l10n.authInvalidCredentials), findsOneWidget);
        expect(
          tester
              .widget<TextFormField>(
                find.descendant(
                  of: find.byKey(const ValueKey('login-identifier')),
                  matching: find.byType(TextFormField),
                ),
              )
              .controller!
              .text,
          'hr@erp.demo',
        );
        expect(tester.takeException(), isNull);
        await unmount(tester, h);
      },
    );
    testWidgets('${language.name} forgot/change/logout frontend workflows', (
      tester,
    ) async {
      viewport(tester, 430);
      final h = await mount(tester, language);
      final r = router(tester);
      r.go('/forgot-password');
      await pump(tester);
      var context = tester.element(find.byType(ForgotPasswordPage));
      await tester.enterText(find.byType(TextFormField), 'unknown@erp.demo');
      await tapVisible(
        tester,
        find.widgetWithText(AppPrimaryButton, context.l10n.continueAction),
      );
      expect(find.text(context.l10n.authResetInformation), findsOneWidget);
      expect(find.text(context.l10n.authResetDemoNote), findsOneWidget);
      h.auth.add(const AuthLoginRequested('employee@erp.demo', 'Employee@123'));
      await pump(tester);
      r.go('/app/change-password');
      await pump(tester);
      context = tester.element(find.byType(ChangePasswordPage));
      await tester.enterText(find.byType(TextFormField).at(0), 'Employee@123');
      await tester.enterText(find.byType(TextFormField).at(1), 'Better@123');
      await tester.enterText(find.byType(TextFormField).at(2), 'Other@123');
      await tapVisible(
        tester,
        find.widgetWithText(AppPrimaryButton, context.l10n.authChangePassword),
      );
      expect(find.text(context.l10n.authPasswordsMismatch), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(2), 'Better@123');
      await tapVisible(
        tester,
        find.widgetWithText(AppPrimaryButton, context.l10n.authChangePassword),
      );
      expect(find.text(context.l10n.authPasswordChanged), findsOneWidget);
      r.go('/app');
      await pump(tester);
      context = tester.element(find.byType(AppShell));
      await tapVisible(tester, find.byType(AppUserMenu));
      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is PopupMenuItem<AppUserMenuAction> &&
              w.value == AppUserMenuAction.logout,
        ),
      );
      await pump(tester);
      expect(find.text(context.l10n.authConfirmLogout), findsOneWidget);
      await screenshot(tester, h.key, '${language.name}_logout_dialog');
      await tester.tap(
        find.descendant(
          of: find.byType(AppDialog),
          matching: find.widgetWithText(AppPrimaryButton, context.l10n.logout),
        ),
      );
      await pump(tester);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(
        await (h.repository as DemoAuthRepository).storage.readSession(),
        isNull,
      );
      expect(tester.takeException(), isNull);
      await unmount(tester, h);
    });
  }
  testWidgets(
    'language switch retains form, focus, router and translates existing validation',
    (tester) async {
      viewport(tester, 390);
      final h = await mount(tester, AppLanguage.english);
      final r = router(tester);
      await tester.enterText(
        find.descendant(
          of: find.byKey(const ValueKey('login-identifier')),
          matching: find.byType(TextFormField),
        ),
        'hr@erp.demo',
      );
      await tapVisible(tester, find.byKey(const ValueKey('login-submit')));
      final saved = h.locale.changeLanguage(AppLanguage.arabic);
      await pump(tester);
      await saved;
      final context = tester.element(find.byType(LoginPage));
      expect(Directionality.of(context), TextDirection.rtl);
      expect(find.text(context.l10n.authPasswordRequired), findsOneWidget);
      expect(find.text('hr@erp.demo'), findsOneWidget);
      expect(identical(router(tester), r), true);
      expect(tester.takeException(), isNull);
      await unmount(tester, h);
    },
  );
  testWidgets('login loading preserves form and blocks duplicate submission', (
    tester,
  ) async {
    viewport(tester, 390);
    final mock = MockAuth(), gate = Completer<Result<AuthContext>>();
    when(() => mock.sessionChanges).thenAnswer((_) => const Stream.empty());
    when(
      () => mock.restoreSession(),
    ).thenAnswer((_) async => const Success(null));
    when(() => mock.dispose()).thenAnswer((_) async {});
    when(() => mock.login(any(), any())).thenAnswer((_) => gate.future);
    final h = await mount(tester, AppLanguage.english, repository: mock);
    await tester.enterText(find.byType(TextFormField).at(0), 'hr@erp.demo');
    await tester.enterText(find.byType(TextFormField).at(1), 'Hr@123');
    final before = tester.getSize(find.byKey(const ValueKey('login-submit')));
    await tapVisible(tester, find.byKey(const ValueKey('login-submit')));
    expect(
      tester
          .widget<AppPrimaryButton>(find.byKey(const ValueKey('login-submit')))
          .loading,
      true,
    );
    expect(tester.getSize(find.byKey(const ValueKey('login-submit'))), before);
    expect(find.byType(LoginPage), findsOneWidget);
    gate.complete(
      const Failed(
        Failure(code: 'invalid', kind: FailureKind.invalidCredentials),
      ),
    );
    await pump(tester);
    verify(() => mock.login(any(), any())).called(1);
    await unmount(tester, h);
  });
  testWidgets('real router protects deep link and returns after login', (
    tester,
  ) async {
    final h = await mount(tester, AppLanguage.english);
    final r = router(tester);
    r.go('/app/change-password');
    await pump(tester);
    expect(r.routeInformationProvider.value.uri.path, '/login');
    h.auth.add(const AuthLoginRequested('manager@erp.demo', 'Manager@123'));
    await pump(tester);
    expect(r.routeInformationProvider.value.uri.path, '/app/change-password');
    r.go('/login');
    await pump(tester);
    expect(r.routeInformationProvider.value.uri.path, '/app/hr');
    await unmount(tester, h);
  });
  testWidgets(
    'session timer redirects to localized login and clears secure data',
    (tester) async {
      final h = await mount(tester, AppLanguage.arabic);
      h.auth.add(const AuthLoginRequested('hr@erp.demo', 'Hr@123'));
      await pump(tester);
      expect(find.byType(AppShell), findsOneWidget);
      await tester.pump(const Duration(hours: 9));
      await pump(tester);
      expect(find.byType(LoginPage), findsOneWidget);
      final context = tester.element(find.byType(LoginPage));
      expect(find.text(context.l10n.failureSessionExpired), findsOneWidget);
      expect(
        await (h.repository as DemoAuthRepository).storage.readSession(),
        isNull,
      );
      await unmount(tester, h);
    },
  );
  testWidgets('keyboard advances focus and Enter submits login', (
    tester,
  ) async {
    final h = await mount(tester, AppLanguage.english);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'employee@erp.demo',
    );
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await pump(tester);
    final password = tester.widget<EditableText>(
      find.descendant(
        of: find.byType(TextFormField).at(1),
        matching: find.byType(EditableText),
      ),
    );
    expect(password.focusNode.hasFocus, true);
    await tester.enterText(find.byType(TextFormField).at(1), 'Employee@123');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pump(tester);
    expect(find.byType(AppShell), findsOneWidget);
    await unmount(tester, h);
  });
  testWidgets('Arabic login handles keyboard and enlarged text', (
    tester,
  ) async {
    viewport(tester, 360);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.view.resetViewInsets);
    final h = await mount(tester, AppLanguage.arabic);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'employee@erp.demo',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Employee@123');
    await tapVisible(tester, find.byKey(const ValueKey('login-submit')));
    expect(find.byType(AppShell), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester, h);
  });
}
