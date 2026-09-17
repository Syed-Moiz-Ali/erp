> Historical Phase 2 handoff. The Dashboard placeholder is now replaced by the [Phase 3 dashboard](phase_3_dashboard.md); the shell architecture remains in use.

# Phase 2 completion report

Completed on 2026-09-17 against Flutter 3.35.7 / Dart 3.9.2. Existing design tokens, fonts, localization, authentication, repositories and dependency injection were audited and reused. No packages, fonts, database tables or backend services were added.

## 1. Implemented

The permanent authenticated AppShell replaces the old authenticated-home placeholder. It provides responsive navigation, company information, a localized account menu, search/notification foundations, breadcrumbs, page primitives and centralized access states. Dashboard, Employees, Attendance, Reports, Settings and Profile remain honest placeholders. Change Password and confirmed logout reuse the existing business BLoCs.

## 2. Important files

Created:

- `lib/app/module_registry/navigation_resolver.dart`: navigation/access resolution and safe landing.
- `lib/app/module_registry/registered_modules.dart`: single composition point for six modules and typed destinations.
- `lib/app/router/app_routes.dart`: route and module constants.
- `lib/app/router/app_route_transitions.dart`: reduced-motion-aware route fade.
- `lib/app/shell/app_shell.dart`: authenticated shell integration.
- `lib/app/shell/app_shell_cubit.dart`: sidebar preference only.
- `lib/app/shell/pages/{more_page,module_placeholder_page,profile_placeholder_page,route_status_pages}.dart`: grouped More, six placeholders and access/404 states.
- `lib/design_system/components/navigation/{app_top_bar,app_user_menu,app_breadcrumbs}.dart`: reusable navigation components.
- `lib/design_system/components/layout/app_workspace_layout.dart`: content constraints, responsive toolbar and split view.
- `lib/design_system/theme/app_dimensions.dart`: sidebar, rail, top bar and page widths.
- `test/shell_test.dart`: registry, navigation, router, state and responsive coverage.

Modified:

- `lib/app/module_registry/module_registry.dart`, `lib/app/router/app_router.dart`, `lib/app/erp_app.dart`.
- `lib/bootstrap/{bootstrap,dependencies}.dart` for registry and preference composition/restoration.
- `lib/core/preferences/app_preferences_repository.dart` for scalar sidebar persistence.
- Existing centralized navigation, responsive scaffold, page/header components and design-system barrel.
- English/Arabic ARB resources and generated localizations.
- Demo company module enablement and authentication-page route constants; embedded Change Password layout.
- Existing authentication/unit/widget tests and in-memory preferences adapter.
- README; removed `authenticated_home_placeholder.dart`.

## 3. Module registry architecture

`AppModule` owns an ID, enabled flag and typed `RegisteredDestination` entries. Each entry joins an `ErpModule` navigation descriptor to concrete GoRouter routes. Metadata includes localized label builder, icons, module ID, group, order, all/any permission requirements, mobile priority and visibility flags. The descriptor name is retained for Phase 0 compatibility.

Collections are read-only. Registry validation rejects duplicate IDs/routes/aliases, mismatched module IDs, empty route registrations and routes outside the destination's guarded path/aliases. Longest strict-boundary path ownership handles nested routes without treating `/app/employees-other` as Employees. Account owns the Change Password alias. This is a practical navigation registry, not a plugin runtime or JSON screen generator.

To extend: add feature layers as needed, a route/module constant, ARB labels and one AppModule registration containing real typed screens. Navigation layouts and router branch composition consume it automatically. New permission semantics belong in the existing permission model; local-first repositories remain responsible for data and transactions.

## 4. Permission-driven navigation

AuthContext supplies explicit PermissionSet grants. NavigationResolver checks every required permission and at least one any-permission when declared, sorts allowed destinations by order/ID, and returns ready-to-render desktop/mobile/group configurations. Widgets never check roles to authorize navigation. HR with removed grants loses access despite its role label. Route refresh observes relevant authenticated context changes.

## 5. Company-enabled navigation

The same resolver checks destination/module enabled flags and CompanyContext.enabledModules before permission checks. Disabled modules disappear from discovery and direct access produces ModuleUnavailable. Demo company enables Dashboard, Employees, Attendance, Reports and Settings. Account is intentionally company-independent so Profile and Change Password stay available to authenticated users. Services/Finance are not registered or exposed.

Stored Phase 1 sessions retain their original company metadata; sign out and back in to adopt the expanded demo company fixture. Restoration does not silently rewrite company settings or grants.

## 6. Router structure

StatefulShellRoute.indexedStack creates branches from the registered destinations, plus one utility branch for More/access-denied/module-unavailable/not-found/no-destinations. Public login, reset and bootstrap routes remain outside the authenticated shell. Central constants replace widget route literals.

Unauthenticated deep links retain their destination through bootstrap/login. Company disablement precedes missing permission. Unknown paths lead to localized 404; known but unimplemented nested paths still undergo authentication and access checks first. External return targets are rejected. Prefix highlighting follows the registered owner.

DefaultLandingResolver selects the first allowed destination and safely falls back when none exists. The basic demo Dashboard deliberately requires authentication and company module enablement, with no additional grant. It is not assumed to be enabled for every company.

Branch navigation uses goBranch, preserving navigator/form state in memory across switches, locale changes and breakpoint changes. A nested test-only form proves preservation; logout discards it before the next session. This does not promise process-restart state restoration.

## 7. Mobile

Compact widths use a simpler top bar and centered bottom navigation. Explicit priorities select up to three primary destinations, reserving More for grouped remaining mobile-visible destinations. Employee gets Dashboard/Attendance/More; HR gets Dashboard/Employees/Attendance/More. No role-specific arrays or random truncation exist. Profile is discoverable in More and the account menu.

## 8. Tablet

Medium widths use the same resolved destinations in a compact, scrollable NavigationRail with selected state, semantic labels and tooltips. Company/account access stays available. Short-height tablet coverage verifies that destinations remain reachable without overflow.

## 9. Desktop

Expanded sidebar is 248px; large sidebar is 272px; collapsed is 80px. Selected/hover/focus states, icon alignment, tooltips and directional borders are centralized. Single-entry group headings are suppressed; account/administration entries sit below a restrained separator. Collapse persists through the non-sensitive preferences repository and AppShellCubit, with ordered writes and safe errors. Router selection is not duplicated in Cubit.

Top bar provides breadcrumbs, search, notification and language/account controls. The menu shows avatar/name/email/localized role, Profile, Change Password, Language and confirmed Logout through AuthBloc. Company click shows actual session company information; no switcher is faked. AppPage defaults to 1200px content, with separate form/details/wide tokens, responsive toolbar/header actions and split-view primitives.

## 10. RTL and visual verification

English and Arabic were exercised at 360, 390, 430, 600, 768, 900, 1024, 1280, 1440 and 1920 logical pixels for Employee, HR and Super Admin. Font-loaded widget screenshots were inspected for Employee/HR mobile and desktop in both languages, Super Admin desktop, Arabic More, account menu and collapsed sidebar. Directional alignment/borders place Arabic sidebar on the right; icons/text and breadcrumbs follow RTL. Directional SDK chevrons mirror while clock/people/settings/bell icons remain unchanged.

Tests also cover Arabic at 150% text scale, short tablet height, selected semantics, collapsed tooltips, live language updates of an already-open account menu and stable route/form state. Screenshots are in `artifacts/auth_phase2_*.png`.

## 11. Demo navigation differences

| Account | Resolved destinations |
| --- | --- |
| Employee | Dashboard, Attendance, Profile |
| Manager | Dashboard, Employees, Attendance, Profile |
| HR | Dashboard, Employees, Attendance, Reports, Profile |
| Company Admin | All six placeholders |
| Super Admin | All six placeholders |

These differences derive from explicit fixture grants, not role checks. Employee's self-view permission does not grant the Employees management destination. Reports requires attendanceReportView; Settings requires company/user/role management. Account details from the session are user data and are not translated.

Credentials remain documented in the Phase 1 handoff. Debug enables demos by default; release disables them unless explicitly configured with DEMO_AUTH=true.

## 12. Analyzer

`flutter analyze`: no issues. Formatting, pub get, localization generation and build_runner completed successfully. Locked packages remain unchanged. `flutter build web` also passed, including its WASM dry-run compilation.

## 13. Tests and commands

All 159 tests pass: 84 retained foundation/localization/authentication checks plus 75 shell tests. New coverage includes immutable/valid registrations, five-role grants, disabled modules, mobile priority, safe landing/deep links, scalar preference persistence/errors, the role/language/width matrix, route guards, More/panels, nested branch preservation, logout reset and live RTL updates.

```sh
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze
flutter test
flutter build web
flutter run -d chrome
```

## 14. Genuine limitations

Search has an explicit empty foundation with no fabricated results. Notifications have no feed, count or read state. Company switching, business CRUD, charts, attendance workflows and remote services are not implemented. Password changes in the existing demo source are in-memory. Frontend authorization must be accompanied by backend enforcement once an API is supplied.

Visual review used rendered Flutter widget screenshots; a connected live browser was unavailable. Native Android/iOS/Windows builds and real-device secure-storage round trips have not been executed. Keyboard/focus semantics use framework controls; this is not a full assistive-technology certification. Branch state is in-memory. Dark theme remains a future centralized palette/contrast exercise.

## 15. Exact foundation ready for Phase 3

The next explicitly authorized feature can add typed nested module routes and real pages without restructuring the shell. Available foundations are authenticated user/company/employee context, explicit permission checking and guards, company module enablement, state-preserving branch navigators, centralized responsive page/navigation/form/table components, English/Arabic typography/localization, get_it composition, BLoC workflows, safe Result/Failure handling, Drift/migration/outbox foundations, secure tokens, connectivity, location and SyncCoordinator.

For a real local-first feature, define domain repository contracts; add Drift tables with explicit versioned migration tests; implement transactional local writes and repository streams; introduce business BLoC/use cases as needed; register dependencies and typed routes; reuse design-system and localized resources. No Phase 3 schema or workflow has been started. Stop here and await Phase 3 instructions.
