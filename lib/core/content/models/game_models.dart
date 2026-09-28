import 'package:flutter/foundation.dart';

import '../../l10n/content_strings.dart';
import '../../riot/riot_ids.dart';
import '../../util/json.dart';
import 'weapon_models.dart' show cleanText;

/// Agent role (vi names from valorant-api, app fallback by uuid).
@immutable
class AgentRole {
  const AgentRole({
    required this.uuid,
    required this.displayName,
    this.displayIcon,
  });

  final String uuid;
  final String displayName;
  final String? displayIcon;

  /// App-owned vi name when known ("Đối đầu"…), else the API name.
  String get label => ContentStrings.roleNames[uuid] ?? displayName;
}

/// Agent ability (`slot`: Ability1, Ability2, Grenade, Ultimate, Passive).
@immutable
class AgentAbility {
  const AgentAbility({
    required this.slot,
    required this.displayName,
    this.description,
    this.displayIcon,
  });

  final String slot;
  final String displayName;
  final String? description;
  final String? displayIcon;
}

/// `/v1/agents?isPlayableCharacter=true`.
@immutable
class Agent {
  const Agent({
    required this.uuid,
    required this.displayName,
    required this.abilities,
    this.description,
    this.developerName,
    this.role,
    this.displayIcon,
    this.displayIconSmall,
    this.bustPortrait,
    this.fullPortrait,
    this.fullPortraitV2,
    this.killfeedPortrait,
    this.background,
    this.backgroundGradientColors = const [],
    this.isBaseContent = false,
    this.releaseDate,
  });

  static Agent? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    final role = asMap(m['role']);
    final roleUuid = lowerUuid(role?['uuid']);
    return Agent(
      uuid: uuid,
      displayName: cleanText(m['displayName']) ?? '',
      description: cleanText(m['description']),
      developerName: asNonEmptyString(m['developerName']),
      role: roleUuid == null
          ? null
          : AgentRole(
              uuid: roleUuid,
              displayName: cleanText(role?['displayName']) ?? '',
              displayIcon: asNonEmptyString(role?['displayIcon']),
            ),
      abilities: [
        for (final a in asMapList(m['abilities']))
          AgentAbility(
            slot: asString(a['slot']) ?? '',
            displayName: cleanText(a['displayName']) ?? '',
            description: cleanText(a['description']),
            displayIcon: asNonEmptyString(a['displayIcon']),
          ),
      ],
      displayIcon: asNonEmptyString(m['displayIcon']),
      displayIconSmall: asNonEmptyString(m['displayIconSmall']),
      bustPortrait: asNonEmptyString(m['bustPortrait']),
      fullPortrait: asNonEmptyString(m['fullPortrait']),
      fullPortraitV2: asNonEmptyString(m['fullPortraitV2']),
      killfeedPortrait: asNonEmptyString(m['killfeedPortrait']),
      background: asNonEmptyString(m['background']),
      backgroundGradientColors: asStringList(m['backgroundGradientColors']),
      isBaseContent: asBool(m['isBaseContent']) ?? false,
      releaseDate: asDateTime(m['releaseDate']),
    );
  }

  final String uuid;
  final String displayName;
  final String? description;
  final String? developerName;
  final AgentRole? role;
  final List<AgentAbility> abilities;
  final String? displayIcon;
  final String? displayIconSmall;
  final String? bustPortrait;
  final String? fullPortrait;
  final String? fullPortraitV2;
  final String? killfeedPortrait;
  final String? background;

  /// `RRGGBBAA` strings (use `parseRgba`).
  final List<String> backgroundGradientColors;

  /// Free starter agent (always owned; never in entitlements).
  final bool isBaseContent;
  final DateTime? releaseDate;

  bool get isStarter =>
      isBaseContent || SpecialIds.starterAgents.contains(uuid);

  /// Ability by slot; match `damageItem` `GrenadeAbility` → `Grenade`.
  AgentAbility? ability(String slot) {
    final s = slot == 'GrenadeAbility' ? 'Grenade' : slot;
    for (final a in abilities) {
      if (a.slot == s) return a;
    }
    return null;
  }
}

/// `/v1/maps`. [mapUrl] equals Riot's `MapID` / `matchInfo.mapId`.
@immutable
class GameMap {
  const GameMap({
    required this.uuid,
    required this.displayName,
    required this.mapUrl,
    this.tacticalDescription,
    this.coordinates,
    this.displayIcon,
    this.listViewIcon,
    this.listViewIconTall,
    this.splash,
    this.stylizedBackgroundImage,
    this.premierBackgroundImage,
    this.xMultiplier = 0,
    this.yMultiplier = 0,
    this.xScalarToAdd = 0,
    this.yScalarToAdd = 0,
  });

  static GameMap? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    return GameMap(
      uuid: uuid,
      displayName: cleanText(m['displayName']) ?? '',
      mapUrl: asString(m['mapUrl']) ?? '',
      tacticalDescription: cleanText(m['tacticalDescription']),
      coordinates: cleanText(m['coordinates']),
      displayIcon: asNonEmptyString(m['displayIcon']),
      listViewIcon: asNonEmptyString(m['listViewIcon']),
      listViewIconTall: asNonEmptyString(m['listViewIconTall']),
      splash: asNonEmptyString(m['splash']),
      stylizedBackgroundImage: asNonEmptyString(m['stylizedBackgroundImage']),
      premierBackgroundImage: asNonEmptyString(m['premierBackgroundImage']),
      xMultiplier: asDouble(m['xMultiplier']) ?? 0,
      yMultiplier: asDouble(m['yMultiplier']) ?? 0,
      xScalarToAdd: asDouble(m['xScalarToAdd']) ?? 0,
      yScalarToAdd: asDouble(m['yScalarToAdd']) ?? 0,
    );
  }

  final String uuid;
  final String displayName;

  /// e.g. `/Game/Maps/Ascent/Ascent` (compare case-insensitively).
  final String mapUrl;
  final String? tacticalDescription;
  final String? coordinates;

  /// Minimap image.
  final String? displayIcon;

  /// Wide list banner.
  final String? listViewIcon;
  final String? listViewIconTall;

  /// Loading-screen splash.
  final String? splash;
  final String? stylizedBackgroundImage;
  final String? premierBackgroundImage;
  final double xMultiplier;
  final double yMultiplier;
  final double xScalarToAdd;
  final double yScalarToAdd;
}

/// `/v1/gamemodes/queues`. Riot `QueueID` = [queueId].
@immutable
class GameQueue {
  const GameQueue({
    required this.uuid,
    required this.queueId,
    required this.displayName,
    this.dropdownText,
    this.selectedText,
    this.description,
    this.displayIcon,
    this.isBeta = false,
  });

  static GameQueue? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    final queueId = asString(m?['queueId']);
    if (m == null || uuid == null || queueId == null) return null;
    return GameQueue(
      uuid: uuid,
      queueId: queueId,
      displayName: cleanText(m['displayName']) ?? queueId,
      dropdownText: cleanText(m['dropdownText']),
      selectedText: cleanText(m['selectedText']),
      description: cleanText(m['description']),
      displayIcon: asNonEmptyString(m['displayIcon']),
      isBeta: asBool(m['isBeta']) ?? false,
    );
  }

  final String uuid;
  final String queueId;
  final String displayName;

  /// Preferred label (SUMMARY §7.5).
  final String? dropdownText;
  final String? selectedText;
  final String? description;
  final String? displayIcon;
  final bool isBeta;

  String get label => dropdownText ?? displayName;
}

/// Directory key of a game-mode path (CA §9.2):
/// `/Game/GameModes/Bomb/BombGameMode.BombGameMode_C` → `bomb`.
String? gameModeKey(String? path) {
  if (path == null) return null;
  final i = path.indexOf('GameModes/');
  if (i < 0) return null;
  final rest = path.substring(i + 'GameModes/'.length);
  final j = rest.lastIndexOf('/');
  return j < 0 ? null : rest.substring(0, j).toLowerCase();
}

/// `/v1/gamemodes`.
@immutable
class GameMode {
  const GameMode({
    required this.uuid,
    required this.displayName,
    required this.assetPath,
    this.description,
    this.duration,
    this.displayIcon,
  });

  static GameMode? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    return GameMode(
      uuid: uuid,
      displayName: cleanText(m['displayName']) ?? '',
      assetPath: asString(m['assetPath']) ?? '',
      description: cleanText(m['description']),
      duration: cleanText(m['duration']),
      displayIcon: asNonEmptyString(m['displayIcon']),
    );
  }

  final String uuid;
  final String displayName;
  final String assetPath;
  final String? description;
  final String? duration;
  final String? displayIcon;

  String? get key => gameModeKey(assetPath);
}

/// `/v1/ceremonies`. [key] matches Riot `roundCeremony` minus the
/// `Ceremony` prefix (`CeremonyAce` → `Ace`).
@immutable
class Ceremony {
  const Ceremony({
    required this.uuid,
    required this.displayName,
    required this.key,
  });

  static Ceremony? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    final asset = asString(m['assetPath']) ?? '';
    final stem = asset.split('/').last.split('_').first;
    final key = stem.endsWith('Ceremony')
        ? stem.substring(0, stem.length - 'Ceremony'.length)
        : stem;
    return Ceremony(
      uuid: uuid,
      displayName: cleanText(m['displayName']) ?? '',
      key: key,
    );
  }

  final String uuid;
  final String displayName;
  final String key;
}
