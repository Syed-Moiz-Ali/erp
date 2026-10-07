import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/errors/result.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_correction.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_correction_repository.dart';
import 'package:modular_erp/modules/hr/attendance/domain/attendance_models.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/bloc/attendance_correction_bloc.dart';
import 'package:modular_erp/modules/hr/attendance/presentation/pages/attendance_correction_pages.dart';

Future<void> pumpCollection(
  WidgetTester tester,
  Widget child, {
  double width = 1200,
  double textScale = 1,
  TextDirection direction = TextDirection.ltr,
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(locale: locale),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, appChild) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: appChild ?? const SizedBox.shrink(),
      ),
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SizedBox(width: width, child: child),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

AttendanceCorrectionRequest correctionRequest({
  String id = 'r1',
  String name = 'Aisha Khan',
  String code = 'EMP-01',
  AttendanceCorrectionStatus status = AttendanceCorrectionStatus.pending,
  AttendanceCorrectionType type = AttendanceCorrectionType.missingPunchOut,
}) => AttendanceCorrectionRequest(
  id: id,
  companyId: 'c1',
  employeeId: 'e1',
  attendanceDayId: 'd1',
  requestType: type,
  status: status,
  reason: 'Forgot to punch out',
  originalSnapshot: '{}',
  changes: [
    AttendanceCorrectionChange(
      eventType: AttendanceEventType.punchOut,
      originalTimestamp: null,
      requestedTimestamp: DateTime.utc(2026, 9, 18, 18),
    ),
  ],
  requestedByUserId: 'u1',
  requestedAt: DateTime.utc(2026, 9, 18, 17),
  createdAt: DateTime.utc(2026, 9, 18, 17),
  updatedAt: DateTime.utc(2026, 9, 18, 17),
  employeeName: name,
  employeeCode: code,
);

class _FakeCorrectionRepository implements AttendanceCorrectionRepository {
  _FakeCorrectionRepository(this.result);

  final Result<List<AttendanceCorrectionRequest>> result;

  @override
  Stream<Result<List<AttendanceCorrectionRequest>>> watchMyRequests() =>
      Stream.value(result);

  @override
  Stream<Result<List<AttendanceCorrectionRequest>>> watchPendingRequests() =>
      Stream.value(result);

  @override
  Future<Result<AttendanceCorrectionRequest?>> getRequestById(String id) =>
      throw UnimplementedError();

  @override
  Future<Result<AttendanceCorrectionRequest>> createRequest(
    AttendanceCorrectionRequest request,
  ) => throw UnimplementedError();

  @override
  Future<Result<void>> cancelRequest(String id) => throw UnimplementedError();

  @override
  Future<Result<AttendanceCorrectionRequest>> approveRequest(
    String id, {
    required String reviewerId,
    String? note,
  }) => throw UnimplementedError();

  @override
  Future<Result<AttendanceCorrectionRequest>> rejectRequest(
    String id, {
    required String reviewerId,
    required String note,
  }) => throw UnimplementedError();
}

Future<AttendanceCorrectionBloc> pumpCorrectionQueue(
  WidgetTester tester, {
  required Result<List<AttendanceCorrectionRequest>> result,
  double width = 1200,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  final bloc = AttendanceCorrectionBloc(_FakeCorrectionRepository(result));
  addTearDown(bloc.close);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(locale: locale),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BlocProvider.value(
          value: bloc,
          child: const AttendanceCorrectionQueuePage(),
        ),
      ),
    ),
  );
  bloc.add(const CorrectionQueueStarted());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  return bloc;
}

void main() {
  group('AppCollectionToolbar', () {
    testWidgets('lays out search, filters, sort and result count', (
      tester,
    ) async {
      var clears = 0;
      await pumpCollection(
        tester,
        AppCollectionToolbar(
          search: AppSearchField(
            controller: TextEditingController(text: 'abc'),
            onClear: () => clears++,
          ),
          filterButton: AppFilterButton(activeCount: 2, onPressed: () {}),
          sort: AppSortControl<String>(
            value: 'a',
            items: const [
              DropdownMenuItem(value: 'a', child: Text('A')),
              DropdownMenuItem(value: 'b', child: Text('B')),
            ],
            onChanged: (_) {},
          ),
          resultCount: const AppResultCount(filtered: 42),
        ),
        width: 1200,
      );
      expect(find.byType(AppSearchField), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is AppSecondaryButton && w.icon == Icons.tune,
        ),
        findsOneWidget,
      );
      expect(find.byType(AppSortControl<String>), findsOneWidget);
      expect(find.text('42 results'), findsOneWidget);
    });

    testWidgets('search clear button resets the query', (tester) async {
      final controller = TextEditingController(text: 'night');
      String? last;
      await pumpCollection(
        tester,
        AppCollectionToolbar(
          search: AppSearchField(
            controller: controller,
            onChanged: (v) => last = v,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      expect(controller.text, isEmpty);
      expect(last, isEmpty);
    });

    testWidgets('stacks controls on compact widths', (tester) async {
      await pumpCollection(
        tester,
        AppCollectionToolbar(
          search: AppSearchField(controller: TextEditingController()),
          filterButton: AppFilterButton(activeCount: 0, onPressed: () {}),
          resultCount: const AppResultCount(filtered: 3),
        ),
        width: 390,
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(AppSearchField), findsOneWidget);
      expect(find.text('3 results'), findsOneWidget);
    });
  });

  group('AppFilterButton', () {
    testWidgets('shows the active filter count', (tester) async {
      await pumpCollection(
        tester,
        AppFilterButton(activeCount: 3, onPressed: () {}),
      );
      expect(
        find.widgetWithText(AppSecondaryButton, 'Filters (3)'),
        findsOneWidget,
      );
    });

    testWidgets('hides the count when no filter is active', (tester) async {
      await pumpCollection(
        tester,
        AppFilterButton(activeCount: 0, onPressed: () {}),
      );
      expect(
        find.widgetWithText(AppSecondaryButton, 'Filters'),
        findsOneWidget,
      );
    });
  });

  group('AppResultCount', () {
    testWidgets('distinguishes filtered from total', (tester) async {
      await pumpCollection(
        tester,
        const AppResultCount(filtered: 12, total: 40),
      );
      expect(find.text('12 of 40 results'), findsOneWidget);
    });

    testWidgets('shows a single total when nothing is filtered', (
      tester,
    ) async {
      await pumpCollection(
        tester,
        const AppResultCount(filtered: 40, total: 40),
      );
      expect(find.text('40 results'), findsOneWidget);
    });
  });

  group('AppActiveFilters', () {
    testWidgets('removes a single chip and exposes clear all', (tester) async {
      final removed = <String>[];
      await pumpCollection(
        tester,
        AppActiveFilters(
          filters: [
            AppActiveFilter(
              label: 'Status: Pending',
              onRemove: () => removed.add('status'),
            ),
            AppActiveFilter(
              label: 'Team: HVAC',
              onRemove: () => removed.add('team'),
            ),
          ],
          onClearAll: () => removed.add('all'),
        ),
      );
      expect(find.text('Status: Pending'), findsOneWidget);
      expect(find.text('Clear all'), findsOneWidget);
      await tester.tap(find.text('Status: Pending'));
      await tester.pump();
      expect(removed, ['status']);
      await tester.tap(find.text('Clear all'));
      await tester.pump();
      expect(removed.last, 'all');
    });

    testWidgets('a single filter has a removable chip but no clear all', (
      tester,
    ) async {
      await pumpCollection(
        tester,
        AppActiveFilters(
          filters: [AppActiveFilter(label: 'Status: Active', onRemove: () {})],
          onClearAll: () {},
        ),
      );
      expect(find.text('Status: Active'), findsOneWidget);
      expect(find.text('Clear all'), findsNothing);
    });
  });

  group('AppPagination', () {
    testWidgets('reports an accurate range and disables previous on page one', (
      tester,
    ) async {
      var requested = -1;
      await pumpCollection(
        tester,
        AppPagination(
          page: 0,
          pageSize: 10,
          total: 25,
          onPageChanged: (p) => requested = p,
        ),
      );
      expect(find.text('1–10 of 25'), findsOneWidget);
      expect(find.text('Page 1 of 3'), findsOneWidget);
      final prev = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left),
      );
      expect(prev.onPressed, isNull);
      await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));
      await tester.pump();
      expect(requested, 1);
    });

    testWidgets('flips chevrons for RTL', (tester) async {
      await pumpCollection(
        tester,
        AppPagination(page: 0, pageSize: 10, total: 25, onPageChanged: (_) {}),
        direction: TextDirection.rtl,
      );
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Collection states', () {
    testWidgets('no-data and no-results are distinct', (tester) async {
      await pumpCollection(
        tester,
        AppCollectionEmptyState.noData(
          title: 'No employees yet',
          message: 'Add your first employee.',
          actionLabel: 'Add employee',
          onAction: () {},
        ),
      );
      expect(find.text('Add employee'), findsOneWidget);
      expect(find.text('Clear filters'), findsNothing);

      await pumpCollection(
        tester,
        AppCollectionEmptyState.noResults(
          title: 'No results found',
          message: 'Try adjusting your search.',
          onClearFilters: () {},
        ),
      );
      expect(find.text('Clear filters'), findsOneWidget);
    });

    testWidgets('skeleton renders table geometry on desktop', (tester) async {
      await pumpCollection(tester, const AppCollectionSkeleton(), width: 1200);
      expect(tester.takeException(), isNull);
    });

    testWidgets('skeleton renders cards on compact', (tester) async {
      await pumpCollection(tester, const AppCollectionSkeleton(), width: 390);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppMobileRecordCard', () {
    testWidgets('renders identity, status and trailing actions', (
      tester,
    ) async {
      await pumpCollection(
        tester,
        AppMobileRecordCard(
          title: 'ENQ-00042',
          subtitle: 'ABC Properties',
          tertiary: 'Tower A · Unit 403',
          status: AppStatus.warning,
          statusLabel: 'Pending',
          onTap: () {},
          metrics: const [(label: 'Priority', value: 'High')],
          trailing: AppActionMenu(
            tooltip: 'Actions',
            actions: [AppMenuAction(label: (l) => 'View', onPressed: () {})],
          ),
        ),
        width: 390,
      );
      expect(find.text('ENQ-00042'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.byType(AppActionMenu), findsOneWidget);
    });
  });

  group('Responsive + RTL matrix', () {
    for (final width in [390.0, 600.0, 768.0, 1000.0, 1280.0, 1440.0, 1920.0]) {
      for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
        for (final scale in [1.0, 1.3]) {
          testWidgets(
            'toolbar fits ${width.toInt()} ${direction.name} x$scale',
            (tester) async {
              await pumpCollection(
                tester,
                AppCollectionToolbar(
                  search: AppSearchField(controller: TextEditingController()),
                  filterButton: AppFilterButton(
                    activeCount: 1,
                    onPressed: () {},
                  ),
                  sort: AppSortControl<String>(
                    value: 'a',
                    items: const [
                      DropdownMenuItem(value: 'a', child: Text('Newest first')),
                    ],
                    onChanged: (_) {},
                  ),
                  resultCount: const AppResultCount(filtered: 8, total: 40),
                  activeFilters: AppActiveFilters(
                    filters: [
                      AppActiveFilter(
                        label: 'Status: Pending',
                        onRemove: () {},
                      ),
                    ],
                  ),
                ),
                width: width,
                direction: direction,
                textScale: scale,
                locale: direction == TextDirection.rtl
                    ? const Locale('ar')
                    : const Locale('en'),
              );
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  });

  group('Correction queue collection', () {
    testWidgets('renders employee, change and status in a desktop table', (
      tester,
    ) async {
      await pumpCorrectionQueue(tester, result: Success([correctionRequest()]));
      expect(find.byType(AppDataTable), findsOneWidget);
      expect(find.byType(AppCollectionSurface), findsOneWidget);
      expect(find.text('Aisha Khan'), findsOneWidget);
      expect(find.text('EMP-01'), findsOneWidget);
      expect(find.byType(AppActionMenu), findsOneWidget);
      expect(find.byType(AppResultCount), findsOneWidget);
    });

    testWidgets('renders a mobile record card on compact', (tester) async {
      await pumpCorrectionQueue(
        tester,
        result: Success([correctionRequest()]),
        width: 390,
      );
      expect(find.byType(AppMobileRecordCard), findsOneWidget);
      expect(find.text('Aisha Khan'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('distinguishes no data from no results', (tester) async {
      await pumpCorrectionQueue(tester, result: const Success([]));
      final l = AppLocalizations.of(
        tester.element(find.byType(AttendanceCorrectionQueuePage)),
      );
      expect(find.text(l.correctionEmptyTitle), findsOneWidget);

      await pumpCorrectionQueue(tester, result: Success([correctionRequest()]));
      await tester.enterText(find.byType(TextField), 'zzz-no-match');
      await tester.pump();
      expect(find.text(l.correctionNoResultsTitle), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);
    });

    testWidgets('renders a retryable error state', (tester) async {
      await pumpCorrectionQueue(
        tester,
        result: Failed(
          const Failure(code: 'correctionLoad', kind: FailureKind.unknown),
        ),
      );
      expect(find.byType(AppErrorState), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });
}
