import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employees/live/domain/live_employee.dart';
import 'package:modular_erp/modules/hr/employees/live/domain/live_employee_repository.dart';

class LiveEmployeeState {
  const LiveEmployeeState({
    this.loading = true,
    this.busy = false,
    this.failure,
    this.items = const [],
    this.lookups,
    this.search = '',
    this.statusId,
    this.page = 1,
    this.pageSize = 25,
    this.totalItems = 0,
    this.totalPages = 0,
  });
  final bool loading, busy;
  final Failure? failure;
  final List<LiveEmployee> items;
  final LiveEmployeeLookups? lookups;
  final String search;
  final int? statusId;
  final int page, pageSize, totalItems, totalPages;

  LiveEmployeeState copyWith({
    bool? loading,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
    List<LiveEmployee>? items,
    LiveEmployeeLookups? lookups,
    String? search,
    int? statusId,
    bool clearStatus = false,
    int? page,
    int? totalItems,
    int? totalPages,
  }) => LiveEmployeeState(
    loading: loading ?? this.loading,
    busy: busy ?? this.busy,
    failure: clearFailure ? null : (failure ?? this.failure),
    items: items ?? this.items,
    lookups: lookups ?? this.lookups,
    search: search ?? this.search,
    statusId: clearStatus ? null : (statusId ?? this.statusId),
    page: page ?? this.page,
    pageSize: pageSize,
    totalItems: totalItems ?? this.totalItems,
    totalPages: totalPages ?? this.totalPages,
  );
}

class LiveEmployeeCubit extends Cubit<LiveEmployeeState> {
  LiveEmployeeCubit(this.repository) : super(const LiveEmployeeState());
  final LiveEmployeeRepository repository;
  Timer? _debounce;

  Future<void> start() async {
    final lookups = await repository.lookups();
    if (lookups is Success<LiveEmployeeLookups>) {
      emit(state.copyWith(lookups: lookups.value));
    }
    await load();
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearFailure: true));
    final result = await repository.list(
      search: state.search,
      statusId: state.statusId,
      page: state.page,
      pageSize: state.pageSize,
    );
    if (isClosed) return;
    switch (result) {
      case Success(:final value):
        emit(
          state.copyWith(
            loading: false,
            items: value.items,
            totalItems: value.totalItems,
            totalPages: value.totalPages,
          ),
        );
      case Failed(:final failure):
        emit(state.copyWith(loading: false, failure: failure));
    }
  }

  void searchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (isClosed) return;
      emit(state.copyWith(search: value.trim(), page: 1));
      unawaited(load());
    });
  }

  void statusChanged(int? statusId) {
    emit(
      state.copyWith(
        statusId: statusId,
        clearStatus: statusId == null,
        page: 1,
      ),
    );
    unawaited(load());
  }

  void pageChanged(int page) {
    emit(state.copyWith(page: page));
    unawaited(load());
  }

  Future<Failure?> save(
    LiveEmployee? current,
    LiveEmployeeDraft draft,
  ) async {
    emit(state.copyWith(busy: true, clearFailure: true));
    final result = current == null
        ? await repository.create(draft)
        : await repository.update(current, draft);
    if (result is Failed<LiveEmployee>) {
      emit(state.copyWith(busy: false, failure: result.failure));
      return result.failure;
    }
    emit(state.copyWith(busy: false));
    await load();
    return null;
  }

  Future<Failure?> toggle(LiveEmployee employee) async {
    emit(state.copyWith(busy: true, clearFailure: true));
    final result = await repository.setActive(employee.id, !employee.isActive);
    if (result is Failed<LiveEmployee>) {
      emit(state.copyWith(busy: false, failure: result.failure));
      return result.failure;
    }
    emit(state.copyWith(busy: false));
    await load();
    return null;
  }

  @override
  Future<void> close() async {
    _debounce?.cancel();
    return super.close();
  }
}
