import 'package:flutter/foundation.dart';

import '../../util/json.dart';
import 'viewer.dart' show baseQueueId;

/// Riot queue id of ranked play.
const kCompetitiveQueue = 'competitive';

/// One act of one queue in P-11 `QueueSkills.<queue>.SeasonalInfoBySeasonID`
/// (EP §10.1).
@immutable
class SeasonalInfo {
  const SeasonalInfo({
    required this.seasonId,
    this.numberOfWins = 0,
    this.numberOfWinsWithPlacements = 0,
    this.numberOfGames = 0,
    this.rank = 0,
    this.capstoneWins = 0,
    this.leaderboardRank = 0,
    this.competitiveTier = 0,
    this.rankedRating = 0,
    this.winsByTier = const {},
    this.gamesNeededForRating = 0,
    this.totalWinsNeededForRank = 0,
  });

  /// [key] is the map key (used when the entry lacks its own `SeasonID`).
  static SeasonalInfo? fromJson(Object? json, {String? key}) {
    final m = asMap(json);
    final id = lowerUuid(m?['SeasonID']) ?? lowerUuid(key);
    if (m == null || id == null) return null;
    final wins = <int, int>{};
    for (final MapEntry(key: k, value: v)
        in (m.obj('WinsByTier') ?? {}).entries) {
      final tier = asInt(k);
      final count = asInt(v);
      if (tier != null && count != null && count > 0) wins[tier] = count;
    }
    return SeasonalInfo(
      seasonId: id,
      numberOfWins: m.integer('NumberOfWins') ?? 0,
      numberOfWinsWithPlacements: m.integer('NumberOfWinsWithPlacements') ?? 0,
      numberOfGames: m.integer('NumberOfGames') ?? 0,
      rank: m.integer('Rank') ?? 0,
      capstoneWins: m.integer('CapstoneWins') ?? 0,
      leaderboardRank: m.integer('LeaderboardRank') ?? 0,
      competitiveTier: m.integer('CompetitiveTier') ?? 0,
      rankedRating: m.integer('RankedRating') ?? 0,
      winsByTier: Map.unmodifiable(wins),
      gamesNeededForRating: m.integer('GamesNeededForRating') ?? 0,
      totalWinsNeededForRank: m.integer('TotalWinsNeededForRank') ?? 0,
    );
  }

  /// Act uuid (lowercase).
  final String seasonId;
  final int numberOfWins;
  final int numberOfWinsWithPlacements;
  final int numberOfGames;

  /// Act-rank badge tier.
  final int rank;
  final int capstoneWins;

  /// `0` = not on the leaderboard.
  final int leaderboardRank;

  /// Tier now (current act) or at the end of the act, in that act's table.
  final int competitiveTier;
  final int rankedRating;

  /// Tier → wins at that tier (`WinsByTier`; may be empty).
  final Map<int, int> winsByTier;
  final int gamesNeededForRating;
  final int totalWinsNeededForRank;

  /// Win rate of the act (`null` without games).
  double? get winRate =>
      numberOfGames > 0 ? numberOfWins / numberOfGames : null;
}

/// P-11 `QueueSkills.<queue>`.
@immutable
class QueueSkill {
  const QueueSkill({
    required this.queueId,
    this.totalGamesNeededForRating = 0,
    this.totalGamesNeededForLeaderboard = 0,
    this.currentSeasonGamesNeededForRating = 0,
    this.seasons = const {},
  });

  static QueueSkill fromJson(String queueId, Object? json) {
    final m = asMap(json) ?? const <String, dynamic>{};
    final seasons = <String, SeasonalInfo>{};
    for (final MapEntry(:key, :value)
        in (m.obj('SeasonalInfoBySeasonID') ?? {}).entries) {
      final info = SeasonalInfo.fromJson(value, key: key);
      if (info != null) seasons[info.seasonId] = info;
    }
    return QueueSkill(
      queueId: queueId,
      totalGamesNeededForRating: m.integer('TotalGamesNeededForRating') ?? 0,
      totalGamesNeededForLeaderboard:
          m.integer('TotalGamesNeededForLeaderboard') ?? 0,
      currentSeasonGamesNeededForRating:
          m.integer('CurrentSeasonGamesNeededForRating') ?? 0,
      seasons: Map.unmodifiable(seasons),
    );
  }

  final String queueId;
  final int totalGamesNeededForRating;
  final int totalGamesNeededForLeaderboard;

  /// `> 0` = still in placements this act.
  final int currentSeasonGamesNeededForRating;

  /// Act uuid (lowercase) → info. Empty when Riot sends `null`.
  final Map<String, SeasonalInfo> seasons;

  SeasonalInfo? season(String? actUuid) =>
      actUuid == null ? null : seasons[actUuid.trim().toLowerCase()];
}

/// One row of P-12 competitive updates (also P-11
/// `LatestCompetitiveUpdate`), EP §10.2.
///
/// [toJson] writes Riot's own keys, so stored rows parse with [fromJson].
@immutable
class CompetitiveUpdate {
  const CompetitiveUpdate({
    required this.matchId,
    this.mapId,
    this.seasonId,
    this.matchStartTime,
    this.tierBefore = 0,
    this.tierAfter = 0,
    this.rrBefore = 0,
    this.rrAfter = 0,
    this.rrEarned = 0,
    this.performanceBonus = 0,
    this.movement,
    this.afkPenalty = 0,
  });

  static CompetitiveUpdate? fromJson(Object? json) {
    final m = asMap(json);
    final id = lowerUuid(m?['MatchID']);
    if (m == null || id == null) return null;
    return CompetitiveUpdate(
      matchId: id,
      mapId: m.text('MapID'),
      seasonId: m.uuid('SeasonID'),
      matchStartTime: m.dateTime('MatchStartTime'),
      tierBefore: m.integer('TierBeforeUpdate') ?? 0,
      tierAfter: m.integer('TierAfterUpdate') ?? 0,
      rrBefore: m.integer('RankedRatingBeforeUpdate') ?? 0,
      rrAfter: m.integer('RankedRatingAfterUpdate') ?? 0,
      rrEarned: m.integer('RankedRatingEarned') ?? 0,
      performanceBonus: m.integer('RankedRatingPerformanceBonus') ?? 0,
      movement: m.text('CompetitiveMovement'),
      afkPenalty: m.integer('AFKPenalty') ?? 0,
    );
  }

  /// Lowercase match uuid (join key with match history / details).
  final String matchId;

  /// Map path (`/Game/Maps/Ascent/Ascent`) → `ContentDb.mapByUrl`.
  final String? mapId;

  /// Act uuid (lowercase): picks the tier table.
  final String? seasonId;

  /// UTC start of the match.
  final DateTime? matchStartTime;
  final int tierBefore;
  final int tierAfter;
  final int rrBefore;
  final int rrAfter;

  /// RR shown for the match (`+24` / `-17`; `0` for draws and remakes).
  final int rrEarned;
  final int performanceBonus;

  /// `PROMOTED`, `DEMOTED`, `MOVEMENT_UNKNOWN`… (informational).
  final String? movement;
  final int afkPenalty;

  bool get isPromotion => tierAfter > tierBefore;
  bool get isDemotion => tierAfter < tierBefore && tierAfter > 0;

  JsonMap toJson() => {
    'MatchID': matchId,
    'MapID': ?mapId,
    'SeasonID': ?seasonId,
    'MatchStartTime': ?matchStartTime?.millisecondsSinceEpoch,
    'TierBeforeUpdate': tierBefore,
    'TierAfterUpdate': tierAfter,
    'RankedRatingBeforeUpdate': rrBefore,
    'RankedRatingAfterUpdate': rrAfter,
    'RankedRatingEarned': rrEarned,
    'RankedRatingPerformanceBonus': performanceBonus,
    'CompetitiveMovement': ?movement,
    'AFKPenalty': afkPenalty,
  };

  @override
  bool operator ==(Object other) =>
      other is CompetitiveUpdate &&
      other.matchId == matchId &&
      other.mapId == mapId &&
      other.seasonId == seasonId &&
      other.matchStartTime == matchStartTime &&
      other.tierBefore == tierBefore &&
      other.tierAfter == tierAfter &&
      other.rrBefore == rrBefore &&
      other.rrAfter == rrAfter &&
      other.rrEarned == rrEarned &&
      other.performanceBonus == performanceBonus &&
      other.movement == movement &&
      other.afkPenalty == afkPenalty;

  @override
  int get hashCode => Object.hash(
    matchId,
    mapId,
    seasonId,
    matchStartTime,
    tierBefore,
    tierAfter,
    rrBefore,
    rrAfter,
    rrEarned,
    performanceBonus,
    movement,
    afkPenalty,
  );

  @override
  String toString() =>
      'CompetitiveUpdate($matchId, $tierBefore/$rrBefore → '
      '$tierAfter/$rrAfter, $rrEarned)';
}

/// Newest first; rows without a start time go last.
int compareUpdatesNewestFirst(CompetitiveUpdate a, CompetitiveUpdate b) {
  final at = a.matchStartTime;
  final bt = b.matchStartTime;
  if (at == null && bt == null) return a.matchId.compareTo(b.matchId);
  if (at == null) return 1;
  if (bt == null) return -1;
  final c = bt.compareTo(at);
  return c != 0 ? c : a.matchId.compareTo(b.matchId);
}

/// P-12 response page.
@immutable
class CompetitiveUpdatesPage {
  const CompetitiveUpdatesPage({this.subject, this.matches = const []});

  static CompetitiveUpdatesPage fromJson(Object? json) {
    final m = asMap(json) ?? const <String, dynamic>{};
    return CompetitiveUpdatesPage(
      subject: m.uuid('Subject'),
      matches: List.unmodifiable([
        for (final row in m.list('Matches')) ?CompetitiveUpdate.fromJson(row),
      ]),
    );
  }

  final String? subject;

  /// In Riot's order (newest first).
  final List<CompetitiveUpdate> matches;
}

/// P-11 player MMR (EP §10.1). Works for any PUUID.
@immutable
class PlayerMmr {
  const PlayerMmr({
    this.subject,
    this.version,
    this.queueSkills = const {},
    this.latestCompetitiveUpdate,
    this.newPlayerExperienceFinished = true,
    this.isLeaderboardAnonymized = false,
    this.isActRankBadgeHidden = false,
  });

  static PlayerMmr fromJson(Object? json) {
    final m = asMap(json) ?? const <String, dynamic>{};
    final skills = <String, QueueSkill>{};
    for (final MapEntry(:key, :value) in (m.obj('QueueSkills') ?? {}).entries) {
      final id = key.trim().toLowerCase();
      if (id.isEmpty) continue;
      skills[id] = QueueSkill.fromJson(id, value);
    }
    return PlayerMmr(
      subject: m.uuid('Subject'),
      version: m.integer('Version'),
      queueSkills: Map.unmodifiable(skills),
      latestCompetitiveUpdate: CompetitiveUpdate.fromJson(
        m['LatestCompetitiveUpdate'],
      ),
      newPlayerExperienceFinished:
          m.boolean('NewPlayerExperienceFinished') ?? true,
      isLeaderboardAnonymized: m.boolean('IsLeaderboardAnonymized') ?? false,
      isActRankBadgeHidden: m.boolean('IsActRankBadgeHidden') ?? false,
    );
  }

  final String? subject;
  final int? version;

  /// Queue id (lowercase, incl. `console_*`) → skill.
  final Map<String, QueueSkill> queueSkills;

  /// `null` when absent or when its `MatchID` is blank (never played ranked).
  final CompetitiveUpdate? latestCompetitiveUpdate;
  final bool newPlayerExperienceFinished;
  final bool isLeaderboardAnonymized;
  final bool isActRankBadgeHidden;

  /// The skill of [queue]. On console the `console_<queue>` entry is used
  /// and the PC entry is the fallback (SUMMARY U12).
  QueueSkill? skill(String queue, {bool console = false}) {
    final base = baseQueueId(queue);
    if (console) {
      final c = queueSkills['console_$base'];
      if (c != null) return c;
    }
    return queueSkills[base];
  }

  /// `QueueSkills.competitive` (or its console variant).
  QueueSkill? competitive({bool console = false}) =>
      skill(kCompetitiveQueue, console: console);
}
