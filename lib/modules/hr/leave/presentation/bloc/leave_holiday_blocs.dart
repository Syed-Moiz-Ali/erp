import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/platform/auth/domain/entities/auth_context.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_models.dart';
import 'package:modular_erp/modules/hr/leave/domain/leave_repository.dart';

class HolidayManagementState {
  const HolidayManagementState({
    required this.year,
    this.loading = true,
    this.holidays = const [],
    this.calendars = const [],
    this.failure,
  });
  final int year;
  final bool loading;
  final List<Holiday> holidays;
  final List<HolidayCalendar> calendars;
  final Failure? failure;
}

/// Year-aware Holiday administration. All business dates and the default year
/// come from the repository (company time), never the device clock.
class HolidayManagementCubit extends Cubit<HolidayManagementState> {
  HolidayManagementCubit(this.repository, this.context, {int? year})
    : super(
        HolidayManagementState(
          year:
              year ?? repository.leaveYearFor(repository.companyToday(context)),
        ),
      ) {
    load();
  }
  final LeaveRepository repository;
  final AuthContext context;
  StreamSubscription<Result<List<Holiday>>>? _holidays;
  StreamSubscription<Result<List<HolidayCalendar>>>? _calendars;

  Future<void> load() async {
    emit(
      HolidayManagementState(
        year: state.year,
        loading: true,
        holidays: state.holidays,
        calendars: state.calendars,
      ),
    );
    await _holidays?.cancel();
    await _calendars?.cancel();
    _holidays = repository
        .watchHolidaysForYear(context, state.year, includeInactive: true)
        .listen(
          (result) => emit(_withResult(result)),
          onError: (Object _) => emit(
            HolidayManagementState(
              year: state.year,
              loading: false,
              holidays: state.holidays,
              calendars: state.calendars,
              failure: const Failure(code: 'leaveStorageError'),
            ),
          ),
        );
    _calendars = repository.watchHolidayCalendars(context).listen((result) {
      if (result is Success<List<HolidayCalendar>>) {
        emit(
          HolidayManagementState(
            year: state.year,
            loading: state.loading,
            holidays: state.holidays,
            calendars: result.value,
            failure: state.failure,
          ),
        );
      }
    }, onError: (Object _) {});
  }

  HolidayManagementState _withResult(Result<List<Holiday>> result) =>
      switch (result) {
        Success<List<Holiday>>(:final value) => HolidayManagementState(
          year: state.year,
          loading: false,
          holidays: value,
          calendars: state.calendars,
        ),
        Failed<List<Holiday>>(:final failure) => HolidayManagementState(
          year: state.year,
          loading: false,
          holidays: state.holidays,
          calendars: state.calendars,
          failure: failure,
        ),
      };

  Future<void> setYear(int year) async {
    emit(
      HolidayManagementState(
        year: year,
        loading: true,
        holidays: const [],
        calendars: state.calendars,
      ),
    );
    await load();
  }

  Future<Result<int>> copyPreviousYear() => repository.copyHolidaysToYear(
    context,
    fromYear: state.year - 1,
    toYear: state.year,
  );

  Future<Result<void>> setStatus(String id, bool active) async {
    final result = await repository.setHolidayStatus(context, id, active);
    return result;
  }

  Future<Result<HolidayImportResult>> import(List<HolidayImportRow> rows) =>
      repository.importHolidays(context, rows);

  List<HolidayCalendar> calendarsForYear(int year) =>
      state.calendars.where((c) => c.year == year).toList();

  bool get yearConfigured => calendarsForYear(state.year).isNotEmpty;

  @override
  Future<void> close() async {
    await _holidays?.cancel();
    await _calendars?.cancel();
    return super.close();
  }
}
