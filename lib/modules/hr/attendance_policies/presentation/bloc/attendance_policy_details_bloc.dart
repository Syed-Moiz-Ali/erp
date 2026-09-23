export 'package:modular_erp/shared/workflows/record_details_bloc.dart';
import 'package:modular_erp/shared/workflows/record_details_bloc.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy_repository.dart';

class AttendancePolicyDetailsBloc
    extends RecordDetailsBloc<AttendancePolicy, AttendancePolicyDraft> {
  AttendancePolicyDetailsBloc(
    AttendancePolicyRepository super.repository,
    super.context,
    super.id,
  );
}

typedef AttendancePolicyDetailsState = RecordDetailsState<AttendancePolicy>;
