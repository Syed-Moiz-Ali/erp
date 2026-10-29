export 'package:modular_erp/shared/workflows/record_list_bloc.dart';
import 'package:modular_erp/shared/workflows/record_list_bloc.dart';
import 'package:modular_erp/modules/hr/departments/domain/department.dart';
import 'package:modular_erp/modules/hr/departments/domain/department_repository.dart';

class DepartmentListBloc extends RecordListBloc<Department, DepartmentDraft> {
  DepartmentListBloc(DepartmentRepository super.repository, super.context);
}

typedef DepartmentListState = RecordListState<Department>;
