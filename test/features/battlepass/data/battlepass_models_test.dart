import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/features/battlepass/data/battlepass_models.dart';
import 'package:valvn/features/battlepass/data/player_contracts.dart';

import '../bp_fixtures.dart';

void main() {
  final contract = Contract.fromJson(bpContractJson())!;

  group('PassProgress (SUMMARY §9.4)', () {
    test('matches ValBuddy screenshot SS-1', () {
      final p = PassProgress.compute(
        contract,
        const ContractProgress(
          contractId: Bp.bpId,
          levelReached: 46,
          xpTowardsNextLevel: 7966,
          totalXpEarned: 840466,
        ),
      );
      expect(p.levelCount, 55);
      expect(p.totalXp, 1162500);
      expect(p.level, 46);
      expect(p.xpForNextLevel, 35750);
      expect(p.xpInLevel, 7966);
      expect(p.totalXpEarned, 840466);
      expect(p.levelFraction, closeTo(7966 / 35750, 1e-9));
      expect(p.totalFraction, closeTo(840466 / 1162500, 1e-9));
      expect(p.xpRemaining, 1162500 - 840466);
      expect(p.unlockedLevels, 46);
      expect(p.isComplete, isFalse);
      expect(p.estimatedMatches(), ((1162500 - 840466) / 4000).ceil());
      expect(p.estimatedMatches(xpPerMatch: 0), 0);
    });

    test('a missing contract is level 0', () {
      final p = PassProgress.compute(contract, null);
      expect(p.level, 0);
      expect(p.xpForNextLevel, isNull, reason: 'flat[0].xp is 0');
      expect(p.levelFraction, 0);
      expect(p.totalFraction, 0);
      expect(p.totalXpEarned, 0);
      expect(p.xpRemaining, 1162500);
    });

    test('a finished pass', () {
      final p = PassProgress.compute(
        contract,
        const ContractProgress(
          contractId: Bp.bpId,
          levelReached: 60,
          xpTowardsNextLevel: 999,
          totalXpEarned: 1162500,
        ),
      );
      expect(p.level, 55);
      expect(p.isComplete, isTrue);
      expect(p.xpForNextLevel, isNull);
      expect(p.levelFraction, 1);
      expect(p.totalFraction, 1);
      expect(p.xpRemaining, 0);
      expect(p.estimatedMatches(), 0);
    });

    test('rebuilds the total when TotalProgressionEarned is missing', () {
      final p = PassProgress.compute(
        contract,
        const ContractProgress(
          contractId: Bp.bpId,
          levelReached: 3,
          xpTowardsNextLevel: 100,
        ),
      );
      expect(p.totalXpEarned, 0 + 2000 + 2750 + 100);
    });

    test('clamps odd level XP', () {
      final p = PassProgress.compute(
        contract,
        const ContractProgress(
          contractId: Bp.bpId,
          levelReached: 2,
          xpTowardsNextLevel: 99999,
          totalXpEarned: 99999999,
        ),
      );
      expect(p.xpInLevel, 2750);
      expect(p.levelFraction, 1);
      expect(p.totalXpEarned, 1162500);
    });
  });

  group('buildRewardTrack', () {
    test('groups 10 chapters + epilogue with premium and free tracks', () {
      final chapters = buildRewardTrack(contract, level: 12, isPremium: true);
      expect(chapters, hasLength(11));
      expect(chapters.first.number, 1);
      expect(chapters.first.firstLevel, 1);
      expect(chapters.first.lastLevel, 5);
      expect(chapters.last.isEpilogue, isTrue);
      expect(chapters.last.firstLevel, 51);
      expect(chapters.last.lastLevel, 55);
      expect(chapters.last.free, isEmpty);
      expect(chapters.first.premium.first.reward?.uuid, Bp.reaverL1);
      expect(chapters.first.free.map((t) => t.isFree), [true, true]);

      // Level 12 → chapter 3 (levels 11–15) is current.
      expect([for (final c in chapters) c.isCurrent].indexOf(true), 2);
      expect(chapters[2].levelsReached(12), 2);
      expect(chapters[0].levelsReached(12), 5);
      expect(chapters[5].levelsReached(12), 0);

      final ch3 = chapters[2].premium;
      expect(ch3[0].level, 11);
      expect(ch3[0].state, RewardState.unlocked);
      expect(ch3[1].state, RewardState.unlocked);
      expect(ch3[2].state, RewardState.locked);

      // Free rewards unlock with the chapter's last level.
      expect(chapters[1].free.first.level, 10);
      expect(chapters[1].free.first.state, RewardState.unlocked);
      expect(chapters[2].free.first.state, RewardState.locked);
    });

    test('free accounts need Premium for reached premium tiers', () {
      final chapters = buildRewardTrack(contract, level: 7, isPremium: false);
      expect(chapters.first.premium.first.state, RewardState.needsPremium);
      expect(chapters.first.free.first.state, RewardState.unlocked);
      expect(chapters[1].premium.last.state, RewardState.locked);
    });

    test('unknown ownership shows reached tiers as unlocked', () {
      final chapters = buildRewardTrack(contract, level: 1);
      expect(chapters.first.premium.first.isUnlocked, isTrue);
      expect(chapters.first.premium[1].isUnlocked, isFalse);
    });

    test('level 0 → chapter 1 current; complete → none current', () {
      expect(buildRewardTrack(contract, level: 0).first.isCurrent, isTrue);
      expect(
        buildRewardTrack(contract, level: 55).any((c) => c.isCurrent),
        isFalse,
      );
    });
  });

  group('buildWeeklyMissions', () {
    final db = bpContent();
    final now = t0;

    test('joins P-15 with /v1/missions, incomplete first', () {
      final w = buildWeeklyMissions(
        PlayerContracts.fromJson(contractsJson(), receivedAt: now),
        db,
        now: now,
      );
      expect(w.missions.map((m) => m.id), [
        Bp.missionUlt,
        Bp.missionHeadshots,
        Bp.missionDamage,
      ]);
      final ult = w.missions.first;
      expect(ult.title, Bp.ultTitle);
      expect(ult.progress, 8);
      expect(ult.target, 15);
      expect(ult.xpGrant, 38400);
      expect(ult.fraction, closeTo(8 / 15, 1e-9));
      final done = w.missions.last;
      expect(done.isComplete, isTrue);
      expect(done.progress, done.target);
      expect(done.fraction, 1);
      expect(w.completedCount, 1);
      expect(w.isAllComplete, isFalse);
      expect(w.xpAvailable, 38400 + 33900);
      expect(w.refillAt, DateTime.utc(2026, 9, 30));
      expect(w.unknownIds, isEmpty);
    });

    test('drops non-weekly missions, keeps unknown ones', () {
      final w = buildWeeklyMissions(
        PlayerContracts.fromJson(
          contractsJson(
            missions: [
              activeMission(Bp.missionNpe, Bp.objUlt, 0),
              activeMission(Bp.missionUnknown, 'obj', 3),
            ],
          ),
          receivedAt: now,
        ),
        db,
        now: now,
      );
      expect(w.missions.single.id, Bp.missionUnknown);
      expect(w.missions.single.title, isNull);
      expect(w.missions.single.target, 3, reason: 'no definition: >= 1');
      expect(w.unknownIds, {Bp.missionUnknown});
    });

    test('all complete, and refill falls back to ExpirationTime', () {
      final w = buildWeeklyMissions(
        PlayerContracts.fromJson(
          contractsJson(
            weeklyRefill: '2026-09-01T00:00:00Z', // stale
            missions: [
              activeMission(
                Bp.missionUlt,
                Bp.objUlt,
                15,
                complete: true,
                expires: '2026-10-06T00:00:00Z',
              ),
              activeMission(
                Bp.missionDamage,
                Bp.objDamage,
                18000,
                complete: true,
                expires: '2026-10-03T00:00:00Z',
              ),
            ],
          ),
          receivedAt: now,
        ),
        db,
        now: now,
      );
      expect(w.isAllComplete, isTrue);
      expect(w.refillAt, DateTime.utc(2026, 10, 3));
    });

    test('no missions', () {
      final w = buildWeeklyMissions(
        PlayerContracts.fromJson(
          contractsJson(missions: const [], weeklyRefill: null),
          receivedAt: now,
        ),
        db,
        now: now,
      );
      expect(w.isEmpty, isTrue);
      expect(w.isAllComplete, isFalse);
      expect(w.refillAt, isNull);
    });
  });

  group('BattlePassOverview.build', () {
    test('current battle pass, premium, act end and event pass', () {
      final db = bpContent();
      final o = BattlePassOverview.build(
        db: db,
        contracts: PlayerContracts.fromJson(
          contractsJson(
            extraContracts: [
              {
                'ContractDefinitionID': Bp.eventPassId,
                'ProgressionLevelReached': 3,
                'ProgressionTowardsNextLevel': 10,
                'ContractProgression': {'TotalProgressionEarned': 4760},
              },
            ],
          ),
          receivedAt: t0,
        ),
        now: t0,
        premiumContracts: {Bp.bpId},
      );
      expect(o.battlePass?.contract.uuid, Bp.bpId);
      expect(o.battlePass?.level, 46);
      expect(o.isPremium, isTrue);
      expect(o.isPremiumFor(Bp.eventPassId), isFalse);
      expect(o.actEndsAt, DateTime.utc(2026, 10, 14));
      expect(o.eventPasses, hasLength(1));
      final e = o.eventPasses.single;
      expect(e.progress.contract.uuid, Bp.eventPassId);
      expect(e.progress.level, 3);
      expect(e.endsAt, DateTime.utc(2026, 10, 19));
      expect(o.passFor(Bp.eventPassId), same(e.progress));
      expect(o.passFor(Bp.bpId.toUpperCase()), same(o.battlePass));
      expect(o.passFor('nope'), isNull);
      expect(o.weekly.missions, hasLength(3));
    });

    test('premium unknown, no battle pass, no event', () {
      final db = bpContent(withBattlePass: false, withEvent: false);
      final o = BattlePassOverview.build(
        db: db,
        contracts: PlayerContracts.fromJson(null, receivedAt: t0),
        now: t0,
      );
      expect(o.battlePass, isNull);
      expect(o.isPremium, isNull);
      expect(o.actEndsAt, isNull);
      expect(o.eventPasses, isEmpty);
      expect(o.weekly.isEmpty, isTrue);
    });

    test('free account', () {
      final o = BattlePassOverview.build(
        db: bpContent(),
        contracts: PlayerContracts.fromJson(contractsJson(), receivedAt: t0),
        now: t0,
        premiumContracts: const {},
      );
      expect(o.isPremium, isFalse);
    });
  });
}
