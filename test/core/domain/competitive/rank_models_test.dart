import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/rank_models.dart';

import 'competitive_test_utils.dart';

void main() {
  group('PlayerMmr (P-11)', () {
    late PlayerMmr mmr;
    setUp(() => mmr = PlayerMmr.fromJson(competitiveFixture('mmr')));

    test('queue skills incl. console keys and null seasonal info', () {
      expect(mmr.subject, me);
      expect(mmr.version, 1790000000000);
      expect(
        mmr.queueSkills.keys,
        containsAll(['competitive', 'console_competitive', 'unrated']),
      );
      expect(mmr.skill('unrated')!.seasons, isEmpty);
      expect(mmr.competitive()!.seasons, hasLength(3));
      expect(mmr.competitive(console: true)!.season(actV)!.competitiveTier, 9);
      // Console falls back to the PC entry when there is no console key.
      expect(mmr.skill('deathmatch', console: true)!.queueId, 'deathmatch');
      expect(mmr.skill('console_unrated')!.queueId, 'unrated');
      expect(mmr.skill('swiftplay'), isNull);
    });

    test('seasonal info fields, WinsByTier and string numbers', () {
      final v = mmr.competitive()!.season(actV.toUpperCase())!;
      expect(v.seasonId, actV);
      expect(v.competitiveTier, 18);
      expect(v.rankedRating, 6);
      expect(v.numberOfWins, 20);
      expect(v.numberOfGames, 38);
      expect(v.winRate, closeTo(20 / 38, 1e-9));
      expect(v.winsByTier, {0: 1, 17: 12, 18: 7});
      expect(v.leaderboardRank, 0);
      // Entry without its own SeasonID uses the map key; "23" parses.
      final u = mmr.competitive()!.season(unknownAct)!;
      expect(u.seasonId, unknownAct);
      expect(u.competitiveTier, 23);
      expect(u.winsByTier, isEmpty);
      expect(u.gamesNeededForRating, 0);
    });

    test('latest competitive update', () {
      final l = mmr.latestCompetitiveUpdate!;
      expect(l.matchId, updateId(5));
      expect(l.seasonId, actV);
      expect(l.isPromotion, isTrue);
      expect(l.isDemotion, isFalse);
      expect(l.rrEarned, 32);
      expect(l.matchStartTime, DateTime.utc(2026, 9, 28, 4));
    });

    test('defensive parsing', () {
      for (final junk in <Object?>[
        null,
        'x',
        42,
        <String, dynamic>{},
        {'QueueSkills': 'x', 'LatestCompetitiveUpdate': 7},
        {
          'QueueSkills': {
            'competitive': {
              'SeasonalInfoBySeasonID': {
                'a': null,
                'b': 'x',
                'c': {'WinsByTier': 'x', 'CompetitiveTier': 'high'},
              },
            },
            '': <String, Object>{},
          },
          'LatestCompetitiveUpdate': {'MatchID': ''},
        },
      ]) {
        final m = PlayerMmr.fromJson(junk);
        expect(m.latestCompetitiveUpdate, isNull);
        expect(m.queueSkills.containsKey(''), isFalse);
      }
      final m = PlayerMmr.fromJson({
        'QueueSkills': {
          'competitive': {
            'SeasonalInfoBySeasonID': {
              'c': {'WinsByTier': 'x', 'CompetitiveTier': 'high'},
            },
          },
        },
      });
      expect(m.competitive()!.season('c')!.competitiveTier, 0);
    });
  });

  group('competitive updates (P-12)', () {
    test('page parsing skips blank and malformed rows', () {
      final page = CompetitiveUpdatesPage.fromJson(
        competitiveFixture('competitive_updates'),
      );
      expect(page.subject, me);
      expect(page.matches.map((u) => u.matchId), [
        for (var i = 5; i >= 1; i--) updateId(i),
      ]);
      final e4 = page.matches[1];
      expect(e4.rrEarned, 22); // arrived as "22"
      expect(e4.mapId, '/Game/Maps/HURM/HURM_Alley/HURM_Alley');
      expect(page.matches[2].rrEarned, 0);
      expect(CompetitiveUpdatesPage.fromJson(null).matches, isEmpty);
      expect(
        CompetitiveUpdatesPage.fromJson({'Matches': 'x'}).matches,
        isEmpty,
      );
    });

    test('toJson round-trips; equality and ordering', () {
      final page = CompetitiveUpdatesPage.fromJson(
        competitiveFixture('competitive_updates'),
      );
      for (final u in page.matches) {
        expect(CompetitiveUpdate.fromJson(u.toJson()), u);
      }
      final noTime = CompetitiveUpdate(matchId: 'z');
      final sorted = [noTime, ...page.matches.reversed]
        ..sort(compareUpdatesNewestFirst);
      expect(sorted.first.matchId, updateId(5));
      expect(sorted.last, noTime);
      expect(noTime.toJson().containsKey('MatchStartTime'), isFalse);
    });
  });
}
