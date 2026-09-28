import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/account_xp.dart';

import 'competitive_test_utils.dart';

void main() {
  test('parses P-9 progress and history (XP / 5000)', () {
    final xp = AccountXp.fromJson(competitiveFixture('account_xp'));
    expect(xp.level, 222);
    expect(xp.xp, 184);
    expect(xp.xpPerLevel, 5000);
    expect(xp.progress, closeTo(184 / 5000, 1e-12));
    expect(xp.xpToNextLevel, 4816);
    expect(xp.history, hasLength(1));
    final h = xp.history.single;
    expect(h.matchId, '912b5e54-c923-4c10-a216-2a77720cd98a');
    expect(h.start, (level: 221, xp: 4900));
    expect(h.end, (level: 222, xp: 184));
    expect(h.xpDelta, 284);
    expect(h.sources, {'time-played': 184, 'match-win': 100});
    expect(h.matchStart, DateTime.utc(2026, 9, 28, 3, 38, 3));
    expect(xp.isFirstWinAvailable(DateTime.utc(2026, 9, 28, 12)), isFalse);
    expect(xp.isFirstWinAvailable(DateTime.utc(2026, 9, 29, 4)), isTrue);
  });

  test('defensive parsing and clamping', () {
    final empty = AccountXp.fromJson('<html>');
    expect((empty.level, empty.xp), (0, 0));
    expect(empty.isFirstWinAvailable(DateTime(2026)), isTrue);
    final odd = AccountXp.fromJson({
      'Progress': {'Level': '12', 'XP': 9000},
      'History': 'x',
    });
    expect(odd.level, 12);
    expect(odd.progress, 1.0);
    expect(odd.xpToNextLevel, 0);
    expect(odd.history, isEmpty);
  });
}
