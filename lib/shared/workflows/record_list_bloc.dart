import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/core/models/configuration_record.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/shared/domain/configuration_repository.dart';

sealed class RecordListEvent {
  const RecordListEvent();
}

class RecordListStarted extends RecordListEvent {
  const RecordListStarted();
}

class RecordSearchChanged extends RecordListEvent {
  const RecordSearchChanged(this.query);
  final String query;
}

class RecordFilterChanged extends RecordListEvent {
  const RecordFilterChanged(this.status);
  final ConfigurationStatus? status;
}

class RecordPageChanged extends RecordListEvent {
  const RecordPageChanged(this.page);
  final int page;
}

class RecordStatusRequested extends RecordListEvent {
  const RecordStatusRequested(this.id, this.active);
  final String id;
  final bool active;
}

class _ListReceived<T extends ConfigurationRecord> extends RecordListEvent {
  const _ListReceived(this.result, this.generation);
  final Result<ConfigurationPageData<T>> result;
  final int generation;
}

class RecordListState<T extends ConfigurationRecord> {
  const RecordListState({
    this.data,
    this.query = '',
    this.status,
    this.page = 0,
    this.loading = true,
    this.busy = false,
    this.failure,
    this.statusSaved = false,
  });
  final ConfigurationPageData<T>? data;
  final String query;
  final ConfigurationStatus? status;
  final int page;
  final bool loading, busy, statusSaved;
  final Failure? failure;
}

class RecordListBloc<T extends ConfigurationRecord, D>
    extends Bloc<RecordListEvent, RecordListState<T>> {
  RecordListBloc(this.repository, this.context) : super(RecordListState<T>()) {
    on<RecordListEvent>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
  final ConfigurationRepository<T, D> repository;
  final AuthContext context;
  StreamSubscription<Result<ConfigurationPageData<T>>>? _subscription;
  Timer? _debounce;
  int _generation = 0;
  @override
  void add(RecordListEvent event) {
    if (isClosed) return;
    if (event is RecordSearchChanged) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (!isClosed) super.add(event);
      });
      return;
    }
    super.add(event);
  }

  RecordListState<T> next({
    ConfigurationPageData<T>? data,
    String? query,
    ConfigurationStatus? status,
    bool changeStatus = false,
    int? page,
    bool? loading,
    bool? busy,
    Failure? failure,
    bool statusSaved = false,
  }) => RecordListState(
    data: data ?? state.data,
    query: query ?? state.query,
    status: changeStatus ? status : state.status,
    page: page ?? state.page,
    loading: loading ?? state.loading,
    busy: busy ?? state.busy,
    failure: failure,
    statusSaved: statusSaved,
  );
  Future<void> watch() async {
    await _subscription?.cancel();
    final generation = ++_generation;
    _subscription = repository
        .watchList(
          context,
          query: state.query,
          status: state.status,
          page: state.page,
        )
        .listen(
          (r) {
            if (!isClosed) add(_ListReceived(r, generation));
          },
          onError: (Object _) {
            if (!isClosed) {
              add(
                _ListReceived<T>(
                  const Failed(Failure(code: 'databaseFailure')),
                  generation,
                ),
              );
            }
          },
        );
  }

  Future<void> _handle(
    RecordListEvent event,
    Emitter<RecordListState<T>> emit,
  ) async {
    switch (event) {
      case RecordListStarted():
        emit(next(loading: true));
        await watch();
      case RecordSearchChanged(:final query):
        emit(next(query: query, page: 0, loading: true));
        await watch();
      case RecordFilterChanged(:final status):
        emit(next(status: status, changeStatus: true, page: 0, loading: true));
        await watch();
      case RecordPageChanged(:final page):
        emit(next(page: page, loading: true));
        await watch();
      case _ListReceived<T>(:final result, :final generation):
        if (generation != _generation) return;
        if (result is Success<ConfigurationPageData<T>>) {
          final last = result.value.filtered == 0
              ? 0
              : (result.value.filtered - 1) ~/ 10;
          if (state.page > last) {
            emit(next(page: last, loading: true));
            await watch();
          } else {
            emit(next(data: result.value, loading: false));
          }
        } else if (result is Failed<ConfigurationPageData<T>>) {
          emit(next(loading: false, failure: result.failure));
        }
      case RecordStatusRequested(:final id, :final active):
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
    _debounce?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
