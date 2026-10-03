import '../../../helpers/l10n.dart';

import 'package:valvn/core/l10n/labels/content_labels.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/features/profile/data/match_filter.dart';
import 'package:valvn/features/profile/data/player_identity.dart';
import 'package:valvn/features/profile/data/round_timeline.dart';
import 'package:valvn/features/profile/data/rr_trend.dart';
import 'package:valvn/features/profile/profile_routes.dart';

import '../profile_test_env.dart';

CompetitiveUpdate _u(String id, DateTime start, int earned) =>
    CompetitiveUpdate(matchId: id, matchStartTime: start, rrEarned: earned);

void main() {
  group('PlayerIdentity.fromLoadout', () {
    test('reads the Identity block, lowercases uuids, drops zero uuids', () {
      final id = PlayerIdentity.fromLoadout({
        'Identity': {
          'PlayerCardID': 'ABCDEF00-0000-4000-8000-000000000001',
          'PlayerTitleID': 'abcdef00-0000-4000-8000-000000000002',
          'PreferredLevelBorderID': '00000000-0000-0000-0000-000000000000',
          'HideAccountLevel': true,
        },
        'Incognito': true,
      });
      expect(id.cardId, 'abcdef00-0000-4000-8000-000000000001');
      expect(id.titleId, 'abcdef00-0000-4000-8000-000000000002');
      expect(id.levelBorderId, isNull);
      expect(id.hideAccountLevel, isTrue);
      expect(id.incognito, isTrue);
    });

    test('garbage and HTML bodies give defaults', () {
      for (final json in [null, '<html>', 42, <String, Object?>{}]) {
        final id = PlayerIdentity.fromLoadout(json);
        expect(id.cardId, isNull);
        expect(id.hideAccountLevel, isFalse);
        expect(id.incognito, isFalse);
      }
      expect(
        PlayerIdentity.fromLoadout({
          'Identity': {'PlayerCardID': 7, 'HideAccountLevel': 'yes'},
        }).cardId,
        isNull,
      );
    });
  });

  group('MatchFilter', () {
    test('map filter compares paths case-insensitively', () {
      const f = MatchFilter(mapUrl: '/Game/Maps/Ascent/Ascent');
      expect(f.hasMap, isTrue);
      expect(f.acceptsMap('/game/maps/ascent/ascent'), isTrue);
      expect(f.acceptsMap('/Game/Maps/Bonsai/Bonsai'), isFalse);
      expect(f.acceptsMap(null), isFalse);
      expect(const MatchFilter().acceptsMap(null), isTrue);
    });

    test('withQueue / withMap keep the other part', () {
      const f = MatchFilter(queue: 'competitive', mapUrl: '/m');
      expect(f.withQueue(null), const MatchFilter(mapUrl: '/m'));
      expect(f.withMap(null), const MatchFilter(queue: 'competitive'));
      expect(f.withQueue('unrated').hashCode, isNot(f.hashCode));
    });

    test('filterableMaps: site maps first, no range / tutorial', () {
      final db = ContentDb.parse({
        ContentEndpoints.maps: {
          'status': 200,
          'data': [
            {
              'uuid': '00000000-0000-4000-8000-000000000001',
              'displayName': 'Bãi Tập',
              'mapUrl': '/Game/Maps/Poveglia/Range',
            },
            {
              'uuid': '00000000-0000-4000-8000-000000000002',
              'displayName': 'District',
              'mapUrl': '/Game/Maps/HURM/HURM_Alley/HURM_Alley',
            },
            {
              'uuid': '00000000-0000-4000-8000-000000000003',
              'displayName': 'Bind',
              'mapUrl': '/Game/Maps/Duality/Duality',
              'tacticalDescription': 'A/B Sites',
            },
            {
              'uuid': '00000000-0000-4000-8000-000000000004',
              'displayName': 'Ascent',
              'mapUrl': '/Game/Maps/Ascent/Ascent',
              'tacticalDescription': 'A/B Sites',
            },
            {
              'uuid': '00000000-0000-4000-8000-000000000005',
              'displayName': 'Hướng dẫn',
              'mapUrl': '/Game/Maps/NPEV2/NPEV2',
            },
            {
              'uuid': '00000000-0000-4000-8000-000000000006',
              'displayName': '',
              'mapUrl': '/Game/Maps/Empty/Empty',
            },
          ],
        },
      });
      expect(filterableMaps(db).map((m) => m.displayName), [
        'Ascent',
        'Bind',
        'District',
      ]);
    });

    test('queue chips are PC ids with vi labels from content', () {
      final db = testContent();
      expect(kProfileQueueFilters.first, kCompetitiveQueue);
      expect(db.queueShortName(tl, 'competitive'), 'Xếp hạng');
      expect(db.queueShortName(tl, 'hurm'), 'Sinh Tử Đội');
    });
  });

  group('RR trend', () {
    test('newest 20 changes, oldest first, deduplicated', () {
      final base = DateTime.utc(2026, 9, 1);
      final rows = [
        for (var i = 0; i < 25; i++) _u('m$i', base.add(Duration(hours: i)), i),
        _u('m24', base.add(const Duration(hours: 24)), 24),
      ]..shuffle();
      final changes = recentRrChanges(rows);
      expect(changes, [for (var i = 5; i < 25; i++) i]);
      expect(recentRrChanges(rows, limit: 3), [22, 23, 24]);
      expect(recentRrChanges(const []), isEmpty);
    });

    test('cumulative total starts at zero', () {
      expect(cumulativeRr([20, -15, 0, 7]), [0, 20, 5, 5, 12]);
      expect(cumulativeRr(const []), [0]);
    });

    test('dailyRrOn finds the local day of now', () {
      final days = groupDailyRr([
        _u('a', DateTime(2026, 9, 28, 9).toUtc(), 20),
        _u('b', DateTime(2026, 9, 27, 23).toUtc(), -10),
      ]);
      expect(dailyRrOn(days, DateTime(2026, 9, 28, 22))?.netRr, 20);
      expect(dailyRrOn(days, DateTime(2026, 9, 27, 1))?.netRr, -10);
      expect(dailyRrOn(days, DateTime(2026, 9, 29, 1)), isNull);
    });
  });

  group('round timeline', () {
    final comp = MatchDetails.fromJson(
      competitiveFixture('match_competitive'),
      matchId: compMatch,
    );

    test('running score, winners and halves from your side', () {
      final rows = buildRoundRows(comp, puuid: me);
      expect(rows.map((r) => r.number), [1, 2, 3]);
      expect(rows.map((r) => r.won), [true, false, true]);
      expect(rows.map((r) => (r.myScore, r.otherScore)), [
        (1, 0),
        (1, 1),
        (2, 1),
      ]);
      expect(rows.every((r) => r.half == MatchHalf.first), isTrue);
      expect(rows.map((r) => r.endType), [
        RoundEndType.elimination,
        RoundEndType.detonate,
        RoundEndType.defuse,
      ]);
      expect(rows.fold<int>(0, (a, r) => a + r.myKills), 3);
    });

    test('the enemy sees the mirrored score', () {
      final rows = buildRoundRows(comp, puuid: enemy1);
      expect(rows.map((r) => r.won), [false, true, false]);
      expect((rows.last.myScore, rows.last.otherScore), (1, 2));
    });

    test('spectators get the first side, unknown players too', () {
      final rows = buildRoundRows(comp, puuid: stranger);
      expect(rows.length, 3);
      expect((rows.last.myScore, rows.last.otherScore), (2, 1));
      expect(rows.every((r) => r.myKills == 0), isTrue);
    });

    test('halves by queue', () {
      expect(roundsPerHalf('competitive'), 12);
      expect(roundsPerHalf('console_unrated'), 12);
      expect(roundsPerHalf(''), 12);
      expect(roundsPerHalf('swiftplay'), 4);
      expect(roundsPerHalf('spikerush'), 3);
      expect(roundsPerHalf('deathmatch'), isNull);
      final rounds = [
        for (var i = 0; i < 26; i++)
          {'roundNum': i, 'winningTeam': i.isEven ? 'Blue' : 'Red'},
      ];
      final long = MatchDetails.fromJson({
        'matchInfo': {'matchId': compMatch, 'queueID': 'competitive'},
        'players': [
          {'subject': me, 'teamId': 'Blue'},
        ],
        'roundResults': rounds,
      });
      final rows = buildRoundRows(long, puuid: me);
      expect(rows[11].half, MatchHalf.first);
      expect(rows[12].half, MatchHalf.second);
      expect(rows[24].half, MatchHalf.overtime);
      expect((rows.last.myScore, rows.last.otherScore), (13, 13));
    });
  });

  group('ProfileRoutes', () {
    test('locations with optional query parameters', () {
      expect(ProfileRoutes.match('m1'), '/profile/match/m1');
      expect(
        ProfileRoutes.match('m1', player: 'p'),
        '/profile/match/m1?player=p',
      );
      expect(ProfileRoutes.matchFullScreen('m1'), '/match/m1');
      expect(
        ProfileRoutes.matchFullScreen('m1', player: 'p'),
        '/match/m1?player=p',
      );
      expect(ProfileRoutes.player('p'), '/player/p');
      expect(ProfileRoutes.player('p', hidden: true), '/player/p?hidden=1');
    });
  });
}
