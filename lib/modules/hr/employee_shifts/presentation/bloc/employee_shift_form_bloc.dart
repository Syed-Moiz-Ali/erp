export 'package:modular_erp/shared/workflows/record_form_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/shared/workflows/record_form_bloc.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift.dart';
import 'package:modular_erp/modules/hr/employee_shifts/presentation/employee_shift_configuration_repository.dart';

class EmployeeShiftFormBloc
    extends RecordFormBloc<EmployeeShiftRecord, EmployeeShiftDraft> {
  EmployeeShiftFormBloc(
    EmployeeShiftConfigurationRepository super.repository,
    super.context, {
    super.id,
  }) : super(
         emptyDraft: const EmployeeShiftDraft(),
         fromRecord: (record) =>
             EmployeeShiftDraft.fromShift(record.employeeShift),
         normalize: (d) => d.normalized(),
         validate: (d) => d.validate(requireEmployee: id == null),
         serverFieldErrors: _serverFieldErrors,
       );

  static Map<String, String> _serverFieldErrors(Failure failure) =>
      switch (failure.code) {
        'EMPLOYEE_SHIFT_OVERLAP' ||
        'EMPLOYEE_SHIFT_LIMIT' ||
        'EMPLOYEE_SHIFT_HAS_PUNCHES' ||
        'EMPLOYEE_SHIFT_ALREADY_REMOVED' => {'toDate': failure.code},
        'EMPLOYEE_SHIFT_TIMEZONE_MISMATCH' ||
        'EMPLOYEE_SHIFT_BRANCH_TIMEZONE_MISSING' => {
          'timeZoneId': failure.code,
        },
        'invalidDateRange' || 'invalidDate' => {'toDate': failure.code},
        _ => const {},
      };
}

typedef EmployeeShiftFormState = RecordFormState<EmployeeShiftDraft>;
