import 'package:modular_erp/core/security/app_permission.dart';
import 'package:modular_erp/core/security/permission_catalog.dart';
import 'package:modular_erp/core/security/permission_definition.dart';
import 'package:modular_erp/core/security/permission_scope.dart';

/// Platform / company-administration permission contribution. Platform-only
/// permissions are not company-delegable.
const platformPermissionModules = <PermissionModule>[
  PermissionModule(
    id: 'platform',
    nameKey: 'accessModulePlatform',
    order: 90,
    submodules: [
      PermissionSubmodule(
        id: 'access',
        nameKey: 'accessSubAccess',
        order: 1,
        definitions: [
          PermissionDefinition(
            key: 'company.access.users.view',
            moduleId: 'platform',
            submoduleId: 'access',
            nameKey: 'accessUsersView',
            descriptionKey: 'accessUsersViewDesc',
            order: 1,
            permissions: {PermissionScope.none: AppPermission.accessUsersView},
          ),
          PermissionDefinition(
            key: 'company.access.permissions.manage',
            moduleId: 'platform',
            submoduleId: 'access',
            nameKey: 'accessPermissionsManage',
            descriptionKey: 'accessPermissionsManageDesc',
            order: 2,
            risk: PermissionRisk.elevated,
            permissions: {
              PermissionScope.none: AppPermission.accessPermissionsManage,
            },
          ),
          PermissionDefinition(
            key: 'company.modules.view',
            moduleId: 'platform',
            submoduleId: 'access',
            nameKey: 'accessModulesView',
            descriptionKey: 'accessModulesViewDesc',
            order: 3,
            permissions: {
              PermissionScope.none: AppPermission.companyModulesView,
            },
          ),
          PermissionDefinition(
            key: 'company.users.manage',
            moduleId: 'platform',
            submoduleId: 'access',
            nameKey: 'accessCompanyUsersManage',
            descriptionKey: 'accessCompanyUsersManageDesc',
            order: 4,
            permissions: {PermissionScope.none: AppPermission.userManage},
          ),
          PermissionDefinition(
            key: 'platform.companies.manage',
            moduleId: 'platform',
            submoduleId: 'access',
            nameKey: 'accessPlatformCompaniesManage',
            descriptionKey: 'accessPlatformCompaniesManageDesc',
            order: 6,
            platformOnly: true,
            delegable: false,
            permissions: {PermissionScope.none: AppPermission.companyManage},
          ),
          PermissionDefinition(
            key: 'platform.modules.manage',
            moduleId: 'platform',
            submoduleId: 'access',
            nameKey: 'accessPlatformModulesManage',
            descriptionKey: 'accessPlatformModulesManageDesc',
            order: 7,
            platformOnly: true,
            delegable: false,
            permissions: {
              PermissionScope.none: AppPermission.platformModulesManage,
            },
          ),
        ],
      ),
    ],
  ),
];
