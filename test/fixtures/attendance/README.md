# Attendance fixtures

**Fallback only.** On the 2026-10-28 re-check the configured ngrok endpoint
returned `404 text/plain` / "endpoint is offline" for `/api/attendance/today`, so
no live attendance capture was possible. These fixtures follow the sanitized
`AttendanceDayStatus` contract in audit 04 section 7 and are labelled fallback.

- `today_working.json` — `working`, allowedActions `break/punchOut`, current and
  next shift, breaks with offset timestamps.
- `today_completed.json` — `completed`, no allowed actions.
- `today_no_shift.json` — `noShift`, no shifts, no allowed actions.
- `day_complete_error.json` — `409 DAY_COMPLETE`.
- `no_shift_error.json` — `409 ATTENDANCE_NO_SHIFT`.

Observed contract (audit): `employeeId`, `date`, `timeZone`, `state`,
`allowedActions`, `currentShiftNo`, `nextShiftNo`, `shifts[]`, `workedMinutes`,
`workedHours`, `breakMinutes`, `serverTime`. Shift fields include
`shiftNo, employeeShiftId, shiftId, shiftName, shiftDate, timeZone,
crossesMidnight, plannedStart, plannedEnd, punchInOpensAt, status, punchIn,
punchOut, punchInLocation, lateMinutes, earlyLeaveMinutes, workedMinutes,
breakMinutes, breaks[]`. Break `end` is null while running.

No punch calls were made. Punch writes must use the audit/Postman shape only.
