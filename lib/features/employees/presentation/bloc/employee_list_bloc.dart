import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/auth_context.dart';
import '../../domain/employee.dart';
import '../../domain/employee_repository.dart';

sealed class EmployeeListEvent {
  const EmployeeListEvent();
}

class EmployeeListStarted extends EmployeeListEvent {
  const EmployeeListStarted();
}

class EmployeeSearchChanged extends EmployeeListEvent {
  const EmployeeSearchChanged(this.query);
  final String query;
}

class EmployeeFilterChanged extends EmployeeListEvent {
  const EmployeeFilterChanged(this.filter);
  final EmployeeFilter filter;
}

class EmployeeSortChanged extends EmployeeListEvent {
  const EmployeeSortChanged(this.sort);
  final EmployeeSort sort;
}

class EmployeePageChanged extends EmployeeListEvent {
  const EmployeePageChanged(this.page);
  final int page;
}

class EmployeeStatusRequested extends EmployeeListEvent {
  const EmployeeStatusRequested(this.id, this.active);
  final String id;
  final bool active;
}

class _Received extends EmployeeListEvent {
  const _Received(this.result, this.generation);
  final Result<EmployeePageData> result;
  final int generation;
}

class EmployeeListState {
  const EmployeeListState({
    this.data,
    this.references,
    this.query = '',
    this.filter = const EmployeeFilter(),
    this.sort = EmployeeSort.nameAscending,
    this.page = 0,
    this.loading = true,
    this.busy = false,
    this.failure,
    this.statusSaved = false,
  });
  final EmployeePageData? data;
  final EmployeeReferences? references;
  final String query;
  final EmployeeFilter filter;
  final EmployeeSort sort;
  final int page;
  final bool loading, busy, statusSaved;
  final Failure? failure;
}

class EmployeeListBloc extends Bloc<EmployeeListEvent, EmployeeListState> {
  EmployeeListBloc(this.repository, this.context)
    : super(const EmployeeListState()) {
    on<EmployeeListEvent>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
  final EmployeeRepository repository;
  final AuthContext context;
  StreamSubscription<Result<EmployeePageData>>? _subscription;
  Timer? _debounce;
  int _generation = 0;
  String? _pendingQuery;
  @override
  void add(EmployeeListEvent event) {
    if (isClosed) return;
    if (event is EmployeeSearchChanged) {
      _pendingQuery = event.query;
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (!isClosed) {
          super.add(EmployeeSearchChanged(_pendingQuery!));
          _pendingQuery = null;
        }
      });
      return;
    }
    super.add(event);
  }

  EmployeeListState next({
    EmployeePageData? data,
    EmployeeReferences? references,
    String? query,
    EmployeeFilter? filter,
    EmployeeSort? sort,
    int? page,
    bool? loading,
    bool? busy,
    Failure? failure,
    bool statusSaved = false,
  }) => EmployeeListState(
    data: data ?? state.data,
    references: references ?? state.references,
    query: query ?? state.query,
    filter: filter ?? state.filter,
    sort: sort ?? state.sort,
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
        .watchEmployees(
          context,
          query: state.query,
          filter: state.filter,
          sort: state.sort,
          page: state.page,
        )
        .listen(
          (r) => add(_Received(r, generation)),
          onError: (Object _) => add(
            _Received(const Failed(Failure(code: 'storage')), generation),
          ),
        );
  }

  Future<void> _handle(
    EmployeeListEvent event,
    Emitter<EmployeeListState> emit,
  ) async {
    switch (event) {
      case EmployeeListStarted():
        emit(next(loading: true));
        final refs = await repository.getReferences(context);
        if (refs case Success<EmployeeReferences>(:final value)) {
          emit(next(references: value));
        }
        await watch();
      case EmployeeSearchChanged(:final query):
        emit(next(query: query, page: 0, loading: true));
        await watch();
      case EmployeeFilterChanged(:final filter):
        emit(next(filter: filter, page: 0, loading: true));
        await watch();
      case EmployeeSortChanged(:final sort):
        emit(next(sort: sort, page: 0, loading: true));
        await watch();
      case EmployeePageChanged(:final page):
        emit(next(page: page, loading: true));
        await watch();
      case _Received(:final result, :final generation):
        if (generation != _generation) return;
        switch (result) {
          case Success<EmployeePageData>(:final value):
            final lastPage = value.filtered == 0
                ? 0
                : (value.filtered - 1) ~/ 10;
            if (state.page > lastPage) {
              emit(next(page: lastPage, loading: true));
              await watch();
            } else {
              emit(next(data: value, loading: false));
            }
          case Failed<EmployeePageData>(:final failure):
            emit(next(loading: false, failure: failure));
        }
      case EmployeeStatusRequested(:final id, :final active):
        if (state.busy) return;
        emit(next(busy: true));
        final result = await repository.setActive(context, id, active);
        emit(
          next(
            busy: false,
            failure: result is Failed<void> ? result.failure : null,
            statusSaved: result is Success<void>,
          ),
        );
    }
  }

  @override
  Future<void> close() async {
    _debounce?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
