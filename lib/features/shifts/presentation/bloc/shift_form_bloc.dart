export '../../../../shared/workflows/record_form_bloc.dart';
import '../../../../shared/workflows/record_form_bloc.dart';
import '../../domain/shift.dart';
import '../../domain/shift_repository.dart';

class ShiftFormBloc extends RecordFormBloc<Shift, ShiftDraft> {
  ShiftFormBloc(ShiftRepository super.repository, super.context, {super.id})
    : super(
        emptyDraft: const ShiftDraft(),
        fromRecord: ShiftDraft.fromShift,
        normalize: (d) => d.normalized(),
        validate: (d) => d.validate(),
      );
}

typedef ShiftFormState = RecordFormState<ShiftDraft>;
