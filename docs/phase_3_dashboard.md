# Phase 3 — dashboard completion report

Frontend-only implementation on the existing Flutter 3.35.7 / Dart 3.9.2 project. Phase 0/1/2 architecture, authentication, shell, registry, permissions, localized fonts and design system were reused. No backend, business CRUD or attendance workflow was introduced.

## 1. Implemented

The actual `/app/dashboard` page replaces DashboardPlaceholderPage. One dashboard system serves all five accounts through permission-scoped typed data. It includes localized greeting/date, clearly labeled deterministic demo snapshots, metric cards, employee Today/monthly preview, attendance status summary, attention items, recent activity and authorized quick access. Initial skeleton, empty, safe error/retry and content-preserving refresh states work. Mobile pull-to-refresh and a page refresh action dispatch BLoC events.

Search, notifications, account actions and company information continue to use the Phase 2 shell; the dashboard does not duplicate these systems. No Punch In/Out/Break controls or actual correction workflow exist.

## 2. Important files

Created:

- `lib/features/dashboard/domain/dashboard_models.dart`: immutable scope, summary, metric, activity, alert, today and status models with read-only collections.
- `lib/features/dashboard/domain/dashboard_scope_resolver.dart`: permission/company-aware scope selection.
- `lib/features/dashboard/domain/dashboard_repository.dart`: context-explicit repository boundary.
- `lib/features/dashboard/data/demo_dashboard_source.dart`: stable typed fixtures; activity sorted newest first.
- `lib/features/dashboard/data/local_dashboard_repository.dart`: demo/local adapter, data authorization and safe Result failures.
- `lib/features/dashboard/presentation/bloc/dashboard_bloc.dart`: one dashboard workflow BLoC and its events/state.
- `lib/features/dashboard/presentation/dashboard_page.dart`: authenticated route/provider and shared composition.
- `lib/features/dashboard/presentation/dashboard_presentation.dart`: typed localized labels, semantic statuses/icons, greeting and formatted metric values.
- `lib/design_system/components/dashboard/app_dashboard.dart`: reusable layout, section, quick-action, activity, summary and skeleton primitives.
- `test/dashboard_test.dart`, `test/dashboard_widget_test.dart`: domain/BLoC and UI/integration coverage.
- `docs/phase_3_dashboard.md`: this handoff.

Modified:

- `registered_modules.dart`: dashboard route joins the existing stateful branch architecture; optional repository injection supports tests without global services in widgets.
- `bootstrap/dependencies.dart`: get_it registers DashboardRepository and supplies it to module composition.
- `module_placeholder_page.dart`: obsolete dashboard placeholder removed; other Phase 2 placeholders retained.
- Existing AppMetricCard, AppResponsiveGrid, AppPage, AppPageHeader and AppSecondaryButton: restrained semantics/status support, balanced equal-height rows, optional scroll physics, inline compact actions and optional button icon. Original callers retain defaults.
- Central date/time formatter: full localized date and localized whole-hour durations.
- English/Arabic ARB resources and generated localizations, design-system barrel and README.
- `pubspec.yaml`/lock: declared Flutter SDK `flutter_web_plugins` directly because the existing bootstrap imports its URL strategy. No third-party package or chart dependency was added; existing versions and local Inter/Noto Sans Arabic fonts remain unchanged.

## 3. DashboardBloc architecture

UI → DashboardBloc → DashboardRepository → DemoDashboardSource.

DashboardStarted and DashboardRefreshRequested use one serialized event bucket. Rapid submissions coalesce into a single read. State distinguishes initial, loading, loaded, refreshing and failure, with an immutable summary and optional safe Failure. Initial reads show skeletons. Refresh keeps the summary; failure preserves it and displays a localized warning. Retry reloads through the repository. Exceptions from a future repository adapter are converted into safe failures.

The page selects AuthContext through BlocSelector and keys its BLoC provider by that context. Relevant user/company/grant changes replace the old dashboard BLoC and data; locale and minor auth status changes do not recreate it. Logout removes the authenticated shell. The BLoC uses an injected context and repository, never global AuthBloc lookup or demo-specific APIs.

## 4. Repository architecture

DashboardRepository.load(context, refresh: bool) returns Result<DashboardSummary>. The local adapter resolves scope before reading fixtures and filters non-attendance metrics and correction content at the repository boundary. Demo values and activity names/timestamps live in the data source, not widgets. Data is immediately available locally and refresh is deterministic.

No Drift dashboard table duplicates future employee/attendance entities. A later implementation can derive summaries from underlying local repositories, refresh remote data into their local stores first, and return a new local snapshot through this boundary. There is currently no remote request, cache synchronization or live subscription. Production demo gating follows the existing DEMO_AUTH configuration; explicitly disabled demos return a typed safe failure.

## 5. Scope and authorization

When the company enables Attendance:

1. attendanceViewAll → company.
2. Otherwise attendanceViewTeam → team.
3. Otherwise attendanceViewSelf → self.
4. Otherwise none; no implicit self grant.

Disabled Attendance resolves none. Multiple scopes choose the highest permitted scope. Roles do not authorize or select fixture scope.

Additional gates:

- Total Employees: company scope plus employeeViewAll and enabled Employees.
- Team Size: team scope plus employeeViewTeam/All and enabled Employees.
- Locations: workLocationView.
- Active Users: userManage and enabled Settings.
- Pending Corrections/related activity: attendanceApprove or attendanceCorrect; own correction activity additionally permits attendanceRequestCorrection in self scope.

Quick actions consume the existing NavigationResolver output and registry metadata. They never duplicate routes, labels, icons or permission arrays. Disabled/inaccessible modules disappear, and normal route guards apply to direct access. Existing Account menu remains the Profile entry point.

## 6. Centralized dashboard components

AppDashboardGrid reuses AppResponsiveGrid with centralized spacing, text-scale-aware sizing, balanced rows and optional equal-height cards. Equal-height layout measures only the small bounded metric rows, not long ERP lists.

AppDashboardSection reuses AppCard/AppSectionHeader. AppDashboardTwoColumn stacks in compact available space and uses balanced tablet columns or desktop 2:1 content. AppQuickActionCard reuses AppSecondaryButton. AppActivityItem supports text/icon/status/timestamp. AppStatusSummary provides readable semantic rows without decorative charts. AppDashboardSkeleton reuses static AppSkeleton blocks. Existing AppEmptyState/AppErrorState/AppAlert handle empty/error/refresh feedback. AppMetricCard was extended, rather than duplicated, with grouped value semantics and semantic icon status.

One loaded-content entrance uses the existing flutter_animate AppMotion helper (220ms), respecting reduced motion. Refresh does not animate numbers or replace the content with skeletons.

## 7. Account differences and coherent fixtures

| Account | Dashboard scope and composition |
| --- | --- |
| Employee | Self: display-only shift/location/status, monthly Present 17, Late 2, Leave 1, 138 work hours; only personal activity and allowed navigation. |
| Manager | Team: 12 members, 9 present including 1 late, 1 absent, 2 on leave; 8 working + 1 on break; team attention/activity. No company/user/location metrics. |
| HR | Company: 84 employees, 73 present including 5 late, 4 absent, 7 on leave; 70 working + 3 on break; 6 corrections, attendance rate and granted location information. |
| Company Admin / Super Admin | Same authorized company foundation; additionally active-user count and Settings quick access through management grants. |

For company data, 68 on time + 5 late + 4 absent + 7 leave = 84. Present includes late; working and break are subsets of present, not separate headcount categories. Company attendance rate is 73/84, formatted as 87%. The active-user count of 90 includes non-employee accounts. Monthly Late is a subset of Present. Fixtures are anchored to 17 September 2026 and visibly labeled as demo previews; refresh does not randomize them or claim current server data.

## 8. Responsive behavior

All five accounts were exercised at 360, 390, 430, 600, 768, 900, 1024, 1280, 1440 and 1920 logical pixels in both languages.

Compact: generally two metric columns, or one when text scale demands it; four primary workforce metrics, then Needs Attention. Secondary rate/location/user figures remain in the status summary, avoiding a long stack of equal-priority cards. Employee prioritizes Today and This Month. All critical data scrolls vertically without mandatory horizontal scrolling.

Tablet: existing rail, responsive metric columns and side-by-side sections where available space permits. Desktop: permanent sidebar, balanced metric rows, 2:1 summary/attention and activity/quick-access sections; employee Today becomes three readable fields across the card. Large desktop remains within AppPage's existing 1200px content constraint and allows up to six metric columns where useful. No breakpoints are hardcoded across feature widgets.

## 9. English/Arabic verification

Every dashboard UI label/message lives in ARB resources, including typed activity/attention descriptions, scope headings and empty/error states. Names come from account/fixture data. Greeting uses local device presentation time; data timestamps remain fixture dates. Date, time, numbers, percentages and durations use centralized locale-aware formatters. Whole-hour values omit zero minutes. Intl's existing number strategy is retained; Arabic captions/date notation are localized without manually rewriting numeric strings.

Tests cover resource parity/genuine Arabic, all five accounts in both languages, live locale changes without recreating the router, state rendering and 150% text scaling for all five accounts. Font-loaded screenshots were generated for mobile/desktop plus scrolled lower content.

## 10. RTL verification

Screenshot review inspected employee, manager, HR and administrator compositions in mobile/desktop English/Arabic, plus Company Admin mobile/desktop. Arabic placement follows the existing right-hand sidebar, directional alignments, mirrored grid order and natural two-column direction. Status values align to the directional end; quick actions retain accessible labels. Clock/people/location/settings icons remain non-directional; navigation icons follow SDK directionality. Activity timestamps include localized absolute date/time rather than ambiguous hardcoded relative text.

Screenshots: `artifacts/auth_phase3_<account>_<language>_<width>.png` and `_lower.png`. Widget assertions check RTL, role data gates, navigation integration, scrolling and overflow at every requested width.

## 11. Analyzer

flutter analyze: no issues. Pub get, gen-l10n and dart format completed. Dashboard models do not use code-generation annotations and no database schema changed, so build_runner was not required for this phase; the existing generated infrastructure remains intact.

## 12. Tests/build and run commands

All 286 tests pass: 159 existing checks plus 127 dashboard checks. Dashboard coverage comprises 13 domain/repository/BLoC tests and 114 widget checks, including 100 account/language/width cases, loading/error/retry/empty/refresh states, all-account enlarged text, pull-to-refresh, metric semantics and permission revocation. Fixtures are checked for coherent scope totals, immutability and newest-first activity.

flutter build web passed, including WASM dry-run compilation. The final test log is `artifacts/phase3_test.log`.

```sh
flutter pub get
flutter gen-l10n
dart format .
flutter analyze
flutter test
flutter run -d chrome
# Deliberate demo release, since default release disables demo authentication:
flutter build web --dart-define=DEMO_AUTH=true
```

Use build_runner after changing generated models or Drift schema. The existing clean-path web URL strategy requires static hosting to serve index.html for application deep links.

## 13. Genuine limitations

Snapshots are deterministic in-memory demo data, not persisted attendance/employee records or live analytics. Today/This Month headings are preview composition anchored by the visible demo date. No actual attendance transition, correction approval, account-management screen or employee mutation is implemented. All quick actions target existing authorized shell placeholders. No charts, API service or dashboard cache table was added.

Partial section failures, live local database subscriptions, period selection, remote refresh/sync and user-customized dashboard arrangements remain future requirements. Current data/error states apply to one complete snapshot. Role composition follows grants; there are no artificial role-specific layouts for users with identical access.

Visual QA uses Flutter-rendered widget screenshots. A connected live browser was unavailable in the existing session; native-device builds and assistive-technology certification were not executed. Device-local greeting time is presentation-only and does not define company attendance dates, schedules or business timezone logic.

## 14. Exact foundation ready for Phase 4

Phase 4 can introduce the next explicitly requested business feature within existing typed stateful module routes and centralized shell. Available: safe authenticated user/company/employee context, explicit grants, enabled modules, registry and route guards, one typed dashboard domain/repository/BLoC, authorized quick access, reusable metrics/sections/status/activity/skeletons, responsive forms/tables/pages, English/Arabic/RTL and centralized formatters, get_it, Result/Failure, Drift migrations/outbox, secure tokens, API/connectivity/location/sync foundations.

Real metrics can replace the demo source with aggregates derived from underlying local repositories. Keep writes and outbox insertion transactional, add explicit Drift migration tests when schemas change, refresh remote data into the local source of truth, and retain the repository/BLoC UI boundary. Attendance statuses/shift/location models must be defined by their future domain rather than treating today's display-only demo snapshot as a state machine.

Phase 3 stops here. Await Phase 4 instructions before Employee CRUD, Attendance, Punch In/Out, Breaks, Shifts, Locations, Policies, Corrections, Reports, Services, Customers, Invoices or Finance.
