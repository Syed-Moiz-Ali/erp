# Localization and RTL contract — Phase 0

English and Arabic use [Flutter's official localization system](https://docs.flutter.dev/ui/internationalization). There are no translation services, runtime font services or backend services.

## Resources and generation

`lib/l10n/app_en.arb` is the template; `app_ar.arb` contains the Arabic translations. `l10n.yaml` generates typed `AppLocalizations` into `lib/l10n/generated`. Do not edit generated files. `flutter: generate: true` integrates generation with normal builds.

```sh
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run -d chrome
```

Installed Flutter 3.35.7 pins `intl` to 0.20.2 for localization. No dependency overrides are used. `untranslated_messages.json` reports missing translations; tests also require exact ARB key parity.

Feature code uses the generated APIs through the context extension:

```dart
import 'package:modular_erp/l10n/l10n.dart';
Text(context.l10n.employees)
```

Every app-owned visible label, hint, tooltip, snackbar, accessibility message, validation message and empty/error-state message comes from ARB. Pickers also use Flutter's translated Material localizations. Real user-entered names, records, identifiers and technical diagnostics remain data. The preview's illustrative names are ARB resources because they are demo copy.

Use ARB placeholders for complete messages; never assemble a sentence from English fragments. `continueAction` avoids the reserved Dart keyword `continue`.

## State and persistence

UI → `LocaleCubit` → `AppPreferencesRepository` → `AppPreferencesLocalDataSource` → `SharedPreferencesAsync`.

Only the non-sensitive language code (`en` or `ar`) is stored under `app.preferences.language`. Shared preferences stores this scalar preference, never ERP records or tokens. ERP data remains in Drift and session secrets remain in secure storage. Presentation has no preference-plugin access.

Bootstrap restores locale before `runApp`, with a two-second bounded preference read. Resolution order: valid saved language, first supported device language (including regional matches), then English. Unknown saved codes are ignored. Read failures retain a usable device/default language and expose a typed failure.

Selections update the UI immediately and serialize saves, so rapid changes persist in order. Failed saves retain the session language and show a localized snackbar. Selecting that language again retries saving.

`AppLanguage` owns supported-language metadata; display/native names resolve through ARB. `LocaleCubit` is an application-scoped get_it dependency, provided by value around `MaterialApp.router`. The router lives in `ErpApp` State, outside the locale builder. Language changes preserve router/route, repositories, feature Cubits, form values, sessions and local data.

`AppLanguageSelector` is a centralized checked popup control in the toolbar and preview language section. Login/profile/settings can reuse the same control later. One app-level listener reports preference failures, so multiple selectors never duplicate the same snackbar.

## RTL and responsive layouts

Flutter's localization delegates supply English LTR and Arabic RTL Directionality. Rows and Scaffold drawers automatically place start-side navigation on the right for Arabic. Sidebar borders and asymmetric toolbar spacing use directional properties. Table content, wraps, input labels, leading/trailing elements and headers inherit direction. Pagination chevrons use Flutter's `matchTextDirection: true` icons.

Symmetric padding/alignment has no direction-dependent meaning. Bottom-sheet padding uses `EdgeInsetsDirectional.fromSTEB`. Header actions receive bounded width and wrap; primary-button text is flexible. Cards/sections grow vertically, while tables scroll horizontally on compact layouts.

The preview is tested in both languages at 390, 768, 1280 and 1600 logical pixels; Arabic also passes at 150% text scale. Dialogs, sheets, date/time pickers and live selector changes are exercised. Font-loaded PNGs in `artifacts` support visual review and are not source assets.

## Bundled typography

English uses local Inter. Arabic uses local **Noto Sans Arabic** from its [official font distribution](https://github.com/google/fonts/tree/main/ofl/notosansarabic), with the SIL license included. There are no runtime network font downloads.

`AppTypography.forLocale` / `of(context)` chooses the family centrally, retains the shared size/weight hierarchy, uses Arabic line height 1.65 and removes negative Latin letter spacing. English includes Arabic fallback for native-language names and mixed-script content. `AppTheme.light(locale: ...)` applies the same typography to controls, inputs, buttons and tables.

## Formatting, validation and statuses

`AppDateFormatter`, `AppTimeFormatter` and `AppNumberFormatter` centralize `intl` formatting for dates, month headings, 12/24-hour time, short durations, numbers, percentages and explicit ISO-code currency values. Bootstrap initializes date symbols. Callers supply display-zone times; UI language never selects a timezone or currency.

Generic `ar` follows installed intl data: Arabic date/time names and Western number formatting. Regional `ar_EG` uses Eastern Arabic numeric digits/separators. Do not manually replace digits or assume a region from UI language. Duration and pagination messages use ARB placeholders with formatted numeric values.

Validation rules return language-independent `ValidationIssue` values; presentation calls `issue.message(context.l10n)`. Shared input controls revalidate previously invalid fields after a locale change; entered text, focus and selection remain intact, and untouched fields gain no new errors. Failures contain stable `code`, `FailureKind` and retryability; presentation calls `failure.localizedMessage(context.l10n)`. Core models do not contain English/translated business messages.

Preview locations/statuses are enums, with presentation mappings to localized labels. Future attendance/work-order/invoice/payment statuses follow this pattern. Module IDs, routes, permissions and NavigationGroup identities remain neutral; module names resolve against generated localizations.

## Reactive overlays

Use builders for dialogs/sheets, and LocalizedText resolvers for confirmation copy and feedback. These evaluate under the overlay's current localization context rather than freezing translated strings before opening. Already-open overlays and visible snackbars update with the app language.

```dart
AppDialog.show<void>(context, (dialogContext) => AppDialog(
  title: dialogContext.l10n.reviewChanges,
  child: Text(dialogContext.l10n.confirmationPreview),
));
AppFeedback.showMessage(context, message: (l10n) => l10n.success);
```

Confirmation title/message/confirm-label parameters use LocalizedText functions. `AppBottomSheet.show` accepts a WidgetBuilder. Do not capture `context.l10n` values outside these builders when overlay copy must remain reactive.

## Adding another language

1. Add `app_<code>.arb`, matching template keys and placeholder contracts.
2. Add its `AppLanguage` entry and translated display/native-name metadata. Generated supportedLocales updates automatically.
3. Validate the centrally selected font/fallback for the script; bundle a family and adjust only AppTypography if needed.
4. Regenerate and run translation/layout checks, including direction and larger text.

No screen, repository, router or business-data rewrite is required. Future modules add keys to the same resources and consume `context.l10n` and shared components.

## Files integrated

Created: l10n.yaml, ARB and generated localization files, context extension, core localization state/metadata/formatters, preferences repository/local adapter, typed validation/failure localization, AppLanguageSelector, Arabic font/license, localization tests and memory preference test adapter.

Modified: pubspec/lock, main/bootstrap/DI, ErpApp, module registry/router, typography/theme, existing design-system families, workspace/preview copy and enum state, foundation/widget tests and README. Drift schema and stored ERP data are unchanged.

Phase 0 only. Authentication keys are placeholders; authentication and Finance workflows have not been implemented.

Validation: dependency resolution, localization generation and code generation passed; analyzer has no issues. The final suite contains 34 tests, including live validation/overlay/snackbar translation and single error feedback. Font-loaded English/Arabic screenshots were visually reviewed. Native builds are not validated.
