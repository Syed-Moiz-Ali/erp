export 'package:modular_erp/shared/workflows/record_details_bloc.dart';
import 'package:modular_erp/shared/workflows/record_details_bloc.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift_repository.dart';

class ShiftDetailsBloc extends RecordDetailsBloc<Shift, ShiftDraft> {
  ShiftDetailsBloc(ShiftRepository super.repository, super.context, super.id);
}

typedef ShiftDetailsState = RecordDetailsState<Shift>;
