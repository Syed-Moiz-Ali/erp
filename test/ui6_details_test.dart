import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';

Future<void> pumpDs(
  WidgetTester tester,
  Widget child, {
  double width = 900,
  double textScale = 1,
  TextDirection direction = TextDirection.ltr,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(locale: locale),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, appChild) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          size: Size(width, 900),
        ),
        child: appChild ?? const SizedBox.shrink(),
      ),
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('AppDetailHeader', () {
    testWidgets('renders identity, business id, status and metadata', (
      tester,
    ) async {
      await pumpDs(
        tester,
        AppDetailHeader(
          title: 'Service Enquiry',
          businessId: 'ENQ-00042',
          description: 'ABC Properties',
          status: const AppDetailStatus(label: 'Open', status: AppStatus.info),
          metadata: const [
            AppMetadataItem(
              icon: Icons.flag_outlined,
              label: 'Priority',
              value: 'High',
            ),
          ],
        ),
        width: 1000,
      );
      expect(find.text('Service Enquiry'), findsOneWidget);
      expect(find.text('ENQ-00042'), findsOneWidget);
      expect(find.text('ABC Properties'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('hierarchy keeps primary/secondary visible and more menu', (
      tester,
    ) async {
      var more = false;
      await pumpDs(
        tester,
        AppDetailHeader(
          title: 'INS-00022',
          primaryAction: AppPrimaryButton(label: 'Complete', onPressed: () {}),
          secondaryActions: [
            AppSecondaryButton(label: 'Edit', onPressed: () {}),
          ],
          overflowActions: [
            AppDetailAction(label: 'Cancel', onPressed: () => more = true),
          ],
        ),
        width: 1000,
      );
      expect(find.widgetWithText(AppPrimaryButton, 'Complete'), findsOneWidget);
      expect(find.widgetWithText(AppSecondaryButton, 'Edit'), findsOneWidget);
      // Cancel is not a visible button; it lives behind the More menu.
      expect(find.widgetWithText(AppSecondaryButton, 'Cancel'), findsNothing);
      await tester.tap(find.byType(AppActionMenu));
      await tester.pumpAndSettle();
      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(more, isTrue);
    });

    testWidgets('compact width stacks identity and actions without overflow', (
      tester,
    ) async {
      await pumpDs(
        tester,
        AppDetailHeader(
          title: 'A very long employee record title that wraps',
          status: const AppDetailStatus(label: 'Active'),
          primaryAction: AppPrimaryButton(label: 'Edit', onPressed: () {}),
          secondaryActions: [
            AppSecondaryButton(label: 'Attendance', onPressed: () {}),
          ],
        ),
        width: 390,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('AppInfoGrid', () {
    List<AppInfoItem> items() => const [
      AppInfoItem(label: 'One', value: 'v1'),
      AppInfoItem(label: 'Two', value: 'v2'),
      AppInfoItem(label: 'Three', value: 'v3'),
    ];

    testWidgets('is one column on mobile', (tester) async {
      await pumpDs(tester, AppInfoGrid(items: items()), width: 390);
      final one = tester.getTopLeft(find.text('One')).dx;
      final two = tester.getTopLeft(find.text('Two')).dx;
      expect(two, closeTo(one, 0.5));
      expect(
        tester.getTopLeft(find.text('Two')).dy,
        greaterThan(tester.getTopLeft(find.text('One')).dy),
      );
    });

    testWidgets('is two columns on tablet', (tester) async {
      await pumpDs(tester, AppInfoGrid(items: items()), width: 768);
      final one = tester.getTopLeft(find.text('One'));
      final two = tester.getTopLeft(find.text('Two'));
      expect(two.dy, closeTo(one.dy, 0.5));
      expect(two.dx, greaterThan(one.dx));
    });

    testWidgets('uses more columns on desktop', (tester) async {
      await pumpDs(tester, AppInfoGrid(items: items()), width: 1280);
      final one = tester.getTopLeft(find.text('One'));
      final two = tester.getTopLeft(find.text('Two'));
      final three = tester.getTopLeft(find.text('Three'));
      expect(two.dy, closeTo(one.dy, 0.5));
      expect(three.dy, closeTo(one.dy, 0.5));
      expect(one.dx, lessThan(two.dx));
      expect(two.dx, lessThan(three.dx));
    });

    testWidgets('applies the single empty-value convention', (tester) async {
      await pumpDs(
        tester,
        const AppInfoGrid(items: [AppInfoItem(label: 'Notes', value: null)]),
        width: 600,
      );
      final l = AppLocalizations.of(tester.element(find.byType(AppInfoGrid)));
      expect(find.text(l.notProvided), findsOneWidget);
    });
  });

  group('AppRelatedRecordLink', () {
    testWidgets('is inert without permission (no destination exposed)', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const AppRelatedRecordLink(label: 'Enquiry', value: 'ENQ-1'),
      );
      expect(find.text('ENQ-1'), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('is clickable when a destination is allowed', (tester) async {
      var tapped = false;
      await pumpDs(
        tester,
        AppRelatedRecordLink(
          label: 'Enquiry',
          value: 'ENQ-1',
          onTap: () => tapped = true,
        ),
      );
      await tester.tap(find.text('ENQ-1'));
      expect(tapped, isTrue);
    });
  });

  group('AppActivityTimeline', () {
    testWidgets('renders structured items with actor and company-local time', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const AppActivityTimeline(
          items: [
            AppActivityEntry(
              id: '1',
              title: 'Created',
              time: '09:04',
              actor: 'Ahmed Khan',
            ),
          ],
        ),
      );
      expect(find.text('Created'), findsOneWidget);
      expect(find.text('Ahmed Khan'), findsOneWidget);
      expect(find.text('09:04'), findsOneWidget);
    });

    testWidgets('shows a compact empty state, not a blank panel', (
      tester,
    ) async {
      await pumpDs(tester, const AppActivityTimeline(items: []));
      final l = AppLocalizations.of(
        tester.element(find.byType(AppActivityTimeline)),
      );
      expect(find.text(l.noActivityYet), findsOneWidget);
    });
  });

  group('AppEvidenceGallery', () {
    testWidgets('renders a thumbnail grid', (tester) async {
      await pumpDs(
        tester,
        AppEvidenceGallery(
          items: [
            for (var i = 0; i < 3; i++)
              AppEvidenceItem(
                id: 'p$i',
                description: 'Photo $i',
                thumbnail: Container(key: ValueKey('thumb$i')),
              ),
          ],
        ),
        width: 1000,
      );
      expect(find.byKey(const ValueKey('thumb0')), findsOneWidget);
      expect(find.byKey(const ValueKey('thumb2')), findsOneWidget);
      expect(find.text('Photo 1'), findsOneWidget);
    });

    testWidgets('shows a compact empty state', (tester) async {
      await pumpDs(tester, const AppEvidenceGallery(items: []));
      final l = AppLocalizations.of(
        tester.element(find.byType(AppEvidenceGallery)),
      );
      expect(find.text(l.noEvidenceYet), findsOneWidget);
    });
  });

  group('Audit metadata', () {
    testWidgets('renders secondary record information', (tester) async {
      await pumpDs(
        tester,
        const AppAuditMetadata(
          items: [AppInfoItem(label: 'Created by', value: 'system')],
        ),
      );
      final l = AppLocalizations.of(
        tester.element(find.byType(AppAuditMetadata)),
      );
      expect(find.text(l.recordInformation), findsOneWidget);
      expect(find.text('system'), findsOneWidget);
    });
  });

  group('Detail states', () {
    testWidgets('skeleton and error states render', (tester) async {
      await pumpDs(
        tester,
        Column(
          children: const [
            AppDetailSkeleton(),
            SizedBox(height: 16),
            AppDetailErrorState(message: 'boom'),
          ],
        ),
      );
      expect(find.byType(AppDetailSkeleton), findsOneWidget);
      expect(find.byType(AppDetailErrorState), findsOneWidget);
    });
  });

  group('RTL and text scale', () {
    testWidgets('header, info grid and mixed identifiers survive RTL 1.3', (
      tester,
    ) async {
      await pumpDs(
        tester,
        AppDetailHeader(
          title: 'استفسار خدمة',
          businessId: 'ENQ-00042',
          description: 'شركة ABC',
          status: const AppDetailStatus(label: 'مفتوح', status: AppStatus.info),
          metadata: const [
            AppMetadataItem(
              icon: Icons.email_outlined,
              label: 'البريد',
              value: 'user@example.com',
            ),
          ],
          primaryAction: AppPrimaryButton(label: 'تعديل', onPressed: () {}),
          overflowActions: [AppDetailAction(label: 'إلغاء', onPressed: () {})],
        ),
        width: 390,
        direction: TextDirection.rtl,
        locale: const Locale('ar'),
        textScale: 1.3,
      );
      expect(find.text('ENQ-00042'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
