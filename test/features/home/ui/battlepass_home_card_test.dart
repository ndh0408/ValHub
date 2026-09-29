import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/ui/val_widgets.dart';
import 'package:valvn/core/util/format.dart';
import 'package:valvn/features/battlepass/battlepass_strings.dart';
import 'package:valvn/features/battlepass/data/xp_pace.dart';
import 'package:valvn/features/home/home_strings.dart';
import 'package:valvn/features/home/ui/cards/battlepass_home_card.dart';
import 'package:valvn/features/home/ui/home_card_frame.dart';

import '../home_test_env.dart';

Widget _card() => const BattlePassHomeCard(puuid: Fx.puuid);

void main() {
  late HomeTestEnv env;

  setUp(() async {
    env = await HomeTestEnv.create();
  });

  testWidgets('level, XP per day, days left, two missions and the pips', (
    tester,
  ) async {
    final snap = homeBpSnapshot();
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmBp(AsyncData(snap))],
    );

    expect(find.text(HomeStrings.cardBattlePass), findsOneWidget);
    expect(
      find.text(BattlePassStrings.levelOf(formatNumber(46), formatNumber(55))),
      findsOneWidget,
    );
    expect(
      find.text(BattlePassStrings.xpPerDay(formatNumber(snap.pace!.xpPerDay))),
      findsOneWidget,
    );
    expect(find.text(BattlePassStrings.xpPerDayCaption), findsOneWidget);
    expect(
      find.text(BattlePassStrings.daysLeft(snap.daysLeft!)),
      findsOneWidget,
    );
    // The two missions closest to done, with their progress.
    expect(find.text(Bp.ultTitle), findsOneWidget);
    expect(find.text(Bp.headshotTitle), findsOneWidget);
    expect(find.text(Bp.damageTitle), findsNothing);
    expect(
      find.text(
        BattlePassStrings.missionProgress(formatNumber(8), formatNumber(15)),
      ),
      findsOneWidget,
    );
    expect(
      find.text(BattlePassStrings.xpReward(formatNumber(38400))),
      findsOneWidget,
    );
    // Four diamonds and the text ("not colour alone").
    expect(find.byType(DiamondPip), findsNWidgets(4));
    expect(find.text(BattlePassStrings.checkpointsDone(1, 4)), findsOneWidget);
    homeExpectNoException(tester);
    await homeUnmount(tester);
  });

  testWidgets('a tap pushes the Battle Pass inside the Home stack', (
    tester,
  ) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmBp(AsyncData(homeBpSnapshot()))],
    );
    await tester.tap(find.text(HomeStrings.cardBattlePass));
    await homeSettle(tester);
    expect(find.text('route /battlepass'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await homeSettle(tester);
    expect(find.text(HomeStrings.cardBattlePass), findsOneWidget);

    // A mission is part of the card: it opens the pass too.
    await tester.tap(find.text(Bp.ultTitle));
    await homeSettle(tester);
    expect(find.text('route /battlepass'), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('the event pass line opens its rewards', (tester) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmBp(AsyncData(homeBpSnapshot()))],
    );
    final line = find.textContaining(BattlePassStrings.eventPass);
    expect(line, findsOneWidget);
    await tester.tap(line);
    await homeSettle(tester);
    expect(
      find.text('route /battlepass/rewards?contract=${Bp.eventPassId}'),
      findsOneWidget,
    );
    await homeUnmount(tester);
  });

  testWidgets('a finished Battle Pass follows the event pass', (tester) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmBp(AsyncData(homeBpSnapshot(complete: true)))],
    );
    expect(
      find.text(
        '${BattlePassStrings.eventPass}${HomeStrings.dot}Champions 2026',
      ),
      findsOneWidget,
    );
    homeExpectNoException(tester);
    await homeUnmount(tester);
  });

  testWidgets('all missions done: the countdown to the next ones', (
    tester,
  ) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmBp(AsyncData(homeBpSnapshot(allMissionsDone: true)))],
    );
    expect(find.text(Bp.ultTitle), findsNothing);
    expect(find.textContaining('Nhiệm vụ mới sau'), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('hidden without a pass, skeleton while loading', (tester) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmBp(const AsyncData(null))],
    );
    expect(find.byType(HomeCardFrame), findsNothing);
    await homeUnmount(tester);

    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmBp(const AsyncLoading())],
    );
    expect(find.byType(HomeCardSkeleton), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('an offline copy says when it was updated', (tester) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmBp(AsyncData(homeBpSnapshot(cache: true)))],
    );
    expect(
      find.text(CommonStrings.updatedAt(formatTime(homeNow))),
      findsOneWidget,
    );
    await homeUnmount(tester);
  });

  group('real pipeline (contracts, ticket, content)', () {
    setUp(() {
      env.content = bpContent();
      when(() => env.api.dailyTicket(any()))
          .thenAnswer((_) async => dailyTicketJson());
    });

    testWidgets('error shows "Thử lại", which refetches', (tester) async {
      var fail = true;
      when(() => env.api.contracts(any())).thenAnswer((_) async {
        if (fail) throw const TransientException(reason: 'offline');
        return contractsJson();
      });
      await pumpHomeCard(tester, env, _card());
      expect(find.text(CommonStrings.retry), findsOneWidget);

      fail = false;
      await tester.tap(find.text(CommonStrings.retry));
      await homeSettle(tester);
      expect(
        find.text(
          BattlePassStrings.levelOf(formatNumber(46), formatNumber(55)),
        ),
        findsOneWidget,
      );
      verify(() => env.api.contracts(any())).called(2);
      await homeUnmount(tester);
    });

    testWidgets('the missions countdown ends: contracts are refetched', (
      tester,
    ) async {
      // All missions done, the next ones arrive in ten seconds.
      final refill = homeNow.add(const Duration(seconds: 10)).toUtc();
      when(() => env.api.contracts(any())).thenAnswer(
        (_) async => contractsJson(
          weeklyRefill: refill.toIso8601String(),
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
      );
      await pumpHomeCard(tester, env, _card());
      verify(() => env.api.contracts(any())).called(1);

      env.clock.advance(const Duration(seconds: 11));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await homeSettle(tester);
      verify(() => env.api.contracts(any())).called(1);
      await homeUnmount(tester);
    });

    testWidgets('pace matches the shared XP-pace helper', (tester) async {
      when(() => env.api.contracts(any()))
          .thenAnswer((_) async => contractsJson());
      await pumpHomeCard(tester, env, _card());
      final expected = xpPaceOf(
        homeBpSnapshot().pass,
        DateTime.utc(2026, 10, 14),
        homeNow,
      )!;
      expect(
        find.text(BattlePassStrings.xpPerDay(formatNumber(expected.xpPerDay))),
        findsOneWidget,
      );
      await homeUnmount(tester);
    });
  });
}
