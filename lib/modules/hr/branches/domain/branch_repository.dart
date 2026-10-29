import 'package:modular_erp/core/errors/result.dart';

import 'branch.dart';

abstract interface class BranchRepository {
  Future<Result<BranchPage>> list({
    String? search,
    BranchStatus? status,
    int? divisionId,
    String? sort,
    int page = 1,
    int pageSize = 25,
  });

  Future<Result<BranchLookups>> lookups();

  Future<Result<Branch>> getById(int id);

  Future<Result<Branch>> create(BranchDraft draft);

  Future<Result<Branch>> update(int id, BranchDraft draft);

  Future<Result<void>> setActive(int id, bool active);
}
