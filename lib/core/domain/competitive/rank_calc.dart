import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';

import '../../content/content_db.dart';
import '../../l10n/content_strings.dart';
import '../../theme/tier_colors.dart';
import 'competitive_strings.dart';
import 'match_models.dart' show MatchOutcome;
import 'rank_models.dart';

// ------------------------------------------------------------ tier tables

/// First tier of each division in the Episode 5+ table (SUMMARY §7.4).
const Map<String, int> _e5DivisionStart = {
  'IRON': 3,
  'BRONZE': 6,
  'SILVER': 9,
  'GOLD': 12,
  'PLATINUM': 15,
  'DIAMOND': 18,
  'ASCENDANT': 21,
  'IMMORTAL': 24,
  'RADIANT': 27,
};

/// Pre-Episode-5 tables (CA §10.1): tiers 21–24 mean Immortal/Radiant there.
const Set<String> _legacyTierTables = {
  '564d8e28-c226-3180-6285-e48a390db8b1', // Episode1
  '23eb970e-6408-bc0b-3f20-d8fb0e0354ea', // Episode2 (single Immortal tier)
  'edb72a72-7e6d-6010-9591-7c053bbdbf48', // Episode3
  'e4e9a692-288f-63ca-7835-16fbf6234fda', // Episode4
};

/// First tier of each division in the pre-Episode-5 tables: identical up to
/// Diamond, then Immortal 1–3 are 21–23 and Radiant is 24 (CA §10.1).
const Map<String, int> _legacyDivisionStart = {
  'IRON': 3,
  'BRONZE': 6,
  'SILVER': 9,
  'GOLD': 12,
  'PLATINUM': 15,
  'DIAMOND': 18,
  'IMMORTAL': 21,
  'RADIANT': 24,
};

/// Episode-5-equivalent tier of [tier] in [table], so ranks from different
/// tables compare correctly (SUMMARY §9.5: "compare by table + tier, not by
/// raw number across E4/E5"). E4 Immortal 1 (21) → 24, E4 Radiant (24) → 27,
/// E5 Ascendant 3 (23) stays 23. Unranked / unused tiers → 0.
///
/// Uses the tier's `division` id and the tier **number**: the position
/// inside the division is `tier − first tier of that division`. Never the
/// localized name, whose numeral may be missing or non-ASCII in the other
/// 17 languages (GL-24). Falls back to the known legacy table ids, then to
/// the raw tier (current table assumed, e.g. before content is downloaded).
int normalizeTier(int tier, CompetitiveTierTable? table) {
  if (tier <= 2) return 0;
  final t = table?.tier(tier);
  final start = _e5DivisionStart[t?.division];
  if (t != null && start != null) {
    if (start == 27) return 27;
    final legacy = table != null && _legacyTierTables.contains(table.uuid);
    final divisionStart = legacy
        ? _legacyDivisionStart[t.division] ?? start
        : start;
    return start + (tier - divisionStart).clamp(0, 2);
  }
  if (table != null && _legacyTierTables.contains(table.uuid) && tier >= 21) {
    return tier >= 24 ? 27 : tier + 3;
  }
  return tier;
}

/// [normalizeTier] in the table of act [seasonId].
int normalizeTierForSeason(ContentDb db, int tier, String? seasonId) =>
    normalizeTier(tier, db.tierTableForSeason(seasonId));

// ------------------------------------------------------------ RankInfo

/// A rank ready for display: tier + RR resolved in the table of its act.
@immutable
class RankInfo {
  const RankInfo({
    required this.tier,
    required this.tierName,
    required this.normalizedTier,
    this.rr = 0,
    this.actUuid,
    this.icon,
    this.largeIcon,
    this.colorHex,
    this.isPlacement = false,
    this.gamesNeeded = 0,
    this.tierData,
  });

  /// Resolves [tier] in the tier table of [actUuid] (SUMMARY §7.4; newest
  /// table for unknown acts). Tiers 0–2 are "Chưa xếp hạng";
  /// [gamesNeeded] `> 0` on an unranked tier marks placements.
  factory RankInfo.resolve(
    ContentDb db, {
    required int tier,
    int rr = 0,
    String? actUuid,
    int gamesNeeded = 0,
  }) {
    final act = actUuid?.trim().toLowerCase();
    final table = db.tierTableForSeason(act);
    final data = table?.tier(tier);
    final unranked = tier <= 2 || (data?.isUnranked ?? false);
    final shown = unranked ? table?.tier(0) : data;
    final normalized = unranked ? 0 : normalizeTier(tier, table);
    return RankInfo(
      tier: math.max(tier, 0),
      tierName: unranked
          ? ContentStrings.unranked
          : data?.displayName ??
                CompetitiveStrings.fallbackTierName(normalized) ??
                ContentStrings.unranked,
      normalizedTier: normalized,
      rr: unranked ? 0 : rr,
      actUuid: act,
      icon: shown?.smallIcon ?? shown?.largeIcon,
      largeIcon: shown?.largeIcon ?? shown?.smallIcon,
      colorHex: unranked ? null : data?.color,
      isPlacement: unranked && gamesNeeded > 0,
      gamesNeeded: math.max(gamesNeeded, 0),
      tierData: data,
    );
  }

  /// Tier number in the table of [actUuid].
  final int tier;

  /// Vietnamese name: `Kim Cương 1`, `Radiant`, `Chưa xếp hạng`.
  final String tierName;

  /// Episode-5-equivalent tier (see [normalizeTier]); 0 when unranked.
  final int normalizedTier;
  final int rr;

  /// Act whose table was used (lowercase).
  final String? actUuid;

  /// Small icon URL (tier 0 icon when unranked).
  final String? icon;
  final String? largeIcon;

  /// `RRGGBBAA` (valorant-api); `null` when unranked.
  final String? colorHex;

  /// Unranked with placement matches left.
  final bool isPlacement;

  /// Placement matches left (`CurrentSeasonGamesNeededForRating`).
  final int gamesNeeded;
  final CompetitiveTier? tierData;

  bool get isUnranked => normalizedTier == 0;

  /// Solid tier color (muted when unranked).
  Color get color => opaqueRgba(colorHex);

  /// "Còn 3 trận phân hạng" during placements, else `null`.
  String? get placementText =>
      isPlacement ? CompetitiveStrings.placementsLeft(gamesNeeded) : null;

  /// Orders by normalized tier, then RR.
  int compareTo(RankInfo other) {
    final c = normalizedTier.compareTo(other.normalizedTier);
    return c != 0 ? c : rr.compareTo(other.rr);
  }

  @override
  bool operator ==(Object other) =>
      other is RankInfo &&
      other.tier == tier &&
      other.rr == rr &&
      other.actUuid == actUuid &&
      other.tierName == tierName &&
      other.isPlacement == isPlacement &&
      other.gamesNeeded == gamesNeeded;

  @override
  int get hashCode =>
      Object.hash(tier, rr, actUuid, tierName, isPlacement, gamesNeeded);

  @override
  String toString() => 'RankInfo($tierName, $rr RR, act: $actUuid)';
}

// ------------------------------------------------------------ current / peak

/// Current rank (SUMMARY §9.5): `QueueSkills.competitive
/// .SeasonalInfoBySeasonID[currentAct]`. The current act comes from
/// `ContentDb.currentAct(now)` (or `LatestCompetitiveUpdate.SeasonID` when
/// content has no active act). Missing → unranked; placements when
/// `CurrentSeasonGamesNeededForRating > 0`.
RankInfo currentRankOf(
  ContentDb db,
  PlayerMmr mmr, {
  required DateTime now,
  bool console = false,
}) {
  final skill = mmr.competitive(console: console);
  final latest = mmr.latestCompetitiveUpdate;
  final act = db.currentAct(now)?.uuid ?? latest?.seasonId;
  final info = skill?.season(act);
  final gamesNeeded = math.max(
    skill?.currentSeasonGamesNeededForRating ?? 0,
    info?.gamesNeededForRating ?? 0,
  );
  if (info != null && info.competitiveTier > 2) {
    return RankInfo.resolve(
      db,
      tier: info.competitiveTier,
      rr: info.rankedRating,
      actUuid: act,
    );
  }
  if (latest != null &&
      act != null &&
      latest.seasonId == act &&
      latest.tierAfter > 2 &&
      gamesNeeded == 0) {
    return RankInfo.resolve(
      db,
      tier: latest.tierAfter,
      rr: latest.rrAfter,
      actUuid: act,
    );
  }
  return RankInfo.resolve(db, tier: 0, actUuid: act, gamesNeeded: gamesNeeded);
}

/// Highest rank ever reached, with the "true peak" RR (R2, R3).
@immutable
class PeakRank {
  const PeakRank({
    required this.rank,
    this.truePeakRr,
    this.truePeakFromLocalHistory = false,
  });

  /// Tier and act of the peak; `rank.rr` is [truePeakRr] (0 when unknown).
  final RankInfo rank;

  /// Highest RR held at the peak tier, when known.
  final int? truePeakRr;

  /// Whether [truePeakRr] is known only from updates stored on this device
  /// (label it as such).
  final bool truePeakFromLocalHistory;

  String? get actUuid => rank.actUuid;
}

typedef _PeakCandidate = ({
  int tier,
  String? act,
  int? rr,
  bool local,
  DateTime? at,
});

/// Peak rank (SUMMARY §9.5): the max over acts of `CompetitiveTier`,
/// `Rank` and the keys of `WinsByTier`, plus tiers seen in
/// `LatestCompetitiveUpdate` and in [history] (stored P-12 rows), each
/// mapped through its own act's table ([normalizeTier]). Ties go to the most
/// recent act.
///
/// True peak RR = the highest RR held at that tier: `RankedRatingAfter/
/// BeforeUpdate` of stored rows and `RankedRating` of acts that ended there.
/// `null` when the player never ranked.
PeakRank? peakRankOf(
  ContentDb db,
  PlayerMmr mmr, {
  Iterable<CompetitiveUpdate> history = const [],
  bool console = false,
}) {
  final candidates = <_PeakCandidate>[];
  final skill = mmr.competitive(console: console);
  for (final info in skill?.seasons.values ?? const <SeasonalInfo>[]) {
    candidates
      ..add((
        tier: info.competitiveTier,
        act: info.seasonId,
        rr: info.rankedRating,
        local: false,
        at: null,
      ))
      ..add((
        tier: info.rank,
        act: info.seasonId,
        rr: null,
        local: false,
        at: null,
      ));
    for (final t in info.winsByTier.keys) {
      candidates.add((
        tier: t,
        act: info.seasonId,
        rr: null,
        local: false,
        at: null,
      ));
    }
  }
  void addUpdate(CompetitiveUpdate u, {required bool local}) {
    candidates
      ..add((
        tier: u.tierAfter,
        act: u.seasonId,
        rr: u.rrAfter,
        local: local,
        at: u.matchStartTime,
      ))
      ..add((
        tier: u.tierBefore,
        act: u.seasonId,
        rr: u.rrBefore,
        local: local,
        at: u.matchStartTime,
      ));
  }

  final latest = mmr.latestCompetitiveUpdate;
  if (latest != null) addUpdate(latest, local: false);
  for (final u in history) {
    addUpdate(u, local: true);
  }

  final scored = [
    for (final c in candidates)
      if (c.tier > 2) (c: c, n: normalizeTierForSeason(db, c.tier, c.act)),
  ].where((e) => e.n > 0).toList();
  if (scored.isEmpty) return null;
  final peak = scored.map((e) => e.n).reduce(math.max);
  final atPeak = [
    for (final e in scored)
      if (e.n == peak) e.c,
  ];

  DateTime actTime(_PeakCandidate c) {
    final act = c.act;
    final start = act == null
        ? null
        : db.season(act)?.startTime ?? db.competitiveSeason(act)?.startTime;
    return start ?? c.at ?? DateTime.utc(1970);
  }

  final shown = atPeak.reduce((a, b) => actTime(b).isAfter(actTime(a)) ? b : a);

  int? bestRr;
  var bestIsLocal = false;
  for (final c in atPeak) {
    final rr = c.rr;
    if (rr == null) continue;
    if (bestRr == null || rr > bestRr) {
      bestRr = rr;
      bestIsLocal = c.local;
    } else if (rr == bestRr && !c.local) {
      bestIsLocal = false;
    }
  }
  return PeakRank(
    rank: RankInfo.resolve(
      db,
      tier: shown.tier,
      rr: bestRr ?? 0,
      actUuid: shown.act,
    ),
    truePeakRr: bestRr,
    truePeakFromLocalHistory: bestRr != null && bestIsLocal,
  );
}

/// One act of the player's ranked history.
@immutable
class ActRank {
  const ActRank({
    required this.actUuid,
    required this.rank,
    required this.info,
    this.act,
    this.title,
    this.badge,
  });

  final String actUuid;
  final Season? act;

  /// `V26 // PHẦN V` (null when the act is unknown to valorant-api).
  final String? title;

  /// Rank at the end of the act (now, for the current act).
  final RankInfo rank;

  /// Act-rank badge tier (`Rank`), `null` when 0.
  final RankInfo? badge;
  final SeasonalInfo info;

  int get wins => info.numberOfWins;
  int get games => info.numberOfGames;
}

/// Per-act ranked history, newest act first (acts unknown to content first:
/// they are newer than the downloaded data).
List<ActRank> actHistoryOf(
  ContentDb db,
  PlayerMmr mmr, {
  bool console = false,
}) {
  final skill = mmr.competitive(console: console);
  final out = [
    for (final info in skill?.seasons.values ?? const <SeasonalInfo>[])
      if (info.numberOfGames > 0 || info.competitiveTier > 2)
        ActRank(
          actUuid: info.seasonId,
          act: db.season(info.seasonId),
          title: switch (db.season(info.seasonId)) {
            final s? => db.actTitle(s),
            null => null,
          },
          rank: RankInfo.resolve(
            db,
            tier: info.competitiveTier,
            rr: info.rankedRating,
            actUuid: info.seasonId,
          ),
          badge: info.rank > 2
              ? RankInfo.resolve(db, tier: info.rank, actUuid: info.seasonId)
              : null,
          info: info,
        ),
  ];
  final far = DateTime.utc(9999);
  out.sort(
    (a, b) => (b.act?.startTime ?? far).compareTo(a.act?.startTime ?? far),
  );
  return out;
}

/// Rank card data (R2, R3): current rank, peak with true-peak RR, act stats.
@immutable
class RankSummary {
  const RankSummary({
    required this.current,
    this.peak,
    this.currentAct,
    this.currentActInfo,
    this.latestUpdate,
    this.acts = const [],
  });

  final RankInfo current;
  final PeakRank? peak;

  /// Active act (`ContentDb.currentAct`), `null` between acts / no content.
  final Season? currentAct;

  /// This act's `SeasonalInfo` (wins, games, leaderboard).
  final SeasonalInfo? currentActInfo;
  final CompetitiveUpdate? latestUpdate;

  /// Every act played, newest first.
  final List<ActRank> acts;

  int get wins => currentActInfo?.numberOfWins ?? 0;
  int get games => currentActInfo?.numberOfGames ?? 0;
  double? get winRate => currentActInfo?.winRate;

  /// Leaderboard position this act (`null` when not on it).
  int? get leaderboardRank {
    final r = currentActInfo?.leaderboardRank ?? 0;
    return r > 0 ? r : null;
  }
}

/// Builds the [RankSummary] of [mmr] with the device-stored [history].
RankSummary buildRankSummary(
  ContentDb db,
  PlayerMmr mmr, {
  required DateTime now,
  Iterable<CompetitiveUpdate> history = const [],
  bool console = false,
}) {
  final current = currentRankOf(db, mmr, now: now, console: console);
  return RankSummary(
    current: current,
    peak: peakRankOf(db, mmr, history: history, console: console),
    currentAct: db.currentAct(now),
    currentActInfo: mmr.competitive(console: console)?.season(current.actUuid),
    latestUpdate: mmr.latestCompetitiveUpdate,
    acts: actHistoryOf(db, mmr, console: console),
  );
}

// ------------------------------------------------------------ Daily RR (§9.6)

/// One local day of ranked play (S42).
@immutable
class DailyRr {
  const DailyRr({
    required this.date,
    required this.matches,
    required this.netRr,
    required this.wins,
    required this.losses,
    required this.draws,
  });

  /// Local midnight of the day.
  final DateTime date;

  /// Oldest first.
  final List<CompetitiveUpdate> matches;

  /// Σ `RankedRatingEarned`.
  final int netRr;
  final int wins;
  final int losses;
  final int draws;

  CompetitiveUpdate get first => matches.first;
  CompetitiveUpdate get last => matches.last;

  /// Rank before the first match of the day.
  int get startTier => first.tierBefore;
  int get startRr => first.rrBefore;
  String? get startSeasonId => first.seasonId;

  /// Rank after the last match of the day.
  int get endTier => last.tierAfter;
  int get endRr => last.rrAfter;
  String? get endSeasonId => last.seasonId;
}

/// Groups competitive updates by the local date of `MatchStartTime`
/// (SUMMARY §9.6; days cut at local midnight). Newest day first, matches
/// oldest first inside a day. Wins/losses come from [outcomes] (P-14
/// `teams[].won`, keyed by match id) when known, otherwise from the RR sign
/// (0 → draw / remake). [toLocal] converts UTC start times (default:
/// device time zone).
List<DailyRr> groupDailyRr(
  Iterable<CompetitiveUpdate> rows, {
  Map<String, MatchOutcome> outcomes = const {},
  DateTime Function(DateTime utc)? toLocal,
}) {
  final convert = toLocal ?? (DateTime d) => d.toLocal();
  final seen = <String>{};
  final byDay = <DateTime, List<CompetitiveUpdate>>{};
  for (final u in rows) {
    final start = u.matchStartTime;
    if (start == null || !seen.add(u.matchId)) continue;
    final local = convert(start);
    final day = DateTime(local.year, local.month, local.day);
    (byDay[day] ??= []).add(u);
  }
  final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final day in days)
      () {
        final list = byDay[day]!
          ..sort((a, b) => a.matchStartTime!.compareTo(b.matchStartTime!));
        var wins = 0;
        var losses = 0;
        var draws = 0;
        var net = 0;
        for (final u in list) {
          net += u.rrEarned;
          final known = outcomes[u.matchId];
          final o = known == null || known == MatchOutcome.unknown
              ? MatchOutcome.fromRr(u.rrEarned)
              : known;
          switch (o) {
            case MatchOutcome.win:
              wins++;
            case MatchOutcome.loss:
              losses++;
            case MatchOutcome.draw || MatchOutcome.unknown:
              draws++;
          }
        }
        return DailyRr(
          date: day,
          matches: List.unmodifiable(list),
          netRr: net,
          wins: wins,
          losses: losses,
          draws: draws,
        );
      }(),
  ];
}

/// The Daily RR entry of the local day of [now] (`null` without ranked
/// matches today). [days] as returned by [groupDailyRr]. [toLocal] converts
/// [now] to the display zone (default: the device's).
DailyRr? dailyRrOn(
  List<DailyRr> days,
  DateTime now, {
  DateTime Function(DateTime)? toLocal,
}) {
  final local = (toLocal ?? (DateTime d) => d.toLocal())(now);
  final today = DateTime(local.year, local.month, local.day);
  for (final d in days) {
    if (d.date == today) return d;
  }
  return null;
}

/// "7 ngày qua" of the Daily RR screen (PR-15): what was played in the last
/// [windowDays] local days, and the RR trend of the newest listed days.
@immutable
class WeekSummary {
  const WeekSummary({
    required this.netRr,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.matches,
    required this.daysPlayed,
    required this.trend,
  });

  /// Σ RR earned in the window.
  final int netRr;
  final int wins;
  final int losses;
  final int draws;
  final int matches;

  /// Days of the window with at least one ranked match.
  final int daysPlayed;

  /// Net RR of the newest [WeekSummary] trend days that have matches, oldest
  /// first (days without ranked matches are not listed).
  final List<int> trend;

  bool get isEmpty => daysPlayed == 0;

  /// Σ of [trend].
  int get trendNet => trend.fold<int>(0, (a, b) => a + b);
}

/// Summary of [days] (newest first, as [groupDailyRr] returns them) for the
/// [windowDays] local days ending on the day of [now]. Days are calendar days
/// of the display zone ([toLocal]), so a daylight-saving day is still one
/// day.
WeekSummary weekSummary(
  List<DailyRr> days,
  DateTime now, {
  int windowDays = 7,
  int trendDays = 14,
  DateTime Function(DateTime)? toLocal,
}) {
  final local = (toLocal ?? (DateTime d) => d.toLocal())(now);
  final from = DateTime(local.year, local.month, local.day - (windowDays - 1));
  final week = [
    for (final d in days)
      if (!d.date.isBefore(from)) d,
  ];
  return WeekSummary(
    netRr: week.fold<int>(0, (a, d) => a + d.netRr),
    wins: week.fold<int>(0, (a, d) => a + d.wins),
    losses: week.fold<int>(0, (a, d) => a + d.losses),
    draws: week.fold<int>(0, (a, d) => a + d.draws),
    matches: week.fold<int>(0, (a, d) => a + d.matches.length),
    daysPlayed: week.length,
    trend: List.unmodifiable(
      [for (final d in days.take(trendDays)) d.netRr].reversed,
    ),
  );
}

/// Progress inside the current tier (PR-15): the one calculation behind the
/// rank card's bar and Home's "Còn N RR lên rank".
@immutable
class RankProgress {
  const RankProgress({required this.fraction, required this.rrToNext});

  /// `rr / 100`, 0–1.
  final double fraction;

  /// RR missing to the next tier, 0–100.
  final int rrToNext;
}

/// The RR progress of [rank]; `null` when unranked (placements included) or
/// from Immortal 1 up, where RR is not a 0–100 ladder.
RankProgress? rankProgress(RankInfo rank) {
  if (rank.isUnranked || rank.normalizedTier >= kRankUpMaxTier) return null;
  return RankProgress(
    fraction: (rank.rr / kRrPerTier).clamp(0.0, 1.0),
    rrToNext: (kRrPerTier - rank.rr).clamp(0, kRrPerTier),
  );
}

// ------------------------------------------------------------ Rank-Up (§9.7)

/// Highest target of the calculator: Immortal 1 (Episode 5+ tier 24).
const kRankUpMaxTier = 24;

/// RR per tier below Immortal.
const kRrPerTier = 100;

/// Win rates of the comparison table (S41).
const kRankUpWinRates = <double>[0.45, 0.50, 0.55, 0.60, 0.65];

/// Recent ranked form (SUMMARY §9.7 step 2).
@immutable
class RankUpForm {
  const RankUpForm({
    this.avgGain = 0,
    this.avgLoss = 0,
    this.wins = 0,
    this.losses = 0,
  });

  /// `G`: mean positive `RankedRatingEarned`.
  final double avgGain;

  /// `L`: mean |negative `RankedRatingEarned`|.
  final double avgLoss;
  final int wins;
  final int losses;

  int get sampleSize => wins + losses;

  /// `p` = wins / (wins + losses); `null` without decided matches.
  double? get winRate => sampleSize == 0 ? null : wins / sampleSize;

  /// Expected RR per match at win rate [p]: `p·G − (1−p)·L`.
  double expectedRrPerMatch(double p) => p * avgGain - (1 - p) * avgLoss;
}

/// Form from the newest [window] competitive updates (draws / remakes with
/// 0 RR are ignored).
RankUpForm rankUpFormOf(Iterable<CompetitiveUpdate> rows, {int window = 20}) {
  final seen = <String>{};
  final recent = [
    for (final u in rows)
      if (seen.add(u.matchId)) u,
  ]..sort(compareUpdatesNewestFirst);
  var gain = 0;
  var loss = 0;
  var wins = 0;
  var losses = 0;
  for (final u in recent.take(window)) {
    if (u.rrEarned > 0) {
      wins++;
      gain += u.rrEarned;
    } else if (u.rrEarned < 0) {
      losses++;
      loss += -u.rrEarned;
    }
  }
  return RankUpForm(
    avgGain: wins == 0 ? 0 : gain / wins,
    avgLoss: losses == 0 ? 0 : loss / losses,
    wins: wins,
    losses: losses,
  );
}

/// RR still needed: `(targetTier − tier) × 100 − rr` (tiers 3..24 are
/// 100 RR each). Negative when the target is already reached.
int rrNeededFor({
  required int tier,
  required int rr,
  required int targetTier,
}) => (targetTier - tier) * kRrPerTier - rr;

/// Matches needed at win rate [winRate]: `ceil(rrNeeded / E)` with
/// `E = p·G − (1−p)·L`; `null` when `E <= 0` ("không ước tính được"),
/// 0 when nothing is needed.
int? matchesNeeded({
  required int rrNeeded,
  required double winRate,
  required double avgGain,
  required double avgLoss,
}) {
  if (rrNeeded <= 0) return 0;
  final e = winRate * avgGain - (1 - winRate) * avgLoss;
  if (!e.isFinite || e <= 0) return null;
  return (rrNeeded / e).ceil();
}

/// Result of the Rank-Up Calculator (R6, S41).
@immutable
class RankUpEstimate {
  const RankUpEstimate({
    required this.currentTier,
    required this.currentRr,
    required this.targetTier,
    required this.rrNeeded,
    required this.form,
    required this.byWinRate,
    this.matchesAtCurrentForm,
    this.bestCaseWins,
  });

  /// Episode-5 tiers.
  final int currentTier;
  final int currentRr;
  final int targetTier;

  /// "Còn thiếu 164 RR".
  final int rrNeeded;
  final RankUpForm form;

  /// "Với phong độ hiện tại: ≈ 9 trận"; `null` = cannot estimate.
  final int? matchesAtCurrentForm;

  /// "Tốt nhất: 7 trận thắng liên tiếp" = `ceil(need / G)`; `null` without
  /// recent wins.
  final int? bestCaseWins;

  /// Matches needed at 45 … 65 % win rate (same G and L).
  final List<({double winRate, int? matches})> byWinRate;

  bool get alreadyReached => rrNeeded <= 0;

  /// 0–1 progress from the current tier to the target
  /// (`(span − rrNeeded) / span`, `span` = 100 RR per tier).
  double get progress {
    final span = (targetTier - currentTier) * kRrPerTier;
    return span <= 0 ? 1.0 : ((span - rrNeeded) / span).clamp(0.0, 1.0);
  }

  /// Whether the [byWinRate] row of [winRate] matches the player's own
  /// recent win rate (within 2.5 points): the row the table highlights.
  bool isNearestWinRate(double winRate) {
    final p = form.winRate;
    return p != null && (p - winRate).abs() < 0.025;
  }
}

/// Targets the calculator offers from [currentTier] (Episode-5 tier): every
/// tier above it up to Immortal 1. Empty when unranked or already
/// Immortal+.
List<int> rankUpTargets(int currentTier) => [
  if (currentTier > 2)
    for (var t = currentTier + 1; t <= kRankUpMaxTier; t++) t,
];

/// Estimate for reaching [targetTier] (SUMMARY §9.7). Tiers are Episode-5
/// tiers (use `RankInfo.normalizedTier`). `null` when unranked, Immortal+,
/// or the target is not above the current tier / beyond Immortal 1.
RankUpEstimate? estimateRankUp({
  required int currentTier,
  required int currentRr,
  required int targetTier,
  required RankUpForm form,
  List<double> winRates = kRankUpWinRates,
}) {
  if (currentTier <= 2 ||
      currentTier >= kRankUpMaxTier ||
      targetTier <= currentTier ||
      targetTier > kRankUpMaxTier) {
    return null;
  }
  final need = rrNeededFor(
    tier: currentTier,
    rr: currentRr,
    targetTier: targetTier,
  );
  final p = form.winRate;
  return RankUpEstimate(
    currentTier: currentTier,
    currentRr: currentRr,
    targetTier: targetTier,
    rrNeeded: need,
    form: form,
    matchesAtCurrentForm: p == null
        ? null
        : matchesNeeded(
            rrNeeded: need,
            winRate: p,
            avgGain: form.avgGain,
            avgLoss: form.avgLoss,
          ),
    bestCaseWins: need <= 0
        ? 0
        : form.avgGain > 0
        ? (need / form.avgGain).ceil()
        : null,
    byWinRate: List.unmodifiable([
      for (final rate in winRates)
        (
          winRate: rate,
          matches: form.sampleSize == 0
              ? null
              : matchesNeeded(
                  rrNeeded: need,
                  winRate: rate,
                  avgGain: form.avgGain,
                  avgLoss: form.avgLoss,
                ),
        ),
    ]),
  );
}
