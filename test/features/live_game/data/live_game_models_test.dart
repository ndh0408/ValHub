import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/live_game/data/live_game_models.dart';

import '../live_game_test_env.dart';

void main() {
  final at = DateTime.utc(2026, 9, 28, 12);

  group('LiveMatch.fromPregame', () {
    test('parses the ally team, selections, identities and timer', () {
      final m = LiveMatch.fromPregame(
        pregameMatchJson(myAgent: jett.toUpperCase(), myState: 'selected'),
        receivedAt: at,
      )!;
      expect(m.matchId, pregameMatchId);
      expect(m.isPregame, isTrue);
      expect(m.mapId, ascent);
      expect(m.queueId, 'competitive');
      expect(m.isRanked, isTrue);
      expect(m.allyTeamId, 'Blue');
      expect(m.enemyTeamSize, 5);
      expect(m.enemyTeamLockCount, 4);
      // Teams[] repeats "me" without an identity: kept once, richer copy.
      expect(m.players.map((p) => p.subject), [me, mate, mateHidden]);
      final self = m.player(me.toUpperCase())!;
      expect(self.characterId, jett);
      expect(self.selection, AgentSelection.selected);
      expect(self.accountLevel, 200);
      expect(m.player(mate)!.isLocked, isTrue);
      final hidden = m.player(mateHidden)!;
      expect(hidden.incognito, isTrue);
      expect(hidden.hideAccountLevel, isTrue);
      expect(hidden.playerCardId, cardId);
      expect(m.phaseTimeRemaining, const Duration(seconds: 42));
      expect(m.phaseEndsAt, at.add(const Duration(seconds: 42)));
      expect(m.isFinished, isFalse);
    });

    test('empty CharacterID means no agent yet', () {
      final m = LiveMatch.fromPregame(pregameMatchJson(), receivedAt: at)!;
      expect(m.player(me)!.characterId, isNull);
      expect(m.player(me)!.selection, AgentSelection.none);
    });

    test('never throws on odd bodies', () {
      expect(LiveMatch.fromPregame(null, receivedAt: at), isNull);
      expect(LiveMatch.fromPregame('<html>403</html>', receivedAt: at), isNull);
      final m = LiveMatch.fromPregame(
        {
          'AllyTeam': {'TeamID': 'Red', 'Players': null},
          'EnemyTeam': 'x',
          'Teams': [null, 3],
          'PhaseTimeRemainingNS': '12000000000',
        },
        fallbackMatchId: 'ABC-1',
        receivedAt: at,
      )!;
      expect(m.matchId, 'abc-1');
      expect(m.players, isEmpty);
      expect(m.phaseTimeRemaining, const Duration(seconds: 12));
      final weird = LiveMatch.fromPregame({
        'ID': 'x',
        'AllyTeam': {
          'Players': [
            {'Subject': null},
            {
              'Subject': 'P1',
              'PlayerIdentity': {'AccountLevel': '17', 'Incognito': 'true'},
              'CompetitiveTier': 12.0,
            },
          ],
        },
        'PhaseTimeRemainingNS': -1,
      }, receivedAt: at)!;
      expect(weird.players.single.subject, 'p1');
      expect(weird.players.single.accountLevel, 17);
      expect(weird.players.single.competitiveTier, 12);
      expect(weird.phaseTimeRemaining, isNull);
    });
  });

  group('LiveMatch.fromCoreGame', () {
    test('parses both teams and finds the ally team from self', () {
      final m = LiveMatch.fromCoreGame(
        coreMatchJson(),
        selfPuuid: me,
        receivedAt: at,
      )!;
      expect(m.matchId, liveMatchId);
      expect(m.isPregame, isFalse);
      expect(m.allyTeamId, 'Blue');
      expect(m.queueId, 'competitive');
      expect(m.state, 'IN_PROGRESS');
      expect(m.players, hasLength(4));
      expect(m.player(enemy2)!.incognito, isTrue);
      expect(m.isFinished, isFalse);
      expect(m.isCustomGame, isFalse);
    });

    test('POST_GAME / CLOSED are finished; coaches are skipped', () {
      final json = coreMatchJson(state: 'post_game');
      (json['Players']! as List<Object?>).add({
        'Subject': 'coach',
        'TeamID': 'Blue',
        'IsCoach': true,
      });
      final m = LiveMatch.fromCoreGame(json, selfPuuid: me, receivedAt: at)!;
      expect(m.isFinished, isTrue);
      expect(m.player('coach'), isNull);
    });

    test('custom games have no queue', () {
      final json = coreMatchJson()
        ..['MatchmakingData'] = null
        ..['ProvisioningFlow'] = 'CustomGame';
      final m = LiveMatch.fromCoreGame(json, selfPuuid: me, receivedAt: at)!;
      expect(m.queueId, isNull);
      expect(m.isCustomGame, isTrue);
    });
  });

  group('LiveParty', () {
    test('parses members, state and queue entry time', () {
      final p = LiveParty.fromJson(partyJson())!;
      expect(p.partyId, partyId);
      expect(p.members, {me, mate});
      expect(p.isMatchmaking, isTrue);
      expect(p.queueId, 'competitive');
      expect(p.queueEntryTime, DateTime.utc(2026, 9, 28, 11, 58, 28));
    });

    test('odd bodies', () {
      expect(LiveParty.fromJson(null), isNull);
      expect(LiveParty.fromJson({'Members': null}), isNull);
      final p = LiveParty.fromJson({
        'ID': 'P',
        'Members': null,
        'QueueEntryTime': '0001-01-01T00:00:00Z',
      })!;
      expect(p.members, isEmpty);
      expect(p.queueEntryTime, isNull);
      expect(p.isMatchmaking, isFalse);
    });
  });

  test('LiveGameState.queueEntryTime only while queueing', () {
    final party = LiveParty.fromJson(partyJson())!;
    expect(
      LiveGameState(
        phase: LivePhase.queueing,
        receivedAt: at,
        party: party,
      ).queueEntryTime,
      party.queueEntryTime,
    );
    expect(
      LiveGameState(
        phase: LivePhase.lobby,
        receivedAt: at,
        party: party,
      ).queueEntryTime,
      isNull,
    );
  });
}
