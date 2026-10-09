# PHASE 3 — Department API Integration (Complete Vertical Slice)

**Status:** Complete. The Departments feature is integrated end-to-end (API → Dio → Freezed DTO → datasource → mapper → repository → BLoC → existing UI), with demo and backend isolation. No live backend was available, so all HTTP is verified with mocked transports only.
**Baseline:** `ac2ec6f` + Phases 1–2. Flutter 3.35.7 / Dart 3.9.2.
**References:** [`PHASE_0_AUDIT.md`](PHASE_0_AUDIT.md), [`PHASE_1_IMPLEMENTATION.md`](PHASE_1_IMPLEMENTATION.md), [`PHASE_2_IMPLEMENTATION.md`](PHASE_2_IMPLEMENTATION.md), `api_integration/FLUTTER_DEPARTMENT_API.md`.

---

## 1. Department API coverage

| # | Method | Path | Status |
|---|---|---|---|
| D1 | GET | `/api/departments` (list, paged) | Implemented + unit-tested (mocked); not live-tested |
| D2 | GET | `/api/departments/{id}` | Implemented + unit-tested; not live-tested |
| D3 | POST | `/api/departments` (create) | Implemented + unit-tested; not live-tested |
| D4 | PUT | `/api/departments/{id}` (rename) | Implemented + unit-tested; not live-tested |
| D5 | POST | `/api/departments/{id}/deactivate` | Implemented + unit-tested; not live-tested |
| — | activate | *(no documented endpoint)* | **Not implemented** — reported as `unsupported` |
| — | hard delete | *(not documented)* | **Not implemented** — deactivation is used |

Search, pagination and sort are server-driven (`search`, `page`, `pageSize`, `sort=nameAsc`). The list endpoint returns **active departments only**, so the inactive status filter is an accurate empty result (no fabricated source).

---

## 2. Verified request/response contracts

- **List** `GET /api/departments?page&pageSize&search&sort` → `data { items:[{departmentId:int, departmentName:String, employeeCount:int}], page, pageSize, totalItems, totalPages }`.
- **Get** `GET /api/departments/{id}` → `data { departmentId, departmentName, employeeCount }`.
- **Create** `POST /api/departments` body `{ departmentName }` → `data` item.
- **Rename** `PUT /api/departments/{id}` body `{ departmentName }` → `data` item.
- **Deactivate** `POST /api/departments/{id}/deactivate` → `200`.
- **Envelope** `{ success, message, data, errors[] }` reused via the Phase 1 `ApiEnvelope`/`PagedResult`.
- **Errors** `VALIDATION_ERROR` (field `departmentName`), `ACCESS_DENIED`, `DEPARTMENT_NOT_FOUND`, `DEPARTMENT_DUPLICATE_NAME`, `DEPARTMENT_IN_USE`, `SERVICE_UNAVAILABLE`.
- **Rules** `departmentName` required, max 50, unique among active (case-insensitive); deactivation refused while `employeeCount > 0`.

---

## 3. Freezed DTOs implemented

`lib/modules/hr/departments/data/dto/department_dtos.dart`
- `DepartmentDto { departmentId: int, departmentName: String, employeeCount: int = 0 }`
- `DepartmentUpsertDto { departmentName: String }` (create + rename)

Generated `fromJson`/`toJson`, integer ids (no string conversion inside the DTO), nullable-tolerant `employeeCount`, missing required fields throw (mapped to `invalidData`). No raw JSON maps cross the repository boundary. The shared `ApiEnvelope`/`PagedResult` are reused — no department-specific envelope.

---

## 4. Remote datasource implementation

- `department_remote_data_source.dart` — abstract interface (list/get/create/rename/deactivate, optional `CancelToken`).
- `dio_department_remote_data_source.dart` — uses the shared `ApiClient` and the centralized `ApiEndpoints.departments` registry. No second Dio client, no custom auth (Phase 2 refresh applies automatically), no `Idempotency-Key` (not documented); double-submit is guarded client-side. Backend codes/field errors are preserved.

---

## 5. Repository and mapping design

- `DepartmentRepository` extends the shared `ConfigurationRepository<Department, DepartmentDraft>`, so the presentation layer is identical to other masters.
- `RemoteDepartmentRepository` (backend): remote-first, one-shot fetch bridged into a **cancellable** stream that re-fetches on mutation (revision stream) for cache invalidation. No optimistic success. Maps documented backend codes to the shared UI codes (`duplicateName`, `inUse`, `notFound`); `activate` is reported `unsupported`.
- `LocalDepartmentRepository` (demo): backed by the existing `workforce_departments` table.
- `DepartmentMapper` converts DTO → domain and centralizes id parsing (`parseId`); no `int.parse`/DTO references leak to UI.

---

## 6. Stable identifier strategy

- Backend integer `departmentId` is carried as its **decimal string** domain id (`7` → `"7"`); it is stable across restarts and never parsed as a UUID or replaced by a random id.
- `parseId` returns null for non-numeric ids (e.g. demo `dept-0`), so local demo ids and backend ids can never collide or be misinterpreted.
- Company scoping is applied from `AuthContext.company.id`; ids from different companies are never conflated.

---

## 7. Existing UI integration points

- **New management slice** (`presentation/blocs` + `pages`): list, create/rename form, details — composed from the shared configuration layouts/BLoCs, so loading/empty/error/success, validation, disabled-while-saving, deactivation confirmation and localization/RTL all come from the established components.
- **Settings hub:** a "Departments" row in `ConfigurationLandingPage`, gated by `departmentView`, with a live count.
- **Routes:** `/app/hr/settings/departments` (+ `/new`, `/:id`, `/:id/edit`) in `HrRoutes`/`AppRoutes`; registered via `hr_module_registration.dart` `settingsDestinations`.
- **Employee form / list / filters / details / profile / cross-module reads** consume departments through the local `workforce_departments` lookup (unchanged); demo department management shares that exact table so selections stay consistent. Backend-mode employee integration is intentionally out of Phase 3 scope.

---

## 8. Local database / cache decision

Reviewed the existing `workforce_departments` table (`id` TEXT, `company_id`, `name`, `active`). It lacks the shared config audit columns (`normalized_name`, `status`, `created_at`, `updated_at`, `sync_status`). Decision:
- **No schema change / no migration.** A bespoke `LocalDepartmentRepository` reuses `workforce_departments` (demo), keeping employee references and department management consistent and avoiding a second department table or a destructive migration.
- **Backend mode is remote-first**; no local cache is written this phase (offline caching deferred, per the phase guidance). No demo⇄backend mixing: demo and backend are selected by `AppConfig.authMode` and never coexist.
- Remote failures are never converted into empty lists; the inactive filter is the only deliberate empty result (documented). No offline mutation queue for departments.

---

## 9. Permissions and security behavior

- Added `departmentView`/`departmentManage` with the standard manage⇒view dependency; catalog definitions `hr.attendance.departments.view|manage`; settings destination requires `departmentView`; `/new` and `/edit` require `departmentManage` via `NavigationResolver`.
- Repository access checks (company match + `settings` module + permission) mirror the other masters.
- **Backend users still receive zero permissions** (Phase 2 safe restriction) — Department screens are therefore unreachable for real backend users until an authoritative permission source exists. This is preserved deliberately; no demo grants were assigned to backend users (see §13).
- Frontend visibility is a UX safeguard only; the backend remains authoritative.

---

## 10. Files modified / created

**Created (module)** — `lib/modules/hr/departments/`
- `domain/department.dart`, `domain/department_repository.dart`
- `data/dto/department_dtos.dart` (+generated), `data/department_mapper.dart`
- `data/datasources/department_remote_data_source.dart`, `data/datasources/dio_department_remote_data_source.dart`
- `data/repositories/remote_department_repository.dart`, `data/repositories/local_department_repository.dart`
- `presentation/bloc/department_{list,form,details}_bloc.dart`
- `presentation/pages/department_{list,form,details}_page.dart`

**Modified (wiring)**
- `lib/core/security/app_permission.dart` (enum + manage⇒view)
- `lib/modules/hr/access/hr_permission_catalog.dart` (catalog definitions)
- `lib/platform/auth/presentation/auth_localization.dart` (permission labels)
- `lib/modules/hr/module/hr_module_registration.dart`, `hr_routes.dart`, `hr_dependencies.dart`
- `lib/app/module_registry/registered_modules.dart`, `lib/app/router/app_routes.dart`
- `lib/shared/presentation/configuration_landing_page.dart`, `configuration_localization.dart`
- `lib/bootstrap/dependencies.dart`
- ARB: `lib/modules/hr/l10n/hr_{en,ar}.arb`, `lib/platform/l10n/platform_{en,ar}.arb`

**Tests created**
- `test/department_dto_test.dart`, `test/department_mapper_test.dart`, `test/department_remote_datasource_test.dart`, `test/department_repository_test.dart`, `test/department_bloc_test.dart`, `test/support/department_test_doubles.dart`
- `test/api_endpoints_test.dart` (Phase 2, now also covers department paths)

---

## 11. Automated test results

- New Department tests: **40 passed / 0 failed** — DTO serialization/decoding, mapper identity/scoping, datasource (endpoint/method/body/query/decoding/401/403/404/409/500/offline/cancellation), remote+local repository (list/create/rename/deactivate/duplicate/in-use/unsupported-activate/no-optimistic-success/permission-denied), BLoC (loading/data/empty/error/create/validation/duplicate/details).
- `flutter analyze`: **No issues**.
- Full `flutter test`: **+1377 passed / 4 failed** (baseline +1335 / 4). The 4 failures are the unchanged, unrelated ones: `localization_test.dart` (`holiday_pages.dart:336`) and three `ui7_part_b_test.dart` UI-7 WIP layout overflows. No new regressions were introduced.

Commands: `flutter pub get` → `dart run build_runner build --delete-conflicting-outputs` → `dart run tool/l10n/generate.dart` → `dart format` (changed files) → `flutter analyze` → Department tests → affected suites → full `flutter test`.

---

## 12. Live backend test status

**Not executed.** No running MassERP instance was available, and — more fundamentally — a productive live UI test is blocked by the missing permission source (§13). All endpoint verification is via deterministic mocked HTTP; per the phase rule, no endpoint is labelled end-to-end verified.

---

## 13. Blockers and contract ambiguities

1. **No permission payload from the backend (primary blocker).** Real backend users receive zero permissions, so they cannot reach the Department screens in a live build. This is by design (Phase 2 safe restriction). Live UI acceptance testing requires either a backend permission payload or a deliberate, documented grant source. The frontend will not be weakened to work around it.
2. **No activate endpoint.** Represented accurately as `unsupported`; the UI offers deactivate only.
3. **Active-only list.** No inactive listing; the inactive filter is a documented empty result.
4. **No status/timestamp fields** in the department response; status is derived (active) and a deterministic sentinel timestamp is used (never displayed).
5. **Integer vs UUID identity.** Handled by the mapper as decimal strings; employee-side and cross-module reads still use the local lookup table.
6. **Employee/backend department selection** is not wired in this phase (employee CRUD is a Phase boundary).

---

## 14. Phase 4 readiness

- [x] All documented Department operations integrated (create/rename/deactivate/list/get); unsupported ones represented accurately.
- [x] Freezed request/response DTOs; shared envelope reused.
- [x] Shared Dio networking + Phase 2 auth/refresh reused; no duplicate client.
- [x] Stable backend identity; safe int↔string mapping.
- [x] Existing consumers use the correct (demo) repository; demo/backend isolated.
- [x] Unauthorized users cannot reach management (route guard + repository access + UI gating).
- [x] Loading/empty/error/success states via shared layouts.
- [x] Unit + BLoC tests pass; no analyzer issues; no new regressions.
- [ ] (Phase 4) Shifts + Employee-Shift assignment integration.
- [ ] (Future) authoritative permission source for backend users.

**STOP — Phase 3 complete. Awaiting instruction before starting Phase 4.**
