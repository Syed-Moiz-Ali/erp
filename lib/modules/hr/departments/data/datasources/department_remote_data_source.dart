import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/departments/data/dto/department_dtos.dart';

/// Typed remote boundary for the documented MassERP department endpoints.
///
/// Transport failures are already mapped to safe [Failure]s by the shared API
/// client; backend error codes and field errors are preserved.
abstract interface class DepartmentRemoteDataSource {
  Future<Result<PagedResult<DepartmentDto>>> list({
    required int page,
    required int pageSize,
    String search = '',
    CancelToken? cancelToken,
  });

  Future<Result<DepartmentDto>> getById(int id, {CancelToken? cancelToken});

  Future<Result<DepartmentDto>> create(
    DepartmentUpsertDto request, {
    CancelToken? cancelToken,
  });

  Future<Result<DepartmentDto>> rename(
    int id,
    DepartmentUpsertDto request, {
    CancelToken? cancelToken,
  });

  Future<Result<void>> deactivate(int id, {CancelToken? cancelToken});
}
