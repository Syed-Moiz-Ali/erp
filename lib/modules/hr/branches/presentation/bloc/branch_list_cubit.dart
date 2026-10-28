import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch.dart';
import 'package:modular_erp/modules/hr/branches/domain/branch_repository.dart';

class BranchListState {
  const BranchListState({
    this.loading = true,
    this.busy = false,
    this.failure,
    this.items = const [],
    this.lookups,
    this.search = '',
    this.status,
    this.page = 1,
    this.pageSize = 25,
    this.totalItems = 0,
    this.totalPages = 0,
  });
  final bool loading, busy;
  final Failure? failure;
  final List<Branch> items;
  final BranchLookups? lookups;
  final String search;
  final String? status;
  final int page, pageSize, totalItems, totalPages;

  BranchListState copyWith({
    bool? loading,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
    List<Branch>? items,
    BranchLookups? lookups,
    String? search,
    String? status,
    bool clearStatus = false,
    int? page,
    int? totalItems,
    int? totalPages,
  }) => BranchListState(
    loading: loading ?? this.loading,
    busy: busy ?? this.busy,
    failure: clearFailure ? null : (failure ?? this.failure),
    items: items ?? this.items,
    lookups: lookups ?? this.lookups,
    search: search ?? this.search,
    status: clearStatus ? null : (status ?? this.status),
    page: page ?? this.page,
    pageSize: pageSize,
    totalItems: totalItems ?? this.totalItems,
    totalPages: totalPages ?? this.totalPages,
  );
}

class BranchListCubit extends Cubit<BranchListState> {
  BranchListCubit(this.repository) : super(const BranchListState());
  final BranchRepository repository;
  Timer? _debounce;

  Future<void> start() async {
    final lookups = await repository.lookups();
    if (lookups is Success<BranchLookups>) {
      emit(state.copyWith(lookups: lookups.value));
    }
    await load();
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearFailure: true));
    final result = await repository.list(
      search: state.search,
      status: state.status,
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

  void statusChanged(String? status) {
    emit(state.copyWith(status: status, clearStatus: status == null, page: 1));
    unawaited(load());
  }

  void pageChanged(int page) {
    emit(state.copyWith(page: page));
    unawaited(load());
  }

  Future<Failure?> save(int? id, BranchDraft draft) async {
    emit(state.copyWith(busy: true, clearFailure: true));
    final result = id == null
        ? await repository.create(draft)
        : await repository.update(id, draft);
    if (result is Failed<Branch>) {
      emit(state.copyWith(busy: false, failure: result.failure));
      return result.failure;
    }
    emit(state.copyWith(busy: false));
    await load();
    return null;
  }

  Future<Failure?> toggle(Branch branch) async {
    emit(state.copyWith(busy: true, clearFailure: true));
    final result = await repository.setActive(branch.id, !branch.isActive);
    if (result is Failed<Branch>) {
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
