export 'package:modular_erp/shared/workflows/record_form_bloc.dart';
import 'package:modular_erp/shared/workflows/record_form_bloc.dart';
import 'package:modular_erp/modules/hr/departments/domain/department.dart';
import 'package:modular_erp/modules/hr/departments/domain/department_repository.dart';

class DepartmentFormBloc extends RecordFormBloc<Department, DepartmentDraft> {
  DepartmentFormBloc(
    DepartmentRepository super.repository,
    super.context, {
    super.id,
  }) : super(
         emptyDraft: const DepartmentDraft(),
         fromRecord: DepartmentDraft.fromDepartment,
         normalize: (d) => d.normalized(),
         validate: (d) => d.validate(),
       );
}

typedef DepartmentFormState = RecordFormState<DepartmentDraft>;
