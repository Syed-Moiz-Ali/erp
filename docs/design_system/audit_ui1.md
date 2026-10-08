# UI-1 — Product-wide Design System & Visual Foundation

Phase UI-1 centralizes the visual foundation of the ERP. It establishes the
tokens, semantic type scale, semantic color palette, light/dark themes,
component states, text-scaling policy and RTL-safe primitives that every
feature screen will migrate to in later phases.

**No business logic, permissions, workflows, repositories, entities, routes,
schemas or outbox/sync code was changed.** `schemaVersion` stays **18**. Feature
screens were deliberately **not** redesigned; UI-1 only improves the shared
foundation and marks raw styling for later migration.

## Token architecture

| Concern | Single source of truth |
| --- | --- |
| Typography | `lib/design_system/theme/app_typography.dart` |
| Colors | `lib/design_system/theme/app_colors.dart` |
| Spacing | `lib/design_system/theme/app_spacing.dart` |
| Radius | `lib/design_system/theme/app_radius.dart` |
| Borders | `lib/design_system/theme/app_borders.dart` |
| Elevation | `lib/design_system/theme/app_elevation.dart` |
| Motion | `lib/design_system/theme/app_motion.dart` |
| Dimensions / control + icon sizes | `lib/design_system/theme/app_dimensions.dart` |
| Breakpoints | `lib/design_system/theme/app_breakpoints.dart` |
| Text-scale policy | `lib/design_system/theme/app_text_scaling.dart` |
| Theme assembly | `lib/design_system/theme/app_theme.dart` |

## Semantic typography roles

`display`, `displaySmall`, `timer`, `pageTitle`, `authTitle`, `sectionTitle`,
`cardTitle`, `bodyLarge`, `body`, `bodySmall`, `labelLarge`, `label`,
`labelMedium`, `labelSmall`, `formLabel`, `inputValue`, `button`, `tableHeader`,
`tableCell`, `status`, `overline`, `caption`, `metadata`, `code`, `metricValue`,
`metricLabel`, `metricSupporting`.

Weight discipline: **400 / 500 / 600** across the interface, **700** reserved
for the display/page-title tier.

## Hard-coded style audit (UI-1 snapshot)

Counts are raw textual occurrences in `lib/**/*.dart` excluding generated files
(460 non-generated Dart files).

| Pattern | Occurrences |
| --- | --- |
| `fontSize:` | 49 |
| `FontWeight.` | 87 |
| `Color(0x...)` | 124 |
| `Colors.*` (Material) | 64 |
| `BorderRadius.circular` | 108 |
| `EdgeInsets` | 257 |
| `SizedBox(` | 854 |
| `BoxShadow(` | 18 |
| `BoxDecoration(` | 64 |

### Highest-impact duplicates to migrate in later phases

1. **`app_auth_layout.dart`** — 9 raw `fontSize` and 4 raw hex colors. The auth
   surface still authors its own display sizes instead of `authTitle` /
   `pageTitle` / `body`. Migrate first: it is one focused screen family.
2. **`app_theme.dart`** — 1 `fontSize` and 7 raw hex (menu shadow colors,
   `0x1A120815`). Replace with `AppElevation` shadow tokens.
3. **`app_elevation.dart`** — 14 raw hex. Intentional: this is the token file;
   the hard-coded alpha shadows are the canonical definitions.
4. **`app_language_selector.dart`** — 5 raw hex colors used by the language
   popup; replace with surface/border/elevation tokens.
5. **`app_cards.dart`** — 4 raw hex and a `0x1F38BDF8` info tint; most card
   colors are now theme-aware, remaining raw values are status tints that should
   route through `AppColors.darkInfo` / `AppStatus`.
6. **`app_user_menu.dart` / `app_navigation.dart`** — 2 raw `fontSize` each;
   switch to `typography.label` / `typography.cardTitle`.
7. **`platform/auth/presentation/pages/*`** — 10 raw hex across login/change
   password; migrate to `AppColors` semantic tokens.
8. **`SizedBox(` (854)** — overwhelmingly geometric gaps. Not a defect by
   itself; enforce `AppSpacing` values during feature migration rather than
   rewriting them now.

Feature pages (`lib/modules/**`, `lib/shared/**`) contain almost no raw
`fontSize` (long tail of one-off occurrences in print/export and calendar
pages). They are intentionally untouched in UI-1.

## Deprecated / discouraged patterns

- Raw `fontSize` / `FontWeight` outside `app_typography.dart`.
- Raw `Color(0x..)` / `Colors.*` for text, borders, surfaces and status.
- `BorderRadius.circular(<literal>)` instead of `AppRadius`.
- Ad-hoc `EdgeInsets` values not on the `AppSpacing` scale.
- `fontWeight` on every title; use the semantic style instead.
- Material `Chip` directly for status/filter/selection/metadata — use
  `AppStatusBadge`, `AppFilterChip`, `AppSelectionChip`, `AppMetadataChip`.
- Disabled inputs for read-only business context — use `AppReadOnlyField`.
- Giant centered spinners — use the geometry-aware `AppTableSkeleton`,
  `AppDetailSkeleton`, `AppDashboardSkeleton`, `AppFormSkeleton`.

These are documented, not removed, so following phases migrate them gradually.

## UI-7 visual-debt update (Part A)

Counts are raw textual occurrences in `lib/**/*.dart` excluding generated files
(468 non-generated Dart files). The counts moved slightly because the UI-7
specialized components and earlier UI-2…UI-6 migrations added new shared widgets
that legitimately use `BorderRadius.circular(AppRadius.x)` /
`EdgeInsets.all(AppSpacing.x)` token wrappers.

| Pattern | UI-1 | UI-7 |
| --- | --- | --- |
| `fontSize:` | 49 | 50 |
| `FontWeight.` | 87 | 75 |
| `Color(0x...)` | 124 | 124 |
| `Colors.*` (Material) | 64 | 65 |
| `BorderRadius.circular` | 108 | 134 |
| `EdgeInsets` | 257 | 272 |
| `BoxShadow(` | 18 | 18 |
| `BoxDecoration(` | 64 | 83 |

### Classification (UI-7)

- **Valid design-system implementation** — `BorderRadius.circular(AppRadius.*)`,
  `EdgeInsets.*(AppSpacing.*)`, `BoxDecoration` inside the token/theme files and
  the specialized primitives. Not debt.
- **Legitimate one-off optical detail** — the calendar grid (`app_calendar.dart`)
  micro sizes (`fontSize: 9.5`, 1–3px paddings) that do not belong on the global
  spacing/type scale; `app_elevation.dart` shadow hex values; auth brand colours.
- **Migration debt (remaining)** — raw `Colors.white` / `const Color(0xFF94A3B8)`
  in the auth surfaces (`change_password_page.dart` accepts the UI-1 auth
  palette exception); any residual module-local decoration.

### Migrated in UI-7 Part A

- Settings hubs (HR/general + Services) on `AppSettingsHub`/`AppSettingsRow`.
- Users & Access list on the UI-4 collection language.
- Users & Access detail editor on `AppAccessSummary`, `AppPermissionMatrix`,
  `AppPermissionGroup`, `AppScopeSelector`, `AppDetailHeader`.
- Company Modules on `AppModuleToggleRow`.
- Supporting UX (profile, change password, reminders, sync) on UI primitives.

### Remaining / intentionally excluded

- Reports, chart panels, leave calendar and holiday management — **UI-7 Part B**.
- Auth-surface raw colours — intentionally excluded (brand exception, UI-1 §57).
- Platform super-admin module management — intentionally kept visually distinct
  from company module enablement (different ownership model).
