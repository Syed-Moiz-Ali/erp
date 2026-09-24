import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/bootstrap/core_dependencies.dart';
import 'package:modular_erp/shared/transactions/transactions_dependencies.dart';
import 'package:modular_erp/bootstrap/dependencies.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/location/location_service.dart';
import 'package:modular_erp/modules/hr/attendance/data/workforce_attendance_read_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_correction_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_repository.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy_repository.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_repository.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_repository.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_repository.dart';
import 'package:modular_erp/modules/hr/module/hr_dependencies.dart';
import 'package:modular_erp/modules/hr/reports/data/attendance_report_export_service.dart';
import 'package:modular_erp/modules/hr/reports/domain/attendance_report_repository.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift_repository.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location_repository.dart';
import 'package:modular_erp/modules/services/module/services_dependencies.dart';
import 'package:modular_erp/platform/access/access_dependencies.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/platform/module/platform_dependencies.dart';
import 'package:modular_erp/shared/domain/configuration_repository.dart';

void main() {
  test(
    'module DI registers every dependency the registry composition needs',
    () {
      final sl = GetIt.asNewInstance();
      configureCoreDependencies(sl);
      configurePlatformDependencies(sl);
      configureHrDependencies(sl);
      configureServicesDependencies(sl);
      configureApplicationComposition(sl);

      expect(sl.isRegistered<AuthRepository>(), isTrue);
      expect(sl.isRegistered<DashboardRepository>(), isTrue);
      expect(sl.isRegistered<EmployeeRepository>(), isTrue);
      expect(sl.isRegistered<ShiftRepository>(), isTrue);
      expect(sl.isRegistered<WorkLocationRepository>(), isTrue);
      expect(sl.isRegistered<AttendancePolicyRepository>(), isTrue);
      expect(sl.isRegistered<LocationService>(), isTrue);
      expect(sl.isRegistered<AttendanceRepository>(), isTrue);
      expect(sl.isRegistered<AttendanceCorrectionRepository>(), isTrue);
      expect(sl.isRegistered<WorkforceAttendanceReadRepository>(), isTrue);
      expect(sl.isRegistered<AttendanceReportRepository>(), isTrue);
      expect(sl.isRegistered<AttendanceReportExportService>(), isTrue);
      expect(sl.isRegistered<LeaveRepository>(), isTrue);
      expect(
        sl.isRegistered<ConfigurationRepository<LeaveType, LeaveTypeDraft>>(),
        isTrue,
      );
      expect(
        sl
            .isRegistered<
              ConfigurationRepository<LeavePolicy, LeavePolicyDraft>
            >(),
        isTrue,
      );
      expect(
        sl.isRegistered<ConfigurationRepository<Holiday, HolidayDraft>>(),
        isTrue,
      );
      expect(sl.isRegistered<ModuleRegistry>(), isTrue);
    },
  );

  test('full DI composition resolves the module registry end to end', () {
    final sl = GetIt.asNewInstance();
    configureCoreDependencies(sl);
    sl.unregister<AppDatabase>();
    final db = AppDatabase(NativeDatabase.memory());
    sl.registerSingleton<AppDatabase>(db);
    configurePlatformDependencies(sl);
    configureTransactionDependencies(sl);
    configureAccessDependencies(sl);
    configureHrDependencies(sl);
    configureServicesDependencies(sl);
    configureApplicationComposition(sl);

    final registry = sl<ModuleRegistry>();
    expect(
      registry.destinations.any(
        (destination) => destination.route == AppRoutes.dashboard,
      ),
      isTrue,
    );
    db.close();
  });
}
