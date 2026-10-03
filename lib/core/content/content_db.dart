import 'package:flutter/foundation.dart';

import '../riot/riot_ids.dart';
import '../util/json.dart';
import 'content_fallbacks.dart';
import 'models/cosmetic_models.dart';
import 'models/game_models.dart';
import 'models/progression_models.dart';
import 'models/rank_models.dart';
import 'models/weapon_models.dart';

export 'models/cosmetic_models.dart';
export 'models/game_models.dart';
export 'models/progression_models.dart';
export 'models/rank_models.dart';
export 'models/weapon_models.dart';

/// Endpoint keys of the raw content map (see `ContentRepository.endpoints`).
abstract final class ContentEndpoints {
  static const weapons = 'weapons';
  static const bundles = 'bundles';
  static const buddies = 'buddies';
  static const sprays = 'sprays';
  static const playerCards = 'playercards';
  static const playerTitles = 'playertitles';
  static const flex = 'flex';
  static const levelBorders = 'levelborders';
  static const agents = 'agents';
  static const maps = 'maps';
  static const gameModes = 'gamemodes';
  static const queues = 'queues';
  static const competitiveTiers = 'competitivetiers';
  static const seasons = 'seasons';
  static const competitiveSeasons = 'competitiveseasons';
  static const contracts = 'contracts';
  static const missions = 'missions';
  static const currencies = 'currencies';
  static const contentTiers = 'contenttiers';
  static const ceremonies = 'ceremonies';
  static const gear = 'gear';
  static const events = 'events';
  static const equippables = 'equippables';
}

/// A resolved store / reward item of any type (bundles, accessory store,
/// contract rewards, entitlements).
@immutable
class ContentItemRef {
  const ContentItemRef({
    required this.itemTypeId,
    required this.uuid,
    required this.name,
    this.image,
    this.contentTierUuid,
  });

  final String itemTypeId;
  final String uuid;
  final String name;

  final String? image;
  final String? contentTierUuid;
}

/// Where a skin comes from when it is a reward (C9).
@immutable
class RewardSource {
  const RewardSource(this.contract);

  final Contract contract;

  ContractRelation get relation => contract.relation;
}

/// Immutable, indexed valorant-api content (CA §17). Build it with
/// [ContentDb.parse] (inside an isolate) or [ContentDb.empty] (fallback
/// tables only). Every lookup lowercases its input and returns `null` when
/// unknown — render a placeholder, never crash.
class ContentDb {
  ContentDb._({
    required this.language,
    required this.manifestId,
    required List<Weapon> weapons,
    required List<Bundle> bundles,
    required List<Buddy> buddies,
    required List<Spray> sprays,
    required List<PlayerCard> playerCards,
    required List<PlayerTitle> playerTitles,
    required List<FlexItem> flex,
    required List<LevelBorder> levelBorders,
    required List<Agent> agents,
    required List<GameMap> maps,
    required List<GameMode> gameModes,
    required List<GameQueue> queues,
    required List<CompetitiveTierTable> tierTables,
    required List<Season> seasons,
    required List<CompetitiveSeason> competitiveSeasons,
    required List<Contract> contracts,
    required List<Mission> missions,
    required List<Currency> currencies,
    required List<ContentTier> contentTiers,
    required List<Ceremony> ceremonies,
    required List<Gear> gear,
    required List<GameEvent> events,
    required List<Weapon> equippables,
  }) : weapons = List<Weapon>.unmodifiable(
         <Weapon>[...weapons]..sort((a, b) {
           final c = a.category.index.compareTo(b.category.index);
           return c != 0 ? c : a.displayName.compareTo(b.displayName);
         }),
       ),
       bundles = List.unmodifiable(bundles),
       buddies = List.unmodifiable(buddies),
       sprays = List.unmodifiable(sprays),
       playerCards = List.unmodifiable(playerCards),
       playerTitles = List.unmodifiable(playerTitles),
       flexItems = List.unmodifiable(flex),
       levelBorders = List<LevelBorder>.unmodifiable(
         <LevelBorder>[...levelBorders]
           ..sort((a, b) => a.startingLevel.compareTo(b.startingLevel)),
       ),
       agents = List<Agent>.unmodifiable(
         <Agent>[...agents]
           ..sort((a, b) => a.displayName.compareTo(b.displayName)),
       ),
       maps = List.unmodifiable(maps),
       gameModes = List.unmodifiable(gameModes),
       queues = List.unmodifiable(queues),
       tierTables = List.unmodifiable(tierTables),
       seasons = List<Season>.unmodifiable(
         <Season>[...seasons]..sort(
           (a, b) => (a.startTime ?? DateTime(0)).compareTo(
             b.startTime ?? DateTime(0),
           ),
         ),
       ),
       competitiveSeasons = List.unmodifiable(competitiveSeasons),
       contracts = List.unmodifiable(contracts),
       missions = List.unmodifiable(missions),
       currencies = List<Currency>.unmodifiable(
         currencies.isEmpty ? ContentFallbacks.currencies : currencies,
       ),
       contentTiers = List<ContentTier>.unmodifiable(
         <ContentTier>[
           ...(contentTiers.isEmpty
               ? ContentFallbacks.contentTiers
               : contentTiers),
         ]..sort((a, b) => a.rank.compareTo(b.rank)),
       ),
       ceremonies = List.unmodifiable(ceremonies),
       gear = List.unmodifiable(gear),
       events = List.unmodifiable(events),
       equippables = List.unmodifiable(equippables) {
    _index();
  }

  /// Only the bundled fallback tables (currencies, content tiers, queue
  /// names). Used before the first download and in tests.
  factory ContentDb.empty({String language = 'vi-VN'}) => ContentDb._(
    language: language,
    manifestId: null,
    weapons: const [],
    bundles: const [],
    buddies: const [],
    sprays: const [],
    playerCards: const [],
    playerTitles: const [],
    flex: const [],
    levelBorders: const [],
    agents: const [],
    maps: const [],
    gameModes: const [],
    queues: const [],
    tierTables: const [],
    seasons: const [],
    competitiveSeasons: const [],
    contracts: const [],
    missions: const [],
    currencies: const [],
    contentTiers: const [],
    ceremonies: const [],
    gear: const [],
    events: const [],
    equippables: const [],
  );

  /// Parses raw valorant-api responses keyed by [ContentEndpoints] (each an
  /// envelope `{"status":200,"data":[…]}` or the bare `data`). Missing or
  /// corrupt endpoints yield empty tables. Pure and isolate-safe.
  factory ContentDb.parse(
    Map<String, Object?> raw, {
    String language = 'vi-VN',
    String? manifestId,
  }) {
    List<Object?> data(String key) {
      final value = raw[key];
      final decoded = value is String ? tryDecodeJson(value) : value;
      final inner = asMap(decoded) != null ? vapiData(decoded) : decoded;
      return asList(inner);
    }

    List<T> parse<T>(String key, T? Function(Object?) f) => [
      for (final item in data(key))
        if (f(item) case final T value) value,
    ];

    return ContentDb._(
      language: language,
      manifestId: manifestId,
      weapons: parse(ContentEndpoints.weapons, Weapon.fromJson),
      bundles: parse(ContentEndpoints.bundles, Bundle.fromJson),
      buddies: parse(ContentEndpoints.buddies, Buddy.fromJson),
      sprays: parse(ContentEndpoints.sprays, Spray.fromJson),
      playerCards: parse(ContentEndpoints.playerCards, PlayerCard.fromJson),
      playerTitles: parse(ContentEndpoints.playerTitles, PlayerTitle.fromJson),
      flex: parse(ContentEndpoints.flex, FlexItem.fromJson),
      levelBorders: parse(ContentEndpoints.levelBorders, LevelBorder.fromJson),
      agents: parse(ContentEndpoints.agents, Agent.fromJson),
      maps: parse(ContentEndpoints.maps, GameMap.fromJson),
      gameModes: parse(ContentEndpoints.gameModes, GameMode.fromJson),
      queues: parse(ContentEndpoints.queues, GameQueue.fromJson),
      tierTables: parse(
        ContentEndpoints.competitiveTiers,
        CompetitiveTierTable.fromJson,
      ),
      seasons: parse(ContentEndpoints.seasons, Season.fromJson),
      competitiveSeasons: parse(
        ContentEndpoints.competitiveSeasons,
        CompetitiveSeason.fromJson,
      ),
      contracts: parse(ContentEndpoints.contracts, Contract.fromJson),
      missions: parse(ContentEndpoints.missions, Mission.fromJson),
      currencies: parse(ContentEndpoints.currencies, Currency.fromJson),
      contentTiers: parse(ContentEndpoints.contentTiers, ContentTier.fromJson),
      ceremonies: parse(ContentEndpoints.ceremonies, Ceremony.fromJson),
      gear: parse(ContentEndpoints.gear, Gear.fromJson),
      events: parse(ContentEndpoints.events, GameEvent.fromJson),
      equippables: parse(ContentEndpoints.equippables, Weapon.fromJson),
    );
  }

  /// valorant-api language of the names (`vi-VN` / `en-US`).
  final String language;

  /// Build the data came from (`null` for [ContentDb.empty]).
  final String? manifestId;

  /// Sorted by category, then name.
  final List<Weapon> weapons;
  final List<Bundle> bundles;
  final List<Buddy> buddies;
  final List<Spray> sprays;
  final List<PlayerCard> playerCards;
  final List<PlayerTitle> playerTitles;
  final List<FlexItem> flexItems;

  /// Sorted by `startingLevel`.
  final List<LevelBorder> levelBorders;

  /// Sorted by name.
  final List<Agent> agents;
  final List<GameMap> maps;
  final List<GameMode> gameModes;
  final List<GameQueue> queues;
  final List<CompetitiveTierTable> tierTables;

  /// Sorted by start time.
  final List<Season> seasons;
  final List<CompetitiveSeason> competitiveSeasons;
  final List<Contract> contracts;
  final List<Mission> missions;
  final List<Currency> currencies;

  /// Sorted by rank (Select → Ultra).
  final List<ContentTier> contentTiers;
  final List<Ceremony> ceremonies;

  /// Armor (`/v1/gear`).
  final List<Gear> gear;
  final List<GameEvent> events;

  /// Game-mode weapons not in `/v1/weapons` (Golden Gun, NPE Classic).
  final List<Weapon> equippables;

  bool get isEmpty => weapons.isEmpty;

  // ------------------------------------------------------------------ indices
  final Map<String, Weapon> _weapons = {};
  final Map<String, WeaponSkin> _skins = {};
  final Map<String, WeaponSkin> _skinByLevel = {};
  final Map<String, SkinLevel> _levels = {};
  final Map<String, WeaponSkin> _skinByChroma = {};
  final Map<String, SkinChroma> _chromas = {};
  final Map<String, Bundle> _bundles = {};
  final Map<String, Buddy> _buddies = {};
  final Map<String, Buddy> _buddyByLevel = {};
  final Map<String, Spray> _sprays = {};
  final Map<String, Spray> _sprayByLevel = {};
  final Map<String, PlayerCard> _cards = {};
  final Map<String, PlayerTitle> _titles = {};
  final Map<String, FlexItem> _flex = {};
  final Map<String, LevelBorder> _borders = {};
  final Map<String, Agent> _agents = {};
  final Map<String, GameMap> _mapsByUrl = {};
  final Map<String, GameMap> _maps = {};
  final Map<String, GameQueue> _queues = {};
  final Map<String, GameMode> _modesByKey = {};
  final Map<String, CompetitiveTierTable> _tierTables = {};
  final Map<String, Season> _seasons = {};
  final Map<String, CompetitiveSeason> _compBySeason = {};
  final Map<String, Contract> _contracts = {};
  final Map<String, Contract> _rewardContract = {};
  final Map<String, Mission> _missions = {};
  final Map<String, Currency> _currencies = {};
  final Map<String, ContentTier> _contentTiers = {};
  final Map<String, Ceremony> _ceremonies = {};
  final Map<String, Gear> _gear = {};
  final Map<String, GameEvent> _events = {};
  final Map<String, Weapon> _equippables = {};

  void _index() {
    for (final w in weapons) {
      _weapons[w.uuid] = w;
      for (final s in w.skins) {
        _skins[s.uuid] = s;
        for (final l in s.levels) {
          _skinByLevel[l.uuid] = s;
          _levels[l.uuid] = l;
        }
        for (final c in s.chromas) {
          _skinByChroma[c.uuid] = s;
          _chromas[c.uuid] = c;
        }
      }
    }
    for (final b in bundles) {
      _bundles[b.uuid] = b;
    }
    for (final b in buddies) {
      _buddies[b.uuid] = b;
      for (final l in b.levels) {
        _buddyByLevel[l.uuid] = b;
      }
    }
    for (final s in sprays) {
      _sprays[s.uuid] = s;
      for (final l in s.levelUuids) {
        _sprayByLevel[l] = s;
      }
    }
    for (final c in playerCards) {
      _cards[c.uuid] = c;
    }
    for (final t in playerTitles) {
      _titles[t.uuid] = t;
    }
    for (final f in flexItems) {
      _flex[f.uuid] = f;
    }
    for (final b in levelBorders) {
      _borders[b.uuid] = b;
    }
    for (final a in agents) {
      _agents[a.uuid] = a;
    }
    for (final m in maps) {
      _maps[m.uuid] = m;
      if (m.mapUrl.isNotEmpty) _mapsByUrl[m.mapUrl.toLowerCase()] = m;
    }
    for (final q in queues) {
      _queues[q.queueId.toLowerCase()] = q;
    }
    for (final m in gameModes) {
      final key = m.key;
      if (key != null) _modesByKey[key] = m;
    }
    for (final t in tierTables) {
      _tierTables[t.uuid] = t;
    }
    for (final s in seasons) {
      _seasons[s.uuid] = s;
    }
    for (final c in competitiveSeasons) {
      _compBySeason[c.seasonUuid] = c;
    }
    for (final c in contracts) {
      _contracts[c.uuid] = c;
      for (final ch in c.chapters) {
        for (final l in ch.levels) {
          final r = l.reward;
          if (r != null) _rewardContract.putIfAbsent(r.uuid, () => c);
        }
        for (final r in ch.freeRewards) {
          _rewardContract.putIfAbsent(r.uuid, () => c);
        }
      }
    }
    for (final m in missions) {
      _missions[m.uuid] = m;
    }
    for (final c in currencies) {
      _currencies[c.uuid] = c;
    }
    for (final t in contentTiers) {
      _contentTiers[t.uuid] = t;
    }
    for (final c in ceremonies) {
      _ceremonies[c.key.toLowerCase()] = c;
    }
    for (final g in gear) {
      _gear[g.uuid] = g;
    }
    for (final e in events) {
      _events[e.uuid] = e;
    }
    for (final e in equippables) {
      _equippables[e.uuid] = e;
    }
  }

  static String _k(String id) => id.trim().toLowerCase();

  // ---------------------------------------------------------- weapons / skins

  Weapon? weapon(String uuid) => _weapons[_k(uuid)];

  WeaponSkin? skin(String skinUuid) => _skins[_k(skinUuid)];

  /// Store offers, entitlements and loadouts use LEVEL uuids.
  WeaponSkin? skinByLevelUuid(String levelUuid) => _skinByLevel[_k(levelUuid)];

  WeaponSkin? skinByChromaUuid(String chromaUuid) =>
      _skinByChroma[_k(chromaUuid)];

  /// Resolves a skin, level or chroma uuid to its skin.
  WeaponSkin? skinByAnyUuid(String uuid) {
    final k = _k(uuid);
    return _skins[k] ?? _skinByLevel[k] ?? _skinByChroma[k];
  }

  SkinLevel? skinLevel(String levelUuid) => _levels[_k(levelUuid)];

  SkinChroma? skinChroma(String chromaUuid) => _chromas[_k(chromaUuid)];

  /// Weapon of a skin (skin, level or chroma uuid).
  Weapon? weaponBySkin(String anySkinUuid) {
    final s = skinByAnyUuid(anySkinUuid);
    return s == null ? null : _weapons[s.weaponUuid];
  }

  /// Every real skin (Standard and Random-favorite filtered out).
  Iterable<WeaponSkin> get collectibleSkins sync* {
    for (final w in weapons) {
      for (final s in w.skins) {
        if (s.isCollectible) yield s;
      }
    }
  }

  // ---------------------------------------------------------------- cosmetics

  Bundle? bundleByUuid(String uuid) => _bundles[_k(uuid)];
  Buddy? buddy(String uuid) => _buddies[_k(uuid)];

  /// Store / entitlements / `CharmLevelID` use LEVEL uuids.
  Buddy? buddyByLevelUuid(String levelUuid) => _buddyByLevel[_k(levelUuid)];

  Spray? spray(String uuid) => _sprays[_k(uuid)] ?? _sprayByLevel[_k(uuid)];
  PlayerCard? card(String uuid) => _cards[_k(uuid)];
  PlayerTitle? title(String uuid) => _titles[_k(uuid)];
  FlexItem? flex(String uuid) => _flex[_k(uuid)];
  LevelBorder? levelBorder(String uuid) => _borders[_k(uuid)];

  /// Border for an account level: [preferredId] when set (and not the
  /// all-zero "auto" id), else the highest `startingLevel <= level`.
  LevelBorder? levelBorderFor(int level, {String? preferredId}) {
    if (preferredId != null &&
        preferredId.isNotEmpty &&
        preferredId != SpecialIds.autoLevelBorder) {
      final preferred = levelBorder(preferredId);
      if (preferred != null) return preferred;
    }
    LevelBorder? best;
    for (final b in levelBorders) {
      if (b.startingLevel <= level) best = b;
    }
    return best ?? levelBorders.firstOrNull;
  }

  ContentTier? contentTier(String? uuid) => uuid == null
      ? null
      : (_contentTiers[_k(uuid)] ?? ContentFallbacks.contentTier(uuid));

  Currency? currency(String uuid) =>
      _currencies[_k(uuid)] ?? ContentFallbacks.currency(uuid);

  /// Resolves any Riot `ItemTypeID` + `ItemID` pair to a display ref.
  ContentItemRef? item(String itemTypeId, String itemId) {
    final type = _k(itemTypeId);
    final id = _k(itemId);
    switch (type) {
      case ItemTypeIds.skinLevel:
        final s = skinByLevelUuid(id) ?? skin(id);
        if (s == null) return null;
        return ContentItemRef(
          itemTypeId: type,
          uuid: id,
          name: s.displayName,
          image: s.image,
          contentTierUuid: s.contentTierUuid,
        );
      case ItemTypeIds.skinChroma:
        final s = skinByChromaUuid(id);
        final c = skinChroma(id);
        if (s == null || c == null) return null;
        return ContentItemRef(
          itemTypeId: type,
          uuid: id,
          name: c.displayName.isEmpty ? s.displayName : c.displayName,
          image: c.fullRender ?? c.displayIcon ?? s.image,
          contentTierUuid: s.contentTierUuid,
        );
      case ItemTypeIds.buddyLevel:
        final b = buddyByLevelUuid(id) ?? buddy(id);
        if (b == null) return null;
        return ContentItemRef(
          itemTypeId: type,
          uuid: id,
          name: b.displayName,
          image: b.image,
        );
      case ItemTypeIds.spray:
        final s = spray(id);
        if (s == null) return null;
        return ContentItemRef(
          itemTypeId: type,
          uuid: id,
          name: s.displayName,
          image: s.image,
        );
      case ItemTypeIds.playerCard:
        final c = card(id);
        if (c == null) return null;
        return ContentItemRef(
          itemTypeId: type,
          uuid: id,
          name: c.displayName,
          image: c.smallArt ?? c.displayIcon,
        );
      case ItemTypeIds.playerTitle:
        final t = title(id);
        if (t == null) return null;
        return ContentItemRef(itemTypeId: type, uuid: id, name: t.text);
      case ItemTypeIds.flex:
        final f = flex(id);
        if (f == null) return null;
        return ContentItemRef(
          itemTypeId: type,
          uuid: id,
          name: f.displayName,
          image: f.displayIcon,
        );
      case ItemTypeIds.agent:
        final a = agent(id);
        if (a == null) return null;
        return ContentItemRef(
          itemTypeId: type,
          uuid: id,
          name: a.displayName,
          image: a.displayIcon,
        );
      case ItemTypeIds.currency:
        final c = currency(id);
        if (c == null) return null;
        return ContentItemRef(
          itemTypeId: type,
          uuid: id,
          name: c.displayName,
          image: c.displayIcon,
        );
      case ItemTypeIds.premiumContract:
        final c = contract(id);
        if (c == null) return null;
        return ContentItemRef(
          itemTypeId: type,
          uuid: id,
          name: c.displayName,
          image: c.displayIcon,
        );
    }
    return null;
  }

  /// Armor by uuid (match `playerEconomy.armor`).
  Gear? gearItem(String uuid) => _gear[_k(uuid)];

  GameEvent? event(String uuid) => _events[_k(uuid)];

  /// Weapon or game-mode equippable (kill feed `damageItem`, which arrives
  /// UPPERCASE; SUMMARY §9.8).
  Weapon? weaponOrEquippable(String uuid) =>
      _weapons[_k(uuid)] ?? _equippables[_k(uuid)];

  // ------------------------------------------------------------ agents / maps

  Agent? agent(String uuid) => _agents[_k(uuid)];

  /// Riot `MapID` / `matchInfo.mapId` (exact, case-insensitive).
  GameMap? mapByUrl(String? mapId) =>
      mapId == null ? null : _mapsByUrl[mapId.trim().toLowerCase()];

  GameMap? map(String uuid) => _maps[_k(uuid)];

  // ---------------------------------------------------------- queues / modes

  GameQueue? queue(String? queueId) =>
      queueId == null ? null : _queues[queueId.trim().toLowerCase()];

  /// Game mode from a Riot `ModeID` / `matchInfo.gameMode` path.
  GameMode? gameModeByPath(String? path) {
    final key = gameModeKey(path);
    return key == null ? null : _modesByKey[key];
  }

  /// Round ceremony by Riot key (`CeremonyAce` or `Ace`); `CeremonyDefault`
  /// and `""` → null.
  Ceremony? ceremony(String? riotKey) {
    if (riotKey == null) return null;
    var k = riotKey.trim();
    if (k.startsWith('Ceremony')) k = k.substring('Ceremony'.length);
    if (k.isEmpty || k == 'Default') return null;
    return _ceremonies[k.toLowerCase()];
  }

  // ---------------------------------------------------------------- ranks

  CompetitiveTierTable? tierTable(String uuid) => _tierTables[_k(uuid)];

  /// Latest competitive season by start time (for unknown / new acts).
  CompetitiveSeason? get latestCompetitiveSeason {
    CompetitiveSeason? best;
    for (final c in competitiveSeasons) {
      final start = c.startTime;
      if (start == null) continue;
      if (best == null || start.isAfter(best.startTime!)) best = c;
    }
    return best;
  }

  /// Tier table for an act (SUMMARY §7.4): `seasonId` →
  /// `/v1/seasons/competitive` → `competitiveTiersUuid`. Unknown act → newest
  /// table.
  CompetitiveTierTable? tierTableForSeason(String? seasonUuid) {
    final cs = seasonUuid == null ? null : _compBySeason[_k(seasonUuid)];
    final tableId =
        cs?.competitiveTiersUuid ??
        latestCompetitiveSeason?.competitiveTiersUuid ??
        SpecialIds.currentTierTable;
    return _tierTables[tableId] ??
        _tierTables[SpecialIds.currentTierTable] ??
        tierTables.lastOrNull;
  }

  /// A tier in the table of [seasonUuid] (current table when null).
  CompetitiveTier? tier(int tier, {String? seasonUuid}) =>
      tierTableForSeason(seasonUuid)?.tier(tier);

  // ---------------------------------------------------------------- seasons

  Season? season(String uuid) => _seasons[_k(uuid)];

  CompetitiveSeason? competitiveSeason(String seasonUuid) =>
      _compBySeason[_k(seasonUuid)];

  Iterable<Season> get acts => seasons.where((s) => s.isAct);

  /// Act with `startTime <= now < endTime` (never hard-code; SUMMARY §7.6).
  Season? currentAct(DateTime now) {
    final t = now.toUtc();
    for (final s in acts) {
      if (s.isActiveAt(t)) return s;
    }
    return null;
  }

  /// Parent episode of [act].
  Season? episodeOf(Season act) =>
      act.parentUuid == null ? null : season(act.parentUuid!);

  /// `V26 // PHẦN V`, or `HỒI 5 // PHẦN II` composed for pre-2025 acts.
  String actTitle(Season act) {
    if (act.title != null) return act.title!;
    final episode = episodeOf(act);
    return episode == null
        ? act.displayName
        : '${episode.displayName} // ${act.displayName}';
  }

  // ---------------------------------------------------------- contracts etc.

  Contract? contract(String uuid) => _contracts[_k(uuid)];

  Mission? mission(String uuid) => _missions[_k(uuid)];

  /// Current battle pass (SUMMARY §9.4): the latest act with
  /// `startTime <= now` that has a `Season` contract pointing at it.
  Contract? currentBattlePass(DateTime now) {
    final t = now.toUtc();
    final started =
        acts
            .where((a) => a.startTime != null && !a.startTime!.isAfter(t))
            .toList()
          ..sort((a, b) => b.startTime!.compareTo(a.startTime!));
    for (final act in started) {
      for (final c in contracts) {
        if (c.relation == ContractRelation.season &&
            c.relationUuid == act.uuid) {
          return c;
        }
      }
    }
    return null;
  }

  /// Contract that grants [itemUuid] (skin level, buddy level, card…), for
  /// reward-source labels (C9) and to exclude reward skins from values.
  RewardSource? rewardSource(String itemUuid) {
    final c = _rewardContract[_k(itemUuid)];
    return c == null ? null : RewardSource(c);
  }

  /// Reward source of a skin (checks every level uuid of the skin).
  RewardSource? rewardSourceForSkin(WeaponSkin skin) {
    for (final l in skin.levels) {
      final r = rewardSource(l.uuid);
      if (r != null) return r;
    }
    return null;
  }
}
