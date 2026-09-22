# Performance Rules

Phase 13 performance guardrails. Apply these when adding or changing screens.

## Rebuilds

- Only the live clock area rebuilds every second. `AttendanceTickerCubit`
  (`lib/features/attendance/presentation/attendance_ticker_cubit.dart`) drives a
  scoped `BlocBuilder` around the timer only — the shift card, timeline,
  sidebar, and page must not rebuild on each tick.
- Workforce monitoring ticks at minute granularity; it must not create a
  `Timer` per row.
- Prefer `BlocSelector` / `buildWhen` for narrow subscriptions.
- Do not rebuild the whole page to swap a badge or a status chip.

## Data access

- Widgets never touch Drift directly. Go through repositories.
- Prefer scoped watches: current employee/day for Attendance Today; selected
  date/scope for Team Attendance; current user for notifications.
- Pagination for large tables (default 25) and repository-side sorting/filtering.
- Avoid N+1 queries; report and workforce aggregation run as single SQL
  queries with `SUM`/`COUNT`/`GROUP BY`.

## Lists

- Use `ListView.builder` / slivers for long lists; never build hundreds of
  offscreen cards.
- Tables are paginated; mobile uses compact cards.

## Timers, streams, controllers

- Cancel every `StreamSubscription`, `Timer`, `AnimationController`,
  `FocusNode`, `TextEditingController`, and `ScrollController` in `dispose`.
- Sync is event-driven: startup, app resume, connectivity change, manual retry.
  No `Timer.periodic` polling of the server.
- Reminders are scheduled through `DeviceNotificationService`; do not keep a
  long-running Dart timer alive waiting for a shift reminder.

## Streams

- Repository watches are cancelled on `onCancel`; the local-first watch
  helpers already guard against stale generations.

## Startup

- Cold start initializes dependencies, restores locale/session, opens the
  database once, and renders the shell. Expensive report/aggregation queries
  must not run at startup.

## Memory

- Avatars use `AppAvatar` (initials fallback) and must not decode full-size
  images for small display sizes.
- Debug inspectors and demo seeds stay behind `kDebugMode` / demo mode.
