import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/design_system/theme/app_breakpoints.dart';

Future<void> pumpFoundation(
  WidgetTester tester,
  Widget child, {
  double width = 480,
  double textScale = 1,
  TextDirection direction = TextDirection.ltr,
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: brightness == Brightness.dark
          ? AppTheme.dark(locale: locale)
          : AppTheme.light(locale: locale),
      builder: (context, appChild) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
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

void main() {
  group('Typography', () {
    test('exposes a deliberate weight set', () {
      expect(AppTypography.weightRegular, FontWeight.w400);
      expect(AppTypography.weightMedium, FontWeight.w500);
      expect(AppTypography.weightSemibold, FontWeight.w600);
      expect(AppTypography.weightBold, FontWeight.w700);
    });

    test('page title uses 700, body uses 500, caption uses 400', () {
      final t = AppTypography.forLocale(const Locale('en'));
      expect(t.pageTitle.fontWeight, FontWeight.w700);
      expect(t.body.fontWeight, FontWeight.w500);
      expect(t.caption.fontWeight, FontWeight.w400);
      expect(t.label.fontWeight, FontWeight.w600);
    });

    test('semantic roles carry calibrated sizes', () {
      final t = AppTypography.forLocale(const Locale('en'));
      expect(t.pageTitle.fontSize, 26);
      expect(t.sectionTitle.fontSize, 19);
      expect(t.cardTitle.fontSize, 16);
      expect(t.body.fontSize, 14);
      expect(t.caption.fontSize, 12);
      expect(t.tableHeader.fontSize, 12.5);
      expect(t.tableCell.fontSize, 13.5);
      expect(t.overline.fontSize, 11);
    });

    test('Arabic keeps natural tracking and taller line box', () {
      final en = AppTypography.forLocale(const Locale('en'));
      final ar = AppTypography.forLocale(const Locale('ar'));
      expect(ar.body.fontFamily, 'IBMPlexSansArabic');
      expect(en.body.fontFamily, 'Manrope');
      expect(ar.pageTitle.letterSpacing, 0);
      expect(ar.body.height, greaterThanOrEqualTo(en.body.height!));
      expect(ar.pageTitle.height, greaterThanOrEqualTo(en.pageTitle.height!));
    });
  });

  group('Theme resolution', () {
    test('light theme uses brand seed and neutral canvas', () {
      final theme = AppTheme.light(locale: const Locale('en'));
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.primary, AppColors.brandPrimary);
      expect(theme.iconTheme.color, AppColors.textSecondary);
      expect(theme.iconTheme.size, AppDimensions.iconMd);
    });

    test('dark theme is authored, not inverted', () {
      final theme = AppTheme.dark(locale: const Locale('en'));
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.darkBackground);
      expect(theme.colorScheme.surface, AppColors.darkSurface);
      expect(theme.colorScheme.primary, AppColors.darkBrand);
      // Surfaces step upward in luminance.
      expect(
        AppColors.darkSurface.computeLuminance(),
        greaterThan(AppColors.darkBackground.computeLuminance()),
      );
    });

    test('switch separates ON and OFF track and thumb states', () {
      final light = AppTheme.light(locale: const Locale('en'));
      final on = light.switchTheme.trackColor!.resolve({WidgetState.selected});
      final off = light.switchTheme.trackColor!.resolve({});
      final onThumb = light.switchTheme.thumbColor!.resolve({
        WidgetState.selected,
      });
      final offThumb = light.switchTheme.thumbColor!.resolve({});
      expect(on, AppColors.brandPrimary);
      expect(off, AppColors.surfaceMuted);
      expect(onThumb, Colors.white);
      expect(offThumb, Colors.white);
      expect(on, isNot(off));
    });
  });

  group('Text scaling policy', () {
    test('clamps above the accessible cap and below the floor', () {
      expect(AppTextScaling.clamp(TextScaler.linear(3)).scale(1), 1.3);
      expect(AppTextScaling.clamp(TextScaler.linear(0.2)).scale(1), 0.8);
      expect(
        AppTextScaling.clamp(TextScaler.linear(1.1)).scale(1),
        closeTo(1.1, 0.001),
      );
    });

    test('keeps a typical control layout overflow-free at large scale', () {
      for (final scale in [1.0, 1.15, 1.3]) {
        final scaler = AppTextScaling.clamp(TextScaler.linear(scale));
        final size = scaler.scale(14);
        expect(size, lessThanOrEqualTo(14 * AppTextScaling.maxScale + 0.001));
      }
    });
  });

  group('Responsive primitives', () {
    test('classifies the four supported widths', () {
      expect(AppBreakpoints.classify(390), AppSize.compact);
      expect(AppBreakpoints.classify(768), AppSize.medium);
      expect(AppBreakpoints.classify(1280), AppSize.expanded);
      expect(AppBreakpoints.classify(1920), AppSize.large);
    });

    test('one global content width is preserved', () {
      expect(AppDimensions.contentMaxWidth, 1200.0);
    });
  });

  group('Component states', () {
    testWidgets('primary button loading does not change width', (tester) async {
      await pumpFoundation(
        tester,
        AppPrimaryButton(label: 'Save', onPressed: () {}),
      );
      final resting = tester.getSize(find.byType(AppPrimaryButton)).width;
      await pumpFoundation(
        tester,
        AppPrimaryButton(label: 'Save', loading: true),
      );
      final loading = tester.getSize(find.byType(AppPrimaryButton)).width;
      expect(loading, closeTo(resting, 0.5));
    });

    testWidgets('disabled primary button exposes no onPressed', (tester) async {
      await pumpFoundation(
        tester,
        AppPrimaryButton(label: 'Save', onPressed: null),
      );
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('switch toggles from its label', (tester) async {
      var value = false;
      await pumpFoundation(
        tester,
        AppSwitchField(
          label: 'Active',
          value: false,
          onChanged: (v) => value = v,
        ),
      );
      await tester.tap(find.text('Active'));
      await tester.pump();
      expect(value, true);
    });

    testWidgets('checkbox toggles from its label', (tester) async {
      var value = false;
      await pumpFoundation(
        tester,
        AppCheckboxField(
          label: 'Enabled',
          value: false,
          onChanged: (v) => value = v,
        ),
      );
      await tester.tap(find.text('Enabled'));
      await tester.pump();
      expect(value, true);
    });

    testWidgets('read-only field renders value without an editable field', (
      tester,
    ) async {
      await pumpFoundation(
        tester,
        const AppReadOnlyField(label: 'Company', value: 'Bitlogix'),
      );
      expect(find.text('Bitlogix'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('RTL safety', () {
    testWidgets('selection controls render RTL without overflow', (
      tester,
    ) async {
      for (final scale in [1.0, 1.3]) {
        await pumpFoundation(
          tester,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSwitchField(label: 'Active', value: true, onChanged: (_) {}),
              AppCheckboxField(
                label: 'Enabled',
                value: true,
                onChanged: (_) {},
              ),
              AppRadioGroup<int>(
                value: 1,
                options: const [
                  AppRadioOption(1, 'One'),
                  AppRadioOption(2, 'Two'),
                ],
                onChanged: (_) {},
              ),
            ],
          ),
          direction: TextDirection.rtl,
          locale: const Locale('ar'),
          textScale: scale,
          width: 320,
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('page and section headers render RTL without overflow', (
      tester,
    ) async {
      await pumpFoundation(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppPageHeader(
              title: 'Employees',
              subtitle: 'All records',
              actions: [AppSecondaryButton(label: 'Add', onPressed: () {})],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSectionHeader(
              title: 'Details',
              subtitle: 'Supporting',
              action: AppTextButton(label: 'Edit', onPressed: () {}),
            ),
          ],
        ),
        direction: TextDirection.rtl,
        width: 360,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Chips and status', () {
    testWidgets('status chips render for every semantic status', (
      tester,
    ) async {
      await pumpFoundation(
        tester,
        Wrap(
          children: [
            for (final status in AppStatus.values)
              AppStatusBadge(label: status.name, status: status),
          ],
        ),
      );
      expect(
        find.byType(AppStatusBadge),
        findsNWidgets(AppStatus.values.length),
      );
    });

    testWidgets('selection and metadata chips render', (tester) async {
      await pumpFoundation(
        tester,
        Wrap(
          children: [
            AppSelectionChip(
              label: 'Active',
              selected: true,
              onSelected: (_) {},
            ),
            const AppMetadataChip(label: 'ID-42'),
          ],
        ),
      );
      expect(find.byType(AppSelectionChip), findsOneWidget);
      expect(find.byType(AppMetadataChip), findsOneWidget);
    });
  });
}
