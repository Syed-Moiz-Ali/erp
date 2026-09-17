import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/errors/result.dart';
import '../../core/models/configuration_record.dart';
import '../../features/auth/domain/entities/auth_context.dart';
import '../domain/configuration_repository.dart';

sealed class RecordDetailsEvent {
  const RecordDetailsEvent();
}

class RecordDetailsStarted extends RecordDetailsEvent {
  const RecordDetailsStarted();
}

class RecordDetailsStatusRequested extends RecordDetailsEvent {
  const RecordDetailsStatusRequested(this.active);
  final bool active;
}

class _DetailReceived<T extends ConfigurationRecord>
    extends RecordDetailsEvent {
  const _DetailReceived(this.result);
  final Result<ConfigurationItem<T>?> result;
}

class RecordDetailsState<T extends ConfigurationRecord> {
  const RecordDetailsState({
    this.detail,
    this.loading = true,
    this.busy = false,
    this.failure,
    this.statusSaved = false,
  });
  final ConfigurationItem<T>? detail;
  final bool loading, busy, statusSaved;
  final Failure? failure;
}

class RecordDetailsBloc<T extends ConfigurationRecord, D>
    extends Bloc<RecordDetailsEvent, RecordDetailsState<T>> {
  RecordDetailsBloc(this.repository, this.context, this.id)
    : super(RecordDetailsState<T>()) {
    on<RecordDetailsEvent>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
  final ConfigurationRepository<T, D> repository;
  final AuthContext context;
  final String id;
  StreamSubscription<Result<ConfigurationItem<T>?>>? _subscription;
  RecordDetailsState<T> next({
    ConfigurationItem<T>? detail,
    bool? loading,
    bool? busy,
    Failure? failure,
    bool statusSaved = false,
  }) => RecordDetailsState(
    detail: detail ?? state.detail,
    loading: loading ?? state.loading,
    busy: busy ?? state.busy,
    failure: failure,
    statusSaved: statusSaved,
  );
  Future<void> _handle(
    RecordDetailsEvent event,
    Emitter<RecordDetailsState<T>> emit,
  ) async {
    switch (event) {
      case RecordDetailsStarted():
        await _subscription?.cancel();
        _subscription = repository
            .watchDetails(context, id)
            .listen(
              (r) {
                if (!isClosed) add(_DetailReceived(r));
              },
              onError: (Object _) {
                if (!isClosed) {
                  add(
                    _DetailReceived<T>(
                      const Failed(Failure(code: 'databaseFailure')),
                    ),
                  );
                }
              },
            );
      case _DetailReceived<T>(:final result):
        if (result is Success<ConfigurationItem<T>?>) {
          emit(RecordDetailsState(detail: result.value, loading: false));
        } else if (result is Failed<ConfigurationItem<T>?>) {
          emit(next(loading: false, failure: result.failure));
        }
      case RecordDetailsStatusRequested(:final active):
        if (state.busy) return;
        emit(next(busy: true));
        final result = await repository.setActive(context, id, active);
        emit(
          next(
            busy: false,
            statusSaved: result is Success<void>,
            failure: result is Failed<void> ? result.failure : null,
          ),
        );
      default:
        break;
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
