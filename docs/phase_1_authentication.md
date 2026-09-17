> Historical Phase 1 handoff. The authenticated placeholder and navigation continuation are superseded by [Phase 2](phase_2_shell.md).

# Phase 1 authentication handoff

Phase 1 extends the existing Flutter frontend. Authentication, session lifecycle, user/company context, permission grants, English/Arabic forms and routing protection now work with a local demo repository. No backend, business module, dashboard or new navigation shell was implemented.

## Architecture and ownership

`LoginPage → AuthBloc → AuthRepository → DemoAuthRepository → DemoAuthSource + SessionStorage`.

`AuthBloc` is one application-level business Bloc, created by get_it. All auth events use one sequential event bucket; duplicate login requests are dropped before queuing. It restores authentication, signs in, signs out, accepts repository context updates and revokes expired sessions. UI receives `AuthContext` (user, company, optional employee reference and settings); access/refresh tokens never enter Bloc state. Password visibility remains local state in the centralized `AppPasswordField`.

Password reset/change are independent page-scoped business workflows in `PasswordBloc`, using the same repository interface. No trivial pass-through use cases were added. Add use cases when future orchestration or reusable business rules justify them. Widgets never import database, preferences, secure-storage or API implementations. Route composition injects the repository into Blocs; widgets dispatch events.

Bootstrap initializes Flutter, DI/error hooks, date symbols and Drift migrations, restores locale, mounts the stable router in its bootstrap state, then dispatches session restoration. There is no artificial delay. Valid sessions open `/app`; missing, expired or corrupt sessions open login. Corrupt session envelopes are removed. Secure-storage failures use typed localized failures and grant no startup access. Database/framework initialization occurs before the Flutter root is mounted; startup database failure recovery is not yet an in-app workflow.

## Secure sessions and lifecycle

`SessionStorage.saveSession/readSession/clearSession` reads/writes one versioned JSON envelope through flutter_secure_storage. Tokens and required restore metadata share one secure write, avoiding separate partial token/metadata writes. No tokens or passwords are stored in Drift, scalar preferences, files or logs. Session and password-bearing event/DTO `toString` methods redact sensitive values; the existing Bloc observer logs types only.

Demo sessions last eight hours. Repository operations serialize secure mutations so expiry cleanup cannot race a new login write. A timer emits repository session invalidation; AuthBloc revokes access and clears storage. App resume rechecks the secure session. Logout removes secure data before becoming unauthenticated; a storage deletion failure leaves the authenticated context and a visible retryable sign-out flow. Expired token envelopes cannot supply an API access token. Refresh-token exchange, remote revocation and backend session verification remain future remote repository responsibilities.

Android requires API 23 and has backup disabled for secure-session safety. iOS Debug/Profile/Release keychain entitlements are configured. Platform-native storage behavior needs verification on actual targets. Web secure storage requires localhost or HTTPS and uses the plugin's browser storage protection, not a server-managed HTTP-only cookie. See the [secure-storage package documentation](https://pub.dev/packages/flutter_secure_storage).

## Demo configuration and accounts

`AppConfig.demoAuthEnabled` is `DEMO_AUTH`, defaulting on in debug/profile and off in release. Release authentication intentionally cannot sign in until a backend repository is registered, unless explicitly built for demonstration with `--dart-define=DEMO_AUTH=true`. The credential helper and permission viewer are available only when demo mode is enabled. A disabled repository rejects fixture login and discards stored demo sessions.

| Role | Email | Phone | Password | Permissions |
| --- | --- | --- | --- | --- |
| Super administrator | admin@erp.demo | +15550001001 | Admin@123 | 25 |
| Company administrator | company@erp.demo | +15550001002 | Company@123 | 25 |
| Human resources | hr@erp.demo | +15550001003 | Hr@123 | 20 |
| Manager | manager@erp.demo | +15550001004 | Manager@123 | 9 |
| Employee | employee@erp.demo | +15550001005 | Employee@123 | 6 |

Email matching ignores case/outer whitespace. Phone accepts simple spaces, parentheses and hyphens, with an optional leading plus. Full international parsing is deferred to backend integration. Each account has a unique user and demo-company context; HR/manager/employee link through a lightweight `EmployeeReference`. User account and employment data remain separate.

The development credential dialog only displays fixture credentials; it does not contain login logic. Demo password changes update memory only and reset on application restart. A minimum eight-character password with a Latin/Arabic letter and a numeric digit is required; confirmation must match and the new password must differ from the current one. Password reset shows a conditional informational result and explicitly states no email/SMS was sent. Demo credentials do not establish production security.

## Roles, grants and future backend boundary

`AppRole` is a label/default-template input. Actual authorization uses immutable `PermissionSet` and `PermissionChecker`, including `can`, `canAll` and `canAny`. A presentation convenience is available from `lib/shared/auth/permission_context.dart`:

```dart
if (context.can(AppPermission.employeeCreate)) {
  // Render a future employee action using centralized components.
}
```

`context.can` subscribes to authentication context updates. An HR label alone never grants create access. Role templates are confined to the demo data source. All 25 employee, attendance, configuration, administration and reporting permissions are defined. Company administrators currently have all defined grants within their company; future platform-wide permissions can differentiate super administration further. Resource/team/company scoping and server enforcement must be supplied by the future backend; hiding a frontend action is not server authorization.

`ErpModule.requiredPermissions` and `ModuleRegistry.visible` now use typed `AppPermission` values. `AuthSessionDto` and `AuthSessionMapper` separate wire codes from domain enums, user/company/employee relationships, enabled module IDs and settings. Unknown permission codes fail closed; corrupt relationships and unknown roles reject restoration. A remote implementation can replace demo-provided grants without changing presentation. The secure DTO is a boundary foundation, not a required future backend JSON schema.

## Routes and deep links

- `/bootstrap`: legitimate session initialization only.
- `/login`: public identifier/password form.
- `/forgot-password`: public reset frontend.
- `/app`: protected authenticated placeholder.
- `/app/change-password`: protected reusable account form.
- `/design-system`: protected internal Phase 0 preview, registered only in demo configuration.

One `AuthRouterRefresh` notifier refreshes GoRouter when initialization/access changes. Locale, password visibility, form validation and loading do not recreate the router. Guests are redirected from protected routes to login; authenticated users are redirected away from login. Known protected destinations are retained across bootstrap/login; external `from` targets are rejected. A direct forgot-password startup link returns to that public page after bootstrap. Flutter Web keeps its existing hash URL strategy, for example `/#/app/change-password`, requiring no server rewrite configuration.

The old Phase 0 shell remains in the separate `createPreviewRouter` visual-test harness. Actual Phase 1 authenticated routes have no sidebar, rail or dashboard. The router override in `ErpApp` is a test/composition injection, not a production alternative selected by configuration.

## Localization, UX and verification

Every new static visible string is in both ARBs, including form labels, typed validation/failures, roles, account status and permission labels. Demo user/company values are account data, not localization resources. Existing locale-aware Inter/Noto Sans Arabic fonts, directional components, breakpoints, motion, dialogs and feedback are reused. `AppAuthLayout` and `AppProductIdentity` are centralized reusable additions. Existing inputs gained label overrides, focus, actions, autofill and enabled-state parameters rather than duplicate feature controls.

Expanded/large login and reset layouts use a balanced brand panel and a form bounded to 460 logical pixels; compact/medium use a centered purpose-built single column. Safe areas, scrolling, keyboard resizing, live error semantics, focus flow, password reveal labels and minimum button touch sizes are retained. Entrance motion respects reduced motion.

Verified on 2026-09-17:

- `flutter pub get`: passed, existing Phase 0 dependency resolution reused; no new packages.
- `flutter gen-l10n`: passed; translation parity complete.
- `dart run build_runner build --delete-conflicting-outputs`: passed.
- `dart format .`: passed.
- `flutter analyze`: no issues.
- `flutter build web`: passed, including WASM dry-run compilation; default release JS contains none of the tested demo credential fixture strings.
- `flutter test`: **84 tests passed** (22 auth/permission/repository/router tests, 28 auth widget tests, 34 existing foundation/localization/preview tests).
- Responsive bootstrap/login/forgot/change/authenticated pages: English LTR and Arabic RTL at **360, 390, 430, 600, 768, 1024, 1280, 1440 and 1920** logical pixels.
- Arabic login at 150% text scale with a 300-pixel keyboard inset: passed.
- Validation, password reveal, retained failed-login input, language-switch form/router retention, loading dimensions, password workflows, logout dialog, Enter/focus flow, expiry redirection, deep-link guards and secure adapter behavior: passed.
- Font-loaded mobile/desktop screenshots are generated under ignored `artifacts/auth_*.png`; login, reset, change, authenticated placeholder and Arabic logout dialog were visually inspected.

Browser runtime discovery found no available browser connection. A live browser smoke test and real native secure-storage roundtrip were not executed. Native Android/iOS/Windows builds were not executed. The frontend web compile result is recorded in README after build completion.

## Important files created or modified

New:

- `lib/app/app_config.dart`
- `lib/app/router/preview_router.dart` (extracted previous internal harness)
- `lib/core/auth/auth_identifier.dart`
- `lib/core/auth/password_policy.dart`
- `lib/core/security/app_permission.dart`
- `lib/shared/auth/permission_context.dart`
- `lib/features/auth/domain/entities/auth_context.dart` and generated `.freezed.dart`
- `lib/features/auth/domain/entities/demo_credential_info.dart`
- `lib/features/auth/domain/repositories/auth_repository.dart`
- `lib/features/auth/data/datasources/local/demo_auth_source.dart`
- `lib/features/auth/data/dto/auth_session_dto.dart` and generated `.g.dart`
- `lib/features/auth/data/repositories/demo_auth_repository.dart`
- `lib/features/auth/presentation/auth_localization.dart`
- `lib/features/auth/presentation/bloc/auth_bloc.dart`
- `lib/features/auth/presentation/bloc/password_bloc.dart`
- `lib/features/auth/presentation/pages/bootstrap_page.dart`
- `lib/features/auth/presentation/pages/login_page.dart`
- `lib/features/auth/presentation/pages/forgot_password_page.dart`
- `lib/features/auth/presentation/pages/change_password_page.dart`
- `lib/features/auth/presentation/pages/authenticated_home_placeholder.dart`
- `lib/design_system/components/layout/app_auth_layout.dart`
- `test/auth_test.dart`
- `test/auth_widget_test.dart`
- `test/support/memory_session_storage.dart`
- `ios/Runner/DebugProfile.entitlements`
- `ios/Runner/Release.entitlements`
- `docs/phase_1_authentication.md`

Modified:

- `lib/bootstrap/bootstrap.dart`, `lib/bootstrap/dependencies.dart`
- `lib/app/erp_app.dart`, `lib/app/router/app_router.dart`
- `lib/app/module_registry/module_registry.dart`
- `lib/core/storage/secure_session_storage.dart`
- `lib/core/errors/result.dart` and generated `.freezed.dart`
- `lib/core/errors/failure_localization.dart`
- `lib/core/api/api_client.dart`
- `lib/core/validation/app_validation.dart`
- `lib/design_system/components/inputs/app_inputs.dart`
- `lib/design_system/design_system.dart`
- `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb` and three generated localization files
- `test/foundation_test.dart`, `test/widget_test.dart` (reuse typed grants/auth-aware preview composition)
- `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`
- `ios/Runner.xcodeproj/project.pbxproj`
- `README.md`

## Exact Phase 2 continuation

Continue from the existing app-level `AuthBloc.state.context`, `AuthRepository` contract, shared typed permission APIs and protected `/app` route. Replace only `AuthenticatedHomePlaceholder` when implementing the Phase 2 shell. Feed actual `context.user.permissions` and `context.company.enabledModules` into registry discovery and route/action gates; do not authorize by role. Keep auth state as the routing source of truth and never navigate independently on logout.

New business features follow `UI → Bloc → optional use case → repository → local/remote source`, reuse design-system/localization contracts and persist structured local data in Drift. Add real migrations and atomic domain/outbox writes as modules appear. Do not place employee employment fields in `UserAccount`. Later swap the demo repository for a remote/local adapter implementing the same contract and session stream; add refresh handling inside that boundary and connect API invalidation without exposing tokens in UI state. No Phase 2 implementation has begun.
