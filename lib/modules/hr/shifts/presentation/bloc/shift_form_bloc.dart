export 'package:modular_erp/shared/workflows/record_form_bloc.dart';
import 'package:modular_erp/shared/workflows/record_form_bloc.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift_repository.dart';

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
