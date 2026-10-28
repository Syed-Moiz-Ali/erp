import 'dart:async';

/// Cross-layer signal that a protected request was denied by the backend
/// authorization layer (`403 ACCESS_DENIED`).
///
/// The authentication layer subscribes and reloads the effective permission
/// set so navigation, routes and actions converge on the server truth without
/// waiting for a re-login.
class AccessEndpoint {
  final _controller = StreamController<String>.broadcast();

  /// Emits the backend error code (normally `ACCESS_DENIED`).
  Stream<String> get onPermissionDenied => _controller.stream;

  void notify(String code) {
    if (!_controller.isClosed) _controller.add(code);
  }

  Future<void> dispose() => _controller.close();
}
