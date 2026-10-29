import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/datasources/employee_shift_remote_data_source.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/employee_shift_mapper.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift_repository.dart';

/// Backend-mode employee-shift repository over `/api/employee-shifts`.
///
/// Client-side validation runs before any request: create requires
/// `employeeId` and `shiftId`, both create and update require `fromDate` and
/// `toDate`, and `fromDate <= toDate` is enforced. Write bodies never include
/// `employeeId` on update and omit a null/blank `timeZoneId`.
///
/// Backend codes are preserved verbatim:
/// `EMPLOYEE_SHIFT_NOT_FOUND` -> `notFound`; `EMPLOYEE_SHIFT_OVERLAP`,
/// `EMPLOYEE_SHIFT_LIMIT`, `EMPLOYEE_SHIFT_HAS_PUNCHES` and
/// `EMPLOYEE_SHIFT_ALREADY_REMOVED` -> `conflict`;
/// `EMPLOYEE_SHIFT_TIMEZONE_MISMATCH` and
/// `EMPLOYEE_SHIFT_BRANCH_TIMEZONE_MISSING` -> `validation`. Deactivate does not
/// treat `EMPLOYEE_SHIFT_ALREADY_REMOVED` as success.
class RemoteEmployeeShiftRepository implements EmployeeShiftRepository {
  RemoteEmployeeShiftRepository(this._dataSource);

  final EmployeeShiftRemoteDataSource _dataSource;

  @override
  Future<Result<EmployeeShiftPage>> list({
    int? employeeId,
    int? shiftId,
    String? fromDate,
    String? toDate,
    bool? includeInactive,
    int page = 1,
    int pageSize = 25,
  }) async {
    final result = await _dataSource.list(
      employeeId: employeeId,
      shiftId: shiftId,
      fromDate: fromDate,
      toDate: toDate,
      includeInactive: includeInactive,
      page: page,
      pageSize: pageSize,
    );
    return switch (result) {
      Failed(:final failure) => Failed(_mapFailure(failure)),
      Success(:final value) => Success(
        EmployeeShiftPage(
          items: value.items
              .map(EmployeeShiftMapper.toDomain)
              .toList(growable: false),
          page: value.page,
          pageSize: value.pageSize,
          totalItems: value.totalItems,
          totalPages: value.totalPages,
        ),
      ),
    };
  }

  @override
  Future<Result<EmployeeShift>> getById(int id) async {
    final result = await _dataSource.getById(id);
    return switch (result) {
      Failed(:final failure) => Failed(_mapFailure(failure)),
      Success(:final value) => Success(EmployeeShiftMapper.toDomain(value)),
    };
  }

  @override
  Future<Result<EmployeeShift>> create(EmployeeShiftDraft draft) async {
    final failure = _validate(draft, requireEmployee: true);
    if (failure != null) return Failed(failure);
    final result = await _dataSource.create(
      EmployeeShiftMapper.toCreate(draft),
    );
    return switch (result) {
      Failed(:final failure) => Failed(_mapFailure(failure)),
      Success(:final value) => Success(EmployeeShiftMapper.toDomain(value)),
    };
  }

  @override
  Future<Result<EmployeeShift>> update(int id, EmployeeShiftDraft draft) async {
    final failure = _validate(draft, requireEmployee: false);
    if (failure != null) return Failed(failure);
    final result = await _dataSource.update(
      id,
      EmployeeShiftMapper.toUpdate(draft),
    );
    return switch (result) {
      Failed(:final failure) => Failed(_mapFailure(failure)),
      Success(:final value) => Success(EmployeeShiftMapper.toDomain(value)),
    };
  }

  @override
  Future<Result<void>> deactivate(int id) async {
    final result = await _dataSource.deactivate(id);
    return switch (result) {
      Failed(:final failure) => Failed(_mapFailure(failure)),
      Success() => const Success(null),
    };
  }

  static Failure? _validate(
    EmployeeShiftDraft draft, {
    required bool requireEmployee,
  }) {
    if (requireEmployee && draft.employeeId == null) {
      return const Failure(
        code: 'required',
        kind: FailureKind.validation,
        field: 'employeeId',
      );
    }
    if (draft.shiftId == null) {
      return const Failure(
        code: 'required',
        kind: FailureKind.validation,
        field: 'shiftId',
      );
    }
    final fromDate = draft.fromDate?.trim() ?? '';
    if (fromDate.isEmpty) {
      return const Failure(
        code: 'required',
        kind: FailureKind.validation,
        field: 'fromDate',
      );
    }
    final toDate = draft.toDate?.trim() ?? '';
    if (toDate.isEmpty) {
      return const Failure(
        code: 'required',
        kind: FailureKind.validation,
        field: 'toDate',
      );
    }
    if (!_isIsoDate(fromDate)) {
      return const Failure(
        code: 'invalidDate',
        kind: FailureKind.validation,
        field: 'fromDate',
      );
    }
    if (!_isIsoDate(toDate)) {
      return const Failure(
        code: 'invalidDate',
        kind: FailureKind.validation,
        field: 'toDate',
      );
    }
    if (fromDate.compareTo(toDate) > 0) {
      return const Failure(
        code: 'invalidDateRange',
        kind: FailureKind.validation,
        field: 'toDate',
      );
    }
    return null;
  }

  static bool _isIsoDate(String value) =>
      RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) &&
      DateTime.tryParse(value) != null;

  static Failure _mapFailure(Failure failure) => switch (failure.code) {
    'EMPLOYEE_SHIFT_NOT_FOUND' => failure.copyWith(kind: FailureKind.notFound),
    'EMPLOYEE_SHIFT_OVERLAP' ||
    'EMPLOYEE_SHIFT_LIMIT' ||
    'EMPLOYEE_SHIFT_HAS_PUNCHES' ||
    'EMPLOYEE_SHIFT_ALREADY_REMOVED' => failure.copyWith(
      kind: FailureKind.conflict,
    ),
    'EMPLOYEE_SHIFT_TIMEZONE_MISMATCH' ||
    'EMPLOYEE_SHIFT_BRANCH_TIMEZONE_MISSING' => failure.copyWith(
      kind: FailureKind.validation,
    ),
    _ => failure,
  };
}
