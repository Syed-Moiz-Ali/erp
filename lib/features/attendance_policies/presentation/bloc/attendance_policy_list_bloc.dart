export '../../../../shared/workflows/record_list_bloc.dart';
import '../../../../shared/workflows/record_list_bloc.dart';
import '../../domain/attendance_policy.dart';
import '../../domain/attendance_policy_repository.dart';

class AttendancePolicyListBloc
    extends RecordListBloc<AttendancePolicy, AttendancePolicyDraft> {
  AttendancePolicyListBloc(
    AttendancePolicyRepository super.repository,
    super.context,
  );
}

typedef AttendancePolicyListState = RecordListState<AttendancePolicy>;
