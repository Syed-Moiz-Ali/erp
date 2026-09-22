import 'demo_attendance_seed.dart';
import 'demo_workforce_seed.dart';
import '../features/attendance/presentation/bloc/attendance_bloc.dart';
import '../features/attendance/domain/shift_workday_resolver.dart';
import '../core/utils/app_clock.dart';
import 'demo_configuration_seed.dart';
import '../features/employees/data/employee_seed.dart';
import '../app/shell/app_shell_cubit.dart';
import '../app/module_registry/module_registry.dart';
import '../app/app_config.dart';
import '../core/database/app_database.dart';
import '../features/auth/data/datasources/local/demo_auth_source.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../app/erp_app.dart';
import '../core/logging/app_logger.dart';
import '../core/sync/outbox_repository.dart';
import '../core/sync/app_sync_status_cubit.dart';
import '../core/sync/sync_coordinator.dart';
import '../app/app_lifecycle_coordinator.dart';
import '../core/localization/locale_cubit.dart';
import 'dependencies.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  configureDependencies();
  final logger = services<AppLogger>();
  Bloc.observer = AppBlocObserver(logger);
  FlutterError.onError = (details) {
    logger.error(details.exception, details.stack ?? StackTrace.current);
    FlutterError.presentError(details);
  };
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    logger.error(error, stack);
    return true;
  };
  await initializeDateFormatting();
  // Force Drift to open and run migrations before session restoration.
  await services<AppDatabase>().customSelect('SELECT 1').get();
  if (AppConfig.demoAuthEnabled) {
    await seedEmployees(services<AppDatabase>());
    await seedAttendanceConfiguration(services<AppDatabase>());
    await seedDemoAttendance(
      services<AppDatabase>(),
      clock: services<AppClock>(),
      time: services<CompanyTimeService>(),
    );
    await seedDemoWorkforce(
      services<AppDatabase>(),
      enabled: true,
      clock: services<AppClock>(),
      time: services<CompanyTimeService>(),
    );
  }
  final localeCubit = services<LocaleCubit>();
  await localeCubit.restore(WidgetsBinding.instance.platformDispatcher.locales);
  final shellCubit = services<AppShellCubit>();
  await shellCubit.restore();
  final authBloc = services<AuthBloc>();
  final syncStatus = services<AppSyncStatusCubit>();
  syncStatus.onSyncNow = () async {
    await services<OutboxLocalDataSource>().recoverStaleProcessing(
      now: services<AppClock>().now().toUtc(),
    );
    await services<SyncCoordinator>().synchronize();
  };
  await syncStatus.start();
  final lifecycle = services<AppLifecycleCoordinator>();
  // Foreground sync only: connectivity-triggered processing after bootstrap.
  // No handlers are registered until a real transport is configured.
  services<SyncCoordinator>().start();

  runApp(
    ErpApp(
      localeCubit: localeCubit,
      authBloc: authBloc,
      shellCubit: shellCubit,
      attendanceBlocFactory: () => services<AttendanceBloc>(),
      attendanceClock: services<AppClock>(),
      companyTime: services<CompanyTimeService>(),
      moduleRegistry: services<ModuleRegistry>(),
      notificationRepository: services(),
      syncStatusCubit: syncStatus,
      lifecycleCoordinator: lifecycle,
      preferences: services(),
      deviceNotifications: services(),
      reminderService: services(),
      syncDiagnostics: services(),
      demoAccounts: AppConfig.demoAuthEnabled
          ? services<DemoAuthSource>().credentials
          : const [],
    ),
  );
  authBloc.add(const AuthBootstrapRequested());
}
