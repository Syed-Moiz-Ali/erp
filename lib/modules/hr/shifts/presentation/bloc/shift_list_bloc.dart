export 'package:modular_erp/shared/workflows/record_list_bloc.dart';
import 'package:modular_erp/shared/workflows/record_list_bloc.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift_repository.dart';

class ShiftListBloc extends RecordListBloc<Shift, ShiftDraft> {
  ShiftListBloc(ShiftRepository super.repository, super.context);
}

typedef ShiftListState = RecordListState<Shift>;
