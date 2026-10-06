import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../content/models/game_models.dart' show gameModeKey;
import '../../util/json.dart';
import 'names.dart';
import 'viewer.dart' show baseQueueId;

final RegExp _uuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

/// Normalises a Riot id: UUID-shaped values are lowercased (weapons, armor,
/// `damageItem` and Deathmatch team ids arrive UPPERCASE, SUMMARY §9.8);
/// other values (`Red`, `Ultimate`, `GrenadeAbility`) are only trimmed.
/// Blank → `null`.
String? normalizeRiotId(Object? value) {
  final s = asString(value)?.trim();
  if (s == null || s.isEmpty) return null;
  return _uuidPattern.hasMatch(s) ? s.toLowerCase() : s;
}

/// Whether [value] looks like a UUID.
bool isUuid(String? value) => value != null && _uuidPattern.hasMatch(value);

// ------------------------------------------------------------------ enums

/// A match result from one player's point of view.
enum MatchOutcome {
  win,
  loss,
  draw,
  unknown;

  /// Parses [name] (as written by `outcome.name`).
  static MatchOutcome? fromName(String? name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }

  /// From the sign of an RR change (0 → draw or remake).
  static MatchOutcome fromRr(int rrEarned) => rrEarned > 0
      ? win
      : rrEarned < 0
      ? loss
      : draw;
}

/// How a mode is scored (SUMMARY §9.8, VF R12).
enum MatchModeKind {
  /// Round-based two-team modes: competitive, unrated, Swiftplay, Spike
  /// Rush, Premier, customs, Replication, Snowball, Skirmish, …
  standard,

  /// Free-for-all: every player is their own team; score = kills.
  deathmatch,

  /// Team Deathmatch (`hurm`): team `numPoints` is the real score.
  teamDeathmatch,

  /// Escalation (`ggteam`): one "round"; team `numPoints` = level reached.
  escalation;

  bool get isRoundBased => this == standard;

  /// Classifies by queue id (`console_*` tolerated), then by the game-mode
  /// directory key of `matchInfo.gameMode` (CA §9.2).
  static MatchModeKind classify(String? queueId, String? gameModePath) {
    final queue = baseQueueId(queueId);
    final key = gameModeKey(gameModePath);
    if (queue == 'deathmatch' || key == 'deathmatch') return deathmatch;
    if (queue == 'hurm' || key == 'hurm') return teamDeathmatch;
    if (queue == 'ggteam' || key == 'gungame') return escalation;
    return standard;
  }
}

/// How a round ended (`roundResultCode`, VF §8.8).
enum RoundEndType {
  elimination,
  detonate,
  defuse,
  timeExpired,
  surrendered,
  unknown;

  /// From `roundResultCode` (`Elimination`, `Detonate`, `Defuse`,
  /// `Surrendered`, `""` = timer) with `roundResult` text as fallback.
  static RoundEndType parse(String? code, String? text) {
    switch ((code ?? '').trim().toLowerCase()) {
      case 'elimination':
        return elimination;
      case 'detonate':
        return detonate;
      case 'defuse':
        return defuse;
      case 'surrendered':
        return surrendered;
    }
    final t = (text ?? '').trim().toLowerCase();
    if (t.contains('eliminat')) return elimination;
    if (t.contains('detonat')) return detonate;
    if (t.contains('defuse')) return defuse;
    if (t.contains('surrender')) return surrendered;
    if (t.contains('timer') || t.contains('time expired')) return timeExpired;
    return unknown;
  }
}

/// Side of a team in a round (`winningTeamRole`, 2026).
enum TeamRole {
  attacker,
  defender;

  TeamRole get opposite => this == attacker ? defender : attacker;

  static TeamRole? parse(String? value) =>
      switch ((value ?? '').trim().toLowerCase()) {
        'attacker' || 'attack' || 'attacking' => attacker,
        'defender' || 'defense' || 'defending' => defender,
        _ => null,
      };
}

// ------------------------------------------------------------------ info

/// P-14 `matchInfo`.
@immutable
class MatchInfo {
  const MatchInfo({
    required this.matchId,
    this.mapId,
    this.gameMode,
    this.queueId = '',
    this.startTime,
    this.gameLength,
    this.isCompleted = false,
    this.provisioningFlowId,
    this.customGameName,
    this.isRanked = false,
    this.seasonId,
    this.completionState,
    this.platformType,
    this.gameVersion,
  });

  static MatchInfo fromJson(Object? json, {String? fallbackMatchId}) {
    final m = asMap(json) ?? const <String, dynamic>{};
    final length = m.integer('gameLengthMillis');
    return MatchInfo(
      matchId: m.uuid('matchId') ?? lowerUuid(fallbackMatchId) ?? '',
      mapId: m.text('mapId'),
      gameMode: m.text('gameMode'),
      queueId: (m.str('queueID') ?? m.str('queueId') ?? '').trim(),
      startTime: m.dateTime('gameStartMillis'),
      gameLength: length == null || length <= 0
          ? null
          : Duration(milliseconds: length),
      isCompleted: m.boolean('isCompleted') ?? false,
      provisioningFlowId: m.text('provisioningFlowID'),
      customGameName: m.text('customGameName'),
      isRanked: m.boolean('isRanked') ?? false,
      seasonId: m.uuid('seasonId'),
      completionState: m.text('completionState'),
      platformType: m.text('platformType'),
      gameVersion: m.text('gameVersion'),
    );
  }

  /// Lowercase match uuid.
  final String matchId;

  /// Map path → `ContentDb.mapByUrl`.
  final String? mapId;

  /// Game-mode class path → `ContentDb.gameModeByPath`.
  final String? gameMode;

  /// Riot `queueID` (`""` for custom games) → `ContentDb.queueName`.
  final String queueId;
  final DateTime? startTime;

  /// `null` while the match is incomplete.
  final Duration? gameLength;
  final bool isCompleted;

  /// `Matchmaking` or `CustomGame`.
  final String? provisioningFlowId;
  final String? customGameName;
  final bool isRanked;

  /// Act uuid (lowercase): picks the tier table for `competitiveTier`.
  final String? seasonId;

  /// `Completed`, `Surrendered`, `VoteDraw`, …
  final String? completionState;
  final String? platformType;
  final String? gameVersion;

  /// Custom game (`queueID == ""` with `provisioningFlowID CustomGame`,
  /// SUMMARY §1 #17).
  bool get isCustom =>
      provisioningFlowId == 'CustomGame' ||
      queueId.isEmpty ||
      queueId.toLowerCase() == 'custom';

  MatchModeKind get modeKind => MatchModeKind.classify(queueId, gameMode);

  bool get isVoteDraw => completionState == 'VoteDraw';
  bool get isSurrendered => completionState == 'Surrendered';

  JsonMap toJson() => {
    'matchId': matchId,
    'mapId': ?mapId,
    'gameMode': ?gameMode,
    'queueID': queueId,
    'gameStartMillis': ?startTime?.millisecondsSinceEpoch,
    'gameLengthMillis': ?gameLength?.inMilliseconds,
    'isCompleted': isCompleted,
    'provisioningFlowID': ?provisioningFlowId,
    'customGameName': ?customGameName,
    'isRanked': isRanked,
    'seasonId': ?seasonId,
    'completionState': ?completionState,
    'platformType': ?platformType,
    'gameVersion': ?gameVersion,
  };
}

// ------------------------------------------------------------------ players

/// P-14 `players[].stats` (null for observers and unfinished customs).
@immutable
class PlayerStats {
  const PlayerStats({
    this.score = 0,
    this.roundsPlayed = 0,
    this.kills = 0,
    this.deaths = 0,
    this.assists = 0,
    this.playtimeMillis = 0,
    this.grenadeCasts = 0,
    this.ability1Casts = 0,
    this.ability2Casts = 0,
    this.ultimateCasts = 0,
  });

  static PlayerStats? fromJson(Object? json) {
    final m = asMap(json);
    if (m == null) return null;
    final casts = m.obj('abilityCasts');
    return PlayerStats(
      score: m.integer('score') ?? 0,
      roundsPlayed: m.integer('roundsPlayed') ?? 0,
      kills: m.integer('kills') ?? 0,
      deaths: m.integer('deaths') ?? 0,
      assists: m.integer('assists') ?? 0,
      playtimeMillis: m.integer('playtimeMillis') ?? 0,
      grenadeCasts: casts?.integer('grenadeCasts') ?? 0,
      ability1Casts: casts?.integer('ability1Casts') ?? 0,
      ability2Casts: casts?.integer('ability2Casts') ?? 0,
      ultimateCasts: casts?.integer('ultimateCasts') ?? 0,
    );
  }

  final int score;
  final int roundsPlayed;
  final int kills;
  final int deaths;
  final int assists;
  final int playtimeMillis;
  final int grenadeCasts;
  final int ability1Casts;
  final int ability2Casts;
  final int ultimateCasts;

  JsonMap toJson() => {
    'score': score,
    'roundsPlayed': roundsPlayed,
    'kills': kills,
    'deaths': deaths,
    'assists': assists,
    'playtimeMillis': playtimeMillis,
    'abilityCasts': {
      'grenadeCasts': grenadeCasts,
      'ability1Casts': ability1Casts,
      'ability2Casts': ability2Casts,
      'ultimateCasts': ultimateCasts,
    },
  };
}

/// P-14 `players[].roundDamage[]`: damage totals without hit locations.
@immutable
class RoundDamage {
  const RoundDamage({
    required this.round,
    required this.receiver,
    required this.damage,
  });

  static RoundDamage? fromJson(Object? json) {
    final m = asMap(json);
    final receiver = lowerUuid(m?['receiver']);
    if (m == null || receiver == null) return null;
    return RoundDamage(
      round: m.integer('round') ?? 0,
      receiver: receiver,
      damage: m.integer('damage') ?? 0,
    );
  }

  final int round;
  final String receiver;
  final int damage;

  JsonMap toJson() => {'round': round, 'receiver': receiver, 'damage': damage};
}

/// One P-14 `players[]` entry.
@immutable
class MatchPlayer {
  const MatchPlayer({
    required this.subject,
    this.name,
    this.teamId,
    this.partyId,
    this.characterId,
    this.stats,
    this.competitiveTier = 0,
    this.isObserver = false,
    this.playerCard,
    this.playerTitle,
    this.preferredLevelBorder,
    this.accountLevel = 0,
    this.platformType,
    this.roundDamage = const [],
  });

  static MatchPlayer? fromJson(Object? json) {
    final m = asMap(json);
    final subject = lowerUuid(m?['subject']);
    if (m == null || subject == null) return null;
    return MatchPlayer(
      subject: subject,
      name: RiotName.of(m.str('gameName'), m.str('tagLine')),
      teamId: normalizeRiotId(m['teamId']),
      partyId: m.uuid('partyId'),
      characterId: m.uuid('characterId'),
      stats: PlayerStats.fromJson(m['stats']),
      competitiveTier: m.integer('competitiveTier') ?? 0,
      isObserver: m.boolean('isObserver') ?? false,
      playerCard: m.uuid('playerCard'),
      playerTitle: m.uuid('playerTitle'),
      preferredLevelBorder: m.uuid('preferredLevelBorder'),
      accountLevel: m.integer('accountLevel') ?? 0,
      platformType:
          m.obj('platformInfo')?.text('platformType') ?? m.text('platformType'),
      roundDamage: List.unmodifiable([
        for (final d in m.list('roundDamage')) ?RoundDamage.fromJson(d),
      ]),
    );
  }

  /// Lowercase PUUID.
  final String subject;

  /// Blank in real 2026 responses (SUMMARY §1 #8): resolve with
  /// [NameResolver] (the match-details provider does it for you).
  final RiotName? name;

  /// `Red` / `Blue`; the player's PUUID in Deathmatch; `Neutral` for
  /// observers.
  final String? teamId;
  final String? partyId;

  /// Agent uuid.
  final String? characterId;
  final PlayerStats? stats;

  /// Tier at match time, in the table of `matchInfo.seasonId`.
  final int competitiveTier;
  final bool isObserver;
  final String? playerCard;
  final String? playerTitle;
  final String? preferredLevelBorder;
  final int accountLevel;
  final String? platformType;
  final List<RoundDamage> roundDamage;

  MatchPlayer withName(RiotName? name) => MatchPlayer(
    subject: subject,
    name: name,
    teamId: teamId,
    partyId: partyId,
    characterId: characterId,
    stats: stats,
    competitiveTier: competitiveTier,
    isObserver: isObserver,
    playerCard: playerCard,
    playerTitle: playerTitle,
    preferredLevelBorder: preferredLevelBorder,
    accountLevel: accountLevel,
    platformType: platformType,
    roundDamage: roundDamage,
  );

  JsonMap toJson() => {
    'subject': subject,
    'gameName': name?.gameName ?? '',
    'tagLine': name?.tagLine ?? '',
    'teamId': ?teamId,
    'partyId': ?partyId,
    'characterId': ?characterId,
    'stats': ?stats?.toJson(),
    'competitiveTier': competitiveTier,
    'isObserver': isObserver,
    'playerCard': ?playerCard,
    'playerTitle': ?playerTitle,
    'preferredLevelBorder': ?preferredLevelBorder,
    'accountLevel': accountLevel,
    if (platformType != null) 'platformInfo': {'platformType': platformType},
    if (roundDamage.isNotEmpty)
      'roundDamage': [for (final d in roundDamage) d.toJson()],
  };
}

/// P-14 `teams[]` (may be null in some customs; one entry per player in
/// Deathmatch).
@immutable
class MatchTeam {
  const MatchTeam({
    required this.teamId,
    this.won = false,
    this.roundsPlayed = 0,
    this.roundsWon = 0,
    this.numPoints = 0,
    this.mvp,
  });

  static MatchTeam? fromJson(Object? json) {
    final m = asMap(json);
    final id = normalizeRiotId(m?['teamId']);
    if (m == null || id == null) return null;
    return MatchTeam(
      teamId: id,
      won: m.boolean('won') ?? false,
      roundsPlayed: m.integer('roundsPlayed') ?? 0,
      roundsWon: m.integer('roundsWon') ?? 0,
      numPoints: m.integer('numPoints') ?? 0,
      mvp: m.uuid('mvp'),
    );
  }

  final String teamId;
  final bool won;
  final int roundsPlayed;
  final int roundsWon;

  /// Kills in Deathmatch, team kills in TDM, level in Escalation.
  final int numPoints;

  /// Team MVP PUUID (2026 field; often blank).
  final String? mvp;

  JsonMap toJson() => {
    'teamId': teamId,
    'won': won,
    'roundsPlayed': roundsPlayed,
    'roundsWon': roundsWon,
    'numPoints': numPoints,
    'mvp': ?mvp,
  };
}

// ------------------------------------------------------------------ rounds

/// Hits on one receiver in one round (`playerStats[].damage[]`).
@immutable
class DamageEvent {
  const DamageEvent({
    required this.receiver,
    this.damage = 0,
    this.headshots = 0,
    this.bodyshots = 0,
    this.legshots = 0,
  });

  static DamageEvent? fromJson(Object? json) {
    final m = asMap(json);
    final receiver = lowerUuid(m?['receiver']);
    if (m == null || receiver == null) return null;
    return DamageEvent(
      receiver: receiver,
      damage: m.integer('damage') ?? 0,
      headshots: m.integer('headshots') ?? 0,
      bodyshots: m.integer('bodyshots') ?? 0,
      legshots: m.integer('legshots') ?? 0,
    );
  }

  final String receiver;
  final int damage;
  final int headshots;
  final int bodyshots;
  final int legshots;

  int get hits => headshots + bodyshots + legshots;

  JsonMap toJson() => {
    'receiver': receiver,
    'damage': damage,
    'headshots': headshots,
    'bodyshots': bodyshots,
    'legshots': legshots,
  };
}

/// Loadout of one player in one round (`playerEconomies[]` or
/// `playerStats[].economy`).
@immutable
class RoundEconomy {
  const RoundEconomy({
    this.subject,
    this.loadoutValue = 0,
    this.weapon,
    this.armor,
    this.remaining = 0,
    this.spent = 0,
  });

  static RoundEconomy? fromJson(Object? json, {String? subject}) {
    final m = asMap(json);
    if (m == null) return null;
    return RoundEconomy(
      subject: m.uuid('subject') ?? subject,
      loadoutValue: m.integer('loadoutValue') ?? 0,
      weapon: m.uuid('weapon'),
      armor: m.uuid('armor'),
      remaining: m.integer('remaining') ?? 0,
      spent: m.integer('spent') ?? 0,
    );
  }

  final String? subject;
  final int loadoutValue;

  /// Weapon uuid (lowercased) → `ContentDb.weaponOrEquippable`.
  final String? weapon;

  /// Armor uuid (lowercased) → `ContentDb.gearItem`.
  final String? armor;
  final int remaining;
  final int spent;

  JsonMap toJson() => {
    'subject': ?subject,
    'loadoutValue': loadoutValue,
    'weapon': ?weapon,
    'armor': ?armor,
    'remaining': remaining,
    'spent': spent,
  };
}

/// One kill (top-level `kills[]`, or `roundResults[].playerStats[].kills[]`
/// when the top-level list is empty, as in 2026 responses).
@immutable
class Kill {
  const Kill({
    required this.round,
    required this.killer,
    required this.victim,
    this.gameTime = 0,
    this.roundTime = 0,
    this.assistants = const [],
    this.damageType,
    this.damageItem,
    this.isSecondaryFireMode = false,
  });

  static Kill? fromJson(Object? json, {int? round}) {
    final m = asMap(json);
    final killer = lowerUuid(m?['killer']);
    final victim = lowerUuid(m?['victim']);
    if (m == null || killer == null || victim == null) return null;
    final finishing = m.obj('finishingDamage');
    return Kill(
      round: m.integer('round') ?? round ?? 0,
      killer: killer,
      victim: victim,
      gameTime: m.integer('gameTime') ?? 0,
      roundTime: m.integer('roundTime') ?? 0,
      assistants: List.unmodifiable([
        for (final a in m.list('assistants')) ?lowerUuid(a),
      ]),
      damageType: finishing?.text('damageType'),
      damageItem: normalizeRiotId(finishing?['damageItem']),
      isSecondaryFireMode: finishing?.boolean('isSecondaryFireMode') ?? false,
    );
  }

  final int round;
  final String killer;
  final String victim;
  final int gameTime;

  /// Milliseconds since the round started.
  final int roundTime;
  final List<String> assistants;

  /// `Weapon`, `Ability`, `Bomb`, `Fall`, `Melee`, …
  final String? damageType;

  /// Lowercased weapon uuid, or `Ultimate` / `Ability1` / `Ability2` /
  /// `GrenadeAbility` / `Primary`.
  final String? damageItem;
  final bool isSecondaryFireMode;

  /// Weapon uuid → `ContentDb.weaponOrEquippable` (`null` for abilities).
  String? get weaponId => isUuid(damageItem) ? damageItem : null;

  /// valorant-api ability slot for `Agent.ability(slot)` (`GrenadeAbility`
  /// ↔ `Grenade`, SUMMARY §9.8); `null` for weapons and unknown items.
  String? get abilitySlot => switch (damageItem) {
    'GrenadeAbility' => 'Grenade',
    'Ability1' => 'Ability1',
    'Ability2' => 'Ability2',
    'Ultimate' => 'Ultimate',
    _ => null,
  };

  JsonMap toJson() => {
    'round': round,
    'gameTime': gameTime,
    'roundTime': roundTime,
    'killer': killer,
    'victim': victim,
    'assistants': assistants,
    'finishingDamage': {
      'damageType': ?damageType,
      'damageItem': ?damageItem,
      'isSecondaryFireMode': isSecondaryFireMode,
    },
  };
}

/// `roundResults[].playerStats[]` (kills live in [MatchDetails.kills]).
@immutable
class RoundPlayerStats {
  const RoundPlayerStats({
    required this.subject,
    this.damage = const [],
    this.score = 0,
    this.economy,
    this.wasAfk = false,
    this.wasPenalized = false,
    this.stayedInSpawn = false,
  });

  static RoundPlayerStats? fromJson(Object? json) {
    final m = asMap(json);
    final subject = lowerUuid(m?['subject']);
    if (m == null || subject == null) return null;
    return RoundPlayerStats(
      subject: subject,
      damage: List.unmodifiable([
        for (final d in m.list('damage')) ?DamageEvent.fromJson(d),
      ]),
      score: m.integer('score') ?? 0,
      economy: RoundEconomy.fromJson(m['economy'], subject: subject),
      wasAfk: m.boolean('wasAfk') ?? false,
      wasPenalized: m.boolean('wasPenalized') ?? false,
      stayedInSpawn: m.boolean('stayedInSpawn') ?? false,
    );
  }

  final String subject;
  final List<DamageEvent> damage;
  final int score;
  final RoundEconomy? economy;
  final bool wasAfk;
  final bool wasPenalized;
  final bool stayedInSpawn;

  JsonMap toJson() => {
    'subject': subject,
    if (damage.isNotEmpty) 'damage': [for (final d in damage) d.toJson()],
    'score': score,
    'economy': ?economy?.toJson(),
    'wasAfk': wasAfk,
    'wasPenalized': wasPenalized,
    'stayedInSpawn': stayedInSpawn,
  };
}

/// One P-14 `roundResults[]` entry.
@immutable
class RoundResult {
  const RoundResult({
    required this.roundNum,
    this.roundResult,
    this.roundResultCode,
    this.ceremony,
    this.winningTeam,
    this.winningTeamRole,
    this.bombPlanter,
    this.bombDefuser,
    this.plantRoundTime,
    this.defuseRoundTime,
    this.plantSite,
    this.firstBloodPlayer,
    this.playerStats = const [],
    this.playerEconomies = const [],
  });

  static RoundResult? fromJson(Object? json) {
    final m = asMap(json);
    final n = asInt(m?['roundNum']);
    if (m == null || n == null) return null;
    final plantTime = m.integer('plantRoundTime');
    final defuseTime = m.integer('defuseRoundTime');
    return RoundResult(
      roundNum: n,
      roundResult: m.text('roundResult'),
      roundResultCode: m.text('roundResultCode'),
      ceremony: m.text('roundCeremony'),
      winningTeam: normalizeRiotId(m['winningTeam']),
      winningTeamRole: TeamRole.parse(m.str('winningTeamRole')),
      bombPlanter: m.uuid('bombPlanter'),
      bombDefuser: m.uuid('bombDefuser'),
      plantRoundTime: plantTime != null && plantTime > 0 ? plantTime : null,
      defuseRoundTime: defuseTime != null && defuseTime > 0 ? defuseTime : null,
      plantSite: m.text('plantSite'),
      firstBloodPlayer: m.uuid('firstBloodPlayer'),
      playerStats: List.unmodifiable([
        for (final p in m.list('playerStats')) ?RoundPlayerStats.fromJson(p),
      ]),
      playerEconomies: List.unmodifiable([
        for (final e in m.list('playerEconomies')) ?RoundEconomy.fromJson(e),
      ]),
    );
  }

  /// 0-based.
  final int roundNum;

  /// Raw text (`Eliminated`, `Bomb detonated`, …).
  final String? roundResult;

  /// Raw code (`Elimination`, `Detonate`, `Defuse`, `Surrendered`, `""`).
  final String? roundResultCode;

  /// `CeremonyAce`, `CeremonyClutch`, … → `ContentDb.ceremony`.
  final String? ceremony;
  final String? winningTeam;

  /// Side of the winning team (2026 field; `null` when absent).
  final TeamRole? winningTeamRole;
  final String? bombPlanter;
  final String? bombDefuser;
  final int? plantRoundTime;
  final int? defuseRoundTime;

  /// `A` / `B` / `C` (`null` when not planted).
  final String? plantSite;

  /// First-blood PUUID (2026 field; computed from kills when absent).
  final String? firstBloodPlayer;
  final List<RoundPlayerStats> playerStats;

  /// Filled only in competitive (EP §11.2); see [economyFor].
  final List<RoundEconomy> playerEconomies;

  RoundEndType get endType => RoundEndType.parse(roundResultCode, roundResult);

  RoundPlayerStats? statsFor(String subject) {
    final id = subject.toLowerCase();
    for (final s in playerStats) {
      if (s.subject == id) return s;
    }
    return null;
  }

  /// Loadout of [subject]: `playerEconomies` first, then
  /// `playerStats[].economy`.
  RoundEconomy? economyFor(String subject) {
    final id = subject.toLowerCase();
    for (final e in playerEconomies) {
      if (e.subject == id) return e;
    }
    return statsFor(id)?.economy;
  }

  /// Side of [teamId] in this round, derived from [winningTeamRole].
  TeamRole? roleOf(String? teamId) {
    final role = winningTeamRole;
    if (role == null || teamId == null || winningTeam == null) return null;
    return teamId == winningTeam ? role : role.opposite;
  }

  JsonMap toJson() => {
    'roundNum': roundNum,
    'roundResult': ?roundResult,
    'roundResultCode': ?roundResultCode,
    'roundCeremony': ?ceremony,
    'winningTeam': ?winningTeam,
    if (winningTeamRole != null)
      'winningTeamRole': switch (winningTeamRole!) {
        TeamRole.attacker => 'Attacker',
        TeamRole.defender => 'Defender',
      },
    'bombPlanter': ?bombPlanter,
    'bombDefuser': ?bombDefuser,
    'plantRoundTime': ?plantRoundTime,
    'defuseRoundTime': ?defuseRoundTime,
    'plantSite': ?plantSite,
    'firstBloodPlayer': ?firstBloodPlayer,
    'playerStats': [for (final s in playerStats) s.toJson()],
    if (playerEconomies.isNotEmpty)
      'playerEconomies': [for (final e in playerEconomies) e.toJson()],
  };
}

// ------------------------------------------------------------------ results

/// Scoreboard line of one player (SUMMARY §9.8), computed from P-14.
@immutable
class ScoreboardStats {
  const ScoreboardStats({
    required this.subject,
    this.kills = 0,
    this.deaths = 0,
    this.assists = 0,
    this.score = 0,
    this.roundsPlayed = 0,
    this.acs,
    this.adr,
    this.headshotRate,
    this.damage = 0,
    this.headshots = 0,
    this.bodyshots = 0,
    this.legshots = 0,
    this.firstBloods = 0,
    this.firstDeaths = 0,
    this.kast,
    this.placement = 0,
    this.isMatchMvp = false,
    this.isTeamMvp = false,
  });

  final String subject;
  final int kills;
  final int deaths;
  final int assists;
  final int score;
  final int roundsPlayed;

  /// Average combat score = score / rounds (`null` without rounds).
  final double? acs;

  /// Average damage per round to enemies (`null` in non-round modes or
  /// without damage data).
  final double? adr;

  /// Headshots / all hits, 0–1; `null` without hit data → show "–" (R12).
  final double? headshotRate;

  /// Damage dealt to enemies over the match.
  final int damage;
  final int headshots;
  final int bodyshots;
  final int legshots;
  final int firstBloods;
  final int firstDeaths;

  /// Share of rounds with a kill, assist, survival or traded death (0–1);
  /// `null` in non-round modes.
  final double? kast;

  /// 1 = highest combat score in the match.
  final int placement;
  final bool isMatchMvp;
  final bool isTeamMvp;

  /// K − D (the "+/−" column).
  int get plusMinus => kills - deaths;

  /// Kills per death (deaths floored at 1).
  double get kd => kills / math.max(deaths, 1);

  bool get hasHitData => headshots + bodyshots + legshots > 0;
}

/// Result of a match for one player (VF R12).
@immutable
class MatchResult {
  const MatchResult({
    required this.outcome,
    this.myScore,
    this.otherScore,
    this.placement,
  });

  static const unknown = MatchResult(outcome: MatchOutcome.unknown);

  final MatchOutcome outcome;

  /// Rounds (standard), team points (TDM, Escalation) or kills (DM) of the
  /// player's side: the "13" in "13 – 7".
  final int? myScore;

  /// The other team's score; in Deathmatch the best other player's kills.
  final int? otherScore;

  /// Free-for-all position by kills (1 = winner); `null` in team modes.
  final int? placement;

  bool get hasScore => myScore != null && otherScore != null;
}

/// What a match list card needs for one player (R8).
@immutable
class MatchPlayerSummary {
  const MatchPlayerSummary({
    required this.info,
    required this.player,
    required this.result,
    required this.stats,
  });

  final MatchInfo info;
  final MatchPlayer player;
  final MatchResult result;
  final ScoreboardStats stats;

  String get matchId => info.matchId;
  String? get agentId => player.characterId;
}

// ------------------------------------------------------------------ details

/// Typed P-14 match details (EP §11.2). Parsing never throws; unknown or
/// malformed parts become empty lists / `null`.
///
/// [toJson] writes a compact copy with Riot's keys (no positions, no
/// behaviour data), which [MatchDetails.fromJson] reads back: that is what
/// the disk cache stores.
class MatchDetails {
  MatchDetails({
    required this.info,
    this.players = const [],
    this.teams = const [],
    this.rounds = const [],
    this.kills = const [],
    this.matchMvp,
  });

  factory MatchDetails.fromJson(Object? json, {String? matchId}) {
    final m = asMap(json) ?? const <String, dynamic>{};
    final rounds = [
      for (final r in m.list('roundResults')) ?RoundResult.fromJson(r),
    ]..sort((a, b) => a.roundNum.compareTo(b.roundNum));
    var kills = [for (final k in m.list('kills')) ?Kill.fromJson(k)];
    if (kills.isEmpty) {
      // 2026: the top-level list is often empty; kills are per round.
      for (final r in asMapList(m['roundResults'])) {
        final n = asInt(r['roundNum']) ?? 0;
        for (final p in asMapList(r['playerStats'])) {
          for (final k in p.list('kills')) {
            final kill = Kill.fromJson(k, round: n);
            if (kill != null) kills.add(kill);
          }
        }
      }
    }
    kills = kills
      ..sort((a, b) {
        final c = a.round.compareTo(b.round);
        return c != 0 ? c : a.roundTime.compareTo(b.roundTime);
      });
    return MatchDetails(
      info: MatchInfo.fromJson(m['matchInfo'], fallbackMatchId: matchId),
      players: List.unmodifiable([
        for (final p in m.list('players')) ?MatchPlayer.fromJson(p),
      ]),
      teams: List.unmodifiable([
        for (final t in m.list('teams')) ?MatchTeam.fromJson(t),
      ]),
      rounds: List.unmodifiable(rounds),
      kills: List.unmodifiable(kills),
      matchMvp: m.uuid('matchMvp'),
    );
  }

  final MatchInfo info;
  final List<MatchPlayer> players;
  final List<MatchTeam> teams;

  /// Sorted by round number.
  final List<RoundResult> rounds;

  /// Sorted by round, then time in round.
  final List<Kill> kills;

  /// Match MVP PUUID (2026 field; computed by score when absent).
  final String? matchMvp;

  String get matchId => info.matchId;
  MatchModeKind get modeKind => info.modeKind;

  /// Players who played (observers excluded).
  List<MatchPlayer> get participants =>
      players.where((p) => !p.isObserver).toList(growable: false);

  MatchPlayer? player(String? puuid) {
    if (puuid == null) return null;
    final id = puuid.trim().toLowerCase();
    for (final p in players) {
      if (p.subject == id) return p;
    }
    return null;
  }

  MatchTeam? team(String? teamId) {
    if (teamId == null) return null;
    for (final t in teams) {
      if (t.teamId == teamId) return t;
    }
    return null;
  }

  /// PUUIDs whose Riot ID arrived blank (resolve them via name-service).
  List<String> get unnamedSubjects => [
    for (final p in players)
      if (p.name == null || p.name!.isBlank) p.subject,
  ];

  /// A copy with names filled in for players whose name was blank.
  MatchDetails withNames(Map<String, RiotName> names) {
    if (names.isEmpty) return this;
    return MatchDetails(
      info: info,
      players: List.unmodifiable([
        for (final p in players)
          (p.name == null || p.name!.isBlank) && names[p.subject] != null
              ? p.withName(names[p.subject])
              : p,
      ]),
      teams: teams,
      rounds: rounds,
      kills: kills,
      matchMvp: matchMvp,
    );
  }

  /// A copy in which the players in [subjects] have no name (Incognito
  /// players must show as anonymous everywhere, SUMMARY U16). Returns `this`
  /// when nobody changes.
  MatchDetails withoutNames(Set<String> subjects) {
    if (subjects.isEmpty || !players.any((p) => subjects.contains(p.subject))) {
      return this;
    }
    return MatchDetails(
      info: info,
      players: List.unmodifiable([
        for (final p in players)
          subjects.contains(p.subject) ? p.withName(null) : p,
      ]),
      teams: teams,
      rounds: rounds,
      kills: kills,
      matchMvp: matchMvp,
    );
  }

  /// Rounds actually played: the rounds a surrender awards to the winner
  /// (`roundResultCode == Surrendered`, no kills) are left out.
  List<RoundResult> get playedRounds => [
    for (final r in rounds)
      if (r.endType != RoundEndType.surrendered ||
          kills.any((k) => k.round == r.roundNum))
        r,
  ];

  List<Kill> killsInRound(int roundNum) =>
      kills.where((k) => k.round == roundNum).toList(growable: false);

  // ---------------------------------------------------------- stats (§9.8)

  late final Map<String, ScoreboardStats> _stats = _computeStats();

  /// Scoreboard line of [puuid] (`null` when not a participant).
  ScoreboardStats? statsFor(String? puuid) =>
      puuid == null ? null : _stats[puuid.trim().toLowerCase()];

  /// Scoreboard lines of every participant, best combat score first.
  List<ScoreboardStats> get scoreboard =>
      _stats.values.toList()
        ..sort((a, b) => a.placement.compareTo(b.placement));

  /// Participants of [teamId], best combat score first.
  List<MatchPlayer> playersOfTeam(String? teamId) {
    final list = participants.where((p) => p.teamId == teamId).toList();
    list.sort(
      (a, b) => (statsFor(a.subject)?.placement ?? 0).compareTo(
        statsFor(b.subject)?.placement ?? 0,
      ),
    );
    return list;
  }

  /// Team ids in display order: two-team modes → the teams that have
  /// players (the order of `teams[]`, else of `players[]`).
  List<String> get sideIds {
    final seen = <String>[];
    for (final t in teams) {
      if (!seen.contains(t.teamId)) seen.add(t.teamId);
    }
    for (final p in participants) {
      final t = p.teamId;
      if (t != null && !seen.contains(t)) seen.add(t);
    }
    return seen;
  }

  Map<String, ScoreboardStats> _computeStats() {
    final kind = modeKind;
    final roundBased = kind.isRoundBased && rounds.isNotEmpty;
    final ffa = kind == MatchModeKind.deathmatch;
    final teamOf = {for (final p in players) p.subject: p.teamId};
    final participants = this.participants;

    bool isEnemy(String attacker, String receiver) {
      if (attacker == receiver) return false;
      if (ffa) return true;
      final a = teamOf[attacker];
      final b = teamOf[receiver];
      return a == null || b == null || a != b;
    }

    // Damage / hits from round player stats (hit locations known).
    final dmg = <String, int>{};
    final head = <String, int>{};
    final body = <String, int>{};
    final leg = <String, int>{};
    var anyHitData = false;
    for (final r in rounds) {
      for (final ps in r.playerStats) {
        for (final d in ps.damage) {
          anyHitData = true;
          if (!isEnemy(ps.subject, d.receiver)) continue;
          dmg[ps.subject] = (dmg[ps.subject] ?? 0) + d.damage;
          head[ps.subject] = (head[ps.subject] ?? 0) + d.headshots;
          body[ps.subject] = (body[ps.subject] ?? 0) + d.bodyshots;
          leg[ps.subject] = (leg[ps.subject] ?? 0) + d.legshots;
        }
      }
    }
    // Fallback: players[].roundDamage (totals only).
    var anyDamageData = anyHitData;
    if (!anyHitData) {
      for (final p in players) {
        for (final d in p.roundDamage) {
          anyDamageData = true;
          if (!isEnemy(p.subject, d.receiver)) continue;
          dmg[p.subject] = (dmg[p.subject] ?? 0) + d.damage;
        }
      }
    }

    // First bloods / deaths per round.
    final firstBloods = <String, int>{};
    final firstDeaths = <String, int>{};
    final killsByRound = <int, List<Kill>>{};
    for (final k in kills) {
      (killsByRound[k.round] ??= []).add(k);
    }
    if (roundBased) {
      for (final r in playedRounds) {
        final roundKills = killsByRound[r.roundNum] ?? const <Kill>[];
        final first = roundKills.isEmpty ? null : roundKills.first;
        final fb = r.firstBloodPlayer ?? first?.killer;
        if (fb != null) firstBloods[fb] = (firstBloods[fb] ?? 0) + 1;
        if (first != null) {
          firstDeaths[first.victim] = (firstDeaths[first.victim] ?? 0) + 1;
        }
      }
    }

    // Placement by score (then kills).
    final ranked = [...participants]
      ..sort((a, b) {
        final c = (b.stats?.score ?? 0).compareTo(a.stats?.score ?? 0);
        return c != 0
            ? c
            : (b.stats?.kills ?? 0).compareTo(a.stats?.kills ?? 0);
      });
    final placement = {
      for (var i = 0; i < ranked.length; i++) ranked[i].subject: i + 1,
    };
    String? matchMvpId;
    final teamMvp = <String, String>{};
    final hasScores = ranked.any((p) => (p.stats?.score ?? 0) > 0);
    if (!ffa && ranked.isNotEmpty && info.isCompleted && hasScores) {
      matchMvpId = matchMvp != null && placement.containsKey(matchMvp)
          ? matchMvp
          : ranked.first.subject;
      for (final t in teams) {
        final explicit = t.mvp;
        if (explicit != null && placement.containsKey(explicit)) {
          teamMvp[t.teamId] = explicit;
        }
      }
      for (final p in ranked) {
        final t = p.teamId;
        if (t != null) teamMvp.putIfAbsent(t, () => p.subject);
      }
    }

    final out = <String, ScoreboardStats>{};
    for (final p in participants) {
      final s = p.stats;
      final played = s?.roundsPlayed ?? 0;
      final id = p.subject;
      final h = head[id] ?? 0;
      final b = body[id] ?? 0;
      final l = leg[id] ?? 0;
      final hits = h + b + l;
      out[id] = ScoreboardStats(
        subject: id,
        kills: s?.kills ?? 0,
        deaths: s?.deaths ?? 0,
        assists: s?.assists ?? 0,
        score: s?.score ?? 0,
        roundsPlayed: played,
        // A per-round average: without rounds (Deathmatch reports one
        // "round") it would only repeat the total score.
        acs: kind.isRoundBased && played > 0 ? (s?.score ?? 0) / played : null,
        adr: roundBased && anyDamageData && played > 0
            ? (dmg[id] ?? 0) / played
            : null,
        headshotRate: hits > 0 ? h / hits : null,
        damage: dmg[id] ?? 0,
        headshots: h,
        bodyshots: b,
        legshots: l,
        firstBloods: firstBloods[id] ?? 0,
        firstDeaths: firstDeaths[id] ?? 0,
        kast: roundBased ? _kast(p, killsByRound) : null,
        placement: placement[id] ?? 0,
        isMatchMvp: matchMvpId == id,
        isTeamMvp: matchMvpId != id && teamMvp[p.teamId] == id,
      );
    }
    return out;
  }

  /// KAST: rounds with a kill, an assist, survival, or a death traded by a
  /// teammate within 5 s.
  double? _kast(MatchPlayer p, Map<int, List<Kill>> killsByRound) {
    final id = p.subject;
    final played = playedRounds
        .where((r) => r.playerStats.isEmpty || r.statsFor(id) != null)
        .toList();
    if (played.isEmpty) return null;
    var counted = 0;
    for (final r in played) {
      final ks = killsByRound[r.roundNum] ?? const <Kill>[];
      if (ks.any((k) => k.killer == id || k.assistants.contains(id))) {
        counted++;
        continue;
      }
      Kill? death;
      for (final k in ks) {
        if (k.victim == id) {
          death = k;
          break;
        }
      }
      if (death == null) {
        counted++;
        continue;
      }
      final d = death;
      final traded = ks.any(
        (k) =>
            k.victim == d.killer &&
            k.roundTime >= d.roundTime &&
            k.roundTime - d.roundTime <= 5000 &&
            k.killer != id &&
            player(k.killer)?.teamId == p.teamId,
      );
      if (traded) counted++;
    }
    return counted / played.length;
  }

  // ---------------------------------------------------------- result

  /// Team score: team points in TDM / Escalation; rounds won otherwise,
  /// except after a surrender, where `roundsWon` includes the rounds awarded
  /// to the winner and `numPoints` keeps the rounds actually won.
  int _teamScore(MatchTeam t) => switch (modeKind) {
    MatchModeKind.teamDeathmatch || MatchModeKind.escalation => t.numPoints,
    _ when info.isSurrendered => t.numPoints,
    _ =>
      t.roundsWon == 0 && t.roundsPlayed <= 1 && t.numPoints > 0
          ? t.numPoints
          : t.roundsWon,
  };

  /// Rounds won per team id, from `teams[]` or (when absent) counted from
  /// `roundResults[].winningTeam`.
  Map<String, int> get _teamScores {
    if (teams.isNotEmpty) {
      return {for (final t in teams) t.teamId: _teamScore(t)};
    }
    final out = <String, int>{for (final id in sideIds) id: 0};
    for (final r in rounds) {
      final w = r.winningTeam;
      if (w != null) out[w] = (out[w] ?? 0) + 1;
    }
    return out;
  }

  /// The score of team [teamId] as the result screens show it: rounds won
  /// (team points in Team Deathmatch / Escalation; after a surrender the
  /// rounds actually won). `null` for an unknown team.
  int? teamScore(String? teamId) => teamId == null ? null : _teamScores[teamId];

  /// Result for [puuid] (VF R12):
  /// - team modes: `teams[].won` (draw when neither won with equal scores
  ///   or `VoteDraw`); score = rounds won, team points in TDM/Escalation;
  /// - Deathmatch: your kills vs the best other player's kills.
  ///
  /// For a spectator / unknown player the outcome is `unknown` and the score
  /// is the first side vs the second.
  MatchResult resultFor(String? puuid) {
    final me = player(puuid);
    if (modeKind == MatchModeKind.deathmatch) return _deathmatchResult(me);
    final scores = _teamScores;
    final sides = sideIds.where(scores.containsKey).toList();
    if (me == null || me.isObserver || !scores.containsKey(me.teamId)) {
      if (sides.length < 2) return MatchResult.unknown;
      return MatchResult(
        outcome: MatchOutcome.unknown,
        myScore: scores[sides[0]],
        otherScore: scores[sides[1]],
      );
    }
    final mine = me.teamId!;
    final others = sides.where((t) => t != mine).toList();
    final myScore = scores[mine];
    final otherScore = others.isEmpty
        ? null
        : others.map((t) => scores[t] ?? 0).reduce(math.max);
    MatchOutcome outcome;
    final myTeam = team(mine);
    final otherWon = others.any((t) => team(t)?.won ?? false);
    if (!info.isCompleted && info.completionState != 'Completed') {
      outcome = MatchOutcome.unknown;
    } else if (info.isVoteDraw) {
      outcome = MatchOutcome.draw;
    } else if (myTeam?.won ?? false) {
      outcome = MatchOutcome.win;
    } else if (otherWon) {
      outcome = MatchOutcome.loss;
    } else if (myScore != null && otherScore != null) {
      outcome = teams.isEmpty
          ? (myScore > otherScore
                ? MatchOutcome.win
                : myScore < otherScore
                ? MatchOutcome.loss
                : MatchOutcome.draw)
          : (myScore == otherScore ? MatchOutcome.draw : MatchOutcome.unknown);
    } else {
      outcome = MatchOutcome.unknown;
    }
    return MatchResult(
      outcome: outcome,
      myScore: myScore,
      otherScore: otherScore,
    );
  }

  MatchResult _deathmatchResult(MatchPlayer? me) {
    int killsOf(MatchPlayer p) {
      final t = team(p.teamId ?? p.subject) ?? team(p.subject);
      return p.stats?.kills ?? t?.numPoints ?? 0;
    }

    final players = participants;
    if (me == null || me.isObserver || players.isEmpty) {
      return MatchResult.unknown;
    }
    final ranked = [...players]
      ..sort((a, b) {
        final c = killsOf(b).compareTo(killsOf(a));
        return c != 0
            ? c
            : (b.stats?.score ?? 0).compareTo(a.stats?.score ?? 0);
      });
    final mine = killsOf(me);
    final others = players.where((p) => p.subject != me.subject);
    final best = others.isEmpty ? null : others.map(killsOf).reduce(math.max);
    final myTeam = team(me.teamId) ?? team(me.subject);
    final anyWon = teams.any((t) => t.won);
    MatchOutcome outcome;
    if (!info.isCompleted && info.completionState != 'Completed') {
      outcome = MatchOutcome.unknown;
    } else if (myTeam?.won ?? false) {
      outcome = MatchOutcome.win;
    } else if (anyWon) {
      outcome = MatchOutcome.loss;
    } else if (best == null || mine > best) {
      outcome = MatchOutcome.win;
    } else {
      outcome = mine == best ? MatchOutcome.draw : MatchOutcome.loss;
    }
    return MatchResult(
      outcome: outcome,
      myScore: mine,
      otherScore: best,
      placement: ranked.indexWhere((p) => p.subject == me.subject) + 1,
    );
  }

  /// Everything a match-list card shows for [puuid] (`null` when the player
  /// is not in the match).
  MatchPlayerSummary? summaryFor(String? puuid) {
    final me = player(puuid);
    if (me == null) return null;
    return MatchPlayerSummary(
      info: info,
      player: me,
      result: resultFor(me.subject),
      stats: statsFor(me.subject) ?? ScoreboardStats(subject: me.subject),
    );
  }

  // ---------------------------------------------------------- serialisation

  JsonMap toJson() => {
    'matchInfo': info.toJson(),
    'players': [for (final p in players) p.toJson()],
    'teams': [for (final t in teams) t.toJson()],
    'roundResults': [for (final r in rounds) r.toJson()],
    'kills': [for (final k in kills) k.toJson()],
    'matchMvp': ?matchMvp,
  };
}
