import 'package:get_it/get_it.dart';

/// Services dependency registration boundary.
///
/// Intentionally minimal in Phase 0 — no fake repositories. Services Phase 1+
/// registers its own repositories/services here so the core bootstrap stays
/// free of Services internals.
class ServicesModuleDependencies {
  const ServicesModuleDependencies();
}

void configureServicesDependencies(GetIt services) {
  // Registered by Services implementation phases.
}
