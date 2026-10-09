import 'package:modular_erp/modules/hr/departments/domain/department.dart';
import 'package:modular_erp/shared/domain/configuration_repository.dart';

/// Department configuration repository. Backed by the local Drift lookup table
/// in demo mode and by the MassERP API in backend mode; both satisfy the shared
/// [ConfigurationRepository] contract so the presentation layer is identical.
abstract interface class DepartmentRepository
    implements ConfigurationRepository<Department, DepartmentDraft> {}
