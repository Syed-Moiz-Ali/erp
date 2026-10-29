# Employees fixtures

## Live capture (2026-10-29)

Captured read-only with the administrator and employee accounts after Admin was
granted `hr.employees.view`. Names, emails, mobiles, bank/account, passport,
Emirates ID, visa, work-permit, insurance and document fields are sanitized.
Envelopes, field names, types and nulls are preserved.

Live files:
- `employees_list.json` - Admin list, page 1, pageSize 25, sort nameAsc.
- `employees_list_filtered.json` - Admin list filtered by code, status,
  department and branch.
- `employees_list_employee.json` - employee-account list, same query as Admin.
- `employee_options.json` - live active employee selector source, pageSize 100,
  statusId 1; 34 rows.
- `employee_detail.json` - Admin detail for the first list employee.
- `employee_not_found.json` - live 404 for employee 999999.
- `employee_lookups.json` - Admin lookups.
- `employee_lookups_employee.json` - employee-account lookups.
- `employee_created.json` - sanitized create-response shape supplied by the
  live 201 (employeeId 1032, employeeCode EMP-33), with the same field shape as
  the live detail.
- `employees_forbidden_admin_pregrant.json` - historical Admin `403
  ACCESS_DENIED` before grant 145; it no longer reflects the live state.

The earlier employee-account employee `403` fixture was removed because that
account now has `hr.employees.view` and receives the same 25-row first page as
Admin.

## Contract notes

- `employeeId` and `employeeCode` are separate values; the client never derives
  one from the other.
- Live detail/login still contains `login.userType`, even though the backend
  removed it from the write contract. The client strips it from PUT bodies,
  ignores it otherwise and never displays it.
- `login.branchIds` is an integer array; `login.branchNames` is one
  comma-separated string.
- Live detail includes many nullable payroll/identity/document fields and money
  as decimals.
- PUT is a full replacement. The repository re-reads detail and overlays form
  edits on the saved raw map so loaded fields are not dropped, except
  `login.userType`, which is the single documented send-side exception.
- Login lives under `login.*`; the login section requires
  `company.users.manage` and activate does not re-enable login.
- Branch selectors use `/api/branches?status=Active`; department selectors use
  `/api/departments` (active-only).
