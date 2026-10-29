import 'package:dio/dio.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/branches/data/dto/branch_dtos.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';

abstract interface class BranchRemoteDataSource {
  Future<Result<PagedResult<BranchDto>>> list({
    String? search,
    BranchStatus? status,
    int? divisionId,
    String? sort,
    required int page,
    required int pageSize,
    CancelToken? cancelToken,
  });

  Future<Result<BranchLookupsDto>> lookups({CancelToken? cancelToken});

  Future<Result<BranchDto>> getById(int id, {CancelToken? cancelToken});

  Future<Result<BranchDto>> create(
    BranchUpsertDto request, {
    CancelToken? cancelToken,
  });

  Future<Result<BranchDto>> update(
    int id,
    BranchUpsertDto request, {
    CancelToken? cancelToken,
  });

  Future<Result<void>> activate(int id, {CancelToken? cancelToken});

  Future<Result<void>> deactivate(int id, {CancelToken? cancelToken});
}
