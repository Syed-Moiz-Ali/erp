import 'dart:math';

/// Controlled exponential backoff with bounded jitter. The first attempts use
/// short delays, later attempts grow exponentially up to a cap so fleets do
/// not hammer a future backend simultaneously.
class SyncRetryPolicy {
  const SyncRetryPolicy({
    this.baseDelay = const Duration(seconds: 5),
    this.maxDelay = const Duration(minutes: 30),
    this.jitterRatio = 0.2,
    this.maxExponent = 10,
  });

  final Duration baseDelay;
  final Duration maxDelay;
  final double jitterRatio;
  final int maxExponent;

  /// [attempt] is the 1-based number of attempts already made.
  Duration delayFor(int attempt) {
    final exponent = (attempt - 1).clamp(0, maxExponent);
    final scaled = baseDelay.inMilliseconds * pow(2, exponent).toInt();
    return Duration(
      milliseconds: scaled.clamp(
        baseDelay.inMilliseconds,
        maxDelay.inMilliseconds,
      ),
    );
  }

  DateTime nextAttemptAt(DateTime now, int attempt, {Random? random}) {
    final delay = delayFor(attempt);
    final jitter = (delay.inMilliseconds * jitterRatio).round();
    final rand = random ?? Random();
    final delta = jitter == 0 ? 0 : rand.nextInt(jitter * 2 + 1) - jitter;
    final total = (delay.inMilliseconds + delta).clamp(
      0,
      maxDelay.inMilliseconds + jitter,
    );
    return now.add(Duration(milliseconds: total));
  }
}
