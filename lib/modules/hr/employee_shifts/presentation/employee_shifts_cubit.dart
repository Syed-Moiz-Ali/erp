import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/employee_shifts/data/employee_shift_api.dart';
import 'package:modular_erp/modules/hr/employee_shifts/domain/employee_shift.dart';

class EmployeeShiftsState {
  const EmployeeShiftsState({
    this.loading = true,
    this.busy = false,
    this.failure,
    this.page,
    this.items = const [],
  });
  final bool loading, busy;
  final Failure? failure;
  final EmployeeShiftPage? page;
  final List<EmployeeShift> items;
}

class EmployeeShiftsCubit extends Cubit<EmployeeShiftsState> {
  EmployeeShiftsCubit(this.api) : super(const EmployeeShiftsState());
  final EmployeeShiftApi api;

  Future<void> load() async {
    emit(const EmployeeShiftsState());
    final result = await api.list(includeInactive: true);
    if (isClosed) return;
    switch (result) {
      case Success(:final value):
        emit(
          EmployeeShiftsState(loading: false, page: value, items: value.items),
        );
      case Failed(:final failure):
        emit(EmployeeShiftsState(loading: false, failure: failure));
    }
  }

  Future<Failure?> create(EmployeeShiftDraft draft) async {
    emit(EmployeeShiftsState(loading: false, items: state.items, busy: true));
    final result = await api.create(draft);
    if (result is Failed<EmployeeShift>) {
      emit(
        EmployeeShiftsState(
          loading: false,
          items: state.items,
          failure: result.failure,
        ),
      );
      return result.failure;
    }
    await load();
    return null;
  }

  Future<Failure?> update(int id, EmployeeShiftDraft draft) async {
    final result = await api.update(id, draft);
    if (result is Failed<EmployeeShift>) return result.failure;
    await load();
    return null;
  }

  Future<Failure?> deactivate(int id) async {
    final result = await api.deactivate(id);
    if (result is Failed<EmployeeShift>) return result.failure;
    await load();
    return null;
  }
}
