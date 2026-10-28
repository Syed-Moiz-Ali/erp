# Client decisions â€” backend session permissions (Phase 1)

Date: 2026-10-28
Branch: `fix/backend-session-permissions`

These are the assumptions made while implementing Tasks Aâ€“C. Each one is deliberate and should be revisited when the backend contract changes.

## D-01 â€” Backend is the only permission source in backend mode

The app is live-only. `AppConfig.authMode` is `backend` when a URL is configured and `disabled` otherwise; demo mode and demo authentication have been removed. `GET /api/me/permissions` is the only permission source. No local/demo grants are used.

Reason: the audit found two divergent grant stores; using local grants for a backend user could show actions the backend will deny. The product owner has also decided that no demo/local fake business data may be reachable.

## D-02 â€” Scope = ALL for key-only backend grants

The backend has no scope field. For scoped client permissions (currently employee view), a granted key is treated as the broadest scope (`ALL`). Self-service keys such as `hr.attendance.self.view` remain SELF because the key itself is self-scoped.

This is implemented once in `lib/core/security/backend_access_policy.dart`. It does not invent scope data; it records the only truthful interpretation of a key-only grant.

## D-03 â€” Module entitlement is derived from permission keys

The backend has no module endpoint. `BackendAccessPolicy.enabledModulesFor` derives:
- `employees` from employee/login-management permissions;
- `attendance` from self-attendance permissions;
- `settings` from shift, department, branch and access permissions.

Dashboard and account are always available. This derivation is the single place to replace when the backend supplies `enabledModules`.

## D-04 â€” Fail closed on permission-load failure

If `/api/me/permissions` fails, the session keeps authentication but has an empty permission/module set and a retryable `permissionsFailure`. The shell shows "Could not load permissions" with retry. No stale/local grants are used.

## D-05 â€” Re-fetch triggers

Permissions are re-fetched:
- after login;
- after token refresh (through the repository session update);
- on app resume (`AppLifecycleCoordinator.refreshPermissions`);
- after any `403 ACCESS_DENIED` (`AccessEndpoint` -> `AuthAccessDenied`).

There is no polling timer. The permission loader itself sets `skipPermissionRefresh` to avoid a reload loop.

## D-06 â€” Client-only permissions are hidden in backend mode

The backend exposes 15 keys. The client catalog is larger (leave, locations, policies, attendance corrections, services). `PermissionCatalog.backendDefinitions` exposes only keys the backend can grant and non-`clientOnly` definitions.

`hr.attendance.self.punch` is one backend key; the client expands it to punch-in, punch-out and break runtime permissions so existing action gates keep working. Separate punch-out/break catalog entries are marked `clientOnly` and hidden in backend mode.

## D-07 â€” Permission keys aligned to the backend

- Departments use `hr.departments.view|manage` (not `hr.attendance.departments.*`).
- Branches use `company.branches.view|manage` and map to new `companyBranchView|companyBranchManage` runtime permissions.
- Employee login management uses `company.users.manage`.
- Access uses `company.access.users.view|permissions.manage`.

A unit test fails if any runtime permission is missing from the catalog or if a backend key is not catalogued.

## D-08 â€” Login identifiers are case-insensitive

The live backend authenticates `admin` as `Admin`. The client does not rely on case; it sends the entered value verbatim and treats the returned `loginId` as authoritative.

## D-09 â€” 401 vs 403

- `401` session-ending codes invalidate the session (existing behavior).
- `403 ACCESS_DENIED` keeps the session, shows the normal "no permission" failure, and triggers a permission reload.
- A `403` from `/api/me/permissions` does not trigger a reload loop.

## D-10 â€” Employee PUT must be a complete object

The backend `PUT` clears omitted fields. The intended remote employee adapter must load the full detail, apply edits, and send the complete payload. The existing Postman update body is not a safe template.

## D-11 â€” Employee activate/login

Activate does not restore the linked login. The client must re-read the employee after activate and display the real `login.enabled/canLogin`; it must not assume login is active.

## D-12 â€” Branch create/update requires an IANA time zone

The client must send `timeZoneId` from the branch lookups. It must not use Windows zone names or offsets.

## D-13 â€” Remote module status in this phase

Implemented and covered by tests:
- Auth login/refresh/logout + backend effective permissions.
- Permission-driven navigation/route/action gating through the existing `PermissionSet`.
- Retryable permission failure and empty-permission states.
- Catalog key alignment, client-only filtering, branch keys.
- Access & Users administration in backend mode, including permission master CRUD, additive assign, replace-all, single/orphan revoke.
- Branches: live list, search, status filter, paging, detail, create, update, activate/deactivate, IANA time-zone lookups.
- Employees: live backend-shaped model, list/search/status filter/paging, detail, create, full-replace update, activate/deactivate. PUT starts from the loaded detail map and applies form edits so no backend field is dropped. Login enablement is part of the edit form and requires `company.users.manage`.

Not completed in this phase:
- Employee Shifts and Attendance live screens.
- Reason: no client feature exists for assignments and the attendance state machine remains local; both need dedicated verticals. Their routes remain unregistered, so no local/fake data is reachable.

## D-14 â€” No secrets or hardcoded environment values

Base URL comes from `AppConfig`/environment files. No token, password, ngrok URL, or credential is hardcoded in the client changes. The live smoke test (if any) uses environment values only and is read-only.



## D-15 — Live-only runtime

- `AuthMode` has only `backend` and `disabled`; `AUTH_MODE=demo` is rejected.
- Demo authentication/credentials, demo seeding and demo account UI are removed from the runtime path.
- Only destinations with a real backend vertical are registered: dashboard, profile, settings, shifts, departments, branches, live-employees, access-users, company-modules. Local-only Attendance, Leave, Reports, Work Locations, Policies and Services routes are removed from the live registry, so typed URLs cannot open fabricated data.
- Local Drift remains only as an unused cache/queue foundation; it is never seeded with business data and is not a source for live screens.
- Admin permission master CRUD and user-grant administration use the live endpoints. Admin means any holder of `company.access.permissions.manage`; granting any key (including module permissions) to any employee user is the intended policy.

