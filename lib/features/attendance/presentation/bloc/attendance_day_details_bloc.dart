import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/result.dart';
import '../../domain/attendance_history.dart';
import '../../domain/attendance_repository.dart';

sealed class AttendanceDayDetailsEvent {
  const AttendanceDayDetailsEvent();
}

class AttendanceDayDetailsStarted extends AttendanceDayDetailsEvent {
  const AttendanceDayDetailsStarted();
}

class AttendanceDayDetailsRefreshRequested extends AttendanceDayDetailsEvent {
  const AttendanceDayDetailsRefreshRequested();
}

class _DetailsLoaded extends AttendanceDayDetailsEvent {
  const _DetailsLoaded(this.result);
  final Result<AttendanceDayDetails?> result;
}

class AttendanceDayDetailsState {
  const AttendanceDayDetailsState({
    this.data,
    this.failure,
    this.loading = true,
    this.notFound = false,
  });
  final AttendanceDayDetails? data;
  final Failure? failure;
  final bool loading, notFound;
}

class AttendanceDayDetailsBloc
    extends Bloc<AttendanceDayDetailsEvent, AttendanceDayDetailsState> {
  AttendanceDayDetailsBloc(this.repository, this.id)
    : super(const AttendanceDayDetailsState()) {
    on<AttendanceDayDetailsStarted>((e, emit) async {
      await _subscription?.cancel();
      if (isClosed) return;
      _subscription = repository
          .watchAttendanceDayById(id)
          .listen(
            (r) {
              if (!isClosed) add(_DetailsLoaded(r));
            },
            onError: (Object e) {
              if (!isClosed) {
                add(
                  const _DetailsLoaded(
                    Failed(Failure(code: 'historyRead', retryable: true)),
                  ),
                );
              }
            },
          );
    });
    on<AttendanceDayDetailsRefreshRequested>((e, emit) async {
      emit(AttendanceDayDetailsState(data: state.data));
      final r = await repository.getAttendanceDayById(id);
      if (!isClosed) add(_DetailsLoaded(r));
    });
    on<_DetailsLoaded>((e, emit) {
      if (e.result case Success<AttendanceDayDetails?>(:final value)) {
        emit(
          AttendanceDayDetailsState(
            data: value,
            loading: false,
            notFound: value == null,
          ),
        );
      } else {
        final f = (e.result as Failed<AttendanceDayDetails?>).failure;
        emit(
          AttendanceDayDetailsState(
            data: f.retryable ? state.data : null,
            failure: f,
            loading: false,
          ),
        );
      }
    });
  }
  final AttendanceRepository repository;
  final String id;
  StreamSubscription<Result<AttendanceDayDetails?>>? _subscription;
  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
