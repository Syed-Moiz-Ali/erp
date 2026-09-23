import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/core/location/location_service.dart';
import 'package:modular_erp/modules/hr/attendance/application/attendance_maintenance_service.dart';
import 'package:modular_erp/modules/hr/attendance/application/execute_attendance_action.dart';
import 'package:modular_erp/modules/hr/attendance/data/attendance_local_data_source.dart';
import 'package:modular_erp/modules/hr/attendance/data/device_attendance_location_capture.dart';
import 'package:modular_erp/modules/hr/attendance/data/local_attendance_correction_repository.dart';
import 'package:modular_erp/modules/hr/attendance/data/local_attendance_repository.dart';
import 'package:modular_erp/modules/hr/attendance/data/workforce_attendance_read_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_context_resolver.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_correction_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_engine.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_scope_resolver.dart';
import 'package:modular_erp/modules/hr/attendance/domain/shift_workday_resolver.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:modular_erp/modules/hr/dashboard/data/local_dashboard_repository.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_repository.dart';
import 'package:modular_erp/modules/hr/attendance_policies/data/local_attendance_policy_repository.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy_repository.dart';
import 'package:modular_erp/modules/hr/employees/data/account_provisioning_repository.dart';
import 'package:modular_erp/modules/hr/employees/data/employee_dao.dart';
import 'package:modular_erp/modules/hr/employees/data/local_account_access_guard.dart';
import 'package:modular_erp/modules/hr/employees/data/local_employee_repository.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_repository.dart';
import 'package:modular_erp/modules/hr/leave/data/leave_configuration_repositories.dart';
import 'package:modular_erp/modules/hr/leave/data/local_leave_repository.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_repository.dart';
import 'package:modular_erp/modules/hr/module/workforce_directory_adapter.dart';
import 'package:modular_erp/modules/hr/reports/data/attendance_report_export_service.dart';
import 'package:modular_erp/modules/hr/reports/data/local_attendance_report_repository.dart';
import 'package:modular_erp/modules/hr/reports/domain/attendance_report_repository.dart';
import 'package:modular_erp/modules/hr/shifts/data/local_shift_repository.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift_repository.dart';
import 'package:modular_erp/modules/hr/work_locations/data/local_work_location_repository.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location_repository.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/platform/auth/domain/repositories/account_access_guard.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';

/// HR module dependency composition. The central bootstrap does not know every
/// HR constructor argument.
void configureHrDependencies(GetIt services) {
  // Attendance engine + repository stack.
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
    () => LocalAttendanceCorrectionRepository(
      services(),
      services(),
      services(),
      notifications: services(),
    ),
  );
  services.registerLazySingleton(() => const AttendanceScopeResolver());
  services.registerLazySingleton(
    () => WorkforceAttendanceReadRepository(
      services(),
      services(),
      services(),
      clock: services(),
      time: services(),
      leave: services(),
    ),
  );
  // HR-owned dashboard (workforce-specific repository).
  services.registerLazySingleton<DashboardRepository>(
    () => LocalDashboardRepository(
      demoEnabled: AppConfig.demoAuthEnabled,
      workforce: services(),
      corrections: services(),
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
  services.registerLazySingleton(
    () => AttendanceMaintenanceService(services(), services(), services()),
  );

  // Workforce configuration + employees.
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

  // Leave / Holidays.
  services.registerLazySingleton<LeaveRepository>(
    () => LocalLeaveRepository(
      services(),
      services(),
      services(),
      notifications: services(),
      time: services(),
    ),
  );
  services.registerLazySingleton(() => leaveTypeConfiguration(services()));
  services.registerLazySingleton(() => leavePolicyConfiguration(services()));
  services.registerLazySingleton(() => holidayConfiguration(services()));

  // Public workforce contract consumed by Services (and others).
  services.registerLazySingleton<WorkforceDirectory>(
    () => HrWorkforceDirectory(services<AuthRepository>(), services()),
  );
}
