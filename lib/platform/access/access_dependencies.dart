import 'package:get_it/get_it.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/app/access/erp_access_catalog.dart';
import 'package:modular_erp/core/security/permission_catalog.dart';
import 'package:modular_erp/platform/access/application/user_grants_controller.dart';
import 'package:modular_erp/platform/access/data/access_user_directory.dart';
import 'package:modular_erp/platform/access/data/local_access_repository.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/grant_authority.dart';
import 'package:modular_erp/platform/auth/data/datasources/local/demo_auth_source.dart';

/// Access-administration dependencies (catalog, directory, repository, guards).
void configureAccessDependencies(GetIt services) {
  services.registerSingleton<PermissionCatalog>(erpAccessCatalog);
  services.registerLazySingleton<AccessUserDirectory>(
    () => AppConfig.demoAuthEnabled
        ? DemoAccessUserDirectory(services<DemoAuthSource>())
        : LocalAccessUserDirectory(services()),
  );
  services.registerLazySingleton<AccessRepository>(
    () => LocalAccessRepository(
      services(),
      services(),
      services(),
      services(),
      outbox: services(),
    ),
  );
  services.registerLazySingleton(() => const GrantAuthorityResolver());
  services.registerLazySingleton<UserGrantsController>(
    () => LocalUserGrantsController(services(), services(), services()),
  );
}
