import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/domain/progress_events.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/viewer.dart' show cacheFor;
import '../../../core/domain/economy/owned_items.dart';
import '../../../core/domain/economy/economy_fetch.dart' show canUseOfflineCopy;
import '../../../core/network/riot_exception.dart';
import '../../../core/riot/pvp_api.dart';
import '../../../core/riot/riot_ids.dart';
import '../../../core/storage/json_file_cache.dart';
import '../../../core/storage/prefs.dart';
import '../../../core/util/clock.dart';
import '../data/battlepass_models.dart';
import '../data/daily_ticket.dart';
import '../data/player_contracts.dart';

/// Contracts and daily ticket are kept 5 minutes (SUMMARY §10).
const kBattlePassTtl = Duration(minutes: 5);

/// Offline-copy key of P-15 (per account, wiped at sign-out; X4).
String contractsCacheKey(String puuid) =>
    JsonFileCache.accountKey(puuid, 'battlepass_contracts');

String _own(Ref ref, String puuid) {
  final id = puuid.trim().toLowerCase();
  // Refetch after a re-login.
  ref.watch(accountProvider(id).select((a) => a?.needsLogin));
  return id;
}

/// P-15 contracts of a signed-in account. On a transient failure the last
/// successful payload is returned with `isFromCache == true`.
final playerContractsProvider = FutureProvider.autoDispose
    .family<PlayerContracts, String>((ref, puuid) async {
      final id = _own(ref, puuid);
      final api = ref.watch(pvpApiProvider);
      final cache = ref.watch(jsonFileCacheProvider);
      final receivedAt = ref.read(clockProvider).now();
      cacheFor(ref, kBattlePassTtl);
      try {
        final json = await api.contracts(id);
        unawaited(
          cache
              .write(contractsCacheKey(id), json, savedAt: receivedAt)
              .catchError((Object _) {}),
        );
        return PlayerContracts.fromJson(json, receivedAt: receivedAt);
      } on RiotException catch (error) {
        if (!canUseOfflineCopy(error)) rethrow;
        CachedJson? cached;
        try {
          cached = await cache.read(contractsCacheKey(id));
        } on Object {
          cached = null;
        }
        if (cached == null) rethrow;
        return PlayerContracts.fromJson(
          cached.data,
          receivedAt: cached.savedAt,
          isFromCache: true,
        );
      }
    });

/// Contracts whose premium track the account bought (P-3 `f85cb6f7…`).
final premiumContractsProvider = FutureProvider.autoDispose
    .family<Set<String>, String>((ref, puuid) async {
      final id = _own(ref, puuid);
      final api = ref.watch(pvpApiProvider);
      final receivedAt = ref.read(clockProvider).now();
      cacheFor(ref, kBattlePassTtl);
      try {
        final json = await api.entitlements(id, ItemTypeIds.premiumContract);
        return Entitlements.fromJson(
          json,
          receivedAt: receivedAt,
          itemTypeId: ItemTypeIds.premiumContract,
        ).itemsOfType(ItemTypeIds.premiumContract);
      } on NotFoundException {
        return const <String>{};
      }
    });

/// P-16 daily ticket; `null` when Riot answers 404 (no ticket yet today).
final dailyTicketProvider = FutureProvider.autoDispose
    .family<DailyTicket?, String>((ref, puuid) async {
      final id = _own(ref, puuid);
      final api = ref.watch(pvpApiProvider);
      final receivedAt = ref.read(clockProvider).now();
      cacheFor(ref, kBattlePassTtl);
      try {
        final json = await api.dailyTicket(id);
        return DailyTicket.fromJson(json, receivedAt: receivedAt);
      } on NotFoundException {
        return null;
      }
    });

/// S20 data: content + contracts + premium ownership. A failed premium
/// lookup only hides the Premium/Miễn phí badge.
final battlePassOverviewProvider = FutureProvider.autoDispose
    .family<BattlePassOverview, String>((ref, puuid) async {
      final id = puuid.trim().toLowerCase();
      final contractsF = ref.watch(playerContractsProvider(id).future);
      final premiumF = ref
          .watch(premiumContractsProvider(id).future)
          .then<Set<String>?>((v) => v, onError: (Object _) => null);
      final dbF = ref.watch(contentProvider.future);
      // Future.wait handles every error (no unhandled future on failure).
      final results = await Future.wait<Object?>([contractsF, premiumF, dbF]);
      final contracts = results[0]! as PlayerContracts;
      final premium = results[1] as Set<String>?;
      final db = results[2]! as ContentDb;
      final now = ref.read(clockProvider).now();
      final overview = BattlePassOverview.build(
        db: db,
        contracts: contracts,
        now: now,
        premiumContracts: premium,
      );
      if (overview.weekly.unknownIds.isNotEmpty && !db.isEmpty) {
        unawaited(
          ref
              .read(contentMissReporterProvider)
              .report()
              .catchError((Object _) {}),
        );
      }
      final pass = overview.battlePass;
      if (ref.mounted &&
          !contracts.isFromCache &&
          pass != null &&
          ref.read(accountProvider(id)) != null) {
        ref
            .read(progressEventsProvider)
            .emit(
              PassObserved(
                id,
                pass.contract.uuid,
                pass.level,
                pass.levelCount,
                overview.actEndsAt,
              ),
            );
      }
      return overview;
    });

/// Prefs key of the last daily-ticket renew of [puuid].
String dailyTicketRenewKey(String puuid) =>
    PrefKeys.account(puuid.toLowerCase(), 'battlepass.ticketRenewedAt');

/// User-initiated daily-ticket renew (SUMMARY U6: only when the ticket is
/// missing or expired, at most once per day).
final dailyTicketRenewerProvider = Provider<DailyTicketRenewer>(
  DailyTicketRenewer.new,
);

class DailyTicketRenewer {
  DailyTicketRenewer(this._ref);

  final Ref _ref;

  DateTime? lastRenewAt(String puuid) =>
      _ref.read(prefsProvider).getDateTime(dailyTicketRenewKey(puuid));

  /// Whether the "Làm mới cột mốc" button may be offered.
  bool canRenew(String puuid, DailyTicket? ticket) => canRenewDailyTicket(
    ticket: ticket,
    now: _ref.read(clockProvider).now(),
    lastRenewAt: lastRenewAt(puuid),
  );

  /// POST `renew` (never retried), then refetch the ticket.
  Future<void> renew(String puuid) async {
    final id = puuid.trim().toLowerCase();
    await _ref.read(pvpApiProvider).renewDailyTicket(id);
    final now = _ref.read(clockProvider).now();
    await _ref.read(prefsProvider).setDateTime(dailyTicketRenewKey(id), now);
    _ref.invalidate(dailyTicketProvider(id));
  }
}

/// "Thử lại" of S20 / S21: refetch the account data, and the content only
/// when that is what failed.
void retryBattlePass(WidgetRef ref, String puuid) {
  final id = puuid.trim().toLowerCase();
  ref
    ..invalidate(playerContractsProvider(id))
    ..invalidate(premiumContractsProvider(id));
  if (ref.read(contentProvider).hasError) ref.invalidate(contentProvider);
}

/// Pull-to-refresh of S20 / S21.
Future<void> refreshBattlePass(WidgetRef ref, String puuid) async {
  final id = puuid.trim().toLowerCase();
  ref
    ..invalidate(playerContractsProvider(id))
    ..invalidate(premiumContractsProvider(id))
    ..invalidate(dailyTicketProvider(id));
  try {
    await Future.wait<Object?>([
      ref.read(battlePassOverviewProvider(id).future),
      ref.read(dailyTicketProvider(id).future),
    ]);
  } on Object {
    // Errors are rendered by AsyncValueView ("Thử lại").
  }
}
