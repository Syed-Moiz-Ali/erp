import 'dart:async';

import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/platform/access/domain/permission_master.dart';
import 'package:modular_erp/platform/access/domain/permission_master_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/domain/configuration_repository.dart';

/// Presentation projection of a backend [PermissionMaster] onto the shared
/// [ConfigurationRecord] contract used by the existing configuration screens.
class PermissionMasterRecord implements ConfigurationRecord {
  const PermissionMasterRecord(this.permission, {required this.companyId});

  final PermissionMaster permission;

  @override
  final String companyId;

  int get permissionId => permission.id;
  String get key => permission.key;
  String? get description => permission.description;
  int get statusId => permission.statusId;
  DateTime? get createdOn => permission.createdOn;
  DateTime? get modifiedOn => permission.modifiedOn;

  static final DateTime _epoch = DateTime.fromMillisecondsSinceEpoch(
    0,
    isUtc: true,
  );

  @override
  String get id => permission.id.toString();

  @override
  String get name => permission.name;

  @override
  ConfigurationStatus get status => permission.isActive
      ? ConfigurationStatus.active
      : ConfigurationStatus.inactive;

  @override
  RecordSyncStatus get syncStatus => RecordSyncStatus.synced;

  @override
  DateTime get createdAt => permission.createdOn ?? _epoch;

  @override
  DateTime get updatedAt => permission.modifiedOn ?? _epoch;

  @override
  Map<String, dynamic> toJson() => {
    'permissionId': permission.id,
    'permissionKey': permission.key,
    'permissionName': permission.name,
    'statusId': permission.statusId,
    'description': permission.description,
    'status': permission.status,
    'createdBy': permission.createdBy,
    'createdOn': permission.createdOn?.toIso8601String(),
    'modifiedBy': permission.modifiedBy,
    'modifiedOn': permission.modifiedOn?.toIso8601String(),
  };
}

/// Editable permission-catalog draft. The key is validated with the same rule
/// as the backend boundary (dot-separated, non-empty segments, max 100 chars).
class PermissionMasterDraft {
  const PermissionMasterDraft({
    this.key = '',
    this.name = '',
    this.description,
    this.status = ConfigurationStatus.active,
  });

  final String key, name;
  final String? description;
  final ConfigurationStatus status;

  static const int maxKeyLength = 100;

  static final RegExp keyPattern = RegExp(r'^[A-Za-z0-9_]+(\.[A-Za-z0-9_]+)+$');

  PermissionMasterDraft normalized() => PermissionMasterDraft(
    key: key.trim(),
    name: name.trim(),
    description: description?.trim(),
    status: status,
  );

  PermissionMasterDraft copyWith({
    String? key,
    String? name,
    String? description,
    bool clearDescription = false,
    ConfigurationStatus? status,
  }) => PermissionMasterDraft(
    key: key ?? this.key,
    name: name ?? this.name,
    description: clearDescription ? null : description ?? this.description,
    status: status ?? this.status,
  );

  Map<String, String> validate() {
    final errors = <String, String>{};
    final trimmedKey = key.trim();
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      errors['permissionName'] = 'required';
    }
    if (trimmedKey.isEmpty) {
      errors['permissionKey'] = 'required';
    } else if (trimmedKey.length > maxKeyLength) {
      errors['permissionKey'] = 'permissionKeyTooLong';
    } else if (!keyPattern.hasMatch(trimmedKey)) {
      errors['permissionKey'] = 'invalidPermissionKey';
    }
    return Map.unmodifiable(errors);
  }

  factory PermissionMasterDraft.fromRecord(PermissionMasterRecord record) =>
      PermissionMasterDraft(
        key: record.key,
        name: record.name,
        description: record.description,
        status: record.status,
      );
}

/// Backend-only adapter from [PermissionMasterRepository] to the shared
/// configuration workflow. Successful writes bump a broadcast revision so
/// active list/detail watchers re-fetch instead of showing optimistic data.
class PermissionMasterConfigurationRepository
    implements
        ConfigurationRepository<PermissionMasterRecord, PermissionMasterDraft> {
  PermissionMasterConfigurationRepository(this._repository);

  final PermissionMasterRepository _repository;
  final _revision = StreamController<void>.broadcast();

  @override
  Stream<Result<ConfigurationPageData<PermissionMasterRecord>>> watchList(
    AuthContext context, {
    String query = '',
    ConfigurationStatus? status,
    int page = 0,
    int pageSize = 10,
  }) => _watch(() => _load(context, query, status, page, pageSize));

  Stream<Result<T>> _watch<T>(Future<Result<T>> Function() load) {
    late StreamController<Result<T>> controller;
    StreamSubscription<void>? revision;
    controller = StreamController<Result<T>>(
      onListen: () {
        load().then((result) {
          if (!controller.isClosed) controller.add(result);
        });
        revision = _revision.stream.listen((_) {
          load().then((result) {
            if (!controller.isClosed) controller.add(result);
          });
        });
      },
      onCancel: () async => revision?.cancel(),
    );
    return controller.stream;
  }

  Future<Result<ConfigurationPageData<PermissionMasterRecord>>> _load(
    AuthContext context,
    String query,
    ConfigurationStatus? status,
    int page,
    int pageSize,
  ) async {
    final result = await _repository.list(
      search: query.trim(),
      statusId: switch (status) {
        null => null,
        ConfigurationStatus.active => 1,
        ConfigurationStatus.inactive => 2,
      },
      page: page + 1,
      pageSize: pageSize,
    );
    switch (result) {
      case Success<PermissionMasterPage>(:final value):
        return Success(
          ConfigurationPageData<PermissionMasterRecord>(
            value.items
                .map(
                  (permission) => ConfigurationItem(
                    PermissionMasterRecord(
                      permission,
                      companyId: context.company.id,
                    ),
                    0,
                  ),
                )
                .toList(growable: false),
            value.totalItems,
            value.totalItems,
          ),
        );
      case Failed<PermissionMasterPage>(:final failure):
        return Failed(failure);
    }
  }

  @override
  Stream<Result<ConfigurationItem<PermissionMasterRecord>?>> watchDetails(
    AuthContext context,
    String id,
  ) => _watch(() => _detail(context, id));

  Future<Result<ConfigurationItem<PermissionMasterRecord>?>> _detail(
    AuthContext context,
    String id,
  ) async {
    final found = await getById(context, id);
    switch (found) {
      case Success<PermissionMasterRecord?>(:final value):
        return Success(value == null ? null : ConfigurationItem(value, 0));
      case Failed<PermissionMasterRecord?>(:final failure):
        return Failed(failure);
    }
  }

  @override
  Future<Result<PermissionMasterRecord?>> getById(
    AuthContext context,
    String id, {
    bool forEditing = false,
  }) async {
    final numericId = _parseId(id);
    if (numericId == null) return const Success(null);
    final result = await _repository.getById(numericId);
    switch (result) {
      case Success<PermissionMaster>(:final value):
        return Success(
          PermissionMasterRecord(value, companyId: context.company.id),
        );
      case Failed<PermissionMaster>(:final failure):
        if (failure.kind == FailureKind.notFound) return const Success(null);
        return Failed(failure);
    }
  }

  @override
  Future<Result<PermissionMasterRecord>> save(
    AuthContext context,
    PermissionMasterDraft draft, {
    String? id,
  }) async {
    final normalized = draft.normalized();
    final errors = normalized.validate();
    if (errors.isNotEmpty) {
      return Failed(
        Failure(
          code: errors.values.first,
          kind: FailureKind.validation,
          field: errors.keys.first,
        ),
      );
    }

    if (id == null) {
      final created = await _repository.create(
        key: normalized.key,
        name: normalized.name,
        description: normalized.description,
      );
      switch (created) {
        case Failed<PermissionMaster>(:final failure):
          return Failed(failure);
        case Success<PermissionMaster>(:final value):
          if (normalized.status == ConfigurationStatus.inactive) {
            final deactivated = await _repository.setActive(value.id, false);
            switch (deactivated) {
              case Failed<PermissionMaster>(:final failure):
                return Failed(failure);
              case Success<PermissionMaster>(:final value):
                _revision.add(null);
                return Success(
                  PermissionMasterRecord(value, companyId: context.company.id),
                );
            }
          }
          _revision.add(null);
          return Success(
            PermissionMasterRecord(value, companyId: context.company.id),
          );
      }
    }

    final numericId = _parseId(id);
    if (numericId == null) {
      return const Failed(
        Failure(code: 'PERMISSION_NOT_FOUND', kind: FailureKind.notFound),
      );
    }

    final currentResult = await _repository.getById(numericId);
    final PermissionMaster current;
    switch (currentResult) {
      case Failed<PermissionMaster>(:final failure):
        return Failed(failure);
      case Success<PermissionMaster>(:final value):
        current = value;
    }

    final updated = await _repository.update(
      numericId,
      key: normalized.key,
      name: normalized.name,
      description: normalized.description ?? '',
    );
    switch (updated) {
      case Failed<PermissionMaster>(:final failure):
        return Failed(failure);
      case Success<PermissionMaster>(:final value):
        if (current.isActive !=
            (normalized.status == ConfigurationStatus.active)) {
          final toggled = await _repository.setActive(
            numericId,
            normalized.status == ConfigurationStatus.active,
          );
          switch (toggled) {
            case Failed<PermissionMaster>(:final failure):
              return Failed(failure);
            case Success<PermissionMaster>(:final value):
              _revision.add(null);
              return Success(
                PermissionMasterRecord(value, companyId: context.company.id),
              );
          }
        }
        _revision.add(null);
        return Success(
          PermissionMasterRecord(value, companyId: context.company.id),
        );
    }
  }

  @override
  Future<Result<void>> setActive(
    AuthContext context,
    String id,
    bool active,
  ) async {
    final numericId = _parseId(id);
    if (numericId == null) {
      return const Failed(
        Failure(code: 'PERMISSION_NOT_FOUND', kind: FailureKind.notFound),
      );
    }
    final result = await _repository.setActive(numericId, active);
    switch (result) {
      case Success<PermissionMaster>():
        _revision.add(null);
        return const Success(null);
      case Failed<PermissionMaster>(:final failure):
        return Failed(failure);
    }
  }

  @override
  Future<Result<int>> assignedEmployeeCount(
    AuthContext context,
    String id,
  ) async => const Success(0);

  static int? _parseId(String id) => int.tryParse(id.trim());

  Future<void> dispose() => _revision.close();
}
