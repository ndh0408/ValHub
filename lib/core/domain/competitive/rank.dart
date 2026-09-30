/// Shared competitive domain: MMR (P-11), competitive updates (P-12), rank
/// resolution, peak / true peak, local RR history, Daily RR and the Rank-Up
/// Calculator (SUMMARY §7.4, §9.5–§9.7).
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/account_providers.dart';
import '../../content/content_db.dart';
import '../../content/content_repository.dart';
import '../../riot/pvp_api.dart';
import '../../util/clock.dart';
import 'paging.dart';
import 'rank_calc.dart';
import 'rank_models.dart';
import 'rr_history.dart';
import 'viewer.dart';

export 'paging.dart';
export 'rank_calc.dart';
export 'rank_models.dart';
export 'rr_history.dart';

/// P-11 MMR of any player (family key = PUUID), kept 3 minutes (SUMMARY
/// §10). For signed-in accounts its `LatestCompetitiveUpdate` is added to
/// the local RR history (other players' rows are stored only when their
/// competitive updates are opened, so live-game rosters leave no files).
final mmrProvider = FutureProvider.autoDispose.family<PlayerMmr, String>((
  ref,
  puuid,
) async {
  final subject = puuid.trim().toLowerCase();
  final viewer = watchViewer(ref, subject);
  final api = ref.watch(pvpApiProvider);
  final store = ref.watch(rrHistoryStoreProvider);
  final mmr = PlayerMmr.fromJson(await api.mmr(viewer, subject: subject));
  cacheFor(ref, const Duration(minutes: 3)); // only after a success
  final latest = mmr.latestCompetitiveUpdate;
  if (latest != null &&
      viewer == subject &&
      ref.mounted &&
      ref.read(accountProvider(subject)) != null) {
    unawaited(
      store.merge(subject, [latest]).then((_) {}, onError: (Object _) {}),
    );
  }
  return mmr;
});

/// Rows of the local RR history of a player (every P-12 row seen on this
/// device, newest first) + known outcomes. Refreshes whenever new rows are
/// stored.
final rrHistoryProvider = FutureProvider.autoDispose.family<RrHistory, String>((
  ref,
  puuid,
) {
  final id = puuid.trim().toLowerCase();
  final store = ref.watch(rrHistoryStoreProvider);
  final own = ref.watch(accountProvider(id)) != null;
  final sub = store.changes
      .where((changed) => changed == id)
      .listen((_) => ref.invalidateSelf());
  ref.onDispose(sub.cancel);
  return own ? store.read(id) : store.readVisitor(id);
});

/// Rank card of any player (R2, R3, R11, R13, G5, G6): current rank,
/// peak over acts with true-peak RR from the local history, act stats.
///
/// For a signed-in account it also caches `rankTier` / `rankSeasonId` on the
/// [Account] for the account switcher (A4).
final rankSummaryProvider = FutureProvider.autoDispose
    .family<RankSummary, String>((ref, puuid) async {
      final id = puuid.trim().toLowerCase();
      final viewer = watchViewer(ref, id);
      final console = watchIsConsole(ref, viewer);
      final mmrFuture = ref.watch(mmrProvider(id).future);
      final historyFuture = ref.watch(rrHistoryProvider(id).future);
      final db = ref.watch(contentProvider).value ?? ContentDb.empty();
      final now = ref.watch(clockProvider).now();
      final mmr = await mmrFuture;
      final history = await historyFuture;
      final summary = buildRankSummary(
        db,
        mmr,
        now: now,
        history: history.rows,
        console: console,
      );
      if (!ref.mounted) return summary;
      final account = ref.read(accountProvider(id));
      final current = summary.current;
      if (account != null &&
          current.actUuid != null &&
          (account.rankTier != current.tier ||
              account.rankSeasonId != current.actUuid)) {
        unawaited(
          ref
              .read(accountsProvider.notifier)
              .updateAccount(
                id,
                (a) => a.copyWith(
                  rankTier: current.tier,
                  rankSeasonId: current.actUuid,
                ),
              )
              .catchError((Object _) {}),
        );
      }
      return summary;
    });

/// P-12 competitive updates of any player (R4), paginated by 20
/// (`queue=competitive`). Every page is merged into the local RR history.
///
/// ```dart
/// final updates = ref.watch(competitiveUpdatesProvider(puuid));   // AsyncValue<PagedState<CompetitiveUpdate>>
/// ref.read(competitiveUpdatesProvider(puuid).notifier).loadMore();
/// ```
final competitiveUpdatesProvider = AsyncNotifierProvider.autoDispose
    .family<CompetitiveUpdatesNotifier, PagedState<CompetitiveUpdate>, String>(
      CompetitiveUpdatesNotifier.new,
    );

class CompetitiveUpdatesNotifier
    extends AsyncNotifier<PagedState<CompetitiveUpdate>> {
  CompetitiveUpdatesNotifier(this.puuid);

  final String puuid;

  late String _viewer;
  late String _subject;
  late String _queue;
  int _nextIndex = 0;

  /// First-page rows that were not in the local history before this load
  /// (used by [rrHistorySyncProvider] to decide whether to backfill). The
  /// newest row always counts as new: [mmrProvider] may have stored it (its
  /// `LatestCompetitiveUpdate`) moments before the first page arrived.
  int newInFirstPage = 0;

  /// Match ids stored before the first page was loaded (minus the newest
  /// row, see [newInFirstPage]). The backfill compares older pages with
  /// this snapshot, so rows stored meanwhile (by [mmrProvider] or
  /// [loadMore]) are not mistaken for an overlap.
  Set<String> knownBeforeFirstPage = const {};

  @override
  Future<PagedState<CompetitiveUpdate>> build() async {
    _subject = puuid.trim().toLowerCase();
    _viewer = watchViewer(ref, _subject);
    _queue =
        queueForPlatform(
          kCompetitiveQueue,
          console: watchIsConsole(ref, _viewer),
        ) ??
        kCompetitiveQueue;
    final api = ref.watch(pvpApiProvider);
    final store = ref.watch(rrHistoryStoreProvider);
    final page = CompetitiveUpdatesPage.fromJson(
      await api.competitiveUpdates(_viewer, subject: _subject, queue: _queue),
    );
    cacheFor(ref, const Duration(minutes: 3)); // only after a success
    final known = await _knownIds(store);
    final newest = page.matches.firstOrNull?.matchId;
    if (newest != null) known.remove(newest);
    knownBeforeFirstPage = known;
    newInFirstPage = page.matches
        .where((u) => !known.contains(u.matchId))
        .length;
    await _store(store, page.matches);
    _nextIndex = page.matches.length;
    return PagedState(
      items: page.matches,
      hasMore: page.matches.length >= kRiotPageSize,
    );
  }

  /// Loads the next page (no-op while loading or at the end).
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true, clearError: true));
    final start = _nextIndex;
    try {
      final page = CompetitiveUpdatesPage.fromJson(
        await ref
            .read(pvpApiProvider)
            .competitiveUpdates(
              _viewer,
              subject: _subject,
              startIndex: start,
              endIndex: start + kRiotPageSize,
              queue: _queue,
            ),
      );
      if (!ref.mounted) return;
      await _store(ref.read(rrHistoryStoreProvider), page.matches);
      if (!ref.mounted) return;
      _nextIndex = start + page.matches.length;
      final seen = {for (final u in current.items) u.matchId};
      state = AsyncData(
        current.copyWith(
          items: List.unmodifiable([
            ...current.items,
            ...page.matches.where((u) => seen.add(u.matchId)),
          ]),
          hasMore: page.matches.length >= kRiotPageSize,
          isLoadingMore: false,
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

  Future<Set<String>> _knownIds(RrHistoryStore store) async {
    try {
      final own = ref.read(accountProvider(_subject)) != null;
      final history = own
          ? await store.read(_subject)
          : store.readVisitor(_subject);
      return {for (final r in history.rows) r.matchId};
    } on Object {
      return <String>{};
    }
  }

  Future<int> _store(RrHistoryStore store, List<CompetitiveUpdate> rows) async {
    try {
      if (!ref.mounted) return 0;
      return ref.read(accountProvider(_subject)) != null
          ? await store.merge(_subject, rows)
          : store.mergeVisitor(_subject, rows);
    } on Object {
      return 0;
    }
  }
}

/// Pages fetched by [rrHistorySyncProvider] beyond the first (5 pages =
/// 100 matches on the first sync).
const kRrHistoryBackfillPages = 4;

/// Backfills the local RR history: when the first page of competitive
/// updates was entirely new to this device, older pages are fetched until
/// one overlaps the stored history (or [kRrHistoryBackfillPages] pages).
/// Returns the number of rows added. Errors are swallowed (best effort).
final rrHistorySyncProvider = FutureProvider.autoDispose.family<int, String>((
  ref,
  puuid,
) async {
  final id = puuid.trim().toLowerCase();
  if (ref.watch(accountProvider(id)) == null) return 0;
  final viewer = watchViewer(ref, id);
  final console = watchIsConsole(ref, viewer);
  final api = ref.watch(pvpApiProvider);
  final store = ref.watch(rrHistoryStoreProvider);
  final firstFuture = ref.watch(competitiveUpdatesProvider(id).future);
  try {
    final first = await firstFuture;
    if (!ref.mounted) return 0;
    final notifier = ref.read(competitiveUpdatesProvider(id).notifier);
    if (!first.hasMore || notifier.newInFirstPage < first.items.length) {
      return 0;
    }
    final queue =
        queueForPlatform(kCompetitiveQueue, console: console) ??
        kCompetitiveQueue;
    final known = notifier.knownBeforeFirstPage;
    var added = 0;
    var start = first.items.length;
    for (var i = 0; i < kRrHistoryBackfillPages; i++) {
      final page = CompetitiveUpdatesPage.fromJson(
        await api.competitiveUpdates(
          viewer,
          subject: id,
          startIndex: start,
          endIndex: start + kRiotPageSize,
          queue: queue,
        ),
      );
      if (!ref.mounted || ref.read(accountProvider(id)) == null) return added;
      final fresh = page.matches
          .where((u) => !known.contains(u.matchId))
          .length;
      added += await store.merge(id, page.matches);
      start += page.matches.length;
      if (page.matches.length < kRiotPageSize || fresh < page.matches.length) {
        break;
      }
    }
    return added;
  } on Object {
    return 0;
  }
});

/// Settings integration: deletes only this own account's recorded RR.
Future<void> deleteRrHistoryFor(Ref ref, String puuid) async {
  final id = puuid.trim().toLowerCase();
  if (ref.read(accountProvider(id)) == null) return;
  await ref.read(rrHistoryStoreProvider).delete(id);
}

final deleteRrHistoryProvider =
    Provider.family<Future<void> Function(), String>(
      (ref, puuid) =>
          () => deleteRrHistoryFor(ref, puuid),
    );

/// Daily RR (R5, S42) of a player from the local RR history, newest day
/// first. Keeps the first page of competitive updates and the backfill
/// running; show their errors from [competitiveUpdatesProvider].
final dailyRrProvider = FutureProvider.autoDispose
    .family<List<DailyRr>, String>((ref, puuid) async {
      final id = puuid.trim().toLowerCase();
      ref
        ..listen(competitiveUpdatesProvider(id), (_, _) {})
        ..listen(rrHistorySyncProvider(id), (_, _) {});
      final history = await ref.watch(rrHistoryProvider(id).future);
      return groupDailyRr(history.rows, outcomes: history.outcomes);
    });

/// Recent form (last 20 competitive updates) for the Rank-Up Calculator.
final rankUpFormProvider = FutureProvider.autoDispose
    .family<RankUpForm, String>((ref, puuid) async {
      final id = puuid.trim().toLowerCase();
      final page = await ref.watch(competitiveUpdatesProvider(id).future);
      return rankUpFormOf(page.items);
    });

/// Family key of [rankUpEstimateProvider]; `targetTier` is an Episode-5
/// tier (`null` = the next tier, for the profile hint "≈ 9 trận để lên …").
typedef RankUpQuery = ({String puuid, int? targetTier});

/// Rank-Up Calculator (R6, S41). `null` when unranked / in placements /
/// Immortal+ or the target is invalid.
final rankUpEstimateProvider = FutureProvider.autoDispose
    .family<RankUpEstimate?, RankUpQuery>((ref, q) async {
      final id = q.puuid.trim().toLowerCase();
      final summaryFuture = ref.watch(rankSummaryProvider(id).future);
      final formFuture = ref.watch(rankUpFormProvider(id).future);
      final summary = await summaryFuture;
      final form = await formFuture;
      final current = summary.current;
      final target = q.targetTier ?? current.normalizedTier + 1;
      return estimateRankUp(
        currentTier: current.normalizedTier,
        currentRr: current.rr,
        targetTier: target,
        form: form,
      );
    });
