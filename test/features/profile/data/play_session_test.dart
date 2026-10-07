import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/features/profile/data/play_session.dart';

final _t0 = DateTime.utc(2026, 10, 7, 13);

MatchHistoryEntry _e(
  String id,
  int minutesAfter, {
  String queue = 'competitive',
}) => MatchHistoryEntry(
  matchId: id,
  startTime: _t0.add(Duration(minutes: minutesAfter)),
  queueId: queue,
);

MatchPlayerSummary _s(
  MatchHistoryEntry e,
  MatchOutcome outcome, {
  String agent = 'jett',
  int k = 20,
  int d = 10,
  int score = 5000,
  int rounds = 20,
  int lengthMinutes = 40,
}) => MatchPlayerSummary(
  info: MatchInfo(
    matchId: e.matchId,
    queueId: e.queueId,
    startTime: e.startTime,
    gameLength: Duration(minutes: lengthMinutes),
  ),
  player: MatchPlayer(subject: 'me', characterId: agent),
  result: MatchResult(outcome: outcome),
  stats: ScoreboardStats(
    subject: 'me',
    kills: k,
    deaths: d,
    score: score,
    roundsPlayed: rounds,
    acs: score / rounds,
  ),
);

void main() {
  test('a session is the newest run of matches started ≤ 2 h apart', () {
    // Newest first, as Riot lists them.
    final history = [_e('c', 100), _e('b', 50), _e('a', 0), _e('old', -200)];
    expect(latestSessionEntries(history).map((e) => e.matchId), [
      'c',
      'b',
      'a',
    ]);
    expect(
      latestSessionEntries([const MatchHistoryEntry(matchId: 'x'), _e('a', 0)]),
      isEmpty,
      reason: 'no start time, no session',
    );
  });

  test('record, time played, top agent and net RR of the session', () {
    final entries = [_e('c', 100), _e('b', 50, queue: 'unrated'), _e('a', 0)];
    final session = buildPlaySession(
      entries,
      [
        _s(entries[0], MatchOutcome.win, lengthMinutes: 35),
        _s(entries[1], MatchOutcome.loss, agent: 'sova'),
        _s(entries[2], MatchOutcome.win),
      ],
      rrByMatch: {'c': 21, 'a': 18},
    )!;
    expect(session.form.wins, 2);
    expect(session.form.losses, 1);
    expect(session.played, const Duration(minutes: 115));
    expect(session.start, _t0);
    expect(session.end, _t0.add(const Duration(minutes: 135)));
    expect(session.rrNet, 39);
    expect(session.topAgentId, 'jett');
    expect(session.topAgentGames, 2);
    // Oldest first, as played.
    expect(session.matches.map((m) => m.matchId), ['a', 'b', 'c']);
    expect(session.matches.first.acs, 250);
    expect(session.isFresh(session.end.add(const Duration(hours: 11))), isTrue);
    expect(
      session.isFresh(session.end.add(const Duration(hours: 13))),
      isFalse,
    );
  });

  test('a ranked match without its RR change gives no net RR', () {
    final entries = [_e('b', 50), _e('a', 0)];
    final session = buildPlaySession(
      entries,
      [_s(entries[0], MatchOutcome.win), _s(entries[1], MatchOutcome.loss)],
      rrByMatch: {'b': 20},
    )!;
    expect(session.rrNet, isNull, reason: 'never a partial sum');
  });

  test('fewer than two decided matches is no session', () {
    final entries = [_e('b', 50), _e('a', 0)];
    expect(
      buildPlaySession(entries, [
        _s(entries[0], MatchOutcome.win),
        null,
      ], rrByMatch: const {}),
      isNull,
    );
    expect(
      buildPlaySession(entries, [
        _s(entries[0], MatchOutcome.win),
        _s(entries[1], MatchOutcome.unknown),
      ], rrByMatch: const {}),
      isNull,
    );
  });

  test('only unrated matches: no RR pill, one agent each: no top agent', () {
    final entries = [
      _e('b', 50, queue: 'unrated'),
      _e('a', 0, queue: 'unrated'),
    ];
    final session = buildPlaySession(entries, [
      _s(entries[0], MatchOutcome.win, agent: 'sova'),
      _s(entries[1], MatchOutcome.loss),
    ], rrByMatch: const {})!;
    expect(session.rrNet, isNull);
    expect(session.topAgentId, isNull);
  });
}
