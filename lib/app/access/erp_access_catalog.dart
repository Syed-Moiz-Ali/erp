import 'package:modular_erp/core/security/permission_catalog.dart';
import 'package:modular_erp/modules/hr/access/hr_permission_catalog.dart';
import 'package:modular_erp/modules/services/access/services_permission_catalog.dart';
import 'package:modular_erp/platform/access/platform_permission_catalog.dart';

/// Composition root for the ERP permission catalog.
///
/// Each module owns its contribution; the application composes them once. New
/// modules register here and the Access UI renders them automatically.
const erpAccessCatalog = PermissionCatalog([
  ...hrPermissionModules,
  ...servicesPermissionModules,
  ...platformPermissionModules,
]);
