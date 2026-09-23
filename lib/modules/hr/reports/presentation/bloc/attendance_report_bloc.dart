import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/modules/hr/attendance/domain/workforce_attendance.dart';
import 'package:modular_erp/modules/hr/reports/data/attendance_report_export_service.dart';
import 'package:modular_erp/modules/hr/reports/domain/attendance_report_models.dart';
import 'package:modular_erp/modules/hr/reports/domain/attendance_report_repository.dart';

sealed class AttendanceReportEvent {
  const AttendanceReportEvent();
}

final class AttendanceReportStarted extends AttendanceReportEvent {
  const AttendanceReportStarted();
}

final class AttendanceReportTypeChanged extends AttendanceReportEvent {
  const AttendanceReportTypeChanged(this.type);
  final AttendanceReportType type;
}

final class AttendanceReportFilterChanged extends AttendanceReportEvent {
  const AttendanceReportFilterChanged(this.filter);
  final AttendanceReportFilter filter;
}

final class AttendanceReportSortChanged extends AttendanceReportEvent {
  const AttendanceReportSortChanged(this.sort);
  final AttendanceReportSort sort;
}

final class AttendanceReportSettingsChanged extends AttendanceReportEvent {
  const AttendanceReportSettingsChanged(this.filter, this.sort);
  final AttendanceReportFilter filter;
  final AttendanceReportSort sort;
}

final class AttendanceReportPageChanged extends AttendanceReportEvent {
  const AttendanceReportPageChanged(this.page);
  final int page;
}

final class AttendanceReportRefreshRequested extends AttendanceReportEvent {
  const AttendanceReportRefreshRequested();
}

final class AttendanceReportExportRequested extends AttendanceReportEvent {
  const AttendanceReportExportRequested({
    required this.format,
    required this.locale,
    required this.companyName,
  });
  final ReportExportFormat format;
  final Locale locale;
  final String companyName;
}

class AttendanceReportState {
  const AttendanceReportState({
    this.type = AttendanceReportType.overview,
    this.filter,
    this.today,
    this.sort = AttendanceReportSort.newest,
    this.page = 0,
    this.pageSize = 25,
    this.data,
    this.options,
    this.loading = false,
    this.refreshing = false,
    this.exporting = false,
    this.exported = false,
    this.failure,
    this.exportFailure,
  });
  final AttendanceReportType type;
  final AttendanceReportFilter? filter;
  final DateTime? today;
  final AttendanceReportSort sort;
  final int page, pageSize;
  final AttendanceReportData? data;
  final AttendanceReportOptions? options;
  final bool loading, refreshing, exporting, exported;
  final Failure? failure, exportFailure;
}

class AttendanceReportBloc
    extends Bloc<AttendanceReportEvent, AttendanceReportState> {
  AttendanceReportBloc(this.repository, this.exportService, this.scope)
    : super(const AttendanceReportState()) {
    on<AttendanceReportStarted>((event, emit) async {
      final today = await repository.companyToday();
      if (today is Failed<DateTime>) {
        emit(AttendanceReportState(failure: today.failure));
        return;
      }
      final day = (today as Success<DateTime>).value;
      await _load(
        emit,
        today: day,
        filter: AttendanceReportFilter.preset(
          AttendanceReportPeriod.thisMonth,
          day,
          scope,
        ),
      );
    });
    on<AttendanceReportTypeChanged>(
      (e, emit) => _load(emit, type: e.type, page: 0),
    );
    on<AttendanceReportFilterChanged>(
      (e, emit) => _load(emit, filter: e.filter, page: 0),
    );
    on<AttendanceReportSortChanged>(
      (e, emit) => _load(emit, sort: e.sort, page: 0),
    );
    on<AttendanceReportSettingsChanged>(
      (e, emit) => _load(emit, filter: e.filter, sort: e.sort, page: 0),
    );
    on<AttendanceReportPageChanged>((e, emit) => _load(emit, page: e.page));
    on<AttendanceReportRefreshRequested>((e, emit) => _load(emit));
    on<AttendanceReportExportRequested>(_export);
  }
  final AttendanceReportRepository repository;
  final AttendanceReportExportService exportService;
  final AttendanceScope scope;
  int _ticket = 0;

  Future<void> _load(
    Emitter<AttendanceReportState> emit, {
    AttendanceReportType? type,
    AttendanceReportFilter? filter,
    AttendanceReportSort? sort,
    int? page,
    DateTime? today,
  }) async {
    final activeFilter = filter ?? state.filter;
    if (activeFilter == null) return;
    final activeType = type ?? state.type;
    final activeSort = sort ?? state.sort;
    final activePage = page ?? state.page;
    final previous = state.data;
    final ticket = ++_ticket;
    emit(
      AttendanceReportState(
        type: activeType,
        filter: activeFilter,
        today: today ?? state.today,
        sort: activeSort,
        page: activePage,
        pageSize: state.pageSize,
        data: previous,
        options: state.options,
        loading: previous == null,
        refreshing: previous != null,
      ),
    );
    final results = await Future.wait<Object>([
      repository.load(
        activeFilter,
        activeType,
        sort: activeSort,
        page: activePage,
        pageSize: state.pageSize,
      ),
      repository.options(activeFilter),
    ]);
    if (emit.isDone || ticket != _ticket) return;
    final data = results[0] as Result<AttendanceReportData>;
    final options = results[1] as Result<AttendanceReportOptions>;
    emit(
      AttendanceReportState(
        type: activeType,
        filter: activeFilter,
        today: today ?? state.today,
        sort: activeSort,
        page: activePage,
        pageSize: state.pageSize,
        data: data is Success<AttendanceReportData> ? data.value : previous,
        options: options is Success<AttendanceReportOptions>
            ? options.value
            : state.options,
        failure: data is Failed<AttendanceReportData> ? data.failure : null,
      ),
    );
  }

  Future<void> _export(
    AttendanceReportExportRequested e,
    Emitter<AttendanceReportState> emit,
  ) async {
    final filter = state.filter;
    if (filter == null || state.exporting) return;
    emit(_withExport(exporting: true));
    final result = await exportService.export(
      ReportExportRequest(
        type: state.type,
        filter: filter,
        sort: state.sort,
        format: e.format,
        locale: e.locale,
        companyName: e.companyName,
        generatedAt: DateTime.now(),
      ),
    );
    if (emit.isDone) return;
    emit(
      _withExport(
        exported: result is Success<ReportExportResult>,
        failure: result is Failed<ReportExportResult> ? result.failure : null,
      ),
    );
  }

  AttendanceReportState _withExport({
    bool exporting = false,
    bool exported = false,
    Failure? failure,
  }) => AttendanceReportState(
    type: state.type,
    filter: state.filter,
    today: state.today,
    sort: state.sort,
    page: state.page,
    pageSize: state.pageSize,
    data: state.data,
    options: state.options,
    exporting: exporting,
    exported: exported,
    exportFailure: failure,
  );
}
