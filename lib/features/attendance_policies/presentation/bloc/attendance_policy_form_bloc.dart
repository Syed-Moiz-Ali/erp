export '../../../../shared/workflows/record_form_bloc.dart';
import '../../../../shared/workflows/record_form_bloc.dart';
import '../../domain/attendance_policy.dart';
import '../../domain/attendance_policy_repository.dart';

class AttendancePolicyFormBloc
    extends RecordFormBloc<AttendancePolicy, AttendancePolicyDraft> {
  AttendancePolicyFormBloc(
    AttendancePolicyRepository super.repository,
    super.context, {
    super.id,
  }) : super(
         emptyDraft: const AttendancePolicyDraft(),
         fromRecord: AttendancePolicyDraft.fromPolicy,
         normalize: (d) => d.normalized(),
         validate: (d) => d.validate(),
       );
}

typedef AttendancePolicyFormState = RecordFormState<AttendancePolicyDraft>;
