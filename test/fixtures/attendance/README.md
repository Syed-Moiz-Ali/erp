# Attendance fixtures

## Live capture (2026-10-29)

Read-only `GET /api/attendance/today` with both accounts; no punch calls were
made. Sanitized live files:
- `today_employee.json` - employee account, state `waitingForShift`, next shift
  no. 2 with a missed overnight shift and an upcoming overnight shift.
- `today_admin.json` - administrator account, state `noShift`.
- `today_no_shift.json` - replaced with the live administrator `noShift`
  response.

## Fallback fixtures

These states were not observed live and remain labelled **audit fallback**:
- `today_working.json` - `working`, allowedActions `break/punchOut`, current and
  next shift, breaks with offset timestamps.
- `today_completed.json` - `completed`, no allowed actions.
- `day_complete_error.json` - `409 DAY_COMPLETE`.
- `no_shift_error.json` - `409 ATTENDANCE_NO_SHIFT`.

The live `waitingForShift` state is not represented by a 409; it is a successful
day response with no allowed actions.

Observed contract: `employeeId`, `date`, `timeZone`, `state`, `allowedActions`,
`currentShiftNo`, `nextShiftNo`, `shifts[]`, `workedMinutes`, `workedHours`,
`breakMinutes`, `serverTime`. Shift fields include
`shiftNo, employeeShiftId, shiftId, shiftName, shiftDate, timeZone,
crossesMidnight, plannedStart, plannedEnd, punchInOpensAt, status, punchIn,
punchOut, punchInLocation, lateMinutes, earlyLeaveMinutes, workedMinutes,
breakMinutes, breaks[]`. Break `end` is null while running.

Punch writes were not called; punch bodies remain audit/Postman shapes only.
