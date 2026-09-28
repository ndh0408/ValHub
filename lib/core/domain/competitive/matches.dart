import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/account_providers.dart';
import '../../network/riot_exception.dart';
import '../../riot/pvp_api.dart';
import '../../storage/json_file_cache.dart';
import '../../util/json.dart';
import 'match_models.dart';
import 'names.dart';
import 'paging.dart';
import 'rank_models.dart' show kCompetitiveQueue;
import 'rr_history.dart';
import 'viewer.dart';

export 'match_models.dart';
export 'paging.dart';

// ------------------------------------------------------------ P-13 models

/// One P-13 `History[]` row.
@immutable
class MatchHistoryEntry {
  const MatchHistoryEntry({
    required this.matchId,
    this.startTime,
    this.queueId = '',
  });

  static MatchHistoryEntry? fromJson(Object? json) {
    final m = asMap(json);
    final id = lowerUuid(m?['MatchID']);
    if (m == null || id == null) return null;
    return MatchHistoryEntry(
      matchId: id,
      startTime: m.dateTime('GameStartTime'),
      queueId: (m.str('QueueID') ?? '').trim(),
    );
  }

  /// Lowercase match uuid → [matchDetailsProvider].
  final String matchId;
  final DateTime? startTime;

  /// `""` for custom games.
  final String queueId;

  @override
  bool operator ==(Object other) =>
      other is MatchHistoryEntry &&
      other.matchId == matchId &&
      other.startTime == startTime &&
      other.queueId == queueId;

  @override
  int get hashCode => Object.hash(matchId, startTime, queueId);
}

/// P-13 response page (EP §11.1).
@immutable
class MatchHistoryPage {
  const MatchHistoryPage({
    this.subject,
    this.beginIndex = 0,
    this.endIndex = 0,
    this.total,
    this.entries = const [],
  });

  static MatchHistoryPage fromJson(Object? json) {
    final m = asMap(json) ?? const <String, dynamic>{};
    return MatchHistoryPage(
      subject: m.uuid('Subject'),
      beginIndex: m.integer('BeginIndex') ?? 0,
      endIndex: m.integer('EndIndex') ?? 0,
      total: m.integer('Total'),
      entries: List.unmodifiable([
        for (final e in m.list('History')) ?MatchHistoryEntry.fromJson(e),
      ]),
    );
  }

  final String? subject;
  final int beginIndex;
  final int endIndex;

  /// Total matches Riot keeps for the filter (`null` when absent).
  final int? total;

  /// Newest first.
  final List<MatchHistoryEntry> entries;

  /// Whether another page exists after one requested at [startIndex].
  bool hasMoreAfter(int startIndex) {
    if (entries.isEmpty) return false;
    final t = total;
    if (t != null) return startIndex + entries.length < t;
    return entries.length >= kRiotPageSize;
  }
}

// ------------------------------------------------------------ disk cache

/// Match details on disk (SUMMARY §10: immutable, keep the last ~200).
///
/// Stores [MatchDetails.toJson] (a compact copy without positions) under the
/// global key `matches/<matchId>` of the general cache, so "Xóa bộ nhớ đệm"
/// clears it. Only completed matches are cached. Least recently used files
/// are pruned beyond [keep].
class MatchDetailsCache {
  MatchDetailsCache(this._files, {this.keep = 200});

  final JsonFileCache _files;
  final int keep;

  static String key(String matchId) =>
      'matches/${matchId.trim().toLowerCase()}';

  Future<MatchDetails?> read(String matchId) async {
    try {
      final cached = await _files.read(key(matchId));
      final data = cached?.map;
      if (data == null) return null;
      final details = MatchDetails.fromJson(data, matchId: matchId);
      if (details.matchId.isEmpty || details.players.isEmpty) return null;
      unawaited(_touch(matchId));
      return details;
    } on Object {
      return null;
    }
  }

  Future<void> write(MatchDetails details) async {
    if (!details.info.isCompleted || details.matchId.isEmpty) return;
    try {
      await _files.write(key(details.matchId), details.toJson());
      await prune();
    } on Object {
      // Disk full / unavailable: the next open refetches.
    }
  }

  /// Deletes the least recently used entries beyond [keep].
  Future<void> prune() async {
    try {
      final dir = (await _files.fileFor(key('x'))).parent;
      if (!dir.existsSync()) return;
      final files = [
        for (final e in dir.listSync())
          if (e is File && e.path.endsWith('.json')) e,
      ];
      if (files.length <= keep) return;
      final stamped = [for (final f in files) (f, f.lastModifiedSync())]
        ..sort((a, b) => a.$2.compareTo(b.$2));
      for (final (file, _) in stamped.take(files.length - keep)) {
        await file.delete();
      }
    } on Object {
      // Best effort.
    }
  }

  Future<void> _touch(String matchId) async {
    try {
      final file = await _files.fileFor(key(matchId));
      await file.setLastModified(DateTime.now());
    } on Object {
      // Best effort (LRU order only).
    }
  }
}

// ------------------------------------------------------------ repository

/// P-13 / P-14 access with the disk cache. Plain class (usable without
/// Riverpod).
class MatchRepository {
  MatchRepository({required this._api, required this._cache});

  final PvpApi _api;
  final MatchDetailsCache _cache;

  MatchDetailsCache get cache => _cache;

  /// One P-13 page of [subject] (default: [viewer]) filtered by [queue]
  /// (`null` = all queues).
  Future<MatchHistoryPage> history(
    String viewer, {
    String? subject,
    int startIndex = 0,
    int endIndex = kRiotPageSize,
    String? queue,
  }) async {
    final q = queue?.trim();
    final json = await _api.matchHistory(
      viewer,
      subject: subject,
      startIndex: startIndex,
      endIndex: endIndex,
      queue: q == null || q.isEmpty ? null : q,
    );
    return MatchHistoryPage.fromJson(json);
  }

  /// Match details: disk cache first, then P-14 (throws
  /// [NotFoundException] while Riot is still processing the match).
  Future<MatchDetails> details(
    String viewer,
    String matchId, {
    bool refresh = false,
  }) async {
    final id = matchId.trim().toLowerCase();
    if (!refresh) {
      final cached = await _cache.read(id);
      if (cached != null) return cached;
    }
    final json = await _api.matchDetails(viewer, id);
    final details = MatchDetails.fromJson(json, matchId: id);
    await _cache.write(details);
    return details;
  }
}

final matchDetailsCacheProvider = Provider<MatchDetailsCache>(
  (ref) => MatchDetailsCache(ref.watch(jsonFileCacheProvider)),
);

final matchRepositoryProvider = Provider<MatchRepository>(
  (ref) => MatchRepository(
    api: ref.watch(pvpApiProvider),
    cache: ref.watch(matchDetailsCacheProvider),
  ),
);

// ------------------------------------------------------------ providers

/// Family key of [matchHistoryProvider]: whose history, and which PC queue
/// id (`null` = every queue). Console accounts get `console_*` ids
/// automatically.
typedef MatchHistoryQuery = ({String puuid, String? queue});

/// Match history of any player (R8, R9, R13), paginated by 20.
///
/// ```dart
/// final q = (puuid: account.puuid, queue: 'competitive');
/// final history = ref.watch(matchHistoryProvider(q));        // AsyncValue<PagedState<MatchHistoryEntry>>
/// ref.read(matchHistoryProvider(q).notifier).loadMore();     // "Tải thêm"
/// ```
final matchHistoryProvider = AsyncNotifierProvider.autoDispose
    .family<
      MatchHistoryNotifier,
      PagedState<MatchHistoryEntry>,
      MatchHistoryQuery
    >(MatchHistoryNotifier.new);

class MatchHistoryNotifier
    extends AsyncNotifier<PagedState<MatchHistoryEntry>> {
  MatchHistoryNotifier(this.query);

  final MatchHistoryQuery query;

  late String _viewer;
  late String _subject;
  String? _queue;
  int _nextIndex = 0;

  @override
  Future<PagedState<MatchHistoryEntry>> build() async {
    _subject = query.puuid.trim().toLowerCase();
    _viewer = watchViewer(ref, _subject);
    _queue = queueForPlatform(
      query.queue,
      console: watchIsConsole(ref, _viewer),
    );
    final repo = ref.watch(matchRepositoryProvider);
    cacheFor(ref, const Duration(minutes: 3));
    final page = await repo.history(_viewer, subject: _subject, queue: _queue);
    _nextIndex = page.entries.length;
    return PagedState(
      items: page.entries,
      hasMore: page.hasMoreAfter(0),
      total: page.total,
    );
  }

  /// Loads the next page (no-op while loading or at the end).
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true, clearError: true));
    final start = _nextIndex;
    try {
      final page = await ref
          .read(matchRepositoryProvider)
          .history(
            _viewer,
            subject: _subject,
            startIndex: start,
            endIndex: start + kRiotPageSize,
            queue: _queue,
          );
      if (!ref.mounted) return;
      _nextIndex = start + page.entries.length;
      final seen = {for (final e in current.items) e.matchId};
      state = AsyncData(
        current.copyWith(
          items: List.unmodifiable([
            ...current.items,
            ...page.entries.where((e) => seen.add(e.matchId)),
          ]),
          hasMore: page.hasMoreAfter(start),
          isLoadingMore: false,
          total: page.total,
        ),
      );
    } on Object catch (e) {
      if (!ref.mounted) return;
      state = AsyncData(
        isPastEndError(e)
            ? current.copyWith(hasMore: false, isLoadingMore: false)
            : current.copyWith(isLoadingMore: false, loadMoreError: e),
      );
    }
  }
}

/// Typed match details (R10–R12, G11), cached on disk forever (completed
/// matches) and for 10 minutes in memory. Blank Riot IDs are filled via
/// [NameResolver] (best effort: names stay blank if name-service fails).
/// Also records the match outcome of every signed-in participant for Daily
/// RR (SUMMARY §9.6).
///
/// Errors: [NotFoundException] right after a match (show
/// `CompetitiveStrings.matchPending`, retry later), other `RiotException`s.
final matchDetailsProvider = FutureProvider.autoDispose
    .family<MatchDetails, String>((ref, matchId) async {
      final id = matchId.trim().toLowerCase();
      final repo = ref.watch(matchRepositoryProvider);
      final resolver = ref.watch(nameResolverProvider);
      final viewer = ref.read(activePuuidProvider);
      if (viewer == null) {
        throw const NeedsLoginException(reason: 'no_account');
      }
      ref.watch(accountProvider(viewer).select((a) => a?.needsLogin));
      cacheFor(ref, const Duration(minutes: 10));

      final details = await repo.details(viewer, id);
      final accounts = ref.read(accountsProvider);
      final names = <String, RiotName>{};
      for (final a in accounts) {
        final n = RiotName.of(a.gameName, a.tagLine);
        if (n != null && details.player(a.puuid) != null) names[a.puuid] = n;
      }
      for (final p in details.players) {
        final n = p.name;
        if (n != null && !n.isBlank) resolver.remember(p.subject, n);
      }
      final missing = [
        for (final s in details.unnamedSubjects)
          if (!names.containsKey(s)) s,
      ];
      if (missing.isNotEmpty) {
        try {
          names.addAll(await resolver.resolve(viewer, missing));
        } on Object {
          // Names are cosmetic: keep the scoreboard.
        }
      }
      if (baseQueueId(details.info.queueId) == kCompetitiveQueue) {
        final store = ref.read(rrHistoryStoreProvider);
        for (final a in accounts) {
          if (details.player(a.puuid) == null) continue;
          final outcome = details.resultFor(a.puuid).outcome;
          unawaited(
            store
                .recordOutcomes(a.puuid, {id: outcome}, force: true)
                .catchError((Object _) {}),
          );
        }
      }
      return details.withNames(names);
    });

/// Family key of [matchSummaryProvider].
typedef MatchSummaryQuery = ({String matchId, String puuid});

/// One player's line of a match (map, score, result, agent, K/D/A, ACS…)
/// for match-list cards; `null` when the player is not in the match.
final matchSummaryProvider = FutureProvider.autoDispose
    .family<MatchPlayerSummary?, MatchSummaryQuery>((ref, q) async {
      final details = await ref.watch(matchDetailsProvider(q.matchId).future);
      return details.summaryFor(q.puuid);
    });
