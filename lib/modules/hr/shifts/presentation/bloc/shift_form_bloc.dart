export 'package:modular_erp/shared/workflows/record_form_bloc.dart';
import 'package:modular_erp/app/app_config.dart';
import 'package:modular_erp/core/utils/local_time.dart';
import 'package:modular_erp/shared/workflows/record_form_bloc.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift.dart';
import 'package:modular_erp/modules/hr/shifts/domain/shift_repository.dart';

class ShiftFormBloc extends RecordFormBloc<Shift, ShiftDraft> {
  ShiftFormBloc(ShiftRepository super.repository, super.context, {super.id})
    : super(
        emptyDraft: _emptyDraft(),
        fromRecord: ShiftDraft.fromShift,
        normalize: (d) => d.normalized(),
        validate: (d) => d.validate(),
      );
}

/// The backend shift contract has no working-days concept, so a new remote shift
/// defaults to every day; a local/demo shift keeps the explicit selection.
ShiftDraft _emptyDraft() => AppConfig.realApiEnabled
    ? ShiftDraft(workingDays: WorkingDay.values.toSet())
    : const ShiftDraft();

typedef ShiftFormState = RecordFormState<ShiftDraft>;
