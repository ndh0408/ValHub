import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/features/battlepass/data/battlepass_models.dart';
import 'package:valvn/features/battlepass/data/player_contracts.dart';
import 'package:valvn/features/battlepass/data/xp_pace.dart';

import '../bp_fixtures.dart';

void main() {
  final contract = Contract.fromJson(bpContractJson())!;
  PassProgress at(int level, {int xp = 0, int total = 0}) =>
      PassProgress.compute(
        contract,
        ContractProgress(
          contractId: Bp.bpId,
          levelReached: level,
          xpTowardsNextLevel: xp,
          totalXpEarned: total,
        ),
      );

  final now = DateTime.utc(2026, 9, 28, 12);

  test('spreads the XP left over the days left (partial day counts)', () {
    final p = at(46, xp: 7966, total: 840466);
    final pace = xpPaceOf(p, DateTime.utc(2026, 10, 14), now)!;
    expect(pace.daysLeft, 16); // 15.5 days → 16
    expect(pace.xpPerDay, (p.xpRemaining / 16).ceil());
  });

  test('last hours still need at least one day', () {
    final p = at(46, xp: 7966, total: 840466);
    final pace = xpPaceOf(p, now.add(const Duration(hours: 3)), now)!;
    expect(pace.daysLeft, 1);
    expect(pace.xpPerDay, p.xpRemaining);
  });

  test('null when complete, ended or without an end date', () {
    final done = at(contract.flatLevels.length);
    expect(done.isComplete, isTrue);
    expect(xpPaceOf(done, DateTime.utc(2026, 10, 14), now), isNull);
    final p = at(10, total: 100000);
    expect(xpPaceOf(p, null, now), isNull);
    expect(xpPaceOf(p, now.subtract(const Duration(minutes: 1)), now), isNull);
    expect(xpPaceOf(p, now, now), isNull);
  });
}
