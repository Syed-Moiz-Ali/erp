import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';

abstract interface class BranchRepository {
  Future<Result<BranchPageData>> list({
    String search = '',
    String? status,
    int? divisionId,
    String sort = 'nameAsc',
    int page = 1,
    int pageSize = 25,
  });

  Future<Result<Branch>> getById(int id);
  Future<Result<Branch>> create(BranchDraft draft);
  Future<Result<Branch>> update(int id, BranchDraft draft);
  Future<Result<Branch>> setActive(int id, bool active);
  Future<Result<BranchLookups>> lookups();
}
