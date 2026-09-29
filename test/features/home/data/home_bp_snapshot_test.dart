import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/battlepass/data/battlepass_models.dart';
import 'package:valvn/features/battlepass/data/daily_ticket.dart';
import 'package:valvn/features/battlepass/data/player_contracts.dart';
import 'package:valvn/features/battlepass/data/xp_pace.dart';
import 'package:valvn/features/home/data/home_battlepass.dart';

import '../../battlepass/bp_fixtures.dart';

BattlePassOverview _overview({
  Map<String, Object?>? contracts,
  bool withBattlePass = true,
  bool withEvent = true,
  DateTime? now,
}) => BattlePassOverview.build(
  db: bpContent(withBattlePass: withBattlePass, withEvent: withEvent),
  contracts: PlayerContracts.fromJson(
    contracts ?? contractsJson(),
    receivedAt: t0,
  ),
  now: now ?? t0,
  premiumContracts: {Bp.bpId},
);

DailyTicket _ticket({
  List<int> progress = const [4, 3, 0, 0],
  num remaining = 13177,
}) => DailyTicket.fromJson(
  dailyTicketJson(progress: progress, remaining: remaining),
  receivedAt: t0,
);

HomeBpSnapshot? _snapshot(
  BattlePassOverview overview, {
  DailyTicket? ticket,
  DateTime? now,
}) => buildHomeBpSnapshot(overview, ticket: ticket, now: now ?? t0);

/// A finished event pass (10 levels) for the P-15 payload.
Map<String, Object?> _doneEventPass() => {
  'ContractDefinitionID': Bp.eventPassId.toUpperCase(),
  'ContractProgression': {'TotalProgressionEarned': 999999},
  'ProgressionLevelReached': 10,
  'ProgressionTowardsNextLevel': 0,
};

void main() {
  test('level, pace and days left of the Battle Pass', () {
    final overview = _overview();
    final s = _snapshot(overview)!;
    expect(s.isEvent, isFalse);
    expect(s.pass.level, 46);
    expect(s.pass.levelCount, 55);
    final pace = xpPaceOf(s.pass, overview.actEndsAt, t0)!;
    expect(s.pace!.xpPerDay, pace.xpPerDay);
    expect(s.daysLeft, pace.daysLeft);
    expect(s.daysLeft, 16);
    expect(s.endsAt, DateTime.utc(2026, 10, 14));
    expect(s.contractId, Bp.bpId);
  });

  test('missions: incomplete only, closest to done first, at most two', () {
    final s = _snapshot(_overview())!;
    // Damage is complete; the ultimate mission (8/15) is closer than
    // headshots (12/40).
    expect(s.nearlyDone.map((m) => m.id), [Bp.missionUlt, Bp.missionHeadshots]);
    expect(s.nearlyDone.every((m) => !m.isComplete), isTrue);
    expect(s.allMissionsDone, isFalse);

    // Three open missions: the two closest, ties broken by XP.
    final three = _snapshot(
      _overview(
        contracts: contractsJson(
          missions: [
            activeMission(Bp.missionUlt, Bp.objUlt, 3),
            activeMission(Bp.missionDamage, Bp.objDamage, 3600),
            activeMission(Bp.missionHeadshots, Bp.objHeadshots, 8),
          ],
        ),
      ),
    )!;
    // 3/15 = .2, 3600/18000 = .2, 8/40 = .2: equal fractions, so the biggest
    // XP reward first.
    expect(three.nearlyDone, hasLength(2));
    expect(three.nearlyDone.first.id, Bp.missionUlt);
    expect(three.nearlyDone.last.id, Bp.missionHeadshots);
  });

  test('all missions done: no rows, the refill time instead', () {
    final s = _snapshot(
      _overview(
        contracts: contractsJson(
          missions: [
            activeMission(Bp.missionUlt, Bp.objUlt, 15, complete: true),
            activeMission(
              Bp.missionDamage,
              Bp.objDamage,
              18000,
              complete: true,
            ),
            activeMission(
              Bp.missionHeadshots,
              Bp.objHeadshots,
              40,
              complete: true,
            ),
          ],
        ),
      ),
    )!;
    expect(s.nearlyDone, isEmpty);
    expect(s.allMissionsDone, isTrue);
    expect(s.missionsRefillAt, DateTime.utc(2026, 9, 30));
  });

  test('checkpoints only with a valid, unexpired ticket', () {
    final overview = _overview();
    expect(_snapshot(overview, ticket: _ticket())!.checkpointsDone, 1);
    expect(
      _snapshot(
        overview,
        ticket: _ticket(progress: [4, 4, 4, 4]),
      )!.checkpointsDone,
      4,
    );
    // No ticket yet today.
    expect(_snapshot(overview)!.checkpointsDone, isNull);
    // An expired ticket still shows yesterday: not counted.
    expect(
      _snapshot(overview, ticket: _ticket(remaining: 0))!.checkpointsDone,
      isNull,
    );
    // A payload without milestones.
    final empty = DailyTicket.fromJson({
      'DailyRewards': {'RemainingLifetimeSeconds': 100},
    }, receivedAt: t0);
    expect(_snapshot(overview, ticket: empty)!.checkpointsDone, isNull);
  });

  test('an active event pass is the extra line under the Battle Pass', () {
    final s = _snapshot(_overview())!;
    expect(s.eventLine, isNotNull);
    expect(s.eventLine!.eventName, 'Champions 2026');
    expect(s.eventLine!.progress.contract.uuid, Bp.eventPassId);
    // No event: no line.
    expect(_snapshot(_overview(withEvent: false))!.eventLine, isNull);
  });

  test('a finished Battle Pass falls back to the event pass', () {
    final s = _snapshot(
      _overview(
        contracts: contractsJson(level: 55, inLevel: 0, total: 1162500),
      ),
    )!;
    expect(s.isEvent, isTrue);
    expect(s.eventName, 'Champions 2026');
    expect(s.pass.contract.uuid, Bp.eventPassId);
    expect(s.eventLine, isNull);
    expect(s.contractId, Bp.eventPassId);
    expect(s.endsAt, DateTime.utc(2026, 10, 19));
  });

  test('nothing to show: complete pass and no event, or no pass at all', () {
    final done = contractsJson(level: 55, inLevel: 0, total: 1162500);
    expect(_snapshot(_overview(contracts: done, withEvent: false)), isNull);
    // Both passes complete.
    final both = contractsJson(
      level: 55,
      inLevel: 0,
      total: 1162500,
      extraContracts: [_doneEventPass()],
    );
    expect(_snapshot(_overview(contracts: both)), isNull);
    // No current pass in the content, no event.
    expect(
      _snapshot(_overview(withBattlePass: false, withEvent: false)),
      isNull,
    );
  });

  test('an offline copy is flagged', () {
    final cached = BattlePassOverview.build(
      db: bpContent(),
      contracts: PlayerContracts.fromJson(
        contractsJson(),
        receivedAt: t0.subtract(const Duration(hours: 2)),
        isFromCache: true,
      ),
      now: t0,
    );
    final s = _snapshot(cached)!;
    expect(s.isFromCache, isTrue);
    expect(s.receivedAt, t0.subtract(const Duration(hours: 2)));
  });
}
