import '../features/auth/domain/repositories/account_access_guard.dart';
import '../features/employees/data/local_account_access_guard.dart';
import '../features/employees/domain/employee_repository.dart';
import '../features/employees/data/local_employee_repository.dart';
import '../features/employees/data/employee_dao.dart';
import '../features/employees/data/account_provisioning_repository.dart';
import '../features/dashboard/domain/dashboard_repository.dart';
import '../features/dashboard/data/local_dashboard_repository.dart';
import '../app/shell/app_shell_cubit.dart';
import '../app/module_registry/module_registry.dart';
import '../app/module_registry/registered_modules.dart';
import '../app/app_config.dart';
import '../features/auth/data/datasources/local/demo_auth_source.dart';
import '../features/auth/data/repositories/demo_auth_repository.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/preferences/app_preferences_repository.dart';
import '../core/localization/locale_cubit.dart';
import '../core/api/api_client.dart';
import '../core/location/location_service.dart';
import '../core/sync/outbox_repository.dart';
import '../core/database/app_database.dart';
import '../core/storage/secure_session_storage.dart';
import '../core/connectivity/connectivity_service.dart';
import '../core/sync/sync_coordinator.dart';
import '../core/logging/app_logger.dart';

final services = GetIt.instance;
void configureDependencies() {
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
    () => LocalDashboardRepository(demoEnabled: AppConfig.demoAuthEnabled),
  );
  services.registerLazySingleton(() => EmployeeDao(services()));
  services.registerLazySingleton<AccountAccessGuard>(
    () => LocalAccountAccessGuard(services()),
  );
  services.registerLazySingleton<AccountProvisioningRepository>(
    () => LocalAccountProvisioningRepository(services()),
  );
  services.registerLazySingleton<EmployeeRepository>(
    () => LocalEmployeeRepository(services(), services()),
  );
  services.registerLazySingleton<ModuleRegistry>(
    () => createErpRegistry(
      services(),
      dashboardRepository: services(),
      employeeRepository: services(),
    ),
  );
  services.registerSingleton(AppLogger());
  services.registerLazySingleton<LocationService>(DeviceLocationService.new);
  services.registerLazySingleton<SessionStorage>(
    () => SecureSessionStorage(const FlutterSecureStorage()),
  );
  services.registerLazySingleton(
    () => ApiClient(
      baseUrl: const String.fromEnvironment('API_BASE_URL'),
      storage: services(),
    ),
  );
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
}
