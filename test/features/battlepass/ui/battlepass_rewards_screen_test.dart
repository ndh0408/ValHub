import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/l10n/content_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/battlepass/battlepass_routes.dart';
import 'package:valvn/features/battlepass/battlepass_strings.dart';
import 'package:valvn/features/battlepass/ui/battlepass_rewards_screen.dart';
import 'package:valvn/features/battlepass/ui/widgets/overview_bits.dart';
import 'package:valvn/features/battlepass/ui/widgets/reward_tile.dart';
import 'package:valvn/features/skin_detail/skin_detail_sheet.dart';

import '../../../helpers/test_prefs.dart';
import '../bp_fixtures.dart';
import '../bp_test_harness.dart';

Future<void> _pump(
  WidgetTester tester,
  MockPvpApi api, {
  String location = BattlePassRoutes.rewards,
  Future<ContentDb> Function()? loadContent,
  List<int>? misses,
  Prefs? prefs,
}) async {
  usePhoneViewport(tester);
  prefs ??= await createTestPrefs();
  await tester.pumpWidget(
    bpApp(
      initialLocation: location,
      overrides: bpOverrides(
        api: api,
        prefs: prefs,
        loadContent: loadContent,
        misses: misses,
      ),
    ),
  );
  await settle(tester);
  // Scroll-to-current-chapter animation.
  await tester.pump(const Duration(milliseconds: 400));
}

Finder _tileWithName(String name) =>
    find.ancestor(of: find.text(name), matching: find.byType(RewardTile));

void main() {
  testWidgets('S21 chapters, epilogue, free tags and states', (tester) async {
    await _pump(tester, bpApi());

    expect(find.text(BattlePassStrings.rewardsTitle), findsOneWidget);
    // The summary card is its own sliver, scrolled away when the screen
    // opens on the current chapter.
    expect(
      find.text('Mùa 2026 // Phần V', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Cấp 46 / 55 · 46/55 đã mở khóa', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text(BattlePassStrings.premium, skipOffstage: false),
      findsOneWidget,
    );
    for (var n = 1; n <= 10; n++) {
      expect(find.text(BattlePassStrings.chapter(n)), findsOneWidget);
    }
    expect(find.text(BattlePassStrings.epilogue), findsOneWidget);
    // 55 premium tiers + 2 free rewards in each of the 10 chapters.
    expect(find.byType(RewardTile), findsNWidgets(75));
    expect(find.text(BattlePassStrings.free), findsNWidgets(20));
    expect(find.text(BattlePassStrings.currentChapter), findsOneWidget);
    expect(find.text('Vandal Reaver'), findsOneWidget);
    expect(find.text(BattlePassStrings.levelShort(1)), findsOneWidget);
    expect(find.text(ContentStrings.currencyRpFull), findsWidgets);
    expect(find.text(ContentStrings.currencyKcFull), findsNWidgets(10));
    expect(
      find.text(BattlePassStrings.premiumHint, skipOffstage: false),
      findsNothing,
    );

    // Opens on the current chapter (levels 46–50).
    final y = tester.getTopLeft(find.text(BattlePassStrings.chapter(10))).dy;
    expect(y, inInclusiveRange(0, 740));

    final l1 = tester.widget<RewardTile>(_tileWithName('Vandal Reaver'));
    expect(l1.reward.tier.state.name, 'unlocked');
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
    await unmount(tester);
  });

  testWidgets('reward filter narrows the grid and is remembered', (
    tester,
  ) async {
    final prefs = await createTestPrefs();
    await _pump(tester, bpApi(), prefs: prefs);
    expect(find.byType(RewardTile), findsNWidgets(75));

    await tester.tap(find.text(BattlePassStrings.filterUnlocked));
    await settle(tester);
    await tester.pump(const Duration(milliseconds: 400));
    final unlocked = find.byType(RewardTile).evaluate().length;
    expect(unlocked, inExclusiveRange(0, 75));
    for (final e in find.byType(RewardTile).evaluate()) {
      expect((e.widget as RewardTile).reward.tier.isUnlocked, isTrue);
    }
    expect(prefs.getString('ui.$kRewardsFilterMemoryKey'), 'unlocked');

    // Reopening the screen keeps the filter.
    await unmount(tester);
    await _pump(tester, bpApi(), prefs: prefs);
    expect(find.byType(RewardTile).evaluate().length, unlocked);

    await tester.tap(find.text(BattlePassStrings.filterAll));
    await settle(tester);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(RewardTile), findsNWidgets(75));
    await unmount(tester);
  });

  testWidgets('free accounts see the Premium hint and locks', (tester) async {
    await _pump(tester, bpApi(premium: const []));
    expect(
      find.text(BattlePassStrings.premiumHint, skipOffstage: false),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.lock), findsWidgets);
    final l1 = tester.widget<RewardTile>(_tileWithName('Vandal Reaver'));
    expect(l1.reward.tier.state.name, 'needsPremium');
    await unmount(tester);
  });

  testWidgets('tapping a non-skin reward shows a preview', (tester) async {
    await _pump(tester, bpApi());
    final tile = find.byType(RewardTile).at(1); // level 2: gun buddy
    await tester.ensureVisible(tile);
    await tester.pump();
    await tester.tap(tile);
    await settle(tester);
    expect(find.byType(RewardPreviewSheet), findsOneWidget);
    // Sheet chrome: level, type, track and state rows plus the close button.
    expect(find.text(BattlePassStrings.rewardLevelLabel), findsOneWidget);
    expect(find.text(BattlePassStrings.rewardTrackLabel), findsOneWidget);
    expect(find.text(BattlePassStrings.rewardStatusLabel), findsOneWidget);
    expect(find.byTooltip(CommonStrings.close), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('the next reward to unlock is marked', (tester) async {
    await _pump(tester, bpApi());
    // Level 46 reached: level 47 is next, in the current chapter.
    expect(find.text(BattlePassStrings.nextReward), findsOneWidget);
    final next = tester.widget<RewardTile>(
      find.ancestor(
        of: find.text(BattlePassStrings.nextReward),
        matching: find.byType(RewardTile),
      ),
    );
    expect(next.reward.tier.level, 47);
    await unmount(tester);
  });

  testWidgets('fits 360 dp at 200 % text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(tester, bpApi());
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('tapping a skin opens S15', (tester) async {
    await _pump(tester, bpApi());
    final tile = _tileWithName('Vandal Reaver');
    await tester.ensureVisible(tile);
    await tester.pump();
    await tester.tap(tile);
    await settle(tester);
    expect(find.byType(SkinDetailSheet), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('event pass via ?contract=', (tester) async {
    await _pump(
      tester,
      bpApi(),
      location: BattlePassRoutes.rewardsFor(Bp.eventPassId),
    );
    expect(find.text('Champions 2026: Shanghai'), findsWidgets);
    expect(find.text(BattlePassStrings.chapter(1)), findsOneWidget);
    expect(find.text(BattlePassStrings.epilogue), findsOneWidget);
    expect(find.text(BattlePassStrings.chapter(2)), findsNothing);
    await unmount(tester);
  });

  testWidgets('unknown contract → empty state', (tester) async {
    await _pump(tester, bpApi(), location: BattlePassRoutes.rewardsFor('x'));
    expect(find.text(BattlePassStrings.noRewards), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('loading skeleton, then error with "Thử lại"', (tester) async {
    final never = Completer<ContentDb>();
    await _pump(tester, bpApi(), loadContent: () => never.future);
    expect(find.byType(RewardsSkeleton), findsOneWidget);
    await unmount(tester);

    final api = bpApi(contractsError: const MaintenanceException());
    await _pump(tester, api);
    expect(find.text(CommonStrings.retry), findsOneWidget);
    when(() => api.contracts(any())).thenAnswer((_) async => contractsJson());
    await tester.tap(find.text(CommonStrings.retry));
    await settle(tester);
    expect(find.text(BattlePassStrings.epilogue), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('rewards missing from the content are reported', (tester) async {
    final misses = [0];
    await _pump(
      tester,
      bpApi(),
      misses: misses,
      loadContent: () async =>
          bpContent(skinLevel: '00000000-dead-beef-0000-000000000000'),
    );
    expect(find.text(CommonStrings.unknownItem), findsOneWidget);
    expect(misses[0], 1);
    await unmount(tester);
  });
}
