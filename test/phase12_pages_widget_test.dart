import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/core/connectivity/connectivity_service.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/preferences/app_preferences_repository.dart';
import 'package:modular_erp/core/sync/app_sync_status_cubit.dart';
import 'package:modular_erp/core/sync/outbox_repository.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_theme.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/platform/notifications/data/noop_notification_repository.dart';
import 'package:modular_erp/platform/notifications/domain/device_notification_service.dart';
import 'package:modular_erp/platform/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:modular_erp/platform/notifications/presentation/bloc/reminder_settings_cubit.dart';
import 'package:modular_erp/platform/notifications/presentation/notifications_page.dart';
import 'package:modular_erp/platform/notifications/presentation/reminder_settings_page.dart';
import 'package:modular_erp/platform/sync/presentation/sync_settings_page.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'support/memory_preferences.dart';
import 'attendance_test.dart' show MockAuth;
import 'employee_test.dart' show employeeContext;

class MockConnectivity extends Mock implements ConnectivityService {}

Widget _host(Locale locale, Widget child) => MaterialApp(
  locale: locale,
  theme: AppTheme.light(locale: locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

/// Entry animations schedule a one-shot timer; draining it keeps the test
/// free of pending-timer failures.
Future<void> _pumpFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  for (final locale in [const Locale('en'), const Locale('ar')]) {
    testWidgets('notification center renders ${locale.languageCode}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final auth = MockAuth();
      when(() => auth.checkSession()).thenAnswer(
        (_) async => Success(employeeContext(DemoScenario.employee)),
      );
      when(() => auth.sessionChanges).thenAnswer((_) => const Stream.empty());
      final bloc = NotificationsBloc(const NoopNotificationRepository(), auth)
        ..add(const NotificationsStarted());
      addTearDown(bloc.close);
      await tester.pumpWidget(
        _host(
          locale,
          BlocProvider.value(value: bloc, child: const NotificationsPage()),
        ),
      );
      await _pumpFrames(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(NotificationsPage), findsOneWidget);
    });

    testWidgets('reminder settings renders ${locale.languageCode}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final cubit = ReminderSettingsCubit(
        LocalAppPreferencesRepository(MemoryPreferences()),
        const NoopDeviceNotificationService(),
      )..load();
      addTearDown(cubit.close);
      await tester.pumpWidget(
        _host(
          locale,
          BlocProvider.value(value: cubit, child: const ReminderSettingsPage()),
        ),
      );
      await _pumpFrames(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(ReminderSettingsPage), findsOneWidget);
    });
  }

  testWidgets('sync settings renders without unbounded viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final auth = MockAuth();
    when(
      () => auth.checkSession(),
    ).thenAnswer((_) async => Success(employeeContext(DemoScenario.employee)));
    when(() => auth.sessionChanges).thenAnswer((_) => const Stream.empty());
    final connectivity = MockConnectivity();
    when(() => connectivity.isConnected).thenAnswer((_) async => true);
    when(() => connectivity.changes).thenAnswer((_) => const Stream.empty());
    final cubit = AppSyncStatusCubit(
      outbox: OutboxLocalDataSource(db),
      connectivity: connectivity,
      preferences: LocalAppPreferencesRepository(MemoryPreferences()),
      auth: auth,
    );
    addTearDown(cubit.close);
    await tester.pumpWidget(
      _host(
        const Locale('en'),
        BlocProvider.value(value: cubit, child: const SyncSettingsPage()),
      ),
    );
    await _pumpFrames(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(SyncSettingsPage), findsOneWidget);
  });
}
