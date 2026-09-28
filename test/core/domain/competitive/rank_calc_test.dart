import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/domain/competitive/competitive_strings.dart';
import 'package:valvn/core/domain/competitive/match_models.dart';
import 'package:valvn/core/domain/competitive/rank_calc.dart';
import 'package:valvn/core/domain/competitive/rank_models.dart';

import 'competitive_test_utils.dart';

const _e1Table = '564d8e28-c226-3180-6285-e48a390db8b1';
const _e2Table = '23eb970e-6408-bc0b-3f20-d8fb0e0354ea';
const _e5Table = '03621f52-342b-cf4e-4f86-9350a49c6d04';

final _now = DateTime.utc(2026, 9, 28, 12);

CompetitiveUpdate _row(
  String id, {
  int tier = 18,
  int rr = 50,
  int earned = 0,
  String? season = actV,
  DateTime? at,
  int? tierBefore,
  int? rrBefore,
}) => CompetitiveUpdate(
  matchId: id,
  seasonId: season,
  matchStartTime: at ?? DateTime.utc(2026, 9, 1),
  tierAfter: tier,
  tierBefore: tierBefore ?? tier,
  rrAfter: rr,
  rrBefore: rrBefore ?? rr,
  rrEarned: earned,
);

void main() {
  late ContentDb db;
  late PlayerMmr mmr;
  late List<CompetitiveUpdate> updates;

  setUpAll(() {
    db = testContent();
    mmr = PlayerMmr.fromJson(competitiveFixture('mmr'));
    updates = CompetitiveUpdatesPage.fromJson(
      competitiveFixture('competitive_updates'),
    ).matches;
  });

  group('normalizeTier (E4 vs E5 tables)', () {
    test('division + number map every table onto Episode 5 tiers', () {
      final e1 = db.tierTable(_e1Table);
      final e5 = db.tierTable(_e5Table);
      expect(normalizeTier(21, e1), 24); // E1 Bất Tử 1 = E5 Bất Tử 1
      expect(normalizeTier(24, e1), 27); // E1 Radiant
      expect(normalizeTier(18, e1), 18);
      expect(normalizeTier(21, e5), 21); // E5 Thượng Nhân 1
      expect(normalizeTier(24, e5), 24);
      expect(normalizeTier(27, e5), 27);
      expect(normalizeTier(0, e5), 0);
      expect(normalizeTier(1, e5), 0);
      expect(normalizeTier(2, null), 0);
    });

    test('fallbacks: legacy table ids, then the raw tier', () {
      // Tier 22 is not in the trimmed E1 fixture table.
      expect(normalizeTier(22, db.tierTable(_e1Table)), 25);
      expect(normalizeTier(23, db.tierTable(_e5Table)), 23);
      expect(normalizeTier(22, null), 22);
    });

    test('Episode 2 single Immortal tier', () {
      final e2 = CompetitiveTierTable.fromJson({
        'uuid': _e2Table,
        'tiers': [
          {
            'tier': 21,
            'tierName': 'BẤT TỬ',
            'division': 'ECompetitiveDivision::IMMORTAL',
          },
          {
            'tier': 24,
            'tierName': 'RADIANT',
            'division': 'ECompetitiveDivision::RADIANT',
          },
        ],
      });
      expect(normalizeTier(21, e2), 24);
      expect(normalizeTier(24, e2), 27);
    });
  });

  group('RankInfo', () {
    test('resolves name, icon and color in the act table', () {
      final r = RankInfo.resolve(db, tier: 18, rr: 6, actUuid: actV);
      expect(r.tierName, 'Kim Cương 1');
      expect(r.rr, 6);
      expect(r.icon, endsWith('/18/smallicon.png'));
      expect(r.largeIcon, endsWith('/18/largeicon.png'));
      expect(r.colorHex, 'b489c4ff');
      expect(r.color.toARGB32(), 0xFFB489C4);
      expect(r.isUnranked, isFalse);
      final old = RankInfo.resolve(db, tier: 21, actUuid: e1a1.toUpperCase());
      expect(old.tierName, 'Bất Tử 1');
      expect(old.actUuid, e1a1);
      expect(old.normalizedTier, 24);
      expect(
        RankInfo.resolve(db, tier: 21, actUuid: actV).tierName,
        'Thượng Nhân 1',
      );
    });

    test('unranked, unused tiers and placements', () {
      final u = RankInfo.resolve(db, tier: 1, rr: 40, actUuid: actV);
      expect(u.tierName, 'Chưa xếp hạng');
      expect(u.rr, 0);
      expect(u.isUnranked, isTrue);
      expect(u.colorHex, isNull);
      expect(u.icon, endsWith('/0/smallicon.png'));
      expect(u.isPlacement, isFalse);
      final p = RankInfo.resolve(db, tier: 0, gamesNeeded: 3);
      expect(p.isPlacement, isTrue);
      expect(p.placementText, 'Còn 3 trận phân hạng');
    });

    test('works before content is downloaded', () {
      final empty = ContentDb.empty();
      final r = RankInfo.resolve(empty, tier: 16, rr: 20, actUuid: actV);
      expect(r.tierName, 'Bạch Kim 2');
      expect(r.icon, isNull);
      expect(RankInfo.resolve(empty, tier: 27).tierName, 'Radiant');
      expect(CompetitiveStrings.fallbackTierName(3), 'Sắt 1');
      expect(CompetitiveStrings.fallbackTierName(26), 'Bất Tử 3');
      expect(CompetitiveStrings.fallbackTierName(2), isNull);
      expect(CompetitiveStrings.fallbackTierName(28), isNull);
    });

    test('compareTo uses normalized tiers across tables', () {
      final e1Immortal = RankInfo.resolve(db, tier: 21, actUuid: e1a1);
      final e5Ascendant = RankInfo.resolve(db, tier: 23, actUuid: actV);
      expect(e1Immortal.compareTo(e5Ascendant), greaterThan(0));
    });
  });

  group('current rank', () {
    test('current act entry', () {
      final r = currentRankOf(db, mmr, now: _now);
      expect((r.tier, r.rr, r.actUuid), (18, 6, actV));
      expect(r.tierName, 'Kim Cương 1');
      final console = currentRankOf(db, mmr, now: _now, console: true);
      expect((console.tier, console.rr), (9, 44));
      expect(console.tierName, 'Bạc 1');
    });

    test('falls back to the latest update of the current act', () {
      final m = PlayerMmr.fromJson({
        'QueueSkills': {
          'competitive': {'SeasonalInfoBySeasonID': null},
        },
        'LatestCompetitiveUpdate': competitiveFixtureMap(
          'mmr',
        )['LatestCompetitiveUpdate'],
      });
      final r = currentRankOf(db, m, now: _now);
      expect((r.tier, r.rr), (18, 6));
    });

    test('placements and never ranked', () {
      final placements = PlayerMmr.fromJson({
        'QueueSkills': {
          'competitive': {'CurrentSeasonGamesNeededForRating': 3},
        },
      });
      final p = currentRankOf(db, placements, now: _now);
      expect(p.isUnranked, isTrue);
      expect(p.isPlacement, isTrue);
      expect(p.gamesNeeded, 3);
      expect(p.actUuid, actV);
      final nobody = PlayerMmr.fromJson(const <String, dynamic>{});
      expect(currentRankOf(db, nobody, now: _now).isPlacement, isFalse);
      expect(peakRankOf(db, nobody), isNull);
      // A different act than the current one is not "current".
      final other = currentRankOf(db, mmr, now: DateTime.utc(2020, 6, 10));
      expect(other.actUuid, e1a1);
      expect(other.tierName, 'Bất Tử 1');
    });
  });

  group('peak and true peak (SUMMARY §9.5)', () {
    test('E1 Immortal beats higher raw numbers of newer tables', () {
      final peak = peakRankOf(db, mmr)!;
      // Unknown act: raw 23 (Thượng Nhân 3) < E1 21 (Bất Tử 1 → 24).
      expect(peak.actUuid, e1a1);
      expect(peak.rank.tier, 21);
      expect(peak.rank.tierName, 'Bất Tử 1');
      expect(peak.rank.normalizedTier, 24);
      expect(peak.truePeakRr, 40); // RankedRating of that act
      expect(peak.truePeakFromLocalHistory, isFalse);
    });

    test('stored rows give the true peak RR', () {
      final peak = peakRankOf(
        db,
        mmr,
        history: [
          _row('h1', tier: 21, rr: 80, season: e1a1),
          _row('h2', tier: 21, rr: 12, season: e1a1),
        ],
      )!;
      expect(peak.truePeakRr, 80);
      expect(peak.rank.rr, 80);
      expect(peak.truePeakFromLocalHistory, isTrue);
    });

    test('ties go to the most recent act; higher tiers win', () {
      final tie = peakRankOf(db, mmr, history: [_row('h', tier: 24, rr: 10)])!;
      expect(tie.actUuid, actV);
      expect(tie.rank.tierName, 'Bất Tử 1');
      expect(tie.truePeakRr, 40);
      final radiant = peakRankOf(
        db,
        mmr,
        history: [_row('r', tier: 26, rr: 180, tierBefore: 25, rrBefore: 60)],
      )!;
      expect(radiant.rank.normalizedTier, 26);
      expect(radiant.truePeakRr, 180);
    });

    test('act history is newest first with titles', () {
      final acts = actHistoryOf(db, mmr);
      expect(acts.map((a) => a.actUuid), [unknownAct, actV, e1a1]);
      expect(acts[1].title, 'V26 // PHẦN V');
      expect(acts[2].title, 'HỒI 1 // PHẦN I');
      expect(acts[0].title, isNull);
      expect(acts[1].badge!.tier, 18);
      expect(acts[2].wins, 30);
      expect(acts[2].games, 55);
    });

    test('summary', () {
      final s = buildRankSummary(db, mmr, now: _now);
      expect(s.current.tierName, 'Kim Cương 1');
      expect(s.peak!.actUuid, e1a1);
      expect(s.currentAct!.uuid, actV);
      expect((s.wins, s.games), (20, 38));
      expect(s.winRate, closeTo(20 / 38, 1e-9));
      expect(s.leaderboardRank, isNull);
      expect(s.latestUpdate!.matchId, updateId(5));
      expect(s.acts, hasLength(3));
    });
  });

  group('Daily RR (SUMMARY §9.6)', () {
    DateTime vn(DateTime utc) => utc.add(const Duration(hours: 7));

    test('groups by local date, newest day first', () {
      final days = groupDailyRr(updates, toLocal: vn);
      expect(days.map((d) => d.date), [
        DateTime(2026, 9, 28),
        DateTime(2026, 9, 27),
      ]);
      final today = days.first;
      // 01:30 on the 28th in Vietnam although 18:30Z on the 27th.
      expect(today.matches.map((m) => m.matchId), [
        updateId(3),
        updateId(4),
        updateId(5),
      ]);
      expect(today.netRr, 54);
      expect((today.wins, today.losses, today.draws), (2, 0, 1));
      expect((today.startTier, today.startRr), (17, 52));
      expect((today.endTier, today.endRr), (18, 6));
      expect(today.endSeasonId, actV);
      final yesterday = days.last;
      expect(yesterday.netRr, 2);
      expect((yesterday.wins, yesterday.losses, yesterday.draws), (1, 1, 0));
      expect((yesterday.startTier, yesterday.startRr), (17, 50));
      expect((yesterday.endTier, yesterday.endRr), (17, 52));
    });

    test('known outcomes win over the RR sign; duplicates ignored', () {
      final days = groupDailyRr(
        [...updates, updates.first],
        outcomes: {
          updateId(3): MatchOutcome.loss,
          updateId(4): MatchOutcome.unknown,
        },
        toLocal: vn,
      );
      expect(days.first.matches, hasLength(3));
      expect((days.first.wins, days.first.losses, days.first.draws), (2, 1, 0));
    });

    test('UTC cut differs from the Vietnamese cut', () {
      final utcDays = groupDailyRr(updates, toLocal: (d) => d);
      expect(utcDays.first.matches.map((m) => m.matchId), [
        updateId(4),
        updateId(5),
      ]);
      expect(groupDailyRr(const []), isEmpty);
      expect(groupDailyRr([const CompetitiveUpdate(matchId: 'x')]), isEmpty);
    });
  });

  group('Rank-Up Calculator (SUMMARY §9.7)', () {
    test('VF S41 example: 164 RR from Gold 1 (36 RR) to Gold 3', () {
      expect(rrNeededFor(tier: 12, rr: 36, targetTier: 14), 164);
      expect(rrNeededFor(tier: 18, rr: 6, targetTier: 19), 94);
    });

    test('form from the last 20 updates', () {
      final form = rankUpFormOf(updates);
      expect(form.wins, 3);
      expect(form.losses, 1);
      expect(form.avgGain, closeTo(74 / 3, 1e-9));
      expect(form.avgLoss, 18);
      expect(form.winRate, 0.75);
      expect(form.expectedRrPerMatch(0.75), closeTo(14, 1e-9));
      final old = [
        for (var i = 0; i < 5; i++)
          _row('old$i', earned: -30, at: DateTime.utc(2026, 1, 1 + i)),
      ];
      final recent = [
        for (var i = 0; i < 20; i++)
          _row('new$i', earned: 20, at: DateTime.utc(2026, 9, 1 + i)),
      ];
      final windowed = rankUpFormOf([...old, ...recent]);
      expect((windowed.wins, windowed.losses), (20, 0));
      expect(windowed.winRate, 1);
      expect(rankUpFormOf(const []).winRate, isNull);
    });

    test('estimate: current form, best case, win-rate table', () {
      final est = estimateRankUp(
        currentTier: 18,
        currentRr: 6,
        targetTier: 19,
        form: rankUpFormOf(updates),
      )!;
      expect(est.rrNeeded, 94);
      expect(est.alreadyReached, isFalse);
      expect(est.matchesAtCurrentForm, 7); // 94 / 14
      expect(est.bestCaseWins, 4); // 94 / 24.67
      expect(est.byWinRate.map((e) => e.winRate), kRankUpWinRates);
      expect(est.byWinRate.map((e) => e.matches), [79, 29, 18, 13, 10]);
      final far = estimateRankUp(
        currentTier: 18,
        currentRr: 6,
        targetTier: kRankUpMaxTier,
        form: rankUpFormOf(updates),
      )!;
      expect(far.rrNeeded, 594);
      expect(far.matchesAtCurrentForm, 43);
    });

    test('cannot estimate with a losing form or without data', () {
      const losing = RankUpForm(avgGain: 10, avgLoss: 30, wins: 1, losses: 1);
      final est = estimateRankUp(
        currentTier: 12,
        currentRr: 0,
        targetTier: 13,
        form: losing,
      )!;
      expect(est.matchesAtCurrentForm, isNull);
      expect(est.bestCaseWins, 10);
      final none = estimateRankUp(
        currentTier: 12,
        currentRr: 0,
        targetTier: 13,
        form: const RankUpForm(),
      )!;
      expect(none.matchesAtCurrentForm, isNull);
      expect(none.bestCaseWins, isNull);
      expect(none.byWinRate.every((e) => e.matches == null), isTrue);
      expect(
        matchesNeeded(rrNeeded: 0, winRate: 0.5, avgGain: 1, avgLoss: 1),
        0,
      );
      expect(
        matchesNeeded(rrNeeded: 10, winRate: 0.5, avgGain: 20, avgLoss: 20),
        isNull,
      );
    });

    test('valid targets only (up to Immortal 1)', () {
      expect(rankUpTargets(18), [19, 20, 21, 22, 23, 24]);
      expect(rankUpTargets(23), [24]);
      expect(rankUpTargets(24), isEmpty);
      expect(rankUpTargets(0), isEmpty);
      const form = RankUpForm(avgGain: 20, avgLoss: 15, wins: 5, losses: 5);
      for (final (tier, target) in [(0, 5), (24, 25), (18, 18), (18, 25)]) {
        expect(
          estimateRankUp(
            currentTier: tier,
            currentRr: 0,
            targetTier: target,
            form: form,
          ),
          isNull,
        );
      }
    });
  });
}
