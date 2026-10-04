import 'package:flutter/foundation.dart';

import '../../util/format.dart';
import '../../util/json.dart';
import 'weapon_models.dart' show cleanText, enumSuffix;

/// One rank inside a competitive tier table.
@immutable
class CompetitiveTier {
  const CompetitiveTier({
    required this.tier,
    required this.tierName,
    this.division,
    this.divisionName,
    this.color,
    this.backgroundColor,
    this.smallIcon,
    this.largeIcon,
    this.rankTriangleDownIcon,
    this.rankTriangleUpIcon,
  });

  static CompetitiveTier? fromJson(Object? json) {
    final m = asMap(json);
    final tier = asInt(m?['tier']);
    if (m == null || tier == null) return null;
    return CompetitiveTier(
      tier: tier,
      tierName: cleanText(m['tierName']) ?? '',
      division: enumSuffix(m['division']),
      divisionName: cleanText(m['divisionName']),
      color: asNonEmptyString(m['color']),
      backgroundColor: asNonEmptyString(m['backgroundColor']),
      smallIcon: asNonEmptyString(m['smallIcon']),
      largeIcon: asNonEmptyString(m['largeIcon']),
      rankTriangleDownIcon: asNonEmptyString(m['rankTriangleDownIcon']),
      rankTriangleUpIcon: asNonEmptyString(m['rankTriangleUpIcon']),
    );
  }

  final int tier;

  /// Raw (ALL CAPS) vi name, e.g. `KIM CƯƠNG 1`.
  final String tierName;

  /// `ECompetitiveDivision` suffix (`IRON`, `RADIANT`, `INVALID`…).
  final String? division;
  final String? divisionName;

  /// `RRGGBBAA`.
  final String? color;
  final String? backgroundColor;
  final String? smallIcon;
  final String? largeIcon;
  final String? rankTriangleDownIcon;
  final String? rankTriangleUpIcon;

  /// Tier 0 and the unused tiers 1–2 (SUMMARY §7.4).
  bool get isUnranked =>
      tier <= 2 || division == 'INVALID' || division == 'UNRANKED';

  /// Compatibility casing of the raw content name; no app-owned fallback.
  String get displayName => viTitleCase(tierName);
}

/// `/v1/competitivetiers` table (5 exist; the act decides which applies).
@immutable
class CompetitiveTierTable {
  const CompetitiveTierTable({
    required this.uuid,
    required this.assetObjectName,
    required this.tiers,
  });

  static CompetitiveTierTable? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    final tiers = [
      for (final t in asList(m['tiers'])) ?CompetitiveTier.fromJson(t),
    ]..sort((a, b) => a.tier.compareTo(b.tier));
    return CompetitiveTierTable(
      uuid: uuid,
      assetObjectName: asString(m['assetObjectName']) ?? '',
      tiers: tiers,
    );
  }

  final String uuid;
  final String assetObjectName;
  final List<CompetitiveTier> tiers;

  CompetitiveTier? tier(int tier) {
    for (final t in tiers) {
      if (t.tier == tier) return t;
    }
    return null;
  }

  /// Highest tier number (27 = Radiant in the Episode 5+ table).
  int get maxTier => tiers.isEmpty ? 0 : tiers.last.tier;
}

/// `/v1/seasons` entry: an act (`type == Act`) or an episode (`parentUuid`
/// null).
@immutable
class Season {
  const Season({
    required this.uuid,
    required this.displayName,
    this.title,
    this.isAct = false,
    this.startTime,
    this.endTime,
    this.parentUuid,
  });

  static Season? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    if (m == null || uuid == null) return null;
    return Season(
      uuid: uuid,
      displayName: cleanText(m['displayName']) ?? '',
      title: cleanText(m['title']),
      isAct: enumSuffix(m['type']) == 'Act',
      startTime: asDateTime(m['startTime']),
      endTime: asDateTime(m['endTime']),
      parentUuid: lowerUuid(m['parentUuid']),
    );
  }

  final String uuid;

  /// e.g. `PHẦN V`, `V26`.
  final String displayName;

  /// e.g. `V26 // PHẦN V` (null before 2025).
  final String? title;
  final bool isAct;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? parentUuid;

  bool get isEpisode => parentUuid == null;

  bool isActiveAt(DateTime now) {
    final s = startTime;
    final e = endTime;
    return s != null && e != null && !now.isBefore(s) && now.isBefore(e);
  }
}

/// `/v1/seasons/competitive` border (act rank badge levels).
@immutable
class SeasonBorder {
  const SeasonBorder({
    required this.uuid,
    required this.level,
    required this.winsRequired,
    this.displayIcon,
    this.smallIcon,
  });

  final String uuid;
  final int level;
  final int winsRequired;
  final String? displayIcon;
  final String? smallIcon;
}

/// `/v1/seasons/competitive`: which tier table an act uses.
@immutable
class CompetitiveSeason {
  const CompetitiveSeason({
    required this.uuid,
    required this.seasonUuid,
    required this.competitiveTiersUuid,
    required this.borders,
    this.startTime,
    this.endTime,
  });

  static CompetitiveSeason? fromJson(Object? json) {
    final m = asMap(json);
    final uuid = lowerUuid(m?['uuid']);
    final season = lowerUuid(m?['seasonUuid']);
    final table = lowerUuid(m?['competitiveTiersUuid']);
    if (m == null || uuid == null || season == null || table == null) {
      return null;
    }
    return CompetitiveSeason(
      uuid: uuid,
      seasonUuid: season,
      competitiveTiersUuid: table,
      startTime: asDateTime(m['startTime']),
      endTime: asDateTime(m['endTime']),
      borders: [
        for (final b in asMapList(m['borders']))
          if (lowerUuid(b['uuid']) case final id?)
            SeasonBorder(
              uuid: id,
              level: asInt(b['level']) ?? 0,
              winsRequired: asInt(b['winsRequired']) ?? 0,
              displayIcon: asNonEmptyString(b['displayIcon']),
              smallIcon: asNonEmptyString(b['smallIcon']),
            ),
      ]..sort((a, b) => a.level.compareTo(b.level)),
    );
  }

  final String uuid;
  final String seasonUuid;
  final String competitiveTiersUuid;
  final List<SeasonBorder> borders;
  final DateTime? startTime;
  final DateTime? endTime;
}
