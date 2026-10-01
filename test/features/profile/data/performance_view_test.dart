import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/features/profile/data/performance_view.dart';

void main() {
  final now = DateTime.utc(2026, 9, 30);
  MatchStatLine line(
    String id,
    int days, {
    String queue = 'competitive',
    int score = 2000,
    int rounds = 10,
  }) => MatchStatLine(
    matchId: id,
    startedAt: now.subtract(Duration(days: days)),
    outcome: MatchOutcome.win,
    queueId: queue,
    agentId: 'jett',
    mapId: 'ascent',
    score: score,
    rounds: rounds,
  );
  test('queue and period filters remain pure; queue comparison ignores selected queue', () {
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
      toLocal: (d) => d,
      queueId: 'competitive',
      period: PerfPeriod.days7,
    );
    expect(view.ledgerCount, 4);
    expect(view.lines.map((l) => l.matchId), ['a', 'b']);
    expect(view.overall.qualifies(), isFalse);
    expect(view.byQueue.map((g) => g.games), [2, 1]);
    expect(view.oldest, now.subtract(const Duration(days: 40)));
    expect(view.hasTrend, isFalse);
  });
  test('empty, insufficient sample and weighted metrics', () {
    final empty = buildPerformanceView(
      MatchLedger(puuid: 'me'),
      now: now,
      toLocal: (d) => d,
    );
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
      toLocal: (d) => d,
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
      toLocal: (d) => d,
    );
    expect(view.overall.qualifies(), isTrue);
    expect(view.roundsWithSide, 10);
    expect(view.roundsTotal, 30);
    expect(view.attackQualifies, isFalse);
    expect(view.defenseQualifies, isFalse);
  });
}
