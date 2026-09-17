export '../../../../shared/workflows/record_details_bloc.dart';
import '../../../../shared/workflows/record_details_bloc.dart';
import '../../domain/shift.dart';
import '../../domain/shift_repository.dart';

class ShiftDetailsBloc extends RecordDetailsBloc<Shift, ShiftDraft> {
  ShiftDetailsBloc(ShiftRepository super.repository, super.context, super.id);
}

typedef ShiftDetailsState = RecordDetailsState<Shift>;
