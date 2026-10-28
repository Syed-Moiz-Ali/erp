import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/branches/data/datasources/dio_branch_remote_data_source.dart';
import 'package:modular_erp/modules/hr/branches/data/dto/branch_dtos.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch_repository.dart';

class RemoteBranchRepository implements BranchRepository {
  RemoteBranchRepository(this._dataSource);
  final DioBranchRemoteDataSource _dataSource;

  @override
  Future<Result<BranchPageData>> list({
    String search = '',
    String? status,
    int? divisionId,
    String sort = 'nameAsc',
    int page = 1,
    int pageSize = 25,
  }) async {
    final result = await _dataSource.list(
      search: search,
      status: status,
      divisionId: divisionId,
      sort: sort,
      page: page,
      pageSize: pageSize,
    );
    return switch (result) {
      Failed(:final failure) => Failed(failure),
      Success(:final value) => Success(
        BranchPageData(
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
  Future<Result<Branch>> getById(int id) async =>
      _map(await _dataSource.getById(id));

  @override
  Future<Result<Branch>> create(BranchDraft draft) async =>
      _map(await _dataSource.create(draft));

  @override
  Future<Result<Branch>> update(int id, BranchDraft draft) async =>
      _map(await _dataSource.update(id, draft));

  @override
  Future<Result<Branch>> setActive(int id, bool active) async =>
      _map(await _dataSource.setActive(id, active: active));

  @override
  Future<Result<BranchLookups>> lookups() => _dataSource.lookups();

  Result<Branch> _map(Result<BranchDto> result) => switch (result) {
    Failed(:final failure) => Failed(failure),
    Success(:final value) => Success(value.toDomain()),
  };
}
