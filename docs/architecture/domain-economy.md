# Economy domain: `lib/core/domain/economy/`

Shared, UI-free layer for the **store**, **skin detail**, **wishlist** and **collection**
features. It sits on top of the core APIs (`PvpApi`, `ContentDb`, `Prefs`,
`JsonFileCache`, `clockProvider`, `RiotException`) and changes none of them.

```dart
import 'package:valvn/core/domain/economy/economy.dart';   // everything below
```

References: SUMMARY §7.1–§7.3, §8.2–§8.3 (B1–B9, W1–W7, C4–C9), §9.1–§9.3, §10, U4;
EP §5.1–§5.3, §6.1; CA §12–§13; VF §6.2, §6.4, §8.2–§8.6.

| File | Contents |
|---|---|
| `storefront.dart` | `Storefront` (P-1), `Wallet` (P-2), `storefrontProvider`, `walletProvider` |
| `owned_items.dart` | `Entitlements` (P-3), `OwnedItems`, `DefaultItemIds`, `entitlementsProvider`, `ownedItemsProvider` |
| `prices.dart` | `PriceService` (B9 chain), `PriceQuote`, `PriceSource`, `CollectionValue`, `PriceTable`, `ObservedPriceStore`, `OffersPriceCache`, providers |
| `reward_sources.dart` | `RewardSourceIndex`, `RewardSourceEntry`, `rewardSourceIndexProvider` |
| `wishlist.dart` | re-exports `core/wishlist/wishlist_store.dart`; `findWishlistHits`, `WishlistHit`, `WishlistPlace`, `wishlistHitsProvider`, uuid helpers |
| `economy_strings.dart` | `EconomyStrings` (place names, price-source captions, value labels) |
| `economy_fetch.dart` | internal plumbing, **not** exported: bounded concurrency, offline cache, refresh timers |
| `assets/data/prices.json` | bundled price table (see §4.3) |

All parsers are pure, never throw, lowercase every uuid and read numbers as `num`.
Every provider is keyed by the **signed-in account's PUUID**, refetches after a
re-login and only ever throws `RiotException` subtypes.

---

## 1. Providers at a glance

| Provider | Type | Cache / refresh |
|---|---|---|
| `storefrontProvider(puuid)` | `FutureProvider.autoDispose.family<Storefront, String>` | kept until the earliest countdown (daily reset, bundle end, Night Market end, accessory rotation), then refetched while listened; min. 10 s between fetches |
| `walletProvider(puuid)` | `FutureProvider.autoDispose.family<Wallet, String>` | 5 min (`kWalletTtl`), then refetched while listened |
| `entitlementsProvider(puuid)` | `FutureProvider.autoDispose.family<Entitlements, String>` | kept 10 min after the last listener (`kEntitlementsTtl`); invalidate after a loadout PUT or on focus |
| `ownedItemsProvider(puuid)` | `FutureProvider.autoDispose.family<OwnedItems, String>` | entitlements resolved with the current content (language switch re-resolves, no refetch) |
| `wishlistHitsProvider(puuid)` | `FutureProvider.autoDispose.family<List<WishlistHit>, String>` | recomputed when the wishlist, storefront or content changes |
| `priceServiceProvider` | `Provider<PriceService>` | rebuilt when content, price table, observed or P-5 prices change |
| `rewardSourceIndexProvider` | `Provider<RewardSourceIndex>` | follows `contentProvider` (empty until it loads) |
| `observedPricesProvider` | `NotifierProvider<ObservedPricesNotifier, Map<String,int>>` | fed by `storefrontProvider` |
| `priceTableProvider` | `FutureProvider<PriceTable>` | bundled asset + remote-config `prices` block |
| `offerPricesProvider` | `FutureProvider<Map<String,int>>` | P-5, only with flag `use_offers_endpoint`; ≤ 1 call / 24 h, disabled 24 h after a failure |
| `priceAssetLoaderProvider` | `Provider<Future<String> Function()>` | override in tests |

**Offline copies (X4).** `storefrontProvider`, `walletProvider` and
`entitlementsProvider` store every successful payload under
`JsonFileCache.accountKey(puuid, 'economy_<name>')` (wiped at sign-out). On a
`TransientException` they return that copy with `isFromCache == true` and
`receivedAt` = the original time, and retry after the server's `Retry-After`
(clamped to 30 s … 10 min, default 60 s). `NeedsLoginException`,
`MaintenanceException` and 4xx always propagate, so `AsyncValueView` shows
"Đăng nhập lại" and the other error states.

```dart
final account = ref.watch(activeAccountProvider)!;
final store = ref.watch(storefrontProvider(account.puuid));
return AsyncValueView(
  value: store,
  puuid: account.puuid,
  onRetry: () => ref.invalidate(storefrontProvider(account.puuid)),
  data: (s) => Column(children: [
    if (s.isFromCache) Text(formatUpdatedAt(s.receivedAt, now)),   // "Cập nhật lúc 14:05"
    DailyGrid(s.daily),
  ]),
);
// pull-to-refresh
TabPageScaffold(onRefresh: () => ref.refresh(storefrontProvider(puuid).future), …);
```

Tests: build containers with `ProviderContainer.test(retry: (_, _) => null, …)`,
override `pvpApiProvider`, `prefsProvider`, `jsonFileCacheProvider`,
`clockProvider`, `contentProvider`, and
`accountProvider.overrideWith((ref, puuid) => null)`. Keep auto-dispose providers
listened while awaiting them (`container.listen(p.future, (_, _) {})`).

---

## 2. Storefront and wallet — `storefront.dart`

```dart
typedef CostMap = Map<String, int>;                 // lowercase currency id → amount
CostMap parseCostMap(Object? json);

class StoreItem  { String itemTypeId; String itemId; int quantity; bool get isSkinLevel; }
class StoreOffer { String offerId; CostMap cost; List<StoreItem> rewards; bool isDirectPurchase;
                   DateTime? startDate; StoreItem? get firstReward; int? costIn(String currencyId);
                   int? get vpCost; String get itemId; }

class Storefront {
  factory Storefront.fromJson(Object? json, {required DateTime receivedAt, bool isFromCache = false});
  DateTime receivedAt; bool isFromCache;
  DailyStore daily;                    // never null (DailyStore.empty)
  List<StoreBundle> bundles;           // ALL of FeaturedBundle.Bundles (headline `Bundle` only as fallback)
  NightMarket? nightMarket;            // null = no Night Market → hide the segment (B6)
  AccessoryStore? accessoryStore;
  bool get hasNightMarket;
  StoreBundle? bundleById(String idOrDataAssetId);
  Iterable<DateTime> get deadlines;
  DateTime? nextRefreshAt(DateTime now);          // earliest future countdown
  Map<String, int> observedSkinPrices();          // full VP prices seen (B9)
}

class DailyStore { List<DailyOffer> offers; DateTime? expiresAt; int get totalVp; bool get isEmpty; }
class DailyOffer { StoreOffer offer; String skinLevelUuid; int? get vpCost; }   // vpCost null if Riot sent ids only

class StoreBundle {
  String id;                 // storefront bundle ID → StoreRoutes.bundle(id)
  String dataAssetId;        // valorant-api bundle → db.bundleByUuid(dataAssetId)
  String currencyId; List<BundleItem> items; DateTime? expiresAt; bool wholesaleOnly;
  int? totalBaseCost; int? totalDiscountedCost; double totalDiscountFraction;   // raw, may be null
  int get price;             // "Giá bundle": TotalDiscountedCost ?? Σ DiscountedPrice (SUMMARY §9.2)
  bool get isPriceComputed;
  int get itemsTotal;        // "Mua lẻ": Σ BasePrice
  int get savings;           // "Tiết kiệm"
  int get discountPercent;
  Iterable<BundleItem> get skinItems;
}
class BundleItem { StoreItem item; int basePrice; int discountedPrice; String currencyId;
                   double discountFraction;          // FRACTION: 0.33 = 33 %, 1 = free
                   bool isPromoItem; int get discountPercent; bool get isDiscounted; bool get isFree; }

class NightMarket { List<NightMarketOffer> offers; DateTime? expiresAt; int get totalSavings; bool get hasUnseen; }
class NightMarketOffer { String bonusOfferId; StoreOffer offer; String skinLevelUuid;
                         int? basePrice;             // "Giá gốc" = Offer.Cost[VP]
                         int? discountedPrice;       // "Giá ưu đãi" = DiscountCosts[VP]
                         int discountPercent;        // INTEGER percent (22 → "-22%")
                         bool isSeen; int get savings; }

class AccessoryStore { List<AccessoryOffer> offers; DateTime? expiresAt; String? storefrontId; }
class AccessoryOffer { StoreOffer offer; String? contractId;   // "Từ …" (null when none / all-zero)
                       StoreItem? get item; String? get itemTypeId; String get itemId; int? get kcCost; }

class Wallet { Map<String,int> balances; DateTime receivedAt; bool isFromCache;
               int balance(String currencyId);   // missing = 0
               int get vp, kc, rp, agentTokens; }
```

Examples:

```dart
final db = ref.watch(contentProvider).value ?? ContentDb.empty();
for (final o in store.daily.offers) {
  final skin = db.skinByLevelUuid(o.skinLevelUuid);          // name, art, tier
  CountdownText(expiresAt: store.daily.expiresAt!, builder: StoreStrings.resetsIn,
      onExpired: () => ref.invalidate(storefrontProvider(puuid)));   // optional: the provider refreshes itself
}
final nm = store.nightMarket;            // S11: formatDiscountPercent(o.discountPercent), o.basePrice struck through
final bundle = store.bundleById(id)!;    // S14 summary: bundle.price / bundle.itemsTotal / bundle.savings
final type = db.item(offer.itemTypeId ?? '', offer.itemId)?.typeLabel;   // S12 row
final from = offer.contractId == null ? null : db.contract(offer.contractId!)?.displayName;
final wallet = ref.watch(walletProvider(puuid)).value;   // header pill: wallet?.vp, .kc, .rp
```

Store reset reminders (B8) stay in the store feature: re-schedule from
`store.daily.expiresAt` after each fetch (ARCHITECTURE §5.8).

---

## 3. Owned items — `owned_items.dart`

```dart
abstract final class DefaultItemIds {       // owned by every account (CA §6)
  static const playerCard = '9fb348bc-…';   // "Thẻ VALORANT"
  static const spray = '0a6db78c-…';        // "Hình Phun Sơn VALORANT"   (+ SpecialIds.nullSpray)
  static const flex = 'af52b5a0-…';         // "Flex STAT-COM"
  static const title = SpecialIds.noTitle;
}

class EntitlementRow { String itemTypeId; String itemId; String? instanceId; }

class Entitlements {
  factory Entitlements.fromJson(Object? json, {required DateTime receivedAt, String? itemTypeId, bool isFromCache});
  factory Entitlements.fromTypeResponses(Map<String, Object?> responsesByType, {required DateTime receivedAt, …});
  factory Entitlements.fromRows(Iterable<EntitlementRow> rows, {required DateTime receivedAt, …});
  factory Entitlements.empty({DateTime? receivedAt});
  static List<EntitlementRow> parseRows(Object? json, {String? requestedItemTypeId});  // both P-3 shapes
  Set<String> itemsOfType(String itemTypeId); bool contains(String itemTypeId, String itemId);
  List<String> buddyInstanceIds(String buddyLevelUuid); int buddyCopies(String buddyLevelUuid);
  DateTime receivedAt; bool isFromCache; int get length;
}

class OwnedItems {
  factory OwnedItems.resolve(Entitlements entitlements, ContentDb db);
  // skins (any skin / level / chroma uuid)
  bool isSkinOwned(String skinOrLevelOrChromaUuid);   // Standard + Random favorite always true
  bool isSkinLevelOwned(String levelUuid);            // owning level N implies 1…N
  bool isChromaOwned(String chromaUuid);              // base chroma comes with the skin
  List<SkinLevel> ownedLevels(WeaponSkin skin);
  List<SkinChroma> ownedChromas(WeaponSkin skin);
  Set<String> get ownedSkinUuids;                     // incl. Standard / Random favorite
  List<WeaponSkin> get ownedCollectibleSkins;         // real skins only (collection value, S39)
  List<WeaponSkin> ownedSkinsForWeapon(String weaponUuid);   // Standard first (S34)
  Set<String> get unknownSkinLevels;                  // → contentMissReporterProvider.report()
  // buddies (LEVEL uuid or buddy uuid)
  List<String> buddyInstances(String buddyOrLevelUuid);      // CharmInstanceID candidates
  int buddyCount(String buddyOrLevelUuid); bool isBuddyOwned(String buddyOrLevelUuid);
  Set<String> get buddyLevelUuids;
  // other cosmetics (defaults included)
  Set<String> get sprayUuids, playerCardUuids, titleUuids, flexUuids, agentUuids;
  bool isSprayOwned(String), isPlayerCardOwned(String), isTitleOwned(String), isFlexOwned(String), isAgentOwned(String);
  // contracts
  Set<String> get premiumContracts; bool hasPremiumContract(String contractUuid);
  // any ItemTypeID + ItemID (bundle items, accessory offers, contract rewards)
  bool owns(String itemTypeId, String itemId);
  DateTime get receivedAt; bool get isFromCache;
}
```

`entitlementsProvider` makes one P-3 call per type in
`ItemTypeIds.collectionTypes` (9 types, what the client does), **at most 3 in
flight**, and stops starting new calls after a failure. A `404` for a type counts
as empty; any other failure fails the whole fetch (a partial collection would
show owned items as locked), preferring `NeedsLoginException`, then
`MaintenanceException`.

```dart
final owned = ref.watch(ownedItemsProvider(puuid)).value;
final isOwned = owned?.isSkinOwned(offer.skinLevelUuid) ?? false;         // "Đã sở hữu" badge
final premium = owned?.hasPremiumContract(bp.uuid) ?? false;              // P1
final free = owned == null ? 0 : owned.buddyInstances(levelUuid).length   // "Còn n/m" (S36)
    - usedInstanceIds.length;
// after a loadout PUT: ref.invalidate(entitlementsProvider(puuid));
```

---

## 4. Prices — `prices.dart`

### 4.1 Chain (B9)

1. **Price table** (`PriceSource.table`, exact): bundled `assets/data/prices.json`,
   overridden entry by entry by the `prices` block of the cached remote config
   (X-4; applied at next launch like the rest of the remote config).
2. **Observed** (`observed`, exact): full prices seen in live storefronts — daily
   cost, Night Market `Offer.Cost` (not the discounted price), bundle `BasePrice`.
   Persisted app-wide in prefs (`f.economy.observedPrices`, ≤ 4000 entries).
3. **P-5 offers** (`offers`, exact): only with remote flag `use_offers_endpoint`
   (default off), fetched with the active account at most once per 24 h, disabled
   24 h after any failure or an empty list (SUMMARY U4).
4. **Reward skins** (`reward`): battle pass / agent contract / event pass items are
   never sold → no price, `caption` = source label (C9).
5. **Tier fallback** (`tierFallback`, **estimate**): SUMMARY §7.3 edition price
   (table `tierPrices` override first); melee × `meleeMultiplier` (2).

Standard / Random-favorite skins → `notForSale`; unknown skins without an exact
price → `unknown`.

### 4.2 API

```dart
enum PriceSource { table, observed, offers, tierFallback, reward, notForSale, unknown;  String get label; }

class PriceQuote {
  int? vp; PriceSource source; bool isEstimate; RewardSourceEntry? reward;
  bool get hasPrice; bool get isReward;
  String? get caption;   // "Phần thưởng Battle Pass" / "Hợp đồng đặc vụ" / "Vé sự kiện" / "Không bán", else null
}

class PriceService {
  PriceService({required ContentDb db, PriceTable table, Map<String,int> observed,
                Map<String,int> offers, RewardSourceIndex? rewards});
  PriceQuote priceForSkin(String skinOrLevelUuid);     // skin, level or chroma uuid
  int? tierFallbackPrice(WeaponSkin skin);
  CollectionValue collectionValue(Iterable<String> skinUuids);   // dedupes, skips Standard, excludes rewards
  CollectionValue ownedCollectionValue(OwnedItems owned);        // C8 footer
}

class CollectionValue { int totalVp, pricedCount, estimatedCount, rewardCount, unpricedCount;
                        int get skinCount; bool get isEstimate; static const zero; }

class PriceTable { Map<String,int> prices, tierPrices; double meleeMultiplier; String? updatedAt;
                   factory PriceTable.fromJson(Object?); factory PriceTable.fromRemoteConfig(Object?);
                   static Map<String,int> parsePriceMap(Object?); PriceTable merge(PriceTable other); }

class ObservedPriceStore { ObservedPriceStore(Prefs); Map<String,int> read();
                           Future<Map<String,int>?> record(Map<String,int> prices); }   // background isolates
class OffersPriceCache   { OffersPriceCache(Prefs); Map<String,int> read(); bool shouldFetch(DateTime now);
                           Future<void> saveSuccess(Map<String,int>, DateTime); Future<void> saveFailure(DateTime);
                           static Map<String,int> parseOffers(Object? json); }
```

```dart
final prices = ref.watch(priceServiceProvider);
final q = prices.priceForSkin(skin.uuid);
final text = q.caption ??
    (q.vp == null ? CommonStrings.dash : (q.isEstimate ? formatEstimatedVp(q.vp!) : formatVp(q.vp!)));
// or: CurrencyAmount.vp(q.vp!, estimate: q.isEstimate)

// C8 / S39 / W7
final owned = ref.watch(ownedItemsProvider(puuid)).value;
final value = owned == null ? CollectionValue.zero : prices.ownedCollectionValue(owned);
// "Giá trị bộ sưu tập: ${formatVp(value.totalVp)}"  + EconomyStrings.excludedRewards when value.rewardCount > 0
final filtered = prices.collectionValue(visibleSkins.map((s) => s.uuid));   // "Đang lọc: …"
final wishlistValue = prices.collectionValue(ref.watch(wishlistProvider(puuid)));
```

Background isolates (no Riverpod):
`ObservedPriceStore(ctx.prefs).record(storefront.observedSkinPrices())`.

### 4.3 `assets/data/prices.json`

```json
{ "schema": 1, "updatedAt": "2026-09-28",
  "prices": { "<level-1 or skin uuid>": 2375 },
  "tierPrices": { "<content tier uuid>": 2175 },
  "meleeMultiplier": 2 }
```

It ships with an **empty `prices` map**: Riot publishes no public price list (P-5
needs a session and is UNVERIFIED in 2026; HenrikDev's store-offers now needs an
API key), so exact prices come from storefronts the user has seen and the rest
use the edition fallback shown with "≈". Add verified per-skin prices (e.g.
Exclusive bundles at 2375 / 2675 VP) here or in the hosted remote config
(`{"prices": {…}}`, bare map or full document). **The asset folder must be listed
in `pubspec.yaml` (`- assets/data/`)**; until then the loader falls back to an
empty table and everything still works through the other sources.

---

## 5. Reward sources — `reward_sources.dart`

```dart
class RewardSourceEntry {
  Contract contract; String itemUuid; ContractRewardType rewardType;
  int chapterIndex; bool isFreeReward; int? level /* 1-based premium level */; bool isEpilogue;
  ContractRelation get relation; String get contractName; String? get label;
}

class RewardSourceIndex {
  static final empty;
  factory RewardSourceIndex.fromContent(ContentDb db);
  factory RewardSourceIndex.fromContracts(Iterable<Contract> contracts, {ContentDb? db});
  RewardSourceEntry? forItem(String itemUuid);          // skin LEVEL / buddy LEVEL / card / spray / title / flex
  List<RewardSourceEntry> allFor(String itemUuid);
  RewardSourceEntry? forSkin(WeaponSkin skin);
  RewardSourceEntry? forSkinUuid(String anySkinUuid);   // skin, level or chroma
  RewardSourceEntry? forBuddy(String buddyOrLevelUuid);
  bool isRewardSkin(WeaponSkin skin);
  int get length;
}
```

Currency rewards are not indexed. When an item is in several contracts the first
one (content order) with a Season / Agent / Event relation wins.

```dart
final source = ref.watch(rewardSourceIndexProvider).forSkin(skin);
// S15: "${source.label} · ${source.contractName}" and ContentStrings.level(source.level!) when set
```

(`ContentDb.rewardSource(...)` from core still works for a bare label; this index
adds the level, track and reward type.)

---

## 6. Wishlist — `wishlist.dart`

Storage is the core contract, re-exported: `wishlistProvider(puuid)` →
`Set<String>` of **skin** uuids; `WishlistNotifier.add / remove / toggle /
contains`; `WishlistRepository(prefs)` for background isolates; stored under
`keep.<puuid>.wishlist` so it survives sign-out (W6).

```dart
String wishlistKeyFor(String anySkinUuid, ContentDb db);                 // → skin uuid
Set<String> normalizeWishlist(Iterable<String> wishlist, ContentDb db);
bool wishlistContains(Set<String> wishlist, String anySkinUuid, ContentDb db);

extension WishlistNotifierX on WishlistNotifier {                         // any skin / level / chroma uuid
  bool containsSkin(String anySkinUuid, ContentDb db);
  Future<void> addSkin(String anySkinUuid, ContentDb db);
  Future<void> removeSkin(String anySkinUuid, ContentDb db);             // also removes legacy level entries
  Future<bool> toggleSkin(String anySkinUuid, ContentDb db);             // → new membership
}

enum WishlistPlace { daily, nightMarket, bundle;  String get label; }

class WishlistHit {
  String skinUuid; String levelUuid; WishlistPlace place; WeaponSkin? skin;
  String? bundleId; String? bundleDataAssetId;
  int? price;              // what you pay: daily cost / NM discounted / price inside the bundle
  int? basePrice;          // full price when discounted
  int? discountPercent;    // NM integer percent / discounted bundle item
  DateTime? expiresAt;
  String get key;          // "place:skin[:bundle]" — stable id for notifications / dedupe
  String placeLabel(ContentDb db);   // "cửa hàng hằng ngày" / "Chợ Đêm" / "bundle Neo Frontier"
}

List<WishlistHit> findWishlistHits(Storefront storefront, Set<String> wishlistSkinUuids, ContentDb db);
```

Hits come in store order (daily → Night Market → bundles); a skin on sale in
several places gives one hit per place (and per bundle).

```dart
// Store / S15 heart
final n = ref.read(wishlistProvider(puuid).notifier);
final inList = n.containsSkin(offer.skinLevelUuid, db);
await n.toggleSkin(offer.skinLevelUuid, db);

// S3A "Đang có trong Chợ Đêm!"
final hits = ref.watch(wishlistHitsProvider(puuid)).value ?? const [];
Text(EconomyStrings.availableNow(hit.placeLabel(db)));

// W2/W4 background check (no Riverpod)
final ctx = await BackgroundContext.instance();
try {
  final db = await ctx.content.load(language: ctx.settings.itemLanguage.apiCode);
  final json = await ctx.pvp.storefront(puuid);
  final store = Storefront.fromJson(json, receivedAt: DateTime.now());
  await ObservedPriceStore(ctx.prefs).record(store.observedSkinPrices());
  final hits = findWishlistHits(store, ctx.wishlist.read(puuid), db);
  // notify once per hit.key per UTC day …
} finally { await ctx.finish(); }
```

---

## 7. Strings — `economy_strings.dart`

`EconomyStrings.placeDaily` ("cửa hàng hằng ngày"), `placeNightMarket` ("Chợ Đêm"),
`placeBundle(name)` ("bundle {name}"), `availableNow(place)` ("Đang có trong
{place}!"), price-source captions (`priceFromTable`, `priceFromStore`,
`priceFromOffers`, `priceEstimated`, `priceUnknown`), `collectionValue`,
`wishlistValue`, `excludedRewards` ("Không tính skin phần thưởng"),
`valueHasEstimates`. Reward labels, "Không bán", item-type and currency labels
stay in `ContentStrings`.
