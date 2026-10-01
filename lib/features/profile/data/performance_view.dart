import 'package:flutter/foundation.dart';

import '../../../core/domain/competitive/competitive.dart';

/// The tabs of the "Hiệu suất" screen.
enum PerfSegment { agents, maps, queues, sides, trend }

/// How far back the screen looks.
enum PerfPeriod {
  all(null),
  days30(Duration(days: 30)),
  days7(Duration(days: 7));

  const PerfPeriod(this.window);

  /// `null` = the whole ledger.
  final Duration? window;
}

/// The most trend points the chart plots.
const kPerfMaxTrendPoints = 12;

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
    required this.bucket,
    required this.trend,
    required this.chart,
    required this.attackQualifies,
    required this.defenseQualifies,
  });

  /// Matches stored for the account, before any filter.
  final int ledgerCount;

  /// Start of the oldest stored match ("trên thiết bị, từ dd/MM").
  final DateTime? oldest;

  /// Queue ids present in the ledger (`''` = custom games), most played
  /// first: the queue chips.
  final List<String> queues;
  final PerfFilter filter;

  /// The matches that pass [filter], newest first.
  final List<MatchStatLine> lines;
  final PerfAggregate overall;
  final List<PerfGroup> byAgent;
  final List<PerfGroup> byMap;

  /// Per queue, over the selected period (the queue chip does not apply:
  /// this table compares queues).
  final List<PerfGroup> byQueue;

  /// Rounds whose side (attack / defense) the payloads proved, out of all
  /// the rounds of the round-based matches.
  final int roundsWithSide;
  final int roundsTotal;

  /// Width of the trend buckets and every bucket with a match.
  final TrendBucket bucket;
  final List<PerfTrendPoint> trend;

  /// The trend buckets with enough matches, the newest
  /// [kPerfMaxTrendPoints], oldest first.
  final List<PerfTrendPoint> chart;
  final bool attackQualifies;
  final bool defenseQualifies;

  bool get isEmpty => ledgerCount == 0;

  /// Too few matches stored for any rate to be shown.
  bool get isYoung => ledgerCount < kPerfMinGames;

  /// The filters leave nothing to show.
  bool get filteredOut => !isEmpty && lines.isEmpty;

  /// A trend needs at least two buckets with enough matches.
  bool get hasTrend => chart.length >= 2;
}

/// Builds the [PerformanceView] of [ledger] for a queue ([queueId], `''` =
/// custom games, `null` = all) and a [period] before [now]. [toLocal] is the
/// display zone used to cut days, weeks and months.
PerformanceView buildPerformanceView(
  MatchLedger ledger, {
  required DateTime now,
  required DateTime Function(DateTime utc) toLocal,
  String? queueId,
  PerfPeriod period = PerfPeriod.all,
}) {
  final window = period.window;
  final since = window == null ? null : now.toUtc().subtract(window);
  final inPeriod = PerfFilter(since: since).apply(ledger.lines);
  final filter = PerfFilter(queueId: queueId, since: since);
  final lines = filter.apply(ledger.lines);
  final overall = PerfAggregate.of(lines);
  final bucket = suggestTrendBucket(lines, toLocal: toLocal);
  final points = trendOf(lines, bucket: bucket, toLocal: toLocal);
  final qualified = qualifiedPoints(points);
  return PerformanceView(
    ledgerCount: ledger.length,
    oldest: ledger.oldest,
    queues: [for (final g in groupByQueue(ledger.lines)) g.key],
    filter: filter,
    lines: lines,
    overall: overall,
    byAgent: groupByAgent(lines),
    byMap: groupByMap(lines),
    byQueue: groupByQueue(inPeriod),
    roundsWithSide: overall.attack.rounds + overall.defense.rounds,
    roundsTotal: overall.rounds,
    bucket: bucket,
    trend: points,
    chart: qualified.length <= kPerfMaxTrendPoints
        ? qualified
        : qualified.sublist(qualified.length - kPerfMaxTrendPoints),
    attackQualifies:
        lines.where((l) => l.isRoundBased && !l.attack.isEmpty).length >=
        kPerfMinGames,
    defenseQualifies:
        lines.where((l) => l.isRoundBased && !l.defense.isEmpty).length >=
        kPerfMinGames,
  );
}
