import 'package:get_it/get_it.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/app/access/erp_access_catalog.dart';
import 'package:modular_erp/core/api/api_client.dart';
import 'package:modular_erp/core/security/permission_catalog.dart';
import 'package:modular_erp/platform/access/data/datasources/remote/access_remotes.dart';
import 'package:modular_erp/platform/access/data/repositories/remote_access_repository.dart';
import 'package:modular_erp/platform/access/data/repositories/remote_permission_master_repository.dart';
import 'package:modular_erp/platform/access/domain/permission_master_repository.dart';
import 'package:modular_erp/platform/access/domain/access_repository.dart';
import 'package:modular_erp/platform/access/domain/grant_authority.dart';

/// Access-administration dependencies (catalog, repository, guards).
///
/// Backend permissions come only from `/api/me/permissions`; there is no local
/// grant store or local grant controller.
void configureAccessDependencies(GetIt services) {
  services.registerSingleton<PermissionCatalog>(
    AppConfig.authMode == AuthMode.backend
        ? erpAccessCatalog.backendView
        : erpAccessCatalog,
  );
  if (AppConfig.authMode == AuthMode.backend) {
    services.registerLazySingleton<AccessAdminRemoteDataSource>(
      () => DioAccessAdminRemoteDataSource(services<ApiClient>()),
    );
    services.registerLazySingleton<AccessRepository>(
      () => RemoteAccessRepository(services(), services()),
      dispose: (repository) {
        if (repository is RemoteAccessRepository) repository.dispose();
      },
    );
    services.registerLazySingleton<PermissionMasterRepository>(
      () => RemotePermissionMasterRepository(services()),
    );
  }
  services.registerLazySingleton(() => const GrantAuthorityResolver());
}
