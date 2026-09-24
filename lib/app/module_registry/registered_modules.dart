import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/app/router/app_route_transitions.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/location/location_service.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_catalog.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/grant_authority.dart';
import 'package:modular_erp/platform/access/presentation/company_modules_page.dart';
import 'package:modular_erp/platform/access/presentation/user_access_detail_page.dart';
import 'package:modular_erp/platform/access/presentation/users_access_page.dart';
import 'package:modular_erp/modules/hr/attendance/data/workforce_attendance_read_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_correction_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_repository.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy_repository.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_repository.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_repository.dart';
import 'package:modular_erp/modules/hr/module/hr_module_registration.dart';
import 'package:modular_erp/modules/hr/module/hr_routes.dart';
import 'package:modular_erp/modules/hr/reports/data/attendance_report_export_service.dart';
import 'package:modular_erp/modules/hr/reports/domain/attendance_report_repository.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift_repository.dart';
import 'package:modular_erp/modules/hr/work_locations/domain/work_location_repository.dart';
import 'package:modular_erp/modules/services/module/services_module_registration.dart';
import 'package:modular_erp/modules/services/customers/domain/service_customer_repository.dart';
import 'package:modular_erp/modules/services/sites/domain/service_site_repository.dart';
import 'package:modular_erp/modules/services/teams/domain/service_team_repository.dart';
import 'package:modular_erp/modules/services/configuration/domain/service_master_repository.dart';
import 'package:modular_erp/modules/services/domain/contracts/workforce_directory.dart';
import 'package:modular_erp/modules/services/enquiries/domain/service_enquiry_repository.dart';
import 'package:modular_erp/modules/services/job_assignments/domain/service_job_assignment_repository.dart';
import 'package:modular_erp/shared/transactions/domain/activity_event.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/modules/hr/dashboard/data/local_dashboard_repository.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_repository.dart';
import 'package:modular_erp/platform/module/platform_registration.dart';
import 'package:modular_erp/shared/domain/configuration_repository.dart';
import 'package:modular_erp/shared/presentation/configuration_landing_page.dart';

/// Composition root for the ERP navigation registry.
///
/// Platform, HR and Services each own their destination registration; this file
/// only wires them together plus the cross-module Settings hub.
ModuleRegistry createErpRegistry(
  AuthRepository authRepository, {
  DashboardRepository? dashboardRepository,
  EmployeeRepository? employeeRepository,
  ShiftRepository? shiftRepository,
  WorkLocationRepository? workLocationRepository,
  AttendancePolicyRepository? attendancePolicyRepository,
  LocationService? locationService,
  AttendanceRepository? attendanceRepository,
  AttendanceCorrectionRepository? correctionRepository,
  WorkforceAttendanceReadRepository? workforceAttendanceRepository,
  AttendanceReportRepository? attendanceReportRepository,
  AttendanceReportExportService? attendanceReportExportService,
  LeaveRepository? leaveRepository,
  ConfigurationRepository<LeaveType, LeaveTypeDraft>? leaveTypeRepository,
  ConfigurationRepository<LeavePolicy, LeavePolicyDraft>? leavePolicyRepository,
  ConfigurationRepository<Holiday, HolidayDraft>? holidayRepository,
  AccessRepository? accessRepository,
  PermissionCatalog? accessCatalog,
  GrantAuthorityResolver? accessAuthority,
  ServiceCustomerRepository? serviceCustomerRepository,
  ServiceSiteRepository? serviceSiteRepository,
  ServiceTeamRepository? serviceTeamRepository,
  ServiceMasterRepository? serviceMasterRepository,
  ServiceEnquiryRepository? serviceEnquiryRepository,
  ServiceJobAssignmentRepository? serviceJobAssignmentRepository,
  WorkforceDirectory? workforceDirectory,
  ActivityRepository? activityRepository,
}) {
  final dashboard =
      dashboardRepository ??
      LocalDashboardRepository(demoEnabled: AppConfig.demoAuthEnabled);
  late final ModuleRegistry registry;

  final platformModules = buildPlatformModules(
    registry: () => registry,
    authRepository: authRepository,
    employeeRepository: employeeRepository,
  );
  final hr = buildHrModules(
    registry: () => registry,
    dashboardRepository: dashboard,
    employeeRepository: employeeRepository,
    shiftRepository: shiftRepository,
    workLocationRepository: workLocationRepository,
    attendancePolicyRepository: attendancePolicyRepository,
    locationService: locationService,
    attendanceRepository: attendanceRepository,
    correctionRepository: correctionRepository,
    workforceAttendanceRepository: workforceAttendanceRepository,
    attendanceReportRepository: attendanceReportRepository,
    attendanceReportExportService: attendanceReportExportService,
    leaveRepository: leaveRepository,
    leaveTypeRepository: leaveTypeRepository,
    leavePolicyRepository: leavePolicyRepository,
    holidayRepository: holidayRepository,
  );

  registry = ModuleRegistry.fromModules([
    ...platformModules,
    ...hr.modules,
    AppModule(
      id: AppModuleIds.settings,
      destinations: [
        RegisteredDestination(
          navigation: ErpModule(
            id: 'settings',
            moduleId: AppModuleIds.settings,
            name: (l) => l.cfgConfiguration,
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            route: AppRoutes.settings,
            // HR configuration now lives under /app/hr/settings; the Settings
            // hub keeps owning that subtree for active-state purposes.
            routeAliases: {HrRoutes.settings},
            navigationGroup: NavigationGroup.configuration,
            order: 40,
            anyPermissions: {
              AppPermission.shiftView,
              AppPermission.workLocationView,
              AppPermission.attendancePolicyView,
              AppPermission.leaveTypeView,
              AppPermission.leavePolicyView,
              AppPermission.holidayView,
              AppPermission.companyManage,
              AppPermission.userManage,
              AppPermission.accessUsersView,
              AppPermission.accessPermissionsManage,
              AppPermission.companyModulesView,
            },
          ),
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              name: 'settings',
              pageBuilder: (context, state) => AppRouteTransitions.page(
                context,
                state,
                ConfigurationLandingPage(
                  shiftRepository: shiftRepository,
                  workLocationRepository: workLocationRepository,
                  attendancePolicyRepository: attendancePolicyRepository,
                  leaveTypeRepository: leaveTypeRepository,
                  leavePolicyRepository: leavePolicyRepository,
                  holidayRepository: holidayRepository,
                ),
              ),
            ),
          ],
        ),
        if (accessRepository != null &&
            accessCatalog != null &&
            accessAuthority != null) ...[
          RegisteredDestination(
            navigation: ErpModule(
              id: 'access-users',
              moduleId: AppModuleIds.settings,
              name: (l) => l.usersAccessTitle,
              icon: Icons.manage_accounts_outlined,
              route: AppRoutes.access,
              navigationGroup: NavigationGroup.configuration,
              order: 47,
              desktopVisible: false,
              mobileVisible: false,
              anyPermissions: {
                AppPermission.accessUsersView,
                AppPermission.accessPermissionsManage,
              },
            ),
            routes: [
              GoRoute(
                path: AppRoutes.access,
                name: 'access',
                builder: (context, state) => UsersAccessPage(
                  repository: accessRepository,
                  catalog: accessCatalog,
                ),
                routes: [
                  GoRoute(
                    path: 'users/:userId',
                    name: 'access-user',
                    builder: (context, state) => UserAccessDetailPage(
                      repository: accessRepository,
                      catalog: accessCatalog,
                      authority: accessAuthority,
                      userId: state.pathParameters['userId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          RegisteredDestination(
            navigation: ErpModule(
              id: 'company-modules',
              moduleId: AppModuleIds.settings,
              name: (l) => l.accessCompanyModules,
              icon: Icons.widgets_outlined,
              route: AppRoutes.modules,
              navigationGroup: NavigationGroup.configuration,
              order: 48,
              desktopVisible: false,
              mobileVisible: false,
              requiredPermissions: {AppPermission.companyModulesView},
            ),
            routes: [
              GoRoute(
                path: AppRoutes.modules,
                name: 'company-modules',
                builder: (context, state) =>
                    CompanyModulesPage(catalog: accessCatalog),
              ),
            ],
          ),
        ],
        ...hr.settingsDestinations,
      ],
    ),
    ...buildServicesModules(
      customers: serviceCustomerRepository,
      sites: serviceSiteRepository,
      teams: serviceTeamRepository,
      masters: serviceMasterRepository,
      enquiries: serviceEnquiryRepository,
      jobAssignments: serviceJobAssignmentRepository,
      workforce: workforceDirectory,
      activity: activityRepository,
    ),
  ]);
  return registry;
}
