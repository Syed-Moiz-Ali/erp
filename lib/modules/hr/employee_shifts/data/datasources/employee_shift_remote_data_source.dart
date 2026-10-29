import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/dto/employee_shift_dtos.dart';

/// Typed remote boundary for the documented MassERP employee-shift endpoints.
abstract interface class EmployeeShiftRemoteDataSource {
  Future<Result<PagedResult<EmployeeShiftDto>>> list({
    int? employeeId,
    int? shiftId,
    String? fromDate,
    String? toDate,
    bool? includeInactive,
    required int page,
    required int pageSize,
    CancelToken? cancelToken,
  });

  Future<Result<EmployeeShiftDto>> getById(int id, {CancelToken? cancelToken});

  Future<Result<EmployeeShiftDto>> create(
    EmployeeShiftCreateDto request, {
    CancelToken? cancelToken,
  });

  Future<Result<EmployeeShiftDto>> update(
    int id,
    EmployeeShiftUpdateDto request, {
    CancelToken? cancelToken,
  });

  Future<Result<void>> deactivate(int id, {CancelToken? cancelToken});
}
