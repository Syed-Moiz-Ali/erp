import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/app/app_environment.dart';
import 'package:modular_erp/app/module_registry/module_registry.dart';
import 'package:modular_erp/bootstrap/core_dependencies.dart';
import 'package:modular_erp/bootstrap/dependencies.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/database/app_database.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/modules/hr/dashboard/data/empty_dashboard_repository.dart';
import 'package:modular_erp/modules/hr/dashboard/data/local_dashboard_repository.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_models.dart';
import 'package:modular_erp/modules/hr/dashboard/domain/dashboard_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/hr/branches/data/datasources/branch_remote_data_source.dart';
import 'package:modular_erp/modules/hr/branches/data/datasources/dio_branch_remote_data_source.dart';
import 'package:modular_erp/modules/hr/branches/data/repositories/remote_branch_repository.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_repository.dart';
import 'package:modular_erp/modules/hr/attendance/live/data/remote_attendance_repository.dart';
import 'package:modular_erp/modules/hr/attendance/data/local_attendance_repository.dart';
import 'package:modular_erp/modules/hr/departments/data/repositories/local_department_repository.dart';
import 'package:modular_erp/modules/hr/departments/data/repositories/remote_department_repository.dart';
import 'package:modular_erp/modules/hr/departments/domain/department_repository.dart';
import 'package:modular_erp/modules/hr/employees/data/local_employee_repository.dart';
import 'package:modular_erp/modules/hr/employees/domain/employee_repository.dart';
import 'package:modular_erp/modules/hr/employees/live/data/repositories/remote_employee_repository.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/repositories/remote_employee_shift_repository.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift_repository.dart';
import 'package:modular_erp/modules/hr/module/hr_dependencies.dart';
import 'package:modular_erp/modules/hr/shifts/data/local_shift_repository.dart';
import 'package:modular_erp/modules/hr/shifts/data/repositories/remote_shift_repository.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift_repository.dart';
import 'package:modular_erp/modules/services/module/services_dependencies.dart';
import 'package:modular_erp/platform/access/access_dependencies.dart';
import 'package:modular_erp/platform/access/data/local_access_repository.dart';
import 'package:modular_erp/platform/access/data/repositories/remote_access_repository.dart';
import 'package:modular_erp/platform/access/data/repositories/remote_permission_master_repository.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/permission_master_repository.dart';
import 'package:modular_erp/platform/auth/data/repositories/demo_auth_repository.dart';
import 'package:modular_erp/platform/auth/data/repositories/disabled_auth_repository.dart';
import 'package:modular_erp/platform/auth/data/repositories/remote_auth_repository.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/platform/module/platform_dependencies.dart';
import 'package:modular_erp/shared/transactions/transactions_dependencies.dart';

/// Proves the real GetIt composition selects the authentication and department
/// repositories that match the injected [AppConfig] environment, with no
/// duplicates, and that the configured URL is injected into Dio. No dart-defines
/// are involved.
AuthContext _dashboardContext() => AuthContext(
  user: UserAccount(
    id: '8',
    displayName: 'Admin',
    email: 'admin',
    companyId: '1',
    permissions: PermissionSet(const <AppPermission>[
      AppPermission.employeeViewAll,
    ]),
    status: AccountStatus.active,
  ),
  company: const CompanyContext(
    id: '1',
    name: 'Company',
    code: 'ORG-1',
    timezone: 'Asia/Dubai',
    defaultLocale: 'en',
    enabledModules: {'employees', 'settings'},
  ),
);

void main() {
  Future<GetIt> compose() async {
    final services = GetIt.asNewInstance();
    configureCoreDependencies(services);
    services.unregister<AppDatabase>();
    services.registerSingleton<AppDatabase>(
      AppDatabase(NativeDatabase.memory()),
    );
    configureTransactionDependencies(services);
    configurePlatformDependencies(services);
    configureAccessDependencies(services);
    configureHrDependencies(services);
    configureServicesDependencies(services);
    configureApplicationComposition(services);
    return services;
  }

  setUp(AppConfig.reset);
  tearDown(AppConfig.reset);

  test(
    'backend environment selects remote repositories and injects the URL',
    () async {
      AppConfig.configure(
        const AppEnvironment(
          name: EnvironmentConfig.developmentName,
          apiBaseUrl: 'https://dev.example.test',
          authMode: AuthMode.backend,
          allowInsecureHttp: false,
        ),
      );
      final services = await compose();
      addTearDown(services.reset);

      expect(services<AuthRepository>(), isA<RemoteAuthRepository>());
      expect(
        services<DepartmentRepository>(),
        isA<RemoteDepartmentRepository>(),
      );
      expect(services<ShiftRepository>(), isA<RemoteShiftRepository>());
      expect(
        services<EmployeeShiftRepository>(),
        isA<RemoteEmployeeShiftRepository>(),
      );
      expect(services<BranchRepository>(), isA<RemoteBranchRepository>());
      expect(
        services<BranchRemoteDataSource>(),
        isA<DioBranchRemoteDataSource>(),
      );
      expect(services<EmployeeRepository>(), isA<RemoteEmployeeRepository>());
      expect(
        services<AttendanceRepository>(),
        isA<RemoteAttendanceRepository>(),
      );
      expect(services<AccessRepository>(), isA<RemoteAccessRepository>());
      expect(
        services<PermissionMasterRepository>(),
        isA<RemotePermissionMasterRepository>(),
      );
      expect(services.isRegistered<ApiClient>(), isTrue);
      expect(
        services<ApiClient>().dio.options.baseUrl,
        'https://dev.example.test',
      );
      expect(services.isRegistered<ModuleRegistry>(), isTrue);
      expect(services<DashboardRepository>(), isA<EmptyDashboardRepository>());
      final dashboard = await services<DashboardRepository>().load(
        _dashboardContext(),
      );
      expect(dashboard, isA<Success<DashboardSummary>>());
      final summary = (dashboard as Success<DashboardSummary>).value;
      expect(summary.isEmpty, isTrue);
      expect(summary.isDemo, isFalse);
    },
  );

  test(
    'demo environment selects demo/local and builds no API client',
    () async {
      AppConfig.configure(
        const AppEnvironment(
          name: EnvironmentConfig.developmentName,
          apiBaseUrl: '',
          authMode: AuthMode.demo,
          allowInsecureHttp: true,
        ),
      );
      final services = await compose();
      addTearDown(services.reset);

      expect(services<AuthRepository>(), isA<DemoAuthRepository>());
      expect(
        services<DepartmentRepository>(),
        isA<LocalDepartmentRepository>(),
      );
      expect(services<ShiftRepository>(), isA<LocalShiftRepository>());
      expect(services.isRegistered<EmployeeShiftRepository>(), isFalse);
      expect(services.isRegistered<BranchRepository>(), isFalse);
      expect(services.isRegistered<BranchRemoteDataSource>(), isFalse);
      expect(services<EmployeeRepository>(), isA<LocalEmployeeRepository>());
      expect(
        services<AttendanceRepository>(),
        isA<LocalAttendanceRepository>(),
      );
      expect(services<AccessRepository>(), isA<LocalAccessRepository>());
      expect(services.isRegistered<PermissionMasterRepository>(), isFalse);
      expect(services.isRegistered<ApiClient>(), isFalse);
      expect(services<DashboardRepository>(), isA<LocalDashboardRepository>());
    },
  );

  test(
    'disabled environment fails auth safely and builds no API client',
    () async {
      AppConfig.configure(
        const AppEnvironment(
          name: EnvironmentConfig.productionName,
          apiBaseUrl: '',
          authMode: AuthMode.disabled,
          allowInsecureHttp: false,
          configurationError: 'API_BASE_URL is missing',
        ),
      );
      final services = await compose();
      addTearDown(services.reset);

      expect(services<AuthRepository>(), isA<DisabledAuthRepository>());
      expect(
        services<DepartmentRepository>(),
        isA<LocalDepartmentRepository>(),
      );
      expect(services<ShiftRepository>(), isA<LocalShiftRepository>());
      expect(services.isRegistered<EmployeeShiftRepository>(), isFalse);
      expect(services.isRegistered<BranchRepository>(), isFalse);
      expect(services.isRegistered<BranchRemoteDataSource>(), isFalse);
      expect(services<EmployeeRepository>(), isA<LocalEmployeeRepository>());
      expect(
        services<AttendanceRepository>(),
        isA<LocalAttendanceRepository>(),
      );
      expect(services<AccessRepository>(), isA<LocalAccessRepository>());
      expect(services.isRegistered<PermissionMasterRepository>(), isFalse);
      expect(services.isRegistered<ApiClient>(), isFalse);
    },
  );
}
