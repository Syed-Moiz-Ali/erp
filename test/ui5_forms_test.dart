import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_attachment_strip.dart';
import 'package:modular_erp/modules/services/presentation/widgets/service_reference_field.dart';
import 'package:modular_erp/shared/transactions/domain/attachment.dart';

Future<void> pumpDs(
  WidgetTester tester,
  Widget child, {
  double width = 900,
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
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          size: Size(width, 800),
        ),
        child: appChild ?? const SizedBox.shrink(),
      ),
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: Center(
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

AttachmentRef attachment({
  String id = 'a1',
  String name = 'photo.png',
  String mime = 'image/png',
  AttachmentUploadStatus status = AttachmentUploadStatus.uploaded,
}) => AttachmentRef(
  id: id,
  companyId: 'c1',
  ownerType: 'serviceInspectionChecklist',
  ownerId: 'o1',
  category: AttachmentCategory.beforeWorkPhoto,
  fileName: name,
  displayName: name,
  mimeType: mime,
  sizeBytes: 1024,
  uploadStatus: status,
  syncStatus: 'pending',
  createdByUserId: 'u1',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

void main() {
  group('AppFormGrid', () {
    testWidgets('honours desktop spans and never exceeds the container', (
      tester,
    ) async {
      await pumpDs(
        tester,
        AppFormGrid(
          spans: const [AppFormSpan.quarter, AppFormSpan.threeQuarters],
          children: const [
            Text('code', key: ValueKey('code')),
            Text('description', key: ValueKey('description')),
          ],
        ),
        width: 1000,
      );
      final code = tester.getSize(find.byKey(const ValueKey('code')));
      final description = tester.getSize(
        find.byKey(const ValueKey('description')),
      );
      expect(code.width, lessThan(description.width));
      expect(
        tester.getTopRight(find.byKey(const ValueKey('description'))).dx,
        lessThanOrEqualTo(1000.5),
      );
    });

    testWidgets('collapses every field to a single column on mobile', (
      tester,
    ) async {
      await pumpDs(
        tester,
        AppFormGrid(
          children: const [
            Text('code', key: ValueKey('code')),
            Text('name', key: ValueKey('name')),
          ],
        ),
        width: 390,
      );
      final code = tester.getRect(find.byKey(const ValueKey('code')));
      final name = tester.getRect(find.byKey(const ValueKey('name')));
      expect(code.left, closeTo(name.left, 0.5));
      expect(name.top, greaterThan(code.bottom - 0.5));
    });
  });

  group('AppBooleanSettingRow', () {
    testWidgets('renders an external label and toggles on tap', (tester) async {
      var value = false;
      await pumpDs(
        tester,
        AppBooleanSettingRow(
          label: 'Default priority',
          description: 'Used when nothing is selected',
          value: value,
          onChanged: (v) => value = v,
        ),
      );
      expect(find.text('Default priority'), findsOneWidget);
      await tester.tap(find.text('Default priority'));
      await tester.pump();
      expect(value, isTrue);
    });

    testWidgets('does not toggle when disabled or loading', (tester) async {
      var calls = 0;
      await pumpDs(
        tester,
        AppBooleanSettingRow(
          label: 'Disabled',
          value: false,
          enabled: false,
          onChanged: (_) => calls++,
        ),
      );
      await tester.tap(find.text('Disabled'));
      await tester.pump();
      expect(calls, 0);
    });

    testWidgets('renders a field-level error below the row', (tester) async {
      await pumpDs(
        tester,
        AppBooleanSettingRow(
          label: 'Tracking',
          value: false,
          onChanged: (_) {},
          errorText: 'Tracking requires a rule',
        ),
      );
      expect(find.text('Tracking requires a rule'), findsOneWidget);
    });
  });

  group('read-only context and generated values', () {
    testWidgets('context renders key/value and generated fallback', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const Column(
          children: [
            AppReadOnlyContextSection(
              title: 'Customer & location',
              fields: [
                AppDetailField(label: 'Customer', value: 'ABC Properties'),
                AppDetailField(label: 'Unit', value: '403'),
              ],
            ),
            AppGeneratedValueField(
              label: 'Enquiry No',
              generatedFallback: 'Generated when saved',
            ),
          ],
        ),
      );
      expect(find.text('ABC Properties'), findsOneWidget);
      expect(find.text('403'), findsOneWidget);
      expect(find.text('Generated when saved'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('AppFormActions', () {
    testWidgets('renders cancel and primary save and prevents double submit', (
      tester,
    ) async {
      var saves = 0;
      await pumpDs(
        tester,
        AppFormActions(
          cancelLabel: 'Cancel',
          onCancel: () {},
          saveLabel: 'Save',
          saving: true,
          onSave: () => saves++,
        ),
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      await tester.tap(find.text('Save'), warnIfMissed: false);
      await tester.pump();
      expect(saves, 0);
    });

    testWidgets('invokes save when idle and mirrors under RTL', (tester) async {
      var saves = 0;
      await pumpDs(
        tester,
        AppFormActions(saveLabel: 'Create', onSave: () => saves++),
        direction: TextDirection.rtl,
      );
      await tester.tap(find.text('Create'));
      await tester.pump();
      expect(saves, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppFormErrorSummary', () {
    testWidgets('shows the count and offending labels', (tester) async {
      await pumpDs(
        tester,
        const AppFormErrorSummary(
          title: '3 fields need attention',
          details: ['Code', 'Name', 'Date'],
        ),
      );
      expect(find.textContaining('3 fields need attention'), findsOneWidget);
      expect(find.textContaining('Name'), findsOneWidget);
    });
  });

  group('ServiceReferenceField', () {
    testWidgets('shows the selected entity with context', (tester) async {
      await pumpDs(
        tester,
        ServiceReferenceField<String>(
          label: 'Customer',
          valueLabel: 'ABC Properties',
          valueSubtitle: 'CUS-0001 · +91 90000',
          onPick: () {},
        ),
      );
      expect(find.text('ABC Properties'), findsOneWidget);
      expect(find.text('CUS-0001 · +91 90000'), findsOneWidget);
    });

    testWidgets('only offers clear when nullable', (tester) async {
      var cleared = 0;
      await pumpDs(
        tester,
        ServiceReferenceField<String>(
          label: 'Site',
          valueLabel: 'Tower A',
          onPick: () {},
          onClear: () => cleared++,
        ),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(cleared, 1);

      await pumpDs(
        tester,
        ServiceReferenceField<String>(
          label: 'Site',
          valueLabel: 'Tower A',
          onPick: () {},
        ),
      );
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('disabled field cannot be opened', (tester) async {
      var picks = 0;
      await pumpDs(
        tester,
        ServiceReferenceField<String>(
          label: 'Employee',
          valueLabel: 'Ahmed',
          enabled: false,
          onPick: () => picks++,
        ),
      );
      await tester.tap(find.text('Ahmed'));
      await tester.pump();
      expect(picks, 0);
    });
  });

  group('reference picker', () {
    testWidgets('searches with debounce, shows empty and selects', (
      tester,
    ) async {
      final results = <String>[];
      await pumpDs(
        tester,
        _PickerHost(
          onResult: (r) {
            if (r is ServiceReferenceSelected<String>) results.add(r.value);
          },
          search: (q) async => [
            'Alpha Tower',
            'Beta Court',
          ].where((e) => e.toLowerCase().contains(q.toLowerCase())).toList(),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Alpha Tower'), findsOneWidget);
      expect(find.text('Beta Court'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'beta');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Beta Court'), findsOneWidget);
      expect(find.text('Alpha Tower'), findsNothing);

      await tester.tap(find.text('Beta Court'));
      await tester.pumpAndSettle();
      expect(results, ['Beta Court']);
    });

    testWidgets('shows an empty state and recovers from errors', (
      tester,
    ) async {
      var throwNext = false;
      await pumpDs(
        tester,
        _PickerHost(
          search: (q) async {
            if (q == 'boom') {
              if (throwNext) {
                throwNext = false;
                return ['Recovered'];
              }
              throwNext = true;
              throw Exception('offline');
            }
            if (q == 'none') return [];
            return ['Alpha'];
          },
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'none');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Nothing here'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'boom');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      final l = AppLocalizations.of(tester.element(find.byType(_PickerHost)));
      expect(find.text(l.somethingWentWrong), findsOneWidget);

      await tester.tap(find.text(l.retry));
      await tester.pumpAndSettle();
      expect(find.text('Recovered'), findsOneWidget);
    });

    testWidgets('renders under RTL', (tester) async {
      await pumpDs(
        tester,
        _PickerHost(search: (q) async => ['Alpha']),
        direction: TextDirection.rtl,
        locale: const Locale('ar'),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Alpha'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppRepeatableSection', () {
    testWidgets('adds and removes dynamic items with a clear empty prompt', (
      tester,
    ) async {
      await pumpDs(tester, const _RepeaterHost());
      expect(find.text('No work items yet'), findsOneWidget);

      await tester.tap(find.text('Add item'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add item'));
      await tester.pumpAndSettle();
      expect(find.text('Work item 1'), findsOneWidget);
      expect(find.text('Work item 2'), findsOneWidget);
      expect(find.text('No work items yet'), findsNothing);

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      expect(find.text('Work item 1'), findsNothing);
      expect(find.text('Work item 2'), findsOneWidget);
    });
  });

  group('attachments', () {
    testWidgets('add, multiple thumbnails and remove', (tester) async {
      var added = 0;
      final removed = <String>[];
      await pumpDs(
        tester,
        ServiceAttachmentStrip(
          label: 'Before work photos',
          addLabel: 'Add photos',
          attachments: [
            attachment(id: 'a1', name: 'before-1.png'),
            attachment(id: 'a2', name: 'before-2.png'),
          ],
          onAdd: () => added++,
          onRemove: removed.add,
        ),
      );
      expect(find.text('before-1.png'), findsOneWidget);
      expect(find.text('before-2.png'), findsOneWidget);
      await tester.tap(find.text('Add photos'));
      await tester.pump();
      expect(added, 1);
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pump();
      expect(removed, ['a1']);
    });

    testWidgets('failed upload exposes retry, uploaded does not', (
      tester,
    ) async {
      final retried = <String>[];
      await pumpDs(
        tester,
        ServiceAttachmentStrip(
          label: 'After work photos',
          addLabel: 'Add photos',
          attachments: [
            attachment(
              id: 'f1',
              name: 'failed.png',
              status: AttachmentUploadStatus.failed,
            ),
            attachment(id: 'u1', name: 'uploaded.png'),
          ],
          onRemove: (_) {},
          onRetry: retried.add,
        ),
      );
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(retried, ['f1']);
    });

    testWidgets('labels upload states in Arabic', (tester) async {
      await pumpDs(
        tester,
        ServiceAttachmentStrip(
          label: 'صور',
          addLabel: 'إضافة',
          attachments: [
            attachment(
              name: 'x.png',
              status: AttachmentUploadStatus.pendingUpload,
            ),
          ],
        ),
        locale: const Locale('ar'),
        direction: TextDirection.rtl,
      );
      final l = AppLocalizations.of(
        tester.element(find.byType(ServiceAttachmentStrip)),
      );
      expect(find.text(l.attachmentPendingUpload), findsOneWidget);
    });
  });

  group('viewport matrix', () {
    for (final width in [390.0, 600.0, 768.0, 1000.0, 1280.0, 1440.0, 1920.0]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets('representative form fits ${width.toInt()} x$scale', (
          tester,
        ) async {
          await pumpDs(
            tester,
            _RepresentativeForm(),
            width: width,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
    testWidgets('representative form fits RTL at 1.3 scale', (tester) async {
      await pumpDs(
        tester,
        _RepresentativeForm(),
        width: 390,
        textScale: 1.3,
        direction: TextDirection.rtl,
        locale: const Locale('ar'),
      );
      expect(tester.takeException(), isNull);
    });
  });
}

class _PickerHost extends StatelessWidget {
  const _PickerHost({required this.search, this.onResult});
  final Future<List<String>> Function(String query) search;
  final void Function(ServiceReferenceResult<String>)? onResult;
  @override
  Widget build(BuildContext context) => Center(
    child: AppPrimaryButton(
      label: 'Open',
      onPressed: () async {
        final result = await showServiceReferencePicker<String>(
          context,
          title: 'Pick a site',
          search: search,
          labelOf: (v) => v,
          idOf: (v) => v,
          emptyText: 'Nothing here',
        );
        if (result != null) onResult?.call(result);
      },
    ),
  );
}

class _RepeaterHost extends StatefulWidget {
  const _RepeaterHost();
  @override
  State<_RepeaterHost> createState() => _RepeaterHostState();
}

class _RepeaterHostState extends State<_RepeaterHost> {
  final items = <int>[];
  @override
  Widget build(BuildContext context) => AppRepeatableSection(
    title: 'Work items',
    addLabel: 'Add item',
    emptyText: 'No work items yet',
    onAdd: () => setState(() => items.add(items.length + 1)),
    children: [
      for (final item in items)
        AppRepeatableItemCard(
          title: 'Work item $item',
          onRemove: () => setState(() => items.remove(item)),
          children: const [Text('Field')],
        ),
    ],
  );
}

class _RepresentativeForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFormSection(
          title: 'Basic information',
          child: AppFormGrid(
            spans: const [AppFormSpan.half, AppFormSpan.half, AppFormSpan.full],
            children: [
              AppTextField(label: 'Code', initialValue: 'ENQ-1'),
              AppTextField(label: 'Name', initialValue: 'Inspection'),
              AppTextField(label: 'Description', maxLines: 3),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppBooleanSettingRow(
          label: 'Material received',
          value: true,
          onChanged: (_) {},
        ),
        const SizedBox(height: AppSpacing.lg),
        ServiceReferenceField<String>(
          label: 'Customer',
          valueLabel: 'ABC Properties',
          valueSubtitle: 'CUS-0001',
          onPick: () {},
        ),
        const SizedBox(height: AppSpacing.lg),
        AppRepeatableSection(
          title: 'Items',
          addLabel: 'Add item',
          emptyText: 'No items yet',
          onAdd: () {},
          children: [
            AppRepeatableItemCard(
              title: 'Item 1',
              statusLabel: 'Pending',
              onRemove: () {},
              children: const [AppTextField(label: 'Work')],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ServiceAttachmentStrip(
          label: 'Before photos',
          addLabel: 'Add photos',
          attachments: [attachment()],
        ),
        const SizedBox(height: AppSpacing.xl),
        AppFormActions(
          cancelLabel: 'Cancel',
          onCancel: () {},
          saveLabel: 'Save',
          onSave: () {},
        ),
      ],
    ),
  );
}
