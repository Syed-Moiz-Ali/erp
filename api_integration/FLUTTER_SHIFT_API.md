# Shifts & Shift Assignment API — Flutter Handoff (Admin / HR screens)

Admin screens to define **shifts** and assign them to **employees for a date range**. Employees then punch per shift
(see `FLUTTER_ATTENDANCE_API.md`).

> **Changed 2026-10-02 (UTC + time zones):** shift times are **wall-clock times of the employee's company time zone**
> (a "09:00" shift is 09:00 in Dubai for a Dubai company, 09:00 in Hyderabad for an India company). Assignments now
> return `timeZoneId` (copied from the company when assigned, never changed afterwards); `createdOn` / `modifiedOn`
> are **UTC** (`"…Z"`). New errors: `409 BRANCH_TIMEZONE_MISSING`, `409 EMPLOYEE_SHIFT_TIMEZONE_MISMATCH`.

Base URL (dev): `http://localhost:5257` · All endpoints need `Authorization: Bearer <accessToken>` and the web ERP
privilege on screen **3110 (HRMS Masters)**: view → GET, save → POST create, edit → PUT / activate / deactivate.
Missing privilege → `403 ACCESS_DENIED`.

## 1. Shifts (templates)

| Method | URL | Use |
|---|---|---|
| GET | `/api/shifts?page=1&pageSize=25&search=&statusId=&sort=startTime` | List (`sort`: `startTime` · `nameAsc` · `nameDesc` · `newest`; `statusId`: 1 Active, 2 InActive) |
| GET | `/api/shifts/{shiftId}` | Detail |
| POST | `/api/shifts` | Create (**201**) |
| PUT | `/api/shifts/{shiftId}` | Update |
| POST | `/api/shifts/{shiftId}/deactivate` | Delete (soft) |
| POST | `/api/shifts/{shiftId}/activate` | Re-activate |

Body (POST / PUT):

```json
{ "shiftName": "Morning", "startTime": "09:00", "endTime": "12:00", "earlyPunchInMinutes": 15, "lateGraceMinutes": 15 }
```

| Field | Rule |
|---|---|
| `shiftName` | Required, max 50, unique among active shifts (case-insensitive) |
| `startTime` / `endTime` | Required, `HH:mm`, **24-hour clock** (`"01:00"` = 1 AM, `"13:00"` = 1 PM; seconds ignored). A 12-hour picker in the app must send 24-hour values. **`endTime` earlier than `startTime` = night shift ending the next day** (`"19:00"` → `"02:00"`). Equal times are rejected |
| `earlyPunchInMinutes` | 0–120, default 15 — punch-in opens this many minutes before the start. The window cannot start before midnight (a `00:00` shift needs `0`), and the shift plus this window must not exceed 24 hours |
| `lateGraceMinutes` | 0–120, default 15 — punch-in later than this after the start is "late" |

Response item:

```json
{ "shiftId": 6, "shiftName": "Night", "startTime": "19:00:00", "endTime": "02:00:00", "durationMinutes": 420,
  "crossesMidnight": true, "punchInOpensAt": "18:45:00", "earlyPunchInMinutes": 15, "lateGraceMinutes": 15,
  "statusId": 1, "status": "Active", "activeAssignments": 3, "createdOn": "2026-10-01T12:10:00Z", "modifiedOn": null }
```

`crossesMidnight: true` → show the end as next day, e.g. "7:00 PM – 2:00 AM (+1)".

* **Editing a shift does not change existing assignments** — they keep the times they were assigned with (history
  stays correct). The response message says so when times change on an assigned shift; assign again to apply.
* **Deactivate** is refused while `activeAssignments > 0` (`409 SHIFT_IN_USE`) — remove or end the assignments first.

## 2. Assign shifts to employees

| Method | URL | Use |
|---|---|---|
| GET | `/api/employee-shifts?employeeId=&shiftId=&fromDate=&toDate=&includeInactive=false&page=1&pageSize=25` | List (date range = assignments **overlapping** it) |
| GET | `/api/employee-shifts/{employeeShiftId}` | Detail |
| POST | `/api/employee-shifts` | Assign (**201**) |
| PUT | `/api/employee-shifts/{employeeShiftId}` | Change shift, dates (e.g. end early) and / or time zone (only before the first punch) |
| POST | `/api/employee-shifts/{employeeShiftId}/deactivate` | Remove |

Body:

```json
{ "employeeId": 14, "shiftId": 1, "fromDate": "2026-10-01", "toDate": "2026-10-31" }
```

Work location in another time zone (e.g. an India-company employee working 12–18 Oct in Dubai):

```json
{ "employeeId": 18, "shiftId": 1, "fromDate": "2026-10-12", "toDate": "2026-10-18", "timeZoneId": "Asia/Dubai" }
```

| Field | Rule |
|---|---|
| `employeeId` | Required on POST (active employee — use `GET /api/employees?statusId=1`). On PUT optional and cannot change |
| `shiftId` | Active shift (`GET /api/shifts?statusId=1`) |
| `fromDate` / `toDate` | `yyyy-MM-dd`, inclusive, `toDate ≥ fromDate`, at most 366 days |
| `timeZoneId` | **Optional.** IANA name (`id` from `GET /api/branches/lookups` → `timeZones`). The shift's times are read in this zone. Not sent / `null` / blank: POST uses the employee's company zone, PUT keeps the assignment's zone. Send it only when HR picks a zone other than the company's |

**Changing the zone on PUT** is allowed only while the assignment has **no punches**. After the first punch it returns
`409 EMPLOYEE_SHIFT_HAS_PUNCHES`: set `toDate` to end the assignment, then POST a new one from the next day with the new
`timeZoneId`. Sending the same zone again (or leaving it out) is always fine.

Response item:

```json
{ "employeeShiftId": 7, "employeeId": 14, "employeeCode": "EMP-14", "employeeName": "Test Employee",
  "shiftId": 1, "shiftName": "Morning", "fromDate": "2026-10-01", "toDate": "2026-10-31",
  "startTime": "09:00:00", "endTime": "12:00:00", "earlyPunchInMinutes": 15, "lateGraceMinutes": 15,
  "statusId": 1, "status": "Active", "timeZoneId": "Asia/Dubai", "punchInOpensAt": "08:45:00", "crossesMidnight": false }
```

`timeZoneId` is the zone the times above are in: the one sent when assigning, else the company's zone at that moment.
If the company's zone changes later, existing assignments keep theirs.

Rules checked on every save:

* **Max 3 shifts per employee per day** (a night shift counts on the day it starts).
* Shifts of the same employee must **not overlap, including the early punch-in window**
  (9:00–12:00 then 12:00–15:00 is rejected because the second opens at 11:45; 12:15 or later is fine).
* **Also across midnight:** a Night 19:00–02:00 on 1 Oct clashes with a 01:00–04:00 shift on 2 Oct (its window
  opens 00:45, before the night ends). A shift whose window opens at 02:00 or later that morning is fine.
* All assignments of an employee on overlapping or neighbouring dates must be in **one time zone** (after a move to a
  company in another zone, end the old assignments before assigning new ones).
* To end an assignment early, PUT a new `toDate`; "Remove" hides it from lists. A removed shift that the employee has
  already punched into today can still be punched out.

## Errors

| HTTP | `errors[0].code` | When |
|---|---|---|
| 400 | `VALIDATION_ERROR` (+ `field`) | Missing / invalid fields, start = end, early window before midnight or over 24 h, dates reversed, employee / shift inactive or unknown, employee changed on PUT |
| 403 | `ACCESS_DENIED` | No privilege on screen 3110 |
| 404 | `SHIFT_NOT_FOUND` / `EMPLOYEE_SHIFT_NOT_FOUND` | Unknown id (or removed assignment on PUT) |
| 409 | `SHIFT_DUPLICATE_NAME` (field `shiftName`) | Active shift with that name exists |
| 409 | `SHIFT_IN_USE` | Deactivating a shift that is still assigned |
| 409 | `SHIFT_ALREADY_ACTIVE` / `SHIFT_ALREADY_INACTIVE` | Status unchanged |
| 409 | `EMPLOYEE_SHIFT_OVERLAP` (field `shiftId`) | Times overlap another shift of the employee on those dates (also a night shift of the day before / after) |
| 409 | `EMPLOYEE_SHIFT_LIMIT` (field `fromDate`) | The employee already has 3 shifts on a date (the message names it) |
| 409 | `EMPLOYEE_SHIFT_ALREADY_REMOVED` | Removing twice |
| 400 | `VALIDATION_ERROR` (field `timeZoneId`) | `timeZoneId` is not an IANA time zone (Windows names like "Arabian Standard Time" and offsets like "+04:00" are rejected) |
| 409 | `BRANCH_TIMEZONE_MISSING` | No `timeZoneId` sent and the employee's company has no time zone — set it on the company first |
| 409 | `EMPLOYEE_SHIFT_HAS_PUNCHES` (field `timeZoneId`) | PUT changes the zone of an assignment that already has punches |
| 409 | `EMPLOYEE_SHIFT_TIMEZONE_MISMATCH` (field `fromDate`) | Another assignment around these dates is in a different time zone |
| 503 | `SERVICE_BUSY` / `SERVICE_UNAVAILABLE` | Retry after a few seconds |
