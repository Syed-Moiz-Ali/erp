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
