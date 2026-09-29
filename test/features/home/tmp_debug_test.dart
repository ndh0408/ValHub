import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/home/providers/home_card_providers.dart';

import 'home_test_env.dart';

void main() {
  testWidgets('debug texts', (tester) async {
    final env = await HomeTestEnv.create(accounts: [homeMe, homeAlt1]);
    final other = homeStoreSummary(wallet: 777);
    await pumpHomeScreen(
      tester,
      env,
      size: const Size(360, 420),
      overrides: [
        ...vmFull(),
        homeStoreSummaryProvider.overrideWith(
          (ref, puuid) => puuid == homeMe.puuid
              ? AsyncData(homeStoreSummary(wallet: 2440))
              : AsyncData(other),
        ),
      ],
    );
    await homePastGate(tester);
    for (final w in tester.widgetList<Text>(find.byType(Text))) {
      final t = w.data ?? w.textSpan?.toPlainText() ?? '';
      // ignore: avoid_print
      print('TEXT: $t');
    }
  });
}
