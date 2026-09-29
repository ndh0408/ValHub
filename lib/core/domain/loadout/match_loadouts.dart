/// Everyone's loadout in agent select (G-7) or in a running match (G-10),
/// read from the socket maps (SUMMARY §7.1, §8.6 G8; EP §7.4), plus the
/// `PlayerIdentity` of the pregame (G-3) / core-game (G-9) match.
library;

import 'package:flutter/foundation.dart';

import '../../riot/riot_ids.dart';
import '../../util/json.dart';
import 'loadout_models.dart';

/// Socket ids of `Items.{weaponId}.Sockets` (VRY; EP §7.4).
abstract final class MatchSocketIds {
  static const skin = LoadoutSocketIds.skin;
  static const skinLevel = ItemTypeIds.skinLevel;
  static const chroma = ItemTypeIds.skinChroma;
  static const buddy = LoadoutSocketIds.buddy;
  static const buddyLevel = ItemTypeIds.buddyLevel;
}

/// One weapon of a match loadout.
@immutable
class MatchGun {
  const MatchGun({
    required this.weaponId,
    this.skinId,
    this.skinLevelId,
    this.chromaId,
    this.buddyId,
    this.buddyLevelId,
  });

  final String weaponId;
  final String? skinId;
  final String? skinLevelId;
  final String? chromaId;
  final String? buddyId;
  final String? buddyLevelId;

  bool get hasBuddy => buddyId != null || buddyLevelId != null;

  @override
  bool operator ==(Object other) =>
      other is MatchGun &&
      other.weaponId == weaponId &&
      other.skinId == skinId &&
      other.skinLevelId == skinLevelId &&
      other.chromaId == chromaId &&
      other.buddyId == buddyId &&
      other.buddyLevelId == buddyLevelId;

  @override
  int get hashCode => Object.hash(
    weaponId,
    skinId,
    skinLevelId,
    chromaId,
    buddyId,
    buddyLevelId,
  );
}

/// `PlayerIdentity` of a live-game player (G-3 / G-9).
@immutable
class MatchPlayerIdentity {
  const MatchPlayerIdentity({
    required this.subject,
    this.characterId,
    this.teamId,
    this.identity = const LoadoutIdentity(),
    this.incognito = false,
  });

  final String subject;
  final String? characterId;
  final String? teamId;

  /// Card, title, level border, hide-level flag and account level.
  final LoadoutIdentity identity;
  final bool incognito;
}

/// What one player has equipped (S51 "Trang bị của người chơi").
@immutable
class MatchPlayerLoadout {
  const MatchPlayerLoadout({
    required this.subject,
    this.characterId,
    this.teamId,
    this.guns = const {},
    this.expressions = const [],
    this.identity,
    this.incognito = false,
  });

  final String subject;

  /// Agent uuid ("" before hovering in agent select → `null`).
  final String? characterId;
  final String? teamId;

  /// Weapon uuid → equipped skin / buddy.
  final Map<String, MatchGun> guns;

  /// Sprays and flex in wheel order.
  final List<Expression> expressions;

  /// From the match payload when it was given (`null` otherwise).
  final LoadoutIdentity? identity;

  /// Honour it in the UI: hide the name (SUMMARY U16).
  final bool incognito;

  MatchGun? gun(String weaponId) => guns[weaponId.trim().toLowerCase()];

  /// Spray uuids in wheel order.
  List<String> get sprayIds => [
    for (final e in expressions)
      if (e.isSpray && !e.isEmpty) e.assetId,
  ];

  List<String> get flexIds => [
    for (final e in expressions)
      if (e.isFlex) e.assetId,
  ];

  String? get playerCardId => identity?.playerCardId;
  String? get playerTitleId => identity?.playerTitleId;

  MatchPlayerLoadout withIdentity(MatchPlayerIdentity? id) => id == null
      ? this
      : MatchPlayerLoadout(
          subject: subject,
          characterId: characterId ?? id.characterId,
          teamId: teamId ?? id.teamId,
          guns: guns,
          expressions: expressions,
          identity: id.identity,
          incognito: id.incognito,
        );
}

/// Parsed G-7 / G-10 response keyed by lowercase PUUID.
@immutable
class MatchLoadouts {
  const MatchLoadouts(this.players);

  static const empty = MatchLoadouts({});

  /// Parses a loadouts body (both shapes: core-game `Loadouts[].{CharacterID,
  /// Loadout}` and pregame `Loadouts[]` = loadout objects), merging the
  /// identities of [matchJson] (G-3 or G-9) when given. Never throws.
  factory MatchLoadouts.parse(Object? loadoutsJson, {Object? matchJson}) {
    final identities = parseIdentities(matchJson);
    final players = <String, MatchPlayerLoadout>{};
    for (final entry in asMapList(asMap(loadoutsJson)?['Loadouts'])) {
      final player = parsePlayer(entry);
      if (player == null) continue;
      players[player.subject] = player.withIdentity(identities[player.subject]);
    }
    return MatchLoadouts(Map.unmodifiable(players));
  }

  final Map<String, MatchPlayerLoadout> players;

  MatchPlayerLoadout? player(String puuid) =>
      players[puuid.trim().toLowerCase()];

  bool get isEmpty => players.isEmpty;

  /// One `Loadouts[]` entry; `null` without a subject.
  static MatchPlayerLoadout? parsePlayer(Object? json) {
    final entry = asMap(json);
    if (entry == null) return null;
    final loadout = asMap(entry['Loadout']) ?? entry;
    final subject = _id(loadout['Subject']) ?? _id(entry['Subject']);
    if (subject == null) return null;
    final guns = <String, MatchGun>{};
    final items = asMap(loadout['Items']) ?? const <String, dynamic>{};
    for (final item in items.entries) {
      final value = asMap(item.value);
      final weapon = _id(value?['ID']) ?? _id(item.key);
      if (value == null || weapon == null) continue;
      final sockets = <String, JsonMap>{};
      for (final s in (asMap(value['Sockets']) ?? const {}).entries) {
        final socket = asMap(s.value);
        if (socket == null) continue;
        sockets[_id(socket['ID']) ?? s.key.toLowerCase()] = socket;
      }
      String? socketItem(String socketId) =>
          _id(asMap(sockets[socketId]?['Item'])?['ID']);
      guns[weapon] = MatchGun(
        weaponId: weapon,
        skinId: socketItem(MatchSocketIds.skin),
        skinLevelId: socketItem(MatchSocketIds.skinLevel),
        chromaId: socketItem(MatchSocketIds.chroma),
        buddyId: socketItem(MatchSocketIds.buddy),
        buddyLevelId: socketItem(MatchSocketIds.buddyLevel),
      );
    }
    final expressions = <Expression>[
      for (final raw in asList(asMap(loadout['Expressions'])?['AESSelections']))
        ?Expression.fromJson(raw),
    ];
    if (expressions.isEmpty) {
      // Pre-10.00 shape: Sprays.SpraySelections[{SocketID, SprayID, LevelID}].
      for (final raw in asList(asMap(loadout['Sprays'])?['SpraySelections'])) {
        if (Expression.fromJson(raw) case final e?) expressions.add(e);
      }
    }
    return MatchPlayerLoadout(
      subject: subject,
      characterId: _id(entry['CharacterID']) ?? _id(loadout['CharacterID']),
      guns: Map.unmodifiable(guns),
      expressions: List.unmodifiable(expressions),
      identity: asMap(loadout['Identity']) == null
          ? null
          : LoadoutIdentity.fromJson(loadout['Identity']),
      incognito: asBool(loadout['Incognito']) ?? false,
    );
  }

  /// `PlayerIdentity` per PUUID from a pregame (`AllyTeam`, `EnemyTeam`,
  /// `Teams[]`) or core-game (`Players[]`) match. Never throws.
  static Map<String, MatchPlayerIdentity> parseIdentities(Object? matchJson) {
    final match = asMap(matchJson);
    if (match == null) return const {};
    final out = <String, MatchPlayerIdentity>{};
    void addPlayers(Object? players, {String? teamId}) {
      for (final p in asMapList(players)) {
        final subject = _id(p['Subject']);
        if (subject == null) continue;
        final identity = asMap(p['PlayerIdentity']);
        final previous = out[subject];
        // `Teams[]` repeats the ally players, sometimes without identity.
        if (previous != null && identity == null) continue;
        out[subject] = MatchPlayerIdentity(
          subject: subject,
          characterId: _id(p['CharacterID']),
          teamId: asNonEmptyString(p['TeamID']) ?? teamId,
          identity: LoadoutIdentity.fromJson(identity),
          incognito: asBool(identity?['Incognito']) ?? false,
        );
      }
    }

    addPlayers(match['Players']);
    for (final team in [
      asMap(match['AllyTeam']),
      asMap(match['EnemyTeam']),
      ...asMapList(match['Teams']),
    ]) {
      if (team == null) continue;
      addPlayers(team['Players'], teamId: asNonEmptyString(team['TeamID']));
    }
    return out;
  }
}

String? _id(Object? value) {
  final id = lowerUuid(value);
  return id == null || id.isEmpty ? null : id;
}
