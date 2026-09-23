import 'package:modular_erp/app/module_registry/module_registry.dart';

/// Services business-module registration boundary.
///
/// Phase 0 deliberately registers no visible destination: the Services module
/// must not appear to users until it has real functionality (Phase 1/2). Future
/// phases add their AppModules here instead of editing the central registry.
List<AppModule> buildServicesModules() => const [];
