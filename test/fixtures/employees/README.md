# Employees fixtures

## Live negative capture (2026-10-28)

- `employees_forbidden_admin.json` — live `GET /api/employees` with the
  administrator token returned `403 ACCESS_DENIED` because the account does not
  hold `hr.employees.view`.
- `employees_forbidden_employee.json` — live `GET /api/employees` with the
  employee token also returned `403 ACCESS_DENIED`.
- Per instruction, the live employee capture stopped at the precondition. No
  grant/write was attempted and no employee data was fetched.

## Fallback fixtures

The success fixtures are **audit fallback**, not live captures:

- `employees_list.json`, `employees_list_filtered.json`
- `employee_detail.json`
- `employee_not_found.json`
- `employee_lookups.json`

They use the audit/Postman field names and the audit's sanitized list/detail
examples. Personal names, contact numbers, emails and document identifiers are
placeholders. The fallback detail intentionally includes only fields evidenced
by audit 04/Postman; the production PUT still preserves any additional field in
the raw detail map.

## Contract notes

- PUT is a full replacement. The repository re-reads detail and overlays form
  edits on the saved raw map so loaded fields are not dropped.
- Login lives under `login.*`; the login section requires
  `company.users.manage` and activate does not re-enable login.
- Branch selectors use `/api/branches?status=Active`; department selectors use
  `/api/departments` (active-only). Login `branches[]` is not used for
  selectors.
