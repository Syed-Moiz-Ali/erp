# Routing Architecture (Phase 13.5)

go_router is the single source of truth for **page identity and URL**. BLoCs own
**business state** (lists, filters, loading) but never decide which screen
replaces another. The same semantic routes are used on Web, Android, iOS and
Windows; only the visual composition adapts by breakpoint.

## 1. Route hierarchy (canonical)

```
/app                                  authenticated shell
  /app/dashboard
  /app/employees
    /app/employees/new
    /app/employees/:employeeId
    /app/employees/:employeeId/edit
  /app/attendance                     today
    /app/attendance/history
      /app/attendance/history/:attendanceDayId
    /app/attendance/corrections
      /app/attendance/corrections/new/:attendanceDayId
      /app/attendance/corrections/:correctionId
    /app/attendance/requests
      /app/attendance/requests/:correctionId
    /app/attendance/team
      /app/attendance/team/:employeeId/:attendanceDayId
    /app/attendance/all
      /app/attendance/all/:employeeId/:attendanceDayId
  /app/reports                        attendance reports workspace
  /app/settings
    /app/settings/shifts[/new|/:id|/:id/edit]
    /app/settings/work-locations[/new|/:id|/:id/edit]
    /app/settings/attendance-policies[/new|/:id|/:id/edit]
    /app/settings/notifications       reminder settings
    /app/settings/sync                sync status
  /app/notifications
  /app/profile
  /app/change-password
  /app/more, /app/access-denied, /app/module-unavailable, /app/not-found
```

Entity identity lives in the **path** (`/app/employees/:employeeId`), never in a
query parameter. Filters/dates/pages may use query parameters as an optional
enhancement; they are not required for correctness.

Use the centralized builders in `AppRoutes` (e.g.
`AppRoutes.employeeDetails(id)`, `AppRoutes.attendanceDayDetails(id)`); never
hand-write URL strings in widgets.

## 2. Push vs go policy

- **push** — deeper hierarchy so Back returns to the previous screen:
  list → detail, detail → edit, history → day, queue → review, row → drill-down.
- **go** — primary navigation and identity replacement:
  sidebar/rail/bottom-nav module items (always the module **root**), post-login
  landing, post-save redirect (`create → detail`, `edit → detail`), logout and
  auth redirects.

Primary navigation intentionally targets the module root even when the user is
already inside that module (`AppShell.navigate` calls `context.go(rootRoute)`).
It never restores a preserved nested branch location, so clicking "Employees"
from `/app/employees/EMP-12` returns to `/app/employees`.

## 3. Active navigation resolver

`ModuleRegistry.ownerOf(path)` (longest-route match) is the resolver used by the
shell and sidebar to decide which navigation item is selected. It matches the
route **family** (`owns` = exact root or `root/…`), so nested details keep their
module selected, while prefix lookalikes (`/app/employee`) never match
`/app/employees`. The shell derives selection from the current URI, not from
local widget state.

## 4. Route guards

Redirect order (see `authRedirect` in `app_router.dart`):

1. session bootstrapping → `/bootstrap` (intended URL preserved in `?from=`).
2. unauthenticated → `/login` with a safe `from` target.
3. module disabled for the company → `/app/module-unavailable`.
4. permission denied → `/app/access-denied`.
5. entity/record scope is enforced inside repositories (`Result` failures), not
   by hidden navigation.

Nested routes inherit the same guards. Hiding a navigation item is not security;
direct deep links are always re-evaluated.

## 5. Deep links & refresh

Every detail/create/edit/review screen loads from its **route parameter**, not
from a previously selected list item. Opening
`/app/employees/EMP-12` directly (new tab, paste, refresh, desktop restore)
mounts the shell, resolves the company/permissions, and loads the employee by
id. Unknown ids render the module's not-found state; unauthorized ids are
blocked by guards/repositories.

Detail pages call `context.pop()` when they can pop (Back returns to the list or
queue) and fall back to the module root when opened directly with no parent
stack.

## 6. Unsaved changes

`FormNavigationGuard.onExit` is attached to create/edit routes
(`onExit`), so AppBar back, browser back, sidebar clicks and breadcrumb
navigation all run the same discard/keep-editing confirmation. `Esc` closes
overlays but does not silently discard a dirty form.

## 7. Web / hosting

Flutter Web uses the path URL strategy (`usePathUrlStrategy()` in bootstrap), so
URLs are `https://host/app/employees/EMP-12` — no `#` fragment. Because these
are real deep links, the host must serve `index.html` for unknown paths
(SPA fallback). Example Nginx:

```
location / { try_files $uri $uri/ /index.html; }
```

Firebase Hosting / Vercel / Netlify: rewrite all paths to `/index.html`. Without
that rewrite, refresh on a nested path returns a host 404 even though routing is
correct.

## 8. Future platform deep links

Android App Links / iOS Universal Links are not configured yet; the route
architecture is ready for them. Integration point: map the incoming platform URI
to the router's initial location (same path scheme), then let the existing
guards run.

## 9. Auth bootstrap & safe return location

While the session is bootstrapping (`AuthStatus.bootstrapping`), the router
holds the decision and routes to `/bootstrap?from=<intended path>` instead of
bouncing to login, so a refresh on a deep link does not lose the URL. After
bootstrap:

- authenticated + authorized → the requested location loads;
- authenticated + unauthorized → `/app/access-denied`;
- module disabled → `/app/module-unavailable`;
- unauthenticated → `/login?from=<intended path>`.

Return locations are validated (`safeTarget`): only internal app paths owned by
a registered module (or known utility paths) are accepted; external/absolute
URLs and malformed paths are rejected and fall back to the default landing.
After sign-in the requested location is restored only if the new session is
authorized, otherwise the default permitted landing is used.

Entity scope is enforced again on load. A route-level allow (e.g. an employee
`employeeViewSelf` route) never implies access to an arbitrary record id; the
page/repository re-evaluates scope and renders Unauthorized/Not Found without
leaking the record.

## 10. Fallback back navigation

`context.popOrGo(fallback)` (`lib/shared/navigation/app_navigation.dart`) pops
when there is history, otherwise replaces the current location with the module
root, so a directly deep-linked detail screen always has a sane parent. The
canonical fallback for a path is resolved with
`moduleRootForPath(path, registry)` using the same longest-match resolver as the
sidebar (`/app/attendance/history/ATT-1` → `/app/attendance/history`).

## 11. Dirty-form navigation

`FormNavigationGuard.onExit` is attached to every create/edit route, so AppBar
back, browser back, system back, sidebar/rail/bottom-nav, breadcrumbs and
in-app links all trigger the same Discard / Keep Editing confirmation. Keep
Editing cancels the navigation (URL stays on the edit route, form data intact);
Discard continues the originally requested navigation.

## 12. Query-parameter policy

Entity identity always lives in the path. Query parameters are reserved for
meaningful, shareable list/report state (`page`, `status`, `date`, `month`,
report `type`) and are validated defensively — invalid values fall back to
defaults and never crash. Authority is never taken from a query parameter: for
example `scope` is always derived from the session's permissions, not the URL.
Complex filter sets (many selected ids) stay local rather than bloating the URL.

