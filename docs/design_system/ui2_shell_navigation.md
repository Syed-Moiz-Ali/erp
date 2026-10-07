# UI-2 — App Shell, Navigation & Global Page Layout

This document is the contract for the ERP application frame. It defines what
the shell owns and what feature screens own, so every current and future screen
aligns without re-implementing shell concerns.

## 1. Shell architecture

There is **one** ERP shell:

- `AppShell` (`lib/app/shell/app_shell.dart`) is the authenticated frame. It
  resolves navigation from the existing `NavigationResolver`/capability
  architecture and never re-implements authorization.
- `AppResponsiveScaffold` (`lib/design_system/components/layout/app_responsive_scaffold.dart`)
  chooses the layout for the current UI-1 breakpoint.
- The shell consumes the module registry + capabilities only. It must **not**
  import HR/Services presentation, DAOs or repositories to decide navigation.

Navigation is resolved once per account (`resolver.resolve(...)`) and the same
resolved descriptors drive every layout (desktop sidebar, tablet rail, compact
bottom bar, mobile More sheet). Empty/inaccessible destinations are filtered
out before the shell ever sees them, so an unauthorized item cannot render.

## 2. Sidebar anatomy

`AppSidebar` (`lib/design_system/components/navigation/app_navigation.dart`) has
four deliberate zones:

1. **Product / company header** — `AppSidebarHeader`: product mark
   (`AppProductMark`, existing Bitlogix branding) plus `AppCompanySwitcher`.
2. **Dashboard** — the single universal Dashboard destination, rendered
   standalone (no group label).
3. **Module navigation** — `AppNavigationGroup` blocks in canonical order.
4. **Lower account / utility footer** — account destinations followed by the
   collapse control. The footer never scrolls away with the list.

The navigation list scrolls independently inside the `Expanded`; the header and
footer stay usable.

### Width

One centralized token: `AppDimensions.sidebar = 264` (inside the 240–280
enterprise band). `sidebarLarge` shares the same value — the shell scales the
workspace, not the rail. Collapsed width is `AppDimensions.sidebarCollapsed`
(80) and shows icons + tooltips only (never clipped text). Collapse is restored
from persisted presentation preferences.

### Background & contrast

The sidebar uses the UI-1 surface hierarchy via `Theme.of(context).colorScheme`
(`surface` + `outlineVariant` border), so it stays neutral/light in production
and correctly consumes the authored dark tokens for the Design System Preview.

## 3. Navigation hierarchy

Maximum practical nesting is Module → Feature. Group labels are small semantic
overlines (`AppTypography.overline`) and are not interactive; the localized
label text is rendered as-is (never force-uppercased) so Arabic and other
locales keep their natural casing.

Sections render in a fixed order: Dashboard, HR, Services, Settings/Admin,
Account. Items within a section keep their registration `order`.

- **Human Resources**: Employees → Attendance → Leave → Reports (operational
  first). HR configuration masters remain under the Settings hub
  (`/app/hr/settings`, aliased to the Settings destination) at a different
  visual level — presentation grouping only, routes unchanged.
- **Services**: Enquiries → Job Assignments → Inspections → Material Requests →
  Work Execution → Customers → Sites → Teams → Settings. Individual masters
  (Service Types, Complaint Types, Priorities, Ticket Types, Root Causes, Charge
  Responsibilities, Material Request Purposes) live inside Services Settings,
  not as top-level rows.
- **Dashboard** appears exactly once, top level. HR and Services expose no
  dashboard destination.

Empty groups are never constructed, so a module with zero visible features
disappears entirely.

### Selected / hover / focus

- Selected: restrained combination of `primaryContainer` background, brand
  icon/text and a small leading indicator (desktop expanded only).
- Hover: subtle brand tint (`scheme.primary` at 6%).
- Focus: UI-1 focus treatment (brand at 10%), never a shell-specific color.
- Collapsed rows show a tooltip with the localized label.

Item height is `AppDimensions.navigationTarget` (42) — compact enterprise
density — with centralized `AppSpacing`. No raw sizes/weights/colors are used.

## 4. Top bar

`AppTopBar` is a `PreferredSizeWidget` of height `AppDimensions.topBar` (64).
It carries only: optional context/breadcrumb, optional real search, the
notification control and the account control. Separation is a subtle bottom
border (`colorScheme.outlineVariant`), never a heavy shadow.

There is **no fake global search** (UI-2 §28). A search affordance renders only
if a genuine `onSearch` callback is supplied; the shell does not supply one.
Feature-specific search lives inside feature pages.

- **Notifications** — `AppNotificationButton`: icon, localized tooltip,
  keyboard focus, and a bounded unread badge driven by real `NotificationBadgeCubit`
  data (`NotificationBell` composes it). No giant badge.
- **Profile** — `AppUserMenu`/`AppProfileMenu`: avatar/initials from the real
  user, UI-1 menu foundations, only real options (Profile, Change password,
  Language, Sign out), busy/disabled state while signing out.
- **Company context** — `AppCompanySwitcher`: initials avatar + active company
  name. A dropdown affordance is shown only when switching is actually possible;
  with a single accessible company there is no pointless dropdown.

## 5. Page workspace & global width

`AppPage` owns:

- the single global content max width `AppDimensions.contentMaxWidth` (1200),
- responsive horizontal/vertical padding,
- horizontal centering **inside the main workspace** (sidebar excluded),
- scroll ownership.

Responsive outer padding (UI-2 §37):

| Breakpoint | Size | Padding |
| --- | --- | --- |
| < 600 | compact | 16 |
| < 1000 | medium | 20 |
| < 1440 | expanded | 24 |
| ≥ 1440 | large | 32 |

The page centers the constrained box inside the workspace (the `Expanded`
beside the sidebar), so at 1920 the free space left/right of the 1200 content
area is balanced and excludes the sidebar width.

Feature screens must not add their own max-width wrappers or page padding. Audit
outcomes (UI-2 §104–§106): `AppPage` was already the single owner for HR and
Services screens; `AppFormPage` delegates to `AppPage`; no redundant
`AppContentMaxWidth` usage remains in feature pages, so there is exactly one
centering point per page.

## 6. Page header

`AppPageHeader` (UI-1) is the standard top-page header: title (`pageTitle`),
optional subtitle, optional breadcrumbs, optional status, primary + secondary
actions. Feature pages migrate their obvious title/action areas to it; internals
are not redesigned in UI-2.

- Primary action: top-right desktop, permission-aware, stacked on compact.
- `AppBreadcrumbs`: compact, secondary text, stronger current item, clickable
  ancestors, RTL-mirrored separators. Used selectively (e.g. Services /
  Inspections / INS-…, HR / Employees / EMP-…), not on shallow list pages.

## 7. Scroll ownership

- Desktop: the sidebar list scrolls independently; the workspace `AppPage`
  scrolls; the top bar stays stable.
- No `SingleChildScrollView` inside the shell inside another list produces
  stacked scrollbars; `AppPage` is the single page scroll owner.
- Centralized web scroll behavior is provided by the app-level
  `ScrollConfiguration`; screens do not style scrollbars individually.

## 8. Responsive behavior

Breakpoints are UI-1 `AppBreakpoints` (600 / 1000 / 1440):

- **Large / normal desktop (≥ 1000)**: expanded `AppSidebar` (264) + sticky top
  bar + centered content.
- **Tablet (600–999)**: `AppNavigationRail` (icons + tooltips) + top bar.
- **Compact (< 600)**: purpose-built mobile pattern — top bar + a small bottom
  navigation for primary destinations plus the grouped `AppMobileNavigation`
  sheet via More (company context + Dashboard + module grouping + account). The
  desktop sidebar is never squeezed into mobile, and no new bottom navigation
  concept was introduced: this is the product's existing deliberate pattern.
- Continuous resize produces no `RenderFlex` overflow or clipped nav text, and
  holds at the maximum allowed text scale (1.3).

## 9. RTL & Arabic

- The sidebar mirrors automatically (it is the leading child of a `Row`); no
  hardcoded left/right.
- Directional icons (chevrons, collapse/expand) mirror via
  `Directionality`; feature icons do not.
- Content centering stays correct with the sidebar on the right.
- Typography uses `IBMPlexSansArabic` only through central `AppTypography`;
  shell widgets never set a font family manually.

## 10. Accessibility

- Sidebar rows: keyboard traversal, visible UI-1 focus, `Semantics(selected)`.
- Collapsed icons, the notification control and icon-only top-bar actions have
  tooltips.
- The mobile drawer/sheet (More) preserves company context and account access
  with accessible touch targets.

## 11. Localization

All shell text flows through generated localization (EN + AR). Shell widgets
reference keys (`shellDashboard`, `navSectionHr`, `navSectionServices`,
`shellNotifications`, …) and never hardcode Dashboard / Human Resources /
Services / Settings strings.

## 12. Migration rule for future phases (UI-2 §117)

> **Feature screens own their CONTENT.**
>
> `AppShell` / `AppPage` own **navigation, workspace, max width, outer page
> padding and the global header layout.** Feature screens must not recreate
> shell concerns.

Concretely: a feature page wraps its body in `AppPage` (optionally with an
`AppPageHeader`), uses `AppTypography`/`AppSpacing`/`AppRadius`/color tokens,
and never adds its own page max-width, page padding, top bar, or navigation.
