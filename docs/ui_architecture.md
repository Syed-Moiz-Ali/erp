# UI Architecture & Reusable Patterns

Phase 13 reference for building any screen (current or future modules) without
inventing new tokens, spacing, tables, or dialogs.

## 1. Design tokens (single source of truth)

All tokens live in `lib/design_system/theme/`:

| Concern      | Token                | Notes |
|--------------|----------------------|-------|
| Color        | `AppColors`          | Semantic names only (`surface`, `borderDefault`, `textPrimary`, `textSecondary`, `textMuted`, `success`, `warning`, `danger`, `info`, `brandPrimary`, `*Subtle`). Never use `Colors.red/green/blue/grey` in feature code. |
| Typography   | `AppTypography`      | `display`, `pageTitle`, `sectionTitle`, `cardTitle`, `body`, `bodySmall`, `label`, `button`, `caption`, `metadata`, `code`, `metricValue`, `metricLabel`, `metricSupporting`, `tableHeader`, `timer`. Access via `AppTypography.of(context)`. |
| Spacing      | `AppSpacing`         | `xxs(2) xs(4) sm(8) md(12) lg(16) xl(20) xxl(24) section(32) wide(40) page(48)`. |
| Radius       | `AppRadius`          | Scale `radiusXs..2Xl` plus semantic aliases (`badge`, `button`, `input`, `chip`, `card`, `panel`, `dialog`, `bottomSheet`). |
| Sizes        | `AppDimensions`      | Sidebar/rail/topbar, content widths (`form`, `details`, `content`, `dashboard`, `wideContent`, `dialog`), icon scale (`iconXs..iconLg`), control scale (`controlSm/Md/Lg`), table heights. |
| Borders      | `AppBorders`         | Border widths and radii helpers. |
| Elevation    | `AppElevation`       | Shadows reserved for dialogs/popovers/floating layers only. |
| Motion       | `AppMotion`          | `fast(150ms) normal(220ms) slow(300ms)` + entrance/fade helpers; respects reduced motion. |
| Breakpoints  | `AppBreakpoints`     | `compact <600`, `medium <1000`, `expanded <1440`, `large >=1440`. |

## 2. Responsive rules

- Classify with `AppBreakpoints.of(context)` or `AppSize`; never compare
  `MediaQuery.sizeOf(context).width` in feature code.
- Content widths are semantic: forms use `AppDimensions.form`, detail/text
  pages `details`, dashboards `dashboard`, tables may stretch to `wideContent`.
- Mobile: single column, cards/sheets, primary action reachable.
- Tablet (`medium`): NavigationRail, two-column layouts, compact tables.
- Desktop (`expanded`/`large`): tables, split layouts, higher density.
- Do not nest a scrollable (`ListView`) inside `AppPage` — `AppPage` is a
  `SingleChildScrollView`. Use `Column` inside it, or build a dedicated
  sliver body.

## 3. Page composition

```
AppPage(
  header: AppPageHeader(title:, subtitle:, actions: [...]),
  filters: AppFilterBar(children: [...]),   // optional
  child: Column(... sections ...),
)
```
`AppPage` owns page padding (`AppSpacing.lg` compact, `AppSpacing.section`
otherwise) and the entrance fade. Feature pages must not add their own outer
page padding or marquee titles.

## 4. Forms

- `AppTextField` / `AppPasswordField` / `AppSelectField` / `AppDropdown` /
  `AppDateField` / `AppTimeField` for all inputs.
- Desktop: two-column grid for logical pairs; mobile: single column.
- Group with `AppFormSection` (title/description/fields) rather than wrapping
  every block in a card.
- Validation errors are locale codes resolved through `AppLocalizations`;
  never surface raw domain/server text.

## 5. Tables & lists

- `AppDataTable` for dense desktop data (heading height `tableHeaderHeight`,
  row height `tableRowHeight`, horizontal scroll fallback).
- `AppTablePagination` for paging.
- Mobile: `AppMobileRecordCard` list instead of a table; show only priority
  fields (name, code, status, key metric).
- Sorting/filtering happens in the repository, not in the widget.

## 6. Filters

- Desktop: `AppToolbar` + `AppFilterBar` chips/popovers.
- Mobile: `AppBottomSheet` filter sheet with Reset/Apply.
- `AppFilterChip` for selected/unselected states.

## 7. Feedback

- `AppFeedback.showMessage` (localized snackbar) for transient results.
- `AppNotice` for inline banners; `AppStatusBadge` / `AppCountBadge` for status.
- `AppEmptyState` (what happened + what to do) and `AppErrorState` (safe
  message + optional retry).
- Loading: `AppSkeleton` for first load, button spinner for mutations, retained
  content + subtle indicator for refresh.

## 8. Dialogs & sheets

- `AppDialog` for confirmations/forms; bounded `AppDimensions.dialog` width.
- `AppConfirmationDialog` for destructive/intent confirmations with specific
  copy (e.g. "Deactivate employee"), not "Are you sure?".
- `AppBottomSheet` for mobile actions/filters; safe areas + scrollable body.

## 9. Permissions & scope

- Authorization is permission/scope based (`AppPermission`,
  `PermissionChecker`, `AttendanceScopeResolver`, module registry guards).
- Roles only select grant templates or presentation defaults — never gate
  routes/actions by comparing `AppRole`.
- Repositories re-validate company scope; UI filters are never the security
  boundary.

## 10. Localization & RTL

- Every visible string lives in the per-module localization sources under `lib/l10n`, `lib/platform/l10n` and `lib/modules/*/l10n` (merged into `lib/l10n/generated`)
  (`flutter gen-l10n`). No hardcoded UI text.
- Use directional APIs: `EdgeInsetsDirectional`, `AlignmentDirectional`,
  `PositionedDirectional`, `BorderDirectional`. The automated test
  `localization_test.dart` fails on physical `left/right` usage.
- Format dates/times/numbers/durations with `AppDateFormatter`,
  `AppTimeFormatter`, `AppNumberFormatter`.
- Directional icons (`chevron_*`) mirror in RTL; non-directional icons
  (clock, location pin, search, check) do not.

## 11. Where components live

`lib/design_system/components/<group>/` — buttons, cards, dialogs,
empty_states, feedback, filters, headers, inputs, layout, navigation, sheets,
skeletons, status, tables, timelines. Add reusable UI here, not inside a
feature. Feature-specific widgets stay under
`lib/features/<feature>/presentation/widgets/`.

## 12. Debug-only tools

`DesignSystemPreviewPage`, `SyncInspectorPage` and demo credentials are gated
behind `kDebugMode` / `AppConfig.demoAuthEnabled` and must never appear in
production navigation.
