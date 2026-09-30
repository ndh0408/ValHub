import 'rate_limiter.dart';
import 'riot_exception.dart';

/// The throttle shared by every call to Riot's **auth** hosts
/// (`auth.riotgames.com`, `entitlements.auth.riotgames.com`,
/// `riot-geo.pas.si.riotgames.com`): silent re-auth, entitlements, userinfo,
/// region. They are the most fragile hosts we talk to (Cloudflare challenges
/// them first), so unlike PD / GLZ they get a tight bucket: bursts of 2, about
/// one request per second, at most 2 in flight per host, and a host cooldown
/// (30 s → 10 min, `Retry-After` wins) after a block.
///
/// One instance per isolate must be shared by the re-auth and bootstrap
/// clients (see `authLimiterProvider` and `BackgroundContext`).
HostRateLimiter createAuthLimiter({
  DateTime Function()? now,
  Future<void> Function(Duration)? delay,
  double Function()? jitter,
}) => HostRateLimiter(
  burst: 2,
  refillPerSecond: 1,
  maxConcurrent: 2,
  now: now,
  delay: delay,
  jitter: jitter,
);

/// Feeds what an auth-host answer taught us into [limiter]:
///
/// - `429` and Cloudflare pages penalise the host at once;
/// - `5xx` penalise it from the second one within two minutes;
/// - any normal answer (even "log in again") resets the strikes.
///
/// [status] / [reason] are those of the transient failure, both `null` for a
/// normal answer. Timeouts and connection errors say nothing about the host's
/// mood and are ignored.
void learnFromAuthAnswer(
  HostRateLimiter limiter,
  String host, {
  int? status,
  String? reason,
  Duration? retryAfter,
  bool transient = false,
}) {
  if (!transient) {
    limiter.recordSuccess(host);
    return;
  }
  if (status == 429 || reason == 'rate_limited' || reason == 'cloudflare') {
    limiter.penalize(host, retryAfter: retryAfter);
  } else if (status != null && status >= 500) {
    limiter.recordServerError(host, retryAfter: retryAfter);
  }
}

/// Same as [learnFromAuthAnswer] for a classified [TransientException].
void learnFromAuthFailure(
  HostRateLimiter limiter,
  String host,
  TransientException e,
) => learnFromAuthAnswer(
  limiter,
  host,
  status: e.status,
  reason: e.reason,
  retryAfter: e.retryAfter,
  transient: true,
);
