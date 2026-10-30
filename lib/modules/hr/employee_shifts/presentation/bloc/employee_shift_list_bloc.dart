export 'package:modular_erp/shared/workflows/record_list_bloc.dart';
import 'package:modular_erp/shared/workflows/record_list_bloc.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift.dart';
import 'package:modular_erp/modules/hr/employee_shifts/presentation/employee_shift_configuration_repository.dart';

class EmployeeShiftListBloc
    extends RecordListBloc<EmployeeShiftRecord, EmployeeShiftDraft> {
  EmployeeShiftListBloc(
    EmployeeShiftConfigurationRepository super.repository,
    super.context,
  );
}

typedef EmployeeShiftListState = RecordListState<EmployeeShiftRecord>;
