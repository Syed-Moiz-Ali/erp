# Phase 7 — employee attendance experience

Implemented in the existing frontend-only Flutter application. No backend, service, authentication replacement, schema change, history/calendar or approval module was added. Existing UI changes, local fonts and centralized design tokens are preserved.

1. **Attendance Today UI.** `/app/attendance` now renders the repository-backed current workday: not started, working, on break and completed. Setup and session failures show localized reasons and retry/contact-HR guidance. Ready content remains visible during refresh and submissions.
2. **Important files.** The file map below identifies the composition, workflow, presentation and reusable components.
3. **AttendanceBloc connection.** `AttendanceSessionScope` creates one business BLoC for each authenticated user/company with `attendanceViewSelf`. Both Dashboard and Today read that instance. Account/company changes dispose the previous owner; missing self-view permission blocks the route. Actions use engine decisions, explicit permissions and the linked active employee, without role checks in widgets.
4. **Ticker architecture.** Today owns `AttendanceTickerCubit`, with the injected `AppClock` and immutable repository context. Each display tick derives durations from effective event instants through the existing summary calculator. Only timer/metric builders subscribe to it. There are no per-second BLoC events, persistence writes or accumulated tick counters. Separately, the business BLoC schedules one read-only refresh at the engine’s next punch-window/grace/shift-end boundary, so time-dependent action eligibility changes without a manual refresh. Timing deadlines reuse the central domain evaluator; that timer is cancelled on context failure or BLoC disposal. It runs only while working/on break and visible/foreground; resume recalculates elapsed time, completed days stop, disposal cancels the timer.
5. **Punch In UX.** Engine preflight runs before any GPS request. Preparation checks location where required and returns an immutable review context. Allowed warnings require consent before event/UUID creation. Normal permitted actions submit directly. Cancelling records nothing.
6. **Break Start UX.** The engine controls visibility, tracking, multiple-break and permission eligibility. Submission remains inline and duplicate taps are gated. Location capture is shared with the punch workflow.
7. **Resume UX.** Resume is the primary on-break action; only the engine can permit it. Work resumes from recorded instants and accumulated breaks remain in the summary/timeline.
8. **Punch Out confirmation UX.** Always uses the shared confirmation sheet. It shows punch-in/current company time, worked/break durations and location; an allowed open break shows the auto-close note. Typed warnings share that sheet. Confirmation revalidates current actor, employee, workday, configuration and evidence. Newly introduced warnings require renewed consent. A modal guard prevents local watch updates from stacking sheets.
9. **Location acquisition flow.** `ExecuteAttendanceAction.prepare` delegates to the existing location abstraction, only for an engine-required action or an explicit location-refresh control. Checking is inline, other attendance information stays visible, and refresh captures evidence without recording attendance. There is no startup/background GPS collection.
10. **Geofence/location error UX.** Inside/outside validation, distance/radius, current accuracy and required accuracy come from domain results. Denied permission offers Allow location; permanent denial offers app settings; disabled services offer location settings. Unavailable, stale/invalid evidence, low accuracy and blocked geofences have localized explanations and retry. Allowed outside-site attendance needs warning confirmation. Raw coordinates are not rendered.
11. **Pending sync UX.** Pending events and the day banner explicitly say saved on this device and waiting for verification when sync becomes available. Connectivity is never presented as server acceptance. Demo-local authority remains local-only, without invented server timestamps.
12. **Failed/rejected sync UX.** Failed events expose retry by their existing operation/request ID. Retry requeues the existing payload and inserts no event. Rejections retain the event/audit context, show stronger contact-HR guidance and have no rejected-operation retry control. No remote sender is configured in the product; controlled senders exist only in tests.
13. **Timeline architecture.** Today maps actual engine-ordered events into generic `AppTimeline`/`AppTimelineItem`. Effective company-local event time, derived completed-break duration and truthful sync badges are displayed. Empty days show a real empty state. This generic component can serve later module activity feeds.
14. **Dashboard integration.** The employee/self section reads `AttendanceDashboardPreview` from the shared BLoC and opens Today. Invented self monthly metrics, punch times and correction activity were removed from the demo source and self UI. Existing organization/team demo summaries remain explicitly labelled, outside this phase’s real self-attendance scope.
15. **Responsive behavior.** Centralized `AppOperationalLayout` stacks compact content in state → notices → shift/location → durations → timeline order. Medium content uses balanced columns; expanded content uses approximately two-thirds operational content and one-third context. `AppPage` bounds wide canvases. No per-feature width literals or stretched mobile-only desktop layout were introduced.
16. **English/Arabic verification.** Typed ARB resources cover state, action, location, warning, sync and confirmation labels. All four states were exercised in both languages at 360, 390, 430, 600, 768, 900, 1024, 1280, 1440 and 1920 logical pixels. Local font loading in tests uses the current Manrope and IBM Plex Sans Arabic design-system families.
17. **RTL/accessibility verification.** Directional layouts mirror naturally; the digital timer alone uses LTR. The Arabic 360px screen and sheet pass at 150% text scale. Timer semantics describe duration meaning, statuses use text/icons, timeline semantics preserve chronology, primary touch targets are at least 48px, and existing focus/keyboard behavior remains available. The open account menu’s locale dependency was restored while preserving its updated styling. Page entrances use existing reduced-motion support; shared sheets now respect disabled animations and centralized motion durations.
18. **Tests added.** `attendance_experience_test.dart` adds 46 widget/integration checks using the real engine, local repository and in-memory Drift. Coverage includes all state/width/language combinations, cancellation and warning-before-write, location progress/errors/accuracy/geofences/retry/stale evidence, pending/failed/rejected sync, idempotent retry, clock-derived timers, keyboard cancellation, scheduled eligibility refresh, lifecycle/offstage behavior, inactive/unlinked employees, explicit mutation permissions, exhausted single breaks, open-break punch-out and shared Dashboard ownership. Dashboard regressions were updated to exercise organizational metrics and prove the self fixtures are removed; the Phase 6 engine tests remain intact.
19. **Flutter analyze.** No issues found (final run: 5.9 seconds).
20. **Flutter test.** All **589 tests passed** (final full run: 1 minute 46 seconds), including **106 existing attendance engine tests** and **46 new attendance experience tests**.
21. **Genuine limitations.** No real API or server confirmation exists. Physical GPS, native permission dialogs, system-settings return behavior and live-browser persistence were not exercised on devices in this phase; those paths use controlled adapters in tests. Company-time support remains the Phase 6 explicit fixed-offset implementation; unsupported DST zones fail safely. Employees must have valid linked active records and assigned shift/policy/location where required. The test capture fixtures do not create fake production attendance. Organization/team dashboards retain their explicitly labelled Phase 3 demo data. Historical screens, monthly summaries, corrections, HR/team attendance and reports remain outside this phase.
22. **Phase 8 foundation.** Repository-backed current context, date/event reads, immutable audit events, frozen configuration, deterministic summaries, company-time abstraction, safe outbox retries and reusable timeline/layout/feedback components are ready for the next authorized phase. No Phase 8 screen or workflow was started.

## Important file map

| Responsibility | Files |
| --- | --- |
| Session composition | `lib/features/attendance/presentation/attendance_session_scope.dart`, `lib/app/erp_app.dart`, `lib/bootstrap/bootstrap.dart`, `lib/bootstrap/dependencies.dart` |
| Today and presentation ticker | `lib/features/attendance/presentation/pages/attendance_today_page.dart`, `attendance_ticker_cubit.dart`, `attendance_presentation.dart` |
| State and action UI | `lib/features/attendance/presentation/widgets/attendance_state_card.dart`, `attendance_action_section.dart`, `attendance_duration_summary.dart` |
| Context and location | `attendance_context_panel.dart`, `attendance_location_status.dart`, `lib/features/attendance/data/device_attendance_location_capture.dart` |
| Confirmation and safe workflow | `attendance_confirmation_sheet.dart`, `lib/features/attendance/application/execute_attendance_action.dart`, `lib/features/attendance/presentation/bloc/attendance_bloc.dart` |
| Sync and timeline | `attendance_sync_banner.dart`, `attendance_today_timeline.dart`, `lib/design_system/components/timelines/app_timeline.dart` |
| Shared design primitives | `lib/design_system/components/layout/app_workspace_layout.dart`, `feedback/app_feedback.dart`, `sheets/app_bottom_sheet.dart`, `lib/design_system/theme/app_typography.dart` |
| Timing eligibility | `lib/features/attendance/domain/attendance_engine.dart`, `shift_workday_resolver.dart`; session BLoC owns one cancellable boundary refresh |
| Repository binding | `lib/features/attendance/domain/attendance_repository.dart`, `attendance_models.dart`, `lib/features/attendance/data/local_attendance_repository.dart` |
| Navigation and Dashboard | `lib/app/module_registry/registered_modules.dart`, `lib/features/dashboard/presentation/dashboard_page.dart`, `lib/features/dashboard/data/demo_dashboard_source.dart`, `attendance_dashboard_preview.dart` |
| Localization | `lib/l10n/app_en.arb`, `app_ar.arb`, generated localizations, `lib/core/localization/app_formatters.dart`, `attendance_localization.dart` |
| Validation | `test/attendance_experience_test.dart`, `test/dashboard_test.dart`, `test/dashboard_widget_test.dart`, `test/auth_widget_test.dart`, `artifacts/phase_7_*.log` |

Paths abbreviated in the widgets/domain rows are relative to their attendance subdirectory.

## Validation

Verified on 2026-09-18 with Flutter 3.35.7 / Dart 3.9.2:

| Check | Result |
| --- | --- |
| `flutter pub get` | Passed; locked compatible resolution retained |
| `flutter gen-l10n` | Passed |
| `dart run build_runner build --delete-conflicting-outputs` | Passed; 37 seconds |
| `dart format lib test` | Passed; new boundary/helper changes also formatted |
| `flutter analyze` | No issues found |
| `flutter test` | **589 passed**, no failures |
| Targeted attendance suite | **152 passed** (106 engine + 46 experience) |
| Keyboard cancellation | Passed; no mutation on Escape or Cancel |
| Release demo web build | Passed; 83.4 seconds, `--no-wasm-dry-run` for the JavaScript target |
| `git diff --check` | Passed |

Logs are in `artifacts/phase_7_pub_get.log`, `phase_7_l10n.log`, `phase_7_codegen.log`, `phase_7_format.log`, `phase_7_analyze.log`, `phase_7_tests.log`, `phase_7_attendance_tests.log`, `phase_7_keyboard_test.log` and `phase_7_web_build.log`.

Font-loaded widget PNGs were captured and visually reviewed:

- `artifacts/auth_phase7_english_390_working.png`
- `artifacts/auth_phase7_arabic_390_working.png`
- `artifacts/auth_phase7_english_1440_working.png`
- `artifacts/auth_phase7_arabic_1440_working.png`

No packages were added for Phase 7. Existing Flutter/Dart-compatible locked dependencies are retained. Database schema remains **4**; no migration or worker rebuild is required for these presentation/workflow changes.

## Run and verify

```sh
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
dart format lib test
flutter analyze
flutter test
flutter run -d chrome --dart-define=DEMO_AUTH=true
flutter build web --release --dart-define=DEMO_AUTH=true
```

For a demo walkthrough, use existing HR/administrator employee editing to assign Noor Ali an active shift and attendance policy (and work location for policies that require it), then sign in to the existing employee account and open Attendance. Root demo seed records intentionally do not invent those assignments or punch events. Office capture requires granted device/browser location permission; a policy without a location requirement needs no GPS.
