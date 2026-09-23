export 'package:modular_erp/shared/workflows/record_list_bloc.dart';
export 'package:modular_erp/shared/workflows/record_form_bloc.dart';
export 'package:modular_erp/shared/workflows/record_details_bloc.dart';

import 'package:modular_erp/shared/workflows/record_details_bloc.dart';
import 'package:modular_erp/shared/workflows/record_form_bloc.dart';
import 'package:modular_erp/shared/workflows/record_list_bloc.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';

// ---- leave types -----------------------------------------------------------

class LeaveTypeListBloc extends RecordListBloc<LeaveType, LeaveTypeDraft> {
  LeaveTypeListBloc(super.repository, super.context);
}

typedef LeaveTypeListState = RecordListState<LeaveType>;

class LeaveTypeFormBloc extends RecordFormBloc<LeaveType, LeaveTypeDraft> {
  LeaveTypeFormBloc(super.repository, super.context, {super.id})
    : super(
        emptyDraft: const LeaveTypeDraft(),
        fromRecord: LeaveTypeDraft.fromType,
        normalize: (d) => d.normalized(),
        validate: (d) => d.validate(),
      );
}

typedef LeaveTypeFormState = RecordFormState<LeaveTypeDraft>;

class LeaveTypeDetailsBloc
    extends RecordDetailsBloc<LeaveType, LeaveTypeDraft> {
  LeaveTypeDetailsBloc(super.repository, super.context, super.id);
}

typedef LeaveTypeDetailsState = RecordDetailsState<LeaveType>;

// ---- leave policies --------------------------------------------------------

class LeavePolicyListBloc
    extends RecordListBloc<LeavePolicy, LeavePolicyDraft> {
  LeavePolicyListBloc(super.repository, super.context);
}

typedef LeavePolicyListState = RecordListState<LeavePolicy>;

class LeavePolicyFormBloc
    extends RecordFormBloc<LeavePolicy, LeavePolicyDraft> {
  LeavePolicyFormBloc(super.repository, super.context, {super.id})
    : super(
        emptyDraft: const LeavePolicyDraft(),
        fromRecord: LeavePolicyDraft.fromPolicy,
        normalize: (d) => d.normalized(),
        validate: (d) => d.validate(),
      );
}

typedef LeavePolicyFormState = RecordFormState<LeavePolicyDraft>;

class LeavePolicyDetailsBloc
    extends RecordDetailsBloc<LeavePolicy, LeavePolicyDraft> {
  LeavePolicyDetailsBloc(super.repository, super.context, super.id);
}

typedef LeavePolicyDetailsState = RecordDetailsState<LeavePolicy>;

// ---- holidays --------------------------------------------------------------

class HolidayListBloc extends RecordListBloc<Holiday, HolidayDraft> {
  HolidayListBloc(super.repository, super.context);
}

typedef HolidayListState = RecordListState<Holiday>;

class HolidayFormBloc extends RecordFormBloc<Holiday, HolidayDraft> {
  HolidayFormBloc(super.repository, super.context, {super.id})
    : super(
        emptyDraft: const HolidayDraft(),
        fromRecord: HolidayDraft.fromHoliday,
        normalize: (d) => d.normalized(),
        validate: (d) => d.validate(),
      );
}

typedef HolidayFormState = RecordFormState<HolidayDraft>;

class HolidayDetailsBloc extends RecordDetailsBloc<Holiday, HolidayDraft> {
  HolidayDetailsBloc(super.repository, super.context, super.id);
}

typedef HolidayDetailsState = RecordDetailsState<Holiday>;
