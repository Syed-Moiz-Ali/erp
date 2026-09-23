import 'package:get_it/get_it.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/app/app_lifecycle_coordinator.dart';
import 'package:modular_erp/app/shell/app_shell_cubit.dart';
import 'package:modular_erp/core/localization/locale_cubit.dart';
import 'package:modular_erp/core/sync/app_sync_status_cubit.dart';
import 'package:modular_erp/core/sync/sync_coordinator.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/data/repositories/demo_auth_repository.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/platform/dashboard/data/local_dashboard_repository.dart';
import 'package:modular_erp/platform/dashboard/domain/dashboard_repository.dart';
import 'package:modular_erp/platform/notifications/application/attendance_reminder_service.dart';
import 'package:modular_erp/platform/notifications/application/reminder_context.dart';
import 'package:modular_erp/platform/notifications/data/local_notification_repository.dart';
import 'package:modular_erp/platform/notifications/data/local_reminder_context_source.dart';
import 'package:modular_erp/platform/notifications/domain/device_notification_service.dart';
import 'package:modular_erp/platform/notifications/domain/notification_repository.dart';

/// Platform (cross-module application) dependencies: authentication, session,
/// shell, dashboard, notifications and app lifecycle.
void configurePlatformDependencies(GetIt services) {
  if (AppConfig.demoAuthEnabled) {
    services.registerLazySingleton(DemoAuthSource.new);
  }
  services.registerLazySingleton<AuthRepository>(
    () => DemoAuthRepository(
      services(),
      source: AppConfig.demoAuthEnabled ? services<DemoAuthSource>() : null,
      accountGuard: services(),
    ),
    dispose: (repo) => repo.dispose(),
  );
  services.registerLazySingleton(
    () => AuthBloc(services()),
    dispose: (bloc) => bloc.close(),
  );
  services.registerLazySingleton(
    () => AppShellCubit(services()),
    dispose: (cubit) => cubit.close(),
  );
  services.registerLazySingleton<DashboardRepository>(
    () => LocalDashboardRepository(
      demoEnabled: AppConfig.demoAuthEnabled,
      workforce: services(),
      corrections: services(),
    ),
  );
  services.registerLazySingleton<NotificationRepository>(
    () => LocalNotificationRepository(services()),
  );
  services.registerLazySingleton<DeviceNotificationService>(
    () => const NoopDeviceNotificationService(),
  );
  services.registerLazySingleton<ReminderContextSource>(
    () => LocalReminderContextSource(services()),
  );
  services.registerLazySingleton(
    () => AttendanceReminderService(
      preferences: services(),
      source: services(),
      device: services(),
      clock: services(),
    ),
  );
  services.registerLazySingleton(
    () => AppSyncStatusCubit(
      outbox: services(),
      connectivity: services(),
      preferences: services(),
      auth: services(),
    ),
    dispose: (cubit) => cubit.close(),
  );
  services.registerLazySingleton(
    () => AppLifecycleCoordinator(
      sync: () => services<SyncCoordinator>().synchronize(),
      reconcileReminders: () => services<AttendanceReminderService>().reconcile(
        locale: services<LocaleCubit>().state.locale,
      ),
    ),
  );
}
