import 'token_refresher.dart';

/// Ensures only one token refresh runs at a time, however many requests get a
/// `401 AUTH_TOKEN_EXPIRED` together. Concurrent callers await the same
/// in-flight refresh instead of racing the server's rotation guard.
///
/// The concrete [TokenRefresher] is supplied by the authentication data layer
/// during composition, keeping this coordinator free of feature dependencies.
class TokenRefreshCoordinator {
  TokenRefreshCoordinator({TokenRefresher? refresher}) : _refresher = refresher;

  TokenRefresher? _refresher;
  Future<TokenRefreshOutcome>? _inFlight;

  /// Wires the auth data layer's refresher. Safe to call after construction.
  set refresher(TokenRefresher refresher) => _refresher = refresher;

  bool get canRefresh => _refresher != null;

  /// Runs (or joins) a single refresh. Never throws.
  Future<TokenRefreshOutcome> refresh() {
    final inFlight = _inFlight;
    if (inFlight != null) return inFlight;
    final future = _run();
    _inFlight = future;
    future.whenComplete(() {
      if (identical(_inFlight, future)) _inFlight = null;
    });
    return future;
  }

  Future<TokenRefreshOutcome> _run() async {
    final refresher = _refresher;
    if (refresher == null) return TokenRefreshOutcome.unavailable;
    try {
      return await refresher.refresh();
    } catch (_) {
      return TokenRefreshOutcome.unavailable;
    }
  }
}
