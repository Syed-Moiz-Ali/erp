export '../../../../shared/workflows/record_list_bloc.dart';
import '../../../../shared/workflows/record_list_bloc.dart';
import '../../domain/shift.dart';
import '../../domain/shift_repository.dart';

class ShiftListBloc extends RecordListBloc<Shift, ShiftDraft> {
  ShiftListBloc(ShiftRepository super.repository, super.context);
}

typedef ShiftListState = RecordListState<Shift>;
