import 'error_classifier.dart';
import 'riot_exception.dart';

const _maxAutoWait = Duration(seconds: 60);

/// A device with no connection answers at once with the same error, so more
/// than one provider-level retry only keeps the skeleton on screen.
const _maxNetworkRetries = 1;

/// Riverpod `retry:` policy for anything that calls Riot (SUMMARY §11.6,
/// FS §9). Never retries "log in again", maintenance, 4xx or programming
/// errors; retries transient failures at most 3 times, honouring
/// `Retry-After` up to 60 s. An offline device (`network`) is retried once.
///
/// Installed globally on the app's `ProviderScope(retry: riotRetry)`.
Duration? riotRetry(int retryCount, Object error) {
  if (retryCount >= 3) return null;
  return switch (error) {
    // Long server-requested waits surface as an error ("Thử lại sau …")
    // instead of a provider silently loading for minutes.
    TransientException(:final retryAfter?) when retryAfter > _maxAutoWait =>
      null,
    TransientException(:final reason) when reason == 'network' =>
      retryCount >= _maxNetworkRetries
          ? null
          : backoffDelay(retryCount, base: const Duration(seconds: 2)),
    TransientException(:final retryAfter) =>
      retryAfter ?? backoffDelay(retryCount, base: const Duration(seconds: 2)),
    _ => null,
  };
}
