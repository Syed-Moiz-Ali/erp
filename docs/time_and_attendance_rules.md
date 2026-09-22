# Time & Attendance Rules

How time is stored, interpreted and grouped so attendance stays correct across
timezones, overnight shifts and later configuration changes.

## 1. Storage standard

- **Instants** (punch in/out, event timestamps, `createdAt`, `updatedAt`,
  `serverTimestamp`) are stored as **UTC epoch milliseconds** (`attendanceInstant`).
- **Workday date** (`AttendanceDay.attendanceDate`) is a **business date**
  (`yyyy-MM-dd` in company/shift timezone), stored separately from instants.
- Configuration snapshots store the timezone used for the workday.

Never mix local and UTC unpredictably.

## 2. Time abstractions

- `AppClock` (`SystemAppClock`) — the injected source of "now" for business logic.
- `CompanyTimeService` — converts between company-local wall time and UTC, using
  the company/shift timezone.
- `ShiftWorkdayResolver` — resolves the active/next workday, shift boundaries
  and late/early evaluation against the shift + policy snapshot.

Business rules (workday date, late detection, current month, shift start,
overnight grouping, correction window, reminder scheduling, report boundaries)
go through these, not raw `DateTime.now()`. Raw `DateTime.now()` is only used for
purely cosmetic UI (e.g. a relative-time label) or non-attendance write stamps.

## 3. Company timezone vs device timezone

Business interpretation uses the **company/shift timezone**, not the device
timezone. A user whose device is set to another timezone still gets the correct
attendance day and shift boundaries. Location capture still comes from device
GPS; timezone and location are separate concerns. Display uses localized
formatters (`AppDateFormatter`, `AppTimeFormatter`) over the intended zone.

## 4. Overnight shifts

An `AttendanceDay` belongs to its **shift-start workday date**. A shift
`17 Sep 22:00 → 18 Sep 07:00` is the `17 Sep` attendance day everywhere:

- Attendance Today resolves the active day via `ShiftWorkdayResolver`;
- History groups by `AttendanceDay.attendanceDate`, not punch-out calendar date;
- Corrections validate against the same workday;
- Reports group by the workday date and use the historical snapshot;
- Reminders schedule from the shift start (already crossing midnight correctly).

No feature re-groups overnight attendance by punch-out time.

## 5. Historical snapshots

On first punch-in a full `AttendanceConfigurationSnapshot` (shift, policy, work
location, timezone, scheduled start/end, work mode) is frozen onto the
`AttendanceDay`. Historical attendance always reads that snapshot:

- Day Details / History show the frozen shift times and location;
- Reports use the snapshot shift/location names and times;
- the Correction validator projects changes against the frozen snapshot, not
  today's configuration.

Changing a Shift/Policy/Location today never rewrites yesterday's meaning. The
next workday picks up the new configuration.

## 6. Known limitation: assignment history

Employee-to-department/designation/manager assignments are not versioned. A day
with **no** historical `AttendanceDay` cannot be reconstructed to its old shift
or location; the UI shows a neutral "No attendance record" instead of
fabricating schedule data.

## 7. Display

Durations/numbers/dates are rendered through the centralized formatters; mixed
values (employee codes, emails, times) keep local direction so Arabic screens
stay readable.
