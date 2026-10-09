export 'package:modular_erp/shared/workflows/record_details_bloc.dart';
import 'package:modular_erp/shared/workflows/record_details_bloc.dart';
import 'package:modular_erp/modules/hr/departments/domain/department.dart';
import 'package:modular_erp/modules/hr/departments/domain/department_repository.dart';

class DepartmentDetailsBloc
    extends RecordDetailsBloc<Department, DepartmentDraft> {
  DepartmentDetailsBloc(
    DepartmentRepository super.repository,
    super.context,
    super.id,
  );
}

typedef DepartmentDetailsState = RecordDetailsState<Department>;
