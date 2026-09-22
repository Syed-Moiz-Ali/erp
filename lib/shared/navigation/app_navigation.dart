import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../app/module_registry/module_registry.dart';

/// Central navigation helpers. Feature widgets must not invent their own
/// push/pop/fallback rules.
extension AppNavigation on BuildContext {
  /// Pops when there is history, otherwise replaces the current location with
  /// [fallback]. This keeps Back working when a detail screen was opened
  /// directly from a deep link (no parent in the stack).
  void popOrGo(String fallback) {
    if (canPop()) {
      pop();
    } else {
      go(fallback);
    }
  }
}

/// Canonical module root for a path using the same longest-match resolver as
/// the shell (`/app/attendance/history/ATT-1` → `/app/attendance/history`).
/// Returns null for paths outside the registered modules.
String? moduleRootForPath(String path, ModuleRegistry registry) =>
    registry.ownerOf(path)?.route;
