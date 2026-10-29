import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employees/live/data/dto/live_employee_dtos.dart';
import 'package:modular_erp/modules/hr/employees/live/domain/live_employee.dart';

/// Transport contract for the MassERP employee endpoints.
///
/// The repository layer depends on this interface so backend mapping and write
/// bodies can be verified with an in-memory double; no HTTP is required.
abstract interface class LiveEmployeeRemoteDataSource {
  Future<Result<PagedResult<LiveEmployeeDto>>> list({
    String search = '',
    int? statusId,
    int? departmentId,
    int? branchId,
    String sort = 'nameAsc',
    int page = 1,
    int pageSize = 25,
    CancelToken? cancelToken,
  });

  Future<Result<LiveEmployeeDto>> getById(int id, {CancelToken? cancelToken});

  Future<Result<LiveEmployeeDto>> create(
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  });

  Future<Result<LiveEmployeeDto>> update(
    int id,
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  });

  Future<Result<LiveEmployeeDto>> setActive(
    int id, {
    required bool active,
    CancelToken? cancelToken,
  });

  Future<Result<LiveEmployeeLookups>> lookups({CancelToken? cancelToken});
}
