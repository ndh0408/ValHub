import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/features/profile/data/recent_form.dart';

MatchPlayerSummary _m(
  MatchOutcome outcome, {
  int k = 10,
  int d = 10,
  double? acs = 200,
  int head = 0,
  int body = 0,
}) => MatchPlayerSummary(
  info: const MatchInfo(matchId: 'x'),
  player: const MatchPlayer(subject: 'me'),
  result: MatchResult(outcome: outcome),
  stats: ScoreboardStats(
    subject: 'me',
    kills: k,
    deaths: d,
    acs: acs,
    headshots: head,
    bodyshots: body,
  ),
);

void main() {
  test('empty input has no rates and no streak', () {
    final f = RecentForm.from(const []);
    expect(f.isEmpty, isTrue);
    expect(f.winRate, isNull);
    expect(f.kd, isNull);
    expect(f.streakKind, isNull);
  });

  test('record, win rate and the streak up to the newest match', () {
    final f = RecentForm.from([
      _m(MatchOutcome.win),
      _m(MatchOutcome.win),
      _m(MatchOutcome.win),
      _m(MatchOutcome.loss),
      _m(MatchOutcome.draw),
      _m(MatchOutcome.unknown),
    ]);
    expect(f.games, 5); // unknown is left out
    expect((f.wins, f.losses, f.draws), (3, 1, 1));
    expect(f.winRate, 0.75); // draws excluded
    expect(f.streakKind, StreakKind.win);
    expect(f.streak, 3);
    expect(f.outcomes.first, MatchOutcome.win);
  });

  test('a loss streak; a draw as newest match breaks the streak', () {
    final losing = RecentForm.from([
      _m(MatchOutcome.loss),
      _m(MatchOutcome.loss),
      _m(MatchOutcome.win),
    ]);
    expect(losing.streakKind, StreakKind.loss);
    expect(losing.streak, 2);

    final drawn = RecentForm.from([
      _m(MatchOutcome.draw),
      _m(MatchOutcome.win),
    ]);
    expect(drawn.streakKind, isNull);
    expect(drawn.streak, 0);
  });

  test('averages: K/D over totals, mean ACS, HS% over all hits', () {
    final f = RecentForm.from([
      _m(MatchOutcome.win, k: 20, d: 10, acs: 300, head: 10, body: 30),
      _m(MatchOutcome.loss, k: 10, d: 20, acs: null, head: 0, body: 10),
    ]);
    expect(f.kd, 1.0);
    expect(f.acs, 300);
    expect(f.headshotRate, closeTo(10 / 50, 1e-9));
  });

  test('zero deaths counts as one for K/D', () {
    final f = RecentForm.from([_m(MatchOutcome.win, k: 7, d: 0)]);
    expect(f.kd, 7);
    expect(f.headshotRate, isNull);
  });
}
