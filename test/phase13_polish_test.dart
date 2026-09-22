import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';

Widget host(
  Widget child, {
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) => MaterialApp(
  locale: locale,
  theme: AppTheme.light(locale: locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('count badge is silent at zero and capped at max', (
    tester,
  ) async {
    await tester.pumpWidget(host(const AppCountBadge(count: 0)));
    expect(find.text('0'), findsNothing);
    await tester.pumpWidget(host(const AppCountBadge(count: 7)));
    expect(find.text('7'), findsOneWidget);
    await tester.pumpWidget(host(const AppCountBadge(count: 250, max: 99)));
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('status badge communicates with text, not colour alone', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const AppStatusBadge(
          label: 'Approved',
          status: AppStatus.success,
          icon: Icons.check,
        ),
      ),
    );
    expect(find.text('Approved'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('icon button exposes tooltip semantics and a 40px target', (
    tester,
  ) async {
    var tapped = 0;
    await tester.pumpWidget(
      host(
        AppIconButton(
          icon: Icons.refresh,
          tooltip: 'Refresh',
          onPressed: () => tapped++,
        ),
      ),
    );
    expect(find.byTooltip('Refresh'), findsOneWidget);
    final size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(AppDimensions.controlMd));
    expect(size.height, greaterThanOrEqualTo(AppDimensions.controlMd));
    await tester.tap(find.byType(IconButton));
    expect(tapped, 1);
  });

  testWidgets('filter chip reflects selection state semantically', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(AppFilterChip(label: 'Active', selected: true, onSelected: (_) {})),
    );
    final chip = tester.widget<FilterChip>(find.byType(FilterChip));
    expect(chip.selected, isTrue);
    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('table renders dense rows at compact width and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      host(
        AppDataTable(
          columns: const [
            DataColumn(label: Text('Employee')),
            DataColumn(label: Text('Status')),
          ],
          rows: const [
            DataRow(
              cells: [DataCell(Text('Ahmed Khan')), DataCell(Text('Working'))],
            ),
          ],
        ),
        textScale: 1.5,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Ahmed Khan'), findsOneWidget);
  });

  testWidgets('directional components mirror in Arabic', (tester) async {
    await tester.pumpWidget(
      host(
        const AppStatusBadge(label: 'حضور', status: AppStatus.info),
        locale: const Locale('ar'),
      ),
    );
    final direction = Directionality.of(
      tester.element(find.byType(AppStatusBadge)),
    );
    expect(direction, TextDirection.rtl);
    expect(find.text('حضور'), findsOneWidget);
  });

  testWidgets('empty and error states keep a readable message', (tester) async {
    await tester.pumpWidget(
      host(
        const AppEmptyState(
          title: 'No employees',
          message: 'Add your first employee to get started.',
        ),
      ),
    );
    expect(find.text('No employees'), findsOneWidget);
    expect(
      find.text('Add your first employee to get started.'),
      findsOneWidget,
    );
    await tester.pumpWidget(host(const AppErrorState(message: 'Try again.')));
    expect(find.text('Try again.'), findsOneWidget);
  });
}
