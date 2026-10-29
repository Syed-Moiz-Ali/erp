import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/branches/data/branch_mapper.dart';
import 'package:modular_erp/modules/hr/branches/data/datasources/branch_remote_data_source.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch_repository.dart';

class RemoteBranchRepository implements BranchRepository {
  RemoteBranchRepository(this._dataSource);

  final BranchRemoteDataSource _dataSource;

  @override
  Future<Result<BranchPage>> list({
    String? search,
    BranchStatus? status,
    int? divisionId,
    String? sort,
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
      Failed(:final failure) => Failed(_mapFailure(failure)),
      Success(:final value) => Success(
        BranchPage(
          items: value.items.map(BranchMapper.toDomain).toList(growable: false),
          page: value.page,
          pageSize: value.pageSize,
          totalItems: value.totalItems,
          totalPages: value.totalPages,
        ),
      ),
    };
  }

  @override
  Future<Result<BranchLookups>> lookups() async {
    final result = await _dataSource.lookups();
    return switch (result) {
      Failed(:final failure) => Failed(_mapFailure(failure)),
      Success(:final value) => Success(BranchMapper.toLookups(value)),
    };
  }

  @override
  Future<Result<Branch>> getById(int id) async {
    final result = await _dataSource.getById(id);
    return switch (result) {
      Failed(:final failure) => Failed(_mapFailure(failure)),
      Success(:final value) => Success(BranchMapper.toDomain(value)),
    };
  }

  @override
  Future<Result<Branch>> create(BranchDraft draft) async {
    final normalized = draft.normalized();
    final failure = _validate(normalized);
    if (failure != null) return Failed(failure);
    final result = await _dataSource.create(BranchMapper.toUpsert(normalized));
    return switch (result) {
      Failed(:final failure) => Failed(_mapFailure(failure)),
      Success(:final value) => Success(BranchMapper.toDomain(value)),
    };
  }

  @override
  Future<Result<Branch>> update(int id, BranchDraft draft) async {
    final normalized = draft.normalized();
    final failure = _validate(normalized);
    if (failure != null) return Failed(failure);
    final result = await _dataSource.update(
      id,
      BranchMapper.toUpsert(normalized),
    );
    return switch (result) {
      Failed(:final failure) => Failed(_mapFailure(failure)),
      Success(:final value) => Success(BranchMapper.toDomain(value)),
    };
  }

  @override
  Future<Result<void>> setActive(int id, bool active) async {
    final result = active
        ? await _dataSource.activate(id)
        : await _dataSource.deactivate(id);
    return switch (result) {
      Failed(:final failure) => Failed(_mapFailure(failure)),
      Success() => const Success(null),
    };
  }

  static Failure? _validate(BranchDraft draft) {
    final name = draft.branchName.trim();
    if (name.isEmpty) {
      return const Failure(
        code: 'required',
        kind: FailureKind.validation,
        field: 'branchName',
      );
    }
    if (name.length > 100) {
      return const Failure(
        code: 'tooLong',
        kind: FailureKind.validation,
        field: 'branchName',
      );
    }
    final timeZoneId = draft.timeZoneId?.trim() ?? '';
    if (timeZoneId.isEmpty) {
      return const Failure(
        code: 'required',
        kind: FailureKind.validation,
        field: 'timeZoneId',
      );
    }
    if (!_isIanaTimeZone(timeZoneId)) {
      return const Failure(
        code: 'invalidTimeZone',
        kind: FailureKind.validation,
        field: 'timeZoneId',
      );
    }
    return null;
  }

  static bool _isIanaTimeZone(String value) =>
      RegExp(r'^[A-Za-z][A-Za-z0-9_+\-]*(/[A-Za-z0-9_+\-]+)*$').hasMatch(value);

  static Failure _mapFailure(Failure failure) => switch (failure.code) {
    'BRANCH_DUPLICATE_NAME' => failure.copyWith(
      kind: FailureKind.conflict,
      field: 'branchName',
    ),
    'BRANCH_NOT_FOUND' => failure.copyWith(kind: FailureKind.notFound),
    'BRANCH_ALREADY_ACTIVE' ||
    'BRANCH_ALREADY_INACTIVE' => failure.copyWith(kind: FailureKind.conflict),
    'VALIDATION_ERROR' => failure.copyWith(kind: FailureKind.validation),
    'ACCESS_DENIED' => failure.copyWith(kind: FailureKind.forbidden),
    _ => failure,
  };
}
