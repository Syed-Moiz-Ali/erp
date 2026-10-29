# API integration docs (historical + reference)

These documents were written during the earlier integration attempts
(2026-10-09 to 2026-10-29). They remain useful as contract references, but they
are **not** a description of the v3 baseline.

For API v3:

* UI/UX baseline is `ac2ec6f` (tip of `services_module`) and is frozen.
* Only the approved Departments and Shifts presentation changes may differ.
* Demo/local code, seeds and Drift tables remain until a separate,
  module-by-module removal phase.
* Endpoint coverage, backend hand-off findings and client decisions are the
  authoritative parts of these documents; ignore statements about removed demo
  paths, a live-only runtime or the `5df51cf` UI.

Files:

| File | Use in v3 |
|---|---|
| `PHASE_0_AUDIT.md` | Contract and gap analysis against `ac2ec6f`; still valid |
| `PHASE_1_IMPLEMENTATION.md` | Core transport/auth implementation notes |
| `PHASE_2_IMPLEMENTATION.md` | Auth/session implementation notes |
| `PHASE_3_IMPLEMENTATION.md` | Departments implementation notes |
| `PHASE_3_5_PRESENTATION_WIRING.md` | Historical; describes wiring into the 5df51cf UI |
| `PHASE_3_6_ENVIRONMENT.md` | Environment/ngrok rules; still valid |
| `MODULE_SHIFTS.md` | Shift backend contract and test notes |
| `../backend-handoff.md` | Backend actions required by the client |
| `../client-decisions.md` | Client assumptions (see v3 applicability note) |
| `../postman-coverage.md` | Endpoint coverage matrix |
| `../manual-test-checklist.md` | Historical manual checks |
| `../ui-regression-report.md` | Historical audit of the 5df51cf UI regression |
