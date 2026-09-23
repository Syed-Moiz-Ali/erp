import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_correction.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_correction_repository.dart';

sealed class AttendanceCorrectionEvent {
  const AttendanceCorrectionEvent();
}

final class CorrectionMyStarted extends AttendanceCorrectionEvent {
  const CorrectionMyStarted();
}

final class CorrectionQueueStarted extends AttendanceCorrectionEvent {
  const CorrectionQueueStarted();
}

final class CorrectionDetailsStarted extends AttendanceCorrectionEvent {
  const CorrectionDetailsStarted(this.id);
  final String id;
}

final class CorrectionSubmitted extends AttendanceCorrectionEvent {
  const CorrectionSubmitted(this.request);
  final AttendanceCorrectionRequest request;
}

final class CorrectionCancelled extends AttendanceCorrectionEvent {
  const CorrectionCancelled(this.id);
  final String id;
}

final class CorrectionReviewed extends AttendanceCorrectionEvent {
  const CorrectionReviewed(
    this.id, {
    required this.approve,
    required this.reviewerId,
    this.note,
  });
  final String id, reviewerId;
  final bool approve;
  final String? note;
}

final class _CorrectionListArrived extends AttendanceCorrectionEvent {
  const _CorrectionListArrived(this.result);
  final Result<List<AttendanceCorrectionRequest>> result;
}

class AttendanceCorrectionState {
  const AttendanceCorrectionState({
    this.loading = false,
    this.busy = false,
    this.items = const [],
    this.detail,
    this.failure,
    this.completed = false,
    this.notFound = false,
  });
  final bool loading, busy, completed, notFound;
  final List<AttendanceCorrectionRequest> items;
  final AttendanceCorrectionRequest? detail;
  final Failure? failure;
  AttendanceCorrectionState copyWith({
    bool? loading,
    bool? busy,
    List<AttendanceCorrectionRequest>? items,
    AttendanceCorrectionRequest? detail,
    Failure? failure,
    bool? completed,
    bool? notFound,
  }) => AttendanceCorrectionState(
    loading: loading ?? this.loading,
    busy: busy ?? this.busy,
    items: items ?? this.items,
    detail: detail ?? this.detail,
    failure: failure,
    completed: completed ?? false,
    notFound: notFound ?? this.notFound,
  );
}

class AttendanceCorrectionBloc
    extends Bloc<AttendanceCorrectionEvent, AttendanceCorrectionState> {
  AttendanceCorrectionBloc(this.repository)
    : super(const AttendanceCorrectionState()) {
    on<CorrectionMyStarted>(
      (e, emit) => _watch(repository.watchMyRequests(), emit),
    );
    on<CorrectionQueueStarted>(
      (e, emit) => _watch(repository.watchPendingRequests(), emit),
    );
    on<_CorrectionListArrived>((e, emit) {
      if (e.result is Success<List<AttendanceCorrectionRequest>>) {
        emit(
          state.copyWith(
            loading: false,
            items:
                (e.result as Success<List<AttendanceCorrectionRequest>>).value,
          ),
        );
      } else {
        emit(
          state.copyWith(loading: false, failure: (e.result as Failed).failure),
        );
      }
    });
    on<CorrectionDetailsStarted>((e, emit) => _details(e.id, emit));
    on<CorrectionSubmitted>((e, emit) => _submit(e, emit));
    on<CorrectionCancelled>((e, emit) => _cancel(e, emit));
    on<CorrectionReviewed>((e, emit) => _review(e, emit));
  }
  final AttendanceCorrectionRepository repository;
  StreamSubscription<Result<List<AttendanceCorrectionRequest>>>? _subscription;
  Future<void> _watch(
    Stream<Result<List<AttendanceCorrectionRequest>>> stream,
    Emitter<AttendanceCorrectionState> emit,
  ) async {
    await _subscription?.cancel();
    emit(state.copyWith(loading: true));
    _subscription = stream.listen(
      (result) => add(_CorrectionListArrived(result)),
    );
  }

  Future<void> _details(
    String id,
    Emitter<AttendanceCorrectionState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    final r = await repository.getRequestById(id);
    if (r is Success<AttendanceCorrectionRequest?>) {
      emit(
        state.copyWith(
          loading: false,
          detail: r.value,
          notFound: r.value == null,
        ),
      );
    } else {
      emit(state.copyWith(loading: false, failure: (r as Failed).failure));
    }
  }

  Future<void> _submit(
    CorrectionSubmitted e,
    Emitter<AttendanceCorrectionState> emit,
  ) async {
    emit(state.copyWith(busy: true));
    final r = await repository.createRequest(e.request);
    if (r is Success<AttendanceCorrectionRequest>) {
      emit(state.copyWith(busy: false, detail: r.value, completed: true));
    } else {
      emit(state.copyWith(busy: false, failure: (r as Failed).failure));
    }
  }

  Future<void> _cancel(
    CorrectionCancelled e,
    Emitter<AttendanceCorrectionState> emit,
  ) async {
    emit(state.copyWith(busy: true));
    final r = await repository.cancelRequest(e.id);
    if (r is Success<void>) {
      emit(state.copyWith(busy: false, completed: true));
      add(CorrectionDetailsStarted(e.id));
    } else {
      emit(state.copyWith(busy: false, failure: (r as Failed).failure));
    }
  }

  Future<void> _review(
    CorrectionReviewed e,
    Emitter<AttendanceCorrectionState> emit,
  ) async {
    emit(state.copyWith(busy: true));
    final r = e.approve
        ? await repository.approveRequest(
            e.id,
            reviewerId: e.reviewerId,
            note: e.note,
          )
        : await repository.rejectRequest(
            e.id,
            reviewerId: e.reviewerId,
            note: e.note ?? '',
          );
    if (r is Success<AttendanceCorrectionRequest>) {
      emit(state.copyWith(busy: false, detail: r.value, completed: true));
    } else {
      emit(state.copyWith(busy: false, failure: (r as Failed).failure));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
