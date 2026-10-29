import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/access/domain/permission_master.dart';

class PermissionMasterPage {
  const PermissionMasterPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final List<PermissionMaster> items;
  final int page, pageSize, totalItems, totalPages;
}

/// Admin CRUD over permission masters. Writes require
/// `company.access.permissions.manage`; reads require
/// `company.access.users.view`.
abstract interface class PermissionMasterRepository {
  Future<Result<PermissionMasterPage>> list({
    String search = '',
    int? statusId,
    int page = 1,
    int pageSize = 100,
  });

  Future<Result<PermissionMaster>> getById(int id);

  Future<Result<PermissionMaster>> create({
    required String key,
    required String name,
    String? description,
  });

  Future<Result<PermissionMaster>> update(
    int id, {
    String? key,
    String? name,
    String? description,
  });

  Future<Result<PermissionMaster>> setActive(int id, bool active);
}
