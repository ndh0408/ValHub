import '../../helpers/l10n.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/domain/economy/store_history.dart';
import 'package:valvn/core/ui/skin_art_card.dart';
import 'package:valvn/features/store/ui/store_history_screen.dart';

import '../../core/domain/economy/economy_fixtures.dart';
import '../../helpers/test_prefs.dart';
import 'store_test_harness.dart';

StoreHistoryDay _day(int d, List<String> levels, {int nightOffers = 0}) {
  final at = DateTime.utc(2026, 9, d, 8);
  return StoreHistoryDay(
    key: 'utc:2026-09-$d',
    firstSeen: at,
    lastSeen: at,
    daily: [
      for (final l in levels) HistoryDailyOffer(skinLevelUuid: l, vp: 1775),
    ],
    nightMarket: [
      for (var i = 0; i < nightOffers; i++)
        HistoryNightOffer(
          skinLevelUuid: Fx.aresPrismL1,
          bonusOfferId: 'run-$d-$i',
          percent: 20 + i,
        ),
    ],
  );
}

void main() {
  Future<void> pump(WidgetTester tester, StoreHistory history) async {
    usePhoneViewport(tester, size: const Size(360, 1400));
    final prefs = await createTestPrefs();
    await tester.pumpWidget(
      testApp(
        overrides: [
          ...storeOverrides(api: MockPvpApi(), prefs: prefs),
          storeHistoryProvider.overrideWith((ref, puuid) async => history),
        ],
        home: const StoreHistoryScreen(),
      ),
    );
    await settle(tester);
  }

  testWidgets('recorded days, newest first, with the most offered skins', (
    tester,
  ) async {
    await pump(
      tester,
      StoreHistory(
        days: [
          _day(26, [Fx.aresPrismL1, Fx.magepunkL1]),
          _day(27, [Fx.aresPrismL1, Fx.operatorL1], nightOffers: 2),
        ],
      ),
    );
    expect(find.text(tl.storeHistoryTitle), findsWidgets);
    expect(
      find.textContaining(
        tl.storeHistorySince('', 2).split(' · ').first.trim(),
      ),
      findsOneWidget,
    );
    expect(find.text(tl.storeHistoryMostOffered.toUpperCase()), findsOneWidget);
    expect(find.text(tl.storeHistoryTimes(2)), findsOneWidget);
    expect(find.byType(SkinArtCard), findsNWidgets(4));
    expect(find.textContaining(tl.storeHistoryNightMarket(2)), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('nothing recorded yet explains where the history comes from', (
    tester,
  ) async {
    await pump(tester, StoreHistory());
    expect(find.text(tl.storeHistoryEmpty), findsOneWidget);
    expect(find.byType(SkinArtCard), findsNothing);
    await unmount(tester);
  });
}
