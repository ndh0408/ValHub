/// Typed storefront (P-1) and wallet (P-2) with their providers
/// (SUMMARY §8.2 B1–B6, §9.1, §9.2; EP §5.1, §5.2).
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/account_providers.dart';
import '../../riot/pvp_api.dart';
import '../../riot/riot_ids.dart';
import '../../util/clock.dart';
import '../../util/countdown.dart';
import '../../util/json.dart';
import 'economy_fetch.dart';
import 'prices.dart' show observedPricesProvider;
import 'store_history.dart';

/// `{currencyId: amount}` with lowercase currency ids.
typedef CostMap = Map<String, int>;

/// Parses a Riot cost map (`{"85ad13f7-…": 1775}`). Keys are lowercased,
/// amounts read as `num` and rounded; non-numeric entries are dropped.
CostMap parseCostMap(Object? json) {
  final m = asMap(json);
  if (m == null) return const {};
  return Map.unmodifiable(<String, int>{
    for (final e in m.entries)
      if (lowerUuid(e.key) case final id?)
        if (asNum(e.value) case final n? when n.isFinite) id: n.round(),
  });
}

/// All-zero uuid Riot uses for "none".
const _zeroUuid = '00000000-0000-0000-0000-000000000000';

String? _id(Object? value) {
  final id = lowerUuid(value);
  return (id == null || id == _zeroUuid) ? null : id;
}

/// One granted item of an offer (`Rewards[]` / bundle `Item`).
@immutable
class StoreItem {
  const StoreItem({
    required this.itemTypeId,
    required this.itemId,
    this.quantity = 1,
  });

  /// Parses `{ItemTypeID, ItemID, Quantity | Amount}`; `null` without an
  /// `ItemID`.
  static StoreItem? fromJson(Object? json) {
    final m = asMap(json);
    final itemId = _id(m?['ItemID']);
    if (m == null || itemId == null) return null;
    return StoreItem(
      itemTypeId: lowerUuid(m['ItemTypeID']) ?? '',
      itemId: itemId,
      quantity: math.max(1, asInt(m['Quantity'] ?? m['Amount']) ?? 1),
    );
  }

  /// `ItemTypeIds.*` (lowercase; `''` when missing).
  final String itemTypeId;

  /// Level uuid for skins and buddies, item uuid otherwise.
  final String itemId;
  final int quantity;

  bool get isSkinLevel => itemTypeId == ItemTypeIds.skinLevel;

  @override
  bool operator ==(Object other) =>
      other is StoreItem &&
      other.itemTypeId == itemTypeId &&
      other.itemId == itemId &&
      other.quantity == quantity;

  @override
  int get hashCode => Object.hash(itemTypeId, itemId, quantity);

  @override
  String toString() => 'StoreItem($itemTypeId, $itemId x$quantity)';
}

/// A Riot `Offer` (`{OfferID, IsDirectPurchase, StartDate, Cost, Rewards}`).
@immutable
class StoreOffer {
  const StoreOffer({
    required this.offerId,
    this.cost = const {},
    this.rewards = const [],
    this.isDirectPurchase = true,
    this.startDate,
  });

  /// `null` when neither `OfferID` nor a reward is present.
  static StoreOffer? fromJson(Object? json) {
    final m = asMap(json);
    if (m == null) return null;
    final rewards = [
      for (final r in asList(m['Rewards'])) ?StoreItem.fromJson(r),
    ];
    final offerId = _id(m['OfferID']) ?? rewards.firstOrNull?.itemId;
    if (offerId == null) return null;
    return StoreOffer(
      offerId: offerId,
      cost: parseCostMap(m['Cost']),
      rewards: List.unmodifiable(rewards),
      isDirectPurchase: asBool(m['IsDirectPurchase']) ?? true,
      startDate: asDateTime(m['StartDate']),
    );
  }

  final String offerId;
  final CostMap cost;
  final List<StoreItem> rewards;
  final bool isDirectPurchase;
  final DateTime? startDate;

  StoreItem? get firstReward => rewards.firstOrNull;

  /// Price in [currencyId], `null` when the offer is not sold in it.
  int? costIn(String currencyId) => cost[currencyId.toLowerCase()];

  int? get vpCost => cost[CurrencyIds.vp];

  /// The granted item (first reward), or the offer id itself for skins
  /// (daily and Night Market offer ids are the level-1 uuid).
  String get itemId => firstReward?.itemId ?? offerId;
}

// ------------------------------------------------------------------- daily

/// One daily-shop skin (B1).
@immutable
class DailyOffer {
  const DailyOffer({required this.offer, required this.skinLevelUuid});

  final StoreOffer offer;

  /// Level-1 skin uuid (`ContentDb.skinByLevelUuid`).
  final String skinLevelUuid;

  /// VP price (`null` when Riot only sent the id list).
  int? get vpCost => offer.vpCost;
}

/// `SkinsPanelLayout` (B1).
@immutable
class DailyStore {
  const DailyStore({this.offers = const [], this.expiresAt});

  static const empty = DailyStore();

  factory DailyStore.fromJson(Object? json, {required DateTime receivedAt}) {
    final m = asMap(json);
    if (m == null) return empty;
    final offers = <DailyOffer>[];
    final seen = <String>{};
    for (final raw in asList(m['SingleItemStoreOffers'])) {
      final offer = StoreOffer.fromJson(raw);
      if (offer == null) continue;
      final level = offer.itemId;
      if (seen.add(level)) {
        offers.add(DailyOffer(offer: offer, skinLevelUuid: level));
      }
    }
    // Older/trimmed payloads: only the id list, no prices.
    if (offers.isEmpty) {
      for (final raw in asList(m['SingleItemOffers'])) {
        final level = _id(raw);
        if (level == null || !seen.add(level)) continue;
        offers.add(
          DailyOffer(
            offer: StoreOffer(
              offerId: level,
              rewards: [
                StoreItem(itemTypeId: ItemTypeIds.skinLevel, itemId: level),
              ],
            ),
            skinLevelUuid: level,
          ),
        );
      }
    }
    return DailyStore(
      offers: List.unmodifiable(offers),
      expiresAt: expiresAtFrom(
        m['SingleItemOffersRemainingDurationInSeconds'],
        receivedAt,
      ),
    );
  }

  final List<DailyOffer> offers;

  /// Next daily reset (`receivedAt + SingleItemOffersRemainingDurationInSeconds`).
  final DateTime? expiresAt;

  /// Σ known VP prices ("Tổng 7.775 VP").
  int get totalVp => offers.fold(0, (sum, o) => sum + (o.vpCost ?? 0));

  /// How many of the daily skins [walletVp] can pay **all at once**
  /// ([maxAffordableTogether] over the offers whose price is known).
  int affordableTogether(int walletVp) =>
      maxAffordableTogether([for (final o in offers) ?o.vpCost], walletVp);

  bool get isEmpty => offers.isEmpty;
}

/// The largest number of [prices] that [wallet] can pay together (PR-04).
///
/// Buying the cheapest items first is optimal for the *count*, so the answer
/// is the longest prefix of the ascending prices whose sum fits in [wallet].
/// A wallet of 2,440 VP against 2,175 / 1,275 / 1,775 / 1,275 buys one skin
/// (1,275 + 1,275 = 2,550 > 2,440), not four. Non-positive prices and a
/// non-positive wallet count for nothing (an unknown price is never "free").
int maxAffordableTogether(Iterable<int> prices, int wallet) {
  if (wallet <= 0) return 0;
  final sorted = [
    for (final p in prices)
      if (p > 0) p,
  ]..sort();
  var left = wallet;
  var count = 0;
  for (final p in sorted) {
    if (p > left) break;
    left -= p;
    count++;
  }
  return count;
}

// ----------------------------------------------------------------- bundles

/// One item of a featured bundle (B4, S14).
@immutable
class BundleItem {
  const BundleItem({
    required this.item,
    required this.basePrice,
    required this.discountedPrice,
    required this.currencyId,
    this.discountFraction = 0,
    this.isPromoItem = false,
  });

  /// Parses a `Bundles[].Items[]` entry.
  static BundleItem? fromJson(Object? json, {required String currencyId}) {
    final m = asMap(json);
    final item = StoreItem.fromJson(m?['Item']);
    if (m == null || item == null) return null;
    final currency = lowerUuid(m['CurrencyID']) ?? currencyId;
    final base = asNum(m['BasePrice'])?.round() ?? 0;
    final fraction = _fraction(m['DiscountPercent']);
    final discounted =
        asNum(m['DiscountedPrice'])?.round() ?? (base * (1 - fraction)).round();
    return BundleItem(
      item: item,
      basePrice: base,
      discountedPrice: discounted,
      currencyId: currency,
      discountFraction: fraction,
      isPromoItem: asBool(m['IsPromoItem']) ?? false,
    );
  }

  /// Parses a `Bundles[].ItemOffers[]` entry (fallback when `Items` is
  /// missing).
  static BundleItem? fromItemOfferJson(
    Object? json, {
    required String currencyId,
  }) {
    final m = asMap(json);
    final offer = StoreOffer.fromJson(m?['Offer']);
    final item = offer?.firstReward;
    if (m == null || offer == null || item == null) return null;
    final base = offer.costIn(currencyId) ?? offer.cost.values.firstOrNull ?? 0;
    final fraction = _fraction(m['DiscountPercent']);
    final discounted =
        parseCostMap(m['DiscountedCost'])[currencyId] ??
        (base * (1 - fraction)).round();
    return BundleItem(
      item: item,
      basePrice: base,
      discountedPrice: discounted,
      currencyId: currencyId,
      discountFraction: fraction,
    );
  }

  final StoreItem item;

  /// Price when bought separately.
  final int basePrice;

  /// Price inside the bundle.
  final int discountedPrice;
  final String currencyId;

  /// `DiscountPercent` as a **fraction** (0.33 = 33 %, 1 = free; SUMMARY §9.2).
  final double discountFraction;
  final bool isPromoItem;

  /// Whole percent for badges ("-33%").
  int get discountPercent => (discountFraction * 100).round();

  bool get isDiscounted => discountedPrice < basePrice;

  /// "Miễn phí" inside the bundle.
  bool get isFree => discountedPrice <= 0 && basePrice > 0;
}

/// Bundle `DiscountPercent` is a fraction; tolerate a whole percent too.
double _fraction(Object? value) {
  final n = asNum(value);
  if (n == null || !n.isFinite || n <= 0) return 0;
  final f = n > 1 ? n / 100 : n.toDouble();
  return f.clamp(0.0, 1.0);
}

/// One featured bundle (`FeaturedBundle.Bundles[]`, B4).
@immutable
class StoreBundle {
  const StoreBundle({
    required this.id,
    required this.dataAssetId,
    required this.currencyId,
    required this.items,
    this.totalBaseCost,
    this.totalDiscountedCost,
    this.totalDiscountFraction = 0,
    this.expiresAt,
    this.wholesaleOnly = false,
  });

  /// `null` without an id / data asset id.
  static StoreBundle? fromJson(
    Object? json, {
    required DateTime receivedAt,
    DateTime? fallbackExpiresAt,
  }) {
    final m = asMap(json);
    if (m == null) return null;
    final dataAssetId = _id(m['DataAssetID']);
    final id = _id(m['ID']) ?? dataAssetId;
    if (id == null) return null;
    final currency = lowerUuid(m['CurrencyID']) ?? CurrencyIds.vp;
    var items = [
      for (final raw in asList(m['Items']))
        ?BundleItem.fromJson(raw, currencyId: currency),
    ];
    if (items.isEmpty) {
      items = [
        for (final raw in asList(m['ItemOffers']))
          ?BundleItem.fromItemOfferJson(raw, currencyId: currency),
      ];
    }
    return StoreBundle(
      id: id,
      dataAssetId: dataAssetId ?? id,
      currencyId: currency,
      items: List.unmodifiable(items),
      totalBaseCost: parseCostMap(m['TotalBaseCost'])[currency],
      totalDiscountedCost: parseCostMap(m['TotalDiscountedCost'])[currency],
      totalDiscountFraction: _fraction(m['TotalDiscountPercent']),
      expiresAt:
          expiresAtFrom(m['DurationRemainingInSeconds'], receivedAt) ??
          fallbackExpiresAt,
      wholesaleOnly: asBool(m['WholesaleOnly']) ?? false,
    );
  }

  /// Storefront bundle id (`ID`) — use it for routes (`StoreRoutes.bundle`).
  final String id;

  /// valorant-api bundle uuid (`ContentDb.bundleByUuid`).
  final String dataAssetId;
  final String currencyId;
  final List<BundleItem> items;

  /// Raw totals; may be `null` (SUMMARY §9.2) — use [price] / [itemsTotal].
  final int? totalBaseCost;
  final int? totalDiscountedCost;
  final double totalDiscountFraction;
  final DateTime? expiresAt;

  /// Items cannot be bought separately.
  final bool wholesaleOnly;

  /// "Giá bundle": `TotalDiscountedCost`, else Σ `DiscountedPrice`.
  int get price =>
      totalDiscountedCost ?? items.fold(0, (sum, i) => sum + i.discountedPrice);

  /// Whether [price] had to be computed from the items.
  bool get isPriceComputed => totalDiscountedCost == null;

  /// "Mua lẻ": Σ `BasePrice` (else `TotalBaseCost`).
  int get itemsTotal => items.isEmpty
      ? (totalBaseCost ?? price)
      : items.fold(0, (sum, i) => sum + i.basePrice);

  /// "Tiết kiệm": [itemsTotal] − [price], never negative.
  int get savings => math.max(0, itemsTotal - price);

  /// Whole-bundle discount in percent, from the prices.
  int get discountPercent =>
      itemsTotal <= 0 ? 0 : (savings * 100 / itemsTotal).round();

  Iterable<BundleItem> get skinItems => items.where((i) => i.item.isSkinLevel);
}

// ------------------------------------------------------------ night market

/// One Night Market card (B5, S11).
@immutable
class NightMarketOffer {
  const NightMarketOffer({
    required this.bonusOfferId,
    required this.offer,
    required this.skinLevelUuid,
    required this.discountPercent,
    this.basePrice,
    this.discountedPrice,
    this.isSeen = false,
  });

  static NightMarketOffer? fromJson(Object? json) {
    final m = asMap(json);
    final offer = StoreOffer.fromJson(m?['Offer']);
    if (m == null || offer == null) return null;
    final base = offer.vpCost ?? offer.cost.values.firstOrNull;
    final discountCosts = parseCostMap(m['DiscountCosts']);
    final discounted =
        discountCosts[CurrencyIds.vp] ?? discountCosts.values.firstOrNull;
    return NightMarketOffer(
      bonusOfferId: _id(m['BonusOfferID']) ?? offer.offerId,
      offer: offer,
      skinLevelUuid: offer.itemId,
      basePrice: base,
      discountedPrice: discounted,
      discountPercent: _nightMarketPercent(
        m['DiscountPercent'],
        base,
        discounted,
      ),
      isSeen: asBool(m['IsSeen']) ?? false,
    );
  }

  final String bonusOfferId;
  final StoreOffer offer;

  /// Level-1 skin uuid.
  final String skinLevelUuid;

  /// "Giá gốc" (`Offer.Cost[VP]`).
  final int? basePrice;

  /// "Giá ưu đãi" (`DiscountCosts[VP]`).
  final int? discountedPrice;

  /// Whole percent ("-22%"); Riot sends an **integer** here (SUMMARY §9.2).
  final int discountPercent;

  /// Card already revealed by the player in game.
  final bool isSeen;

  int get savings => (basePrice == null || discountedPrice == null)
      ? 0
      : math.max(0, basePrice! - discountedPrice!);
}

int _nightMarketPercent(Object? raw, int? base, int? discounted) {
  final n = asNum(raw);
  if (n != null && n.isFinite && n > 0) {
    // Defensive: a fraction (0.22) instead of an integer percent.
    return (n < 1 ? n * 100 : n).round().clamp(0, 100);
  }
  if (base != null && discounted != null && base > 0) {
    return ((1 - discounted / base) * 100).round().clamp(0, 100);
  }
  return 0;
}

/// `BonusStore` (B5). Only present while a Night Market runs.
@immutable
class NightMarket {
  const NightMarket({required this.offers, this.expiresAt});

  /// `null` when the key is absent or has no offers.
  static NightMarket? fromJson(Object? json, {required DateTime receivedAt}) {
    final m = asMap(json);
    if (m == null) return null;
    final offers = [
      for (final raw in asList(m['BonusStoreOffers']))
        ?NightMarketOffer.fromJson(raw),
    ];
    if (offers.isEmpty) return null;
    return NightMarket(
      offers: List.unmodifiable(offers),
      expiresAt: expiresAtFrom(
        m['BonusStoreRemainingDurationInSeconds'],
        receivedAt,
      ),
    );
  }

  final List<NightMarketOffer> offers;
  final DateTime? expiresAt;

  /// "Tiết kiệm tổng cộng …".
  int get totalSavings => offers.fold(0, (sum, o) => sum + o.savings);

  /// Red dot on the segment until every card has been revealed.
  bool get hasUnseen => offers.any((o) => !o.isSeen);
}

// --------------------------------------------------------------- accessory

/// One Kingdom Credits offer (B3, S12).
@immutable
class AccessoryOffer {
  const AccessoryOffer({required this.offer, this.contractId});

  static AccessoryOffer? fromJson(Object? json) {
    final m = asMap(json);
    final offer = StoreOffer.fromJson(m?['Offer']);
    if (m == null || offer == null) return null;
    return AccessoryOffer(offer: offer, contractId: _id(m['ContractID']));
  }

  final StoreOffer offer;

  /// Contract the item comes from ("Từ Battle Pass …"); `null` when none.
  final String? contractId;

  StoreItem? get item => offer.firstReward;

  /// `ItemTypeIds.*` of the item ("Hình phun sơn", "Thẻ người chơi"…).
  String? get itemTypeId => item?.itemTypeId;
  String get itemId => offer.itemId;

  int? get kcCost => offer.costIn(CurrencyIds.kc);
}

/// `AccessoryStore` (B3). `AccessoryStoreOffers` may be `null`.
@immutable
class AccessoryStore {
  const AccessoryStore({
    this.offers = const [],
    this.expiresAt,
    this.storefrontId,
  });

  static AccessoryStore? fromJson(
    Object? json, {
    required DateTime receivedAt,
  }) {
    final m = asMap(json);
    if (m == null) return null;
    return AccessoryStore(
      offers: List.unmodifiable([
        for (final raw in asList(m['AccessoryStoreOffers']))
          ?AccessoryOffer.fromJson(raw),
      ]),
      expiresAt: expiresAtFrom(
        m['AccessoryStoreRemainingDurationInSeconds'],
        receivedAt,
      ),
      storefrontId: _id(m['StorefrontID']),
    );
  }

  final List<AccessoryOffer> offers;
  final DateTime? expiresAt;
  final String? storefrontId;
}

// -------------------------------------------------------------- storefront

/// The whole P-1 response, typed.
@immutable
class Storefront {
  const Storefront({
    required this.receivedAt,
    this.daily = DailyStore.empty,
    this.bundles = const [],
    this.nightMarket,
    this.accessoryStore,
    this.isFromCache = false,
  });

  /// Parses a storefront v3 body. Never throws; a non-map yields an empty
  /// storefront.
  factory Storefront.fromJson(
    Object? json, {
    required DateTime receivedAt,
    bool isFromCache = false,
  }) {
    final m = asMap(json) ?? const <String, dynamic>{};
    final featured = asMap(m['FeaturedBundle']) ?? const <String, dynamic>{};
    final fallbackExpiry = expiresAtFrom(
      featured['BundleRemainingDurationInSeconds'],
      receivedAt,
    );
    final bundles = <StoreBundle>[];
    final ids = <String>{};
    void add(Object? raw) {
      final b = StoreBundle.fromJson(
        raw,
        receivedAt: receivedAt,
        fallbackExpiresAt: fallbackExpiry,
      );
      if (b != null && ids.add(b.id)) bundles.add(b);
    }

    // Render ALL bundles; `Bundle` (headline, often without totals) is only
    // a fallback when `Bundles` is missing.
    for (final raw in asList(featured['Bundles'])) {
      add(raw);
    }
    if (bundles.isEmpty) add(featured['Bundle']);

    return Storefront(
      receivedAt: receivedAt,
      daily: DailyStore.fromJson(m['SkinsPanelLayout'], receivedAt: receivedAt),
      bundles: List.unmodifiable(bundles),
      nightMarket: NightMarket.fromJson(
        m['BonusStore'],
        receivedAt: receivedAt,
      ),
      accessoryStore: AccessoryStore.fromJson(
        m['AccessoryStore'],
        receivedAt: receivedAt,
      ),
      isFromCache: isFromCache,
    );
  }

  /// When the response was received (for a cached copy: originally).
  final DateTime receivedAt;
  final DailyStore daily;
  final List<StoreBundle> bundles;

  /// `null` when no Night Market is running (hide the segment, B6).
  final NightMarket? nightMarket;
  final AccessoryStore? accessoryStore;

  /// Served from the offline cache after a transient failure (X4): show
  /// "Cập nhật lúc …" (`formatUpdatedAt(receivedAt, now)`).
  final bool isFromCache;

  bool get hasNightMarket => nightMarket != null;

  StoreBundle? bundleById(String id) {
    final k = id.toLowerCase();
    for (final b in bundles) {
      if (b.id == k || b.dataAssetId == k) return b;
    }
    return null;
  }

  /// Every countdown in the response.
  Iterable<DateTime> get deadlines sync* {
    if (daily.expiresAt case final d?) yield d;
    for (final b in bundles) {
      if (b.expiresAt case final d?) yield d;
    }
    if (nightMarket?.expiresAt case final d?) yield d;
    if (accessoryStore?.expiresAt case final d?) yield d;
  }

  /// Earliest countdown still in the future at [now] (when the storefront
  /// must be refetched, SUMMARY §9.1); `null` when none is left.
  DateTime? nextRefreshAt(DateTime now) =>
      earliest(deadlines.where((d) => d.isAfter(now)));

  /// Full VP prices of skin levels seen in this storefront (B9 "prices seen
  /// in the live store"): daily cost, Night Market `Offer.Cost` (not the
  /// discounted price) and bundle `BasePrice`.
  Map<String, int> observedSkinPrices() {
    final out = <String, int>{};
    void put(String levelUuid, int? vp) {
      if (vp != null && vp > 0) out[levelUuid] = vp;
    }

    for (final o in daily.offers) {
      put(o.skinLevelUuid, o.vpCost);
    }
    for (final o in nightMarket?.offers ?? const <NightMarketOffer>[]) {
      if (o.offer.firstReward?.isSkinLevel ?? true) {
        put(o.skinLevelUuid, o.offer.vpCost);
      }
    }
    for (final b in bundles) {
      for (final i in b.skinItems) {
        if (i.currencyId == CurrencyIds.vp) put(i.item.itemId, i.basePrice);
      }
    }
    return out;
  }
}

// ------------------------------------------------------------------ wallet

/// P-2 balances (B2). A missing currency is 0.
@immutable
class Wallet {
  const Wallet({
    required this.balances,
    required this.receivedAt,
    this.isFromCache = false,
  });

  factory Wallet.fromJson(
    Object? json, {
    required DateTime receivedAt,
    bool isFromCache = false,
  }) => Wallet(
    balances: parseCostMap(asMap(json)?['Balances']),
    receivedAt: receivedAt,
    isFromCache: isFromCache,
  );

  /// `{currencyId: amount}`, lowercase ids.
  final Map<String, int> balances;
  final DateTime receivedAt;
  final bool isFromCache;

  int balance(String currencyId) => balances[currencyId.toLowerCase()] ?? 0;

  int get vp => balance(CurrencyIds.vp);
  int get kc => balance(CurrencyIds.kc);
  int get rp => balance(CurrencyIds.rp);
  int get agentTokens => balance(CurrencyIds.agentTokens);
}

// --------------------------------------------------------------- providers

/// How long a wallet stays cached (SUMMARY §10: 5 min).
const kWalletTtl = Duration(minutes: 5);

/// Storefront of one signed-in account (P-1).
///
/// - Cached until its earliest countdown (daily reset, bundle end, Night
///   Market end, accessory rotation) expires, then refetched automatically
///   while listened (SUMMARY §9.1, §10).
/// - Refetches after a re-login.
/// - On a transient failure serves the last stored copy (X4,
///   `Storefront.isFromCache`) and retries after ~60 s.
/// - Records full prices it sees for the price chain (B9).
///
/// ```dart
/// final store = ref.watch(storefrontProvider(puuid));
/// ```
final storefrontProvider = FutureProvider.autoDispose
    .family<Storefront, String>((ref, puuid) async {
      ref.watch(accountProvider(puuid).select((a) => a?.needsLogin));
      final api = ref.watch(pvpApiProvider);
      final fetched = await fetchWithOfflineCache(
        ref,
        puuid: puuid,
        name: 'storefront',
        fetch: () => api.storefront(puuid),
      );
      final storefront = Storefront.fromJson(
        fetched.data,
        receivedAt: fetched.receivedAt,
        isFromCache: fetched.isFromCache,
      );
      if (!ref.mounted) return storefront;
      final now = ref.read(clockProvider).now();
      if (fetched.cachedAfter case final error?) {
        scheduleProviderRefresh(
          ref,
          now.add(offlineRetryDelay(error)),
          now: now,
        );
        return storefront;
      }
      scheduleProviderRefresh(ref, storefront.nextRefreshAt(now), now: now);
      await recordStoreHistoryFor(ref, puuid, storefront, fetched.receivedAt);
      await ref
          .read(observedPricesProvider.notifier)
          .record(storefront.observedSkinPrices());
      return storefront;
    });

/// Wallet of one signed-in account (P-2), cached for [kWalletTtl] and
/// refetched after that while listened. Offline copy on transient failures.
///
/// ```dart
/// final vp = ref.watch(walletProvider(puuid)).value?.vp;
/// ```
final walletProvider = FutureProvider.autoDispose.family<Wallet, String>((
  ref,
  puuid,
) async {
  ref.watch(accountProvider(puuid).select((a) => a?.needsLogin));
  final api = ref.watch(pvpApiProvider);
  final fetched = await fetchWithOfflineCache(
    ref,
    puuid: puuid,
    name: 'wallet',
    fetch: () => api.wallet(puuid),
  );
  final wallet = Wallet.fromJson(
    fetched.data,
    receivedAt: fetched.receivedAt,
    isFromCache: fetched.isFromCache,
  );
  if (!ref.mounted) return wallet;
  final now = ref.read(clockProvider).now();
  final retry = fetched.cachedAfter;
  scheduleProviderRefresh(
    ref,
    now.add(retry == null ? kWalletTtl : offlineRetryDelay(retry)),
    now: now,
  );
  return wallet;
});
