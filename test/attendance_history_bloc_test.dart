import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/features/attendance/domain/attendance_history.dart';
import 'package:modular_erp/features/attendance/domain/attendance_repository.dart';
import 'package:modular_erp/features/attendance/presentation/bloc/attendance_history_bloc.dart';
import 'package:modular_erp/features/attendance/presentation/bloc/attendance_day_details_bloc.dart';
import 'attendance_history_test.dart' show record;

class MockHistoryRepository extends Mock implements AttendanceRepository {}

AttendanceHistoryPageData data(
  AttendanceHistoryQuery q, {
  bool empty = false,
}) => AttendanceHistoryPageData(
  q,
  empty
      ? []
      : [AttendanceHistoryItem.fromDay(record(1), DateTime.utc(2026, 9, 17))],
  empty ? 0 : 1,
  AttendanceMonthSummary(
    counts: {
      for (final s in AttendanceHistoryStatus.values)
        s: s == AttendanceHistoryStatus.present && !empty ? 1 : 0,
    },
    work: empty ? Duration.zero : const Duration(hours: 8),
    breaks: Duration.zero,
    completed: empty ? 0 : 1,
  ),
  DateTime.utc(2026, 9, 17),
);
Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 20));
void main() {
  setUpAll(
    () => registerFallbackValue(AttendanceHistoryQuery(year: 2026, month: 9)),
  );
  late MockHistoryRepository repo;
  setUp(() {
    repo = MockHistoryRepository();
    when(
      () => repo.getCompanyAttendanceDate(),
    ).thenAnswer((_) async => Success(DateTime.utc(2026, 9, 17)));
  });
  test('initial company date failure is typed and stops loading', () async {
    when(
      () => repo.getCompanyAttendanceDate(),
    ).thenAnswer((_) async => const Failed(Failure(code: 'accountInactive')));
    final bloc = AttendanceHistoryBloc(repo);
    final ready = bloc.stream.firstWhere((s) => !s.loading);
    bloc.add(const AttendanceHistoryStarted());
    await ready;
    expect(bloc.state.failure!.code, 'accountInactive');
    expect(bloc.state.data, null);
    await bloc.close();
  });
  test(
    'empty month and filtered empty retain distinct month summary',
    () async {
      when(() => repo.watchAttendanceHistory(any())).thenAnswer((i) {
        final q = i.positionalArguments.first as AttendanceHistoryQuery;
        final result = data(q, empty: true);
        return Stream.value(
          Success(
            q.statuses.isEmpty
                ? result
                : AttendanceHistoryPageData(
                    q,
                    [],
                    0,
                    data(q).summary,
                    result.asOf,
                  ),
          ),
        );
      });
      final bloc = AttendanceHistoryBloc(repo);
      var ready = bloc.stream.firstWhere((s) => !s.loading);
      bloc.add(const AttendanceHistoryStarted());
      await ready;
      expect(bloc.state.data!.summary.records, 0);
      ready = bloc.stream.firstWhere((s) => !s.loading);
      bloc.add(AttendanceHistoryFilterChanged({AttendanceHistoryStatus.late}));
      await ready;
      expect(bloc.state.data!.total, 0);
      expect(bloc.state.data!.summary.records, 1);
      expect(bloc.state.query!.page, 0);
      await bloc.close();
    },
  );
  test(
    'refresh failure preserves cached content; permission failure clears it',
    () async {
      final controller =
          StreamController<Result<AttendanceHistoryPageData>>.broadcast();
      when(
        () => repo.watchAttendanceHistory(any()),
      ).thenAnswer((_) => controller.stream);
      final bloc = AttendanceHistoryBloc(repo);
      bloc.add(const AttendanceHistoryStarted());
      await tick();
      var ready = bloc.stream.firstWhere((s) => !s.loading);
      controller.add(Success(data(bloc.state.query!)));
      await ready;
      final cached = bloc.state.data;
      bloc.add(const AttendanceHistoryRefreshRequested());
      await tick();
      expect(bloc.state.data, same(cached));
      ready = bloc.stream.firstWhere((s) => !s.loading);
      controller.add(
        const Failed(Failure(code: 'historyRead', retryable: true)),
      );
      await ready;
      expect(bloc.state.data, same(cached));
      ready = bloc.stream.firstWhere((s) => !s.loading && s.data == null);
      controller.add(const Failed(Failure(code: 'permissionDenied')));
      await ready;
      expect(bloc.state.data, null);
      await bloc.close();
      await controller.close();
    },
  );
  test(
    'changing month cancels stale watch results and resets pagination',
    () async {
      final streams =
          <int, StreamController<Result<AttendanceHistoryPageData>>>{};
      when(() => repo.watchAttendanceHistory(any())).thenAnswer((i) {
        final q = i.positionalArguments.first as AttendanceHistoryQuery;
        return (streams[q.month] ??= StreamController.broadcast()).stream;
      });
      final bloc = AttendanceHistoryBloc(repo);
      bloc.add(const AttendanceHistoryStarted());
      await tick();
      var ready = bloc.stream.firstWhere((s) => !s.loading);
      streams[9]!.add(Success(data(bloc.state.query!)));
      await ready;
      bloc.add(AttendanceHistoryMonthChanged(DateTime.utc(2026, 8)));
      await tick();
      streams[9]!.add(
        Success(data(AttendanceHistoryQuery(year: 2026, month: 9))),
      );
      ready = bloc.stream.firstWhere((s) => !s.loading);
      streams[8]!.add(Success(data(bloc.state.query!, empty: true)));
      await ready;
      expect(bloc.state.data!.query.month, 8);
      await bloc.close();
      for (final c in streams.values) {
        await c.close();
      }
    },
  );
  test('details refresh keeps cached record on local read failure', () async {
    final details = AttendanceDayDetails(
      record(1),
      [],
      DateTime.utc(2026, 9, 17),
    );
    when(
      () => repo.watchAttendanceDayById('day'),
    ).thenAnswer((_) => Stream.value(Success(details)));
    when(() => repo.getAttendanceDayById('day')).thenAnswer(
      (_) async => const Failed(Failure(code: 'historyRead', retryable: true)),
    );
    final bloc = AttendanceDayDetailsBloc(repo, 'day');
    var ready = bloc.stream.firstWhere((s) => !s.loading);
    bloc.add(const AttendanceDayDetailsStarted());
    await ready;
    ready = bloc.stream.firstWhere((s) => !s.loading && s.failure != null);
    bloc.add(const AttendanceDayDetailsRefreshRequested());
    await ready;
    expect(bloc.state.data, same(details));
    await bloc.close();
  });
}
