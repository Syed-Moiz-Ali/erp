export '../../../../shared/workflows/record_details_bloc.dart';
import '../../../../shared/workflows/record_details_bloc.dart';
import '../../domain/attendance_policy.dart';
import '../../domain/attendance_policy_repository.dart';

class AttendancePolicyDetailsBloc
    extends RecordDetailsBloc<AttendancePolicy, AttendancePolicyDraft> {
  AttendancePolicyDetailsBloc(
    AttendancePolicyRepository super.repository,
    super.context,
    super.id,
  );
}

typedef AttendancePolicyDetailsState = RecordDetailsState<AttendancePolicy>;
