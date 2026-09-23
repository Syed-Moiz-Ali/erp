import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/auth_context.dart';
import '../../domain/leave_models.dart';
import '../../domain/leave_repository.dart';

// ---- request list ----------------------------------------------------------

sealed class LeaveRequestListEvent {
  const LeaveRequestListEvent();
}

class LeaveRequestListStarted extends LeaveRequestListEvent {
  const LeaveRequestListStarted();
}

class _LeaveRequestsReceived extends LeaveRequestListEvent {
  const _LeaveRequestsReceived(this.result);
  final Result<List<LeaveRequestRow>> result;
}

class LeaveRequestListState {
  const LeaveRequestListState({
    this.loading = true,
    this.rows = const [],
    this.failure,
  });
  final bool loading;
  final List<LeaveRequestRow> rows;
  final Failure? failure;
}

class LeaveRequestListBloc
    extends Bloc<LeaveRequestListEvent, LeaveRequestListState> {
  LeaveRequestListBloc(this.repository, this.context, this.scope)
    : super(const LeaveRequestListState()) {
    on<LeaveRequestListEvent>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
  final LeaveRepository repository;
  final AuthContext context;
  final LeaveRequestScope scope;
  StreamSubscription<Result<List<LeaveRequestRow>>>? _subscription;

  Future<void> _handle(
    LeaveRequestListEvent event,
    Emitter<LeaveRequestListState> emit,
  ) async {
    switch (event) {
      case LeaveRequestListStarted():
        emit(const LeaveRequestListState());
        await _subscription?.cancel();
        _subscription = repository
            .watchRequests(context, scope: scope)
            .listen(
              (r) => add(_LeaveRequestsReceived(r)),
              onError: (Object _) => add(
                const _LeaveRequestsReceived(
                  Failed(Failure(code: 'leaveStorageError')),
                ),
              ),
            );
      case _LeaveRequestsReceived(:final result):
        switch (result) {
          case Success<List<LeaveRequestRow>>(:final value):
            emit(LeaveRequestListState(loading: false, rows: value));
          case Failed<List<LeaveRequestRow>>(:final failure):
            emit(LeaveRequestListState(loading: false, failure: failure));
        }
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

// ---- request form ----------------------------------------------------------

sealed class LeaveRequestFormEvent {
  const LeaveRequestFormEvent();
}

class LeaveRequestFormStarted extends LeaveRequestFormEvent {
  const LeaveRequestFormStarted();
}

class LeaveRequestDraftChanged extends LeaveRequestFormEvent {
  const LeaveRequestDraftChanged(this.update);
  final LeaveRequestDraft Function(LeaveRequestDraft) update;
}

class LeaveRequestSubmitted extends LeaveRequestFormEvent {
  const LeaveRequestSubmitted();
}

class LeaveRequestFormState {
  const LeaveRequestFormState({
    required this.draft,
    this.types = const [],
    this.loadingTypes = true,
    this.preview,
    this.previewing = false,
    this.submitting = false,
    this.failure,
    this.submitted,
  });
  final LeaveRequestDraft draft;
  final List<LeaveType> types;
  final bool loadingTypes, previewing, submitting;
  final LeaveRequestPreview? preview;
  final Failure? failure;
  final LeaveRequest? submitted;
}

class LeaveRequestFormBloc
    extends Bloc<LeaveRequestFormEvent, LeaveRequestFormState> {
  LeaveRequestFormBloc(this.repository, this.context)
    : super(
        LeaveRequestFormState(
          draft: LeaveRequestDraft(
            leaveTypeId: '',
            startDate: DateTime.utc(1970),
            endDate: DateTime.utc(1970),
          ),
        ),
      ) {
    on<LeaveRequestFormEvent>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }

  final LeaveRepository repository;
  final AuthContext context;
  bool _submissionQueued = false;

  @override
  void add(LeaveRequestFormEvent event) {
    if (isClosed) return;
    if (event is LeaveRequestSubmitted) {
      if (_submissionQueued) return;
      _submissionQueued = true;
    }
    super.add(event);
  }

  LeaveType? get selectedType {
    final id = state.draft.leaveTypeId;
    for (final type in state.types) {
      if (type.id == id) return type;
    }
    return null;
  }

  Future<void> _handle(
    LeaveRequestFormEvent event,
    Emitter<LeaveRequestFormState> emit,
  ) async {
    switch (event) {
      case LeaveRequestFormStarted():
        emit(LeaveRequestFormState(draft: state.draft, loadingTypes: true));
        final result = await repository.watchLeaveTypes(context).first;
        if (result is Failed<List<LeaveType>>) {
          emit(
            LeaveRequestFormState(
              draft: state.draft,
              loadingTypes: false,
              failure: result.failure,
            ),
          );
          return;
        }
        final types = (result as Success<List<LeaveType>>).value;
        final today = repository.companyToday(context);
        var draft = state.draft;
        if (draft.startDate.year < 2000) {
          draft = draft.copyWith(startDate: today, endDate: today);
        }
        if (draft.leaveTypeId.isEmpty && types.isNotEmpty) {
          draft = draft.copyWith(leaveTypeId: types.first.id);
        }
        emit(
          LeaveRequestFormState(
            draft: draft,
            types: types,
            loadingTypes: false,
          ),
        );
        await _refreshPreview(emit, draft);
      case LeaveRequestDraftChanged(:final update):
        if (state.submitting) return;
        final draft = update(state.draft);
        emit(
          LeaveRequestFormState(
            draft: draft,
            types: state.types,
            loadingTypes: false,
            preview: state.preview,
            submitting: false,
          ),
        );
        await _refreshPreview(emit, draft);
      case LeaveRequestSubmitted():
        if (state.submitting || state.submitted != null) {
          _submissionQueued = false;
          return;
        }
        emit(
          LeaveRequestFormState(
            draft: state.draft,
            types: state.types,
            loadingTypes: false,
            preview: state.preview,
            submitting: true,
          ),
        );
        final result = await repository.submitRequest(context, state.draft);
        _submissionQueued = false;
        emit(
          LeaveRequestFormState(
            draft: state.draft,
            types: state.types,
            loadingTypes: false,
            preview: state.preview,
            submitting: false,
            failure: result is Failed<LeaveRequest> ? result.failure : null,
            submitted: result is Success<LeaveRequest> ? result.value : null,
          ),
        );
    }
  }

  Future<void> _refreshPreview(
    Emitter<LeaveRequestFormState> emit,
    LeaveRequestDraft draft,
  ) async {
    if (draft.leaveTypeId.isEmpty) return;
    emit(
      LeaveRequestFormState(
        draft: draft,
        types: state.types,
        loadingTypes: false,
        preview: state.preview,
        previewing: true,
      ),
    );
    final result = await repository.previewRequest(context, draft);
    emit(
      LeaveRequestFormState(
        draft: draft,
        types: state.types,
        loadingTypes: false,
        preview: result is Success<LeaveRequestPreview> ? result.value : null,
        previewing: false,
        failure: result is Failed<LeaveRequestPreview> ? result.failure : null,
      ),
    );
  }
}

// ---- request details -------------------------------------------------------

sealed class LeaveRequestDetailsEvent {
  const LeaveRequestDetailsEvent();
}

class LeaveRequestDetailsStarted extends LeaveRequestDetailsEvent {
  const LeaveRequestDetailsStarted();
}

class LeaveRequestApproved extends LeaveRequestDetailsEvent {
  const LeaveRequestApproved(this.note);
  final String note;
}

class LeaveRequestRejected extends LeaveRequestDetailsEvent {
  const LeaveRequestRejected(this.note);
  final String note;
}

class LeaveRequestCancelled extends LeaveRequestDetailsEvent {
  const LeaveRequestCancelled(this.reason);
  final String reason;
}

class LeaveRequestDetailsState {
  const LeaveRequestDetailsState({
    this.loading = true,
    this.row,
    this.busy = false,
    this.failure,
    this.actionCompleted = false,
  });
  final bool loading, busy, actionCompleted;
  final LeaveRequestRow? row;
  final Failure? failure;
}

class LeaveRequestDetailsBloc
    extends Bloc<LeaveRequestDetailsEvent, LeaveRequestDetailsState> {
  LeaveRequestDetailsBloc(this.repository, this.context, this.id)
    : super(const LeaveRequestDetailsState()) {
    on<LeaveRequestDetailsEvent>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
  final LeaveRepository repository;
  final AuthContext context;
  final String id;

  Future<void> _load(Emitter<LeaveRequestDetailsState> emit) async {
    final result = await repository.requestById(context, id);
    switch (result) {
      case Success<LeaveRequestRow?>(:final value):
        emit(LeaveRequestDetailsState(loading: false, row: value));
      case Failed<LeaveRequestRow?>(:final failure):
        emit(LeaveRequestDetailsState(loading: false, failure: failure));
    }
  }

  Future<void> _handle(
    LeaveRequestDetailsEvent event,
    Emitter<LeaveRequestDetailsState> emit,
  ) async {
    switch (event) {
      case LeaveRequestDetailsStarted():
        emit(const LeaveRequestDetailsState());
        await _load(emit);
      case LeaveRequestApproved(:final note):
      case LeaveRequestRejected(:final note):
        final approve = event is LeaveRequestApproved;
        emit(
          LeaveRequestDetailsState(loading: false, row: state.row, busy: true),
        );
        final result = approve
            ? await repository.approveRequest(context, id, note: note)
            : await repository.rejectRequest(context, id, note: note);
        emit(
          LeaveRequestDetailsState(
            loading: false,
            busy: false,
            failure: result is Failed<LeaveRequest> ? result.failure : null,
            actionCompleted: result is Success<LeaveRequest>,
          ),
        );
        await _load(emit);
      case LeaveRequestCancelled(:final reason):
        emit(
          LeaveRequestDetailsState(loading: false, row: state.row, busy: true),
        );
        final result = await repository.cancelRequest(
          context,
          id,
          reason: reason,
        );
        emit(
          LeaveRequestDetailsState(
            loading: false,
            busy: false,
            failure: result is Failed<LeaveRequest> ? result.failure : null,
            actionCompleted: result is Success<LeaveRequest>,
          ),
        );
        await _load(emit);
    }
  }
}

// ---- balances --------------------------------------------------------------

class LeaveBalancesCubit extends Cubit<LeaveBalancesState> {
  LeaveBalancesCubit(
    this.repository,
    this.context,
    this.employeeId, {
    this.year,
  }) : super(const LeaveBalancesState()) {
    load();
  }
  final LeaveRepository repository;
  final AuthContext context;
  final String employeeId;
  final int? year;
  StreamSubscription<Result<List<LeaveBalanceSummary>>>? _subscription;

  Future<void> load() async {
    emit(const LeaveBalancesState());
    await _subscription?.cancel();
    _subscription = repository
        .watchBalances(context, employeeId, year: year)
        .listen(
          (r) => switch (r) {
            Success<List<LeaveBalanceSummary>>(:final value) => emit(
              LeaveBalancesState(loading: false, balances: value),
            ),
            Failed<List<LeaveBalanceSummary>>(:final failure) => emit(
              LeaveBalancesState(loading: false, failure: failure),
            ),
          },
          onError: (Object _) => emit(
            const LeaveBalancesState(
              loading: false,
              failure: Failure(code: 'leaveStorageError'),
            ),
          ),
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

class LeaveBalancesState {
  const LeaveBalancesState({
    this.loading = true,
    this.balances = const [],
    this.failure,
  });
  final bool loading;
  final List<LeaveBalanceSummary> balances;
  final Failure? failure;
}

// ---- calendar --------------------------------------------------------------

class LeaveCalendarCubit extends Cubit<LeaveCalendarState> {
  LeaveCalendarCubit(this.repository, this.context)
    : super(const LeaveCalendarState(from: null, to: null));
  final LeaveRepository repository;
  final AuthContext context;

  static DateTime _monthStart(DateTime d) => DateTime.utc(d.year, d.month, 1);
  static DateTime _monthEnd(DateTime d) => DateTime.utc(d.year, d.month + 1, 0);

  DateTime get _companyToday => repository.companyToday(context);

  Future<void> load({DateTime? from, DateTime? to}) async {
    final anchor = _companyToday;
    final range = (
      from: from ?? _monthStart(state.from ?? anchor),
      to: to ?? _monthEnd(state.to ?? anchor),
    );
    emit(LeaveCalendarState(from: range.from, to: range.to, loading: true));
    final result = await repository.calendar(context, range.from, range.to);
    switch (result) {
      case Success<List<LeaveCalendarEntry>>(:final value):
        emit(
          LeaveCalendarState(
            from: range.from,
            to: range.to,
            loading: false,
            entries: value,
          ),
        );
      case Failed<List<LeaveCalendarEntry>>(:final failure):
        emit(
          LeaveCalendarState(
            from: range.from,
            to: range.to,
            loading: false,
            failure: failure,
          ),
        );
    }
  }
}

class LeaveCalendarState {
  const LeaveCalendarState({
    required this.from,
    required this.to,
    this.loading = true,
    this.entries = const [],
    this.failure,
  });
  final DateTime? from, to;
  final bool loading;
  final List<LeaveCalendarEntry> entries;
  final Failure? failure;
}

// ---- employee leave home ---------------------------------------------------

class LeaveHomeState {
  const LeaveHomeState({
    this.loading = true,
    this.balances = const [],
    this.requests = const [],
    this.nextHoliday,
    this.failure,
  });
  final bool loading;
  final List<LeaveBalanceSummary> balances;
  final List<LeaveRequestRow> requests;
  final Holiday? nextHoliday;
  final Failure? failure;
}

/// Aggregates the employee's balances, requests and next holiday for the My
/// Leave home. All dates come from the repository (company time).
class LeaveHomeCubit extends Cubit<LeaveHomeState> {
  LeaveHomeCubit(this.repository, this.context, this.employeeId)
    : super(const LeaveHomeState()) {
    load();
  }
  final LeaveRepository repository;
  final AuthContext context;
  final String employeeId;
  StreamSubscription<Result<List<LeaveBalanceSummary>>>? _balances;
  StreamSubscription<Result<List<LeaveRequestRow>>>? _requests;

  Future<void> load() async {
    emit(const LeaveHomeState());
    await _balances?.cancel();
    await _requests?.cancel();
    _balances = repository
        .watchBalances(context, employeeId)
        .listen(
          (result) => _emit(
            balances: result is Success<List<LeaveBalanceSummary>>
                ? result.value
                : null,
            failure: result is Failed<List<LeaveBalanceSummary>>
                ? result.failure
                : null,
          ),
          onError: (Object _) {},
        );
    _requests = repository
        .watchRequests(context, scope: LeaveRequestScope.self)
        .listen(
          (result) => _emit(
            requests: result is Success<List<LeaveRequestRow>>
                ? result.value
                : null,
            failure: result is Failed<List<LeaveRequestRow>>
                ? result.failure
                : null,
          ),
          onError: (Object _) {},
        );
    final holiday = await repository.nextHoliday(
      context,
      employeeId,
      repository.companyToday(context),
    );
    if (holiday is Success<Holiday?>) {
      emit(
        LeaveHomeState(
          loading: false,
          balances: state.balances,
          requests: state.requests,
          nextHoliday: holiday.value,
        ),
      );
    }
  }

  void _emit({
    List<LeaveBalanceSummary>? balances,
    List<LeaveRequestRow>? requests,
    Failure? failure,
  }) => emit(
    LeaveHomeState(
      loading: false,
      balances: balances ?? state.balances,
      requests: requests ?? state.requests,
      nextHoliday: state.nextHoliday,
      failure: failure,
    ),
  );

  @override
  Future<void> close() async {
    await _balances?.cancel();
    await _requests?.cancel();
    return super.close();
  }
}
