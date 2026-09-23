import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/auth_context.dart';

import '../../domain/leave_models.dart';
import '../../domain/leave_repository.dart';

// ---- operations (team / company) ------------------------------------------

sealed class LeaveOperationsEvent {
  const LeaveOperationsEvent();
}

class LeaveOperationsStarted extends LeaveOperationsEvent {
  const LeaveOperationsStarted();
}

class LeaveOperationsFilterChanged extends LeaveOperationsEvent {
  const LeaveOperationsFilterChanged(this.filter);
  final LeaveRequestFilter filter;
}

class _LeaveOperationsReceived extends LeaveOperationsEvent {
  const _LeaveOperationsReceived(this.result);
  final Result<LeaveOperationsData> result;
}

class LeaveOperationsState {
  const LeaveOperationsState({
    this.loading = true,
    this.data,
    this.failure,
    this.filter = const LeaveRequestFilter(),
  });
  final bool loading;
  final LeaveOperationsData? data;
  final Failure? failure;
  final LeaveRequestFilter filter;
}

class LeaveOperationsBloc
    extends Bloc<LeaveOperationsEvent, LeaveOperationsState> {
  LeaveOperationsBloc(this.repository, this.context, this.scope)
    : super(const LeaveOperationsState()) {
    on<LeaveOperationsEvent>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
  final LeaveRepository repository;
  final AuthContext context;
  final LeaveRequestScope scope;
  StreamSubscription<Result<LeaveOperationsData>>? _subscription;

  Future<void> _watch(LeaveRequestFilter filter) async {
    await _subscription?.cancel();
    _subscription = repository
        .watchOperations(context, scope: scope, filter: filter)
        .listen(
          (r) => add(_LeaveOperationsReceived(r)),
          onError: (Object _) => add(
            const _LeaveOperationsReceived(
              Failed(Failure(code: 'leaveStorageError')),
            ),
          ),
        );
  }

  Future<void> _handle(
    LeaveOperationsEvent event,
    Emitter<LeaveOperationsState> emit,
  ) async {
    switch (event) {
      case LeaveOperationsStarted():
        emit(LeaveOperationsState(filter: state.filter));
        await _watch(state.filter);
      case LeaveOperationsFilterChanged(:final filter):
        emit(LeaveOperationsState(filter: filter));
        await _watch(filter);
      case _LeaveOperationsReceived(:final result):
        switch (result) {
          case Success<LeaveOperationsData>(:final value):
            emit(
              LeaveOperationsState(
                loading: false,
                data: value,
                filter: state.filter,
              ),
            );
          case Failed<LeaveOperationsData>(:final failure):
            emit(
              LeaveOperationsState(
                loading: false,
                failure: failure,
                filter: state.filter,
              ),
            );
        }
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

// ---- approval queue --------------------------------------------------------

sealed class LeaveApprovalsEvent {
  const LeaveApprovalsEvent();
}

class LeaveApprovalsStarted extends LeaveApprovalsEvent {
  const LeaveApprovalsStarted();
}

class _LeaveApprovalsReceived extends LeaveApprovalsEvent {
  const _LeaveApprovalsReceived(this.result);
  final Result<List<LeaveApprovalItem>> result;
}

class LeaveApprovalsState {
  const LeaveApprovalsState({
    this.loading = true,
    this.items = const [],
    this.failure,
  });
  final bool loading;
  final List<LeaveApprovalItem> items;
  final Failure? failure;
}

class LeaveApprovalsBloc
    extends Bloc<LeaveApprovalsEvent, LeaveApprovalsState> {
  LeaveApprovalsBloc(this.repository, this.context)
    : super(const LeaveApprovalsState()) {
    on<LeaveApprovalsEvent>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
  final LeaveRepository repository;
  final AuthContext context;
  StreamSubscription<Result<List<LeaveApprovalItem>>>? _subscription;

  Future<void> _handle(
    LeaveApprovalsEvent event,
    Emitter<LeaveApprovalsState> emit,
  ) async {
    switch (event) {
      case LeaveApprovalsStarted():
        emit(const LeaveApprovalsState());
        await _subscription?.cancel();
        _subscription = repository
            .watchApprovalQueue(context)
            .listen(
              (r) => add(_LeaveApprovalsReceived(r)),
              onError: (Object _) => add(
                const _LeaveApprovalsReceived(
                  Failed(Failure(code: 'leaveStorageError')),
                ),
              ),
            );
      case _LeaveApprovalsReceived(:final result):
        switch (result) {
          case Success<List<LeaveApprovalItem>>(:final value):
            emit(LeaveApprovalsState(loading: false, items: value));
          case Failed<List<LeaveApprovalItem>>(:final failure):
            emit(LeaveApprovalsState(loading: false, failure: failure));
        }
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

// ---- employee leave profile ------------------------------------------------

sealed class EmployeeLeaveEvent {
  const EmployeeLeaveEvent();
}

class EmployeeLeaveStarted extends EmployeeLeaveEvent {
  const EmployeeLeaveStarted();
}

class _EmployeeLeaveReceived extends EmployeeLeaveEvent {
  const _EmployeeLeaveReceived(this.result);
  final Result<EmployeeLeaveSummary?> result;
}

class EmployeeLeaveState {
  const EmployeeLeaveState({this.loading = true, this.summary, this.failure});
  final bool loading;
  final EmployeeLeaveSummary? summary;
  final Failure? failure;
}

class EmployeeLeaveBloc extends Bloc<EmployeeLeaveEvent, EmployeeLeaveState> {
  EmployeeLeaveBloc(this.repository, this.context, this.employeeId)
    : super(const EmployeeLeaveState()) {
    on<EmployeeLeaveEvent>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
  final LeaveRepository repository;
  final AuthContext context;
  final String employeeId;
  StreamSubscription<Result<EmployeeLeaveSummary?>>? _subscription;

  Future<void> _handle(
    EmployeeLeaveEvent event,
    Emitter<EmployeeLeaveState> emit,
  ) async {
    switch (event) {
      case EmployeeLeaveStarted():
        emit(const EmployeeLeaveState());
        await _subscription?.cancel();
        _subscription = repository
            .watchEmployeeLeave(context, employeeId)
            .listen(
              (r) => add(_EmployeeLeaveReceived(r)),
              onError: (Object _) => add(
                const _EmployeeLeaveReceived(
                  Failed(Failure(code: 'leaveStorageError')),
                ),
              ),
            );
      case _EmployeeLeaveReceived(:final result):
        switch (result) {
          case Success<EmployeeLeaveSummary?>(:final value):
            emit(EmployeeLeaveState(loading: false, summary: value));
          case Failed<EmployeeLeaveSummary?>(:final failure):
            emit(EmployeeLeaveState(loading: false, failure: failure));
        }
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

// ---- balance table ---------------------------------------------------------

sealed class LeaveBalanceTableEvent {
  const LeaveBalanceTableEvent();
}

class LeaveBalanceTableStarted extends LeaveBalanceTableEvent {
  const LeaveBalanceTableStarted();
}

class LeaveBalanceTableFilterChanged extends LeaveBalanceTableEvent {
  const LeaveBalanceTableFilterChanged({
    this.departmentId,
    this.leaveTypeId,
    this.search = '',
    this.year,
  });
  final String? departmentId, leaveTypeId;
  final String search;
  final int? year;
}

class _LeaveBalanceTableReceived extends LeaveBalanceTableEvent {
  const _LeaveBalanceTableReceived(this.result);
  final Result<List<LeaveBalanceRow>> result;
}

class LeaveBalanceTableState {
  const LeaveBalanceTableState({
    this.loading = true,
    this.rows = const [],
    this.failure,
    this.departmentId,
    this.leaveTypeId,
    this.search = '',
    this.year,
  });
  final bool loading;
  final List<LeaveBalanceRow> rows;
  final Failure? failure;
  final String? departmentId, leaveTypeId;
  final String search;
  final int? year;
}

class LeaveBalanceTableBloc
    extends Bloc<LeaveBalanceTableEvent, LeaveBalanceTableState> {
  LeaveBalanceTableBloc(this.repository, this.context)
    : super(const LeaveBalanceTableState()) {
    on<LeaveBalanceTableEvent>(
      _handle,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
  final LeaveRepository repository;
  final AuthContext context;
  StreamSubscription<Result<List<LeaveBalanceRow>>>? _subscription;

  Future<void> _watch(LeaveBalanceTableState state) async {
    await _subscription?.cancel();
    _subscription = repository
        .watchBalanceTable(
          context,
          year: state.year,
          departmentId: state.departmentId,
          leaveTypeId: state.leaveTypeId,
          search: state.search,
        )
        .listen(
          (r) => add(_LeaveBalanceTableReceived(r)),
          onError: (Object _) => add(
            const _LeaveBalanceTableReceived(
              Failed(Failure(code: 'leaveStorageError')),
            ),
          ),
        );
  }

  Future<void> _handle(
    LeaveBalanceTableEvent event,
    Emitter<LeaveBalanceTableState> emit,
  ) async {
    switch (event) {
      case LeaveBalanceTableStarted():
        emit(LeaveBalanceTableState(year: state.year));
        await _watch(state);
      case LeaveBalanceTableFilterChanged(
        :final departmentId,
        :final leaveTypeId,
        :final search,
        :final year,
      ):
        final next = LeaveBalanceTableState(
          year: year ?? state.year,
          departmentId: departmentId,
          leaveTypeId: leaveTypeId,
          search: search,
        );
        emit(next);
        await _watch(next);
      case _LeaveBalanceTableReceived(:final result):
        switch (result) {
          case Success<List<LeaveBalanceRow>>(:final value):
            emit(
              LeaveBalanceTableState(
                loading: false,
                rows: value,
                year: state.year,
                departmentId: state.departmentId,
                leaveTypeId: state.leaveTypeId,
                search: state.search,
              ),
            );
          case Failed<List<LeaveBalanceRow>>(:final failure):
            emit(
              LeaveBalanceTableState(
                loading: false,
                failure: failure,
                year: state.year,
                departmentId: state.departmentId,
                leaveTypeId: state.leaveTypeId,
                search: state.search,
              ),
            );
        }
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
