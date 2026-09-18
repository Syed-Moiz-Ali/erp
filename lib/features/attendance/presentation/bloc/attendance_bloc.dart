import '../../domain/attendance_state_machine.dart';
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

enum AttendanceActionStatus {
  idle,
  submitting,
  checkingLocation,
  awaitingConfirmation,
  succeeded,
  failed,
}

class AttendanceActionConfirmed extends AttendanceBlocEvent {
  const AttendanceActionConfirmed();
}

class AttendanceConfirmationCancelled extends AttendanceBlocEvent {
  const AttendanceConfirmationCancelled();
}

class AttendanceLocationRefreshRequested extends AttendanceBlocEvent {
  const AttendanceLocationRefreshRequested(this.type);
  final AttendanceEventType type;
}

class AttendanceLocationSettingsRequested extends AttendanceBlocEvent {
  const AttendanceLocationSettingsRequested({this.locationSettings = false});
  final bool locationSettings;
}

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
    this.preparedAction,
    this.locationPreview,
    this.operation,
    this.refreshing = false,
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
  final PreparedAttendanceAction? preparedAction, locationPreview;
  final AttendanceEventType? operation;
  final bool refreshing;
  bool get busy =>
      actionStatus == AttendanceActionStatus.submitting ||
      actionStatus == AttendanceActionStatus.checkingLocation ||
      actionStatus == AttendanceActionStatus.awaitingConfirmation;
  AttendanceBlocState update({
    AttendanceContext? context,
    AttendanceSummary? summary,
    AttendanceAvailableActions? actions,
    AttendanceContextStatus? contextStatus,
    AttendanceActionStatus? actionStatus,
    Failure? failure,
    List<AttendanceWarningCode>? warnings,
    AttendanceLocationValidation? validation,
    PreparedAttendanceAction? preparedAction,
    PreparedAttendanceAction? locationPreview,
    AttendanceEventType? operation,
    bool? refreshing,
    bool clearPrepared = false,
    bool clearPreview = false,
    bool clearData = false,
  }) => AttendanceBlocState(
    context: clearData ? null : context ?? this.context,
    summary: clearData ? null : summary ?? this.summary,
    actions: clearData ? null : actions ?? this.actions,
    contextStatus: contextStatus ?? this.contextStatus,
    actionStatus: actionStatus ?? this.actionStatus,
    failure: failure,
    warnings: List.unmodifiable(warnings ?? this.warnings),
    lastLocationValidation: clearData
        ? null
        : validation ?? (clearPreview ? null : lastLocationValidation),
    preparedAction: clearData || clearPrepared
        ? null
        : preparedAction ?? this.preparedAction,
    locationPreview: clearData || clearPreview
        ? null
        : locationPreview ?? this.locationPreview,
    operation: operation ?? this.operation,
    refreshing: refreshing ?? this.refreshing,
  );
}

class AttendanceBloc extends Bloc<AttendanceBlocEvent, AttendanceBlocState> {
  AttendanceBloc(
    this.repository,
    this.execute, {
    this.engine = const AttendanceEngine(),
    this.requireConfirmation = false,
    this.openSettings,
  }) : super(const AttendanceBlocState()) {
    on<AttendanceBlocEvent>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
  final AttendanceRepository repository;
  final ExecuteAttendanceAction execute;
  final AttendanceEngine engine;
  final bool requireConfirmation;
  final Future<Result<bool>> Function(bool locationSettings)? openSettings;
  StreamSubscription<Result<AttendanceContext>>? _watch;
  bool _queued = false;
  @override
  void add(AttendanceBlocEvent event) {
    if (event is AttendanceActionConfirmed) {
      if (_queued ||
          state.preparedAction == null ||
          state.actionStatus != AttendanceActionStatus.awaitingConfirmation) {
        return;
      }
      _queued = true;
    } else if (event is AttendanceActionRequested ||
        event is PendingOperationRetryRequested ||
        event is AttendanceLocationRefreshRequested ||
        event is AttendanceLocationSettingsRequested) {
      if (_queued || state.busy) return;
      _queued = true;
    }
    super.add(event);
  }

  void _loaded(
    Result<AttendanceContext> result,
    Emitter<AttendanceBlocState> emit,
  ) {
    if (result case Failed<AttendanceContext>(:final failure)) {
      emit(
        state.update(
          contextStatus: AttendanceContextStatus.unavailable,
          failure: failure,
          refreshing: false,
          clearData: true,
        ),
      );
      return;
    }
    final c = (result as Success<AttendanceContext>).value,
        s = engine.calculateSummary(c);
    if (s case Failed<AttendanceSummary>(:final failure)) {
      emit(
        state.update(
          contextStatus: AttendanceContextStatus.unavailable,
          failure: failure,
          refreshing: false,
          clearData: true,
        ),
      );
      return;
    }
    var actions = engine.getAvailableActions(c);
    final preview = state.locationPreview;
    if (preview != null &&
        !preview.decision.allowed &&
        preview.context.workday == c.workday &&
        preview.context.day?.id == c.day?.id) {
      actions = AttendanceAvailableActions({
        ...actions.decisions,
        preview.type: preview.decision,
      });
    }
    emit(
      state.update(
        context: c,
        summary: (s as Success<AttendanceSummary>).value,
        actions: actions,
        contextStatus: AttendanceContextStatus.ready,
        refreshing: false,
        failure: state.actionStatus == AttendanceActionStatus.failed
            ? state.failure
            : null,
      ),
    );
  }

  void _preview(PreparedAttendanceAction p, Emitter<AttendanceBlocState> emit) {
    final actions = state.actions;
    emit(
      state.update(
        locationPreview: p,
        validation: p.decision.locationValidation,
        actions: actions == null
            ? null
            : AttendanceAvailableActions({
                ...actions.decisions,
                p.type: p.decision,
              }),
        failure: p.decision.failure == null
            ? null
            : attendanceFailure(p.decision.failure!),
      ),
    );
  }

  Future<void> _submit(
    PreparedAttendanceAction p,
    Emitter<AttendanceBlocState> emit,
  ) async {
    emit(
      state.update(
        actionStatus: AttendanceActionStatus.submitting,
        clearPrepared: true,
      ),
    );
    final result = await execute.commit(p);
    if (result case Failed<AttendanceMutationResult>(:final failure)) {
      emit(
        state.update(
          actionStatus: AttendanceActionStatus.failed,
          failure: failure,
        ),
      );
      return;
    }
    final value = (result as Success<AttendanceMutationResult>).value;
    emit(
      state.update(
        actionStatus: AttendanceActionStatus.succeeded,
        warnings: value.decision.warnings,
        validation: value.event.locationValidation,
        clearPreview: true,
      ),
    );
    _loaded(await repository.getCurrentAttendance(), emit);
  }

  Future<void> _handle(
    AttendanceBlocEvent event,
    Emitter<AttendanceBlocState> emit,
  ) async {
    if (event is AttendanceStarted) {
      emit(
        state.update(
          contextStatus: state.context == null
              ? AttendanceContextStatus.loading
              : AttendanceContextStatus.ready,
        ),
      );
      await _watch?.cancel();
      _watch = repository.watchCurrentAttendance().listen(
        (r) {
          if (!isClosed) add(_AttendanceChanged(r));
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
      emit(state.update(refreshing: true));
      _loaded(await repository.getCurrentAttendance(), emit);
    } else if (event is AttendanceConfirmationCancelled) {
      emit(
        state.update(
          actionStatus: AttendanceActionStatus.idle,
          clearPrepared: true,
          warnings: const [],
        ),
      );
    } else {
      try {
        if (event is AttendanceActionRequested ||
            event is AttendanceLocationRefreshRequested) {
          final type = event is AttendanceActionRequested
              ? event.type
              : (event as AttendanceLocationRefreshRequested).type;
          emit(
            state.update(
              actionStatus: AttendanceActionStatus.submitting,
              operation: type,
              clearPrepared: true,
              clearPreview: true,
              warnings: const [],
            ),
          );
          final result = await execute.prepare(
            type,
            workMode: event is AttendanceActionRequested
                ? event.workMode
                : AttendanceWorkMode.office,
            onCheckingLocation: () => emit(
              state.update(
                actionStatus: AttendanceActionStatus.checkingLocation,
              ),
            ),
          );
          if (result case Failed<PreparedAttendanceAction>(:final failure)) {
            emit(
              state.update(
                actionStatus: AttendanceActionStatus.failed,
                failure: failure,
              ),
            );
            return;
          }
          final p = (result as Success<PreparedAttendanceAction>).value;
          _preview(p, emit);
          if (!p.decision.allowed) {
            emit(
              state.update(
                actionStatus: AttendanceActionStatus.failed,
                failure: attendanceFailure(p.decision.failure!),
              ),
            );
            return;
          }
          if (event is AttendanceLocationRefreshRequested) {
            emit(state.update(actionStatus: AttendanceActionStatus.idle));
            return;
          }
          if (requireConfirmation &&
              (type == AttendanceEventType.punchOut ||
                  p.decision.warnings.isNotEmpty)) {
            emit(
              state.update(
                actionStatus: AttendanceActionStatus.awaitingConfirmation,
                preparedAction: p,
                warnings: p.decision.warnings,
              ),
            );
          } else {
            await _submit(p, emit);
          }
        } else if (event is AttendanceActionConfirmed) {
          final original = state.preparedAction;
          if (original == null) return;
          emit(state.update(actionStatus: AttendanceActionStatus.submitting));
          final review = await execute.review(original);
          if (review case Failed<PreparedAttendanceAction>(:final failure)) {
            emit(
              state.update(
                actionStatus: AttendanceActionStatus.failed,
                failure: failure,
                clearPrepared: true,
              ),
            );
            return;
          }
          final p = (review as Success<PreparedAttendanceAction>).value;
          _preview(p, emit);
          if (!p.decision.allowed) {
            emit(
              state.update(
                actionStatus: AttendanceActionStatus.failed,
                failure: attendanceFailure(p.decision.failure!),
                clearPrepared: true,
              ),
            );
            return;
          }
          if (p.decision.warnings.any(
            (w) => !original.decision.warnings.contains(w),
          )) {
            emit(
              state.update(
                actionStatus: AttendanceActionStatus.awaitingConfirmation,
                preparedAction: p,
                warnings: p.decision.warnings,
              ),
            );
            return;
          }
          await _submit(p, emit);
        } else if (event is PendingOperationRetryRequested) {
          emit(state.update(actionStatus: AttendanceActionStatus.submitting));
          final r = await repository.retryPendingOperation(event.operationId);
          if (r case Failed<void>(:final failure)) {
            emit(
              state.update(
                actionStatus: AttendanceActionStatus.failed,
                failure: failure,
              ),
            );
          } else {
            emit(state.update(actionStatus: AttendanceActionStatus.succeeded));
            _loaded(await repository.getCurrentAttendance(), emit);
          }
        } else if (event is AttendanceLocationSettingsRequested) {
          final r = await openSettings?.call(event.locationSettings);
          if (r == null || r is Failed<bool>) {
            emit(
              state.update(
                failure: r is Failed<bool>
                    ? r.failure
                    : attendanceFailure(
                        AttendanceFailureCode.locationUnavailable,
                      ),
              ),
            );
          }
        }
      } catch (_) {
        emit(
          state.update(
            actionStatus: AttendanceActionStatus.failed,
            failure: attendanceFailure(
              AttendanceFailureCode.persistenceFailure,
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
