import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/result.dart';
import '../../domain/attendance_history.dart';
import '../../domain/attendance_repository.dart';

sealed class AttendanceHistoryEvent {
  const AttendanceHistoryEvent();
}

class AttendanceHistoryStarted extends AttendanceHistoryEvent {
  const AttendanceHistoryStarted();
}

class AttendanceHistoryMonthChanged extends AttendanceHistoryEvent {
  const AttendanceHistoryMonthChanged(this.month);
  final DateTime month;
}

class AttendanceHistoryFilterChanged extends AttendanceHistoryEvent {
  AttendanceHistoryFilterChanged(Set<AttendanceHistoryStatus> statuses)
    : statuses = Set.unmodifiable(statuses);
  final Set<AttendanceHistoryStatus> statuses;
}

class AttendanceHistoryPageChanged extends AttendanceHistoryEvent {
  const AttendanceHistoryPageChanged(this.page);
  final int page;
}

class AttendanceHistoryRefreshRequested extends AttendanceHistoryEvent {
  const AttendanceHistoryRefreshRequested();
}

class _HistoryLoaded extends AttendanceHistoryEvent {
  const _HistoryLoaded(this.ticket, this.result);
  final int ticket;
  final Result<AttendanceHistoryPageData> result;
}

class AttendanceHistoryState {
  const AttendanceHistoryState({
    this.query,
    this.currentMonth,
    this.data,
    this.failure,
    this.loading = true,
  });
  final AttendanceHistoryQuery? query;
  final DateTime? currentMonth;
  final AttendanceHistoryPageData? data;
  final Failure? failure;
  final bool loading;
}

class AttendanceHistoryBloc
    extends Bloc<AttendanceHistoryEvent, AttendanceHistoryState> {
  AttendanceHistoryBloc(this.repository)
    : super(const AttendanceHistoryState()) {
    on<AttendanceHistoryStarted>((e, emit) async {
      final result = await repository.getCompanyAttendanceDate();
      if (isClosed) return;
      if (result case Failed<DateTime>(:final failure)) {
        emit(AttendanceHistoryState(failure: failure, loading: false));
        return;
      }
      final date = (result as Success<DateTime>).value;
      _current = DateTime.utc(date.year, date.month);
      await _bind(
        AttendanceHistoryQuery(year: date.year, month: date.month),
        emit,
      );
    });
    on<AttendanceHistoryMonthChanged>((e, emit) async {
      final month = DateTime.utc(e.month.year, e.month.month);
      if (_current == null || month.isAfter(_current!)) return;
      await _bind(
        AttendanceHistoryQuery(
          year: month.year,
          month: month.month,
          statuses: state.query?.statuses ?? {},
        ),
        emit,
      );
    });
    on<AttendanceHistoryFilterChanged>((e, emit) async {
      final q = state.query;
      if (q == null) return;
      await _bind(
        AttendanceHistoryQuery(
          year: q.year,
          month: q.month,
          statuses: e.statuses,
        ),
        emit,
      );
    });
    on<AttendanceHistoryPageChanged>((e, emit) async {
      final q = state.query;
      if (q == null ||
          e.page < 0 ||
          (e.page > 0 && e.page * q.pageSize >= (state.data?.total ?? 0))) {
        return;
      }
      await _bind(
        AttendanceHistoryQuery(
          year: q.year,
          month: q.month,
          statuses: q.statuses,
          page: e.page,
          pageSize: q.pageSize,
        ),
        emit,
      );
    });
    on<AttendanceHistoryRefreshRequested>((e, emit) async {
      final q = state.query;
      if (q == null) {
        add(const AttendanceHistoryStarted());
        return;
      }
      final date = await repository.getCompanyAttendanceDate();
      if (date case Success<DateTime>(:final value)) {
        _current = DateTime.utc(value.year, value.month);
      }
      if (isClosed) return;
      await _bind(q, emit, keep: true);
    });
    on<_HistoryLoaded>((e, emit) {
      if (e.ticket != _ticket) return;
      if (e.result case Success<AttendanceHistoryPageData>(:final value)) {
        if (value.query.page > 0 && value.items.isEmpty && value.total > 0) {
          add(const AttendanceHistoryPageChanged(0));
          return;
        }
        emit(
          AttendanceHistoryState(
            query: state.query,
            currentMonth: _current,
            data: value,
            loading: false,
          ),
        );
      } else {
        final failure = (e.result as Failed<AttendanceHistoryPageData>).failure;
        emit(
          AttendanceHistoryState(
            query: state.query,
            currentMonth: _current,
            data: failure.retryable ? state.data : null,
            failure: failure,
            loading: false,
          ),
        );
      }
    });
  }
  final AttendanceRepository repository;
  StreamSubscription<Result<AttendanceHistoryPageData>>? _subscription;
  int _ticket = 0;
  DateTime? _current;
  Future<void> _bind(
    AttendanceHistoryQuery q,
    Emitter<AttendanceHistoryState> emit, {
    bool keep = false,
  }) async {
    final ticket = ++_ticket;
    emit(
      AttendanceHistoryState(
        query: q,
        currentMonth: _current,
        data: keep ? state.data : null,
        loading: true,
      ),
    );
    await _subscription?.cancel();
    if (isClosed || ticket != _ticket) return;
    _subscription = repository
        .watchAttendanceHistory(q)
        .listen(
          (r) {
            if (!isClosed) add(_HistoryLoaded(ticket, r));
          },
          onError: (Object e) {
            if (!isClosed) {
              add(
                _HistoryLoaded(
                  ticket,
                  const Failed(Failure(code: 'historyRead', retryable: true)),
                ),
              );
            }
          },
        );
  }

  @override
  Future<void> close() async {
    ++_ticket;
    await _subscription?.cancel();
    return super.close();
  }
}
