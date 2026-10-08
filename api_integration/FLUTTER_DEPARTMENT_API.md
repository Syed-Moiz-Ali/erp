# MassERP API — Departments (for the Flutter developer)

Base URL (development): `http://<server-ip>:5257` · Swagger: `http://<server-ip>:5257/swagger`

```http
Authorization: Bearer {accessToken}
Content-Type: application/json        (for POST / PUT)
```

Access = the user's ERP privileges on the **HRMS Masters** screen (same as employees):
view → read, save → create, edit → rename / delete. Missing privilege → **403 `ACCESS_DENIED`**.

## Endpoints

| Method | URL | Purpose | Success |
|---|---|---|---|
| GET | `/api/departments?page=1&pageSize=25&search=&sort=nameAsc` | Paged list of **active** departments | 200 |
| GET | `/api/departments/{departmentId}` | One department | 200 |
| POST | `/api/departments` | Create | **201** |
| PUT | `/api/departments/{departmentId}` | Rename | 200 |
| POST | `/api/departments/{departmentId}/deactivate` | Delete (soft; cannot be undone from the app) | 200 |

`sort` = `nameAsc` (default) | `nameDesc` | `newest`.

### Body (create / rename)

```json
{ "departmentName": "Accounts" }
```

`departmentName`: required, max **50** characters, unique among active departments (case-insensitive).

### Response

```json
{
  "success": true,
  "message": "Departments retrieved.",
  "data": {
    "items": [ { "departmentId": 2, "departmentName": "accounts", "employeeCount": 1 } ],
    "page": 1, "pageSize": 25, "totalItems": 3, "totalPages": 1
  },
  "errors": []
}
```

`employeeCount` = employees assigned to the department. **Disable "Delete" when it is greater than 0** — the API refuses it.

## Errors

| HTTP | `errors[].code` | App action |
|---|---|---|
| 400 | `VALIDATION_ERROR` (field `departmentName`) | Show under the field |
| 401 | `AUTH_UNAUTHORIZED` / `AUTH_TOKEN_EXPIRED` | Log in again |
| 403 | `ACCESS_DENIED` | Hide/disable the action |
| 404 | `DEPARTMENT_NOT_FOUND` | Department does not exist or was deleted |
| 409 | `DEPARTMENT_DUPLICATE_NAME` (field `departmentName`) | Show under the field |
| 409 | `DEPARTMENT_IN_USE` | Department has employees — move them first |
| 503 / 500 | `SERVICE_UNAVAILABLE` / `SERVER_ERROR` | Show retry |
