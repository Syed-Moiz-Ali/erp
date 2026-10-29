# Permissions fixtures

Live sanitized capture: **2026-10-29** for the employee/Admin permission
snapshots, `user_permissions_user8.json` and `user_permissions_assign.json`;
earlier permission fixtures were captured on **2026-10-28** by
`tool/access_capture.dart` against the configured base URL with
`ngrok-skip-browser-warning: true`.

## Live fixtures

- `permissions_list.json` — page 1, pageSize 25, sort keyAsc.
- `permissions_list_filtered.json` — statusId=1, pageSize 5.
- `permission_detail.json` — active valid key (id 4).
- `permission_detail_unknown.json` — inactive key with spaces (id 20).
- `permission_not_found.json` — GET id 999999, `PERMISSION_NOT_FOUND`.
- `user_permissions_all.json` — page 1, pageSize 100; total 135 rows, 8 orphans.
- `user_permissions_user.json` — employee user 43 / employee 27.
- `me_permissions_admin.json` - live, 15 keys including `hr.employees.view`.
- `me_permissions_employee.json` - live, 4 keys including view and edit.
- `user_permissions_user8.json` - live Admin user 8 grant list, 18 rows with
  orphan permission ids 1, 2 and 3.
- `user_permissions_assign.json` - sanitized assign response shape with the
  complete list, including three orphan rows.

## Observed contract

- Permission list: `{items, page, pageSize, totalItems, totalPages}`; 17 rows,
  15 active and 2 inactive. One inactive key is `bad key with spaces` (the
  backend still accepts it) and is treated as an unknown key by the client.
- Permission detail adds `createdBy`, `modifiedBy` and `modifiedOn`; both
  modifier fields are null for id 4 and populated for id 20.
- User permission rows expose `permissionKey`/`permissionName` as nullable.
  Eight live rows have `permissionKey: null`, `permissionStatusId: 2`; these are
  orphan grants and remain revocable. Inactive masters with a key are also
  treated as orphans in the domain.
- Admin `/me` now has 15 keys including `hr.employees.view`; the employee
  account has 4 keys including view and edit.
- All personal identity fields (`loginId`, `userName`, `employeeName`,
  `employeeCode`) and any phone field are sanitized. Tokens are not present in
  these fixtures.

## Write shapes

No live writes were sent. Create/update/activate/deactivate/assign/replace/revoke
requests must follow `audit-output/massep-2026-10-28/02-api-test-results.md`,
`04-response-contract-audit.md` and the Postman collection.
