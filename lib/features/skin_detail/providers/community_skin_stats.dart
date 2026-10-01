import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/util/clock.dart';
import '../../community/data/community_api.dart';
import '../../community/data/community_models.dart';
import '../../community/providers/community_providers.dart';

/// Anonymous ratings of visible cards: coalesced in batches of at most 50,
/// retained for 30 minutes, bounded to 500 skins. No Riot account is sent.
class CommunitySkinStats {
  static const freshness = Duration(minutes: 30);
  CommunitySkinStats(this.api, this.clock);
  final CommunityApi api;
  final Clock clock;
  final Map<String, ({SkinStats? stats, DateTime at})> _cache = {};
  Map<String, Completer<SkinStats?>> _pending = {};
  final Map<String, Future<SkinStats?>> _inFlight = {};
  Timer? _timer;
  bool _disposed = false;

  Future<SkinStats?> get(String skinUuid) {
    if (_disposed) return Future.value();
    final id = skinUuid.trim().toLowerCase();
    final cached = _cache[id];
    if (cached != null && clock.now().difference(cached.at) < freshness) {
      return Future.value(cached.stats);
    }
    if (_inFlight[id] case final future?) return future;
    final completion = Completer<SkinStats?>();
    _pending[id] = completion;
    _inFlight[id] = completion.future;
    _timer ??= Timer(
      const Duration(milliseconds: 20),
      () => unawaited(_flush()),
    );
    return completion.future;
  }

  /// Time left from the original fetch, including a cached empty response.
  Duration? expiresIn(String skinUuid) {
    final cached = _cache[skinUuid.trim().toLowerCase()];
    if (cached == null) return null;
    final left = freshness - clock.now().difference(cached.at);
    return left.isNegative ? Duration.zero : left;
  }

  Future<void> _flush() async {
    _timer = null;
    final pending = _pending;
    _pending = {};
    final ids = pending.keys.toList();
    for (var start = 0; start < ids.length; start += 50) {
      final chunk = ids.skip(start).take(50).toList();
      Map<String, SkinStats> stats = {};
      var succeeded = false;
      try {
        stats = await api.skinVotes(chunk); // no puuid, signIn remains false
        succeeded = true;
      } on Object {
        // Optional: a failed request hides the score, never the skin.
      }
      for (final id in chunk) {
        if (!_disposed && succeeded) {
          _cache.remove(id);
          _cache[id] = (stats: stats[id], at: clock.now());
          while (_cache.length > 500) {
            _cache.remove(_cache.keys.first);
          }
        }
        unawaited(_inFlight.remove(id));
        if (!pending[id]!.isCompleted) pending[id]!.complete(stats[id]);
      }
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    for (final completion in _pending.values) {
      if (!completion.isCompleted) completion.complete(null);
    }
    _pending.clear();
    _cache.clear();
  }
}

final communitySkinStatsStoreProvider = Provider<CommunitySkinStats>((ref) {
  final store = CommunitySkinStats(
    ref.watch(communityApiProvider),
    ref.watch(clockProvider),
  );
  ref.onDispose(store.dispose);
  return store;
});

final communitySkinStatsProvider = FutureProvider.autoDispose
    .family<SkinStats?, String>((ref, id) async {
      if (!ref.watch(communityEnabledProvider)) return null;
      final store = ref.watch(communitySkinStatsStoreProvider);
      final stats = await store.get(id);
      if (ref.mounted) {
        final timer = Timer(
          store.expiresIn(id) ?? CommunitySkinStats.freshness,
          ref.invalidateSelf,
        );
        ref.onDispose(timer.cancel);
      }
      return stats;
    });
