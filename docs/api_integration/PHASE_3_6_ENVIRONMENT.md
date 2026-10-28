# PHASE 3.6 — Automatic Development / Production Environment Configuration

**Status:** Complete. The app now loads `.env.development` in debug builds and `.env.production` in profile/release builds automatically — **no `--dart-define` arguments are required**. Configuration is centralized, validated, testable, and fails safely.
**Baseline:** Phases 0–3.5. Full suite before: **+1386 passed / 4 failed**. After: **+1405 passed / 4 failed** (same 4 unrelated failures).

---

## 1. Architecture of environment loading

```
main.dart → bootstrap()
  WidgetsFlutterBinding.ensureInitialized()
  usePathUrlStrategy()
  await loadEnvironment()        ← reads the build-mode env file (flutter_dotenv)
        ├─ EnvironmentConfig.fileNameForMode(currentBuildMode())
        ├─ dotenv.load(fileName)          (rootBundle asset)
        ├─ EnvironmentConfig.parse(...)   (validate + normalize)
        └─ AppConfig.configure(environment)
  configureDependencies()        ← GetIt reads AppConfig (auth mode, API URL)
  … Drift open, seeds (demo only), AuthBloc, runApp, AuthBootstrapRequested
```

Files:
- `lib/app/app_environment.dart` — `AuthMode`, `AppEnvironment` (value object), `EnvironmentConfig` (file names, build-mode selection, parsing/validation/normalization), `FlutterBuildMode`.
- `lib/app/app_config.dart` — centralized facade: `configure`/`reset` + getters (`environmentName`, `apiBaseUrl`, `authMode`, `demoMode`, `realApiEnabled`, `allowInsecureHttp`, `configurationValid`, `configurationError`). Re-exports `AuthMode`/`AppEnvironment`.
- `lib/app/environment_loader.dart` — `loadEnvironment({dotenv, fileName, buildMode})`; never throws.
- `.env.development`, `.env.production` — root env files, bundled as Flutter assets.

Loading is the **first** thing bootstrap does after binding initialization, so dependency registration, Dio, session restoration and route resolution all see the final configuration. `loadEnvironment` supports injection (`dotenv`, `fileName`, `buildMode`) for tests; the app calls it with no arguments.

---

## 2. Config keys

| Key | Required | Values | Notes |
|---|---|---|---|
| `API_BASE_URL` | Yes for `AUTH_MODE=backend` | absolute URL | HTTPS required; origin normalized (trailing slash stripped, base path preserved) |
| `AUTH_MODE` | Yes | `backend` \| `demo` \| `disabled` | `demo` rejected in production |

Schema is identical in both files. No credentials, tokens, secrets or keys.

---

## 3. Development / production selection

Uses Flutter's compile-time build-mode constants only — no runtime heuristics:

| Build mode | Constant | File |
|---|---|---|
| Debug | `kDebugMode` | `.env.development` |
| Profile | `kProfileMode` | `.env.production` |
| Release | `kReleaseMode` | `.env.production` |

`EnvironmentConfig.fileNameForMode` implements this and is unit-tested for all three modes. No manual toggles, no `--dart-define`, no shell variables, no localhost detection.

---

## 4. Ngrok configuration

- Development uses a plain `https://<subdomain>.ngrok-free.app` URL with no path. The loader keeps the hostname, strips a trailing slash and strips nothing else, and the Dio base URL is the ngrok origin — endpoints are the existing `/api/...` paths, so **no duplicate path segments** (e.g. `https://x.ngrok-free.app` + `/api/auth/login`).
- The trusted-origin guard is unchanged: the bearer token is attached only to the configured host.
- TLS validation is not disabled; we do not bypass CORS and we do not add ngrok-specific headers the contract doesn't require.
- Failures are distinguished: connection/DNS (Dio `connectionError` → `offline`), tunnel expired (404/5xx → mapped status failure), unexpected HTML (JSON transform error → `invalidData`), backend JSON errors (envelope `errors[0].code` → typed `Failure`).
- **A temporary ngrok tunnel gets a new hostname on restart** — update `API_BASE_URL` in `.env.development` and restart `flutter run`.

---

## 5. Flutter Web CORS requirements

The browser enforces CORS between the Flutter Web origin and the ngrok/backend origin. The **backend** must return `Access-Control-Allow-Origin` for the app's origin (and allow `Authorization`, `Content-Type`, `X-Request-ID`, `X-Client-Platform` for preflight). ngrok tunnels pass the backend's CORS headers through; they do not add CORS themselves. The app does not and must not bypass CORS, and `Flutter` code cannot fix this — no client-side change can satisfy the browser.

### Symptom

```
Access to XMLHttpRequest at 'https://<tunnel>.ngrok-free.dev/api/auth/login'
from origin 'http://localhost:62494' has been blocked by CORS policy:
Response to preflight request doesn't pass access control check:
No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

### Diagnosis (verified against the dev tunnel)

`OPTIONS` reaches Kestrel but the backend answers with **401 and no CORS headers**, i.e. authentication runs on the preflight before CORS does:

```
curl -i -X OPTIONS "https://<tunnel>.ngrok-free.dev/api/auth/login" \
  -H "Origin: http://localhost:62494" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: content-type,authorization,x-request-id,x-client-platform"
# → HTTP/1.1 401 Unauthorized  (no Access-Control-Allow-Origin)
```

A correct preflight returns `HTTP/1.1 204 No Content` with `Access-Control-Allow-Origin`,
`Access-Control-Allow-Methods` and `Access-Control-Allow-Headers`.

### Fix (ASP.NET Core / MassERP — backend)

1. Register a policy:

```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("FlutterWeb", policy => policy
        .WithOrigins(
            "http://localhost:62494",   // this run's Flutter web origin
            "http://localhost:8080")    // recommended fixed dev origin
        .AllowAnyHeader()
        .AllowAnyMethod());
});
```

2. Enable it **before** authentication/authorization so the preflight short-circuits
   (a `401` from auth is precisely what breaks the preflight):

```csharp
app.UseRouting();
app.UseCors("FlutterWeb");        // must precede UseAuthentication/UseAuthorization
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
```

For a local-only dev environment `AllowAnyOrigin()` is also acceptable (we send no
cookies, so `Access-Control-Allow-Credentials` is not required).

3. The allowed request headers must include every header the app sends:
   `authorization`, `content-type`, `x-request-id`, `x-client-platform`
   (`AllowAnyHeader()` covers this).

### Recommendation: pin the Flutter Web dev port

The dev origin changes every `flutter run -d chrome` (e.g. `:62494`). Pin it so the
backend allowlist stays stable:

```
flutter run -d chrome --web-port=8080
```

### Dev-only alternatives (until the backend allows CORS)

- Serve the Flutter Web build from the **same origin** as the API (e.g. backend serves `build/web`).
- Put a local reverse proxy in front of the tunnel on a fixed port and point `API_BASE_URL` at that proxy (it can add the CORS headers).
- Do **not** ship `--disable-web-security`/`--disable-features=IsolateOrigins` browser hacks; they are local debugging only and never a fix.

`ngrok-skip-browser-warning` is not added by the app: the ngrok browser interstitial is a separate, documented tunnel behaviour and adding a non-contract header would not fix a preflight that receives a `401` from the backend.

---

## 6. Startup failure behavior

`loadEnvironment` never throws and never falls back:

- Missing / empty / unreadable file → invalid environment, `AUTH_MODE=disabled`.
- Missing `API_BASE_URL` for `backend`, missing/unknown `AUTH_MODE`, malformed URL, production placeholder/loopback/private/HTTP URL, or `demo` in production → invalid, `disabled`.
- Invalid configuration forces `authMode = disabled` regardless of the file's `AUTH_MODE`; `DisabledAuthRepository` makes login fail with the localized `auth_not_configured` error, and no API client is built.
- There is **no** production→development URL fallback and **no** backend→demo fallback.
- Unconfigured default: debug → demo (preserves local-first dev/tests); profile/release → disabled (so a build that somehow skipped loading can never use demo).

---

## 7. Production security restrictions

- HTTPS only (loopback HTTP is permitted only in development debug builds).
- Production rejects placeholder hosts (`example.com`, `yourdomain`, `your-domain`, `your-dev-tunnel`, `changeme`, `placeholder`, `ngrok`), loopback (`localhost`, `127.0.0.1`, `::1`, `0.0.0.0`), private ranges (`10/8`, `192.168/16`, `172.16–31`, `169.254/16`), `.local`/`.internal`, HTTP, and `AUTH_MODE=demo`.
- Profile builds follow production rules (`allowInsecureHttp = false`).
- Authorization headers remain restricted to the configured trusted origin.
- Diagnostics log only environment name, auth mode, host and validity — never tokens or the full URL.

Debug-only log example:
```
[env] file=.env.development name=development mode=backend host=your-dev-tunnel.ngrok-free.app valid=true
```

---

## 8. Example environment files

`.env.development`
```
API_BASE_URL=https://your-dev-tunnel.ngrok-free.app
AUTH_MODE=backend
```

`.env.production`
```
API_BASE_URL=https://api.yourdomain.com
AUTH_MODE=backend
```

Both ship with placeholders. The production placeholder is deliberately rejected, so a release build without a real URL fails safely (does not connect anywhere and does not fall back).

---

## 9. How to change backend URLs

1. Open `.env.development` (or `.env.production`).
2. Set `API_BASE_URL` to the HTTPS endpoint (e.g. the current ngrok URL).
3. Restart the app (`flutter run` / rebuild). Reload alone is not enough because the env loads at startup.

---

## 10. Normal run/build commands (no extra arguments)

```
flutter run -d chrome
flutter run -d windows
flutter run -d android

flutter build web --release
flutter build apk --release
flutter build windows --release
```

---

## 11. Files modified / added

**Added**
- `.env.development`, `.env.production`
- `lib/app/app_environment.dart`, `lib/app/environment_loader.dart`
- `test/environment_config_test.dart`

**Modified**
- `lib/app/app_config.dart` — runtime centralized facade (replaced `String.fromEnvironment`/`bool.fromEnvironment`)
- `pubspec.yaml` — `flutter_dotenv: ^6.0.1`; env files declared as assets
- `lib/bootstrap/bootstrap.dart` — `await loadEnvironment()` before dependency registration
- `lib/modules/hr/demo/demo_attendance_seed.dart`, `lib/modules/hr/attendance/data/local_attendance_correction_repository.dart`, `lib/modules/hr/leave/data/local_leave_repository.dart` — replaced const `AppConfig.demoMode` default parameters with nullable + runtime resolution
- `test/di_runtime_wiring_test.dart` — now injects demo/backend/disabled environments explicitly (no dart-defines)

No repository, Dio, authentication or Department architecture changed.

---

## 12. Test results

- `test/environment_config_test.dart` — **17 passed**: build-mode selection (debug/profile/release), development parse (HTTPS, loopback HTTP, demo), production parse (valid HTTPS; placeholder/loopback/private/HTTP/ngrok and demo rejected), missing `AUTH_MODE`, malformed/relative/query URLs, unknown mode, URL normalization + safe host, `AppConfig` injection/reset, and real-file load tests (development file loads; production placeholder rejected; missing file fails safely with `disabled`).
- `test/di_runtime_wiring_test.dart` — **3 passed**: backend → `RemoteAuthRepository` + `RemoteDepartmentRepository` + `ApiClient` base URL equals the configured URL; demo → `DemoAuthRepository` + `LocalDepartmentRepository`, no `ApiClient`; disabled → `DisabledAuthRepository`, no `ApiClient`.
- `flutter analyze` — **No issues**.
- `flutter build web --release --no-wasm-dry-run` — **succeeded** without any `--dart-define`; `build/web/assets/.env.development` and `.env.production` are bundled.
- Full `flutter test` — **+1405 passed / 4 failed**. The 4 failures are the unchanged, unrelated pre-existing ones: `localization_test.dart` (`holiday_pages.dart` source scan) and three `ui7_part_b_test.dart` UI‑7 WIP overflows.

Phase 1–3.5 integration tests all remain green (auth full-chain, department full-chain, remote auth/repository, refresh, security).

---

## Known limitations

- Live backend connectivity remains unverified in this environment (no tunnel/host); the dev file ships a placeholder until a real ngrok URL is provided.
- A release build with the placeholder production URL shows the safe `auth_not_configured` error by design until a real HTTPS endpoint is configured.
- Web CORS is a backend responsibility; it is documented, not bypassed.

**STOP — Phase 3.6 complete.**
