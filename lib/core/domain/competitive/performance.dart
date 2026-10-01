/// Cross-match performance analytics (PR-01): one compact stat line per
/// match of an own account, and pure aggregates over any set of lines (by
/// agent, map, queue, attack / defense side, time buckets).
///
/// Everything here is deterministic and locale-independent: no `DateTime.now`
/// (callers inject `now` and `toLocal`), no text (enums, ids and numbers
/// only), no I/O. Every number traces back to a Riot P-14 field:
///
/// | Metric | Source |
/// |---|---|
/// | Win / loss / draw | `teams[].won` via `MatchDetails.resultFor` |
/// | K / D / A, score, rounds | `players[].stats` |
/// | ACS | Σ score / Σ rounds over round-based matches |
/// | ADR | Σ enemy damage / Σ rounds (matches with damage data) |
/// | HS% | Σ headshots / Σ hits, from `damage[]` (hits, not kills) |
/// | First bloods / deaths | `firstBloodPlayer`, else earliest kill |
/// | Attack / defense | `winningTeamRole`, else the team of `bombPlanter` / `bombDefuser` |
/// | Multi-kills | `kills[]` grouped by round, only when they add up to `stats.kills` |
///
/// Clutches are NOT derivable from P-14 (the ceremony has no player) and are
/// never computed. Attack / defense and multi-kills stay "unknown" whenever
/// the payload does not prove them.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'match_models.dart';
import 'streak.dart';
import 'viewer.dart' show baseQueueId;

/// Fewer matches than this in a group show no rates (PR-01 min-sample rule).
const kPerfMinGames = 3;

// ------------------------------------------------------------------ sides

/// Side of [teamId] in [round] when the payload proves it, else `null`:
///
/// 1. `winningTeamRole` with `winningTeam` (2026 payloads);
/// 2. the team of the `bombPlanter` attacked, so every other team defended;
/// 3. the team of the `bombDefuser` defended.
///
/// A round that only says "eliminated" or "timer expired" in an older payload
/// has no proof and stays `null` (never guessed from the half or the map).
TeamRole? roundSideOf(MatchDetails details, RoundResult round, String? teamId) {
  if (teamId == null) return null;
  final byRole = round.roleOf(teamId);
  if (byRole != null) return byRole;
  final planter = round.bombPlanter;
  if (planter != null) {
    final team = details.player(planter)?.teamId;
    if (team != null) {
      return team == teamId ? TeamRole.attacker : TeamRole.defender;
    }
  }
  final defuser = round.bombDefuser;
  if (defuser != null) {
    final team = details.player(defuser)?.teamId;
    if (team != null) {
      return team == teamId ? TeamRole.defender : TeamRole.attacker;
    }
  }
  return null;
}

/// One player's rounds on one side in one match.
@immutable
class SideLine {
  const SideLine({
    this.rounds = 0,
    this.won = 0,
    this.kills,
    this.deaths,
    this.firstBloods = 0,
    this.firstDeaths = 0,
  });

  static const none = SideLine();

  /// Rounds played on this side whose side the payload proves.
  final int rounds;

  /// Of those, rounds the player's team won.
  final int won;

  /// Kills / deaths of the player on this side; `null` when the kill feed
  /// does not add up to the match totals (then it is not trusted).
  final int? kills;
  final int? deaths;
  final int firstBloods;
  final int firstDeaths;

  bool get isEmpty => rounds == 0;

  @override
  bool operator ==(Object other) =>
      other is SideLine &&
      other.rounds == rounds &&
      other.won == won &&
      other.kills == kills &&
      other.deaths == deaths &&
      other.firstBloods == firstBloods &&
      other.firstDeaths == firstDeaths;

  @override
  int get hashCode =>
      Object.hash(rounds, won, kills, deaths, firstBloods, firstDeaths);
}

// ------------------------------------------------------------------ line

/// The compact stat line of one match for one own account: what the
/// analytics need and nothing else (≈ 150 B on disk).
@immutable
class MatchStatLine {
  const MatchStatLine({
    required this.matchId,
    required this.startedAt,
    required this.outcome,
    this.queueId = '',
    this.mapId,
    this.agentId,
    this.mode = MatchModeKind.standard,
    this.kills = 0,
    this.deaths = 0,
    this.assists = 0,
    this.score = 0,
    this.rounds = 0,
    this.damage,
    this.headshots = 0,
    this.bodyshots = 0,
    this.legshots = 0,
    this.firstBloods = 0,
    this.firstDeaths = 0,
    this.attack = SideLine.none,
    this.defense = SideLine.none,
    this.multiKills,
  });

  /// The line of [puuid] in [details], or `null` when there is nothing to
  /// count: not a participant, spectator, no stats, unfinished match, no
  /// start time or an unknown result.
  static MatchStatLine? fromDetails(MatchDetails details, String? puuid) {
    final me = details.player(puuid);
    final info = details.info;
    if (me == null || me.isObserver || me.stats == null) return null;
    if (!info.isCompleted && info.completionState != 'Completed') return null;
    final start = info.startTime;
    if (start == null) return null;
    final result = details.resultFor(me.subject);
    if (result.outcome == MatchOutcome.unknown) return null;
    final s = details.statsFor(me.subject);
    if (s == null) return null;

    final mode = details.modeKind;
    var attack = SideLine.none;
    var defense = SideLine.none;
    List<int>? multi;
    if (mode.isRoundBased && details.playedRounds.isNotEmpty) {
      final sides = _rounds(details, me, s);
      attack = sides.attack;
      defense = sides.defense;
      multi = sides.multiKills;
    }
    return MatchStatLine(
      matchId: details.matchId,
      startedAt: start.toUtc(),
      outcome: result.outcome,
      queueId: info.isCustom ? '' : baseQueueId(info.queueId),
      mapId: info.mapId,
      agentId: me.characterId,
      mode: mode,
      kills: s.kills,
      deaths: s.deaths,
      assists: s.assists,
      score: s.score,
      rounds: s.roundsPlayed,
      damage: s.adr == null ? null : s.damage,
      headshots: s.headshots,
      bodyshots: s.bodyshots,
      legshots: s.legshots,
      firstBloods: s.firstBloods,
      firstDeaths: s.firstDeaths,
      attack: attack,
      defense: defense,
      multiKills: multi,
    );
  }

  /// The line of a match-list summary. It has no round data, so sides and
  /// multi-kills stay unknown. Used for the recent form of players whose
  /// ledger this device does not keep.
  static MatchStatLine? fromSummary(MatchPlayerSummary s) {
    final outcome = s.result.outcome;
    if (outcome == MatchOutcome.unknown) return null;
    final st = s.stats;
    final info = s.info;
    return MatchStatLine(
      matchId: info.matchId,
      startedAt:
          info.startTime?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      outcome: outcome,
      queueId: info.isCustom ? '' : baseQueueId(info.queueId),
      mapId: info.mapId,
      agentId: s.player.characterId,
      mode: info.modeKind,
      kills: st.kills,
      deaths: st.deaths,
      assists: st.assists,
      score: st.score,
      rounds: st.roundsPlayed,
      damage: st.adr == null ? null : st.damage,
      headshots: st.headshots,
      bodyshots: st.bodyshots,
      legshots: st.legshots,
      firstBloods: st.firstBloods,
      firstDeaths: st.firstDeaths,
    );
  }

  /// Lowercase match uuid (the ledger's unique key).
  final String matchId;

  /// Match start (UTC).
  final DateTime startedAt;
  final MatchOutcome outcome;

  /// PC queue id (`competitive`, `unrated`…); `''` for custom games.
  final String queueId;

  /// Map path (`/Game/Maps/Ascent/Ascent`).
  final String? mapId;

  /// Agent uuid (lowercase).
  final String? agentId;
  final MatchModeKind mode;
  final int kills;
  final int deaths;
  final int assists;
  final int score;

  /// Rounds the player took part in (1 in Deathmatch: not a round count).
  final int rounds;

  /// Damage dealt to enemies; `null` without damage data (Deathmatch…).
  final int? damage;
  final int headshots;
  final int bodyshots;
  final int legshots;
  final int firstBloods;
  final int firstDeaths;
  final SideLine attack;
  final SideLine defense;

  /// Rounds with exactly 2, 3, 4 and 5+ kills; `null` unless the kill feed
  /// adds up to `stats.kills` (then multi-kills are unknown).
  final List<int>? multiKills;

  /// Round-based two-team modes: the only ones whose ACS, ADR, HS%, K/D and
  /// first bloods are comparable (PR-02).
  bool get isRoundBased => mode.isRoundBased;

  int get hits => headshots + bodyshots + legshots;

  @override
  bool operator ==(Object other) =>
      other is MatchStatLine &&
      other.matchId == matchId &&
      other.startedAt == startedAt &&
      other.outcome == outcome &&
      other.queueId == queueId &&
      other.mapId == mapId &&
      other.agentId == agentId &&
      other.mode == mode &&
      other.kills == kills &&
      other.deaths == deaths &&
      other.assists == assists &&
      other.score == score &&
      other.rounds == rounds &&
      other.damage == damage &&
      other.headshots == headshots &&
      other.bodyshots == bodyshots &&
      other.legshots == legshots &&
      other.firstBloods == firstBloods &&
      other.firstDeaths == firstDeaths &&
      other.attack == attack &&
      other.defense == defense &&
      listEquals(other.multiKills, multiKills);

  @override
  int get hashCode => Object.hash(
    matchId,
    startedAt,
    outcome,
    queueId,
    mapId,
    agentId,
    mode,
    kills,
    deaths,
    assists,
    score,
    rounds,
    damage,
    Object.hash(
      headshots,
      bodyshots,
      legshots,
      firstBloods,
      firstDeaths,
      attack,
      defense,
      multiKills == null ? null : Object.hashAll(multiKills!),
    ),
  );

  @override
  String toString() => 'MatchStatLine($matchId, ${outcome.name})';
}

class _SideAcc {
  var rounds = 0;
  var won = 0;
  var kills = 0;
  var deaths = 0;
  var firstBloods = 0;
  var firstDeaths = 0;

  /// A side without a single provable round is [SideLine.none] (unknown),
  /// never a row of zeros.
  SideLine build({required bool feedOk}) => rounds == 0
      ? SideLine.none
      : SideLine(
          rounds: rounds,
          won: won,
          kills: feedOk ? kills : null,
          deaths: feedOk ? deaths : null,
          firstBloods: firstBloods,
          firstDeaths: firstDeaths,
        );
}

({SideLine attack, SideLine defense, List<int>? multiKills}) _rounds(
  MatchDetails d,
  MatchPlayer me,
  ScoreboardStats stats,
) {
  final id = me.subject;
  final team = me.teamId;
  final byRound = <int, List<Kill>>{};
  for (final k in d.kills) {
    (byRound[k.round] ??= []).add(k);
  }
  bool isEnemy(String subject) {
    final other = d.player(subject)?.teamId;
    return other == null || team == null || other != team;
  }

  final atk = _SideAcc();
  final def = _SideAcc();
  final multi = [0, 0, 0, 0];
  var derivedKills = 0;
  var derivedDeaths = 0;
  for (final r in d.playedRounds) {
    final ks = byRound[r.roundNum] ?? const <Kill>[];
    final mine = ks
        .where((k) => k.killer == id && k.victim != id && isEnemy(k.victim))
        .length;
    final died = ks.where((k) => k.victim == id).length;
    derivedKills += mine;
    derivedDeaths += died > 0 ? 1 : 0;
    if (mine >= 2) multi[math.min(mine, 5) - 2]++;

    final winner = r.winningTeam;
    final side = winner == null ? null : roundSideOf(d, r, team);
    if (side == null) continue;
    final acc = side == TeamRole.attacker ? atk : def;
    acc.rounds++;
    if (winner == team) acc.won++;
    acc.kills += mine;
    if (died > 0) acc.deaths++;
    final first = ks.isEmpty ? null : ks.first;
    final fb = r.firstBloodPlayer ?? first?.killer;
    if (fb == id) acc.firstBloods++;
    if (first?.victim == id) acc.firstDeaths++;
  }
  // The kill feed is trusted only when it adds up to the official totals.
  final feedOk =
      d.kills.isNotEmpty &&
      derivedKills == stats.kills &&
      derivedDeaths == stats.deaths;
  return (
    attack: atk.build(feedOk: feedOk),
    defense: def.build(feedOk: feedOk),
    multiKills: feedOk ? List.unmodifiable(multi) : null,
  );
}

// ------------------------------------------------------------- aggregates

/// Totals of one side over many matches.
@immutable
class SideTotals {
  const SideTotals({
    this.rounds = 0,
    this.won = 0,
    this.feedRounds = 0,
    this.kills = 0,
    this.deaths = 0,
    this.firstBloods = 0,
    this.firstDeaths = 0,
  });

  final int rounds;
  final int won;

  /// Rounds of the matches whose kill feed is trusted (the denominator of
  /// [kills], [deaths] and the first-blood counts).
  final int feedRounds;
  final int kills;
  final int deaths;
  final int firstBloods;
  final int firstDeaths;

  /// Rounds won / rounds played on this side; `null` without rounds.
  double? get winRate => rounds == 0 ? null : won / rounds;

  /// Kills per death on this side (deaths floored at 1); `null` without a
  /// trusted kill feed.
  double? get kd => feedRounds == 0 ? null : kills / math.max(deaths, 1);

  bool get isEmpty => rounds == 0;
}

/// Totals over a set of [MatchStatLine]s. Rates that need round data
/// (K/D, ACS, ADR, HS%, first bloods) only use round-based matches; the win
/// rate uses every decided match.
@immutable
class PerfAggregate {
  const PerfAggregate({
    this.games = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.roundGames = 0,
    this.rounds = 0,
    this.kills = 0,
    this.deaths = 0,
    this.assists = 0,
    this.score = 0,
    this.damage = 0,
    this.damageRounds = 0,
    this.damageGames = 0,
    this.hitGames = 0,
    this.headshots = 0,
    this.hits = 0,
    this.firstBloods = 0,
    this.firstDeaths = 0,
    this.attack = const SideTotals(),
    this.defense = const SideTotals(),
    this.multiGames = 0,
    this.multi2 = 0,
    this.multi3 = 0,
    this.multi4 = 0,
    this.multi5 = 0,
  });

  static const empty = PerfAggregate();

  /// Aggregates [lines] (any order).
  factory PerfAggregate.of(Iterable<MatchStatLine> lines) {
    var games = 0, wins = 0, losses = 0, draws = 0;
    var roundGames = 0, rounds = 0, kills = 0, deaths = 0, assists = 0;
    var score = 0, damage = 0, damageRounds = 0, headshots = 0, hits = 0;
    var damageGames = 0, hitGames = 0;
    var fb = 0, fd = 0;
    var multiGames = 0, m2 = 0, m3 = 0, m4 = 0, m5 = 0;
    final atk = _SideSum();
    final def = _SideSum();
    for (final l in lines) {
      games++;
      switch (l.outcome) {
        case MatchOutcome.win:
          wins++;
        case MatchOutcome.loss:
          losses++;
        case MatchOutcome.draw:
          draws++;
        case MatchOutcome.unknown:
          break;
      }
      if (!l.isRoundBased || l.rounds <= 0) continue;
      roundGames++;
      rounds += l.rounds;
      kills += l.kills;
      deaths += l.deaths;
      assists += l.assists;
      score += l.score;
      headshots += l.headshots;
      hits += l.hits;
      if (l.hits > 0) hitGames++;
      fb += l.firstBloods;
      fd += l.firstDeaths;
      if (l.damage case final dmg?) {
        damageGames++;
        damage += dmg;
        damageRounds += l.rounds;
      }
      atk.add(l.attack);
      def.add(l.defense);
      if (l.multiKills case final m? when m.length >= 4) {
        multiGames++;
        m2 += m[0];
        m3 += m[1];
        m4 += m[2];
        m5 += m[3];
      }
    }
    return PerfAggregate(
      games: games,
      wins: wins,
      losses: losses,
      draws: draws,
      roundGames: roundGames,
      rounds: rounds,
      kills: kills,
      deaths: deaths,
      assists: assists,
      score: score,
      damage: damage,
      damageRounds: damageRounds,
      damageGames: damageGames,
      hitGames: hitGames,
      headshots: headshots,
      hits: hits,
      firstBloods: fb,
      firstDeaths: fd,
      attack: atk.build(),
      defense: def.build(),
      multiGames: multiGames,
      multi2: m2,
      multi3: m3,
      multi4: m4,
      multi5: m5,
    );
  }

  /// Every match counted (round-based or not).
  final int games;
  final int wins;
  final int losses;
  final int draws;

  /// Round-based matches with round data: the sample of the per-round stats.
  final int roundGames;
  final int rounds;
  final int kills;
  final int deaths;
  final int assists;
  final int score;
  final int damage;

  /// Rounds of the matches that have damage data (the ADR denominator).
  final int damageRounds;
  final int damageGames;
  final int hitGames;
  final int headshots;
  final int hits;
  final int firstBloods;
  final int firstDeaths;
  final SideTotals attack;
  final SideTotals defense;

  /// Matches whose multi-kills are known, and the rounds with 2 / 3 / 4 /
  /// 5+ kills in them.
  final int multiGames;
  final int multi2;
  final int multi3;
  final int multi4;
  final int multi5;

  bool get isEmpty => games == 0;

  /// Whether the sample is large enough to show rates.
  bool qualifies([int minGames = kPerfMinGames]) => games >= minGames;

  /// Each rate requires enough matches proving its own denominator.
  bool get hasWinRateSample => wins + losses >= kPerfMinGames;
  bool get hasRoundSample => roundGames >= kPerfMinGames;
  bool get hasDamageSample => damageGames >= kPerfMinGames;
  bool get hasHitSample => hitGames >= kPerfMinGames;

  /// Wins / decided games (draws excluded); `null` without decided games.
  double? get winRate {
    final decided = wins + losses;
    return decided == 0 ? null : wins / decided;
  }

  /// Σ kills / Σ deaths (deaths floored at 1) over round-based matches.
  double? get kd => roundGames == 0 ? null : kills / math.max(deaths, 1);

  /// Σ score / Σ rounds over round-based matches (never a mean of
  /// per-match values, never mixing Deathmatch scores in).
  double? get acs => rounds == 0 ? null : score / rounds;

  /// Σ enemy damage / Σ rounds of the matches that have damage data.
  double? get adr => damageRounds == 0 ? null : damage / damageRounds;

  /// Headshots / all hits; `null` without hit data.
  double? get headshotRate => hits == 0 ? null : headshots / hits;

  /// Opening kills per match (round-based matches).
  double? get firstBloodsPerGame =>
      roundGames == 0 ? null : firstBloods / roundGames;

  double? get firstDeathsPerGame =>
      roundGames == 0 ? null : firstDeaths / roundGames;

  /// Rounds with 3+ kills among the matches with known multi-kills.
  int get multiKills3Plus => multi3 + multi4 + multi5;

  /// Aces (5 kills in a round).
  int get aces => multi5;

  bool get hasMultiKills => multiGames > 0;
  bool get hasSides => !attack.isEmpty || !defense.isEmpty;
}

class _SideSum {
  var rounds = 0;
  var won = 0;
  var feedRounds = 0;
  var kills = 0;
  var deaths = 0;
  var fb = 0;
  var fd = 0;

  void add(SideLine s) {
    if (s.isEmpty) return;
    rounds += s.rounds;
    won += s.won;
    if (s.kills != null && s.deaths != null) {
      feedRounds += s.rounds;
      kills += s.kills!;
      deaths += s.deaths!;
      fb += s.firstBloods;
      fd += s.firstDeaths;
    }
  }

  SideTotals build() => SideTotals(
    rounds: rounds,
    won: won,
    feedRounds: feedRounds,
    kills: kills,
    deaths: deaths,
    firstBloods: fb,
    firstDeaths: fd,
  );
}

// ------------------------------------------------------------- filtering

/// [lines] newest first (ties by match id, so the order is deterministic).
List<MatchStatLine> sortedNewestFirst(Iterable<MatchStatLine> lines) =>
    [...lines]..sort((a, b) {
      final c = b.startedAt.compareTo(a.startedAt);
      return c != 0 ? c : a.matchId.compareTo(b.matchId);
    });

/// A filter over the ledger (all fields optional; unset = no constraint).
@immutable
class PerfFilter {
  const PerfFilter({this.queueId, this.mapId, this.agentId, this.since});

  /// PC queue id; `''` = custom games; `null` = every queue.
  final String? queueId;
  final String? mapId;
  final String? agentId;

  /// Only matches that started at or after this instant.
  final DateTime? since;

  bool get isEmpty =>
      queueId == null && mapId == null && agentId == null && since == null;

  bool accepts(MatchStatLine l) {
    if (queueId != null && l.queueId != queueId) return false;
    if (mapId != null && l.mapId?.toLowerCase() != mapId!.toLowerCase()) {
      return false;
    }
    if (agentId != null && l.agentId != agentId!.toLowerCase()) return false;
    if (since != null && l.startedAt.isBefore(since!)) return false;
    return true;
  }

  List<MatchStatLine> apply(Iterable<MatchStatLine> lines) => [
    for (final l in lines)
      if (accepts(l)) l,
  ];

  PerfFilter copyWith({
    String? Function()? queueId,
    String? Function()? mapId,
    String? Function()? agentId,
    DateTime? Function()? since,
  }) => PerfFilter(
    queueId: queueId == null ? this.queueId : queueId(),
    mapId: mapId == null ? this.mapId : mapId(),
    agentId: agentId == null ? this.agentId : agentId(),
    since: since == null ? this.since : since(),
  );

  @override
  bool operator ==(Object other) =>
      other is PerfFilter &&
      other.queueId == queueId &&
      other.mapId == mapId &&
      other.agentId == agentId &&
      other.since == since;

  @override
  int get hashCode => Object.hash(queueId, mapId, agentId, since);
}

/// The lines that started within [window] before [now] (instants, so it is
/// safe across daylight-saving changes).
List<MatchStatLine> withinLast(
  Iterable<MatchStatLine> lines, {
  required DateTime now,
  required Duration window,
}) {
  final from = now.toUtc().subtract(window);
  return [
    for (final l in lines)
      if (!l.startedAt.isBefore(from)) l,
  ];
}

// -------------------------------------------------------------- grouping

/// One row of a "by agent / map / queue" table.
@immutable
class PerfGroup {
  const PerfGroup(this.key, this.aggregate);

  /// Agent uuid, map path or queue id.
  final String key;
  final PerfAggregate aggregate;

  int get games => aggregate.games;
}

List<PerfGroup> _groupBy(
  Iterable<MatchStatLine> lines,
  String? Function(MatchStatLine) keyOf,
) {
  final buckets = <String, List<MatchStatLine>>{};
  for (final l in lines) {
    final key = keyOf(l);
    if (key == null) continue;
    (buckets[key] ??= []).add(l);
  }
  final groups = [
    for (final e in buckets.entries)
      PerfGroup(e.key, PerfAggregate.of(e.value)),
  ];
  // Most played first; ties by key so the order never depends on input.
  groups.sort((a, b) {
    final c = b.games.compareTo(a.games);
    return c != 0 ? c : a.key.compareTo(b.key);
  });
  return groups;
}

/// Performance per agent (matches without an agent are left out).
List<PerfGroup> groupByAgent(Iterable<MatchStatLine> lines) =>
    _groupBy(lines, (l) => l.agentId);

/// Performance per map (matches without a map are left out).
List<PerfGroup> groupByMap(Iterable<MatchStatLine> lines) =>
    _groupBy(lines, (l) => l.mapId?.toLowerCase());

/// Performance per queue (`''` = custom games).
List<PerfGroup> groupByQueue(Iterable<MatchStatLine> lines) =>
    _groupBy(lines, (l) => l.queueId);

// ---------------------------------------------------------------- trends

/// Width of a trend bucket.
enum TrendBucket { day, week, month }

/// One point of a trend: the local calendar date the bucket starts on
/// (`DateTime.utc(y, m, d)` used as a plain date, never as an instant;
/// weeks start on Monday) and everything played in it.
@immutable
class PerfTrendPoint {
  const PerfTrendPoint(this.start, this.aggregate);

  final DateTime start;
  final PerfAggregate aggregate;
}

/// Calendar date of [utc] in the caller's zone, as `DateTime.utc(y, m, d)`
/// (arithmetic on it is immune to daylight-saving changes).
DateTime _localDate(DateTime utc, DateTime Function(DateTime) toLocal) {
  final l = toLocal(utc);
  return DateTime.utc(l.year, l.month, l.day);
}

DateTime _bucketStart(DateTime date, TrendBucket bucket) => switch (bucket) {
  TrendBucket.day => date,
  TrendBucket.week => date.subtract(Duration(days: date.weekday - 1)),
  TrendBucket.month => DateTime.utc(date.year, date.month),
};

/// [lines] grouped into [bucket]s by their local start date, oldest bucket
/// first. Buckets without matches are absent (a trend never interpolates).
List<PerfTrendPoint> trendOf(
  Iterable<MatchStatLine> lines, {
  required TrendBucket bucket,
  required DateTime Function(DateTime utc) toLocal,
}) {
  final buckets = <DateTime, List<MatchStatLine>>{};
  for (final l in lines) {
    final start = _bucketStart(_localDate(l.startedAt, toLocal), bucket);
    (buckets[start] ??= []).add(l);
  }
  final starts = buckets.keys.toList()..sort();
  return [
    for (final s in starts) PerfTrendPoint(s, PerfAggregate.of(buckets[s]!)),
  ];
}

/// The bucket width that fits the span of [lines]: days up to 2 weeks,
/// weeks up to ~4 months, months beyond.
TrendBucket suggestTrendBucket(
  Iterable<MatchStatLine> lines, {
  required DateTime Function(DateTime utc) toLocal,
}) {
  DateTime? first;
  DateTime? last;
  for (final l in lines) {
    final d = _localDate(l.startedAt, toLocal);
    if (first == null || d.isBefore(first)) first = d;
    if (last == null || d.isAfter(last)) last = d;
  }
  if (first == null || last == null) return TrendBucket.day;
  final days = last.difference(first).inDays;
  return days <= 14
      ? TrendBucket.day
      : days <= 120
      ? TrendBucket.week
      : TrendBucket.month;
}

/// Metrics a trend can plot.
enum PerfMetric { winRate, kd, acs, adr, headshotRate }

/// The value of [metric] in [a]; `null` when unknown.
double? metricOf(PerfAggregate a, PerfMetric metric) => switch (metric) {
  PerfMetric.winRate => a.winRate,
  PerfMetric.kd => a.kd,
  PerfMetric.acs => a.acs,
  PerfMetric.adr => a.adr,
  PerfMetric.headshotRate => a.headshotRate,
};

/// The trend points that hold at least [minGames] matches (the min-sample
/// rule: a rate from one or two matches is noise).
List<PerfTrendPoint> qualifiedPoints(
  List<PerfTrendPoint> points, {
  int minGames = kPerfMinGames,
}) => [
  for (final p in points)
    if (p.aggregate.qualifies(minGames)) p,
];

/// Streak at the head of [lines] (any order; scope = whatever was passed).
Streak? streakOfLines(Iterable<MatchStatLine> lines) =>
    currentStreak(sortedNewestFirst(lines).map((l) => l.outcome));
