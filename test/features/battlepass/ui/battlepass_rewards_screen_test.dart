import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/l10n/content_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
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
}) async {
  usePhoneViewport(tester);
  final prefs = await createTestPrefs();
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
    expect(find.text('Mùa 2026 // Phần V'), findsOneWidget);
    expect(find.text('Cấp 46 / 55 · 46/55 đã mở khóa'), findsOneWidget);
    expect(find.text(BattlePassStrings.premium), findsOneWidget);
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
    expect(find.text(BattlePassStrings.premiumHint), findsNothing);

    // Opens on the current chapter (levels 46–50).
    final y = tester.getTopLeft(find.text(BattlePassStrings.chapter(10))).dy;
    expect(y, inInclusiveRange(0, 740));

    final l1 = tester.widget<RewardTile>(_tileWithName('Vandal Reaver'));
    expect(l1.reward.tier.state.name, 'unlocked');
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
    await unmount(tester);
  });

  testWidgets('free accounts see the Premium hint and locks', (tester) async {
    await _pump(tester, bpApi(premium: const []));
    expect(find.text(BattlePassStrings.premiumHint), findsOneWidget);
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
