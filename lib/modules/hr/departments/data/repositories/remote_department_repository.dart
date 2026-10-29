import 'dart:async';

import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/modules/hr/departments/data/datasources/department_remote_data_source.dart';
import 'package:modular_erp/modules/hr/departments/data/department_mapper.dart';
import 'package:modular_erp/modules/hr/departments/data/dto/department_dtos.dart';
import 'package:modular_erp/modules/hr/departments/domain/department.dart';
import 'package:modular_erp/modules/hr/departments/domain/department_repository.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';

/// Backend-mode department repository. Remote-first: the backend is the source
/// of truth and no local cache is written in this phase (offline caching is a
/// later concern). Successful mutations bump a revision stream so any active
/// list/detail watcher re-fetches, giving correct cache invalidation without
/// optimistic success.
class RemoteDepartmentRepository implements DepartmentRepository {
  RemoteDepartmentRepository(this._dataSource);

  final DepartmentRemoteDataSource _dataSource;
  final _revision = StreamController<void>.broadcast();

  @override
  Stream<Result<ConfigurationPageData<Department>>> watchList(
    AuthContext context, {
    String query = '',
    ConfigurationStatus? status,
    int page = 0,
    int pageSize = 10,
  }) => _watch(() => _load(context, query, status, page, pageSize));

  /// Bridges the one-shot remote fetch into a cancellable stream that re-fetches
  /// whenever a mutation bumps [_revision]. A controller (rather than an
  /// `async*`/`await for` generator) is used so cancelling the subscription
  /// reliably tears down the revision listener.
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

  Future<Result<ConfigurationPageData<Department>>> _load(
    AuthContext context,
    String query,
    ConfigurationStatus? status,
    int page,
    int pageSize,
  ) async {
    if (status == ConfigurationStatus.inactive) {
      // The documented list endpoint returns active departments only; there is
      // no inactive source, so the inactive filter is an accurate empty result.
      return Success(ConfigurationPageData<Department>(const [], 0, 0));
    }
    final result = await _dataSource.list(
      page: page + 1,
      pageSize: pageSize,
      search: query,
    );
    switch (result) {
      case Success<PagedResult<DepartmentDto>>(:final value):
        return Success(
          ConfigurationPageData<Department>(
            value.items
                .map(
                  (dto) => ConfigurationItem(
                    DepartmentMapper.toDomain(
                      dto,
                      companyId: context.company.id,
                    ),
                    dto.employeeCount,
                  ),
                )
                .toList(),
            value.totalItems,
            value.totalItems,
          ),
        );
      case Failed<PagedResult<DepartmentDto>>(:final failure):
        return Failed(failure);
    }
  }

  @override
  Stream<Result<ConfigurationItem<Department>?>> watchDetails(
    AuthContext context,
    String id,
  ) => _watch(() => _detail(context, id));

  Future<Result<ConfigurationItem<Department>?>> _detail(
    AuthContext context,
    String id,
  ) async {
    final numericId = DepartmentMapper.parseId(id);
    if (numericId == null) return const Success(null);
    final result = await _dataSource.getById(numericId);
    switch (result) {
      case Success<DepartmentDto>(:final value):
        return Success(
          ConfigurationItem(
            DepartmentMapper.toDomain(value, companyId: context.company.id),
            value.employeeCount,
          ),
        );
      case Failed<DepartmentDto>(:final failure):
        if (failure.kind == FailureKind.notFound) return const Success(null);
        return Failed(failure);
    }
  }

  @override
  Future<Result<Department?>> getById(
    AuthContext context,
    String id, {
    bool forEditing = false,
  }) async {
    final numericId = DepartmentMapper.parseId(id);
    if (numericId == null) return const Success(null);
    final result = await _dataSource.getById(numericId);
    switch (result) {
      case Success<DepartmentDto>(:final value):
        return Success(
          DepartmentMapper.toDomain(value, companyId: context.company.id),
        );
      case Failed<DepartmentDto>(:final failure):
        if (failure.kind == FailureKind.notFound) return const Success(null);
        return Failed(failure);
    }
  }

  @override
  Future<Result<Department>> save(
    AuthContext context,
    DepartmentDraft draft, {
    String? id,
  }) async {
    final normalized = draft.normalized();
    final errors = normalized.validate();
    if (errors.isNotEmpty) {
      return Failed(
        Failure(code: errors.values.first, kind: FailureKind.validation),
      );
    }
    final request = DepartmentUpsertDto(departmentName: normalized.name);
    final result = id == null
        ? await _dataSource.create(request)
        : await _rename(id, request);
    switch (result) {
      case Success<DepartmentDto>(:final value):
        var domain = DepartmentMapper.toDomain(
          value,
          companyId: context.company.id,
        );
        if (normalized.status == ConfigurationStatus.inactive) {
          // Department create/rename always returns an active record and the
          // backend has no activate endpoint. Apply the requested inactive
          // status explicitly; the list is active-only, so this is the only
          // truthful way to honor the draft.
          final status = await _dataSource.deactivate(value.departmentId);
          if (status is Failed<void>) {
            return Failed(_mapWriteFailure(status.failure));
          }
          domain = domain.copyWith(status: ConfigurationStatus.inactive);
        } else if (domain.status != ConfigurationStatus.active) {
          // Defensive: an active draft cannot be restored without an activate
          // endpoint. Never fabricate one.
          return const Failed(Failure(code: 'unsupported'));
        }
        _revision.add(null);
        return Success(domain);
      case Failed<DepartmentDto>(:final failure):
        return Failed(_mapWriteFailure(failure));
    }
  }

  Future<Result<DepartmentDto>> _rename(
    String id,
    DepartmentUpsertDto request,
  ) {
    final numericId = DepartmentMapper.parseId(id);
    if (numericId == null) {
      return Future.value(const Failed(Failure(code: 'notFound')));
    }
    return _dataSource.rename(numericId, request);
  }

  @override
  Future<Result<void>> setActive(
    AuthContext context,
    String id,
    bool active,
  ) async {
    if (active) {
      // No activate endpoint is documented; the backend supports deactivation
      // only. Represent this accurately instead of fabricating support.
      return const Failed(Failure(code: 'unsupported'));
    }
    final numericId = DepartmentMapper.parseId(id);
    if (numericId == null) return const Failed(Failure(code: 'notFound'));
    final result = await _dataSource.deactivate(numericId);
    switch (result) {
      case Success<void>():
        _revision.add(null);
        return const Success(null);
      case Failed<void>(:final failure):
        return Failed(_mapWriteFailure(failure));
    }
  }

  @override
  Future<Result<int>> assignedEmployeeCount(
    AuthContext context,
    String id,
  ) async {
    final numericId = DepartmentMapper.parseId(id);
    if (numericId == null) return const Failed(Failure(code: 'notFound'));
    final result = await _dataSource.getById(numericId);
    switch (result) {
      case Success<DepartmentDto>(:final value):
        return Success(value.employeeCount);
      case Failed<DepartmentDto>(:final failure):
        return Failed(failure);
    }
  }

  /// Maps documented backend codes to the codes the shared configuration UI
  /// renders, preserving the safe server message.
  Failure _mapWriteFailure(Failure failure) => switch (failure.code) {
    'DEPARTMENT_DUPLICATE_NAME' => Failure(
      code: 'duplicateName',
      kind: FailureKind.validation,
      field: 'departmentName',
      serverMessage: failure.serverMessage,
    ),
    'DEPARTMENT_IN_USE' => Failure(
      code: 'inUse',
      kind: FailureKind.conflict,
      serverMessage: failure.serverMessage,
    ),
    'DEPARTMENT_NOT_FOUND' => const Failure(
      code: 'notFound',
      kind: FailureKind.notFound,
    ),
    _ => failure,
  };

  Future<void> dispose() => _revision.close();
}
