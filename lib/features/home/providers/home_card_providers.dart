/// Per-card view models of the Home dashboard (docs/design/HOME.md §5).
/// Each watches the existing providers of its feature (same TTLs, no new
/// polling) and turns them into a small, pure-built snapshot.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/accounts/account_status.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/riot/platform_status.dart';
import '../../../core/util/clock.dart';
import '../../../core/xmpp/xmpp_providers.dart';
import '../../battlepass/providers/battlepass_providers.dart';
import '../../community/community_previews.dart';
import '../../community/data/community_models.dart';
import '../../community/providers/community_providers.dart';
import '../../live_game/providers/live_game_providers.dart';
import '../../store/providers/night_market_seen.dart';
import '../data/home_accounts.dart';
import '../data/home_battlepass.dart';
import '../data/home_card.dart';
import '../data/home_community.dart';
import '../data/home_friends.dart';
import '../data/home_live.dart';
import '../data/home_rank.dart';
import '../data/home_status.dart';
import '../data/home_store.dart';
import 'home_layout_provider.dart';

/// [value] mapped by [convert]; keeps the loading / error state when there
/// is no value yet, and shows the value while a refresh runs or fails.
AsyncValue<R> mapAsync<T, R>(AsyncValue<T> value, R Function(T) convert) {
  if (value.hasValue) return AsyncData(convert(value.requireValue));
  if (value.hasError) return AsyncError(value.error!, value.stackTrace!);
  return AsyncLoading<R>();
}

// ------------------------------------------------------------------- live

/// The live match card, `null` unless the player queues, picks an agent or
/// plays. Home only watches the poller that `LiveGameOverlayHost` owns.
final homeLiveSnapshotProvider = Provider.autoDispose
    .family<HomeLiveSnapshot?, String>((ref, puuid) {
      final state = ref.watch(liveGameProvider(puuid)).value;
      if (state == null) return null;
      final db = ref.watch(contentProvider).value ?? ContentDb.empty();
      return homeLiveSnapshotOf(
        state,
        db,
        self: puuid,
        now: ref.watch(clockProvider).now(),
      );
    });

// ------------------------------------------------------------------ store

/// Today's store: the storefront (required), the wishlist, wallet and the
/// Night Market "seen" flag (optional).
final homeStoreSummaryProvider = Provider.autoDispose
    .family<AsyncValue<HomeStoreSummary?>, String>((ref, puuid) {
      final store = ref.watch(storefrontProvider(puuid));
      final content = ref.watch(contentProvider);
      // Wait for the content so tiles do not flash as "unknown item".
      if (!content.hasValue && !content.hasError && !store.hasError) {
        return AsyncLoading<HomeStoreSummary?>();
      }
      final db = content.value ?? ContentDb.empty();
      final wishlist = ref.watch(wishlistProvider(puuid));
      final wallet = ref.watch(walletProvider(puuid)).value;
      final seen = ref.watch(nightMarketSeenProvider(puuid));
      final now = ref.watch(clockProvider).now();
      return mapAsync(
        store,
        (s) => buildHomeStoreSummary(
          s,
          db: db,
          wishlist: wishlist,
          wallet: wallet,
          nightMarketSeen: seen,
          now: now,
        ),
      );
    });

// ------------------------------------------------------------------- rank

/// Rank, today's RR, streak and games to rank up. Not `dailyRrProvider`: it
/// starts the RR-history backfill (up to 5 pages); today's rows are always
/// in the first page.
final homeRankSnapshotProvider = Provider.autoDispose
    .family<AsyncValue<HomeRankSnapshot?>, String>((ref, puuid) {
      final summary = ref.watch(rankSummaryProvider(puuid));
      final history = ref.watch(rrHistoryProvider(puuid)).value;
      final estimate = ref
          .watch(rankUpEstimateProvider((puuid: puuid, targetTier: null)))
          .value;
      final db = ref.watch(contentProvider).value ?? ContentDb.empty();
      final now = ref.watch(clockProvider).now();
      return mapAsync(
        summary,
        (s) => buildHomeRankSnapshot(
          s,
          db: db,
          now: now,
          history: history,
          estimate: estimate,
        ),
      );
    });

// ------------------------------------------------------------ battle pass

final homeBattlePassSnapshotProvider = Provider.autoDispose
    .family<AsyncValue<HomeBpSnapshot?>, String>((ref, puuid) {
      final overview = ref.watch(battlePassOverviewProvider(puuid));
      final ticket = ref.watch(dailyTicketProvider(puuid)).value;
      final now = ref.watch(clockProvider).now();
      return mapAsync(
        overview,
        (o) => buildHomeBpSnapshot(o, ticket: ticket, now: now),
      );
    });

// ---------------------------------------------------------------- friends

/// Whether Home reads the friends list: the user opted in, or the chat is
/// already connected for another screen. Never starts the connection by
/// itself (chat makes the user look online to friends).
final homeFriendsLiveProvider = Provider.autoDispose<bool>((ref) {
  final consent = ref.watch(homeFriendsConsentProvider);
  if (consent != null) return consent;
  return ref.exists(xmppServiceProvider);
});

/// Friends who are playing now; `data(null)` when nobody is or Home may not
/// read the chat.
final homeFriendsSnapshotProvider =
    Provider.autoDispose<AsyncValue<HomeFriendsSnapshot?>>((ref) {
      if (!ref.watch(homeFriendsLiveProvider)) {
        return const AsyncData<HomeFriendsSnapshot?>(null);
      }
      return mapAsync(ref.watch(friendsProvider), playingFriendsOf);
    });

// -------------------------------------------------------------- community

/// Home owns these TTLs; the shared community previews stay untouched.
final homeLfgPreviewProvider = FutureProvider.autoDispose
    .family<List<LfgPost>, String>((ref, puuid) async {
      final rows = await ref.watch(matchingLfgPreviewProvider(puuid).future);
      cacheFor(ref, const Duration(minutes: 3));
      return rows;
    });

final homeTrendingPreviewProvider = FutureProvider.autoDispose
    .family<List<TopSkin>, TopPeriod>((ref, period) async {
      final rows = await ref.watch(trendingSkinsProvider(period).future);
      cacheFor(ref, const Duration(minutes: 30));
      return rows;
    });

/// LFG posts that fit the viewer's rank (only when the account already
/// agreed to the community) and this week's hot skins. Read-only: Home never
/// signs in to the community server.
final homeCommunitySnapshotProvider = Provider.autoDispose
    .family<AsyncValue<HomeCommunitySnapshot?>, String>((ref, puuid) {
      if (!ref.watch(communityEnabledProvider)) {
        return const AsyncData<HomeCommunitySnapshot?>(null);
      }
      final lfg = ref.watch(homeLfgPreviewProvider(puuid));
      final trending = ref.watch(homeTrendingPreviewProvider(TopPeriod.all));
      final wishlist = ref.watch(wishlistProvider(puuid));
      if (!lfg.hasValue && !trending.hasValue) {
        return lfg.hasError && trending.hasError
            ? AsyncError<HomeCommunitySnapshot?>(lfg.error!, lfg.stackTrace!)
            : AsyncLoading<HomeCommunitySnapshot?>();
      }
      final snapshot = buildHomeCommunitySnapshot(
        lfg: lfg.value ?? const [],
        trending: trending.value ?? const [],
        wishlist: wishlist,
      );
      // One preview may still be on its way: do not settle on "empty" yet.
      if (snapshot == null &&
          ((lfg.isLoading && !lfg.hasValue) ||
              (trending.isLoading && !trending.hasValue))) {
        return AsyncLoading<HomeCommunitySnapshot?>();
      }
      return AsyncData(snapshot);
    });

// --------------------------------------------------------- other accounts

/// The other accounts (saved storefronts and wishlists are local; activity
/// is fetched only for the rows shown).
final homeOtherAccountsProvider = Provider.autoDispose<HomeOtherAccounts?>((
  ref,
) {
  final accounts = ref.watch(accountsProvider);
  if (accounts.length < 2) return null;
  final active = ref.watch(activePuuidProvider);
  final db = ref.watch(contentProvider).value ?? ContentDb.empty();
  final now = ref.watch(clockProvider).now();
  final others = [
    for (final a in accounts)
      if (a.puuid != active) a,
  ];
  return buildOtherAccountSummaries(
    accounts: accounts,
    activePuuid: active,
    savedStores: {
      for (final a in others)
        a.puuid: a.needsLogin
            ? null
            : ref.watch(savedStorefrontProvider(a.puuid)).value,
    },
    wishlists: {
      for (final a in others) a.puuid: ref.watch(wishlistProvider(a.puuid)),
    },
    db: db,
    now: now,
    activityOf: (puuid) => ref.watch(accountActivityProvider(puuid)).value,
  );
});

// ---------------------------------------------------------- server status

/// Regions of the signed-in accounts (lowercase, sorted).
final homeStatusRegionsProvider = Provider.autoDispose<List<String>>((ref) {
  final key = ref.watch(
    accountsProvider.select(
      (list) => ({
        for (final a in list) a.region.toLowerCase(),
      }.toList()..sort()).join(','),
    ),
  );
  return [
    for (final r in key.split(','))
      if (r.isNotEmpty) r,
  ];
});

/// X-1 notices of every region the user has an account in. Empty regions
/// and failed downloads read as "no notice" (never an error on Home).
final homeServerStatusProvider = Provider.autoDispose<HomeServerStatus?>((ref) {
  final active = ref.watch(
    activeAccountProvider.select((a) => a?.region.toLowerCase()),
  );
  final regions = ref.watch(homeStatusRegionsProvider);
  return buildHomeServerStatus({
    for (final r in regions) r: ref.watch(platformStatusProvider(r)).value,
  }, activeRegion: active);
});

/// A maintenance or critical incident in the active region that the user
/// did not switch off: cards without data then stay hidden (their errors
/// would repeat the notice) and the status card is pinned.
final homeStatusBlockingProvider = Provider.autoDispose<bool>((ref) {
  final hidden = ref.watch(
    homeLayoutProvider.select((l) => l.isHidden(HomeCardId.serverStatus)),
  );
  if (hidden) return false;
  return ref.watch(
    homeServerStatusProvider.select((s) => s?.blocking ?? false),
  );
});
