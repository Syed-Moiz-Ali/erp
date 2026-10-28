import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/attendance/live/data/attendance_api.dart';
import 'package:modular_erp/modules/hr/attendance/live/domain/attendance_day.dart';

class AttendanceState {
  const AttendanceState({this.loading = true, this.busy = false, this.day, this.failure});
  final bool loading, busy;
  final AttendanceDay? day;
  final Failure? failure;
}

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit(this.api) : super(const AttendanceState());
  final AttendanceApi api;

  Future<void> load() async {
    emit(const AttendanceState());
    final result = await api.today();
    if (isClosed) return;
    switch (result) {
      case Success(:final value): emit(AttendanceState(loading: false, day: value));
      case Failed(:final failure): emit(AttendanceState(loading: false, failure: failure));
    }
  }

  Future<Failure?> punch(String action) async {
    emit(AttendanceState(loading: false, busy: true, day: state.day));
    final result = await api.punch(action, latitude: 25.20485, longitude: 55.27078);
    if (result is Failed<AttendanceDay>) {
      emit(AttendanceState(loading: false, day: state.day, failure: result.failure));
      return result.failure;
    }
    emit(AttendanceState(loading: false, day: (result as Success<AttendanceDay>).value));
    return null;
  }
}
