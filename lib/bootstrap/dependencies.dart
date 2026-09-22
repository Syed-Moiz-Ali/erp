import 'package:flutter/foundation.dart';
import '../core/utils/app_clock.dart';
import '../features/attendance/domain/attendance_models.dart';
import '../features/attendance/domain/attendance_context_resolver.dart';
import '../features/attendance/domain/attendance_engine.dart';
import '../features/attendance/domain/attendance_repository.dart';
import '../features/attendance/domain/shift_workday_resolver.dart';
import '../features/attendance/data/attendance_local_data_source.dart';
import '../features/attendance/data/local_attendance_repository.dart';
import '../features/attendance/data/local_attendance_correction_repository.dart';
import '../features/attendance/data/workforce_attendance_read_repository.dart';
import '../features/attendance/domain/attendance_correction_repository.dart';
import '../features/attendance/domain/attendance_scope_resolver.dart';
import '../features/attendance/data/device_attendance_location_capture.dart';
import '../features/attendance/application/execute_attendance_action.dart';
import '../features/attendance/presentation/bloc/attendance_bloc.dart';
import '../features/shifts/domain/shift_repository.dart';
import '../features/shifts/data/local_shift_repository.dart';
import '../features/work_locations/domain/work_location_repository.dart';
import '../features/work_locations/data/local_work_location_repository.dart';
import '../features/attendance_policies/domain/attendance_policy_repository.dart';
import '../features/attendance_policies/data/local_attendance_policy_repository.dart';
import '../features/auth/domain/repositories/account_access_guard.dart';
import '../features/employees/data/local_account_access_guard.dart';
import '../features/employees/domain/employee_repository.dart';
import '../features/employees/data/local_employee_repository.dart';
import '../features/employees/data/employee_dao.dart';
import '../features/employees/data/account_provisioning_repository.dart';
import '../features/dashboard/domain/dashboard_repository.dart';
import '../features/dashboard/data/local_dashboard_repository.dart';
import '../features/reports/domain/attendance_report_repository.dart';
import '../features/reports/data/local_attendance_report_repository.dart';
import '../features/reports/data/attendance_report_export_service.dart';
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
  services.registerLazySingleton<AppClock>(() => const SystemAppClock());
  services.registerLazySingleton<CompanyTimeService>(
    () => const FixedOffsetCompanyTimeService(),
  );
  services.registerLazySingleton(() => ShiftWorkdayResolver(services()));
  services.registerLazySingleton(() => const AttendanceEngine());
  services.registerLazySingleton(
    () => AttendanceContextResolver(services(), services()),
  );
  services.registerLazySingleton(() => AttendanceLocalDataSource(services()));
  services.registerLazySingleton<AttendanceRemoteAvailability>(
    () => const UnconfiguredAttendanceRemote(),
  );
  services.registerLazySingleton<AttendanceRepository>(
    () => LocalAttendanceRepository(
      services(),
      services(),
      services(),
      services(),
      services(),
      authority: AppConfig.demoAuthEnabled
          ? AttendanceAuthority.demoLocal
          : AttendanceAuthority.productionPending,
    ),
  );
  services.registerLazySingleton<AttendanceCorrectionRepository>(
    () =>
        LocalAttendanceCorrectionRepository(services(), services(), services()),
  );
  services.registerLazySingleton(() => const AttendanceScopeResolver());
  services.registerLazySingleton(
    () => WorkforceAttendanceReadRepository(
      services(),
      services(),
      services(),
      clock: services(),
      time: services(),
    ),
  );
  services.registerLazySingleton<AttendanceReportRepository>(
    () => LocalAttendanceReportRepository(
      services(),
      services(),
      clock: services(),
      time: services(),
    ),
  );
  services.registerLazySingleton<ReportFileSaver>(
    () => const PlatformReportFileSaver(),
  );
  services.registerLazySingleton(
    () => AttendanceReportExportService(services(), services()),
  );
  services.registerLazySingleton<AttendanceLocationCapture>(
    () => DeviceAttendanceLocationCapture(services()),
  );
  services.registerLazySingleton(
    () => ExecuteAttendanceAction(
      services(),
      services(),
      services(),
      kIsWeb ? AttendanceEventSource.web : AttendanceEventSource.mobile,
    ),
  );
  services.registerFactory(
    () => AttendanceBloc(
      services(),
      services(),
      requireConfirmation: true,
      openSettings: (gps) =>
          services<LocationService>().openSettings(locationSettings: gps),
    ),
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
  services.registerLazySingleton<ShiftRepository>(
    () => LocalShiftRepository(services()),
  );
  services.registerLazySingleton<WorkLocationRepository>(
    () => LocalWorkLocationRepository(services()),
  );
  services.registerLazySingleton<AttendancePolicyRepository>(
    () => LocalAttendancePolicyRepository(services()),
  );
  services.registerLazySingleton<ModuleRegistry>(
    () => createErpRegistry(
      services(),
      dashboardRepository: services(),
      employeeRepository: services(),
      shiftRepository: services(),
      workLocationRepository: services(),
      attendancePolicyRepository: services(),
      locationService: services(),
      attendanceRepository: services(),
      correctionRepository: services(),
      workforceAttendanceRepository: services(),
      attendanceReportRepository: services(),
      attendanceReportExportService: services(),
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
