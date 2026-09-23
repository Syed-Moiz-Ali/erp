import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/attendance/data/workforce_attendance_read_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/workforce_attendance.dart';

sealed class WorkforceAttendanceEvent {
  const WorkforceAttendanceEvent();
}

final class WorkforceAttendanceStarted extends WorkforceAttendanceEvent {
  const WorkforceAttendanceStarted([this.date]);
  final DateTime? date;
}

final class WorkforceAttendanceDateChanged extends WorkforceAttendanceEvent {
  const WorkforceAttendanceDateChanged(this.date);
  final DateTime date;
}

final class WorkforceAttendanceFilterChanged extends WorkforceAttendanceEvent {
  const WorkforceAttendanceFilterChanged(this.filter);
  final WorkforceAttendanceFilter filter;
}

final class WorkforceAttendanceRefreshed extends WorkforceAttendanceEvent {
  const WorkforceAttendanceRefreshed();
}

final class _WorkforceArrived extends WorkforceAttendanceEvent {
  const _WorkforceArrived(this.result, this.ticket);
  final Result<WorkforceAttendancePage> result;
  final int ticket;
}

class WorkforceAttendanceViewState {
  const WorkforceAttendanceViewState({
    this.loading = false,
    this.data,
    this.failure,
    this.date,
    this.today,
    this.filter = const WorkforceAttendanceFilter(),
  });
  final bool loading;
  final WorkforceAttendancePage? data;
  final Failure? failure;
  final DateTime? date, today;
  final WorkforceAttendanceFilter filter;
}

class WorkforceAttendanceBloc
    extends Bloc<WorkforceAttendanceEvent, WorkforceAttendanceViewState> {
  WorkforceAttendanceBloc(this.repository, this.scope)
    : super(const WorkforceAttendanceViewState()) {
    on<WorkforceAttendanceStarted>((e, emit) => _reload(emit, date: e.date));
    on<WorkforceAttendanceDateChanged>(
      (e, emit) => _reload(
        emit,
        date: e.date,
        filter: const WorkforceAttendanceFilter(),
      ),
    );
    on<WorkforceAttendanceFilterChanged>(
      (e, emit) => _reload(emit, filter: e.filter),
    );
    on<WorkforceAttendanceRefreshed>((e, emit) => _reload(emit));
    on<_WorkforceArrived>((e, emit) {
      if (e.ticket != _ticket) return;
      if (e.result is Success<WorkforceAttendancePage>) {
        emit(
          WorkforceAttendanceViewState(
            data: (e.result as Success<WorkforceAttendancePage>).value,
            date: state.date,
            today: state.today,
            filter: state.filter,
          ),
        );
      } else {
        emit(
          WorkforceAttendanceViewState(
            data: state.data,
            failure: (e.result as Failed).failure,
            date: state.date,
            today: state.today,
            filter: state.filter,
          ),
        );
      }
    });
  }
  final WorkforceAttendanceReadRepository repository;
  final AttendanceScope scope;
  StreamSubscription<Result<WorkforceAttendancePage>>? _watch;
  Timer? _ticker;
  int _ticket = 0;

  Future<void> _reload(
    Emitter<WorkforceAttendanceViewState> emit, {
    DateTime? date,
    WorkforceAttendanceFilter? filter,
  }) async {
    final todayResult = await repository.companyToday();
    if (todayResult is Failed<DateTime>) {
      emit(WorkforceAttendanceViewState(failure: todayResult.failure));
      return;
    }
    final today = (todayResult as Success<DateTime>).value;
    final selected = date ?? state.date ?? today;
    final activeFilter = filter ?? state.filter;
    _ticker?.cancel();
    await _watch?.cancel();
    final ticket = ++_ticket;
    emit(
      WorkforceAttendanceViewState(
        loading: true,
        data: state.data,
        date: selected,
        today: today,
        filter: activeFilter,
      ),
    );
    _watch = repository
        .watch(date: selected, filter: activeFilter, scope: scope)
        .listen((result) {
          if (!isClosed) add(_WorkforceArrived(result, ticket));
        });
    if (selected == today) {
      _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
        if (!isClosed) add(const WorkforceAttendanceRefreshed());
      });
    }
  }

  @override
  Future<void> close() async {
    _ticker?.cancel();
    await _watch?.cancel();
    await super.close();
  }
}
