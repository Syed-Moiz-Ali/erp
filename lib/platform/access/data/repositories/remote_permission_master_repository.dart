import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/access/data/datasources/remote/access_remotes.dart';
import 'package:modular_erp/platform/access/data/dto/permission_dtos.dart';
import 'package:modular_erp/platform/access/domain/permission_master.dart';
import 'package:modular_erp/platform/access/domain/permission_master_repository.dart';

class RemotePermissionMasterRepository implements PermissionMasterRepository {
  RemotePermissionMasterRepository(this._dataSource);

  final AccessAdminRemoteDataSource _dataSource;

  PermissionMaster _map(PermissionDto dto) => PermissionMaster(
    id: dto.permissionId,
    key: dto.permissionKey,
    name: dto.permissionName,
    statusId: dto.statusId,
    description: dto.description,
    status: dto.status,
    createdBy: dto.createdBy,
    createdOn: dto.createdOn,
    modifiedBy: dto.modifiedBy,
    modifiedOn: dto.modifiedOn,
  );

  @override
  Future<Result<PermissionMasterPage>> list({
    String search = '',
    int? statusId,
    int page = 1,
    int pageSize = 100,
  }) async {
    final result = await _dataSource.permissions(
      search: search,
      statusId: statusId,
      page: page,
      pageSize: pageSize,
    );
    return switch (result) {
      Failed(:final failure) => Failed(failure),
      Success(:final value) => Success(
        PermissionMasterPage(
          items: value.items.map(_map).toList(growable: false),
          page: value.page,
          pageSize: value.pageSize,
          totalItems: value.totalItems,
          totalPages: value.totalPages,
        ),
      ),
    };
  }

  @override
  Future<Result<PermissionMaster>> getById(int id) async {
    final result = await _dataSource.permissionById(id);
    return switch (result) {
      Failed(:final failure) => Failed(failure),
      Success(:final value) => Success(_map(value)),
    };
  }

  @override
  Future<Result<PermissionMaster>> create({
    required String key,
    required String name,
    String? description,
  }) async {
    final result = await _dataSource.createPermission({
      'permissionKey': key,
      'permissionName': name,
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
    });
    return switch (result) {
      Failed(:final failure) => Failed(failure),
      Success(:final value) => Success(_map(value)),
    };
  }

  @override
  Future<Result<PermissionMaster>> update(
    int id, {
    String? key,
    String? name,
    String? description,
  }) async {
    final result = await _dataSource.updatePermission(id, {
      if (key != null && key.trim().isNotEmpty) 'permissionKey': key.trim(),
      if (name != null && name.trim().isNotEmpty) 'permissionName': name.trim(),
      if (description != null) 'description': description.trim(),
    });
    return switch (result) {
      Failed(:final failure) => Failed(failure),
      Success(:final value) => Success(_map(value)),
    };
  }

  @override
  Future<Result<PermissionMaster>> setActive(int id, bool active) async {
    final result = await _dataSource.setPermissionActive(id, active: active);
    return switch (result) {
      Failed(:final failure) => Failed(failure),
      Success(:final value) => Success(_map(value)),
    };
  }
}
