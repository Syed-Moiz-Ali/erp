# Modular localization architecture

Localization uses Flutter's `gen_l10n`. There is exactly **one** runtime API:
`context.l10n` backed by `AppLocalizations`. There are no per-module delegates
(`HrLocalizations`, `ServicesLocalizations`, ...) and no runtime ARB loading.

## Source tree

Translation sources follow the module boundaries from
[modules.md](modules.md):

```text
lib/l10n/common/          common_en.arb, common_ar.arb
lib/platform/l10n/        platform_en.arb, platform_ar.arb
lib/modules/hr/l10n/      hr_en.arb, hr_ar.arb
lib/modules/services/l10n/ services_en.arb, services_ar.arb
```

`lib/l10n/generated/` holds the **generated** outputs: the merged
`app_en.arb` / `app_ar.arb` and the generated `app_localizations*.dart`. Never
edit generated files.

## Pipeline

```text
module source ARBs
        -> deterministic merge + validation (tool/l10n/merge_arb.dart)
        -> generated/app_en.arb, generated/app_ar.arb
        -> flutter gen-l10n
        -> AppLocalizations (context.l10n)
```

## Commands

```sh
dart run tool/l10n/generate.dart   # merge + validate + flutter gen-l10n
```

or the two explicit steps:

```sh
dart run tool/l10n/merge_arb.dart
flutter gen-l10n
```

`tool/l10n/arb_merger.dart` holds the merge/validation logic and the central
`l10nModules` registration. The historical monolithic ARBs were split once by a
throwaway migration helper; source ownership is now expressed directly by the
module ARB files, so no classification algorithm is retained.

## Validation

The merge fails (non-zero exit, actionable message, no silent overwrite) on:

- malformed ARB JSON, naming the offending file;
- duplicate message keys across modules, naming both files;
- orphan `@key` metadata without its message;
- missing English or Arabic counterpart keys (parity);
- ICU placeholder drift between English and Arabic.

`test/localization_architecture_test.dart` exercises each failure mode and also
fails if the committed generated ARBs are out of sync with the sources.

## Key ownership

| Domain | Source |
| --- | --- |
| Generic UI vocabulary (Save, Cancel, Search, Status, ...) | `common` |
| Auth, profile, notifications, sync, shell, workspace, settings landing | `platform` |
| Dashboard, employees, attendance, corrections, leave, holidays, shifts, work locations, attendance policies, attendance reports | `hr` |
| Service Enquiry, Scheduling, Inspection, Material Request, Work Execution | `services` (future) |

Moving a key between modules does not require renaming it: the public key stays
the same, only its source file changes.

## l10n.yaml

```yaml
arb-dir: lib/l10n/generated
template-arb-file: app_en.arb
output-dir: lib/l10n/generated
output-localization-file: app_localizations.dart
```

`context.l10n`, `AppLocalizations.delegate` and
`AppLocalizations.supportedLocales` are unchanged. Supported locales remain
English and Arabic; adding a locale means adding `<module>_<locale>.arb` files
and regenerating, with no feature-code changes.
