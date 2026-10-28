import 'dart:async';

/// Central app lifecycle coordinator. Pages must not register their own
/// observers for sync/reminder reconciliation; this is the single entry point
/// invoked on app resume.
class AppLifecycleCoordinator {
  AppLifecycleCoordinator({
    this.refreshPermissions,
    this.refreshAttendance,
    this.sync,
    this.reconcileReminders,
    this.refreshNotifications,
    this.purgeNotifications,
  });

  /// Re-reads the effective backend access. Backend grants can change while
  /// the app is backgrounded; no timer/polling is used.
  final Future<void> Function()? refreshPermissions;
  final Future<void> Function()? refreshAttendance;
  final Future<void> Function()? sync;
  final Future<void> Function()? reconcileReminders;
  final Future<void> Function()? refreshNotifications;
  final Future<void> Function()? purgeNotifications;

  Future<void>? _running;

  Future<void> onResumed() =>
      _running ??= _run().whenComplete(() => _running = null);

  Future<void> _run() async {
    await _safe(refreshPermissions);
    await _safe(refreshAttendance);
    await _safe(sync);
    await _safe(reconcileReminders);
    await _safe(refreshNotifications);
    await _safe(purgeNotifications);
  }

  /// Pausing persists nothing: attendance truth is already stored and the
  /// ticker is stopped by the attendance scope.
  Future<void> onPaused() async {}

  Future<void> _safe(Future<void> Function()? action) async {
    if (action == null) return;
    try {
      await action();
    } catch (_) {
      // Lifecycle reconciliation must never crash the app.
    }
  }
}
