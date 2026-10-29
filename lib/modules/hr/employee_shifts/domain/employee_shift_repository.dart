import 'package:modular_erp/core/errors/result.dart';

import 'employee_shift.dart';

abstract interface class EmployeeShiftRepository {
  Future<Result<EmployeeShiftPage>> list({
    int? employeeId,
    int? shiftId,
    String? fromDate,
    String? toDate,
    bool? includeInactive,
    int page = 1,
    int pageSize = 25,
  });

  Future<Result<EmployeeShift>> getById(int id);

  Future<Result<EmployeeShift>> create(EmployeeShiftDraft draft);

  Future<Result<EmployeeShift>> update(int id, EmployeeShiftDraft draft);

  Future<Result<void>> deactivate(int id);
}
