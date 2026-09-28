/// Fetch plumbing shared by the economy providers: bounded concurrency,
/// offline cache (X4) and countdown-driven refresh (SUMMARY §9.1, §10).
///
/// Not exported from `economy.dart`; feature code should use the providers.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../network/riot_exception.dart';
import '../../storage/json_file_cache.dart';
import '../../util/clock.dart';

/// Maximum number of P-3 calls in flight for one account (SUMMARY §10:
/// "at most 2–3 concurrent" per account).
const kEconomyConcurrency = 3;

/// Extra delay after a countdown reaches zero before refetching, so Riot has
/// rotated the offers when we ask again.
const kRefreshGrace = Duration(seconds: 3);

/// Floor between two refetches, so a countdown Riot keeps reporting as
/// nearly expired cannot turn into a request loop.
const kMinRefreshDelay = Duration(seconds: 10);

/// Retry delay while showing an offline copy after a transient failure.
const kOfflineRetryDelay = Duration(seconds: 60);

/// Runs [task] for every input with at most [concurrency] tasks in flight and
/// returns the results in input order.
///
/// Once a task fails no new task is started; running ones finish, then the
/// most actionable error is rethrown: [NeedsLoginException] first, then
/// [MaintenanceException], otherwise the first failure in input order.
Future<List<T>> runPooled<S, T>(
  Iterable<S> inputs,
  Future<T> Function(S input) task, {
  int concurrency = kEconomyConcurrency,
}) async {
  final items = inputs.toList(growable: false);
  final results = List<T?>.filled(items.length, null);
  final errors = <int, (Object, StackTrace)>{};
  var next = 0;

  Future<void> worker() async {
    while (errors.isEmpty && next < items.length) {
      final index = next++;
      try {
        results[index] = await task(items[index]);
      } on Object catch (error, stack) {
        errors[index] = (error, stack);
      }
    }
  }

  final workers = math.max(1, math.min(concurrency, items.length));
  await Future.wait([for (var i = 0; i < workers; i++) worker()]);

  if (errors.isNotEmpty) {
    final ordered = errors.keys.toList()..sort();
    (Object, StackTrace)? pick(bool Function(Object) test) {
      for (final i in ordered) {
        if (test(errors[i]!.$1)) return errors[i];
      }
      return null;
    }

    final (error, stack) =
        pick((e) => e is NeedsLoginException) ??
        pick((e) => e is MaintenanceException) ??
        errors[ordered.first]!;
    Error.throwWithStackTrace(error, stack);
  }
  return [for (final r in results) r as T];
}

/// Awaits two futures started together and rethrows the first failure
/// unwrapped (unlike `(a, b).wait`, which wraps it in a `ParallelWaitError`
/// that `describeError` would not recognise).
Future<(A, B)> awaitBoth<A, B>(Future<A> a, Future<B> b) async {
  // Mark both as handled so a failure of the second while awaiting the first
  // is not reported as an unhandled zone error.
  a.ignore();
  b.ignore();
  final first = await a;
  final second = await b;
  return (first, second);
}

/// A JSON payload from the network or from the offline cache.
class FetchedJson {
  const FetchedJson(this.data, {required this.receivedAt, this.cachedAfter});

  final Object? data;

  /// When the payload was received from Riot (for a cached copy: when it was
  /// originally received, so countdowns stay correct).
  final DateTime receivedAt;

  /// The transient failure that made us fall back to the cache; `null` for
  /// live data.
  final TransientException? cachedAfter;

  bool get isFromCache => cachedAfter != null;
}

/// Fetches [fetch]; on success stores the payload under
/// `acct/<puuid>/<name>` (wiped at sign-out). On a [TransientException]
/// returns the last stored copy instead (X4), or rethrows when there is none.
/// Every other error propagates unchanged.
Future<FetchedJson> fetchWithOfflineCache(
  Ref ref, {
  required String puuid,
  required String name,
  required Future<Object?> Function() fetch,
}) async {
  final cache = ref.read(jsonFileCacheProvider);
  final clock = ref.read(clockProvider);
  final key = JsonFileCache.accountKey(puuid.toLowerCase(), 'economy_$name');
  try {
    final data = await fetch();
    final receivedAt = clock.now();
    try {
      await cache.write(key, data, savedAt: receivedAt);
    } on Object {
      // The offline copy is best effort.
    }
    return FetchedJson(data, receivedAt: receivedAt);
  } on TransientException catch (error) {
    CachedJson? cached;
    try {
      cached = await cache.read(key);
    } on Object {
      cached = null;
    }
    if (cached == null || cached.data == null) rethrow;
    return FetchedJson(
      cached.data,
      receivedAt: cached.savedAt,
      cachedAfter: error,
    );
  }
}

/// Delay before retrying after serving an offline copy: the server's
/// `Retry-After` when given, clamped to 30 s … 10 min.
Duration offlineRetryDelay(TransientException error) {
  final wanted = error.retryAfter ?? kOfflineRetryDelay;
  const min = Duration(seconds: 30);
  const max = Duration(minutes: 10);
  if (wanted < min) return min;
  if (wanted > max) return max;
  return wanted;
}

/// Keeps an auto-dispose provider's value cached until [at] (plus [grace],
/// at least [minDelay] from [now]) and then invalidates it: listened providers refetch,
/// unlistened ones are disposed. With [refetch] `false` the cache is only
/// released (no refetch while listened). A `null` [at] keeps nothing alive.
void scheduleProviderRefresh(
  Ref ref,
  DateTime? at, {
  required DateTime now,
  bool refetch = true,
  Duration grace = kRefreshGrace,
  Duration minDelay = kMinRefreshDelay,
}) {
  if (at == null || !ref.mounted) return;
  final link = ref.keepAlive();
  var delay = at.difference(now) + grace;
  if (delay < minDelay) delay = minDelay;
  final timer = Timer(delay, () {
    link.close();
    if (refetch && ref.mounted) ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);
}
