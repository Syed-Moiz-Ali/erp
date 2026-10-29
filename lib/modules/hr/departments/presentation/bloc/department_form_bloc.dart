export 'package:modular_erp/shared/workflows/record_form_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
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
         serverFieldErrors: _serverFieldErrors,
       );

  static Map<String, String> _serverFieldErrors(Failure failure) {
    if (failure.field != 'departmentName') return const {};
    final message = failure.serverMessage?.toLowerCase() ?? '';
    return {
      'name': switch (failure.code) {
        'duplicateName' => 'duplicateName',
        'DEPARTMENT_DUPLICATE_NAME' => 'duplicateName',
        'VALIDATION_ERROR' || 'validation' =>
          message.contains('50') || message.contains('character')
              ? 'tooLong'
              : 'required',
        _ => failure.code,
      },
    };
  }
}

typedef DepartmentFormState = RecordFormState<DepartmentDraft>;
