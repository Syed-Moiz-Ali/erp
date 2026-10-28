import 'package:get_it/get_it.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/app/access/erp_access_catalog.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/security/permission_catalog.dart';
import 'package:modular_erp/platform/access/data/access_user_directory.dart';
import 'package:modular_erp/platform/access/data/datasources/remote/access_remotes.dart';
import 'package:modular_erp/platform/access/data/local_access_repository.dart';
import 'package:modular_erp/platform/access/data/repositories/remote_access_repository.dart';
import 'package:modular_erp/platform/access/data/repositories/remote_permission_master_repository.dart';
import 'package:modular_erp/platform/access/domain/permission_master_repository.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/grant_authority.dart';

/// Access-administration dependencies (catalog, directory, repository, guards).
void configureAccessDependencies(GetIt services) {
  services.registerSingleton<PermissionCatalog>(
    AppConfig.authMode == AuthMode.backend
        ? erpAccessCatalog.backendView
        : erpAccessCatalog,
  );
  services.registerLazySingleton<AccessUserDirectory>(
    () => LocalAccessUserDirectory(services()),
  );
  if (AppConfig.authMode == AuthMode.backend) {
    services.registerLazySingleton<AccessAdminRemoteDataSource>(
      () => DioAccessAdminRemoteDataSource(services<ApiClient>()),
    );
  }
  services.registerLazySingleton<AccessRepository>(
    () => AppConfig.authMode == AuthMode.backend
        ? RemoteAccessRepository(services(), services())
        : LocalAccessRepository(
            services(),
            services(),
            services(),
            services(),
            outbox: services(),
          ),
    dispose: (repository) {
      if (repository is RemoteAccessRepository) repository.dispose();
    },
  );
  if (AppConfig.authMode == AuthMode.backend) {
    services.registerLazySingleton<PermissionMasterRepository>(
      () => RemotePermissionMasterRepository(services()),
    );
  }
  services.registerLazySingleton(() => const GrantAuthorityResolver());
}
