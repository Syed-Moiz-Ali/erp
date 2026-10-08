# Attendance (Shift-wise Punch In / Out) API — Flutter Handoff

Self-service attendance for the **logged-in employee**, per **shift**. An employee has up to **3 shifts a day**
(assigned by the admin, see `FLUTTER_SHIFT_API.md`) and punches **in and out once per shift**, with any number of
breaks inside a shift. Four buttons: **Punch In**, **Break**, **Resume**, **Punch Out** — all sent to **one URL**.

The server records the time from its **UTC clock** (the phone's clock and location never decide the time), shows it
in the **company's time zone**, decides which shift the button applies to, and returns the full status after every call.

> **Changed 2026-10-02 (UTC + time zones, time contract v0.1) — breaking:**
> * Every date-time now has an **offset**: `"2026-10-02T09:05:00+04:00"` (was `"2026-10-02T09:05:00"`).
>   Affected: `serverTime`, `punchIn`, `punchOut`, break `start` / `end`.
> * New `timeZone` (IANA name, e.g. `"Asia/Dubai"`) on the day and on every shift.
> * `recordedManually` (state and shift status) and `ATTENDANCE_RECORDED_MANUALLY` **no longer exist**.
> * New error `409 BRANCH_TIMEZONE_MISSING` (the employee's company has no time zone).
> * Dates (`date`, `shiftDate`) and planned times (`plannedStart`, `plannedEnd`, `punchInOpensAt`) are unchanged.

Base URL (dev): `http://localhost:5257` · All endpoints need `Authorization: Bearer <accessToken>`.
The user's login must be linked to an **active employee** (`user.empId` in the login response is not null); the login
response also returns `user.timeZone`. **No shift assigned today = no punching** (the screen shows "No shift today").

## Endpoints

| Method | URL | Body | Use |
|---|---|---|---|
| GET | `/api/attendance/today` | – | Load the screen, refresh, and after any 409 |
| POST | `/api/attendance/punch` | `{ "action": "...", "latitude": ..., "longitude": ... }` | **Every button** |

```json
{ "action": "punchIn", "latitude": 25.20485, "longitude": 55.27078 }
```

| Field | Rule |
|---|---|
| `action` | **Required.** `punchIn` · `break` · `resume` · `punchOut` (case-insensitive; numbers are rejected) |
| `latitude` / `longitude` | Optional — send both or neither. −90…90 / −180…180, stored with 5 decimals (≈ 1 m), saved on **every** punch |

The request never contains a time.

## Response (both endpoints, `200`)

Example at **00:20 on 2 Oct, Dubai**: last night's Night shift (19:00–02:00, shift date 1 Oct) still running after a
break across midnight, and a Morning shift today.

```json
{
  "success": true,
  "message": "Work resumed.",
  "data": {
    "employeeId": 15,
    "date": "2026-10-02",
    "timeZone": "Asia/Dubai",
    "state": "working",
    "allowedActions": [ "break", "punchOut" ],
    "currentShiftNo": 1,
    "nextShiftNo": 2,
    "shifts": [
      {
        "shiftNo": 1, "employeeShiftId": 6, "shiftId": 6, "shiftName": "Night",
        "shiftDate": "2026-10-01", "timeZone": "Asia/Dubai", "crossesMidnight": true,
        "plannedStart": "19:00:00", "plannedEnd": "02:00:00", "punchInOpensAt": "18:45:00",
        "status": "working",
        "punchIn": "2026-10-01T18:50:00+04:00", "punchOut": null,
        "punchInLocation": { "latitude": 25.20485, "longitude": 55.27078 },
        "lateMinutes": 0, "earlyLeaveMinutes": 0,
        "workedMinutes": 290, "breakMinutes": 40,
        "breaks": [ { "start": "2026-10-01T23:30:00+04:00", "end": "2026-10-02T00:10:00+04:00", "minutes": 40 } ]
      },
      {
        "shiftNo": 2, "employeeShiftId": 7, "shiftId": 1, "shiftName": "Morning",
        "shiftDate": "2026-10-02", "timeZone": "Asia/Dubai", "crossesMidnight": false,
        "plannedStart": "09:00:00", "plannedEnd": "12:00:00", "punchInOpensAt": "08:45:00",
        "status": "upcoming",
        "punchIn": null, "punchOut": null, "punchInLocation": null,
        "lateMinutes": 0, "earlyLeaveMinutes": 0,
        "workedMinutes": 0, "breakMinutes": 0, "breaks": []
      }
    ],
    "workedMinutes": 290,
    "workedHours": 4.83,
    "breakMinutes": 40,
    "serverTime": "2026-10-02T00:20:00+04:00"
  },
  "errors": []
}
```

### Day fields

| Field | Meaning |
|---|---|
| `date` | Today in the company's time zone (`yyyy-MM-dd`) |
| `timeZone` | The company's IANA time zone, e.g. `Asia/Dubai` |
| `state` | See the table below |
| `allowedActions` | **Enable only these buttons** |
| `currentShiftNo` | The shift the buttons apply to (working / on break / open for punch-in); `null` otherwise |
| `nextShiftNo` | Next shift whose punch-in has not opened yet — show "Next shift opens at `punchInOpensAt`" |
| `shifts` | Today's shifts **plus last night's shift if it crosses midnight**, in punch-in order (`shiftNo` 1..n) |
| `workedMinutes` / `workedHours` | Work time of the listed shifts **excluding breaks**, real elapsed minutes (a running period counts up to `serverTime`) |
| `breakMinutes` | Total break time of the listed shifts |
| `serverTime` | Server time in the company's zone, with offset — run live timers from this, **not** from the phone clock |

### Shift fields

| Field | Meaning |
|---|---|
| `shiftDate` | The date the shift **starts** in its time zone (`yyyy-MM-dd`) — its attendance and payroll date. Yesterday for last night's shift |
| `timeZone` | IANA time zone of this shift's times (the company's zone when the shift was assigned) |
| `crossesMidnight` | `true` when the shift ends the next day (`plannedEnd` is on `shiftDate` + 1). Show e.g. "7:00 PM – 2:00 AM (+1)" |
| `plannedStart` / `plannedEnd` | The shift as assigned, wall clock of `timeZone` (`HH:mm:ss`, 24-hour) |
| `punchInOpensAt` | Punch In accepted from here (on `shiftDate`) until `plannedEnd` |
| `status` | `upcoming` · `open` · `working` · `onBreak` · `completed` · `missed` · `missedPunchOut` |
| **`punchIn`** | **Actual Punch In**, date + time + offset (`2026-10-01T18:50:00+04:00`) |
| **`punchOut`** | **Actual Punch Out**; `null` until the shift is `completed` |
| `punchInLocation` | Location sent with Punch In (`null` when none was sent) |
| `lateMinutes` | Minutes after `plannedStart` when Punch In was later than the grace period; else 0 |
| `earlyLeaveMinutes` | Minutes before `plannedEnd` when Punch Out was earlier; else 0 |
| `workedMinutes` / `breakMinutes` / `breaks` | This shift only; break `start` / `end` with offset; `end: null` = break running |

## Showing times (Dart)

The **main display is the company's time** (what the workplace clock showed), exactly as sent:

```dart
// "2026-10-01T18:50:00+04:00" -> 18:50 (company time). Do NOT format DateTime.parse(s) directly:
// with an offset it returns a UTC DateTime (14:50).
DateTime companyTime(String s) => DateTime.parse(s.substring(0, 19)); // wall-clock part, no zone

// Optional second label "your time": the phone's zone.
DateTime phoneTime(String s) => DateTime.parse(s).toLocal();

// Durations: use workedMinutes / breakMinutes from the API. Live timer while working:
// workedMinutes + (DateTime.now().toUtc() - DateTime.parse(serverTime)).inMinutes
```

Never group or label by the date of a converted time — use `shiftDate`.

## States and buttons

| `state` | Meaning | Show |
|---|---|---|
| `noShift` | No shift assigned today | "No shift today" — no buttons |
| `waitingForShift` | Next shift not open yet | "Next shift (name) opens at `punchInOpensAt`" — no buttons |
| `readyToPunchIn` | A shift's window is open | **Punch In** |
| `working` | In a shift | **Break**, **Punch Out** |
| `onBreak` | On a break | **Resume**, **Punch Out** |
| `completed` | No more shifts today | Day summary — no buttons |

While `waitingForShift`, call `GET today` again when `punchInOpensAt` of `nextShiftNo` is reached.

## Shift status meanings

| `status` | Meaning |
|---|---|
| `upcoming` | Punch-in window not open yet |
| `open` | Window open, not punched in — Punch In now |
| `working` / `onBreak` | In this shift |
| `completed` | Punched in and out |
| `missed` | Never punched in (window closed at `plannedEnd`, or a later shift was started) |
| `missedPunchOut` | Punched in but not out before the next shift's window opened, or **4 hours after the planned end** — **HR corrects it**; the employee can punch in to the next shift |

## Errors

| HTTP | `errors[0].code` | App action |
|---|---|---|
| 400 | `VALIDATION_ERROR` (field `action` / `latitude` / `longitude`) | Bug in the app — check the body |
| 401 | `AUTH_UNAUTHORIZED` / `AUTH_TOKEN_EXPIRED` | Log in again |
| 403 | `ATTENDANCE_NO_EMPLOYEE` | "Your login is not linked to an employee." — hide attendance |
| 403 | `ATTENDANCE_EMPLOYEE_INACTIVE` | Show the message |
| 409 | `BRANCH_TIMEZONE_MISSING` | Show the message ("Your company has no time zone set…") — HR must set it |
| 409 | `ATTENDANCE_NO_SHIFT` | "No shift assigned today" |
| 409 | `ATTENDANCE_SHIFT_NOT_OPEN` | Show the message (contains the opening time) |
| 409 | `ATTENDANCE_DAY_COMPLETE` | No more shifts today |
| 409 | `ATTENDANCE_INVALID_ACTION` | Button no longer valid (double tap, other device) — call **GET today** and redraw |
| 503 | `ATTENDANCE_BUSY` / `SERVICE_UNAVAILABLE` | Retry after a few seconds |

Disable the button while its request is running; a repeated tap is harmless (409) but avoid it.
Always show `message` from the response — it is written for the user (e.g. "Punched in for Morning (20 min late).").

## Rules

* Punch In is accepted from the early window (default 15 minutes) before a shift until its planned end. Later than
  the grace period (default 15 minutes) after the start counts as late (`lateMinutes`, counted from the planned start).
* One Punch In and one Punch Out per shift (also enforced by the database); any number of breaks inside a shift.
* A forgotten Punch Out is **not** closed automatically: when the next shift's window opens, or 4 hours after the
  planned end, the shift becomes `missedPunchOut` for HR to correct, and the buttons move to the next shift.
* **Night shifts** (e.g. 19:00–02:00): punch in in the evening; breaks, resume and punch out after midnight apply to
  the same shift. All of its hours belong to `shiftDate` (the day it started) — also for payroll.
* Hours are **real elapsed time**: on a summer-time night (countries that change clocks) a 22:00–06:00 shift is 7 or
  9 hours. UAE and India do not change clocks.
* An employee working abroad still punches against their **company's** hours and calendar (time contract D1).
