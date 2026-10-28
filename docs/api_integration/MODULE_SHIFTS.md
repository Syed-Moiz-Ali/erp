# Module Integration — Shifts

**Status:** Complete. Shifts is the second remote vertical (after Departments), integrated **module-by-module** with local model/schema/form extensions so the backend contract round-trips losslessly.

## Endpoints integrated

| Method | Path | Use | Status |
|---|---|---|---|
| GET | `/api/shifts` | List (`page`, `pageSize`, `search`, `statusId`, `sort=startTime`) | Implemented + unit-tested |
| GET | `/api/shifts/{id}` | Detail | Implemented + unit-tested |
| POST | `/api/shifts` | Create (`201`) | Implemented + unit-tested |
| PUT | `/api/shifts/{id}` | Update | Implemented + unit-tested |
| POST | `/api/shifts/{id}/deactivate` | Soft delete | Implemented + unit-tested |
| POST | `/api/shifts/{id}/activate` | Re-activate | Implemented + unit-tested |

Backend-only field **`earlyPunchInMinutes`**; backend has **no** working-day or break-rule concept. Status codes preserved; error codes mapped (`SHIFT_DUPLICATE_NAME`→`duplicateName`, `SHIFT_IN_USE`→`inUse`, `SHIFT_NOT_FOUND`→`notFound`).

## Model + schema change (lossless round-trip)

- `Shift`/`ShiftDraft` gained `earlyPunchInMinutes` (default 15, validated 0–120).
- `ShiftRecords` gained `early_punch_in_minutes` (default 15); **schema 18 → 19** with an additive, idempotent `_ensureColumn` migration. Existing databases upgrade safely.
- Local/demo mode is unchanged except it now also persists the early window.

## Backend vs local mapping

| Backend | Domain |
|---|---|
| `shiftId` (int) | `Shift.id` = decimal string (stable) |
| `startTime`/`endTime` `HH:mm:ss` | `LocalTime` |
| `lateGraceMinutes` | `gracePeriodMinutes` |
| `earlyPunchInMinutes` | `earlyPunchInMinutes` (new) |
| *(none)* | `workingDays` = every day; `breakMode` = `noBreak` |
| `statusId` (1/2) | `ConfigurationStatus` |
| `activeAssignments` | `ConfigurationItem.assignedEmployees` |

In **backend mode** the shift form/list/details hide the local-only working-days, break-rule and minimum-work controls (the API ignores them) and expose the early punch-in window, so the form never offers settings the backend discards.

## Wiring

- `RemoteShiftRepository implements ShiftRepository` (remote-first, cancellable revision stream for cache invalidation, no optimistic success, backend-contract validation only).
- `DioShiftRemoteDataSource` on the shared `ApiClient` + centralized `ApiEndpoints.shifts`.
- `configureHrDependencies` selects remote for `AuthMode.backend`, local otherwise; the config UI, Settings hub and repository contract are unchanged.

## Files

- Added: `shifts/data/dto/shift_dtos.dart`, `shifts/data/shift_mapper.dart`, `shifts/data/datasources/shift_remote_data_source.dart`, `.../dio_shift_remote_data_source.dart`, `shifts/data/repositories/remote_shift_repository.dart`.
- Modified: `shifts/domain/shift.dart`, `shifts/data/shifts_table.dart`, `shifts/data/local_shift_repository.dart`, `shifts/presentation/bloc/shift_form_bloc.dart`, `shifts/presentation/pages/{shift_list,shift_form,shift_details}_page.dart`, `core/database/app_database.dart` (schema 19), `hr_dependencies.dart`, `shared/presentation/configuration_localization.dart`, HR ARBs.
- Tests: `shift_dto_test.dart`, `shift_mapper_test.dart`, `shift_remote_datasource_test.dart`, `shift_remote_repository_test.dart`, `support/shift_test_doubles.dart`; `di_runtime_wiring_test.dart` asserts `RemoteShiftRepository` (backend) / `LocalShiftRepository` (demo/disabled). Migration assertions updated to schema 19 (`configuration_test`, `attendance_correction_test`, `employee_test`, `services_phase2_test`).

## Results

- New Shifts tests: **30 passed** (DTO, mapper, datasource, remote repository, DI).
- `flutter analyze`: **No issues**.
- Full `flutter test`: **+1435 passed / 4 failed** — the 4 are the unchanged, unrelated pre-existing ones (`localization_test` `holiday_pages.dart` + three `ui7_part_b_test` overflows).
- Live backend: not exercised (no tunnel run here); mocked-HTTP only.

## Remaining queue

Employee Shifts → Attendance → Branches → Employees, each as its own vertical.
