import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/access/data/datasources/remote/access_remotes.dart';
import 'package:modular_erp/platform/access/data/dto/permission_dtos.dart';
import 'package:modular_erp/platform/access/domain/permission_master.dart';
import 'package:modular_erp/platform/access/domain/permission_master_repository.dart';

/// Backend-mode [PermissionMasterRepository] over `/api/permissions`.
///
/// Permission keys are validated here, at the repository boundary, before any
/// request is sent: non-empty, no whitespace, at most [maxKeyLength] characters
/// and dot-separated (`^[A-Za-z0-9_]+(\.[A-Za-z0-9_]+)+$`, e.g.
/// `company.access.permissions.manage`). Names/descriptions are not validated
/// beyond a required non-empty name on create.
///
/// Error codes are preserved verbatim from the backend envelope
/// (`PERMISSION_DUPLICATE_KEY`, `VALIDATION_ERROR`, `PERMISSION_NOT_FOUND`,
/// `PERMISSION_ALREADY_ACTIVE`, `PERMISSION_ALREADY_INACTIVE`). Activate and
/// deactivate are **not** treated as idempotent: an already-active/inactive
/// response propagates the documented code as a conflict failure.
class RemotePermissionMasterRepository implements PermissionMasterRepository {
  RemotePermissionMasterRepository(this._dataSource);

  final AccessAdminRemoteDataSource _dataSource;

  static const String keyField = 'permissionKey';
  static const String nameField = 'permissionName';
  static const int maxKeyLength = 100;

  static final RegExp _keyPattern = RegExp(
    r'^[A-Za-z0-9_]+(\.[A-Za-z0-9_]+)+$',
  );

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

  Result<PermissionMaster> _mapResult(Result<PermissionDto> result) =>
      switch (result) {
        Failed(:final failure) => Failed(_normalize(failure)),
        Success(:final value) => Success(_map(value)),
      };

  /// Validates a trimmed key. Returns `null` when the key is well formed.
  Failure? _validateKey(String key) {
    if (key.isEmpty ||
        key.length > maxKeyLength ||
        !_keyPattern.hasMatch(key)) {
      return const Failure(
        code: 'VALIDATION_ERROR',
        kind: FailureKind.validation,
        field: keyField,
      );
    }
    return null;
  }

  /// Keeps the backend code but makes the failure kind/field actionable.
  Failure _normalize(Failure failure) => switch (failure.code) {
    'PERMISSION_DUPLICATE_KEY' => failure.copyWith(
      kind: FailureKind.conflict,
      field: failure.field ?? keyField,
    ),
    'PERMISSION_NOT_FOUND' => failure.copyWith(kind: FailureKind.notFound),
    'PERMISSION_ALREADY_ACTIVE' || 'PERMISSION_ALREADY_INACTIVE' =>
      failure.copyWith(kind: FailureKind.conflict),
    _ => failure,
  };

  @override
  Future<Result<PermissionMasterPage>> list({
    String search = '',
    int? statusId,
    String sort = 'keyAsc',
    int page = 1,
    int pageSize = 100,
  }) async {
    final result = await _dataSource.permissions(
      search: search,
      statusId: statusId,
      sort: sort,
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
  Future<Result<PermissionMaster>> getById(int id) async =>
      _mapResult(await _dataSource.permissionById(id));

  @override
  Future<Result<PermissionMaster>> create({
    required String key,
    required String name,
    String? description,
  }) async {
    final trimmedKey = key.trim();
    final keyFailure = _validateKey(trimmedKey);
    if (keyFailure != null) return Failed(keyFailure);

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return const Failed(
        Failure(
          code: 'VALIDATION_ERROR',
          kind: FailureKind.validation,
          field: nameField,
        ),
      );
    }

    final trimmedDescription = description?.trim();
    final result = await _dataSource.createPermission({
      keyField: trimmedKey,
      nameField: trimmedName,
      if (trimmedDescription != null && trimmedDescription.isNotEmpty)
        'description': trimmedDescription,
    });
    return _mapResult(result);
  }

  @override
  Future<Result<PermissionMaster>> update(
    int id, {
    String? key,
    String? name,
    String? description,
  }) async {
    final trimmedKey = key?.trim();
    if (trimmedKey != null && trimmedKey.isNotEmpty) {
      final keyFailure = _validateKey(trimmedKey);
      if (keyFailure != null) return Failed(keyFailure);
    }

    final trimmedName = name?.trim();
    final result = await _dataSource.updatePermission(id, {
      if (trimmedKey != null && trimmedKey.isNotEmpty) keyField: trimmedKey,
      if (trimmedName != null && trimmedName.isNotEmpty) nameField: trimmedName,
      if (description != null) 'description': description.trim(),
    });
    return _mapResult(result);
  }

  @override
  Future<Result<PermissionMaster>> setActive(int id, bool active) async =>
      _mapResult(await _dataSource.setPermissionActive(id, active: active));
}
