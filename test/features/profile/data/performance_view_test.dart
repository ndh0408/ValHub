import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/features/profile/data/performance_view.dart';

void main() {
  final now = DateTime.utc(2026, 9, 30);
  MatchStatLine line(
    String id,
    int days, {
    String queue = 'competitive',
    String agent = 'jett',
    String map = 'ascent',
    int score = 2000,
    int rounds = 10,
    int kills = 10,
    int deaths = 10,
    int? damage,
    int headshots = 0,
    int bodyshots = 0,
    int firstBloods = 0,
    int firstDeaths = 0,
    MatchModeKind mode = MatchModeKind.standard,
    MatchOutcome outcome = MatchOutcome.win,
  }) => MatchStatLine(
    matchId: id,
    startedAt: now.subtract(Duration(days: days)),
    outcome: outcome,
    queueId: queue,
    agentId: agent,
    mapId: map,
    mode: mode,
    score: score,
    rounds: rounds,
    kills: kills,
    deaths: deaths,
    damage: damage,
    headshots: headshots,
    bodyshots: bodyshots,
    firstBloods: firstBloods,
    firstDeaths: firstDeaths,
  );

  test(
    'queue and period filters; the queue table ignores the queue filter',
    () {
      final ledger = MatchLedger(
        puuid: 'me',
        lines: [
          line('a', 1),
          line('b', 2),
          line('c', 3, queue: 'unrated'),
          line('old', 40),
        ],
      );
      final view = buildPerformanceView(
        ledger,
        now: now,
        queueId: 'competitive',
        period: PerfPeriod.days7,
      );
      expect(view.ledgerCount, 4);
      expect(view.lines.map((l) => l.matchId), ['a', 'b']);
      expect(view.overall.qualifies(), isFalse);
      expect(view.byQueue.map((g) => g.games), [2, 1]);
      expect(view.oldest, now.subtract(const Duration(days: 40)));
    },
  );

  test('empty, insufficient sample and weighted metrics', () {
    final empty = buildPerformanceView(MatchLedger(puuid: 'me'), now: now);
    expect(empty.isEmpty, isTrue);
    final view = buildPerformanceView(
      MatchLedger(
        puuid: 'me',
        lines: [
          line('a', 1),
          line('b', 1),
          line('c', 1, score: 6000, rounds: 30),
        ],
      ),
      now: now,
    );
    expect(view.overall.acs, 200);
    expect(view.overall.qualifies(), isTrue);
    expect(view.byAgent.single.games, 3);
    expect(view.byMap.single.games, 3);
  });

  test('unknown-side matches cannot qualify a one-match side sample', () {
    final view = buildPerformanceView(
      MatchLedger(
        puuid: 'me',
        lines: [
          MatchStatLine(
            matchId: 'known',
            startedAt: now,
            outcome: MatchOutcome.win,
            rounds: 10,
            attack: const SideLine(rounds: 10, won: 10),
          ),
          line('unknown-a', 1),
          line('unknown-b', 2),
        ],
      ),
      now: now,
    );
    expect(view.overall.qualifies(), isTrue);
    expect(view.roundsWithSide, 10);
    expect(view.roundsTotal, 30);
    expect(view.attackQualifies, isFalse);
    expect(view.defenseQualifies, isFalse);
  });

  test('an agent narrows every table: its maps, its queues', () {
    final view = buildPerformanceView(
      MatchLedger(
        puuid: 'me',
        lines: [
          line('a', 1, map: 'ascent'),
          line('b', 1, map: 'bind'),
          line('c', 1, map: 'bind', queue: 'unrated'),
          line('d', 1, agent: 'sova', map: 'haven'),
        ],
      ),
      now: now,
      agentId: 'jett',
      queueId: 'competitive',
    );
    expect(view.lines.map((l) => l.matchId), ['a', 'b']);
    expect(view.byMap.map((g) => g.key), ['ascent', 'bind']);
    // The queue table compares queues for the same agent.
    expect(
      {for (final g in view.byQueue) g.key: g.games},
      {'competitive': 2, 'unrated': 1},
    );
    final byMap = buildPerformanceView(
      MatchLedger(
        puuid: 'me',
        lines: [line('x', 1, map: 'Bind')],
      ),
      now: now,
      mapId: 'bind',
    );
    expect(byMap.lines, hasLength(1), reason: 'map ids compare lowercase');
  });

  group('per-match chart', () {
    test('per-round values only; Deathmatch has none', () {
      final comp = line('c', 1, score: 2400, rounds: 12, kills: 18, deaths: 9);
      expect(matchMetricOf(comp, PerfMatchMetric.acs), 200);
      expect(matchMetricOf(comp, PerfMatchMetric.kd), 2);
      expect(matchMetricOf(comp, PerfMatchMetric.adr), isNull);
      expect(matchMetricOf(comp, PerfMatchMetric.headshotRate), isNull);
      final withHits = line('h', 1, damage: 1800, headshots: 1, bodyshots: 3);
      expect(matchMetricOf(withHits, PerfMatchMetric.adr), 180);
      expect(matchMetricOf(withHits, PerfMatchMetric.headshotRate), 0.25);
      final dm = line(
        'dm',
        1,
        mode: MatchModeKind.deathmatch,
        score: 6000,
        rounds: 1,
      );
      expect(matchMetricOf(dm, PerfMatchMetric.acs), isNull);
      expect(matchMetricOf(dm, PerfMatchMetric.kd), isNull);
    });

    test('newest 20 with a value, oldest first, aggregate average', () {
      final lines = [
        for (var i = 0; i < 25; i++)
          line('m$i', i, score: 100 * (i + 1), rounds: 1),
        line('dm', 0, mode: MatchModeKind.deathmatch, rounds: 1),
      ];
      final newestFirst = sortedNewestFirst(lines);
      final chart = PerfMatchChart.of(newestFirst, PerfMatchMetric.acs);
      expect(chart.points, hasLength(kPerfChartMatches));
      expect(chart.points.first.line.matchId, 'm19');
      expect(chart.points.last.line.matchId, 'm0');
      // Σ score / Σ rounds of exactly the plotted matches (100…2000).
      expect(chart.average, 1050);
      expect(chart.isEmpty, isFalse);
      expect(
        PerfMatchChart.of([line('one', 1)], PerfMatchMetric.acs).isEmpty,
        isTrue,
        reason: 'one match is not a series',
      );
    });
  });

  test('opening duels need a round sample and a duel', () {
    PerfAggregate agg(List<MatchStatLine> lines) => PerfAggregate.of(lines);
    expect(
      openingWinRate(agg([line('a', 1, firstBloods: 3, firstDeaths: 1)])),
      isNull,
      reason: 'one match is below the sample',
    );
    final three = agg([
      line('a', 1, firstBloods: 3, firstDeaths: 1),
      line('b', 1, firstBloods: 1, firstDeaths: 1),
      line('c', 1, firstBloods: 2),
    ]);
    expect(openingWinRate(three), 0.75);
    expect(
      openingWinRate(agg([line('a', 1), line('b', 1), line('c', 1)])),
      isNull,
    );
  });
}
