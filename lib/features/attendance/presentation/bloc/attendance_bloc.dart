import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/result.dart';
import '../../domain/attendance_models.dart';
import '../../domain/attendance_engine.dart';
import '../../domain/attendance_repository.dart';
import '../../application/execute_attendance_action.dart';

sealed class AttendanceBlocEvent {
  const AttendanceBlocEvent();
}

class AttendanceStarted extends AttendanceBlocEvent {
  const AttendanceStarted();
}

class AttendanceRefreshRequested extends AttendanceBlocEvent {
  const AttendanceRefreshRequested();
}

class AttendanceActionRequested extends AttendanceBlocEvent {
  const AttendanceActionRequested(
    this.type, {
    this.workMode = AttendanceWorkMode.office,
  });
  final AttendanceEventType type;
  final AttendanceWorkMode workMode;
}

class PunchInRequested extends AttendanceActionRequested {
  const PunchInRequested({super.workMode}) : super(AttendanceEventType.punchIn);
}

class BreakStartRequested extends AttendanceActionRequested {
  const BreakStartRequested() : super(AttendanceEventType.breakStart);
}

class BreakEndRequested extends AttendanceActionRequested {
  const BreakEndRequested() : super(AttendanceEventType.breakEnd);
}

class PunchOutRequested extends AttendanceActionRequested {
  const PunchOutRequested() : super(AttendanceEventType.punchOut);
}

class PendingOperationRetryRequested extends AttendanceBlocEvent {
  const PendingOperationRetryRequested(this.operationId);
  final String operationId;
}

class _AttendanceChanged extends AttendanceBlocEvent {
  const _AttendanceChanged(this.result);
  final Result<AttendanceContext> result;
}

enum AttendanceContextStatus { initial, loading, ready, unavailable }

enum AttendanceActionStatus { idle, submitting, succeeded, failed }

class AttendanceBlocState {
  const AttendanceBlocState({
    this.context,
    this.summary,
    this.actions,
    this.contextStatus = AttendanceContextStatus.initial,
    this.actionStatus = AttendanceActionStatus.idle,
    this.failure,
    this.warnings = const [],
    this.lastLocationValidation,
  });
  final AttendanceContext? context;
  AttendanceDay? get currentDay => context?.day;
  final AttendanceSummary? summary;
  final AttendanceAvailableActions? actions;
  final AttendanceContextStatus contextStatus;
  final AttendanceActionStatus actionStatus;
  final Failure? failure;
  final List<AttendanceWarningCode> warnings;
  final AttendanceLocationValidation? lastLocationValidation;
  AttendanceBlocState update({
    AttendanceContext? context,
    AttendanceSummary? summary,
    AttendanceAvailableActions? actions,
    AttendanceContextStatus? contextStatus,
    AttendanceActionStatus? actionStatus,
    Failure? failure,
    List<AttendanceWarningCode>? warnings,
    AttendanceLocationValidation? validation,
    bool clearData = false,
  }) => AttendanceBlocState(
    context: clearData ? null : context ?? this.context,
    summary: clearData ? null : summary ?? this.summary,
    actions: clearData ? null : actions ?? this.actions,
    contextStatus: contextStatus ?? this.contextStatus,
    actionStatus: actionStatus ?? this.actionStatus,
    failure: failure,
    warnings: List.unmodifiable(warnings ?? this.warnings),
    lastLocationValidation: validation ?? lastLocationValidation,
  );
}

class AttendanceBloc extends Bloc<AttendanceBlocEvent, AttendanceBlocState> {
  AttendanceBloc(
    this.repository,
    this.execute, {
    this.engine = const AttendanceEngine(),
  }) : super(const AttendanceBlocState()) {
    on<AttendanceBlocEvent>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
  final AttendanceRepository repository;
  final ExecuteAttendanceAction execute;
  final AttendanceEngine engine;
  StreamSubscription<Result<AttendanceContext>>? _watch;
  bool _queued = false;
  @override
  void add(AttendanceBlocEvent event) {
    if (event is AttendanceActionRequested ||
        event is PendingOperationRetryRequested) {
      if (_queued || state.actionStatus == AttendanceActionStatus.submitting) {
        return;
      }
      _queued = true;
    }
    super.add(event);
  }

  void _loaded(
    Result<AttendanceContext> result,
    Emitter<AttendanceBlocState> emit,
  ) {
    if (result case Failed<AttendanceContext>(:final failure)) {
      // Session/access/context failures cannot retain actionable stale employee data.
      emit(
        state.update(
          contextStatus: AttendanceContextStatus.unavailable,
          failure: failure,
          clearData: true,
        ),
      );
      return;
    }
    final c = (result as Success<AttendanceContext>).value,
        summary = engine.calculateSummary(c);
    if (summary case Failed<AttendanceSummary>(:final failure)) {
      emit(
        state.update(
          contextStatus: AttendanceContextStatus.unavailable,
          failure: failure,
          clearData: true,
        ),
      );
      return;
    }
    emit(
      state.update(
        context: c,
        summary: (summary as Success<AttendanceSummary>).value,
        actions: engine.getAvailableActions(c),
        contextStatus: AttendanceContextStatus.ready,
        failure: state.actionStatus == AttendanceActionStatus.failed
            ? state.failure
            : null,
      ),
    );
  }

  Future<void> _handle(
    AttendanceBlocEvent event,
    Emitter<AttendanceBlocState> emit,
  ) async {
    if (event is AttendanceStarted) {
      emit(state.update(contextStatus: AttendanceContextStatus.loading));
      await _watch?.cancel();
      _watch = repository.watchCurrentAttendance().listen(
        (result) {
          if (!isClosed) add(_AttendanceChanged(result));
        },
        onError: (Object error) {
          if (!isClosed) {
            add(
              const _AttendanceChanged(
                Failed(
                  Failure(
                    code: 'persistenceFailure',
                    kind: FailureKind.storageWrite,
                  ),
                ),
              ),
            );
          }
        },
      );
    } else if (event is _AttendanceChanged) {
      _loaded(event.result, emit);
    } else if (event is AttendanceRefreshRequested) {
      _loaded(await repository.getCurrentAttendance(), emit);
    } else if (event is AttendanceActionRequested ||
        event is PendingOperationRetryRequested) {
      emit(
        state.update(
          actionStatus: AttendanceActionStatus.submitting,
          warnings: const [],
        ),
      );
      try {
        if (event is AttendanceActionRequested) {
          final result = await execute(event.type, workMode: event.workMode);
          if (result case Failed<AttendanceMutationResult>(:final failure)) {
            emit(
              state.update(
                actionStatus: AttendanceActionStatus.failed,
                failure: failure,
              ),
            );
          } else {
            final value = (result as Success<AttendanceMutationResult>).value;
            emit(
              state.update(
                actionStatus: AttendanceActionStatus.succeeded,
                warnings: value.decision.warnings,
                validation: value.event.locationValidation,
              ),
            );
            _loaded(await repository.getCurrentAttendance(), emit);
          }
        } else {
          final result = await repository.retryPendingOperation(
            (event as PendingOperationRetryRequested).operationId,
          );
          if (result case Failed<void>(:final failure)) {
            emit(
              state.update(
                actionStatus: AttendanceActionStatus.failed,
                failure: failure,
              ),
            );
          } else {
            emit(state.update(actionStatus: AttendanceActionStatus.succeeded));
          }
        }
      } catch (_) {
        emit(
          state.update(
            actionStatus: AttendanceActionStatus.failed,
            failure: const Failure(
              code: 'persistenceFailure',
              kind: FailureKind.storageWrite,
            ),
          ),
        );
      } finally {
        _queued = false;
      }
    }
  }

  @override
  Future<void> close() async {
    await _watch?.cancel();
    return super.close();
  }
}
