import 'package:get_it/get_it.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/platform/access/domain/permission_master_repository.dart';
import 'package:modular_erp/app/module_registry/registered_modules.dart';
import 'package:modular_erp/bootstrap/core_dependencies.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch_repository.dart';
import 'package:modular_erp/modules/hr/employees/live/domain/live_employee_repository.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/employee_shift_api.dart';
import 'package:modular_erp/modules/hr/attendance/live/data/attendance_api.dart';
import 'package:modular_erp/modules/hr/module/hr_dependencies.dart';
import 'package:modular_erp/modules/services/module/services_dependencies.dart';
import 'package:modular_erp/platform/module/platform_dependencies.dart';
import 'package:modular_erp/platform/access/access_dependencies.dart';
import 'package:modular_erp/shared/transactions/transactions_dependencies.dart';

final services = GetIt.instance;

/// Application composition root. Delegates to core, platform, HR and Services
/// composition boundaries, then wires the module registry.
void configureDependencies() {
  configureCoreDependencies(services);
  configureTransactionDependencies(services);
  configurePlatformDependencies(services);
  configureAccessDependencies(services);
  configureHrDependencies(services);
  configureServicesDependencies(services);
  configureApplicationComposition(services);
}

/// Destinations with a real backend vertical in this build.
///
/// Local/demo-backed screens are intentionally absent so neither navigation nor
/// a typed URL can reach fabricated business data.
const _liveDestinationIds = <String>{
  'dashboard',
  'profile',
  'settings',
  'shifts',
  'departments',
  'access-users',
  'company-modules',
  'live-employees',
  'employee-shifts',
  'live-attendance',
};

void configureApplicationComposition(GetIt services) {
  services.registerLazySingleton<ModuleRegistry>(
    () => createErpRegistry(
      services(),
      dashboardRepository: services(),
      employeeRepository: services(),
      branchRepository: services.isRegistered<BranchRepository>()
          ? services<BranchRepository>()
          : null,
      includeLegacyEmployees: false,
      liveEmployeeRepository: services.isRegistered<LiveEmployeeRepository>()
          ? services<LiveEmployeeRepository>()
          : null,
      employeeShiftApi: services.isRegistered<EmployeeShiftApi>()
          ? services<EmployeeShiftApi>()
          : null,
      attendanceApi: services.isRegistered<AttendanceApi>()
          ? services<AttendanceApi>()
          : null,
      shiftRepository: services(),
      departmentRepository: services(),
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
      accessRepository: services(),
      accessCatalog: services(),
      accessAuthority: services(),
      permissionMasterRepository: services.isRegistered<PermissionMasterRepository>()
          ? services<PermissionMasterRepository>()
          : null,
      serviceCustomerRepository: services(),
      serviceSiteRepository: services(),
      serviceTeamRepository: services(),
      serviceMasterRepository: services(),
      serviceEnquiryRepository: services(),
      serviceJobAssignmentRepository: services(),
      serviceInspectionRepository: services(),
      serviceMaterialRequestRepository: services(),
      serviceWorkExecutionRepository: services(),
      serviceWorkflowRepository: services(),
      workforceDirectory: services(),
      activityRepository: services(),
      database: services(),
      clock: services(),
      companyTimeService: services(),
    ).retainDestinations(_liveDestinationIds),
  );
}








