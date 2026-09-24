import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/core/utils/app_clock.dart';
import 'package:modular_erp/modules/hr/demo/hr_demo_seed.dart';
import 'package:modular_erp/app/access/erp_access_catalog.dart';
import 'package:modular_erp/platform/access/data/access_seed.dart';
import 'package:modular_erp/modules/services/demo/services_demo_seed.dart';
import 'package:modular_erp/platform/auth/domain/policies/demo_scenario_grants.dart';
import 'package:modular_erp/app/shell/app_shell_cubit.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:modular_erp/app/erp_app.dart';
import 'package:modular_erp/core/logging/app_logger.dart';
import 'package:modular_erp/core/sync/outbox_repository.dart';
import 'package:modular_erp/core/sync/app_sync_status_cubit.dart';
import 'package:modular_erp/core/sync/sync_coordinator.dart';
import 'package:modular_erp/app/app_lifecycle_coordinator.dart';
import 'package:modular_erp/core/localization/locale_cubit.dart';
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
    await seedHrDemoData(
      services<AppDatabase>(),
      clock: services<AppClock>(),
      time: services<CompanyTimeService>(),
    );
    await seedAccessDemoData(
      services<AppDatabase>(),
      erpAccessCatalog,
      services<DemoAuthSource>(),
      services<AppClock>(),
    );
    await seedServicesDemoData(
      services<AppDatabase>(),
      services<DemoAuthSource>()
          .findByScenario(DemoScenario.platformAdmin)!
          .context,
      services<AppClock>(),
    );
    await seedServiceEnquiriesDemoData(
      services<AppDatabase>(),
      services<DemoAuthSource>()
          .findByScenario(DemoScenario.platformAdmin)!
          .context,
      services<AppClock>(),
    );
    await seedServiceJobAssignmentDemoData(
      services<AppDatabase>(),
      services<DemoAuthSource>()
          .findByScenario(DemoScenario.platformAdmin)!
          .context,
      services<AppClock>(),
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
