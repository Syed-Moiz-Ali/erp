import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/app/router/app_routes.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/features/attendance/data/attendance_local_data_source.dart';
import 'package:modular_erp/features/attendance/domain/attendance_history.dart';
import 'package:modular_erp/features/attendance/domain/attendance_models.dart';
import 'package:modular_erp/features/attendance/presentation/bloc/attendance_history_bloc.dart';
import 'package:modular_erp/features/attendance/presentation/pages/attendance_history_page.dart';
import 'package:modular_erp/features/attendance/presentation/pages/attendance_day_details_page.dart';
import 'package:modular_erp/features/attendance/presentation/widgets/attendance_history_components.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'attendance_history_test.dart' show record;
import 'attendance_test.dart' show fixtureLocation;
import 'package:modular_erp/features/attendance/domain/attendance_summary_calculator.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'attendance_experience_test.dart' as e;
import 'auth_widget_test.dart' as h;
import 'package:flutter/services.dart';

Future<void> seed(WidgetTester t, e.Experience x) async {
  {
    final local = AttendanceLocalDataSource(x.db);
    for (final day in [
      record(1).copyWith(
        snapshot: record(1).snapshot.copyWith(workLocation: fixtureLocation()),
      ),
      record(2),
      record(3, overnight: true),
      record(4).copyWith(syncStatus: AttendanceSyncStatus.failed),
      record(5).copyWith(syncStatus: AttendanceSyncStatus.rejected),
      record(16, open: true, onBreak: true),
    ]) {
      await local.putDay(day);
      final start = day.punchInAt!;
      final types = [
        AttendanceEventType.punchIn,
        if (day.attendanceDate.day == 2 ||
            day.state == AttendanceWorkdayState.onBreak)
          AttendanceEventType.breakStart,
        if (day.attendanceDate.day == 2) ...[
          AttendanceEventType.breakEnd,
          AttendanceEventType.breakStart,
          AttendanceEventType.breakEnd,
        ],
        if (day.punchOutAt != null) AttendanceEventType.punchOut,
      ];
      final events = <AttendanceEvent>[];
      for (var i = 0; i < types.length; i++) {
        final time = types[i] == AttendanceEventType.punchOut
            ? day.punchOutAt!
            : start.add(Duration(minutes: i * 20));
        final event = AttendanceEvent(
          id: '${day.id}-$i',
          attendanceDayId: day.id,
          companyId: day.companyId,
          employeeId: day.employeeId,
          eventType: types[i],
          deviceTimestamp: time,
          sequence: i,
          requestId: '${day.id}-$i',
          source: AttendanceEventSource.mobile,
          syncStatus: day.syncStatus,
          workLocationId: day.snapshot.workLocation?.id,
          locationEvidence: day.snapshot.workLocation == null
              ? null
              : AttendanceLocationEvidence(
                  latitude: 0,
                  longitude: 0,
                  accuracyMeters: 10,
                  capturedAt: time,
                ),
          locationValidation: AttendanceLocationValidation(
            state: day.snapshot.workLocation == null
                ? AttendanceLocationState.notRequired
                : AttendanceLocationState.insideAllowedArea,
          ),
          createdAt: time,
        );
        events.add(event);
        await local.insertEvent(event);
      }
      if (day.punchOutAt != null) {
        final summary =
            (const AttendanceSummaryCalculator().calculate(
                      events,
                      x.clock.now(),
                    )
                    as Success<AttendanceSummary>)
                .value;
        await local.putDay(
          day.copyWith(
            workMilliseconds: summary.workDuration.inMilliseconds,
            breakMilliseconds: summary.breakDuration.inMilliseconds,
            elapsedMilliseconds: summary.elapsedDuration.inMilliseconds,
          ),
        );
      }
    }
  }
}

void resetScroll(WidgetTester t) {
  for (final element in find.byType(Scrollable).evaluate()) {
    final state = (element as StatefulElement).state as ScrollableState;
    if (state.position.hasContentDimensions) state.position.jumpTo(0);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final font in {
      'Manrope': 'assets/fonts/Manrope-Regular.ttf',
      'IBMPlexSansArabic': 'assets/fonts/IBMPlexSansArabic-Regular.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      await (FontLoader(font.key)..addFont(rootBundle.load(font.value))).load();
    }
  });
  for (final language in AppLanguage.values) {
    for (final width in [
      360.0,
      390.0,
      430.0,
      600.0,
      768.0,
      900.0,
      1024.0,
      1280.0,
      1440.0,
      1920.0,
    ]) {
      testWidgets('${language.name} history and six record states fit $width', (
        t,
      ) async {
        final x = await e.mount(t, language, width);
        final seeding = seed(t, x);
        await e.settle(t);
        await seeding;
        h.router(t).go(AppRoutes.attendanceHistory);
        await e.settle(t);
        expect(find.byType(AttendanceHistoryPage), findsOneWidget);
        expect(find.byType(AttendanceMonthlySummary), findsOneWidget);
        expect(t.takeException(), null);
        final context = t.element(find.byType(AttendanceHistoryPage));
        final l = context.l10n;
        final bloc = context.read<AttendanceHistoryBloc>();
        expect(bloc.state.data!.total, 6);
        if (width == 390 || width == 1440) {
          resetScroll(t);
          await h.pump(t);
          await h.screenshot(
            t,
            x.harness.key,
            'phase8_${language.name}_${width.toInt()}_history',
          );
        }
        // A route push retains the month/filter owner for Back.
        final owner = bloc;
        for (final i in [1, 2, 3, 4, 5, 16]) {
          h.router(t).push(AppRoutes.attendanceDayDetails(record(i).id));
          await e.settle(t);
          expect(find.byType(AttendanceDayDetailsPage), findsOneWidget);
          expect(t.takeException(), null);
          if (i == 16) {
            expect(find.text(l.historyMissingOut), findsOneWidget);
            expect(find.text(l.historyOpenBreak), findsOneWidget);
          }
          if (i == 3) expect(find.text(l.historyOvernight), findsOneWidget);
          if (i == 1 && (width == 390 || width == 1440)) {
            resetScroll(t);
            await h.pump(t);
            await h.screenshot(
              t,
              x.harness.key,
              'phase8_${language.name}_${width.toInt()}_details',
            );
          }
          h.router(t).pop();
          await e.settle(t);
          expect(
            t
                .element(find.byType(AttendanceHistoryPage))
                .read<AttendanceHistoryBloc>(),
            same(owner),
          );
        }
        bloc.add(
          AttendanceHistoryFilterChanged({AttendanceHistoryStatus.late}),
        );
        await e.settle(t);
        expect(find.text(l.historyFilteredEmpty), findsOneWidget);
        expect(t.takeException(), null);
        bloc.add(AttendanceHistoryMonthChanged(DateTime.utc(2026, 8)));
        await e.settle(t);
        expect(find.text(l.historyEmpty), findsOneWidget);
        expect(t.takeException(), null);
        await h.unmount(t, x.harness);
      });
    }
  }
  testWidgets('mobile filter draft requires Apply, can cancel and reset', (
    t,
  ) async {
    final x = await e.mount(t, AppLanguage.english, 390);
    final seeding = seed(t, x);
    await e.settle(t);
    await seeding;
    h.router(t).go(AppRoutes.attendanceHistory);
    await e.settle(t);
    final c = t.element(find.byType(AttendanceHistoryPage)),
        l = c.l10n,
        bloc = c.read<AttendanceHistoryBloc>();
    final button = find.byWidgetPredicate(
      (w) => w is AppSecondaryButton && w.label.startsWith(l.historyFilters),
    );
    await h.tapVisible(t, button);
    await e.settle(t);
    await h.tapVisible(t, find.widgetWithText(AppFilterChip, l.historyLate));
    expect(bloc.state.query!.statuses, isEmpty);
    Navigator.of(t.element(find.byType(AttendanceHistoryFilterSheet))).pop();
    await e.settle(t);
    expect(bloc.state.query!.statuses, isEmpty);
    await h.tapVisible(t, button);
    await e.settle(t);
    await h.tapVisible(t, find.widgetWithText(AppFilterChip, l.historyLate));
    await h.tapVisible(
      t,
      find.widgetWithText(AppPrimaryButton, l.historyApply),
    );
    await e.settle(t);
    expect(bloc.state.query!.statuses, {AttendanceHistoryStatus.late});
    expect(find.text(l.historyFilteredEmpty), findsOneWidget);
    await h.tapVisible(t, button);
    await e.settle(t);
    await h.tapVisible(
      t,
      find.widgetWithText(AppSecondaryButton, l.historyReset),
    );
    await h.tapVisible(
      t,
      find.widgetWithText(AppPrimaryButton, l.historyApply),
    );
    await e.settle(t);
    expect(bloc.state.query!.statuses, isEmpty);
    expect(bloc.state.data!.total, 6);
    expect(t.takeException(), null);
    await h.unmount(t, x.harness);
  });
  testWidgets(
    'invalid detail deep link is friendly and Back preserves filtered month',
    (t) async {
      final x = await e.mount(t, AppLanguage.english, 1440);
      final seeding = seed(t, x);
      await e.settle(t);
      await seeding;
      h.router(t).go(AppRoutes.attendanceHistory);
      await e.settle(t);
      final c = t.element(find.byType(AttendanceHistoryPage)),
          l = c.l10n,
          bloc = c.read<AttendanceHistoryBloc>();
      bloc.add(
        AttendanceHistoryFilterChanged({AttendanceHistoryStatus.present}),
      );
      await e.settle(t);
      h.router(t).push(AppRoutes.attendanceDayDetails('unknown-id'));
      await e.settle(t);
      expect(find.text(l.historyNotFound), findsOneWidget);
      h.router(t).pop();
      await e.settle(t);
      expect(
        t
            .element(find.byType(AttendanceHistoryPage))
            .read<AttendanceHistoryBloc>(),
        same(bloc),
      );
      expect(bloc.state.query!.statuses, {AttendanceHistoryStatus.present});
      expect(bloc.state.query!.month, 9);
      expect(t.takeException(), null);
      await h.unmount(t, x.harness);
    },
  );
  testWidgets('current working row opens Today and keeps one business owner', (
    t,
  ) async {
    final x = await e.mount(t, AppLanguage.english, 390);
    final day = record(17, open: true);
    final writing = AttendanceLocalDataSource(x.db).putDay(day);
    await e.settle(t);
    await writing;
    h.router(t).go(AppRoutes.attendanceHistory);
    await e.settle(t);
    expect(find.byType(AttendanceHistoryList), findsOneWidget);
    final row = find
        .descendant(
          of: find.byType(AttendanceHistoryList),
          matching: find.byType(AppCard),
        )
        .first;
    await h.tapVisible(t, row);
    await e.settle(t);
    expect(
      h.router(t).routeInformationProvider.value.uri.path,
      AppRoutes.attendance,
    );
    expect(t.takeException(), null);
    await h.unmount(t, x.harness);
  });
}
