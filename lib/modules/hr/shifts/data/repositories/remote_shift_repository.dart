import 'dart:async';

import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/hr/shifts/data/datasources/shift_remote_data_source.dart';
import 'package:modular_erp/modules/hr/shifts/data/dto/shift_dtos.dart';
import 'package:modular_erp/modules/hr/shifts/data/shift_mapper.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Backend-mode shift repository. Remote-first: the MassERP API is the source of
/// truth. Successful mutations bump a revision stream so active list/detail
/// watchers re-fetch (cache invalidation without optimistic success).
class RemoteShiftRepository implements ShiftRepository {
  RemoteShiftRepository(this._dataSource);

  final ShiftRemoteDataSource _dataSource;
  final _revision = StreamController<void>.broadcast();

  @override
  Stream<Result<ConfigurationPageData<Shift>>> watchList(
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

  Future<Result<ConfigurationPageData<Shift>>> _load(
    AuthContext context,
    String query,
    ConfigurationStatus? status,
    int page,
    int pageSize,
  ) async {
    final result = await _dataSource.list(
      page: page + 1,
      pageSize: pageSize,
      search: query,
      statusId: _statusId(status),
    );
    switch (result) {
      case Success<PagedResult<ShiftDto>>(:final value):
        return Success(
          ConfigurationPageData<Shift>(
            value.items
                .map(
                  (dto) => ConfigurationItem(
                    ShiftMapper.toDomain(dto, companyId: context.company.id),
                    dto.activeAssignments,
                  ),
                )
                .toList(),
            value.totalItems,
            value.totalItems,
          ),
        );
      case Failed<PagedResult<ShiftDto>>(:final failure):
        return Failed(failure);
    }
  }

  static int? _statusId(ConfigurationStatus? status) => switch (status) {
    ConfigurationStatus.active => 1,
    ConfigurationStatus.inactive => 2,
    null => null,
  };

  @override
  Stream<Result<ConfigurationItem<Shift>?>> watchDetails(
    AuthContext context,
    String id,
  ) => _watch(() => _detail(context, id));

  Future<Result<ConfigurationItem<Shift>?>> _detail(
    AuthContext context,
    String id,
  ) async {
    final numericId = ShiftMapper.parseId(id);
    if (numericId == null) return const Success(null);
    final result = await _dataSource.getById(numericId);
    switch (result) {
      case Success<ShiftDto>(:final value):
        return Success(
          ConfigurationItem(
            ShiftMapper.toDomain(value, companyId: context.company.id),
            value.activeAssignments,
          ),
        );
      case Failed<ShiftDto>(:final failure):
        if (failure.kind == FailureKind.notFound) return const Success(null);
        return Failed(failure);
    }
  }

  @override
  Future<Result<Shift?>> getById(
    AuthContext context,
    String id, {
    bool forEditing = false,
  }) async {
    final numericId = ShiftMapper.parseId(id);
    if (numericId == null) return const Success(null);
    final result = await _dataSource.getById(numericId);
    switch (result) {
      case Success<ShiftDto>(:final value):
        return Success(
          ShiftMapper.toDomain(value, companyId: context.company.id),
        );
      case Failed<ShiftDto>(:final failure):
        if (failure.kind == FailureKind.notFound) return const Success(null);
        return Failed(failure);
    }
  }

  @override
  Future<Result<Shift>> save(
    AuthContext context,
    ShiftDraft draft, {
    String? id,
  }) async {
    final normalized = draft.normalized();
    final error = _validateBackend(normalized);
    if (error != null) {
      return Failed(Failure(code: error, kind: FailureKind.validation));
    }
    final request = ShiftMapper.toUpsert(normalized);
    final result = id == null
        ? await _dataSource.create(request)
        : await _update(id, request);
    switch (result) {
      case Success<ShiftDto>(:final value):
        final requestedActive = normalized.status == ConfigurationStatus.active;
        final returnedActive = value.statusId != 2;
        if (requestedActive != returnedActive) {
          final status = await _ensureStatus(value.shiftId, requestedActive);
          if (status is Failed<void>) return Failed(status.failure);
        }
        _revision.add(null);
        return Success(
          ShiftMapper.toDomain(
            value,
            companyId: context.company.id,
          ).copyWith(status: normalized.status),
        );
      case Failed<ShiftDto>(:final failure):
        return Failed(_mapWriteFailure(failure));
    }
  }

  /// Applies the requested status and treats an already-in-that-state response
  /// as success (the backend makes activate/deactivate idempotent-failing).
  Future<Result<void>> _ensureStatus(int id, bool active) async {
    final result = active
        ? await _dataSource.activate(id)
        : await _dataSource.deactivate(id);
    switch (result) {
      case Success<void>():
        return const Success(null);
      case Failed<void>(:final failure):
        if (active && failure.code == 'SHIFT_ALREADY_ACTIVE') {
          return const Success(null);
        }
        if (!active && failure.code == 'SHIFT_ALREADY_INACTIVE') {
          return const Success(null);
        }
        return Failed(_mapWriteFailure(failure));
    }
  }

  /// Backend-contract validation only. Working days, break rules and minimum
  /// work are local-only concepts the API does not store, so they are not
  /// enforced here (their codes would be misleading).
  static String? _validateBackend(ShiftDraft draft) {
    if (draft.name.trim().isEmpty) return 'required';
    final start = draft.startTime, end = draft.endTime;
    if (start == null || !start.isValid || end == null || !end.isValid) {
      return 'invalidTimeRange';
    }
    final duration = (end.minutes - start.minutes + 1440) % 1440;
    if (duration == 0) return 'invalidTimeRange';
    if (draft.earlyPunchInMinutes < 0 || draft.earlyPunchInMinutes > 120) {
      return 'invalidEarlyPunch';
    }
    if (draft.gracePeriodMinutes < 0 || draft.gracePeriodMinutes >= duration) {
      return 'invalidGrace';
    }
    return null;
  }

  Future<Result<ShiftDto>> _update(String id, ShiftUpsertDto request) {
    final numericId = ShiftMapper.parseId(id);
    if (numericId == null) {
      return Future.value(const Failed(Failure(code: 'notFound')));
    }
    return _dataSource.update(numericId, request);
  }

  @override
  Future<Result<void>> setActive(
    AuthContext context,
    String id,
    bool active,
  ) async {
    final numericId = ShiftMapper.parseId(id);
    if (numericId == null) return const Failed(Failure(code: 'notFound'));
    final result = await _ensureStatus(numericId, active);
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
  ) async {
    final numericId = ShiftMapper.parseId(id);
    if (numericId == null) return const Failed(Failure(code: 'notFound'));
    final result = await _dataSource.getById(numericId);
    switch (result) {
      case Success<ShiftDto>(:final value):
        return Success(value.activeAssignments);
      case Failed<ShiftDto>(:final failure):
        return Failed(failure);
    }
  }

  /// Maps documented backend codes to the codes the shared configuration UI
  /// renders, preserving the safe server message.
  Failure _mapWriteFailure(Failure failure) => switch (failure.code) {
    'SHIFT_DUPLICATE_NAME' => Failure(
      code: 'duplicateName',
      kind: FailureKind.validation,
      field: 'shiftName',
      serverMessage: failure.serverMessage,
    ),
    'SHIFT_IN_USE' => Failure(
      code: 'shiftInUse',
      kind: FailureKind.conflict,
      serverMessage: failure.serverMessage,
    ),
    'SHIFT_NOT_FOUND' => const Failure(
      code: 'notFound',
      kind: FailureKind.notFound,
    ),
    'SHIFT_ALREADY_ACTIVE' || 'SHIFT_ALREADY_INACTIVE' => Failure(
      code: 'notFound',
      kind: FailureKind.conflict,
      serverMessage: failure.serverMessage,
    ),
    _ => failure,
  };

  Future<void> dispose() => _revision.close();
}
