import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/shifts/data/dto/shift_dtos.dart';

/// Typed remote boundary for the documented MassERP shift endpoints.
abstract interface class ShiftRemoteDataSource {
  Future<Result<PagedResult<ShiftDto>>> list({
    required int page,
    required int pageSize,
    String search = '',
    int? statusId,
    CancelToken? cancelToken,
  });

  Future<Result<ShiftDto>> getById(int id, {CancelToken? cancelToken});

  Future<Result<ShiftDto>> create(
    ShiftUpsertDto request, {
    CancelToken? cancelToken,
  });

  Future<Result<ShiftDto>> update(
    int id,
    ShiftUpsertDto request, {
    CancelToken? cancelToken,
  });

  Future<Result<void>> deactivate(int id, {CancelToken? cancelToken});

  Future<Result<void>> activate(int id, {CancelToken? cancelToken});
}
