import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/battlepass/data/player_contracts.dart';

import '../bp_fixtures.dart';

void main() {
  group('PlayerContracts.fromJson', () {
    test('parses the EP §12.1 shape', () {
      final c = PlayerContracts.fromJson(contractsJson(), receivedAt: t0);
      expect(c.receivedAt, t0);
      expect(c.isFromCache, isFalse);
      expect(c.contracts, hasLength(1));
      final bp = c.progressFor(Bp.bpId)!;
      expect(bp.contractId, Bp.bpId, reason: 'uuid is lowercased');
      expect(bp.levelReached, 46);
      expect(bp.xpTowardsNextLevel, 7966);
      expect(bp.totalXpEarned, 840466);
      expect(c.progressFor(Bp.bpId.toUpperCase()), same(bp));
      expect(c.activeSpecialContract, Bp.agentContractId);

      expect(c.missions, hasLength(3));
      final ult = c.missions.first;
      expect(ult.id, Bp.missionUlt);
      expect(ult.objectives, {Bp.objUlt: 8});
      expect(ult.progress, 8);
      expect(ult.isComplete, isFalse);
      expect(ult.expiresAt, DateTime.utc(2026, 10, 14));
      expect(c.missions[1].isComplete, isTrue);

      expect(c.metadata.npeCompleted, isTrue);
      expect(c.metadata.weeklyRefillTime, DateTime.utc(2026, 9, 30));
      expect(c.metadata.weeklyCheckpoint, DateTime.utc(2026, 9, 22));
    });

    test('a missing contract means level 0', () {
      final c = PlayerContracts.fromJson(
        contractsJson(includeBattlePass: false),
        receivedAt: t0,
      );
      expect(c.progressFor(Bp.bpId), isNull);
    });

    test('never throws on odd payloads', () {
      for (final json in <Object?>[
        null,
        '<html>Cloudflare</html>',
        42,
        const <Object?>[],
        const {'Contracts': null, 'Missions': null, 'MissionMetadata': null},
        const {'Contracts': 'x', 'Missions': 7, 'MissionMetadata': 'y'},
        const {
          'Contracts': [null, 1, <String, Object?>{}],
          'Missions': [null, 'a', <String, Object?>{}],
        },
      ]) {
        final c = PlayerContracts.fromJson(json, receivedAt: t0);
        expect(c.contracts, isEmpty);
        expect(c.missions, isEmpty);
        expect(c.metadata.weeklyRefillTime, isNull);
      }
    });

    test('reads numbers as num, clamps negatives and ignores bad keys', () {
      final c = PlayerContracts.fromJson({
        'Contracts': [
          {
            'ContractDefinitionID': 'ABC',
            'ProgressionLevelReached': 12.0,
            'ProgressionTowardsNextLevel': '350',
            'ContractProgression': {'TotalProgressionEarned': -5},
          },
        ],
        'Missions': [
          {
            'ID': 'M1',
            'Objectives': {'OBJ': '4', 'bad': null, ' ': 3},
            'Complete': 'true',
            'ExpirationTime': '0001-01-01T00:00:00Z',
          },
        ],
        'MissionMetadata': {'WeeklyRefillTime': 'not a date'},
      }, receivedAt: t0);
      final p = c.progressFor('abc')!;
      expect(p.levelReached, 12);
      expect(p.xpTowardsNextLevel, 350);
      expect(p.totalXpEarned, 0);
      final m = c.missions.single;
      expect(m.id, 'm1');
      expect(m.objectives, {'obj': 4, 'bad': 0});
      expect(m.isComplete, isTrue);
      expect(m.expiresAt, isNull);
      expect(c.metadata.weeklyRefillTime, isNull);
    });

    test('copyWith marks an offline copy', () {
      final c = PlayerContracts.fromJson(contractsJson(), receivedAt: t0);
      final cached = c.copyWith(isFromCache: true);
      expect(cached.isFromCache, isTrue);
      expect(cached.contracts, same(c.contracts));
    });
  });
}
