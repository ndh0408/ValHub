import '../../../helpers/l10n.dart';

import 'package:valvn/core/l10n/labels/rank_labels.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/util/format.dart';
import 'package:valvn/features/home/data/home_rank.dart';
import 'package:valvn/features/home/home_strings.dart';
import 'package:valvn/features/home/ui/cards/rank_home_card.dart';
import 'package:valvn/features/home/ui/home_card_frame.dart';

import '../../profile/profile_test_env.dart'
    show competitiveFixtureMap, testContent, updateRow;
import '../home_test_env.dart';

Widget _card() => const RankHomeCard(puuid: Fx.puuid);

/// "Hôm nay +37 RR · 3 thắng – 1 thua".
String get _todayText =>
    '${HomeStrings.rrToday(formatSignedRr(37))}${HomeStrings.dot}'
    '${HomeStrings.winsLosses(3, 1, 0)}';

void main() {
  late HomeTestEnv env;

  setUp(() async {
    env = await HomeTestEnv.create();
  });

  testWidgets('rank name, RR and the progress bar', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmRank(AsyncData(homeRankSnapshot()))],
    );
    expect(find.text(HomeStrings.cardRank), findsOneWidget);
    expect(find.text('Kim Cương 1'), findsOneWidget);
    expect(find.text('6 RR'), findsOneWidget);
    // The bar says how far the next rank is (not only by its fill).
    expect(
      find.bySemanticsLabel(RegExp(RegExp.escape(HomeStrings.rankToNext(94)))),
      findsOneWidget,
    );
    handle.dispose();
    homeExpectNoException(tester);
    await homeUnmount(tester);
  });

  testWidgets('RR today: arrow, sign and the record; tap opens daily RR', (
    tester,
  ) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmRank(AsyncData(homeRankSnapshot()))],
    );
    expect(find.text(_todayText), findsOneWidget);
    expect(find.byIcon(Icons.arrow_drop_up_rounded), findsOneWidget);

    await tester.tap(find.text(_todayText));
    await homeSettle(tester);
    expect(find.text('route /profile/daily-rr'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('a losing day points down', (tester) async {
    final snap = homeRankSnapshot();
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [
        vmRank(
          AsyncData(
            HomeRankSnapshot(
              current: snap.current,
              progress: snap.progress,
              rrToNext: snap.rrToNext,
              today: groupDailyRr([
                CompetitiveUpdate.fromJson(
                  updateRow(
                    'e0000000-0000-4000-8000-0000000000aa',
                    start: homeNow.subtract(const Duration(hours: 1)),
                    earned: -18,
                  ),
                )!,
              ]).first,
            ),
          ),
        ),
      ],
    );
    expect(find.byIcon(Icons.arrow_drop_down_rounded), findsOneWidget);
    expect(find.textContaining(formatSignedRr(-18)), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('nothing today: the last day, then "no ranked today"', (
    tester,
  ) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmRank(AsyncData(homeRankSnapshot(daysAgo: 1)))],
    );
    expect(find.textContaining(CommonStrings.yesterdayTitle), findsOneWidget);
    expect(find.textContaining(HomeStrings.rrToday('')), findsNothing);
    await homeUnmount(tester);

    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [
        vmRank(AsyncData(homeRankSnapshot(noGames: true, streak: false))),
      ],
    );
    expect(find.text(HomeStrings.noRankedToday), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('streak pill with a flame, or a falling arrow', (tester) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmRank(AsyncData(homeRankSnapshot()))],
    );
    expect(find.text(HomeStrings.winStreak(2)), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
    await homeUnmount(tester);

    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmRank(AsyncData(homeRankSnapshot(lossStreak: true)))],
    );
    expect(find.text(HomeStrings.lossStreak(2)), findsOneWidget);
    expect(find.byIcon(Icons.trending_down_rounded), findsOneWidget);
    await homeUnmount(tester);

    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmRank(AsyncData(homeRankSnapshot(streak: false)))],
    );
    expect(find.textContaining('Chuỗi'), findsNothing);
    await homeUnmount(tester);
  });

  testWidgets('games to rank up open the calculator', (tester) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmRank(AsyncData(homeRankSnapshot()))],
    );
    final text = HomeStrings.matchesToRankUp(9, 'Kim Cương 2');
    expect(find.text(text), findsOneWidget);
    await tester.tap(find.text(text));
    await homeSettle(tester);
    expect(find.text('route /profile/rankup'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    await homeUnmount(tester);

    // No estimate, no row.
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmRank(AsyncData(homeRankSnapshot(matches: null)))],
    );
    expect(find.textContaining('≈'), findsNothing);
    await homeUnmount(tester);
  });

  testWidgets('the analysis is one tap away from the rank card', (
    tester,
  ) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmRank(AsyncData(homeRankSnapshot()))],
    );
    await tester.tap(find.text(tl.profilePerformanceTitle));
    await homeSettle(tester);
    expect(find.text('route /profile/performance'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('the card itself switches to the Hồ sơ tab', (tester) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmRank(AsyncData(homeRankSnapshot()))],
    );
    await tester.tap(find.text(HomeStrings.cardRank));
    await homeSettle(tester);
    expect(find.text('route /profile'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
    await homeUnmount(tester);
  });

  testWidgets('variants: placements, unranked with a past act, Immortal+', (
    tester,
  ) async {
    final past = homeRankSnapshot(tier: 21, rr: 40).current;
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [
        vmRank(AsyncData(homeRankSnapshot(tier: 0, rr: 0, gamesNeeded: 3))),
      ],
    );
    expect(find.textContaining('3'), findsWidgets);
    expect(find.text('0 RR'), findsNothing);
    await homeUnmount(tester);

    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [
        vmRank(AsyncData(homeRankSnapshot(tier: 0, rr: 0, previousAct: past))),
      ],
    );
    expect(find.text('Chưa xếp hạng'), findsOneWidget);
    expect(
      find.text(HomeStrings.previousAct(past.displayLabel(tf))),
      findsOneWidget,
    );
    await homeUnmount(tester);

    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [
        vmRank(
          AsyncData(
            homeRankSnapshot(
              tier: 24,
              rr: 200,
              leaderboard: 123,
              matches: null,
            ),
          ),
        ),
      ],
    );
    expect(
      find.text(HomeStrings.leaderboard(formatNumber(123))),
      findsOneWidget,
    );
    expect(find.textContaining('≈'), findsNothing);
    await homeUnmount(tester);
  });

  testWidgets('never ranked: nothing at all; loading: a skeleton', (
    tester,
  ) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmRank(const AsyncData(null))],
    );
    expect(find.byType(HomeCardFrame), findsNothing);
    await homeUnmount(tester);

    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmRank(const AsyncLoading())],
    );
    expect(find.byType(HomeCardSkeleton), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('a wide card lays the rank and the form side by side', (
    tester,
  ) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      size: const Size(900, 700),
      overrides: [vmRank(AsyncData(homeRankSnapshot()))],
    );
    final name = tester.getTopLeft(find.text('Kim Cương 1'));
    final form = tester.getTopLeft(find.text(_todayText));
    expect(form.dx, greaterThan(name.dx + 200));
    homeExpectNoException(tester);
    await homeUnmount(tester);
  });

  testWidgets('"Hôm nay" rolls over at the local midnight', (tester) async {
    final mmr = PlayerMmr.fromJson(competitiveFixtureMap('mmr'));
    final summary = buildRankSummary(testContent(), mmr, now: homeNow);
    final history = RrHistory(
      puuid: Fx.puuid,
      rows: [
        for (final (i, earned) in [22, 20].indexed)
          CompetitiveUpdate.fromJson(
            updateRow(
              'e0000000-0000-4000-8000-00000000000${i + 1}',
              start: homeNow.subtract(Duration(hours: i + 1)),
              rrBefore: 50,
              rrAfter: 50 + earned,
              earned: earned,
            ),
          )!,
      ],
    );
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [
        rankSummaryProvider.overrideWith((ref, puuid) async => summary),
        rrHistoryProvider.overrideWith((ref, puuid) async => history),
        rankUpEstimateProvider.overrideWith((ref, q) async => null),
      ],
    );
    final today = HomeStrings.rrToday(formatSignedRr(42));
    expect(
      find.textContaining(today),
      findsOneWidget,
      reason: 'two wins today',
    );

    // Past midnight: the same games are now "yesterday".
    env.clock.time = DateTime(2026, 9, 29, 0, 5);
    await tester.pump(const Duration(hours: 12, minutes: 6));
    await homeSettle(tester);
    expect(find.textContaining(today), findsNothing);
    expect(find.textContaining(CommonStrings.yesterdayTitle), findsOneWidget);
    await homeUnmount(tester);
  });
}
