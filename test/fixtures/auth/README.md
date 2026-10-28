# Auth fixtures

**Source: audit fallback, not a live capture.** On re-check the configured live
base URL is reachable and returns JSON (`GET /api/me/permissions` -> `401`,
`GET /openapi/v1.json` -> `200`) once `ngrok-skip-browser-warning: true` is sent.
No login credentials were present in `.env.local` or the OS environment, so a
successful login/refresh/`me` capture could not be performed without inventing
data. These fixtures therefore remain the audit fallback; replace them once a
sanitized live capture is possible.

These files mirror the sanitized contract in
`audit-output/massep-2026-10-28/04-response-contract-audit.md` and the Postman
folder `Authentication`:

- Success envelope: `{ success, message, data, errors: [] }`.
- Login/refresh `data` is the same shape, including rotated token pair and the
  nested `user`/`branches[]` block.
- `GET /api/me/permissions` is `{ userId:int, employeeId:int?,
  permissions:string[] }` and is the only authoritative grant source.
- Tokens and personal identifiers are replaced with `SANITIZED_*` values and
  generic names; addresses, phones and real passwords are absent.
- `me_permissions_unknown.json` is a deliberate edge fixture proving unknown
  keys fail closed.
- Error fixtures use the live error envelope with `errors[].code`/`field`.

## Observed contract notes

- Login/refresh return identity only. They do **not** return permissions or
  module entitlements.
- The audit's live admin held 14 keys but not `hr.employees.view`; the
  composition table in `lib/core/security/access_tree.dart` remains the source
  of truth for supported keys.
- `loginId` is not an email. It now maps to `UserAccount.loginId`; backend
  sessions leave `UserAccount.email` null.
- `branches[]` is mapped read-only into `AuthContext.branches` as
  `CompanyBranch(id, name)` and survives session serialization.
- Enabled modules are derived client-side from effective permissions because the
  backend has no module endpoint.
