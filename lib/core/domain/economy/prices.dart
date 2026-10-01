/// Skin prices (SUMMARY §8.2 B9, §9.3; CA §13; VF §9 R3).
///
/// Chain, first hit wins:
/// 1. VanHub price table: bundled `assets/data/prices.json`, overridden by the
///    `prices` block of the cached remote config (X-4) — exact;
/// 2. full prices seen in live storefronts (persisted in prefs) — exact;
/// 3. Riot `store/v1/offers` (P-5), only behind remote flag
///    `use_offers_endpoint`, fetched at most once per 24 h app-wide and
///    disabled for 24 h after any failure (SUMMARY U4) — exact;
/// 4. reward skins (battle pass / agent contract / event pass): no price,
///    labelled with their source (C9);
/// 5. content-tier fallback (SUMMARY §7.3, melee × 2) — estimate ("≈").
library;

import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/account_providers.dart';
import '../../config/remote_config.dart';
import '../../content/content_db.dart';
import '../../content/content_repository.dart';
import '../../l10n/content_strings.dart';
import '../../network/riot_exception.dart';
import '../../riot/pvp_api.dart';
import '../../riot/riot_ids.dart';
import '../../storage/prefs.dart';
import '../../util/clock.dart';
import '../../util/json.dart';
import 'economy_strings.dart';
import 'owned_items.dart';
import 'reward_sources.dart';

/// Where a [PriceQuote] comes from.
enum PriceSource {
  /// VanHub price table (bundled / remote). Exact.
  table,

  /// Seen in a live storefront (daily, Night Market full price, bundle
  /// base price). Exact.
  observed,

  /// Riot P-5 offers list. Exact.
  offers,

  /// Content-tier fallback. Estimate.
  tierFallback,

  /// Battle pass / agent contract / event pass reward: never sold.
  reward,

  /// Standard / Random-favorite skin: not for sale.
  notForSale,

  /// Unknown skin, or no tier to estimate from.
  unknown;

  /// Short Vietnamese caption for tooltips.
  String get label => switch (this) {
    table => EconomyStrings.priceFromTable,
    observed => EconomyStrings.priceFromStore,
    offers => EconomyStrings.priceFromOffers,
    tierFallback => EconomyStrings.priceEstimated,
    reward => ContentStrings.notForSale,
    notForSale => ContentStrings.notForSale,
    unknown => EconomyStrings.priceUnknown,
  };
}

/// The price of one skin.
@immutable
class PriceQuote {
  const PriceQuote({
    required this.vp,
    required this.source,
    this.isEstimate = false,
    this.reward,
  });

  const PriceQuote.notForSale()
    : vp = null,
      source = PriceSource.notForSale,
      isEstimate = false,
      reward = null;

  const PriceQuote.unknown()
    : vp = null,
      source = PriceSource.unknown,
      isEstimate = false,
      reward = null;

  const PriceQuote.reward(RewardSourceEntry this.reward)
    : vp = null,
      source = PriceSource.reward,
      isEstimate = false;

  /// VP price; `null` for rewards, non-sold and unknown skins.
  final int? vp;
  final PriceSource source;

  /// Show with "≈" (`formatEstimatedVp`, `CurrencyAmount(estimate: true)`).
  final bool isEstimate;

  /// Contract granting the skin when [source] is [PriceSource.reward].
  final RewardSourceEntry? reward;

  bool get hasPrice => vp != null;
  bool get isReward => source == PriceSource.reward;

  /// Text to show instead of a price: the reward label ("Phần thưởng Battle
  /// Pass"), "Không bán", or `null` when there is a price (or it is unknown).
  String? get caption => switch (source) {
    PriceSource.reward => reward?.label ?? ContentStrings.notForSale,
    PriceSource.notForSale => ContentStrings.notForSale,
    _ => null,
  };

  @override
  bool operator ==(Object other) =>
      other is PriceQuote &&
      other.vp == vp &&
      other.source == source &&
      other.isEstimate == isEstimate &&
      other.reward?.contract.uuid == reward?.contract.uuid;

  @override
  int get hashCode =>
      Object.hash(vp, source, isEstimate, reward?.contract.uuid);

  @override
  String toString() =>
      'PriceQuote(${isEstimate ? '≈' : ''}$vp, ${source.name})';
}

// ------------------------------------------------------------- price table

/// VanHub price table (`assets/data/prices.json`, X-4 remote override).
///
/// Document shape:
/// ```json
/// { "schema": 1, "updatedAt": "2026-09-28",
///   "prices": { "<level-1 or skin uuid>": 2375 },
///   "tierPrices": { "<contentTierUuid>": 2175 },
///   "meleeMultiplier": 2 }
/// ```
@immutable
class PriceTable {
  const PriceTable({
    this.prices = const {},
    this.tierPrices = const {},
    this.meleeMultiplier = defaultMeleeMultiplier,
    this.updatedAt,
  });

  static const empty = PriceTable();

  /// Melee skins cost about twice the gun price of their edition (CA §13).
  static const defaultMeleeMultiplier = 2.0;

  /// Prices above this are rejected as corrupt.
  static const maxVp = 100000;

  /// Parses a price document; invalid entries are dropped. Never throws.
  factory PriceTable.fromJson(Object? json) {
    final m = asMap(json);
    if (m == null) return empty;
    final multiplier = asDouble(m['meleeMultiplier']);
    return PriceTable(
      prices: parsePriceMap(m['prices']),
      tierPrices: parsePriceMap(m['tierPrices']),
      meleeMultiplier: (multiplier != null && multiplier > 0 && multiplier <= 5)
          ? multiplier
          : defaultMeleeMultiplier,
      updatedAt: asNonEmptyString(m['updatedAt']),
    );
  }

  /// Reads the `prices` block of a remote-config document (SUMMARY §13):
  /// either a full price document or a bare `{uuid: vp}` map.
  factory PriceTable.fromRemoteConfig(Object? remoteConfigJson) {
    final block = asMap(asMap(remoteConfigJson)?['prices']);
    if (block == null) return empty;
    return block.containsKey('prices')
        ? PriceTable.fromJson(block)
        : PriceTable(prices: parsePriceMap(block));
  }

  /// `{uuid: vp}` with lowercase keys, positive integer prices ≤ [maxVp];
  /// keys starting with `_` (comments) are ignored.
  static Map<String, int> parsePriceMap(Object? json) {
    final m = asMap(json);
    if (m == null) return const {};
    return Map.unmodifiable(<String, int>{
      for (final e in m.entries)
        if (!e.key.startsWith('_'))
          if (lowerUuid(e.key) case final id?)
            if (asNum(e.value) case final n?
                when n.isFinite && n > 0 && n <= maxVp)
              id: n.round(),
    });
  }

  /// Exact skin prices (level-1 or skin uuid → VP).
  final Map<String, int> prices;

  /// Tier fallback overrides (content tier uuid → VP).
  final Map<String, int> tierPrices;
  final double meleeMultiplier;
  final String? updatedAt;

  bool get isEmpty => prices.isEmpty && tierPrices.isEmpty;

  /// [other] wins entry by entry.
  PriceTable merge(PriceTable other) => PriceTable(
    prices: Map.unmodifiable({...prices, ...other.prices}),
    tierPrices: Map.unmodifiable({...tierPrices, ...other.tierPrices}),
    meleeMultiplier: other.meleeMultiplier != defaultMeleeMultiplier
        ? other.meleeMultiplier
        : meleeMultiplier,
    updatedAt: other.updatedAt ?? updatedAt,
  );
}

/// Bundled price table asset.
const kPricesAssetPath = 'assets/data/prices.json';

/// Loads the bundled price document (override in tests).
final priceAssetLoaderProvider = Provider<Future<String> Function()>(
  (ref) =>
      () => rootBundle.loadString(kPricesAssetPath),
);

/// Bundled `prices.json` merged with the `prices` block of the cached remote
/// config (remote wins). A missing / corrupt asset yields an empty table.
final priceTableProvider = FutureProvider<PriceTable>((ref) async {
  final load = ref.watch(priceAssetLoaderProvider);
  final prefs = ref.watch(prefsProvider);
  var table = PriceTable.empty;
  try {
    table = PriceTable.fromJson(tryDecodeJson(await load()));
  } on Object {
    // Asset missing (tests / not registered): tier fallback still works.
  }
  return table.merge(
    PriceTable.fromRemoteConfig(prefs.getJson(PrefKeys.remoteConfig)),
  );
});

// ---------------------------------------------------------- observed prices

/// Full prices seen in live storefronts, app-wide (prices are global), in
/// prefs so they survive restarts. Plain class for background isolates.
class ObservedPriceStore {
  ObservedPriceStore(this._prefs);

  final Prefs _prefs;

  static const key = 'f.economy.observedPrices';

  /// Oldest entries are dropped beyond this size.
  static const maxEntries = 4000;

  /// `{levelUuid: vp}` in insertion order (oldest first).
  Map<String, int> read() =>
      LinkedHashMap.of(PriceTable.parsePriceMap(_prefs.getJson(key)));

  /// Merges [prices] (newest wins). Returns the new map when something
  /// changed, `null` otherwise (no write).
  Future<Map<String, int>?> record(Map<String, int> prices) async {
    final valid = PriceTable.parsePriceMap(prices);
    if (valid.isEmpty) return null;
    final current = read();
    var changed = false;
    for (final e in valid.entries) {
      if (current[e.key] == e.value) continue;
      current
        ..remove(e.key)
        ..[e.key] = e.value;
      changed = true;
    }
    if (!changed) return null;
    while (current.length > maxEntries) {
      current.remove(current.keys.first);
    }
    await _prefs.setJson(key, current);
    return Map.unmodifiable(current);
  }
}

/// Observed prices, updated by [storefrontProvider] after every live fetch.
final observedPricesProvider =
    NotifierProvider<ObservedPricesNotifier, Map<String, int>>(
      ObservedPricesNotifier.new,
    );

class ObservedPricesNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() =>
      Map.unmodifiable(ObservedPriceStore(ref.watch(prefsProvider)).read());

  /// Records `Storefront.observedSkinPrices()`.
  Future<void> record(Map<String, int> prices) async {
    final updated = await ObservedPriceStore(ref.read(prefsProvider))
        .record(prices);
    if (updated != null && ref.mounted) state = updated;
  }
}

// ------------------------------------------------------------ P-5 offers

/// App-wide cache of the P-5 price list with its 24 h fetch / disable
/// windows (SUMMARY U4).
class OffersPriceCache {
  OffersPriceCache(this._prefs);

  final Prefs _prefs;

  static const pricesKey = 'f.economy.offerPrices';
  static const fetchedAtKey = 'f.economy.offersFetchedAt';
  static const disabledUntilKey = 'f.economy.offersDisabledUntil';
  static const interval = Duration(hours: 24);

  Map<String, int> read() =>
      PriceTable.parsePriceMap(_prefs.getJson(pricesKey));

  DateTime? get fetchedAt => _prefs.getDateTime(fetchedAtKey);
  DateTime? get disabledUntil => _prefs.getDateTime(disabledUntilKey);

  /// Whether a fetch is due at [now] (flag checked by the caller).
  bool shouldFetch(DateTime now) {
    final disabled = disabledUntil;
    if (disabled != null && now.isBefore(disabled)) return false;
    final last = fetchedAt;
    return last == null || !now.isBefore(last.add(interval));
  }

  Future<void> saveSuccess(Map<String, int> prices, DateTime now) async {
    await _prefs.setJson(pricesKey, prices);
    await _prefs.setDateTime(fetchedAtKey, now);
    await _prefs.remove(disabledUntilKey);
  }

  Future<void> saveFailure(DateTime now) =>
      _prefs.setDateTime(disabledUntilKey, now.add(interval));

  /// `{level-1 uuid: VP}` from a P-5 body: skin-level offers priced in VP
  /// (`OfferID == Rewards[0].ItemID`, CA §13).
  static Map<String, int> parseOffers(Object? json) {
    final out = <String, int>{};
    for (final offer in asMapList(asMap(json)?['Offers'])) {
      final reward = asMapList(offer['Rewards']).firstOrNull;
      if (lowerUuid(reward?['ItemTypeID']) != ItemTypeIds.skinLevel) continue;
      final id = lowerUuid(reward?['ItemID']) ?? lowerUuid(offer['OfferID']);
      final cost = asMap(offer['Cost']);
      num? vp;
      for (final e in (cost ?? const <String, dynamic>{}).entries) {
        if (lowerUuid(e.key) == CurrencyIds.vp) vp = asNum(e.value);
      }
      if (id != null && vp != null && vp.isFinite && vp > 0) {
        out[id] = vp.round();
      }
    }
    return out;
  }
}

/// P-5 prices when remote flag `use_offers_endpoint` is on (default off);
/// otherwise empty. Uses the active account's session; never throws.
final offerPricesProvider = FutureProvider<Map<String, int>>((ref) async {
  final enabled = ref
      .watch(remoteConfigProvider)
      .flag(RemoteFlags.useOffersEndpoint);
  if (!enabled) return const {};
  final cache = OffersPriceCache(ref.watch(prefsProvider));
  final cached = cache.read();
  final puuid = ref.watch(activePuuidProvider);
  final now = ref.read(clockProvider).now();
  if (puuid == null || !cache.shouldFetch(now)) return cached;
  final api = ref.read(pvpApiProvider);
  try {
    final prices = OffersPriceCache.parseOffers(await api.offers(puuid));
    if (prices.isEmpty) {
      await cache.saveFailure(now);
      return cached;
    }
    await cache.saveSuccess(prices, now);
    return prices;
  } on RiotException {
    await cache.saveFailure(now);
    return cached;
  }
});

// ---------------------------------------------------------- price service

/// Value of a set of skins (C8, W7; SUMMARY §9.3).
@immutable
class CollectionValue {
  const CollectionValue({
    this.totalVp = 0,
    this.pricedCount = 0,
    this.estimatedCount = 0,
    this.rewardCount = 0,
    this.unpricedCount = 0,
  });

  static const zero = CollectionValue();

  /// Σ prices ("Giá trị bộ sưu tập: 123.456 VP").
  final int totalVp;

  /// Skins that contributed a price.
  final int pricedCount;

  /// Of [pricedCount], priced with the tier fallback (show "≈").
  final int estimatedCount;

  /// Reward skins excluded ("Không tính skin phần thưởng").
  final int rewardCount;

  /// Skins without any price (unknown content / tier).
  final int unpricedCount;

  /// Real skins considered (Standard / Random-favorite never are).
  int get skinCount => pricedCount + rewardCount + unpricedCount;

  bool get isEstimate => estimatedCount > 0;
}

/// Resolves skin prices through the B9 chain. Pure and synchronous; get it
/// from [priceServiceProvider] (rebuilt whenever an input changes).
class PriceService {
  PriceService({
    required this.db,
    this.table = PriceTable.empty,
    this._observed = const {},
    this._offers = const {},
    RewardSourceIndex? rewards,
  }) : rewards = rewards ?? RewardSourceIndex.fromContent(db);

  final ContentDb db;
  final PriceTable table;
  final RewardSourceIndex rewards;
  final Map<String, int> _observed;
  final Map<String, int> _offers;

  /// Price of the skin of a skin, level or chroma uuid.
  PriceQuote priceForSkin(String skinOrLevelUuid) {
    final raw = skinOrLevelUuid.trim().toLowerCase();
    final skin = db.skinByAnyUuid(raw);
    if (skin != null && !skin.isCollectible) {
      return const PriceQuote.notForSale();
    }
    final keys = <String>[?skin?.level1Uuid, ?skin?.uuid, raw];
    int? find(Map<String, int> prices) {
      for (final k in keys) {
        if (prices[k] case final vp?) return vp;
      }
      return null;
    }

    if (find(table.prices) case final vp?) {
      return PriceQuote(vp: vp, source: PriceSource.table);
    }
    if (find(_observed) case final vp?) {
      return PriceQuote(vp: vp, source: PriceSource.observed);
    }
    if (find(_offers) case final vp?) {
      return PriceQuote(vp: vp, source: PriceSource.offers);
    }
    if (skin == null) return const PriceQuote.unknown();
    if (rewards.forSkin(skin) case final reward?) {
      return PriceQuote.reward(reward);
    }
    if (tierFallbackPrice(skin) case final vp?) {
      return PriceQuote(
        vp: vp,
        source: PriceSource.tierFallback,
        isEstimate: true,
      );
    }
    return const PriceQuote.unknown();
  }

  /// SUMMARY §7.3 fallback for [skin]'s edition (table override first),
  /// doubled for melee; `null` without a known tier.
  int? tierFallbackPrice(WeaponSkin skin) {
    final tier = db.contentTier(skin.contentTierUuid);
    if (tier == null) return null;
    final base = table.tierPrices[tier.uuid] ?? tier.fallbackPrice;
    if (base == null) return null;
    final isMelee =
        db.weapon(skin.weaponUuid)?.isMelee ??
        skin.weaponUuid == SpecialIds.melee;
    return isMelee ? (base * table.meleeMultiplier).round() : base;
  }

  /// Value of [skinUuids] (skin, level or chroma uuids; duplicates counted
  /// once). Standard / Random-favorite skins are skipped, reward skins are
  /// excluded and counted in [CollectionValue.rewardCount].
  CollectionValue collectionValue(Iterable<String> skinUuids) {
    var total = 0;
    var priced = 0;
    var estimated = 0;
    var rewardsCount = 0;
    var unpriced = 0;
    final seen = <String>{};
    for (final id in skinUuids) {
      final skin = db.skinByAnyUuid(id);
      if (skin != null && !skin.isCollectible) continue;
      if (!seen.add(skin?.uuid ?? id.trim().toLowerCase())) continue;
      final quote = priceForSkin(id);
      if (quote.isReward) {
        rewardsCount++;
      } else if (quote.vp case final vp?) {
        total += vp;
        priced++;
        if (quote.isEstimate) estimated++;
      } else {
        unpriced++;
      }
    }
    return CollectionValue(
      totalVp: total,
      pricedCount: priced,
      estimatedCount: estimated,
      rewardCount: rewardsCount,
      unpricedCount: unpriced,
    );
  }

  /// Value of every owned real skin (C8 footer).
  CollectionValue ownedCollectionValue(OwnedItems owned) =>
      collectionValue([for (final s in owned.ownedCollectibleSkins) s.uuid]);
}

/// The B9 price chain over the current content, table, observed and P-5
/// prices. Synchronous: before content loads every quote is
/// [PriceSource.unknown] (or exact when the uuid is in a price map).
///
/// ```dart
/// final quote = ref.watch(priceServiceProvider).priceForSkin(offer.skinLevelUuid);
/// quote.caption ?? (quote.isEstimate ? formatEstimatedVp(quote.vp!) : formatVp(quote.vp!))
/// ```
final priceServiceProvider = Provider<PriceService>((ref) {
  final db = ref.watch(contentProvider).value ?? ContentDb.empty();
  return PriceService(
    db: db,
    table: ref.watch(priceTableProvider).value ?? PriceTable.empty,
    observed: ref.watch(observedPricesProvider),
    offers: ref.watch(offerPricesProvider).value ?? const {},
    rewards: ref.watch(rewardSourceIndexProvider),
  );
});
