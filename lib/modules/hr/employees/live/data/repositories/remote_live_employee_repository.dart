import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employees/live/data/datasources/dio_live_employee_data_source.dart';
import 'package:modular_erp/modules/hr/employees/live/data/dto/live_employee_dtos.dart';
import 'package:modular_erp/modules/hr/employees/live/domain/live_employee.dart';
import 'package:modular_erp/modules/hr/employees/live/domain/live_employee_repository.dart';

class RemoteLiveEmployeeRepository implements LiveEmployeeRepository {
  RemoteLiveEmployeeRepository(this._dataSource);
  final DioLiveEmployeeDataSource _dataSource;

  @override
  Future<Result<LiveEmployeePage>> list({
    String search = '',
    int? statusId,
    int? departmentId,
    int? branchId,
    String sort = 'nameAsc',
    int page = 1,
    int pageSize = 25,
  }) async {
    final result = await _dataSource.list(
      search: search,
      statusId: statusId,
      departmentId: departmentId,
      branchId: branchId,
      sort: sort,
      page: page,
      pageSize: pageSize,
    );
    return switch (result) {
      Failed(:final failure) => Failed(failure),
      Success(:final value) => Success(
        LiveEmployeePage(
          items: value.items.map((dto) => dto.toDomain()).toList(),
          page: value.page,
          pageSize: value.pageSize,
          totalItems: value.totalItems,
          totalPages: value.totalPages,
        ),
      ),
    };
  }

  @override
  Future<Result<LiveEmployee>> getById(int id) async =>
      _map(await _dataSource.getById(id));

  @override
  Future<Result<LiveEmployee>> create(LiveEmployeeDraft draft) async {
    final errors = draft.validate();
    if (errors.isNotEmpty) {
      return Failed(
        Failure(
          code: 'VALIDATION_ERROR',
          kind: FailureKind.validation,
          field: errors.keys.first,
          serverMessage: errors.values.first,
        ),
      );
    }
    return _map(await _dataSource.create(draft.toBody()));
  }

  /// Full replace: starts with every field returned by GET, then applies form
  /// edits. A field loaded from the backend is never silently dropped.
  @override
  Future<Result<LiveEmployee>> update(
    LiveEmployee current,
    LiveEmployeeDraft draft,
  ) async {
    final fresh = await getById(current.id);
    if (fresh is Failed<LiveEmployee>) return Failed(fresh.failure);
    final detail = (fresh as Success<LiveEmployee>).value;
    return _map(
      await _dataSource.update(detail.id, draft.toBody(base: detail.raw)),
    );
  }

  @override
  Future<Result<LiveEmployee>> setActive(int id, bool active) async {
    final result = await _dataSource.setActive(id, active: active);
    if (result is Failed<LiveEmployeeDto>) {
      return Failed(result.failure);
    }
    // Activate does not restore login; re-read so the UI shows real state.
    return getById(id);
  }

  @override
  Future<Result<LiveEmployeeLookups>> lookups() => _dataSource.lookups();

  Result<LiveEmployee> _map(Result<LiveEmployeeDto> result) =>
      switch (result) {
        Failed(:final failure) => Failed(failure),
        Success(:final value) => Success(value.toDomain()),
      };
}
