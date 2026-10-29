# Manual test checklist

Run once against the shared database. Use QA-named records only. Do not loop,
stress, or bulk-create. Do not revoke the three live orphan grants unless the
backend owner asks for cleanup.

## Accounts

- **Admin**: current administrator account.
- **Employee view+edit**: the employee account with `hr.employees.view` and
  `hr.employees.edit` (live user 43).
- **Fresh employee**: a QA employee login with no grants.

## A. Admin

1. Launch the app and sign in at `/login`.
2. Confirm the app shell loads and `/api/me/permissions` is fetched once.
3. Open **Employees** (`/app/hr/employees`).
4. Confirm the list loads, search works, and `EMP-33` is visible.
5. Open `EMP-33`; confirm detail, login section and no `userType` field.
6. Use **Edit** on the QA employee; change only a QA description/designation.
   Save once. Expected: success or a field-level backend error; no dropped
   fields and no `login.userType` in the PUT payload.
7. Open **Settings -> Shifts** (`/app/hr/settings/shifts`).
8. Confirm the list loads (live shift options have 22 active shifts).
9. Create one `QA Shift Checklist` record once. Edit its grace/early minutes.
   Deactivate it once. Expected: duplicate/in-use/validation messages map to the
   form, not a generic crash.
10. Open **Settings -> Employee Shifts** (`/app/hr/employee-shifts`).
11. Click **Add assignment**. Expected: employee selector is live and includes
    `EMP-33`; shift selector is live. Assign `EMP-33` to the QA shift for one
    short QA date range.
12. Edit the assignment dates once; then remove it once. Expected: overlap,
    limit, date-order and timezone errors appear on `toDate`/`timeZoneId`.
13. Open **Settings -> Branches**. View the list and one detail. If a QA branch
    already exists, open it; otherwise create one `QA Branch Checklist` once
    with an IANA time zone. Deactivate it once.
14. Open **Settings -> Departments**. Create/rename one `QA Department Checklist`
    once. Deactivate it once. Expected: duplicate/in-use errors map to the form.
15. Open **Settings -> Access & Users**. Confirm the user list loads and the
    Admin entry is present.
16. Open the employee view+edit account. Confirm view/edit grants are visible and
    **Add permissions**/**Save changes** are available.
17. Open **Permission catalog**. Confirm the list loads, the QA permission row is
    visible, and edit/activate/deactivate controls work without a crash.
18. Return to the employee access detail. Confirm the three orphan rows are
    visible with **Revoke** actions. Do not revoke them.
19. Open **Attendance Today** (`/app/hr/attendance-today`). Expected for Admin:
    the day resolves; no punch buttons unless the backend sends allowed actions.
20. Sign out from the user menu once. Expected: login screen, session cleared.

## B. Employee with view+edit

1. Sign in as the employee view+edit account.
2. Confirm the navigation contains **Dashboard**, **Employees** and **Attendance
   Today**.
3. Confirm **Settings**/Access administration, Branches, Departments, Shifts and
   Employee Shifts are absent.
4. Open **Employees**. Expected: list and detail load; **Add** is absent;
   **Edit** is visible; **Deactivate** is absent; login-management controls are
   absent.
5. Open `EMP-33`, make one QA-only edit, and save once. Expected: success; no
   create/deactivate/login actions appear.
6. Enter `/app/settings/branches`, `/app/hr/settings/shifts` and
   `/app/settings/access` directly. Expected: permission-denied/unavailable
   state, never the data screen.
7. Open **Attendance Today**. Expected: the employee's real day loads; punch
   buttons appear only for actions in `allowedActions`; no client-invented
   actions.
8. Sign out once.

## C. Fresh employee with no grants

1. Sign in as the fresh QA employee.
2. Expected navigation: Dashboard and account/profile only. No Employees,
   Attendance, Settings or Access entries.
3. Enter `/app/hr/employees` directly. Expected: access-denied state.
4. Enter `/app/hr/attendance-today` directly. Expected: access-denied state.
5. Confirm the app does not crash and does not fetch employee/attendance data.
6. As Admin, open **Employees → Details → Manage access** for this fresh QA
   employee. The existing user-access editor opens for `login.userId` even
   though the account has no grants. Expected: **No permissions assigned** with
   **Add permissions**. Add `hr.employees.view` once and save.
7. Sign in again as the fresh employee after the grant is applied. Expected:
   Employees appears only if `hr.employees.view` is present; Edit appears only
   if `hr.employees.edit` is present.

## Expected permission-tree behaviour

| Area | Admin | Employee view+edit | Fresh employee |
|---|---|---|---|
| Dashboard/account | Yes | Yes | Yes |
| Employees entry | Yes | Yes | No |
| Employees list/detail | Yes | Yes | No |
| Add employee | Yes | No | No |
| Edit employee | Yes | Yes | No |
| Deactivate employee | Yes | No | No |
| Login section/enable login | Yes | No | No |
| Attendance Today | Yes (self) | Yes (self) | No |
| Branches/Departments/Shifts | Yes | No | No |
| Employee Shifts | Yes | No | No |
| Access & Users / Permission catalog | Yes | No | No |
| Direct protected URLs | Allowed | Employees/Attendance only | Denied |

## Punch check

Only run a punch if the live day returns the action and you are inside its
window. Use the employee account once:

- `punchIn` -> expect working state and server time.
- `break` -> expect onBreak and an open break.
- `resume` -> expect working and closed break.
- `punchOut` -> expect completed and no further actions.

If the day returns `noShift`/`waitingForShift` or `409 DAY_COMPLETE`/
`ATTENDANCE_NO_SHIFT`, do not retry; record the message and stop.
