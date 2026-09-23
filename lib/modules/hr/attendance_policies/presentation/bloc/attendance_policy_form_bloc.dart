export 'package:modular_erp/shared/workflows/record_form_bloc.dart';
import 'package:modular_erp/shared/workflows/record_form_bloc.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy_repository.dart';

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
