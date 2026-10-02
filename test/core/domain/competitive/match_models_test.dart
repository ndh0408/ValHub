import 'package:valvn/core/l10n/labels/competitive_labels.dart';

import '../../../helpers/l10n.dart';

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/competitive_strings.dart';
import 'package:valvn/core/domain/competitive/match_models.dart';
import 'package:valvn/core/domain/competitive/names.dart';

import 'competitive_test_utils.dart';

MatchDetails _load(String name) =>
    MatchDetails.fromJson(competitiveFixture(name));

void main() {
  group('helpers', () {
    test('normalizeRiotId lowercases UUIDs only', () {
      expect(
        normalizeRiotId('9C82E19D-4575-0200-1A81-3EACF00CF872'),
        '9c82e19d-4575-0200-1a81-3eacf00cf872',
      );
      expect(normalizeRiotId(' Red '), 'Red');
      expect(normalizeRiotId('GrenadeAbility'), 'GrenadeAbility');
      expect(normalizeRiotId(''), isNull);
      expect(normalizeRiotId(null), isNull);
      expect(normalizeRiotId(42), '42');
    });

    test('mode classification by queue then game-mode path', () {
      expect(
        MatchModeKind.classify('competitive', null),
        MatchModeKind.standard,
      );
      expect(
        MatchModeKind.classify('console_deathmatch', null),
        MatchModeKind.deathmatch,
      );
      expect(
        MatchModeKind.classify(
          '',
          '/Game/GameModes/HURM/HURMGameMode.HURMGameMode_C',
        ),
        MatchModeKind.teamDeathmatch,
      );
      expect(
        MatchModeKind.classify(
          'ggteam',
          '/Game/GameModes/GunGame/GunGameTeamsGameMode.GunGameTeamsGameMode_C',
        ),
        MatchModeKind.escalation,
      );
      expect(MatchModeKind.classify(null, null), MatchModeKind.standard);
    });

    test('round end types from code, then text', () {
      expect(RoundEndType.parse('Elimination', null), RoundEndType.elimination);
      expect(RoundEndType.parse('Detonate', null), RoundEndType.detonate);
      expect(RoundEndType.parse('Defuse', null), RoundEndType.defuse);
      expect(RoundEndType.parse('Surrendered', null), RoundEndType.surrendered);
      expect(
        RoundEndType.parse('', 'Round timer expired'),
        RoundEndType.timeExpired,
      );
      expect(RoundEndType.parse(null, 'Bomb defused'), RoundEndType.defuse);
      expect(RoundEndType.parse('???', ''), RoundEndType.unknown);
      expect(tl.roundEndType(RoundEndType.elimination), 'Hạ toàn đội');
      expect(tl.roundEndType(RoundEndType.timeExpired), 'Hết giờ');
      expect(tl.roundEndType(RoundEndType.unknown), isNull);
    });

    test('outcome labels and RR sign', () {
      expect(tl.matchOutcome(MatchOutcome.win), 'Thắng');
      expect(tl.matchOutcome(MatchOutcome.loss), 'Thua');
      expect(tl.matchOutcome(MatchOutcome.draw), 'Hòa');
      expect(tl.matchOutcome(MatchOutcome.unknown), CompetitiveStrings.noValue);
      expect(MatchOutcome.fromRr(12), MatchOutcome.win);
      expect(MatchOutcome.fromRr(-3), MatchOutcome.loss);
      expect(MatchOutcome.fromRr(0), MatchOutcome.draw);
      expect(MatchOutcome.fromName('loss'), MatchOutcome.loss);
      expect(MatchOutcome.fromName('bogus'), isNull);
      expect(TeamRole.parse('Attacker'), TeamRole.attacker);
      expect(TeamRole.parse('x'), isNull);
      expect(tl.teamRole(TeamRole.defender), 'Phòng thủ');
    });
  });

  group('competitive match (2026 shape)', () {
    late MatchDetails d;
    setUp(() => d = _load('match_competitive'));

    test('match info is normalised', () {
      expect(d.matchId, compMatch);
      expect(d.info.seasonId, actV);
      expect(d.info.queueId, 'competitive');
      expect(d.info.isCustom, isFalse);
      expect(d.info.isRanked, isTrue);
      expect(d.info.gameLength, const Duration(minutes: 21));
      expect(d.info.startTime, DateTime.utc(2026, 9, 28, 4));
      expect(d.modeKind, MatchModeKind.standard);
    });

    test('players, observer and blank names', () {
      expect(d.players, hasLength(5));
      expect(d.participants.map((p) => p.subject), [me, mate, enemy1, enemy2]);
      expect(d.player(me.toUpperCase())!.characterId, isNotNull);
      expect(
        d.player(enemy2)!.name,
        const RiotName(gameName: 'Kẻ Thù', tagLine: 'VN2'),
      );
      expect(d.player(me)!.name, isNull);
      expect(d.unnamedSubjects, [me, mate, enemy1, observer]);
      expect(d.player(me)!.playerCard, '9fb348bc-41a0-91ad-8a3e-818035c4e561');
      expect(d.player(me)!.playerTitle, isNull);
      expect(d.player(me)!.platformType, 'PC');
      expect(d.player(observer)!.isObserver, isTrue);
      expect(d.sideIds, ['Blue', 'Red']);
    });

    test(
      'kills are rebuilt from round player stats when the list is empty',
      () {
        expect(d.kills, hasLength(7));
        expect(d.kills.map((k) => k.round), [0, 0, 1, 1, 1, 2, 2]);
        final first = d.kills.first;
        expect(first.killer, me);
        expect(first.victim, enemy1);
        expect(first.weaponId, '9c82e19d-4575-0200-1a81-3eacf00cf872');
        expect(first.abilitySlot, isNull);
        expect(d.killsInRound(1).map((k) => k.roundTime), [5000, 8000, 30000]);
        final ult = d.killsInRound(2).first;
        expect(ult.damageItem, 'Ultimate');
        expect(ult.weaponId, isNull);
        expect(ult.abilitySlot, 'Ultimate');
        expect(d.killsInRound(2).last.abilitySlot, 'Grenade');
        expect(d.kills[1].assistants, [mate]);
      },
    );

    test('rounds: end type, side, plant/defuse, economy', () {
      expect(d.rounds.map((r) => r.endType), [
        RoundEndType.elimination,
        RoundEndType.detonate,
        RoundEndType.defuse,
      ]);
      final r0 = d.rounds[0];
      expect(r0.roleOf('Blue'), TeamRole.defender);
      expect(r0.roleOf('Red'), TeamRole.attacker);
      expect(r0.plantSite, isNull);
      expect(r0.plantRoundTime, isNull);
      expect(r0.economyFor(me)!.loadoutValue, 3900);
      expect(r0.economyFor(me)!.armor, '822bcab2-40a2-324e-c137-e09195ad7692');
      expect(r0.economyFor(enemy1)!.armor, isNull);
      final r1 = d.rounds[1];
      expect(r1.bombPlanter, enemy1);
      expect(r1.plantSite, 'A');
      expect(r1.plantRoundTime, 60000);
      // No playerEconomies in this round → playerStats[].economy.
      expect(r1.economyFor(me)!.weapon, '29a0cfab-485b-f5d5-779a-b59f85e204a8');
      final r2 = d.rounds[2];
      expect(r2.ceremony, 'CeremonyCloser');
      expect(r2.bombDefuser, me);
      expect(r2.defuseRoundTime, 90000);
      expect(r2.roleOf('Blue'), isNull);
    });

    test('scoreboard stats (SUMMARY §9.8)', () {
      final s = d.statsFor(me)!;
      expect((s.kills, s.deaths, s.assists), (3, 1, 0));
      expect(s.acs, 200);
      // 150+150 (r0) + 150+60 (r2) to enemies.
      expect(s.damage, 510);
      expect(s.adr, 170);
      expect((s.headshots, s.bodyshots, s.legshots), (2, 5, 1));
      expect(s.headshotRate, 0.25);
      expect(s.firstBloods, 2);
      expect(s.firstDeaths, 1);
      expect(s.plusMinus, 2);
      expect(s.kd, 3);
      expect(s.kast, 1.0); // r1 death traded by the teammate within 5 s
      expect(s.placement, 1);
      expect(s.isMatchMvp, isTrue);
      expect(s.isTeamMvp, isFalse);

      final m = d.statsFor(mate)!;
      // Friendly damage (20 to "me") is excluded.
      expect(m.damage, 180);
      expect(m.adr, 60);
      expect(m.headshotRate, 0.25);
      expect(m.kast, closeTo(2 / 3, 1e-9));
      expect(m.placement, 3);
      expect(m.isTeamMvp, isFalse);

      final e1 = d.statsFor(enemy1)!;
      expect(e1.firstBloods, 1);
      expect(e1.firstDeaths, 2);
      expect(e1.isTeamMvp, isTrue);
      expect(d.statsFor(observer), isNull);
      expect(d.scoreboard.map((x) => x.subject), [me, enemy1, mate, enemy2]);
      expect(d.playersOfTeam('Red').map((p) => p.subject), [enemy1, enemy2]);
    });

    test('result for each side and for a spectator', () {
      final mine = d.resultFor(me);
      expect(mine.outcome, MatchOutcome.win);
      expect((mine.myScore, mine.otherScore), (2, 1));
      expect(mine.placement, isNull);
      final theirs = d.resultFor(enemy2);
      expect(theirs.outcome, MatchOutcome.loss);
      expect((theirs.myScore, theirs.otherScore), (1, 2));
      final spectator = d.resultFor(observer);
      expect(spectator.outcome, MatchOutcome.unknown);
      expect((spectator.myScore, spectator.otherScore), (2, 1));
      expect(d.resultFor(friend).outcome, MatchOutcome.unknown);
      final summary = d.summaryFor(me)!;
      expect(summary.agentId, 'add6443a-41bd-e414-f6ad-e58d267f4e95');
      expect(summary.stats.acs, 200);
      expect(summary.result.outcome, MatchOutcome.win);
      expect(d.summaryFor(friend), isNull);
    });

    test('withNames fills blank names only', () {
      final named = d.withNames({
        me: const RiotName(gameName: 'Tôi', tagLine: 'VN1'),
        enemy2: const RiotName(gameName: 'Khác', tagLine: 'X'),
      });
      expect(named.player(me)!.name!.riotId, 'Tôi#VN1');
      expect(named.player(enemy2)!.name!.riotId, 'Kẻ Thù#VN2');
      expect(named.player(mate)!.name, isNull);
      expect(named.statsFor(me)!.acs, 200);
      expect(identical(d.withNames(const {}), d), isTrue);
    });

    test('compact JSON round-trips and drops positions', () {
      final compact = jsonEncode(d.toJson());
      expect(compact, isNot(contains('playerLocations')));
      expect(compact, isNot(contains('behaviorFactors')));
      final back = MatchDetails.fromJson(jsonDecode(compact));
      expect(jsonEncode(back.toJson()), compact);
      expect(back.statsFor(me)!.headshotRate, 0.25);
      expect(back.statsFor(me)!.firstBloods, 2);
      expect(back.resultFor(me).outcome, MatchOutcome.win);
      expect(back.rounds[0].roleOf('Blue'), TeamRole.defender);
    });
  });

  group('deathmatch', () {
    late MatchDetails d;
    setUp(() => d = _load('match_deathmatch'));

    test('your kills vs the best other player; placement', () {
      expect(d.modeKind, MatchModeKind.deathmatch);
      // Team ids arrive UPPERCASE and are normalised to the PUUID.
      expect(d.player(me)!.teamId, me);
      final r = d.resultFor(me);
      expect(r.outcome, MatchOutcome.loss);
      expect((r.myScore, r.otherScore, r.placement), (25, 40, 2));
      final winner = d.resultFor('dddddddd-0000-4000-8000-000000000002');
      expect(winner.outcome, MatchOutcome.win);
      expect(
        (winner.myScore, winner.otherScore, winner.placement),
        (40, 25, 1),
      );
    });

    test('no hit data → HS% and ADR are unknown; no MVP', () {
      final s = d.statsFor(me)!;
      expect(s.headshotRate, isNull);
      expect(s.hasHitData, isFalse);
      expect(s.adr, isNull);
      expect(s.kast, isNull);
      expect(s.acs, 6000);
      expect(s.firstBloods, 0);
      expect(s.isMatchMvp, isFalse);
      expect(d.kills[1].killer, me);
      expect(d.kills[1].isSecondaryFireMode, isTrue);
      expect(d.kills[1].assistants, isEmpty);
    });

    test('without teams the kill counts decide', () {
      final json = competitiveFixtureMap('match_deathmatch')..['teams'] = null;
      final players = json['players'] as List<dynamic>;
      ((players[0] as Map<String, dynamic>)['stats']
              as Map<String, dynamic>)['kills'] =
          45;
      final r = MatchDetails.fromJson(json).resultFor(me);
      expect(r.outcome, MatchOutcome.win);
      expect((r.myScore, r.otherScore, r.placement), (45, 40, 1));
    });
  });

  test('team deathmatch uses the team points', () {
    final d = _load('match_tdm');
    expect(d.modeKind, MatchModeKind.teamDeathmatch);
    expect(d.kills, isEmpty);
    final r = d.resultFor(me);
    expect(r.outcome, MatchOutcome.loss);
    expect((r.myScore, r.otherScore), (87, 100));
    expect(d.resultFor(enemy1).outcome, MatchOutcome.win);
    expect(d.statsFor(me)!.adr, isNull);
    expect(d.statsFor(me)!.isMatchMvp, isFalse);
    expect(d.statsFor(enemy1)!.isMatchMvp, isTrue);
  });

  test('escalation scores by level reached', () {
    final json = competitiveFixtureMap('match_tdm');
    final info = json['matchInfo'] as Map<String, dynamic>;
    info['queueID'] = 'ggteam';
    info['gameMode'] =
        '/Game/GameModes/GunGame/GunGameTeamsGameMode.GunGameTeamsGameMode_C';
    json['teams'] = [
      {
        'teamId': 'Red',
        'won': true,
        'roundsPlayed': 1,
        'roundsWon': 1,
        'numPoints': 12,
      },
      {
        'teamId': 'Blue',
        'won': false,
        'roundsPlayed': 1,
        'roundsWon': 0,
        'numPoints': 11,
      },
    ];
    final r = MatchDetails.fromJson(json).resultFor(me);
    expect(r.outcome, MatchOutcome.loss);
    expect((r.myScore, r.otherScore), (11, 12));
  });

  group('custom game (queueID "", teams null)', () {
    late MatchDetails d;
    setUp(() => d = _load('match_custom'));

    test('info and ids', () {
      expect(d.matchId, customMatch);
      expect(d.info.isCustom, isTrue);
      expect(d.info.queueId, '');
      expect(d.info.seasonId, isNull);
      expect(d.info.isCompleted, isFalse); // field absent
      expect(d.player(me)!.characterId, 'add6443a-41bd-e414-f6ad-e58d267f4e95');
      expect(d.player(me)!.name!.riotId, 'Tôi#VN1');
      expect(d.rounds.map((r) => r.roundNum), [0, 1, 2]);
      expect(d.rounds[2].endType, RoundEndType.timeExpired);
      expect(d.rounds[0].economyFor(me)!.weapon, isNull);
      expect(d.kills.first.weaponId, '5f0aaf7a-4289-3998-d5ff-eb9a5cf7ef5c');
    });

    test('score counted from the rounds; completionState decides', () {
      final r = d.resultFor(me);
      expect(r.outcome, MatchOutcome.win);
      expect((r.myScore, r.otherScore), (2, 1));
      expect(d.resultFor(enemy1).outcome, MatchOutcome.loss);
      final s = d.statsFor(me)!;
      expect(s.firstBloods, 1); // r0 only: in r1 the enemy killed first
      expect(s.headshotRate, isNull);
    });
  });

  test('surrendered match: awarded rounds are not scored or played', () {
    final json = competitiveFixtureMap('match_competitive');
    (json['matchInfo'] as Map<String, dynamic>)['completionState'] =
        'Surrendered';
    json['teams'] = [
      {
        'teamId': 'Blue',
        'won': true,
        'roundsPlayed': 4,
        'roundsWon': 13,
        'numPoints': 2,
      },
      {
        'teamId': 'Red',
        'won': false,
        'roundsPlayed': 4,
        'roundsWon': 1,
        'numPoints': 1,
      },
    ];
    (json['roundResults'] as List<dynamic>).add({
      'roundNum': 3,
      'roundResult': 'Surrendered',
      'roundResultCode': 'Surrendered',
      'winningTeam': 'Blue',
      'playerStats': [
        {'subject': me, 'damage': <Object>[], 'score': 0},
      ],
    });
    final d = MatchDetails.fromJson(json);
    expect(d.rounds, hasLength(4));
    expect(d.playedRounds, hasLength(3));
    final r = d.resultFor(me);
    expect(r.outcome, MatchOutcome.win);
    expect((r.myScore, r.otherScore), (2, 1));
    expect(d.statsFor(me)!.kast, 1.0);
  });

  test('vote draw and incomplete matches', () {
    final draw = competitiveFixtureMap('match_competitive');
    (draw['matchInfo'] as Map<String, dynamic>)['completionState'] = 'VoteDraw';
    draw['teams'] = [
      {'teamId': 'Blue', 'won': false, 'roundsWon': 12},
      {'teamId': 'Red', 'won': false, 'roundsWon': 12},
    ];
    expect(
      MatchDetails.fromJson(draw).resultFor(me).outcome,
      MatchOutcome.draw,
    );

    final unfinished = {
      'matchInfo': {
        'matchId': 'X',
        'queueID': '',
        'provisioningFlowID': 'CustomGame',
        'isCompleted': false,
        'completionState': '',
      },
      'players': [
        {'subject': me, 'teamId': 'Blue', 'stats': null},
        {'subject': mate, 'teamId': 'Red', 'stats': null},
      ],
      'teams': null,
      'roundResults': null,
      'kills': null,
    };
    final d = MatchDetails.fromJson(unfinished);
    expect(d.resultFor(me).outcome, MatchOutcome.unknown);
    final s = d.statsFor(me)!;
    expect(s.acs, isNull);
    expect(s.isMatchMvp, isFalse);
  });

  test('garbage never throws', () {
    for (final junk in <Object?>[
      null,
      42,
      'not json',
      <String, dynamic>{},
      {
        'matchInfo': 'x',
        'players': 'y',
        'teams': 3,
        'roundResults': <String, Object>{},
        'kills': 'z',
      },
      {
        'players': [
          null,
          {'subject': null},
          {'subject': 7, 'stats': 'bad', 'teamId': 5},
        ],
        'roundResults': [
          {'roundNum': 'x'},
          {
            'roundNum': 0,
            'playerStats': [
              null,
              {'subject': me, 'damage': 'x'},
            ],
          },
        ],
        'kills': [
          {'killer': me},
          {
            'killer': me,
            'victim': mate,
            'finishingDamage': 'x',
            'assistants': [null, 3],
          },
        ],
      },
    ]) {
      final d = MatchDetails.fromJson(junk, matchId: 'ABC');
      expect(d.resultFor(me), isA<MatchResult>());
      expect(d.scoreboard, isA<List<ScoreboardStats>>());
      expect(d.toJson(), isA<Map<String, dynamic>>());
    }
    expect(MatchDetails.fromJson(null, matchId: 'ABC').matchId, 'abc');
  });
}
