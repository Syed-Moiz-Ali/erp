import 'dart:async';

/// Cross-layer signal that a protected request received a definitively
/// session-ending authentication response (unauthorized / refresh rejected /
/// account inactive). The authentication layer subscribes and invalidates the
/// session; core networking stays free of any auth-feature dependency.
class SessionEndpoint {
  final _controller = StreamController<String>.broadcast();

  /// Emits the backend error code that ended the session.
  Stream<String> get onSessionEnding => _controller.stream;

  void notify(String code) {
    if (!_controller.isClosed) _controller.add(code);
  }

  Future<void> dispose() => _controller.close();
}
