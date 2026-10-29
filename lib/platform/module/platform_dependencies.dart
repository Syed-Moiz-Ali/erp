import 'package:get_it/get_it.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/app/app_lifecycle_coordinator.dart';
import 'package:modular_erp/app/shell/app_shell_cubit.dart';
import 'package:modular_erp/core/api/access_endpoint.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/token_refresh_coordinator.dart';
import 'package:modular_erp/core/localization/locale_cubit.dart';
import 'package:modular_erp/core/sync/app_sync_status_cubit.dart';
import 'package:modular_erp/core/sync/sync_coordinator.dart';
import 'package:modular_erp/platform/access/application/user_grants_controller.dart';
import 'package:modular_erp/platform/access/data/datasources/remote/dio_access_remote_data_source.dart';
import 'package:modular_erp/platform/access/data/repositories/remote_effective_access_repository.dart';
import 'package:modular_erp/platform/access/domain/effective_access_source.dart';
import 'package:modular_erp/platform/auth/application/permission_loader.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';
import 'package:modular_erp/platform/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:modular_erp/platform/auth/data/datasources/remote/dio_auth_remote_data_source.dart';
import 'package:modular_erp/platform/auth/data/repositories/demo_auth_repository.dart';
import 'package:modular_erp/platform/auth/data/repositories/disabled_auth_repository.dart';
import 'package:modular_erp/platform/auth/data/repositories/remote_auth_repository.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/platform/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/platform/notifications/application/attendance_reminder_service.dart';
import 'package:modular_erp/platform/notifications/application/reminder_context.dart';
import 'package:modular_erp/platform/notifications/data/local_notification_repository.dart';
import 'package:modular_erp/platform/notifications/data/local_reminder_context_source.dart';
import 'package:modular_erp/platform/notifications/domain/device_notification_service.dart';
import 'package:modular_erp/platform/notifications/domain/notification_repository.dart';

/// Platform (cross-module application) dependencies: authentication, session,
/// shell, notifications and app lifecycle.
void configurePlatformDependencies(GetIt services) {
  _registerAuthentication(services);
  services.registerLazySingleton(
    () => AuthBloc(
      services(),
      // Local grants are a demo-only source. Backend sessions are gated only by
      // GET /api/me/permissions (fail closed), never by local/demo grants.
      grants: AppConfig.realApiEnabled
          ? null
          : services<UserGrantsController>(),
    ),
    dispose: (bloc) => bloc.close(),
  );
  if (AppConfig.realApiEnabled) {
    services.registerLazySingleton<EffectiveAccessSource>(
      () => RemoteEffectiveAccessRepository(
        DioAccessRemoteDataSource(services<ApiClient>()),
      ),
    );
    services.registerLazySingleton<BackendPermissionLoader>(() {
      final authBloc = services<AuthBloc>();
      return BackendPermissionLoader(
        repository: services(),
        source: services(),
        accessEndpoint: services<AccessEndpoint>(),
        contexts: authBloc.stream
            .where((state) => !state.loggingOut)
            .map((state) => state.context),
        currentContext: () => authBloc.state.context,
      );
    }, dispose: (loader) => loader.dispose());
  }
  services.registerLazySingleton(
    () => AppShellCubit(services()),
    dispose: (cubit) => cubit.close(),
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
      refreshPermissions: AppConfig.realApiEnabled
          ? () => services<BackendPermissionLoader>().refresh()
          : null,
      reconcileReminders: () => services<AttendanceReminderService>().reconcile(
        locale: services<LocaleCubit>().state.locale,
      ),
    ),
  );
}

/// Registers exactly one [AuthRepository] according to [AppConfig.authMode]:
/// the real backend repository, the demo repository, or an explicit disabled
/// repository. There is no fallback between them.
void _registerAuthentication(GetIt services) {
  switch (AppConfig.authMode) {
    case AuthMode.backend:
      services.registerLazySingleton<AuthRemoteDataSource>(
        () => DioAuthRemoteDataSource(services<ApiClient>()),
      );
      services.registerLazySingleton<AuthRepository>(() {
        final repository = RemoteAuthRepository(
          dataSource: services(),
          storage: services(),
          sessionEndpoint: services(),
        );
        // Wire the single-flight coordinator so protected requests rotate
        // tokens through this repository (Phase 1 infrastructure, now live).
        services<TokenRefreshCoordinator>().refresher = repository;
        return repository;
      }, dispose: (repo) => repo.dispose());
    case AuthMode.demo:
      services.registerLazySingleton(DemoAuthSource.new);
      services.registerLazySingleton<AuthRepository>(
        () => DemoAuthRepository(
          services(),
          source: services(),
          accountGuard: services(),
        ),
        dispose: (repo) => repo.dispose(),
      );
    case AuthMode.disabled:
      services.registerLazySingleton<AuthRepository>(
        () => const DisabledAuthRepository(),
      );
  }
}
