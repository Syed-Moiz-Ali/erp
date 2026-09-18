# Phase 5 — attendance configuration handoff

1. **Summary.** Three independent, local-first Flutter features provide shifts, work locations and attendance policies. Each supports searchable/status-filtered lists, details, a shared create/edit form, activation and deactivation. Configuration discovery is integrated into the existing enterprise shell. Employee assignments use persisted records. No backend or Phase 6 attendance workflow was added.

2. **Important files.** Feature folders are `lib/features/shifts`, `lib/features/work_locations` and `lib/features/attendance_policies`, each with domain models/contracts, structured Drift tables/local repositories/seeds, feature-named BLoCs and explicit Flutter pages. Integration files include `lib/features/employees/data/employee_attendance_catalog.dart`, `lib/core/database/app_database.dart`, `lib/bootstrap/dependencies.dart`, `lib/bootstrap/demo_configuration_seed.dart`, `lib/app/module_registry/registered_modules.dart`, `lib/app/module_registry/navigation_resolver.dart` and `lib/app/router/app_routes.dart`. Shared mechanics live in `lib/shared/data/local_configuration_repository.dart`, `lib/shared/workflows`, and `lib/shared/presentation/configuration_*`. Reusable components are exported through `lib/design_system/design_system.dart`.

3. **Shift architecture.** Freezed `Shift`/`ShiftDraft` use pure local clock values (`LocalTime`), stable ISO weekday identities, break mode, grace, optional minimum work, status and timestamps. The repository owns normalization/validation and persistence. List/details/form workflows are separate feature-named BLoCs. Weekday selection and time inputs use centralized components.

4. **WorkLocation architecture.** `WorkLocation`/`WorkLocationDraft` contain address fields, country code, coordinates, radius, optional accepted accuracy and typed validation mode. Validation rejects missing fields, invalid coordinate ranges, non-finite values, non-positive radius/accuracy and country codes that do not have two letters. Country-code validation checks format; a full ISO country picker is not included. The form has a user-triggered location capture workflow through `LocationService`.

5. **AttendancePolicy architecture.** Immutable policy records separate location, break, timing, correction-request and offline rules. Forms conditionally expose dependent controls. Details summarize rules by meaningful section rather than showing raw object booleans. Stable enum values are persisted, never translated labels.

6. **Drift schema/migration.** Schema **3** adds `shift_records`, `work_location_records` and `attendance_policy_records`. Explicit upgrades support versions 1 and 2 without dropping workforce/account/outbox data. Snapshot `drift_schemas/drift_schema_v3.json` is included alongside previous snapshots; the reproducible web worker was regenerated. Partial unique indexes enforce normalized active names per company. Assignment indexes support SQL counts. Existing nullable employee ID columns are retained rather than rebuilding the employee table; repository checks enforce company ownership and active new assignments transactionally. Configuration APIs expose no permanent deletion.

7. **Repository architecture.** UI → feature BLoC → typed feature repository → Drift. Shared generic code implements tenant-safe CRUD mechanics, streams, SQL pagination/counts, safe failures, serialization and transactional outbox enqueueing. Each feature owns its model, schema, row mapping and business validation. Widgets and BLoCs never query Drift or Dio. Domain mutations and outbox inserts commit together; rollback tests prove neither survives a failed enqueue. Future sync handlers use `shifts`, `work_locations` and `attendance_policies` module identifiers; each queued mutation has its own UUID. There is no remote sender or automatic acknowledgement.

8. **Employee integration.** `EmployeeDraft` carries nullable shift/location/policy IDs. Searchable selectors receive real active company records plus the edited employee's current inactive assignments, which are clearly marked and disabled for new selection. An unchanged inactive assignment remains valid; clearing or switching an assignment is explicit. Missing, cross-company or newly inactive assignments fail before any employee/account/outbox write commits. SQL-derived counts include existing assignments, and soft deactivation does not unset IDs. Employee details resolve names, shift hours, radius and policy summaries; configuration links appear only with the relevant view grant. Self/team access remains scoped. Assigned reference labels do not grant directory/configuration access. Configuration changes invalidate employee detail observation.

9. **Overnight handling.** Clock duration is `(endMinutes - startMinutes + 1440) % 1440`. A 22:00–07:00 shift is overnight and lasts 540 minutes. Equal times are invalid, not a 24-hour shift. Expected work subtracts a fixed *planned* break; manual/no-break modes do not subtract it. This calculates configuration values only. Phase 6 must bind local clocks to actual dates in the company timezone and evaluate attendance separately.

10. **Geofence/location strategy.** Coordinates must be finite and within latitude/longitude ranges; radius and optional accuracy are positive finite meters. Validation modes are geofence required/preferred, capture only and none. A provider-independent `AppLocationPreview` displays address/coordinates/radius; it does not render a fake map or require API keys. `Use current location` is the only permission-request trigger. Capture populates coordinates and shows measured accuracy, with a non-blocking poor-accuracy warning. Denied/permanent permission, disabled service, timeout and unavailable-device failures have localized feedback, retry/settings actions and manual entry. Android foreground permissions and iOS purpose text are configured. No startup/background capture, geofence attendance validation or map SDK exists.

11. **Policy validation.** Normalization runs in both form workflows and repositories. Turning location off clears event requirements, outside-location and accuracy settings; turning break tracking off clears multiple-break, punch-out-during-break and break-location requirements. Disabling early arrival clears its limit. Location-required policies need at least one location event. Required accuracy must be positive and finite; enabled early arrival requires a valid non-negative limit (up to one day). Shift defines **when**, location **where**, policy **what is required/allowed**. Phase 6 should intersect their constraints: a location mode must not silently weaken a policy's required event capture/accuracy; a policy permitting outside/remote work requires explicit engine resolution. No rule precedence or attendance outcome is currently executed.

12. **Permissions.** Separate `shiftView`/`shiftManage`, `workLocationView`/`workLocationManage` and `attendancePolicyView`/`attendancePolicyManage` grants control discovery, direct routes and repository operations. View permits list/details; manage permits create/edit/status mutations. Manage-only users can directly create/edit and return to Dashboard after saving, without receiving view access. View-only users cannot access forms. No workflow authorization checks roles. Existing role templates merely provide explicit demo grants. The longest matching destination owns route authorization and sidebar highlighting.

13. **Company scoping.** Every configuration lookup/list/count/uniqueness check/write uses the current company ID, and repositories reject mismatched user/company contexts. Configuration destinations belong to the existing company-enabled `settings` module, grouped under Configuration. Disabling that module removes discovery and blocks direct configuration routes. Shared IDs do not bypass tenant checks. Demo seeding runs only with explicit demo authentication and preserves existing edits/status changes on restart.

14. **English/Arabic.** All new labels, errors, validation, units, permission feedback, confirmations and settings descriptions have typed English/Arabic ARB resources. Existing bundled Inter/Noto Sans Arabic fonts are retained. Numeric input accepts Latin, Arabic-Indic and Persian digits/decimal separators. Fixture names and addresses are persisted business data, not hardcoded feature UI labels. Resource-parity and no-hardcoded-UI-message regression checks remain active.

15. **RTL.** Feature layouts inherit directionality and use directional alignment/padding. Technical numeric coordinates/codes remain readable with local LTR isolation; localized times and durations follow the selected language. Mobile controls, dialogs, sheets and desktop shell were checked in Arabic. The settings tile chevron follows reading direction. Sidebar selection resolves one most-specific destination.

16. **Responsive QA.** Configuration list/details/create/edit pages and employee configuration selectors were exercised in both languages at **360, 390, 430, 600, 768, 900, 1024, 1280, 1440 and 1920** logical pixels. Compact lists use cards; desktop uses real data tables with relevant shift/location/policy columns and SQL pagination. Headers wrap controls, forms use bounded responsive grids, tables can scroll horizontally, and shared forms scroll with keyboard/enlarged text. Font-loaded screenshots at 390/1440 were visually inspected. Interactive checks cover actual shift time pickers/weekday selection, selectors, policy dependencies, filters, status confirmations, dirty protection, permission routes and capture errors/accuracy updates.

17. **Analyzer.** Final result recorded below. The only localized annotation suppression documents Freezed forwarding a constructor JSON annotation to its generated class; unrelated diagnostics remain enabled.

18. **Tests and builds.** Final result recorded below. `test/configuration_test.dart` covers repository/domain/workflow behavior, SQLite migration/restart, transactional failures, counts, tenant/permission isolation and controlled location capture. `test/configuration_widget_test.dart` covers responsive, localized and interactive pages. `test/location_service_test.dart` verifies the actual device adapter against a controlled platform, including permission-request boundaries and distinct capture/settings failures. Existing employee/auth/shell/dashboard/localization/design-system suites remain part of the full regression run. A dashboard test now centers its large-text action before tapping, preventing the test target from sitting underneath the shell header.

19. **Genuine limitations.** Frontend only: demo authentication/account credentials remain fixtures; newly linked employee accounts still require future credential provisioning. No backend, map provider, remote synchronization or attendance engine exists. Work location capture depends on device permission/services and browser secure-context support. Native builds, physical-device GPS and a live browser storage roundtrip were not executed. Company timezone conversion and policy/geofence enforcement belong to the future attendance engine. The dashboard retains its existing demo snapshot; configuration pages and assignment counts use repository data. Existing demo employees begin unassigned; real assignment counts start at zero and increase through actual employee edits, avoiding invented counts or reseeding over intentionally cleared assignments. OS permission prompt purpose text uses the platform configuration; app-managed feedback supports English/Arabic.

20. **Phase 6 foundation.** Reuse `Employee` assignment IDs and scoped repository lookups, `Shift` local clocks/weekdays/planned durations, `WorkLocation` geometry/accuracy/mode, normalized `AttendancePolicy`, `LocationService`, explicit attendance grants, company timezone metadata, transactional outbox/database, safe failures and centralized UI components. Add a dedicated attendance evaluation use case and attendance repository/tables/migration when Phase 6 is authorized. Do not infer current attendance from configuration status or mutate shared configuration while evaluating an event.

## Validation results

Verified on **2026-09-18**:

- `flutter pub get`: passed; no new runtime packages or dependency overrides.
- `flutter gen-l10n`: passed; typed English/Arabic resources regenerated.
- `dart run build_runner build --delete-conflicting-outputs`: passed.
- Drift schema v3 dump, web-worker compilation and Dart formatting: passed.
- `flutter analyze`: **no issues found**.
- `flutter test`: **437 passed, 0 failed**. Phase 5 adds 41 repository/domain/BLoC tests, 36 widget tests and 4 controlled-platform location-service tests to the existing 356 tests.
- Default release web build: passed.
- Explicit demo release web build: passed.
- `git diff --check`: passed.
- Font-loaded English desktop and Arabic mobile/desktop configuration screenshots inspected.

Machine-local evidence is in `artifacts/phase_5_tests.log`, `phase_5_analyze.log`, `phase_5_generation.log`, `phase_5_web_release.log` and `phase_5_web_demo.log`. Screenshot artifacts are `artifacts/auth_phase5_*.png`. Build/test artifacts are ignored by Git.

## Commands

```sh
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas
dart compile js -O2 tool/drift_worker.dart -o web/drift_worker.dart.js
dart format .
flutter analyze
flutter test
flutter run -d chrome
# Explicit demo release:
flutter build web --release --dart-define=DEMO_AUTH=true
```

No new runtime packages or fonts were required. **Stop after Phase 5.** Punching, breaks, timers, history, corrections, reports and future ERP modules have not been started.
