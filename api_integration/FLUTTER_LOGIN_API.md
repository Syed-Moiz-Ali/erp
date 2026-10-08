# MassERP API — Login (for the Flutter developer)

The app talks **only** to this API. Base URL (development): `http://<server-ip>:5257` — you'll be given the address.
Swagger (development): `http://<server-ip>:5257/swagger`

---

## Endpoint

```http
POST /api/auth/login
```

### Headers

```http
Content-Type: application/json
X-Client-Platform: android        # optional: android | ios | web
```

### Request

```json
{
  "loginId": "your-login-id",
  "password": "your-password"
}
```

| Field | Type | Rules |
|---|---|---|
| `loginId` | string | required, not blank, max 100 |
| `password` | string | required, not blank, max 100 |

No branch/company selection is needed — the server picks the user's branch and returns it.

### Success — `200 OK`

```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "tokenType": "Bearer",
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 3600,
    "accessTokenExpiresAtUtc": "2026-09-24T15:00:00Z",
    "refreshToken": "q3V0...",
    "refreshTokenExpiresAtUtc": "2026-10-24T14:00:00Z",
    "user": {
      "userId": 1,
      "loginId": "Admin",
      "name": "Administrator",
      "userType": "Director",
      "empId": null,
      "orgId": 1,
      "branchName": "Head Office",
      "timeZone": "Asia/Dubai",
      "orgCount": 1,
      "transactionAccess": true,
      "reportAccess": true,
      "branches": [ { "orgId": 1, "branchName": "Head Office" } ]
    }
  },
  "errors": []
}
```

| `user` field | Meaning |
|---|---|
| `userId` | User ID (int) |
| `loginId`, `name` | Login name and display name |
| `userType` | ERP user type, e.g. `Director`, `Accounts`, `Sales`, `HR` (display only for now) |
| `empId` | Linked employee ID, or `null` if the user isn't an employee — HR self-service screens will need this |
| `orgId`, `branchName` | Branch used for this session |
| `timeZone` | IANA time zone of that branch (e.g. `Asia/Dubai`; new 2026-10-02); `null` when the branch has none. Times from the API carry their offset, so this is only needed to label the zone |
| `branches` | Branches the user can access — **use this list** |
| `orgCount` | Legacy ERP count; can be higher than `branches.length` because of old data — don't rely on it |
| `transactionAccess`, `reportAccess` | ERP access flags |

### Errors

Every error has the same shape. **Use `errors[0].code` in app logic, and show `message` to the user.**

```json
{
  "success": false,
  "message": "Invalid login ID or password.",
  "data": null,
  "errors": [ { "code": "AUTH_INVALID_CREDENTIALS", "message": "Invalid login ID or password." } ]
}
```

| HTTP | `code` | What the app should do |
|---|---|---|
| 400 | `VALIDATION_ERROR` | Highlight the field named in `errors[].field` (`loginId` / `password`) |
| 401 | `AUTH_INVALID_CREDENTIALS` | Show "Invalid login ID or password" |
| 401 | `AUTH_ACCOUNT_INACTIVE` | Show "Account inactive, contact administrator" |
| 429 | `AUTH_RATE_LIMITED` | Too many attempts — ask the user to wait a minute |
| 503 | `SERVICE_UNAVAILABLE` | Server/database down — show a retry option |
| 500 | `SERVER_ERROR` | Unexpected error — show a generic message and a retry option |

---

## Using the tokens

Send the access token on every protected request (future endpoints):

```http
Authorization: Bearer {accessToken}
```

* **Access token lifetime:** 60 minutes (`expiresIn` = seconds). Don't parse the JWT for business data — use the `user` object.
* **Refresh token:** valid for **30 days from its last use** (sliding): an app that is opened at least once a month stays
  logged in. **Every refresh returns a NEW refresh token — always store the newest one**; the one you sent is used up.
* **Storage:** keep both tokens in secure storage (`flutter_secure_storage`), never in plain shared preferences or logs.
* A 401 on a protected call has `errors[0].code`: `AUTH_TOKEN_EXPIRED` (refresh, then retry) or `AUTH_UNAUTHORIZED`
  (no / invalid token — go to login).

---

## Refresh (new 2026-10-07)

```http
POST /api/auth/refresh
Content-Type: application/json
X-Client-Platform: android        # optional

{ "refreshToken": "q3V0..." }
```

No `Authorization` header is needed (the access token may already have expired).

**Success — `200 OK`:** exactly the **login response** (same `data` shape: new `accessToken`, new `refreshToken`, both
expiry times and the current `user` — branch, `empId`, `timeZone` are re-read, so they may have changed). Message
`"Token refreshed."` Reuse the login parser and **replace both stored tokens**.

| HTTP | `code` | What the app should do |
|---|---|---|
| 401 | `AUTH_REFRESH_INVALID` | Session no longer valid (logged out, unknown token, user removed) → clear tokens, login screen |
| 401 | `AUTH_REFRESH_EXPIRED` | 30 days without use → clear tokens, login screen |
| 401 | `AUTH_REFRESH_REUSED` | An old refresh token was used again (possible copy) — this device's session was ended → clear tokens, login screen |
| 401 | `AUTH_ACCOUNT_INACTIVE` | Account deactivated → clear tokens, login screen with "contact administrator" |
| 400 | `VALIDATION_ERROR` | `refreshToken` missing — app bug |
| 429 | `AUTH_RATE_LIMITED` | Wait a minute, then retry |
| 503 | `SERVICE_UNAVAILABLE` | Server / database down — **keep the tokens**, retry later |

**Rule of thumb: any 401 from `/refresh` = go to the login screen. 503 / network error = keep the tokens and retry.**

### How the app must refresh (important)

1. **Only one refresh at a time.** When several calls get `401 AUTH_TOKEN_EXPIRED` together, send **one** refresh; the
   other calls wait for it and then retry with the new access token (e.g. a lock / shared `Future` in the Dio interceptor).
2. **Refresh early:** when `accessTokenExpiresAtUtc` is less than about 1 minute away, refresh before the call.
3. **Retry the original call once** after a successful refresh. If it fails with 401 again, go to the login screen.
4. **Save the new tokens before using them**, so an app kill right after the refresh does not lose them.

The server tolerates the common accidents for **30 seconds** after a refresh (two parallel refreshes, or a retry after
the response was lost on a bad network): the old token still works once more in that window. After that, using an old
refresh token ends that device's session (`AUTH_REFRESH_REUSED`).

---

## Logout (new 2026-10-07)

```http
POST /api/auth/logout
Content-Type: application/json

{ "refreshToken": "q3V0..." }
```

* Ends **this device's** session: its refresh token (and every token rotated from it) stops working. Other devices of
  the same user stay logged in.
* Always `200 OK` (`"Logged out."`, `data: null`), also for an unknown or already logged-out token.
* **Delete both tokens locally whatever the result** (also on 503 / no network) and show the login screen.
* The access token is not revoked by the server; it simply expires (at most 60 minutes). Never use it after logout.

**Deactivated employees:** when HR deactivates an employee or switches off their login, every device's session is ended
on the server; the app gets `AUTH_ACCOUNT_INACTIVE` / `AUTH_REFRESH_INVALID` at the next refresh (within 60 minutes).

**Rate limit:** login 20 / minute, refresh + logout 60 / minute per IP → `429 AUTH_RATE_LIMITED`, message
"Too many attempts. Please try again in a minute." (wording changed 2026-10-07; branch on the code, not the text).
