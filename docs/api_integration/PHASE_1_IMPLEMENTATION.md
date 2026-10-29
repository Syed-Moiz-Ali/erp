# PHASE 1 — Production-Grade Dio Infrastructure and Freezed API Foundation

**Status:** Complete. Shared networking foundation implemented, tested and documented. No feature endpoints, no login/refresh workflow, no repository migration.
**Baseline:** `ac2ec6f`. Flutter 3.35.7 / Dart 3.9.2. Dio 5.11.1, freezed 3.2.3, json_serializable 6.11.x.
**Prior audit:** [`PHASE_0_AUDIT.md`](PHASE_0_AUDIT.md).

---

## 1. Summary of work completed

A scalable, testable Dio-based networking foundation now exists under `lib/core/api`, with:

- Multi-verb HTTP client (`GET/POST/PUT/PATCH/DELETE`) plus a generic `request<T>`.
- Typed Freezed response envelope (`ApiEnvelope<T>`), reusable pagination (`PagedResult<T>`) and error entry (`ApiError`).
- Consistent error mapping for every documented transport/status case, preserving backend codes and field-level validation.
- Safe authentication-header attachment with a trusted-origin guard and redaction utilities.
- Explicit protection against accidental duplicate mutations (in-flight coalescing + opt-in `Idempotency-Key`).
- A single shared `ApiClient` registered in GetIt, replaceable in tests.
- 64 focused, hermetic tests (no live backend).

No application BLoC, screen, route, permission, database schema or local repository was changed. Demo authentication and all local-first features continue to work.

---

## 2. Reused stashed work

There was **no git stash** at the start of this phase — the previous Phase 1 draft had already been recovered into the working tree (it was popped at the end of the prior session). It was therefore reviewed in place against the Phase 0 audit. A path-scoped stash was used only temporarily to prove the pre-existing UI-7 test failures are unrelated.

**Reused unchanged**
- `lib/core/api/models/api_error.dart` — Freezed wire error.
- `lib/core/api/api_error_codes.dart` — backend code/status mapping (expanded this phase).
- `lib/core/api/token_refresher.dart`, `token_refresh_coordinator.dart` — single-flight refresh primitive.
- `lib/core/api/interceptors/request_id_interceptor.dart`, `client_platform_interceptor.dart`, `authentication_interceptor.dart`, `auth_retry_interceptor.dart`.
- `lib/core/storage/secure_session_storage.dart` refresh-token-expiry fix and new token-state methods.
- `lib/platform/auth/domain/entities/auth_context.dart` + `data/dto/auth_session_dto.dart` (`refreshTokenExpiresAt`, `tokenType`).
- `lib/app/app_config.dart` `apiBaseUrl`/`realApiEnabled`; `core_dependencies.dart` coordinator registration; `test/support/memory_session_storage.dart` additions.

**Refined / corrected**
- `api_client.dart` — was monkey-unwrapping maps; now unwraps the typed `ApiEnvelope`, adds `sendTimeout`, generic `request<T>`, in-flight mutation coalescing, opt-in idempotency, and safe path/query handling.
- Error mapping — added `400`→validation, `404`→notFound, `409`→conflict, `422`→validation; `Failure` now carries `field` and `serverMessage`.
- `ApiBaseUrl` extracted to its own file with an explicit, environment-restricted HTTP exception.

**Replaced / discarded**
- Deleted the ad-hoc `test/api_foundation_test.dart` (11 tests) and replaced it with 5 focused suites + a shared harness (64 tests).
- The old `skipAuth` parameter was renamed `requiresAuth` (positive form); no behaviour lost.

Nothing unrelated was overwritten or discarded.

---

## 3. Architecture decisions

1. **One client, no per-feature clients.** Future modules resolve the shared `ApiClient` and add remote data sources on top of it. Feature endpoint methods are deliberately *not* added to the client.
2. **DTOs never reach the UI.** Envelope/error/pagination models live in `lib/core/api/models`; feature DTOs will live in each module's `data/dto` (Phase 3+).
3. **Anti-corruption at the boundary.** The client returns `Result<T>` decoded by a caller-supplied `fromJson`; domain entities are mapped in the module layer.
4. **Refresh is infrastructure, not workflow.** The single-flight coordinator and retry interceptor are wired but **inert** until a `TokenRefresher` is registered (Phase 2). This is the minimum safe forward-compatibility change.
5. **Fail-closed parsing.** A missing `success` flag, malformed JSON or a non-envelope body maps to `invalidData` — never silently to empty data.
6. **Deterministic interceptor order** so behaviour is predictable and recursion-safe.

---

## 4. Files created / modified

**Created — `lib/core/api`**
| File | Purpose |
|---|---|
| `api_base_url.dart` | HTTPS validation + explicit debug loopback exception |
| `api_path.dart` | Safe `{placeholder}` path resolution with URL-encoding |
| `api_redaction.dart` | Masks Authorization/Cookie/idempotency headers and tokens |
| `models/api_error.dart` | Freezed `errors[]` entry |
| `models/api_envelope.dart` | Freezed generic `{success,message,data,errors}` |
| `models/paged_result.dart` | Freezed generic `{items,page,pageSize,totalItems,totalPages}` |
| `interceptors/idempotency_interceptor.dart` | Opt-in `Idempotency-Key`, stable across retries |

**Modified — `lib/core/api`**
- `api_client.dart` — full rewrite (verbs, typed envelope decode, dedupe, timeouts, error mapper, origin-safe auth).
- `api_error_codes.dart`, `api_option_keys.dart`, `interceptors/authentication_interceptor.dart` (trusted host), `interceptors/auth_retry_interceptor.dart` (cancellation-safe).

**Modified — core / app / bootstrap**
- `lib/core/errors/result.dart` — `FailureKind.validation/conflict/notFound`; `Failure.field`, `Failure.serverMessage`.
- `lib/core/errors/failure_localization.dart` + `lib/l10n/common/common_{en,ar}.arb` — localized copy.
- `lib/core/storage/secure_session_storage.dart` — refresh expiry + token-state methods.
- `lib/app/app_config.dart` — `apiBaseUrl`, `realApiEnabled`, `allowInsecureHttp`.
- `lib/bootstrap/core_dependencies.dart` — `registerSharedApiClient(...)`; conditional registration.
- `lib/platform/auth/...` `auth_context.dart`, `auth_session_dto.dart` — session metadata fields.

**Created — tests**
- `test/support/api_test_harness.dart`, `test/api_networking_test.dart`, `test/api_error_mapping_test.dart`, `test/api_auth_foundation_test.dart`, `test/api_envelope_test.dart`, `test/api_di_test.dart`.

Generated code (`*.g.dart`, `*.freezed.dart`) and `lib/l10n/generated/*` were regenerated by build_runner and the project's l10n merge tool.

---

## 5. Dio request lifecycle

```
ApiClient.get/post/.../request
        │
        ├─ _send:   mutation? → in-flight coalescing (identical method+path+query+body)
        ├─ _perform: dio.request(Options(method, headers, extra…))
        │
        │   Interceptor chain (deterministic, in order):
        │     1. RequestIdInterceptor        → X-Request-ID
        │     2. ClientPlatformInterceptor   → X-Client-Platform
        │     3. IdempotencyInterceptor      → Idempotency-Key (opt-in, reused on retry)
        │     4. AuthenticationInterceptor   → trusted host? proactive refresh → Bearer
        │     5. AuthRetryInterceptor        → on 401 AUTH_TOKEN_EXPIRED, one refresh + retry
        │
        ├─ success → _decodeEnvelope: ApiEnvelope.fromJson → Success(data)
        └─ DioException → ApiErrorMapper → Failed(Failure)
```

The `AuthRetryInterceptor` retries via `dio.fetch` with an `authRetried` flag, so it cannot recurse; it is a no-op while no `TokenRefresher` is wired.

---

## 6. API envelope and Freezed design

```dart
ApiEnvelope<T>  { bool success; String message; T? data; List<ApiError> errors; }
ApiError        { String code; String message; String? field; }
PagedResult<T>  { List<T> items; int page, pageSize, totalItems, totalPages; }
```

- Generic (`genericArgumentFactories: true`), `fromJson`/`toJson` generated by `freezed` + `json_serializable`.
- `ApiEnvelope<Object?>` is used internally to decode the envelope first (so error envelopes with `data:null` still map correctly), then the caller's `fromJson` decodes `data` into a typed DTO.
- Reusable and typed: list endpoints will use `PagedResult<SomeDto>` as `T`.
- No envelope field was invented; only `success, message, data, errors` are modelled. No feature DTOs were added this phase.

---

## 7. Error handling contract

`Failure { String code; FailureKind kind; bool retryable; String? field; String? serverMessage; }`

| Situation | Result |
|---|---|
| Connection/send/receive timeout | `timeout` (retryable) |
| No internet / connection refused | `offline` (retryable) |
| Cancelled request | `cancelled` |
| Invalid JSON / bad certificate | `invalidData` / `request` |
| Unexpected structure (missing `success`, non-object body) | `invalidData` |
| 400 / 422 | `validation` (field preserved) |
| 401 | `sessionExpired` |
| 403 | `forbidden` |
| 404 | `notFound` |
| 409 | `conflict` |
| 429 | `rateLimited` |
| 5xx | `server` (retryable) |
| Known backend `code` | overrides the status-derived kind; code preserved verbatim |

Field-level validation is preserved on `Failure.field`; the backend's user-facing message on `Failure.serverMessage`. Raw Dio exceptions and bodies never reach the UI. `Failure.localizedMessage` provides the presentation-safe text.

---

## 8. Security safeguards

| Safeguard | Implementation |
|---|---|
| Tokens/passwords never logged | No logging interceptor; no body/header logging anywhere |
| Authorization redaction | `ApiRedaction.headers/token/authorization` mask sensitive values |
| HTTPS in production | `ApiBaseUrl.parse` rejects non-HTTPS |
| Dev HTTP exception | Explicit `ALLOW_INSECURE_HTTP` dart-define, debug-only, loopback hosts only |
| No hardcoded secrets | Base URL is a dart-define; no credentials in source |
| Trusted origins only | `AuthenticationInterceptor` attaches the token only when the request host equals the base host |
| Sensitive bodies not dumped | Only `Failure` (safe) values are produced; bodies discarded |
| Cancellation ≠ retry | `AuthRetryInterceptor` ignores `DioExceptionType.cancel` |
| Deterministic interceptor order | Fixed add order documented in §5 |
| No recursive requests | Retry gated by `authRetried`; `dio.fetch` re-entry is bounded to one |

**Flutter Web note:** `flutter_secure_storage` on Web is backed by browser storage in a secure context and does **not** provide the same at-rest guarantees as native keychain/Keystore. This is documented, not claimed equivalent.

---

## 9. Dependency registration

- `TokenRefreshCoordinator` — always registered as a lazy singleton.
- `ApiClient` — registered only when `AppConfig.realApiEnabled` (i.e. `API_BASE_URL` is set), via `registerSharedApiClient(services, baseUrl: …, allowInsecureHttp: …)`, with `dispose: (c) => c.close()`.
- One shared instance per container; `registerSharedApiClient` throws on a duplicate registration (prevents divergent global config).
- Tests inject a fake transport by constructing `ApiClient(dio: Dio()..httpClientAdapter = FakeDioAdapter(...))`.
- Existing local repositories and their registrations are untouched; no screen/BLoC changed.

---

## 10. Test cases and results

`test/api_networking_test.dart` — base URL (HTTPS, HTTP rejection, loopback dev exception), path encoding, all five verbs, query params, custom + correlation headers, typed body serialization, nullable data, malformed JSON, unexpected envelope, cancellation, mutation coalescing (same vs different), idempotency header.
`test/api_error_mapping_test.dart` — 400/401/403/404/409/422/429/500/503, backend codes (auth + access + validation + service), field-level preservation, timeout/offline/cancel/FormatException, `ApiErrorCodes` helpers.
`test/api_auth_foundation_test.dart` — token attached/omitted (public, missing, untrusted origin), proactive refresh with a fake refresher, no-refresh without a refresher, redaction.
`test/api_envelope_test.dart` — `ApiError` round-trip, envelope success/failure/missing-flag, `PagedResult` nested parsing and helpers.
`test/api_di_test.dart` — shared coordinator singleton, shared client lazy singleton, duplicate-registration rejection.

**Results**
- New API tests: **64 passed / 0 failed**.
- `dart analyze`: **No issues**.
- Full `flutter test`: **+1283 passed / 4 failed**. All 4 are **pre-existing and unrelated** (see §11): 1 `localization_test.dart`, 3 `ui7_part_b_test.dart`.
- Baseline preserved: the 1,204 baseline-passing tests still pass; +64 new API tests +15 pre-existing UI-7 passing tests = 1,283.

Verification commands run in order: `flutter pub get` → `dart run build_runner build --delete-conflicting-outputs` → `dart format` (36 files, 7 changed) → `dart analyze` → new API tests → full `flutter test`.

---

## 11. Known limitations

- **No refresh workflow** — the coordinator/retry interceptor are inert until a `TokenRefresher` is wired in Phase 2.
- **`ApiClient` is not registered in demo mode** (no base URL). Tests construct it directly.
- **No certificate pinning** yet — deferred to a later hardening pass.
- **Mutation coalescing is per-client-instance, in-memory** and keys on method+path+query+body; it is a double-submit guard, not distributed idempotency.
- **`requestVoid` expects the envelope**; a bare `204 No Content` would map to `invalidData` (no such endpoint is documented).
- **Web storage** parity caveat noted in §8.
- **Pre-existing failures reported separately (unchanged, not hidden):**
  - `test/localization_test.dart` — `holiday_pages.dart:336` (`label: '$year'`) source-scan false-positive. `holiday_pages.dart` was **not** modified.
  - `test/ui7_part_b_test.dart` — 3 UI-7 WIP layout failures (`RenderFlex` overflow / RTL). Verified to fail identically with Phase 1 changes stashed.

---

## 12. Issues deferred to Phase 2

- `RemoteAuthRepository` + remote data source + Freezed auth DTOs + mapper.
- Real login (`loginId`), refresh, server logout; wire a `TokenRefresher` into the coordinator; 401→session-invalidation signal to `AuthBloc`.
- Resolve the permission-source decision (`userType` + flags vs local grants).
- `AuthIdentifier` `loginId` support; session-invalidation flow on `AUTH_REFRESH_REUSED/INVALID/EXPIRED`.
- Confirm backend contract ambiguities from the Phase 0 audit (logout body/auth, envelope on non-2xx, branch selection).

---

## 13. Phase 2 readiness checklist

- [x] Multi-verb typed client with envelope unwrapping.
- [x] Freezed envelope/pagination/error models generated and tested.
- [x] Consistent, field-aware error mapping.
- [x] Safe, testable auth-header attachment with trusted-origin guard.
- [x] Production HTTPS enforced; explicit dev exception.
- [x] Single shared DI client; test transport injection.
- [x] Existing local features and demo auth unaffected.
- [x] Zero analyzer issues; new tests green; baseline preserved.
- [ ] (Phase 2) `TokenRefresher` implementation + `RemoteAuthRepository` registration.

**STOP — Phase 1 complete. Awaiting instruction before starting Phase 2.**
