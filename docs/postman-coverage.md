> **v3 applicability (2026-10-29):** Produced during the previous integration session. For API v3 the UI baseline is `ac2ec6f`; UI/UX is frozen and demo/local code stays until a separate, module-by-module removal phase. Statements about the 5df51cf UI, a live-only runtime, or removed demo paths are historical and do not describe v3.

# Postman coverage matrix

Audit date: 2026-10-29

Source: `../audit-output/massep-2026-10-28/` (read-only; API inventory, test results and response-contract audit).
No endpoint was called for this matrix. The collection contains **100 requests**:
**83 WIRED**, **5 PARTIAL**, **12 NOT WIRED**.

Status definitions:

- **WIRED** - the client has a real call path (repository/data source), a screen or
  intentional automatic flow, and test/fixture evidence for the contract.
- **PARTIAL** - the transport or a screen exists, but there is no direct UI path,
  no filter/detail use, or a specific error path is not handled.
- **NOT WIRED** - no product call path. Some rows are intentionally Postman-only
  access-check or negative-test scenarios.

## Full request matrix

| Folder | Request | Method + path | Permission key | Repository method | Screen / trigger | Fixture | Test | Status |
|---|---|---|---|---|---|---|---|---|
| Authentication | Login - Valid | POST `{{baseUrl}}/api/auth/login` | none | RemoteAuthRepository.login | Login screen -> Sign in | auth/login_* | auth_fixture_mapper_test, remote_auth_repository_test | WIRED |
| Authentication | Login - Invalid Password | POST `{{baseUrl}}/api/auth/login` | none | RemoteAuthRepository.login | Login screen -> Sign in | auth/login_* | auth_fixture_mapper_test, remote_auth_repository_test | WIRED |
| Authentication | Login - Invalid Username | POST `{{baseUrl}}/api/auth/login` | none | RemoteAuthRepository.login | Login screen -> Sign in | auth/login_* | auth_fixture_mapper_test, remote_auth_repository_test | WIRED |
| Authentication | Login - Empty LoginId | POST `{{baseUrl}}/api/auth/login` | none | RemoteAuthRepository.login | Login screen -> Sign in | auth/login_* | auth_fixture_mapper_test, remote_auth_repository_test | WIRED |
| Authentication | Login - Empty Password | POST `{{baseUrl}}/api/auth/login` | none | RemoteAuthRepository.login | Login screen -> Sign in | auth/login_* | auth_fixture_mapper_test, remote_auth_repository_test | WIRED |
| Authentication | Refresh token | POST `{{baseUrl}}/api/auth/refresh` | none | RemoteAuthRepository refresh + TokenRefresher | Automatic on expiry / 401 | auth/refresh_success.json | auth_refresh_flow_test, auth_security_test | WIRED |
| Authentication | Refresh - old token after 30 s - 401 REUSED (ends session) | POST `{{baseUrl}}/api/auth/refresh` | none | RemoteAuthRepository refresh + TokenRefresher | Automatic on expiry / 401 | auth/refresh_success.json | auth_refresh_flow_test, auth_security_test | WIRED |
| Authentication | Logout | POST `{{baseUrl}}/api/auth/logout` | none | RemoteAuthRepository.logout | User menu -> Logout | auth/logout_success.json | auth_test, remote_auth_repository_test | WIRED |
| Authentication | Refresh after logout - 401 INVALID | POST `{{baseUrl}}/api/auth/refresh` | none | RemoteAuthRepository refresh + TokenRefresher | Automatic on expiry / 401 | auth/refresh_success.json | auth_refresh_flow_test, auth_security_test | WIRED |
| Employees | Lookups (dropdowns) | GET `{{baseUrl}}/api/employees/lookups` | hr.employees.view | RemoteLiveEmployeeRepository.lookups | Employees page / editor lookups | employees/employee_lookups*.json | employee_fixture_test, live_employee_test | WIRED |
| Employees | List employees | GET `{{baseUrl}}/api/employees?page=1&pageSize=25&sort=nameAsc` | hr.employees.view | RemoteLiveEmployeeRepository.list | /app/hr/employees list + search/status filter | employees/employees_list*.json | employee_fixture_test, live_employee_test | WIRED |
| Employees | Get employee by id | GET `{{baseUrl}}/api/employees/{{employeeId}}` | hr.employees.view | RemoteLiveEmployeeRepository.getById | Employees row -> detail | employees/employee_detail.json | employee_fixture_test, live_employee_test | WIRED |
| Employees | Create employee (WRITES DATA) | POST `{{baseUrl}}/api/employees` | hr.employees.create | RemoteLiveEmployeeRepository.create | Employees -> Add employee -> Save | employees/employee_created.json | employee_created_fixture_test, live_employee_test, employee_test | WIRED |
| Employees | Update employee (WRITES DATA) | PUT `{{baseUrl}}/api/employees/{{employeeId}}` | hr.employees.edit | RemoteLiveEmployeeRepository.update | Employees -> Edit -> Save | employees/employee_detail.json | employee_fixture_test, live_employee_test | WIRED |
| Employees | Deactivate employee (WRITES DATA) | POST `{{baseUrl}}/api/employees/{{employeeId}}/deactivate` | hr.employees.deactivate | RemoteLiveEmployeeRepository.setActive(false) | Employees row menu -> Deactivate | employees/employee_detail.json | employee_test, live_employee_test | WIRED |
| Employees | Activate employee (WRITES DATA) | POST `{{baseUrl}}/api/employees/{{employeeId}}/activate` | hr.employees.deactivate | RemoteLiveEmployeeRepository.setActive(true) | Employees row menu -> Activate | employees/employee_detail.json | employee_test, live_employee_test | WIRED |
| Employees | Create - validation error (no write) | POST `{{baseUrl}}/api/employees` | hr.employees.create | RemoteLiveEmployeeRepository.create | Employees -> Add employee -> Save | employees/employee_created.json | employee_created_fixture_test, live_employee_test, employee_test | WIRED |
| Employees | Get employee - not found | GET `{{baseUrl}}/api/employees/999999` | hr.employees.view | RemoteLiveEmployeeRepository.getById | Employees detail 404 | employees/employee_not_found.json | employee_fixture_test | WIRED |
| Employees | List - without token (401) | GET `{{baseUrl}}/api/employees` | -> (authenticated) | ApiClient auth guard | Any protected screen; session ends on 401 | none | api_auth_foundation_test | WIRED |
| Branches (Company) | Lookups (divisions, statuses, yes/no) | GET `{{baseUrl}}/api/branches/lookups` | company.branches.view | RemoteBranchRepository.lookups | Branches form lookups | branches/branch_lookups.json | branch_fixture_test, branch_test | WIRED |
| Branches (Company) | List companies | GET `{{baseUrl}}/api/branches?page=1&pageSize=25&sort=nameAsc` | company.branches.view | RemoteBranchRepository.list | /app/settings/branches | branches/branches_list*.json | branch_fixture_test, branch_test | WIRED |
| Branches (Company) | Get company by id | GET `{{baseUrl}}/api/branches/{{branchId}}` | company.branches.view | RemoteBranchRepository.getById | Branches row -> detail | branches/branch_detail.json | branch_fixture_test, branch_test | WIRED |
| Branches (Company) | Create company (WRITES DATA) | POST `{{baseUrl}}/api/branches` | company.branches.manage | RemoteBranchRepository.create | Branches -> Add -> Save | branches/branches_list.json | branch_test | WIRED |
| Branches (Company) | Update company (WRITES DATA) | PUT `{{baseUrl}}/api/branches/{{branchId}}` | company.branches.manage | RemoteBranchRepository.update | Branches -> Edit -> Save | branches/branch_detail.json | branch_test | WIRED |
| Branches (Company) | Deactivate company (WRITES DATA) | POST `{{baseUrl}}/api/branches/{{branchId}}/deactivate` | company.branches.manage | RemoteBranchRepository.setActive(false) | Branches action -> Deactivate | branches/branch_detail.json | branch_test | WIRED |
| Branches (Company) | Activate company (WRITES DATA) | POST `{{baseUrl}}/api/branches/{{branchId}}/activate` | company.branches.manage | RemoteBranchRepository.setActive(true) | Branches action -> Activate | branches/branch_detail.json | branch_test | WIRED |
| Branches (Company) | Create - duplicate name (no write) | POST `{{baseUrl}}/api/branches` | company.branches.manage | RemoteBranchRepository.create | Branches -> Add -> Save | branches/branches_list.json | branch_test | WIRED |
| Departments | List departments | GET `{{baseUrl}}/api/departments?page=1&pageSize=25&sort=nameAsc` | hr.departments.view | RemoteDepartmentRepository.watchList | /app/hr/settings/departments | departments/departments_list*.json | department_fixture_test, department_bloc_test | WIRED |
| Departments | Get department by id | GET `{{baseUrl}}/api/departments/{{departmentId}}` | hr.departments.view | RemoteDepartmentRepository.getById/watchDetails | Department row -> detail | departments/department_detail.json | department_fixture_test, department_repository_test | WIRED |
| Departments | Create department (WRITES DATA) | POST `{{baseUrl}}/api/departments` | hr.departments.manage | RemoteDepartmentRepository.save | Departments -> Add -> Save | departments/departments_list.json | department_repository_test, department_dto_test | WIRED |
| Departments | Rename department (WRITES DATA) | PUT `{{baseUrl}}/api/departments/{{departmentId}}` | hr.departments.manage | RemoteDepartmentRepository.save(id) | Department -> Edit -> Save | departments/department_detail.json | department_repository_test | WIRED |
| Departments | Delete (deactivate) department (WRITES DATA) | POST `{{baseUrl}}/api/departments/{{departmentId}}/deactivate` | hr.departments.manage | RemoteDepartmentRepository.setActive(false) | Department action -> Deactivate | departments/department_detail.json | department_repository_test | WIRED |
| Departments | Create - duplicate name (no write) | POST `{{baseUrl}}/api/departments` | hr.departments.manage | RemoteDepartmentRepository.save | Departments -> Add -> Save | departments/departments_list.json | department_repository_test, department_dto_test | WIRED |
| Shifts | List shifts | GET `{{baseUrl}}/api/shifts?page=1&pageSize=25&sort=startTime` | hr.attendance.shifts.view | RemoteShiftRepository.watchList | /app/hr/settings/shifts | shifts/shifts_list*, shift_options | shift_fixture_test, shift_remote_repository_test | WIRED |
| Shifts | Create shift - Morning 09:00-12:00 (WRITES DATA) | POST `{{baseUrl}}/api/shifts` | hr.attendance.shifts.manage | RemoteShiftRepository.save | Shifts -> Add -> Save | shifts/shifts_list.json | shift_remote_repository_test, shift_dto_test | WIRED |
| Shifts | Create shift - Evening 14:00-19:00 (WRITES DATA) | POST `{{baseUrl}}/api/shifts` | hr.attendance.shifts.manage | RemoteShiftRepository.save | Shifts -> Add -> Save | shifts/shifts_list.json | shift_remote_repository_test, shift_dto_test | WIRED |
| Shifts | Get shift by id | GET `{{baseUrl}}/api/shifts/{{shiftId}}` | hr.attendance.shifts.view | RemoteShiftRepository.getById | Shift row -> detail | shifts/shift_detail.json | shift_fixture_test, shift_remote_repository_test | WIRED |
| Shifts | Update shift (WRITES DATA) | PUT `{{baseUrl}}/api/shifts/{{shiftId}}` | hr.attendance.shifts.manage | RemoteShiftRepository.save(id) | Shift -> Edit -> Save | shifts/shift_detail.json | shift_remote_repository_test, shift_remote_datasource_test | WIRED |
| Shifts | Create - duplicate name (no write) | POST `{{baseUrl}}/api/shifts` | hr.attendance.shifts.manage | RemoteShiftRepository.save | Shifts -> Add -> Save | shifts/shifts_list.json | shift_remote_repository_test, shift_dto_test | WIRED |
| Shifts | Create shift - Night 19:00-02:00 (WRITES DATA) | POST `{{baseUrl}}/api/shifts` | hr.attendance.shifts.manage | RemoteShiftRepository.save | Shifts -> Add -> Save | shifts/shifts_list.json | shift_remote_repository_test, shift_dto_test | WIRED |
| Shifts | Create - same start and end rejected (no write) | POST `{{baseUrl}}/api/shifts` | hr.attendance.shifts.manage | RemoteShiftRepository.save | Shifts -> Add -> Save | shifts/shifts_list.json | shift_remote_repository_test, shift_dto_test | WIRED |
| Shifts | Deactivate shift in use - 409 (no write) | POST `{{baseUrl}}/api/shifts/{{shiftId}}/deactivate` | hr.attendance.shifts.manage | RemoteShiftRepository.setActive(false) | Shift action -> Deactivate | shifts/shift_detail.json | shift_remote_repository_test | WIRED |
| Employee Shifts | Assign Morning (WRITES DATA) | POST `{{baseUrl}}/api/employee-shifts` | hr.attendance.shifts.manage | EmployeeShiftApi.create | Employee Shifts -> Add assignment -> Save | employee_shifts/employee_shifts_list.json | employee_shift_fixture_test, employee_shift_test | WIRED |
| Employee Shifts | Assign Evening (WRITES DATA) | POST `{{baseUrl}}/api/employee-shifts` | hr.attendance.shifts.manage | EmployeeShiftApi.create | Employee Shifts -> Add assignment -> Save | employee_shifts/employee_shifts_list.json | employee_shift_fixture_test, employee_shift_test | WIRED |
| Employee Shifts | Assign Morning again - overlap 409 (no write) | POST `{{baseUrl}}/api/employee-shifts` | hr.attendance.shifts.manage | EmployeeShiftApi.create | Employee Shifts -> Add assignment -> Save | employee_shifts/employee_shifts_list.json | employee_shift_fixture_test, employee_shift_test | WIRED |
| Employee Shifts | List assignments of the employee | GET `{{baseUrl}}/api/employee-shifts?employeeId={{shiftEmployeeId}}&fromDate={{shiftFromDate}}&toDate={{shiftToDate}}` | hr.attendance.shifts.view | EmployeeShiftApi.list | /app/hr/employee-shifts | employee_shifts/employee_shifts_list*.json | employee_shift_fixture_test, employee_shift_test | WIRED |
| Employee Shifts | Change dates (WRITES DATA) | PUT `{{baseUrl}}/api/employee-shifts/{{employeeShiftId}}` | hr.attendance.shifts.manage | EmployeeShiftApi.update | Assignment -> Edit -> Save | employee_shifts/employee_shift_detail.json | employee_shift_fixture_test, employee_shift_test | WIRED |
| Employee Shifts | Assign - toDate before fromDate (no write) | POST `{{baseUrl}}/api/employee-shifts` | hr.attendance.shifts.manage | EmployeeShiftApi.create | Employee Shifts -> Add assignment -> Save | employee_shifts/employee_shifts_list.json | employee_shift_fixture_test, employee_shift_test | WIRED |
| Employee Shifts | Remove assignment (WRITES DATA) | POST `{{baseUrl}}/api/employee-shifts/{{employeeShiftId}}/deactivate` | hr.attendance.shifts.manage | EmployeeShiftApi.deactivate | Assignment action -> Remove | employee_shifts/employee_shift_detail.json | employee_shift_test | WIRED |
| Attendance | Today | GET `{{baseUrl}}/api/attendance/today` | hr.attendance.self.view | AttendanceApi.today | /app/hr/attendance-today | attendance/today_*.json | attendance_fixture_test, live_attendance_test | WIRED |
| Attendance | Punch in (WRITES DATA) | POST `{{baseUrl}}/api/attendance/punch` | hr.attendance.self.punch | AttendanceCubit.punch -> AttendanceApi.punch | Attendance Today -> Punch in/Break/Resume/Punch out | attendance/today_employee.json, attendance/*error*.json | attendance_fixture_test, attendance_experience_test, live_attendance_test | WIRED |
| Attendance | Break (WRITES DATA) | POST `{{baseUrl}}/api/attendance/punch` | hr.attendance.self.punch | AttendanceCubit.punch -> AttendanceApi.punch | Attendance Today -> Punch in/Break/Resume/Punch out | attendance/today_employee.json, attendance/*error*.json | attendance_fixture_test, attendance_experience_test, live_attendance_test | WIRED |
| Attendance | Resume (WRITES DATA) | POST `{{baseUrl}}/api/attendance/punch` | hr.attendance.self.punch | AttendanceCubit.punch -> AttendanceApi.punch | Attendance Today -> Punch in/Break/Resume/Punch out | attendance/today_employee.json, attendance/*error*.json | attendance_fixture_test, attendance_experience_test, live_attendance_test | WIRED |
| Attendance | Punch out (WRITES DATA) | POST `{{baseUrl}}/api/attendance/punch` | hr.attendance.self.punch | AttendanceCubit.punch -> AttendanceApi.punch | Attendance Today -> Punch in/Break/Resume/Punch out | attendance/today_employee.json, attendance/*error*.json | attendance_fixture_test, attendance_experience_test, live_attendance_test | WIRED |
| Attendance | Punch in outside window / no shift - 409 (no write) | POST `{{baseUrl}}/api/attendance/punch` | hr.attendance.self.punch | AttendanceCubit.punch -> AttendanceApi.punch | Attendance Today -> Punch in/Break/Resume/Punch out | attendance/today_employee.json, attendance/*error*.json | attendance_fixture_test, attendance_experience_test, live_attendance_test | WIRED |
| Attendance | Punch - missing action (no write) | POST `{{baseUrl}}/api/attendance/punch` | hr.attendance.self.punch | AttendanceCubit.punch -> AttendanceApi.punch | Attendance Today -> Punch in/Break/Resume/Punch out | attendance/today_employee.json, attendance/*error*.json | attendance_fixture_test, attendance_experience_test, live_attendance_test | WIRED |
| Attendance | Punch - invalid location (no write) | POST `{{baseUrl}}/api/attendance/punch` | hr.attendance.self.punch | AttendanceCubit.punch -> AttendanceApi.punch | Attendance Today -> Punch in/Break/Resume/Punch out | attendance/today_employee.json, attendance/*error*.json | attendance_fixture_test, attendance_experience_test, live_attendance_test | WIRED |
| Attendance | Today - without token (401) | GET `{{baseUrl}}/api/attendance/today` | hr.attendance.self.view | AttendanceApi.today | /app/hr/attendance-today | attendance/today_*.json | attendance_fixture_test, live_attendance_test | WIRED |
| Permissions | List permissions | GET `{{baseUrl}}/api/permissions?page=1&pageSize=100&sort=keyAsc` | company.access.users.view | RemotePermissionMasterRepository.list | Access -> Permission catalog | permissions/permissions_list*.json | permission_fixture_test, permission_master_repository_test | WIRED |
| Permissions | Create test permission (WRITES DATA) | POST `{{baseUrl}}/api/permissions` | company.access.permissions.manage | RemotePermissionMasterRepository.create | Permission catalog -> New permission -> Save | permissions/permission_detail.json | permission_master_repository_test | WIRED |
| Permissions | Create - duplicate key, other case (no write) | POST `{{baseUrl}}/api/permissions` | company.access.permissions.manage | RemotePermissionMasterRepository.create | Permission catalog -> New permission -> Save | permissions/permission_detail.json | permission_master_repository_test | WIRED |
| Permissions | Create - key longer than 100 characters (no write) | POST `{{baseUrl}}/api/permissions` | company.access.permissions.manage | RemotePermissionMasterRepository.create | Permission catalog -> New permission -> Save | permissions/permission_detail.json | permission_master_repository_test | WIRED |
| Permissions | Create - missing key (no write) | POST `{{baseUrl}}/api/permissions` | company.access.permissions.manage | RemotePermissionMasterRepository.create | Permission catalog -> New permission -> Save | permissions/permission_detail.json | permission_master_repository_test | WIRED |
| Permissions | Get permission by id | GET `{{baseUrl}}/api/permissions/{{permissionId}}` | company.access.users.view | RemotePermissionMasterRepository.getById | Permission catalog -> Edit (fresh GET before editor) | permissions/permission_detail*.json | permission_master_repository_test | WIRED |
| Permissions | Get permission - not found | GET `{{baseUrl}}/api/permissions/999999` | company.access.users.view | RemotePermissionMasterRepository.getById | Permission catalog -> Edit -> "no longer exists" + refresh | permissions/permission_not_found.json | permission_master_repository_test | WIRED |
| Permissions | Update permission - name / description (WRITES DATA) | PUT `{{baseUrl}}/api/permissions/{{permissionId}}` | company.access.permissions.manage | RemotePermissionMasterRepository.update | Permission catalog -> Edit -> Save | permissions/permission_detail*.json | permission_master_repository_test | WIRED |
| Permissions | Update - correct the key (WRITES DATA) | PUT `{{baseUrl}}/api/permissions/{{permissionId}}` | company.access.permissions.manage | RemotePermissionMasterRepository.update | Permission catalog -> Edit -> Save | permissions/permission_detail*.json | permission_master_repository_test | WIRED |
| Permissions | Update - key back (WRITES DATA) | PUT `{{baseUrl}}/api/permissions/{{permissionId}}` | company.access.permissions.manage | RemotePermissionMasterRepository.update | Permission catalog -> Edit -> Save | permissions/permission_detail*.json | permission_master_repository_test | WIRED |
| Permissions | Update - key used by another permission (no write) | PUT `{{baseUrl}}/api/permissions/{{permissionId}}` | company.access.permissions.manage | RemotePermissionMasterRepository.update | Permission catalog -> Edit -> Save | permissions/permission_detail*.json | permission_master_repository_test | WIRED |
| Permissions | Update - rename a key the API checks (no write) | PUT `{{baseUrl}}/api/permissions/{{viewPermissionId}}` | company.access.permissions.manage | RemotePermissionMasterRepository.update | Permission catalog -> Edit -> Save | permissions/permission_detail*.json | permission_master_repository_test | WIRED |
| Permissions | Deactivate test permission (WRITES DATA) | POST `{{baseUrl}}/api/permissions/{{permissionId}}/deactivate` | company.access.permissions.manage | RemotePermissionMasterRepository.setActive(false) | Permission catalog -> Deactivate | permissions/permission_detail.json | permission_master_repository_test | WIRED |
| Permissions | Activate test permission (WRITES DATA) | POST `{{baseUrl}}/api/permissions/{{permissionId}}/activate` | company.access.permissions.manage | RemotePermissionMasterRepository.setActive(true) | Permission catalog -> Activate | permissions/permission_detail.json | permission_master_repository_test | WIRED |
| Permissions | List - without token (401) | GET `{{baseUrl}}/api/permissions` | company.access.users.view | RemotePermissionMasterRepository.list | Access -> Permission catalog | permissions/permissions_list*.json | permission_fixture_test, permission_master_repository_test | WIRED |
| User Permissions | Assign permission to the login (WRITES DATA) | POST `{{baseUrl}}/api/user-permissions` | company.access.permissions.manage | RemoteAccessRepository.assignGrants | Access -> Manage user -> Add permissions | permissions/user_permissions_assign.json | remote_access_repository_test, permission_fixture_test | WIRED |
| User Permissions | Assign again - already assigned is kept (no write) | POST `{{baseUrl}}/api/user-permissions` | company.access.permissions.manage | RemoteAccessRepository.assignGrants | Access -> Add permissions (idempotent) | permissions/user_permissions_assign.json | remote_access_repository_test | WIRED |
| User Permissions | Assign - unknown permission (no write) | POST `{{baseUrl}}/api/user-permissions` | company.access.permissions.manage | RemoteAccessRepository.assignGrants (_resolveGrantIds) | Access -> Add permissions (catalog prevents unknown) | none | remote_access_repository_test | WIRED |
| User Permissions | Assign - empty list (no write) | POST `{{baseUrl}}/api/user-permissions` | company.access.permissions.manage | UserAccessCubit.assignAdditive | Access -> Add permissions (empty selection blocked) | none | access_delegation_test | WIRED |
| User Permissions | Assign - unknown login (no write) | POST `{{baseUrl}}/api/user-permissions` | company.access.permissions.manage | RemoteAccessRepository.assignGrants | Employee detail -> Manage access covers a known userId; unknown login remains backend-only | none | employee_access_entry_test | PARTIAL |
| User Permissions | List permissions of the login | GET `{{baseUrl}}/api/user-permissions?userId={{limitedUserId}}&page=1&pageSize=100` | company.access.users.view | RemoteAccessRepository._loadAllUserPermissions | Access users list / user editor | permissions/user_permissions_*.json | remote_access_repository_test, permission_fixture_test | WIRED |
| User Permissions | List permissions of the employee's login | GET `{{baseUrl}}/api/user-permissions?employeeId={{limitedEmployeeId}}&page=1&pageSize=100` | company.access.users.view | AccessAdminRemoteDataSource.userPermissions(employeeId:) | No employee filter in Access UI | permissions/user_permissions_*.json | permission_fixture_test | PARTIAL |
| User Permissions | List logins having the permission | GET `{{baseUrl}}/api/user-permissions?permissionId={{permissionId}}&page=1&pageSize=100` | company.access.users.view | AccessAdminRemoteDataSource.userPermissions(permissionId:) | No permission-to-users screen | permissions/user_permissions_*.json | none | PARTIAL |
| User Permissions | Get assignment by id | GET `{{baseUrl}}/api/user-permissions/{{userPermissionId}}` | company.access.users.view | No repository method | No screen | none | none | NOT WIRED |
| User Permissions | Remove assignment (WRITES DATA) | DELETE `{{baseUrl}}/api/user-permissions/{{userPermissionId}}` | company.access.permissions.manage | RemoteAccessRepository.revokeGrant | Access user -> Orphan row -> Revoke | permissions/user_permissions_user8.json | remote_access_repository_test, access_widget_test | WIRED |
| User Permissions | Remove again - not found | DELETE `{{baseUrl}}/api/user-permissions/{{userPermissionId}}` | company.access.permissions.manage | RemoteAccessRepository.revokeGrant | Access user -> Revoke (idempotent success + refresh) | permissions/user_permissions_user8.json | remote_access_repository_test | WIRED |
| User Permissions | List - without token (401) | GET `{{baseUrl}}/api/user-permissions` | -> (authenticated) | ApiClient auth guard | Any protected screen | none | api_auth_foundation_test | WIRED |
| Me | My permissions | GET `{{baseUrl}}/api/me/permissions` | -> (authenticated) | RemoteAuthRepository / AuthBloc permissions reload | Login/bootstrap/admin screens | auth/me_permissions_*.json | auth_permissions_bloc_test, auth_test | WIRED |
| Me | My permissions - without token (401) | GET `{{baseUrl}}/api/me/permissions` | -> (authenticated) | RemoteAuthRepository / AuthBloc permissions reload | Login/bootstrap/admin screens | auth/me_permissions_*.json | auth_permissions_bloc_test, auth_test | WIRED |
| Access check (QA Employee 27) | 1. [Admin] Employee gets ONLY hr.employees.view (WRITES DATA) | PUT `{{baseUrl}}/api/user-permissions/users/{{limitedUserId}}` | company.access.permissions.manage | RemoteAccessRepository.replaceGrants | Postman-only access-check scenario (client replace screen exists) | auth/me_permissions_employee.json, employees/* | none | PARTIAL |
| Access check (QA Employee 27) | 2. Login as the employee | POST `{{baseUrl}}/api/auth/login` | none | RemoteAuthRepository.login | No product screen (manual access-check) | auth/me_permissions_employee.json, employees/* | none | NOT WIRED |
| Access check (QA Employee 27) | 3. My permissions - only hr.employees.view | GET `{{baseUrl}}/api/me/permissions` | none | /api/me/permissions bootstrap | No product screen (manual access-check) | auth/me_permissions_employee.json, employees/* | none | NOT WIRED |
| Access check (QA Employee 27) | 4. List employees - allowed (200) | GET `{{baseUrl}}/api/employees?page=1&pageSize=25&sort=nameAsc` | hr.employees.view | RemoteLiveEmployeeRepository list/detail/lookups | No product screen (manual access-check) | auth/me_permissions_employee.json, employees/* | none | NOT WIRED |
| Access check (QA Employee 27) | 5. Get employee - allowed (200) | GET `{{baseUrl}}/api/employees/{{limitedEmployeeId}}` | hr.employees.view | RemoteLiveEmployeeRepository list/detail/lookups | No product screen (manual access-check) | auth/me_permissions_employee.json, employees/* | none | NOT WIRED |
| Access check (QA Employee 27) | 6. Lookups - allowed (200) | GET `{{baseUrl}}/api/employees/lookups` | hr.employees.view | RemoteLiveEmployeeRepository list/detail/lookups | No product screen (manual access-check) | auth/me_permissions_employee.json, employees/* | none | NOT WIRED |
| Access check (QA Employee 27) | 7. Create employee - refused (403) | POST `{{baseUrl}}/api/employees` | hr.employees.create | RemoteLiveEmployeeRepository.create | No product screen (manual access-check) | auth/me_permissions_employee.json, employees/* | none | NOT WIRED |
| Access check (QA Employee 27) | 8. Update employee - refused (403) | PUT `{{baseUrl}}/api/employees/{{limitedEmployeeId}}` | hr.employees.edit | RemoteLiveEmployeeRepository.update | No product screen (manual access-check) | auth/me_permissions_employee.json, employees/* | none | NOT WIRED |
| Access check (QA Employee 27) | 9. Deactivate employee - refused (403) | POST `{{baseUrl}}/api/employees/{{limitedEmployeeId}}/deactivate` | hr.employees.deactivate | RemoteLiveEmployeeRepository.setActive | No product screen (manual access-check) | auth/me_permissions_employee.json, employees/* | none | NOT WIRED |
| Access check (QA Employee 27) | 10. Branches - refused (403) | GET `{{baseUrl}}/api/branches` | company.branches.view | RemoteBranchRepository.list | No product screen (manual access-check) | auth/me_permissions_employee.json, employees/* | none | NOT WIRED |
| Access check (QA Employee 27) | 11. Attendance today - refused (403, key removed in step 1) | GET `{{baseUrl}}/api/attendance/today` | hr.attendance.self.view | AttendanceApi.today | No product screen (manual access-check) | auth/me_permissions_employee.json, employees/* | none | NOT WIRED |
| Access check (QA Employee 27) | 12. Assign permissions to myself - refused (403) | POST `{{baseUrl}}/api/user-permissions` | company.access.permissions.manage | RemoteAccessRepository.assignGrants | No product screen (manual access-check) | auth/me_permissions_employee.json, employees/* | none | NOT WIRED |
| Access check (QA Employee 27) | 13. [Admin] Give the attendance keys back (WRITES DATA) | PUT `{{baseUrl}}/api/user-permissions/users/{{limitedUserId}}` | company.access.permissions.manage | RemoteAccessRepository.replaceGrants | Postman-only access-check scenario (client replace screen exists) | auth/me_permissions_employee.json, employees/* | none | PARTIAL |

## Gaps and smallest change (not implemented)

| Gap | Impact | Smallest change |
|---|---|---|

| `POST /api/user-permissions` still has no unknown-login UI target. | The Access list derives users from grants; a grantless login is reachable only from its employee detail. | Use Employee detail -> Manage access; add a user directory only if Access must find grantless users directly. |
| `GET /api/user-permissions?employeeId=...` is supported by the data source but the Access screen has no employee picker. | No Access-wide employee lookup; employee detail opens access by `userId` instead. | Reuse the existing method once Access has an employee directory. |
| `GET /api/user-permissions?permissionId=...` has no screen. | No "who has this permission?" view in the permission catalog. | Add a usage drawer on the permission detail screen using the existing data-source filter. |
| `GET /api/user-permissions/{id}` has no repository method. | No direct grant-detail refresh. | Add a data-source method if a grant detail screen is introduced; not needed for the current UI. |

| Postman "Access check (QA Employee 27)" folder is a manual access scenario, not a product flow. | No single in-app flow runs those 13 steps end to end. | Keep it as a Postman/QA scenario; the underlying screens and calls are covered individually. |

## Write-contract risk list

Bodies below are what the client sends. Source means where the shape came from.
"Live-verified" means the shape was exercised successfully against the live
backend in this integration; it does not mean every validation branch was tested.

| Write | Client body | Source | Status |
|---|---|---|---|
| `POST /api/permissions` | `{permissionKey, permissionName, description?}` | Code + audit/Postman | UNVERIFIED |
| `PUT /api/permissions/{id}` | Optional `{permissionKey, permissionName, description}` (omitted fields are not sent) | Code + audit/Postman | UNVERIFIED |
| `POST /api/permissions/{id}/activate` | No body | Postman | UNVERIFIED |
| `POST /api/permissions/{id}/deactivate` | No body | Postman | UNVERIFIED |
| `POST /api/user-permissions` (assign) | `{userId, permissionIds}` | Postman/audit; grant 145 self-assign and employee grants succeeded live | LIVE-VERIFIED |
| `PUT /api/user-permissions/users/{userId}` (replace) | `{permissionIds}` | Postman/audit | UNVERIFIED |
| `DELETE /api/user-permissions/{id}` | No body | Postman | UNVERIFIED |
| `POST /api/branches` | Full branch body: `branchName, branchCode, contactPerson, mobileNo, landLine, address, email, inventoryAlerts, multiInventory, divisionId, status, timeZoneId` | Code + audit/Postman | UNVERIFIED |
| `PUT /api/branches/{id}` | Same full branch body | Code + audit/Postman | UNVERIFIED |
| `POST /api/branches/{id}/activate` | No body | Postman | UNVERIFIED |
| `POST /api/branches/{id}/deactivate` | No body | Postman | UNVERIFIED |
| `POST /api/departments` | `{departmentName}` | Code + audit/Postman | UNVERIFIED |
| `PUT /api/departments/{id}` | `{departmentName}` | Code + audit/Postman | UNVERIFIED |
| `POST /api/departments/{id}/deactivate` | No body | Postman | UNVERIFIED |
| `POST /api/employees` | Full employee body; login only when enabled: `{enabled, loginId, mobileNo, branchIds, password?}`. Never `login.userType`. | Live create + code + live fixture | LIVE-VERIFIED |
| `PUT /api/employees/{id}` | Full loaded employee map + form edits; login copy minus `userType`; no other loaded field dropped. | Code + live detail shape | UNVERIFIED |
| `POST /api/employees/{id}/activate` | No body | Postman | UNVERIFIED |
| `POST /api/employees/{id}/deactivate` | No body | Postman | UNVERIFIED |
| `POST /api/shifts` | `{shiftName, startTime, endTime, earlyPunchInMinutes, lateGraceMinutes}` | Code + audit/Postman | UNVERIFIED |
| `PUT /api/shifts/{id}` | Same five-field body | Code + audit/Postman | UNVERIFIED |
| `POST /api/shifts/{id}/activate` | No body (UI path exists; no Postman request) | Code + audit | UNVERIFIED |
| `POST /api/shifts/{id}/deactivate` | No body | Postman | UNVERIFIED |
| `POST /api/employee-shifts` | `{employeeId, shiftId, fromDate, toDate, timeZoneId?}` | Code + audit/Postman | UNVERIFIED |
| `PUT /api/employee-shifts/{id}` | `{shiftId, fromDate, toDate, timeZoneId?}` (employee omitted) | Code + audit/Postman | UNVERIFIED |
| `POST /api/employee-shifts/{id}/deactivate` | No body | Postman | UNVERIFIED |
| `POST /api/attendance/punch` | `{action, latitude?, longitude?}` with action `punchIn/break/resume/punchOut` | Code + audit/Postman; no live punch was ever sent | UNVERIFIED |

## Remaining demo/local code under `lib/`

| File | Still needed by |
|---|---|
| `modules/hr/attendance/data/attendance_local_data_source.dart` | Reports/attendance history fallback; HR local composition |
| `modules/hr/attendance/data/local_attendance_correction_repository.dart` | Reports/attendance corrections fallback |
| `modules/hr/attendance/data/local_attendance_repository.dart` | Reports and notification/reminder context fallback |
| `modules/hr/attendance_policies/data/attendance_policy_seed.dart` | Attendance Policies (out of scope) |
| `modules/hr/attendance_policies/data/local_attendance_policy_repository.dart` | Attendance Policies |
| `modules/hr/dashboard/data/local_dashboard_repository.dart` | Dashboard has no backend endpoint; local empty summary only |
| `modules/hr/employees/data/local_account_access_guard.dart` | Leave/Reports legacy composition |
| `modules/hr/employees/data/local_employee_repository.dart` | Leave/Reports legacy composition |
| `modules/hr/leave/data/leave_seed.dart` | Leave (out of scope) |
| `modules/hr/leave/data/local_leave_repository.dart` | Leave |
| `modules/hr/reports/data/local_attendance_report_repository.dart` | Reports |
| `modules/hr/shifts/data/local_shift_repository.dart` | Attendance catalog/Employee Shifts local composition |
| `modules/hr/work_locations/data/local_work_location_repository.dart` | Work Locations (out of scope) |
| `modules/hr/work_locations/data/work_location_seed.dart` | Work Locations |
| `modules/services/configuration/data/local_service_master_repository.dart` | Services |
| `modules/services/customers/data/local_service_customer_repository.dart` | Services |
| `modules/services/demo/services_demo_seed.dart` | Services demo only; no live importer |
| `modules/services/enquiries/data/local_service_enquiry_repository.dart` | Services |
| `modules/services/inspections/data/local_service_inspection_repository.dart` | Services |
| `modules/services/job_assignments/data/local_service_job_assignment_repository.dart` | Services |
| `modules/services/material_requests/data/local_service_material_request_repository.dart` | Services |
| `modules/services/overview/data/local_services_dashboard_repository.dart` | Services |
| `modules/services/sites/data/local_service_site_repository.dart` | Services |
| `modules/services/teams/data/local_service_team_repository.dart` | Services |
| `modules/services/workflow/data/local_service_workflow_repository.dart` | Services |
| `modules/services/work_executions/data/local_service_work_execution_repository.dart` | Services |
| `platform/notifications/data/local_notification_repository.dart` | Notifications |
| `platform/notifications/data/local_reminder_context_source.dart` | Notifications/attendance reminders |
| `shared/data/local_configuration_repository.dart` | Attendance Policies, Work Locations, local shift adapter |
| `shared/transactions/data/local_activity_repository.dart` | Services/transaction history |
| `shared/transactions/data/local_attachment_repository.dart` | Services/transaction attachments |
| `shared/transactions/data/local_document_number_service.dart` | Services/transaction numbering |

`core/utils/local_time.dart` and all `*localization.dart` files are not demo/local
data code and are excluded from this inventory.
