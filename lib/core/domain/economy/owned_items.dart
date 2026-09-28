/// Owned items from P-3 entitlements (SUMMARY §7.1, §8.3 C1–C10; EP §6.1).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/account_providers.dart';
import '../../content/content_db.dart';
import '../../content/content_repository.dart';
import '../../network/riot_exception.dart';
import '../../riot/pvp_api.dart';
import '../../riot/riot_ids.dart';
import '../../util/clock.dart';
import '../../util/json.dart';
import 'economy_fetch.dart';

/// Items every account owns without an entitlement row (CA §6, EP §6.1).
/// Starter agents are in `SpecialIds.starterAgents` / `Agent.isStarter`;
/// Standard and Random-favorite skins are detected by theme.
abstract final class DefaultItemIds {
  /// "Thẻ VALORANT" (`Playercard_Default`).
  static const playerCard = '9fb348bc-41a0-91ad-8a3e-818035c4e561';

  /// "Hình Phun Sơn VALORANT" (`Spray_Default_VALLogo`).
  static const spray = '0a6db78c-48b9-a32d-c47a-82be597584c1';

  /// "Flex STAT-COM" (`Totem_PDA`).
  static const flex = 'af52b5a0-4a4c-03b2-c9d7-8187a08a2675';

  /// "Không có danh hiệu" (the empty title).
  static const title = SpecialIds.noTitle;

  static const sprays = {spray, SpecialIds.nullSpray};
  static const playerCards = {playerCard};
  static const titles = {title};
  static const flexItems = {flex};
}

/// One entitlement row (`{TypeID, ItemID, InstanceID?}`) with its item type.
@immutable
class EntitlementRow {
  const EntitlementRow({
    required this.itemTypeId,
    required this.itemId,
    this.instanceId,
  });

  final String itemTypeId;
  final String itemId;

  /// Buddy copy id (`CharmInstanceID` in the loadout).
  final String? instanceId;

  @override
  bool operator ==(Object other) =>
      other is EntitlementRow &&
      other.itemTypeId == itemTypeId &&
      other.itemId == itemId &&
      other.instanceId == instanceId;

  @override
  int get hashCode => Object.hash(itemTypeId, itemId, instanceId);

  @override
  String toString() => 'EntitlementRow($itemTypeId, $itemId, $instanceId)';
}

/// Raw entitlements of one account, independent of valorant-api content.
@immutable
class Entitlements {
  const Entitlements._({
    required this._byType,
    required this._instances,
    required this._buddyCopies,
    required this.receivedAt,
    required this.isFromCache,
  });

  /// Builds from parsed rows (duplicates are merged).
  factory Entitlements.fromRows(
    Iterable<EntitlementRow> rows, {
    required DateTime receivedAt,
    bool isFromCache = false,
  }) {
    final byType = <String, Set<String>>{};
    final instances = <String, List<String>>{};
    final copies = <String, int>{};
    final seenInstances = <String>{};
    for (final row in rows) {
      byType.putIfAbsent(row.itemTypeId, () => <String>{}).add(row.itemId);
      if (row.itemTypeId != ItemTypeIds.buddyLevel) continue;
      final instance = row.instanceId;
      if (instance != null) {
        if (!seenInstances.add(instance)) continue;
        instances.putIfAbsent(row.itemId, () => <String>[]).add(instance);
      }
      copies[row.itemId] = (copies[row.itemId] ?? 0) + 1;
    }
    return Entitlements._(
      byType: {
        for (final e in byType.entries) e.key: Set.unmodifiable(e.value),
      },
      instances: {
        for (final e in instances.entries) e.key: List.unmodifiable(e.value),
      },
      buddyCopies: copies,
      receivedAt: receivedAt,
      isFromCache: isFromCache,
    );
  }

  /// Parses one P-3 / P-4 response (either shape, see [parseRows]).
  factory Entitlements.fromJson(
    Object? json, {
    required DateTime receivedAt,
    String? itemTypeId,
    bool isFromCache = false,
  }) => Entitlements.fromRows(
    parseRows(json, requestedItemTypeId: itemTypeId),
    receivedAt: receivedAt,
    isFromCache: isFromCache,
  );

  /// Parses per-type responses keyed by the requested `ItemTypeID` (the
  /// shape [entitlementsProvider] caches).
  factory Entitlements.fromTypeResponses(
    Map<String, Object?> responses, {
    required DateTime receivedAt,
    bool isFromCache = false,
  }) => Entitlements.fromRows(
    [
      for (final e in responses.entries)
        ...parseRows(e.value, requestedItemTypeId: e.key),
    ],
    receivedAt: receivedAt,
    isFromCache: isFromCache,
  );

  /// No entitlements at all (defaults still apply in [OwnedItems]).
  factory Entitlements.empty({DateTime? receivedAt}) => Entitlements.fromRows(
    const [],
    receivedAt: receivedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Rows of a P-3 / P-4 body. Handles both shapes (EP §6.1):
  /// `{ItemTypeID, Entitlements[…]}` and `{EntitlementsByTypes: [{ItemTypeID,
  /// Entitlements[…]}]}`. A missing `ItemTypeID` falls back to
  /// [requestedItemTypeId]; rows without `ItemID` are skipped; ids are
  /// lowercased. Never throws.
  static List<EntitlementRow> parseRows(
    Object? json, {
    String? requestedItemTypeId,
  }) {
    final m = asMap(json);
    if (m == null) return const [];
    final requested = lowerUuid(requestedItemTypeId);
    final groups = m.containsKey('EntitlementsByTypes')
        ? asMapList(m['EntitlementsByTypes'])
        : [m];
    return [
      for (final group in groups)
        if (lowerUuid(group['ItemTypeID']) ?? requested case final type?)
          for (final row in asMapList(group['Entitlements']))
            if (lowerUuid(row['ItemID']) case final id?)
              EntitlementRow(
                itemTypeId: type,
                itemId: id,
                instanceId: lowerUuid(row['InstanceID']),
              ),
    ];
  }

  final Map<String, Set<String>> _byType;
  final Map<String, List<String>> _instances;
  final Map<String, int> _buddyCopies;

  /// When the entitlements were received from Riot.
  final DateTime receivedAt;

  /// Served from the offline cache after a transient failure (X4).
  final bool isFromCache;

  /// Item ids of one `ItemTypeIds.*` type (lowercase).
  Set<String> itemsOfType(String itemTypeId) =>
      _byType[itemTypeId.toLowerCase()] ?? const {};

  bool contains(String itemTypeId, String itemId) =>
      itemsOfType(itemTypeId).contains(itemId.toLowerCase());

  /// Owned instance ids of a buddy LEVEL (one per copy that can be equipped).
  List<String> buddyInstanceIds(String buddyLevelUuid) =>
      _instances[buddyLevelUuid.toLowerCase()] ?? const [];

  /// Number of owned copies of a buddy LEVEL (rows, with or without
  /// `InstanceID`).
  int buddyCopies(String buddyLevelUuid) =>
      _buddyCopies[buddyLevelUuid.toLowerCase()] ?? 0;

  /// Total number of distinct owned items over all types.
  int get length => _byType.values.fold(0, (sum, s) => sum + s.length);
}

/// Everything an account owns, resolved against valorant-api content: the
/// entitlements plus the items every account has (Standard skins and their
/// level/chroma, base chromas, default card / title / spray / flex, starter
/// agents).
///
/// Every lookup accepts upper- or lowercase uuids and never throws.
class OwnedItems {
  OwnedItems._(this.entitlements, this._db) {
    _index();
  }

  /// Resolves [entitlements] with [db].
  factory OwnedItems.resolve(Entitlements entitlements, ContentDb db) =>
      OwnedItems._(entitlements, db);

  final Entitlements entitlements;
  final ContentDb _db;

  /// skin uuid → highest owned level index (0 = level 1).
  final Map<String, int> _maxLevel = {};
  final Set<String> _skins = {};
  final Set<String> _chromas = {};

  DateTime get receivedAt => entitlements.receivedAt;
  bool get isFromCache => entitlements.isFromCache;

  void _index() {
    for (final levelUuid in entitlements.itemsOfType(ItemTypeIds.skinLevel)) {
      final skin = _db.skinByLevelUuid(levelUuid);
      if (skin == null) continue;
      final index = _db.skinLevel(levelUuid)?.index ?? 0;
      final previous = _maxLevel[skin.uuid];
      if (previous == null || index > previous) _maxLevel[skin.uuid] = index;
    }
    for (final weapon in _db.weapons) {
      for (final skin in weapon.skins) {
        if (!skin.isCollectible) {
          _maxLevel[skin.uuid] = skin.levels.length - 1;
        }
      }
    }
    _skins.addAll(_maxLevel.keys);
    _chromas.addAll(entitlements.itemsOfType(ItemTypeIds.skinChroma));
    for (final skinUuid in _skins) {
      final skin = _db.skin(skinUuid);
      if (skin == null) continue;
      // The base chroma comes with the skin; Standard skins own everything.
      for (final c in skin.chromas) {
        if (c.isBase || !skin.isCollectible) _chromas.add(c.uuid);
      }
    }
  }

  static String _k(String id) => id.trim().toLowerCase();

  // ------------------------------------------------------------------ skins

  /// Whether the skin of [skinOrLevelOrChromaUuid] is owned (any level;
  /// Standard / Random-favorite skins are always owned). Unknown uuids fall
  /// back to the raw skin-level entitlements.
  bool isSkinOwned(String skinOrLevelOrChromaUuid) {
    final skin = _db.skinByAnyUuid(skinOrLevelOrChromaUuid);
    if (skin == null) {
      return entitlements.contains(
        ItemTypeIds.skinLevel,
        _k(skinOrLevelOrChromaUuid),
      );
    }
    return _skins.contains(skin.uuid);
  }

  /// Whether a specific level is unlocked (owning level N implies 1…N).
  bool isSkinLevelOwned(String levelUuid) {
    final skin = _db.skinByLevelUuid(levelUuid);
    final level = _db.skinLevel(levelUuid);
    if (skin == null || level == null) {
      return entitlements.contains(ItemTypeIds.skinLevel, _k(levelUuid));
    }
    final max = _maxLevel[skin.uuid];
    return max != null && level.index <= max;
  }

  /// Whether a chroma is unlocked (base chroma of an owned skin included).
  bool isChromaOwned(String chromaUuid) => _chromas.contains(_k(chromaUuid));

  /// Unlocked levels of [skin], in order (empty when not owned).
  List<SkinLevel> ownedLevels(WeaponSkin skin) {
    final max = _maxLevel[skin.uuid];
    if (max == null) return const [];
    return [
      for (final l in skin.levels)
        if (l.index <= max) l,
    ];
  }

  /// Unlocked chromas of [skin], in order (empty when not owned).
  List<SkinChroma> ownedChromas(WeaponSkin skin) {
    if (!_skins.contains(skin.uuid)) return const [];
    return [
      for (final c in skin.chromas)
        if (_chromas.contains(c.uuid)) c,
    ];
  }

  /// Uuids of every owned skin, including Standard / Random-favorite ones.
  Set<String> get ownedSkinUuids => Set.unmodifiable(_skins);

  /// Owned real skins (Standard and Random favorite excluded), in content
  /// order — the input of the collection value (SUMMARY §9.3).
  List<WeaponSkin> get ownedCollectibleSkins => [
    for (final s in _db.collectibleSkins)
      if (_skins.contains(s.uuid)) s,
  ];

  /// Owned skins of one weapon, Standard first (skin picker S34).
  List<WeaponSkin> ownedSkinsForWeapon(String weaponUuid) {
    final weapon = _db.weapon(weaponUuid);
    if (weapon == null) return const [];
    final owned = [
      for (final s in weapon.skins)
        if (_skins.contains(s.uuid) && !s.isRandomFavorite) s,
    ];
    owned.sort((a, b) {
      if (a.isStandard != b.isStandard) return a.isStandard ? -1 : 1;
      return a.displayName.compareTo(b.displayName);
    });
    return owned;
  }

  /// Skin-level entitlements that are not in content (new patch). Report
  /// them with `contentMissReporterProvider`.
  Set<String> get unknownSkinLevels => {
    for (final l in entitlements.itemsOfType(ItemTypeIds.skinLevel))
      if (_db.skinByLevelUuid(l) == null) l,
  };

  // ---------------------------------------------------------------- buddies

  /// Instance ids of a buddy (LEVEL uuid, or buddy uuid → all its levels).
  /// One instance can be equipped on one gun (`CharmInstanceID`).
  List<String> buddyInstances(String buddyOrLevelUuid) => [
    for (final level in _buddyLevels(buddyOrLevelUuid))
      ...entitlements.buddyInstanceIds(level),
  ];

  /// Number of owned copies ("Còn 2/3" denominator).
  int buddyCount(String buddyOrLevelUuid) =>
      _buddyLevels(buddyOrLevelUuid)
          .fold(0, (sum, level) => sum + entitlements.buddyCopies(level));

  bool isBuddyOwned(String buddyOrLevelUuid) =>
      buddyCount(buddyOrLevelUuid) > 0;

  /// Owned buddy LEVEL uuids.
  Set<String> get buddyLevelUuids =>
      entitlements.itemsOfType(ItemTypeIds.buddyLevel);

  Iterable<String> _buddyLevels(String buddyOrLevelUuid) {
    final id = _k(buddyOrLevelUuid);
    final buddy = _db.buddy(id);
    if (buddy != null) return [for (final l in buddy.levels) l.uuid];
    return [id];
  }

  // ------------------------------------------------------- other cosmetics

  /// Owned sprays (entitlements + defaults, spray uuids).
  Set<String> get sprayUuids => {
    ...entitlements.itemsOfType(ItemTypeIds.spray),
    ...DefaultItemIds.sprays,
  };

  Set<String> get playerCardUuids => {
    ...entitlements.itemsOfType(ItemTypeIds.playerCard),
    ...DefaultItemIds.playerCards,
  };

  Set<String> get titleUuids => {
    ...entitlements.itemsOfType(ItemTypeIds.playerTitle),
    ...DefaultItemIds.titles,
  };

  Set<String> get flexUuids => {
    ...entitlements.itemsOfType(ItemTypeIds.flex),
    ...DefaultItemIds.flexItems,
  };

  /// Owned agents including the starters (never in entitlements).
  Set<String> get agentUuids => {
    ...entitlements.itemsOfType(ItemTypeIds.agent),
    ...SpecialIds.starterAgents,
    for (final a in _db.agents)
      if (a.isStarter) a.uuid,
  };

  /// Spray uuid or spray LEVEL uuid.
  bool isSprayOwned(String uuid) {
    final id = _db.spray(uuid)?.uuid ?? _k(uuid);
    return DefaultItemIds.sprays.contains(id) ||
        entitlements.contains(ItemTypeIds.spray, id);
  }

  bool isPlayerCardOwned(String uuid) =>
      DefaultItemIds.playerCards.contains(_k(uuid)) ||
      entitlements.contains(ItemTypeIds.playerCard, uuid);

  bool isTitleOwned(String uuid) =>
      DefaultItemIds.titles.contains(_k(uuid)) ||
      entitlements.contains(ItemTypeIds.playerTitle, uuid);

  bool isFlexOwned(String uuid) =>
      DefaultItemIds.flexItems.contains(_k(uuid)) ||
      entitlements.contains(ItemTypeIds.flex, uuid);

  bool isAgentOwned(String uuid) {
    final id = _k(uuid);
    return SpecialIds.starterAgents.contains(id) ||
        (_db.agent(id)?.isStarter ?? false) ||
        entitlements.contains(ItemTypeIds.agent, id);
  }

  // -------------------------------------------------------------- contracts

  /// Contracts whose premium track was bought (BP, event passes).
  Set<String> get premiumContracts =>
      entitlements.itemsOfType(ItemTypeIds.premiumContract);

  /// Premium battle pass / event pass check (P1: `f85cb6f7` contains the
  /// contract uuid).
  bool hasPremiumContract(String contractUuid) =>
      entitlements.contains(ItemTypeIds.premiumContract, contractUuid);

  // ---------------------------------------------------------------- generic

  /// Ownership of any store / reward item (`ItemTypeID` + `ItemID`): bundle
  /// items, accessory offers, contract rewards. Currencies are never "owned".
  bool owns(String itemTypeId, String itemId) =>
      switch (itemTypeId.trim().toLowerCase()) {
        ItemTypeIds.skinLevel => isSkinLevelOwned(itemId),
        ItemTypeIds.skinChroma => isChromaOwned(itemId),
        ItemTypeIds.buddyLevel => isBuddyOwned(itemId),
        ItemTypeIds.spray => isSprayOwned(itemId),
        ItemTypeIds.playerCard => isPlayerCardOwned(itemId),
        ItemTypeIds.playerTitle => isTitleOwned(itemId),
        ItemTypeIds.flex => isFlexOwned(itemId),
        ItemTypeIds.agent => isAgentOwned(itemId),
        ItemTypeIds.premiumContract => hasPremiumContract(itemId),
        _ => false,
      };
}

// --------------------------------------------------------------- providers

/// How long entitlements stay cached after the last listener leaves
/// (SUMMARY §10: 10 min; invalidate after a loadout PUT or on focus).
const kEntitlementsTtl = Duration(minutes: 10);

/// Raw entitlements of one signed-in account: one P-3 call per type in
/// `ItemTypeIds.collectionTypes`, at most [kEconomyConcurrency] in flight
/// (what the game client does, EP §6.1). A type answering 404 counts as
/// empty; any other failure fails the whole fetch (a partial collection would
/// show owned items as locked). Offline copy on transient failures (X4).
final entitlementsProvider = FutureProvider.autoDispose
    .family<Entitlements, String>((ref, puuid) async {
      ref.watch(accountProvider(puuid).select((a) => a?.needsLogin));
      final api = ref.watch(pvpApiProvider);
      final fetched = await fetchWithOfflineCache(
        ref,
        puuid: puuid,
        name: 'entitlements',
        fetch: () async {
          final types = ItemTypeIds.collectionTypes;
          final bodies = await runPooled<String, Object?>(types, (type) async {
            try {
              return await api.entitlements(puuid, type);
            } on NotFoundException {
              return null;
            }
          });
          return <String, Object?>{
            for (var i = 0; i < types.length; i++) types[i]: bodies[i],
          };
        },
      );
      final entitlements = Entitlements.fromTypeResponses(
        asMap(fetched.data) ?? const {},
        receivedAt: fetched.receivedAt,
        isFromCache: fetched.isFromCache,
      );
      if (!ref.mounted) return entitlements;
      final now = ref.read(clockProvider).now();
      if (fetched.cachedAfter case final error?) {
        scheduleProviderRefresh(
          ref,
          now.add(offlineRetryDelay(error)),
          now: now,
        );
      } else {
        scheduleProviderRefresh(
          ref,
          now.add(kEntitlementsTtl),
          now: now,
          refetch: false,
        );
      }
      return entitlements;
    });

/// [OwnedItems] of one signed-in account: [entitlementsProvider] resolved
/// with the current content (a language switch re-resolves without
/// refetching). Invalidate [entitlementsProvider] to refetch.
///
/// ```dart
/// final owned = ref.watch(ownedItemsProvider(puuid)).value;
/// final isOwned = owned?.isSkinOwned(offer.skinLevelUuid) ?? false;
/// ```
final ownedItemsProvider = FutureProvider.autoDispose
    .family<OwnedItems, String>((ref, puuid) async {
      final (entitlements, db) = await awaitBoth(
        ref.watch(entitlementsProvider(puuid).future),
        ref.watch(contentProvider.future),
      );
      return OwnedItems.resolve(entitlements, db);
    });
