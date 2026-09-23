# Localization sources

Translation **sources** are split by ERP module. The merged `app_en.arb` /
`app_ar.arb` and the generated Dart are outputs — never edit them by hand.

## Where to add a translation

| You are working on | Edit this source |
| --- | --- |
| Generic UI vocabulary (Save, Cancel, Search, Status, ...) | `lib/l10n/common/common_en.arb` + `common_ar.arb` |
| Platform (auth, profile, notifications, sync, shell, workspace) | `lib/platform/l10n/platform_en.arb` + `platform_ar.arb` |
| HR (dashboard, employees, attendance, leave, holidays, shifts, locations, policies, reports) | `lib/modules/hr/l10n/hr_en.arb` + `hr_ar.arb` |
| Services (future phases) | `lib/modules/services/l10n/services_en.arb` + `services_ar.arb` |

Add the key to **both** the English and the Arabic source file. Do not edit
`lib/l10n/generated/app_en.arb` / `app_ar.arb` directly.

## Generate

```sh
dart run tool/l10n/generate.dart
```

This merges and validates the module sources, then runs `flutter gen-l10n`.
If you prefer explicit steps:

```sh
dart run tool/l10n/merge_arb.dart
flutter gen-l10n
```

The committed `lib/l10n/generated/app_en.arb` / `app_ar.arb` must stay in sync
with the sources; a test fails otherwise.

## Rules

- **Unique keys.** A message key must be globally unique. A duplicate across
  modules fails the merge with both source files named; nothing is silently
  overwritten.
- **English/Arabic parity.** Every English message needs an Arabic message and
  vice versa. Missing keys fail the merge.
- **Placeholders.** ICU placeholders such as `{name}` must be preserved in the
  Arabic message. Placeholder drift fails the merge.
- **Metadata.** `@key` metadata stays paired with its message through the merge.
- **Reuse common keys.** If a concept is generic (Save, Cancel, Search), use the
  existing `common` key instead of a module-specific duplicate.
- **Business terms** stay with their owner: Employee/Attendance/Leave/Holiday →
  HR; Service Enquiry/Inspection/Work Execution → Services;
  Profile/Password/Notification → Platform.

## Adding a new module

1. Create `lib/modules/<module>/l10n/<module>_en.arb` and `_ar.arb`.
2. Register it in `tool/l10n/arb_merger.dart` (`l10nModules`).
3. Run `dart run tool/l10n/generate.dart`.

Adding a new **language** means adding `<module>_<locale>.arb` to each registered
module and regenerating; no feature code changes.
