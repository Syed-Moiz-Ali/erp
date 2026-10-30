export 'package:modular_erp/shared/workflows/record_details_bloc.dart';
import 'package:modular_erp/shared/workflows/record_details_bloc.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift.dart';
import 'package:modular_erp/modules/hr/employee_shifts/presentation/employee_shift_configuration_repository.dart';

class EmployeeShiftDetailsBloc
    extends RecordDetailsBloc<EmployeeShiftRecord, EmployeeShiftDraft> {
  EmployeeShiftDetailsBloc(
    EmployeeShiftConfigurationRepository super.repository,
    super.context,
    super.id,
  );
}

typedef EmployeeShiftDetailsState = RecordDetailsState<EmployeeShiftRecord>;
