import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/api/session_endpoint.dart';
import 'package:modular_erp/core/api/token_refresh_coordinator.dart';
import 'package:modular_erp/core/connectivity/connectivity_service.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/localization/locale_cubit.dart';
import 'package:modular_erp/core/location/location_service.dart';
import 'package:modular_erp/core/logging/app_logger.dart';
import 'package:modular_erp/core/preferences/app_preferences_repository.dart';
import 'package:modular_erp/core/storage/secure_session_storage.dart';
import 'package:modular_erp/core/sync/outbox_repository.dart';
import 'package:modular_erp/core/sync/sync_coordinator.dart';
import 'package:modular_erp/core/sync/sync_diagnostics.dart';
import 'package:modular_erp/core/utils/app_clock.dart';

/// Core infrastructure: clock, database, storage, sync, preferences and logging.
/// Owns nothing business-specific and is shared by every module.
void configureCoreDependencies(GetIt services) {
  services.registerLazySingleton<AppClock>(() => const SystemAppClock());
  services.registerSingleton(AppLogger());
  services.registerLazySingleton<LocationService>(DeviceLocationService.new);
  services.registerLazySingleton<SessionStorage>(
    () => SecureSessionStorage(const FlutterSecureStorage()),
  );
  services.registerLazySingleton<TokenRefreshCoordinator>(
    TokenRefreshCoordinator.new,
  );
  services.registerLazySingleton<SessionEndpoint>(
    () => SessionEndpoint(),
    dispose: (endpoint) => endpoint.dispose(),
  );
  if (AppConfig.realApiEnabled) {
    registerSharedApiClient(
      services,
      baseUrl: AppConfig.apiBaseUrl,
      allowInsecureHttp: AppConfig.allowInsecureHttp,
    );
  }
  services.registerLazySingleton(
    () => AppDatabase(),
    dispose: (db) => db.close(),
  );
  services.registerLazySingleton(() => OutboxLocalDataSource(services()));
  services.registerLazySingleton<OutboxRepository>(
    () => LocalOutboxRepository(services()),
  );
  services.registerLazySingleton<ConnectivityService>(
    () => DeviceConnectivityService(Connectivity()),
  );
  services.registerLazySingleton(
    () => SyncCoordinator(services()),
    dispose: (sync) => sync.dispose(),
  );
  services.registerLazySingleton(
    () => SyncDiagnosticsService(services(), services()),
  );
  services.registerLazySingleton<AppPreferencesLocalDataSource>(
    () => SharedPreferencesLocalDataSource(SharedPreferencesAsync()),
  );
  services.registerLazySingleton<AppPreferencesRepository>(
    () => LocalAppPreferencesRepository(services()),
  );
  services.registerLazySingleton(
    () => LocaleCubit(services()),
    dispose: (cubit) => cubit.close(),
  );
}

/// Registers the single shared authenticated [ApiClient] for the container.
///
/// Future modules resolve this same instance and register their own remote data
/// sources on top of it; none may construct a client of their own. Registering
/// twice throws, which protects against duplicate, divergent API configuration.
void registerSharedApiClient(
  GetIt services, {
  required String baseUrl,
  bool allowInsecureHttp = false,
}) {
  services.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: baseUrl,
      storage: services(),
      refreshCoordinator: services(),
      sessionEndpoint: services(),
      allowInsecureHttp: allowInsecureHttp,
    ),
    dispose: (client) => client.close(),
  );
}
