import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/domain/competitive/competitive.dart';

/// The breakdown tables of the "Hiệu suất" screen.
enum PerfSegment { agents, maps, queues }

/// How far back the screen looks.
enum PerfPeriod {
  all(null),
  days30(Duration(days: 30)),
  days7(Duration(days: 7));

  const PerfPeriod(this.window);

  /// `null` = the whole ledger.
  final Duration? window;
}

/// What the per-match chart plots. Every metric is a per-round number, so
/// only round-based matches have one (PR-02).
enum PerfMatchMetric { acs, kd, adr, headshotRate }

/// The newest matches the per-match chart shows.
const kPerfChartMatches = 20;

/// The value of [metric] in one match, or `null` when the match cannot prove
/// it (no rounds, no damage or hit data).
double? matchMetricOf(MatchStatLine line, PerfMatchMetric metric) {
  if (!line.isRoundBased || line.rounds <= 0) return null;
  return switch (metric) {
    PerfMatchMetric.acs => line.score / line.rounds,
    PerfMatchMetric.kd => line.kills / math.max(line.deaths, 1),
    PerfMatchMetric.adr => switch (line.damage) {
      final damage? => damage / line.rounds,
      null => null,
    },
    PerfMatchMetric.headshotRate =>
      line.hits == 0 ? null : line.headshots / line.hits,
  };
}

/// The same metric over many matches, with the screen's own definitions
/// (Σ score / Σ rounds, never a mean of per-match values).
double? aggregateMetricOf(PerfAggregate a, PerfMatchMetric metric) =>
    switch (metric) {
      PerfMatchMetric.acs => a.acs,
      PerfMatchMetric.kd => a.kd,
      PerfMatchMetric.adr => a.adr,
      PerfMatchMetric.headshotRate => a.headshotRate,
    };

/// One bar of the per-match chart.
@immutable
class PerfChartPoint {
  const PerfChartPoint(this.line, this.value);

  final MatchStatLine line;
  final double value;
}

/// The per-match chart of [newestFirst]: the newest [limit] matches that
/// have a value for [metric], oldest first (left to right), and the
/// aggregate of exactly those matches for the average line.
@immutable
class PerfMatchChart {
  const PerfMatchChart({required this.points, required this.average});

  factory PerfMatchChart.of(
    List<MatchStatLine> newestFirst,
    PerfMatchMetric metric, {
    int limit = kPerfChartMatches,
  }) {
    final picked = <PerfChartPoint>[];
    for (final line in newestFirst) {
      if (picked.length >= limit) break;
      final value = matchMetricOf(line, metric);
      if (value != null) picked.add(PerfChartPoint(line, value));
    }
    final points = picked.reversed.toList(growable: false);
    return PerfMatchChart(
      points: points,
      average: aggregateMetricOf(
        PerfAggregate.of([for (final p in points) p.line]),
        metric,
      ),
    );
  }

  final List<PerfChartPoint> points;
  final double? average;

  /// Two bars at least: one match is not a series.
  bool get isEmpty => points.length < 2;
}

/// Share of the opening duels the player won: first bloods / (first bloods +
/// first deaths). `null` until enough round-based matches prove it.
double? openingWinRate(PerfAggregate a) {
  final duels = a.firstBloods + a.firstDeaths;
  if (!a.hasRoundSample || duels == 0) return null;
  return a.firstBloods / duels;
}

/// Everything the "Hiệu suất" screen shows, computed from the on-device
/// ledger by pure functions (PR-15: no math in widgets). All rates are
/// `null` when the sample is too small or the payload never proved them.
@immutable
class PerformanceView {
  const PerformanceView({
    required this.ledgerCount,
    required this.oldest,
    required this.queues,
    required this.filter,
    required this.lines,
    required this.overall,
    required this.byAgent,
    required this.byMap,
    required this.byQueue,
    required this.roundsWithSide,
    required this.roundsTotal,
    required this.attackQualifies,
    required this.defenseQualifies,
  });

  /// Matches stored for the account, before any filter.
  final int ledgerCount;

  /// Start of the oldest stored match ("trên thiết bị, từ dd/MM").
  final DateTime? oldest;

  /// Queue ids present in the ledger (`''` = custom games), most played
  /// first: the queue picker.
  final List<String> queues;
  final PerfFilter filter;

  /// The matches that pass [filter], newest first.
  final List<MatchStatLine> lines;
  final PerfAggregate overall;

  /// Per agent / map of the filtered matches (most played first). Picking a
  /// row narrows [filter] to it, so the other table then answers "which
  /// maps with this agent" / "which agents on this map".
  final List<PerfGroup> byAgent;
  final List<PerfGroup> byMap;

  /// Per queue, over the selected period, agent and map (the queue filter
  /// does not apply: this table compares queues).
  final List<PerfGroup> byQueue;

  /// Rounds whose side (attack / defense) the payloads proved, out of all
  /// the rounds of the round-based matches.
  final int roundsWithSide;
  final int roundsTotal;
  final bool attackQualifies;
  final bool defenseQualifies;

  bool get isEmpty => ledgerCount == 0;

  /// Too few matches stored for any rate to be shown.
  bool get isYoung => ledgerCount < kPerfMinGames;

  /// The filters leave nothing to show.
  bool get filteredOut => !isEmpty && lines.isEmpty;

  /// The per-match chart of the filtered matches for [metric].
  PerfMatchChart chart(PerfMatchMetric metric) =>
      PerfMatchChart.of(lines, metric);
}

/// Builds the [PerformanceView] of [ledger] for a queue ([queueId], `''` =
/// custom games, `null` = all), an agent, a map and a [period] before [now].
PerformanceView buildPerformanceView(
  MatchLedger ledger, {
  required DateTime now,
  String? queueId,
  String? agentId,
  String? mapId,
  PerfPeriod period = PerfPeriod.all,
}) {
  final window = period.window;
  final since = window == null ? null : now.toUtc().subtract(window);
  final filter = PerfFilter(
    queueId: queueId,
    agentId: agentId,
    mapId: mapId,
    since: since,
  );
  final lines = filter.apply(ledger.lines);
  final allQueues = filter.copyWith(queueId: () => null).apply(ledger.lines);
  final overall = PerfAggregate.of(lines);
  bool sideQualifies(SideLine Function(MatchStatLine) side) =>
      lines.where((l) => l.isRoundBased && !side(l).isEmpty).length >=
      kPerfMinGames;
  return PerformanceView(
    ledgerCount: ledger.length,
    oldest: ledger.oldest,
    queues: [for (final g in groupByQueue(ledger.lines)) g.key],
    filter: filter,
    lines: lines,
    overall: overall,
    byAgent: groupByAgent(lines),
    byMap: groupByMap(lines),
    byQueue: groupByQueue(allQueues),
    roundsWithSide: overall.attack.rounds + overall.defense.rounds,
    roundsTotal: overall.rounds,
    attackQualifies: sideQualifies((l) => l.attack),
    defenseQualifies: sideQualifies((l) => l.defense),
  );
}
