import 'package:get_it/get_it.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/bootstrap/core_dependencies.dart';
import 'package:modular_erp/modules/hr/module/hr_dependencies.dart';
import 'package:modular_erp/modules/services/module/services_dependencies.dart';
import 'package:modular_erp/platform/module/platform_dependencies.dart';
import 'package:modular_erp/shared/transactions/transactions_dependencies.dart';

final services = GetIt.instance;

/// Application composition root. Delegates to core, platform, HR and Services
/// composition boundaries, then wires the module registry.
void configureDependencies() {
  configureCoreDependencies(services);
  configureTransactionDependencies(services);
  configurePlatformDependencies(services);
  configureHrDependencies(services);
  configureServicesDependencies(services);
  configureApplicationComposition(services);
}

void configureApplicationComposition(GetIt services) {
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
      leaveRepository: services(),
      leaveTypeRepository: services(),
      leavePolicyRepository: services(),
      holidayRepository: services(),
    ),
  );
}
