import '../../../helpers/l10n.dart';

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account_widgets.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/ui/sub_page.dart';
import 'package:valvn/core/ui/tab_page_scaffold.dart';
import 'package:valvn/core/util/format.dart';
import 'package:valvn/features/battlepass/battlepass_strings.dart';
import 'package:valvn/features/battlepass/ui/battlepass_rewards_screen.dart';
import 'package:valvn/features/battlepass/ui/widgets/daily_checkpoints.dart';
import 'package:valvn/features/battlepass/ui/widgets/overview_bits.dart';
import 'package:valvn/features/battlepass/ui/widgets/pass_card.dart';
import 'package:valvn/features/battlepass/ui/widgets/weekly_missions.dart';

import '../../../helpers/test_prefs.dart';
import '../bp_fixtures.dart';
import '../bp_test_harness.dart';

Future<void> _pump(
  WidgetTester tester,
  MockPvpApi api, {
  Future<ContentDb> Function()? loadContent,
  bool noAccount = false,
  Size size = const Size(360, 740),
  ThemeData? theme,
}) async {
  usePhoneViewport(tester, size: size);
  final prefs = await createTestPrefs();
  await tester.pumpWidget(
    bpApp(
      theme: theme,
      overrides: bpOverrides(
        api: api,
        prefs: prefs,
        loadContent: loadContent,
        account: noAccount ? null : testAccount,
      ),
    ),
  );
  await settle(tester);
}

Finder _rich(String text) => find.textContaining(text, findRichText: true);

void main() {
  testWidgets('S20 pass card, estimate and event pass', (tester) async {
    await _pump(tester, bpApi());

    // A pushed sub-page: no account chip, no maintenance banner.
    expect(find.byType(SubPageScaffold), findsOneWidget);
    expect(find.byType(TabPageScaffold), findsNothing);
    expect(find.byType(AccountChip), findsNothing);
    expect(find.text('Battle Pass'), findsOneWidget);
    // Compact card: the pass name in bold, "Cấp 46 / 55" on the right.
    expect(find.text('Mùa 2026 // Phần V'), findsOneWidget);
    expect(find.text('Cấp 46 / 55'), findsOneWidget);
    expect(find.text('7.966 / 35.750 XP'), findsOneWidget);
    expect(find.text('840.466 / 1.162.500 XP'), findsOneWidget);
    expect(find.text(BattlePassStrings.premium.toUpperCase()), findsOneWidget);
    // Time left once: the countdown on the card. No wall-clock end under
    // it and no "Còn 16 ngày" tile in the estimate.
    expect(find.text('Phần kết thúc sau 15 ngày'), findsOneWidget);
    expect(
      find.text(
        tl.battlePassEndsAtWall(
          formatWallTime(DateTime.utc(2026, 10, 14), t0, messages: tl),
        ),
      ),
      findsNothing,
    );
    expect(find.text(tl.battlePassDaysLeft(16)), findsNothing);
    // The card is the one entry to the rewards: no separate row.
    expect(find.text(tl.battlePassViewAllRewards), findsNothing);
    expect(find.text('46/55 đã mở khóa'), findsNothing);
    expect(_rich('Còn cần 322.034 XP'), findsOneWidget);
    expect(_rich('≈ 81 trận Đấu thường'), findsOneWidget);
    // XP pace: 322.034 XP over the 16 days (15.5 rounded up) left in the act.
    expect(find.text('20.128 XP / ngày'), findsOneWidget);
    expect(find.textContaining('Nhiệm vụ tuần còn +'), findsOneWidget);
    // Active Champions event pass.
    expect(find.text('VÉ SỰ KIỆN'), findsOneWidget);
    expect(find.text('Champions 2026: Shanghai'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('S20 daily checkpoints and weekly missions', (tester) async {
    await _pump(tester, bpApi());

    expect(find.text(BattlePassStrings.dailyMissions), findsOneWidget);
    expect(find.text('Làm mới sau 03:39:37'), findsOneWidget);
    expect(find.byType(CheckpointPip), findsNWidgets(4));
    expect(find.text(BattlePassStrings.bonusBadge), findsOneWidget);
    // Under the pips only what they do not show: rewards and how to fill
    // one. "1/4 reached" stays for screen readers.
    expect(_rich('Đã đạt 1/4 cột mốc'), findsNothing);
    expect(_rich('Cột mốc tiếp theo: 3/4'), findsNothing);
    expect(find.text(tl.battlePassCheckpointRewards), findsOneWidget);
    expect(find.text(tl.battlePassCheckpointHint), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(RegExp.escape('Đã đạt 1/4 cột mốc'))),
      findsOneWidget,
    );

    expect(find.text(BattlePassStrings.weeklyMissions), findsOneWidget);
    // Weekly reset (2026-09-30 00:00 UTC) also as local wall time.
    final weeklyReset = BattlePassStrings.resetsAtWall(
      formatWallTime(DateTime.utc(2026, 9, 30), t0, messages: tl),
    );
    expect(find.text('1/3 hoàn thành · $weeklyReset'), findsOneWidget);
    expect(find.text('1 ngày 12:00:00'), findsOneWidget);
    expect(find.byType(WeeklyMissionTile), findsNWidgets(3));
    expect(find.text(Bp.ultTitle), findsOneWidget);
    expect(find.text('8 / 15'), findsOneWidget);
    expect(find.text('+38.400 XP'), findsOneWidget);
    final done = tester.widget<Text>(find.text(Bp.damageTitle));
    expect(done.style?.decoration, TextDecoration.lineThrough);
    expect(find.byType(MissionsDoneCard), findsNothing);
    await unmount(tester);
  });

  testWidgets('P5: everything completed', (tester) async {
    await _pump(
      tester,
      bpApi(
        ticket: dailyTicketJson(progress: [4, 4, 4, 4]),
        contracts: contractsJson(
          missions: [
            activeMission(Bp.missionUlt, Bp.objUlt, 15, complete: true),
            activeMission(Bp.missionDamage, Bp.objDamage, 1, complete: true),
          ],
        ),
      ),
    );
    expect(find.text(BattlePassStrings.dailyAllDone), findsOneWidget);
    expect(find.text(tl.battlePassCheckpointRewards), findsNothing);
    expect(find.text(BattlePassStrings.allMissionsDone), findsOneWidget);
    expect(find.text('Nhiệm vụ mới sau 1 ngày 12:00:00'), findsOneWidget);
    expect(
      find.text(
        BattlePassStrings.newMissionsAtWall(
          formatWallTime(DateTime.utc(2026, 9, 30), t0, messages: tl),
        ),
      ),
      findsOneWidget,
    );
    await unmount(tester);
  });

  testWidgets('weekly done but dailies left; free account; no missions', (
    tester,
  ) async {
    await _pump(
      tester,
      bpApi(
        premium: const [],
        contracts: contractsJson(
          missions: [
            activeMission(Bp.missionUlt, Bp.objUlt, 15, complete: true),
          ],
        ),
      ),
    );
    expect(find.text(BattlePassStrings.allWeeklyDone), findsOneWidget);
    expect(find.text(BattlePassStrings.free.toUpperCase()), findsWidgets);
    expect(find.text(BattlePassStrings.premium.toUpperCase()), findsNothing);
    await unmount(tester);

    await _pump(
      tester,
      bpApi(contracts: contractsJson(missions: const [], weeklyRefill: null)),
    );
    expect(find.text(BattlePassStrings.noWeeklyMissions), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('loading skeleton while content loads', (tester) async {
    final never = Completer<ContentDb>();
    await _pump(tester, bpApi(), loadContent: () => never.future);
    expect(find.byType(BattlePassSkeleton), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('error with "Thử lại" refetches', (tester) async {
    final api = bpApi(contractsError: const TransientException(status: 503));
    await _pump(tester, api);
    expect(find.text(CommonStrings.retry), findsOneWidget);
    when(() => api.contracts(any())).thenAnswer((_) async => contractsJson());
    await tester.tap(find.text(CommonStrings.retry));
    await settle(tester);
    expect(find.text('Cấp 46 / 55'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('missing daily ticket offers a user-initiated renew', (
    tester,
  ) async {
    final api = bpApi(ticketError: const NotFoundException());
    await _pump(tester, api);
    expect(find.text(BattlePassStrings.dailyNotReady), findsOneWidget);
    verifyNever(() => api.renewDailyTicket(any()));

    when(() => api.dailyTicket(any()))
        .thenAnswer((_) async => dailyTicketJson());
    final button = find.text(BattlePassStrings.renewButton);
    await tester.ensureVisible(button);
    await tester.pump();
    await tester.tap(button);
    await settle(tester);
    verify(() => api.renewDailyTicket(Bp.puuid)).called(1);
    expect(find.text(BattlePassStrings.renewDone), findsOneWidget);
    expect(find.byType(DailyCheckpointsCard), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('no current battle pass in the content', (tester) async {
    await _pump(
      tester,
      bpApi(),
      loadContent: () async => bpContent(withBattlePass: false),
    );
    expect(find.text(BattlePassStrings.noBattlePass), findsOneWidget);
    expect(find.text(BattlePassStrings.weeklyMissions), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('no signed-in account', (tester) async {
    await _pump(tester, bpApi(), noAccount: true);
    expect(find.text(CommonStrings.errorNoAccount), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('long strings fit a 320 dp phone with large text', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(tester, bpApi(), size: const Size(320, 640));
    expect(find.text('Cấp 46 / 55'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('light theme, 360 dp and 200 % text: no overflow', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(tester, bpApi(), theme: buildLightTheme());
    expect(tester.takeException(), isNull);
    expect(find.text('Cấp 46 / 55'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byType(WeeklyMissionTile).last,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await settle(tester);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('pull-to-refresh refetches contracts and the ticket', (
    tester,
  ) async {
    final api = bpApi();
    await _pump(tester, api);
    verify(() => api.contracts(Bp.puuid)).called(1);
    verify(() => api.dailyTicket(Bp.puuid)).called(1);
    await tester.fling(find.text('Cấp 46 / 55'), const Offset(0, 400), 1200);
    await settle(tester, 40);
    verify(() => api.contracts(Bp.puuid)).called(1);
    verify(() => api.dailyTicket(Bp.puuid)).called(1);
    await unmount(tester);
  });

  testWidgets('the pass card opens S21', (tester) async {
    await _pump(tester, bpApi());
    expect(
      find.descendant(
        of: find.byType(PassCard).first,
        matching: find.byIcon(Icons.chevron_right),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Cấp 46 / 55'));
    await settle(tester);
    expect(find.byType(BattlePassRewardsScreen), findsOneWidget);
    expect(find.text(BattlePassStrings.rewardsTitle), findsOneWidget);
    await unmount(tester);
  });
}
