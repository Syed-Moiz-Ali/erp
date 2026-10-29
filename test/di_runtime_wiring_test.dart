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
import 'package:modular_erp/modules/hr/departments/data/repositories/remote_department_repository.dart';
import 'package:modular_erp/modules/hr/departments/domain/department_repository.dart';
import 'package:modular_erp/modules/hr/module/hr_dependencies.dart';
import 'package:modular_erp/modules/hr/shifts/data/local_shift_repository.dart';
import 'package:modular_erp/modules/hr/shifts/data/repositories/remote_shift_repository.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift_repository.dart';
import 'package:modular_erp/modules/services/module/services_dependencies.dart';
import 'package:modular_erp/platform/access/access_dependencies.dart';
import 'package:modular_erp/platform/auth/data/repositories/disabled_auth_repository.dart';
import 'package:modular_erp/platform/auth/data/repositories/remote_auth_repository.dart';
import 'package:modular_erp/platform/auth/domain/repositories/auth_repository.dart';
import 'package:modular_erp/platform/module/platform_dependencies.dart';
import 'package:modular_erp/shared/transactions/transactions_dependencies.dart';

/// Proves the real GetIt composition selects the authentication and department
/// repositories that match the injected [AppConfig] environment, with no
/// duplicates, and that the configured URL is injected into Dio. No dart-defines
/// are involved.
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
      expect(services.isRegistered<ApiClient>(), isTrue);
      expect(
        services<ApiClient>().dio.options.baseUrl,
        'https://dev.example.test',
      );
      expect(services.isRegistered<ModuleRegistry>(), isTrue);
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
      expect(services.isRegistered<DepartmentRepository>(), isFalse);
      expect(services<ShiftRepository>(), isA<LocalShiftRepository>());
      expect(services.isRegistered<ApiClient>(), isFalse);
    },
  );
}
