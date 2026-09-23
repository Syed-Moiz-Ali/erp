export 'package:modular_erp/shared/workflows/record_list_bloc.dart';
import 'package:modular_erp/shared/workflows/record_list_bloc.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy.dart';
import 'package:modular_erp/modules/hr/attendance_policies/domain/attendance_policy_repository.dart';

class AttendancePolicyListBloc
    extends RecordListBloc<AttendancePolicy, AttendancePolicyDraft> {
  AttendancePolicyListBloc(
    AttendancePolicyRepository super.repository,
    super.context,
  );
}

typedef AttendancePolicyListState = RecordListState<AttendancePolicy>;
