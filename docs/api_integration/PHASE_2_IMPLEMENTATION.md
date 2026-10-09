# PHASE 2 — Real Backend Authentication and Secure Session Lifecycle

**Status:** Complete. Real MassERP authentication replaces demo-only auth, with rotating refresh tokens, secure persistence, and deterministic demo/backend selection.
**Baseline:** `ac2ec6f` + Phase 1. Flutter 3.35.7 / Dart 3.9.2.
**References:** [`PHASE_0_AUDIT.md`](PHASE_0_AUDIT.md), [`PHASE_1_IMPLEMENTATION.md`](PHASE_1_IMPLEMENTATION.md), `api_integration/FLUTTER_LOGIN_API.md`.

---

## 1. Exact endpoints integrated

| Operation | Method | Path | Auth | Body | Notes |
|---|---|---|---|---|---|
| Login | POST | `/api/auth/login` | none (`requiresAuth: false`) | `{ loginId, password }` | Decodes `data` into `LoginResponseDto` |
| Refresh | POST | `/api/auth/refresh` | none | `{ refreshToken }` | Rotates both tokens; re-reads user/branch |
| Logout | POST | `/api/auth/logout` | none | `{ refreshToken }` | Follows the Markdown contract; best-effort |

No `/me`, permission, or session-validation endpoint was invented.

**Logout contract ambiguity (documented):** the Playbook/Markdown specifies body `{ refreshToken }` and no `Authorization` header, while the Postman sample sends an empty body with a bearer token. We implement the Markdown contract (body `{ refreshToken }`, unauthenticated) so logout still works after the access token has expired, and we never depend on the server call succeeding to clear local access.

---

## 2. DTOs created (Freezed + json_serializable)

`lib/platform/auth/data/dto/auth_remote_dtos.dart`
- `LoginRequestDto { loginId, password }`
- `RefreshRequestDto { refreshToken }`
- `LogoutRequestDto { refreshToken }`
- `LoginResponseDto { tokenType, accessToken, expiresIn, accessTokenExpiresAtUtc, refreshToken, refreshTokenExpiresAtUtc, user }`
- `AuthUserDto { userId, loginId, name, userType, empId?, orgId, branchName?, timeZone?, orgCount?, transactionAccess, reportAccess, branches[] }`
- `AuthBranchDto { orgId, branchName }`

Correctness properties: integer ids, ISO-8601 date-times parsed to `DateTime`, nullable `empId`/`timeZone`/`branchName`, missing required token fields throw (mapped to `invalidData` by the client), and unknown extra fields are ignored. DTOs never reach presentation — `RemoteAuthMapper` converts them.

---

## 3. Repository and datasource structure

```
lib/platform/auth/
  data/
    dto/auth_remote_dtos.dart                       # Freezed wire DTOs
    mappers/remote_auth_mapper.dart                 # DTO -> AuthSession/AuthContext (anti-corruption)
    datasources/remote/
      auth_remote_data_source.dart                  # abstract interface (testable)
      dio_auth_remote_data_source.dart              # Phase 1 ApiClient implementation
    repositories/
      remote_auth_repository.dart                   # AuthRepository + SessionPermissionSink + TokenRefresher
      disabled_auth_repository.dart                 # explicit safe failure (no config)
  domain/
    policies/backend_session_policy.dart            # documented safe-restriction grants
```

`RemoteAuthRepository` satisfies the **existing** `AuthRepository` contract unchanged, so `AuthBloc`, routing guards, and screens are untouched. `DioAuthRemoteDataSource` is a thin typed wrapper over the shared `ApiClient`; it does not create a second Dio client.

---

## 4. Login lifecycle

1. `LoginPage` → `AuthLoginRequested` → `AuthBloc` parses the identifier (now accepting a `loginId`) → `repository.login(identifier, password)`.
2. `RemoteAuthRepository.login` increments the session generation, calls the datasource (`/api/auth/login`, unauthenticated), and on success maps the response to an `AuthSession`.
3. The session is persisted to secure storage **before** being accepted; a storage failure returns `FailureKind.sessionStorage` and does not authenticate.
4. `_accept` sets the in-memory session and schedules an access-token expiry timer.
5. `AuthBloc` applies the effective permission set (empty for backend users — see §9) and emits `authenticated`.
6. Failures (`AUTH_INVALID_CREDENTIALS`, `AUTH_ACCOUNT_INACTIVE`, `AUTH_RATE_LIMITED`, `offline`, `timeout`, …) surface as localized `Failure`s; raw bodies are never exposed.

Landing: backend users receive **no permissions and no module enablement**, but Dashboard and Profile are `alwaysAvailable`, so a successful login lands on the Dashboard with no business capability granted.

---

## 5. Token-refresh sequence

```
protected request ── 401 AUTH_TOKEN_EXPIRED ─▶ AuthRetryInterceptor
                                                   │
                                    TokenRefreshCoordinator.refresh()   (single-flight)
                                                   │
                                    RemoteAuthRepository.refresh()
                                                   │
                            POST /api/auth/refresh { refreshToken }   (unauthenticated)
                                                   │
                    ┌──────────────────────────────┴───────────────────────────┐
             success: persist rotated pair, _accept, emit context      failure:
             → retry original request ONCE with new token              session-ending code → invalidate (clear + emit null)
                                                                       transient (offline/503) → keep tokens (unavailable)
```

- Proactive refresh: `AuthenticationInterceptor` refreshes when the access token expires within 60 seconds.
- Reactive: one retry per request, fenced by the `authRetried` flag; cancellation is never retried.
- Refresh requests are `requiresAuth: false`, which also disables the refresh/retry interceptor for them — **no recursion**.

---

## 6. Single-flight behavior

`TokenRefreshCoordinator` (Phase 1) coalesces concurrent 401s into one `RemoteAuthRepository.refresh()`. The end-to-end test drives five simultaneous protected requests through the real `ApiClient` + interceptor chain and asserts **exactly one** `/api/auth/refresh` call, all five retried with the rotated token.

A monotonically increasing **session generation** fences stale refreshes:
- `login`, `logout`, and forced invalidation advance it (logout advances it **before** any await).
- A refresh captures the generation before awaiting; if it changed, the late result is discarded and cannot restore a logged-out/replaced session.

Persist-failure case: if the server rotated successfully but the new pair cannot be persisted, old refresh tokens are already invalid server-side, so the session is invalidated cleanly rather than left in an inconsistent authenticated state.

---

## 7. Token persistence strategy

- Single atomic secure envelope via `SessionStorage` (`flutter_secure_storage`), unchanged from Phase 1.
- Access and refresh token expiries are tracked independently (`expiresAt`, `refreshTokenExpiresAt`); the refresh token remains readable after access-token expiry.
- Restore accepts a session whose access token expired but whose refresh token is still valid; it clears a session whose refresh token expired or whose envelope is corrupt.
- No passwords are persisted. Tokens are never written to preferences, Drift, or logs.
- Storage read/write failures are handled explicitly (`sessionStorage` failures); logout clears local access **before** the best-effort server call.

---

## 8. Flutter Web security considerations

On Web, `flutter_secure_storage` uses browser storage in a secure context (HTTPS). Tokens are therefore exposed to XSS in a way that native keychain/Keystore is not; this build does **not** claim native-equivalent guarantees. The contract offers no safer browser session mechanism (no HttpOnly cookie flow), so the safest supported behavior is used: HTTPS-only in release, trusted-origin header injection, no token logging, and redaction helpers. Operators deploying Web should treat token storage as a residual XSS risk and harden CSP/asset integrity accordingly.

---

## 9. Permission and identity limitations

- **No permission payload** exists in the login contract. `BackendSessionPolicy` grants **zero** permissions and **no** module enablement — it never grants all permissions, assumes an admin role, or reuses demo grants. Access is gated by the existing permission/scope layer, whose local grant store remains authoritative; a real user receives Dashboard + Profile only until an authoritative grant source exists.
- **Integer identifiers** (`userId`, `orgId`, `empId`) are carried as their decimal string form, so they stay stable across restarts and are never parsed as UUIDs or replaced by random local identities.
- **Identity mapping:** `userId` → `UserAccount.id`, `orgId` → `CompanyContext.id`, `branchName` → company name, `timeZone` → company timezone, `empId` → `EmployeeReference.id`, `userType` → session setting.
- **No demo mixing:** a live backend user is never combined with seeded demo employee records; seeding and local-authoritative behavior are gated by `AppConfig.demoMode`.

---

## 10. Demo / backend configuration

`AppConfig.authMode` is deterministic:
- `API_BASE_URL` set → **backend** (real repository).
- else, demo explicitly available → **demo**.
- else → **disabled**: `DisabledAuthRepository` makes login fail with `auth_not_configured` (`FailureKind.notConfigured`). Release builds (demo off by default) can never authenticate through demo fallback.

`configurePlatformDependencies` registers exactly one `AuthRepository` per mode (no duplicate registration). `AppConfig.demoMode` replaced the fixture gates in bootstrap seeding, access directory, dashboard, attendance authority, corrections and leave repositories, so a backend build carries no demo fixtures or demo-local authority.

---

## 11. Files modified / created

**Created**
- `lib/core/api/api_endpoints.dart` — centralized, typed registry of every backend route (`ApiEndpoints.auth.login`, `ApiEndpoints.departments.byId(id)`, …); no feature hardcodes a path
- `lib/core/api/session_endpoint.dart`, `lib/core/api/interceptors/session_guard_interceptor.dart`
- `lib/platform/auth/data/dto/auth_remote_dtos.dart` (+ generated)
- `lib/platform/auth/data/mappers/remote_auth_mapper.dart`
- `lib/platform/auth/data/datasources/remote/auth_remote_data_source.dart`, `dio_auth_remote_data_source.dart`
- `lib/platform/auth/data/repositories/remote_auth_repository.dart`, `disabled_auth_repository.dart`
- `lib/platform/auth/domain/policies/backend_session_policy.dart`
- Tests: `test/auth_dto_test.dart`, `test/auth_identifier_test.dart`, `test/auth_config_test.dart`, `test/remote_auth_repository_test.dart`, `test/auth_refresh_flow_test.dart`, `test/auth_security_test.dart`, `test/remote_auth_bloc_test.dart`, `test/api_endpoints_test.dart`, `test/support/auth_test_doubles.dart`

**Modified**
- `lib/core/auth/auth_identifier.dart` (loginId support)
- `lib/core/errors/result.dart` (`FailureKind.notConfigured`) + `failure_localization.dart` + platform ARBs
- `lib/core/api/api_client.dart` (SessionEndpoint wiring), `lib/bootstrap/core_dependencies.dart` (endpoint registration + client injection)
- `lib/app/app_config.dart` (`AuthMode`, `demoMode`)
- `lib/platform/module/platform_dependencies.dart` (mode-based `_registerAuthentication`, coordinator wiring)
- `lib/bootstrap/bootstrap.dart` + 6 fixture-gate files (`demoAuthEnabled` → `demoMode`)

---

## 12. Automated tests and results

- `test/auth_dto_test.dart` — request serialization, response decoding, null `empId`, JSON round-trip, missing/unexpected fields.
- `test/auth_identifier_test.dart` — loginId parsing, email/phone normalization, form validation.
- `test/auth_config_test.dart` — auth-mode selection, `DisabledAuthRepository` behavior.
- `test/remote_auth_repository_test.dart` — login success/invalid/offline/storage failure; restore (valid, access-expired-with-valid-refresh, expired refresh, corrupt); logout success/server-failure/storage failure; refresh rotation persisted, rejected→invalidate, transient→unavailable, no-session, stale-after-logout discarded, persist-failure invalidates; server-driven invalidation; unsupported password ops.
- `test/auth_refresh_flow_test.dart` — five concurrent protected requests → one refresh, rotated tokens persisted, all retried; repeated 401 after one retry not retried again.
- `test/auth_security_test.dart` — session/login redaction, no `Authorization` on login, no credential material in failures, no token to untrusted origins.
- `test/remote_auth_bloc_test.dart` — login success/failure, restore, logout, server-driven invalidation.

**Results**
- New Phase 2 tests: **52 passed / 0 failed** (plus the 64 Phase 1 API tests still green).
- `flutter analyze`: **No issues**.
- Full `flutter test`: **+1335 passed / 4 failed** (baseline was +1283 / 4). The 4 failures are unchanged and unrelated: `localization_test.dart` (`holiday_pages.dart:336`) and three `ui7_part_b_test.dart` UI-7 WIP layout overflows. No new failures were introduced.

Commands run: `flutter pub get` → `dart run build_runner build --delete-conflicting-outputs` → `dart format` (60 files, 10 changed) → `flutter analyze` → targeted auth tests → full `flutter test`.

---

## 13. Backend contract gaps

- **No permission/role payload** on login — the app's capability layer cannot be server-driven from this contract.
- **No module enablement** on login.
- **Logout body vs bearer** ambiguity (resolved to the Markdown contract).
- **No password reset/change endpoints** — reported as `unsupported`.
- **No branch/company selection** mechanism on subsequent calls (single `orgId` returned).
- **Envelope on non-2xx** not formally documented (client handles both).
- **No session-revocation or device-list endpoint**.

---

## 14. Remaining risks

- Backend-authenticated users have **no business capabilities** until a real permission source exists; Dashboard/Profile only. This is intentional safe restriction, not a bug.
- Flutter Web token storage carries XSS exposure (native-equivalent guarantees not claimed).
- A late refresh response after logout/new-login is discarded via the generation fence; if the server rotated the token but the client discarded it, the device re-authenticates on next use (no silent stale session).
- Password reset/change flows are unavailable against this backend.
- Access-token expiry during app-idle triggers a refresh attempt; on transient failure the session is retained and retried (60 s), then invalidated if it remains unavailable.

---

## 15. Phase 3 readiness

- [x] Real login/refresh/logout integrated behind the existing `AuthRepository`.
- [x] Freezed auth DTOs with generated JSON.
- [x] Rotating refresh tokens with single-flight coordination and generation fencing.
- [x] Secure session restoration, independent expiries, safe clearing.
- [x] Logout clears local access promptly; server logout best-effort.
- [x] Deterministic demo/backend/disabled selection; no silent demo fallback.
- [x] Permission restrictions preserved (no grants invented).
- [x] Zero analyzer issues; new tests green; no new regressions.
- [ ] (Phase 3) Departments module + first remote data source on the shared client.

**STOP — Phase 2 complete. Awaiting instruction before starting Phase 3.**
