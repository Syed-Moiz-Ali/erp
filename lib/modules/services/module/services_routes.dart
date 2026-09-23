/// Canonical Services module routes.
///
/// Only the module root is reserved for now. Feature routes (enquiries, jobs,
/// inspections, material requests, work executions, reports, settings) are
/// added by Services Phase 1+ and must follow `/app/services/...`.
abstract final class ServicesRoutes {
  static const root = '/app/services';
}
