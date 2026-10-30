import 'dart:async';

import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/domain/configuration_repository.dart';

/// Presentation projection of a backend [Branch] onto the shared
/// [ConfigurationRecord] contract used by the existing configuration screens.
class BranchRecord implements ConfigurationRecord {
  const BranchRecord(this.branch, {required this.companyId});

  final Branch branch;

  @override
  final String companyId;

  int get branchId => branch.branchId;
  String get branchName => branch.branchName;
  String? get branchCode => branch.branchCode;
  String? get contactPerson => branch.contactPerson;
  String? get mobileNo => branch.mobileNo;
  String? get landLine => branch.landLine;
  String? get address => branch.address;
  String? get email => branch.email;
  String? get inventoryAlerts => branch.inventoryAlerts;
  String? get multiInventory => branch.multiInventory;
  int? get divisionId => branch.divisionId;
  String? get divisionName => branch.divisionName;
  int get statusId => branch.statusId;
  String get timeZoneId => branch.timeZoneId;

  @override
  String get id => branch.branchId.toString();

  @override
  String get name => branch.branchName;

  @override
  ConfigurationStatus get status => branch.isActive
      ? ConfigurationStatus.active
      : ConfigurationStatus.inactive;

  @override
  RecordSyncStatus get syncStatus => RecordSyncStatus.synced;

  @override
  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  @override
  DateTime get updatedAt => DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  @override
  Map<String, dynamic> toJson() => {
    'branchId': branch.branchId,
    'branchName': branch.branchName,
    'branchCode': branch.branchCode,
    'contactPerson': branch.contactPerson,
    'mobileNo': branch.mobileNo,
    'landLine': branch.landLine,
    'address': branch.address,
    'email': branch.email,
    'inventoryAlerts': branch.inventoryAlerts,
    'multiInventory': branch.multiInventory,
    'divisionId': branch.divisionId,
    'divisionName': branch.divisionName,
    'statusId': branch.statusId,
    'status': branch.status,
    'timeZoneId': branch.timeZoneId,
  };
}

/// Backend-only adapter from [BranchRepository] to the shared configuration
/// workflow. Successful writes bump a broadcast revision so active list/detail
/// watchers re-fetch instead of showing optimistic data.
class BranchConfigurationRepository
    implements ConfigurationRepository<BranchRecord, BranchDraft> {
  BranchConfigurationRepository(this._repository);

  final BranchRepository _repository;
  final _revision = StreamController<void>.broadcast();

  @override
  Stream<Result<ConfigurationPageData<BranchRecord>>> watchList(
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

  Future<Result<ConfigurationPageData<BranchRecord>>> _load(
    AuthContext context,
    String query,
    ConfigurationStatus? status,
    int page,
    int pageSize,
  ) async {
    final result = await _repository.list(
      search: query.trim().isEmpty ? null : query.trim(),
      status: switch (status) {
        null => null,
        ConfigurationStatus.active => BranchStatus.active,
        ConfigurationStatus.inactive => BranchStatus.inactive,
      },
      page: page + 1,
      pageSize: pageSize,
    );
    switch (result) {
      case Success<BranchPage>(:final value):
        return Success(
          ConfigurationPageData<BranchRecord>(
            value.items
                .map(
                  (branch) => ConfigurationItem(
                    BranchRecord(branch, companyId: context.company.id),
                    0,
                  ),
                )
                .toList(growable: false),
            value.totalItems,
            value.totalItems,
          ),
        );
      case Failed<BranchPage>(:final failure):
        return Failed(failure);
    }
  }

  @override
  Stream<Result<ConfigurationItem<BranchRecord>?>> watchDetails(
    AuthContext context,
    String id,
  ) => _watch(() => _detail(context, id));

  Future<Result<ConfigurationItem<BranchRecord>?>> _detail(
    AuthContext context,
    String id,
  ) async {
    final found = await getById(context, id);
    switch (found) {
      case Success<BranchRecord?>(:final value):
        return Success(value == null ? null : ConfigurationItem(value, 0));
      case Failed<BranchRecord?>(:final failure):
        return Failed(failure);
    }
  }

  @override
  Future<Result<BranchRecord?>> getById(
    AuthContext context,
    String id, {
    bool forEditing = false,
  }) async {
    final numericId = _parseId(id);
    if (numericId == null) return const Success(null);
    final result = await _repository.getById(numericId);
    switch (result) {
      case Success<Branch>(:final value):
        return Success(BranchRecord(value, companyId: context.company.id));
      case Failed<Branch>(:final failure):
        if (failure.kind == FailureKind.notFound) return const Success(null);
        return Failed(failure);
    }
  }

  @override
  Future<Result<BranchRecord>> save(
    AuthContext context,
    BranchDraft draft, {
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
    final Result<Branch> result;
    if (id == null) {
      result = await _repository.create(normalized);
    } else {
      final numericId = _parseId(id);
      if (numericId == null) return const Failed(Failure(code: 'notFound'));
      result = await _repository.update(numericId, normalized);
    }
    switch (result) {
      case Success<Branch>(:final value):
        _revision.add(null);
        return Success(BranchRecord(value, companyId: context.company.id));
      case Failed<Branch>(:final failure):
        return Failed(failure);
    }
  }

  @override
  Future<Result<void>> setActive(
    AuthContext context,
    String id,
    bool active,
  ) async {
    final numericId = _parseId(id);
    if (numericId == null) return const Failed(Failure(code: 'notFound'));
    final result = await _repository.setActive(numericId, active);
    switch (result) {
      case Success<void>():
        _revision.add(null);
        return const Success(null);
      case Failed<void>(:final failure):
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
