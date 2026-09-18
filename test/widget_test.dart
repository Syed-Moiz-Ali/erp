import 'package:modular_erp/app/router/preview_router.dart';
import 'package:modular_erp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:modular_erp/features/auth/data/repositories/demo_auth_repository.dart';
import 'support/memory_session_storage.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:modular_erp/app/erp_app.dart';
import 'package:modular_erp/core/localization/app_language.dart';
import 'package:modular_erp/core/localization/locale_cubit.dart';
import 'package:modular_erp/core/preferences/app_preferences_repository.dart';
import 'package:modular_erp/design_system/design_system.dart';
import 'package:modular_erp/features/design_system_preview/presentation/preview_cubit.dart';
import 'package:modular_erp/l10n/l10n.dart';
import 'support/memory_preferences.dart';

Future<void> pumpTransitions(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('artifacts/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Future<LocaleCubit> mountApp(
  WidgetTester tester,
  AppLanguage language, {
  GlobalKey? key,
}) async {
  final cubit = LocaleCubit(
    LocalAppPreferencesRepository(
      MemoryPreferences(code: language.locale.languageCode),
    ),
  );
  await cubit.restore([const Locale('en')]);
  addTearDown(() async {
    if (!cubit.isClosed) await tester.runAsync(cubit.close);
  });
  final repository = DemoAuthRepository(MemorySessionStorage());
  final auth = AuthBloc(repository);
  addTearDown(() async {
    await auth.close();
    await repository.dispose();
  });
  final app = ErpApp(
    localeCubit: cubit,
    authBloc: auth,
    routerOverride: createPreviewRouter(),
  );
  await tester.pumpWidget(
    key == null ? app : RepaintBoundary(key: key, child: app),
  );
  await pumpTransitions(tester);
  return cubit;
}

Future<void> unmountApp(WidgetTester tester, LocaleCubit locale) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await pumpTransitions(tester);
  final closing = locale.close();
  await pumpTransitions(tester);
  await closing;
}

void main() {
  setUpAll(() async {
    for (final font in {
      'Manrope': 'assets/fonts/Manrope-SemiBold.ttf',
      'IBMPlexSansArabic': 'assets/fonts/IBMPlexSansArabic-Regular.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      await (FontLoader(font.key)..addFont(rootBundle.load(font.value))).load();
    }
  });
  for (final language in AppLanguage.values) {
    for (final width in [390.0, 768.0, 1280.0, 1600.0]) {
      testWidgets(
        '${language.name} preview fits $width and mirrors its shell',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 900);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final key = GlobalKey();
          await mountApp(tester, language, key: key);
          final context = tester.element(find.byType(AppPage));
          expect(find.text(context.l10n.designSystemSubtitle), findsOneWidget);
          expect(
            Directionality.of(context),
            language == AppLanguage.arabic
                ? TextDirection.rtl
                : TextDirection.ltr,
          );
          expect(tester.takeException(), isNull);
          final prefix =
              'preview_${language.locale.languageCode}_${width.toInt()}';
          await capture(tester, key, '${prefix}_top');
          if (width >= 1000) {
            final sidebar = tester.getRect(find.byType(AppSidebar));
            expect(
              sidebar.center.dx,
              language == AppLanguage.arabic
                  ? greaterThan(width / 2)
                  : lessThan(width / 2),
            );
          }
          for (var i = 0; i < 22; i++) {
            await tester.drag(
              find.byType(SingleChildScrollView).first,
              const Offset(0, -600),
            );
            await pumpTransitions(tester);
            expect(tester.takeException(), isNull);
          }
          if (width == 390 || width == 1280) {
            for (final section in {
              'forms': find.byType(AppPasswordField),
              'feedback': find.byType(AppLoadingState),
              'table': find.byType(AppDataTable),
            }.entries) {
              await tester.ensureVisible(section.value);
              await pumpTransitions(tester);
              await capture(tester, key, '${prefix}_${section.key}');
            }
          }
          await tester.pumpWidget(const SizedBox.shrink());
          await pumpTransitions(tester);
        },
      );
    }
    testWidgets('${language.name} dialogs, sheets and pickers are localized', (
      tester,
    ) async {
      final key = GlobalKey();
      await mountApp(tester, language, key: key);
      final l10n = tester.element(find.byType(AppPage)).l10n;
      await tester.tap(find.text(l10n.openDialog));
      await pumpTransitions(tester);
      expect(find.text(l10n.reviewChanges), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(AlertDialog))),
        language == AppLanguage.arabic ? TextDirection.rtl : TextDirection.ltr,
      );
      await capture(tester, key, 'dialog_${language.locale.languageCode}');
      await tester.tap(find.text(l10n.cancel));
      await pumpTransitions(tester);
      expect(find.text(l10n.reviewChanges), findsNothing);
      await tester.ensureVisible(find.text(l10n.previewBottomSheet));
      await pumpTransitions(tester);
      await tester.tap(find.text(l10n.previewBottomSheet));
      await pumpTransitions(tester);
      expect(find.text(l10n.quickDetails), findsOneWidget);
      await capture(tester, key, 'sheet_${language.locale.languageCode}');
      await tester.tap(find.text(l10n.done));
      await pumpTransitions(tester);
      await tester.ensureVisible(find.byType(AppDateField));
      await pumpTransitions(tester);
      await tester.tap(find.byType(AppDateField));
      await pumpTransitions(tester);
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(find.text(l10n.cancel), findsOneWidget);
      await tester.tap(find.text(l10n.cancel));
      await pumpTransitions(tester);
      await tester.ensureVisible(find.byType(AppTimeField));
      await pumpTransitions(tester);
      await tester.tap(find.byType(AppTimeField));
      await pumpTransitions(tester);
      expect(find.byType(TimePickerDialog), findsOneWidget);
      await tester.tap(find.text(l10n.cancel));
      await pumpTransitions(tester);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Selector preserves route, router, form and feature state', (
    tester,
  ) async {
    final locale = await mountApp(tester, AppLanguage.english);
    final context = tester.element(find.byType(AppDropdown<PreviewLocation>));
    final preview = context.read<PreviewCubit>();
    final router = GoRouter.of(context);
    preview.location(PreviewLocation.remote);
    preview.date(DateTime(2026, 9, 17));
    preview.filter(true);
    await pumpTransitions(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(AppLanguageSelector),
      ),
    );
    await pumpTransitions(tester);
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is PopupMenuItem<AppLanguage> &&
            widget.value == AppLanguage.arabic,
      ),
    );
    await pumpTransitions(tester);
    final next = tester.element(find.byType(AppDropdown<PreviewLocation>));
    expect(locale.state.language, AppLanguage.arabic);
    expect(Directionality.of(next), TextDirection.rtl);
    expect(find.text(next.l10n.designSystemSubtitle), findsOneWidget);
    expect(identical(preview, next.read<PreviewCubit>()), true);
    expect(identical(router, GoRouter.of(next)), true);
    expect(router.routeInformationProvider.value.uri.path, '/design-system');
    expect(preview.state.location, PreviewLocation.remote);
    expect(preview.state.activeOnly, true);
    expect(preview.state.date, DateTime(2026, 9, 17));
    router.go('/');
    await pumpTransitions(tester);
    final saved = locale.changeLanguage(AppLanguage.english);
    await pumpTransitions(tester);
    await saved;
    expect(router.routeInformationProvider.value.uri.path, '/');
    expect(
      find.text(tester.element(find.byType(AppPage)).l10n.workspaceTitle),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpTransitions(tester);
    final closing = locale.close();
    await pumpTransitions(tester);
    await closing;
  });
  testWidgets('Preference save failure appears once in the selected language', (
    tester,
  ) async {
    final storage = MemoryPreferences()..failWrites = true;
    final locale = LocaleCubit(LocalAppPreferencesRepository(storage));
    final repository = DemoAuthRepository(MemorySessionStorage());
    final auth = AuthBloc(repository);
    addTearDown(() async {
      await auth.close();
      await repository.dispose();
    });
    await tester.pumpWidget(
      ErpApp(
        localeCubit: locale,
        authBloc: auth,
        routerOverride: createPreviewRouter(),
      ),
    );
    await pumpTransitions(tester);
    expect(find.byType(AppLanguageSelector), findsNWidgets(2));
    final saving = locale.changeLanguage(AppLanguage.arabic);
    await pumpTransitions(tester);
    await saving;
    final l10n = tester.element(find.byType(AppPage)).l10n;
    expect(find.text(l10n.failurePreferencesWrite), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(AppPage))),
      TextDirection.rtl,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpTransitions(tester);
    final closing = locale.close();
    await pumpTransitions(tester);
    await closing;
  });
  testWidgets('Visible validation translates without clearing entered text', (
    tester,
  ) async {
    final locale = await mountApp(tester, AppLanguage.english);
    final en = tester.element(find.byType(AppPage)).l10n;
    final nameField = find.widgetWithText(TextFormField, en.fullName);
    await tester.ensureVisible(nameField);
    await pumpTransitions(tester);
    await tester.enterText(nameField, 'Example User');
    tester.state<FormState>(find.byType(Form)).validate();
    await pumpTransitions(tester);
    expect(find.text(en.fieldRequired), findsOneWidget);
    final saving = locale.changeLanguage(AppLanguage.arabic);
    await pumpTransitions(tester);
    await saving;
    final ar = tester.element(find.byType(AppPage)).l10n;
    expect(find.text(ar.fieldRequired), findsOneWidget);
    expect(find.text(en.fieldRequired), findsNothing);
    expect(
      tester
          .state<FormFieldState<String>>(
            find.widgetWithText(TextFormField, ar.fullName),
          )
          .value,
      'Example User',
    );
    await unmountApp(tester, locale);
  });

  testWidgets('Already-open dialog and sheet follow language changes', (
    tester,
  ) async {
    final locale = await mountApp(tester, AppLanguage.english);
    var l10n = tester.element(find.byType(AppPage)).l10n;
    await tester.tap(find.text(l10n.openDialog));
    await pumpTransitions(tester);
    final firstSave = locale.changeLanguage(AppLanguage.arabic);
    await pumpTransitions(tester);
    await firstSave;
    l10n = tester.element(find.byType(AppPage)).l10n;
    expect(find.text(l10n.reviewChanges), findsOneWidget);
    expect(find.text(l10n.confirmationPreview), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(AlertDialog))),
      TextDirection.rtl,
    );
    await tester.tap(find.text(l10n.cancel));
    await pumpTransitions(tester);
    await tester.ensureVisible(find.text(l10n.previewBottomSheet));
    await pumpTransitions(tester);
    await tester.tap(find.text(l10n.previewBottomSheet));
    await pumpTransitions(tester);
    final secondSave = locale.changeLanguage(AppLanguage.english);
    await pumpTransitions(tester);
    await secondSave;
    l10n = tester.element(find.byType(AppPage)).l10n;
    expect(find.text(l10n.quickDetails), findsOneWidget);
    expect(find.text(l10n.quickDetailsSubtitle), findsOneWidget);
    await tester.tap(find.text(l10n.done));
    await pumpTransitions(tester);
    await unmountApp(tester, locale);
  });

  testWidgets('Already-visible snackbar follows language changes', (
    tester,
  ) async {
    final locale = await mountApp(tester, AppLanguage.english);
    var context = tester.element(find.byType(AppPage));
    AppFeedback.showMessage(
      context,
      message: (l10n) => l10n.previewActionComplete,
    );
    await pumpTransitions(tester);
    expect(find.text(context.l10n.previewActionComplete), findsOneWidget);
    final saving = locale.changeLanguage(AppLanguage.arabic);
    await pumpTransitions(tester);
    await saving;
    context = tester.element(find.byType(AppPage));
    expect(find.text(context.l10n.previewActionComplete), findsOneWidget);
    await unmountApp(tester, locale);
  });

  testWidgets('Arabic fits compact screens with enlarged text', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 900);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await mountApp(tester, AppLanguage.arabic);
    for (var i = 0; i < 28; i++) {
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -600),
      );
      await pumpTransitions(tester);
      expect(tester.takeException(), isNull);
    }
  });
}
