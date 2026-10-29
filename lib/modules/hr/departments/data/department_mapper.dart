import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/hr/departments/data/dto/department_dtos.dart';
import 'package:modular_erp/modules/hr/departments/domain/department.dart';

/// Anti-corruption boundary between the MassERP department wire contract and the
/// app's domain [Department].
///
/// The backend integer id is carried as its decimal string form so identity is
/// stable across restarts; it is never parsed as a UUID or replaced by a random
/// local id. The contract exposes no timestamps and no status field (the list is
/// active-only), so a deterministic sentinel timestamp and `active` status are
/// used.
abstract final class DepartmentMapper {
  const DepartmentMapper._();

  static final DateTime _sentinel = DateTime.fromMillisecondsSinceEpoch(
    0,
    isUtc: true,
  );

  static Department toDomain(
    DepartmentDto dto, {
    required String companyId,
    RecordSyncStatus syncStatus = RecordSyncStatus.synced,
  }) => Department(
    id: dto.departmentId.toString(),
    companyId: companyId,
    name: dto.departmentName,
    status: ConfigurationStatus.active,
    createdAt: _sentinel,
    updatedAt: _sentinel,
    syncStatus: syncStatus,
  );

  /// Parses a backend department id, returning null for non-numeric ids (for
  /// example local demo ids) so callers can fail safely instead of throwing.
  static int? parseId(String id) => int.tryParse(id);
}
