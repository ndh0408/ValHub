import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/home/home_strings.dart';
import 'package:valvn/features/home/ui/cards/live_home_card.dart';
import 'package:valvn/features/home/ui/home_card_frame.dart';
import 'package:valvn/features/live_game/live_game_sheet.dart';
import 'package:valvn/features/live_game/live_game_strings.dart';
import 'package:valvn/features/live_game/ui/live_widgets.dart';

import '../../live_game/live_game_test_env.dart';

void main() {
  late LiveTestEnv env;

  setUpAll(registerLiveFallbacks);

  setUp(() async {
    env = await LiveTestEnv.create();
  });

  Future<void> pumpCard(
    WidgetTester tester, {
    double width = 360,
    double textScale = 1,
  }) async {
    await pumpLive(
      tester,
      env,
      const Padding(
        padding: EdgeInsets.all(16),
        child: LiveHomeCard(puuid: me),
      ),
      width: width,
      textScale: textScale,
    );
    await settle(tester);
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 30));
  }

  testWidgets('hidden when the game is not running and in the lobby', (
    tester,
  ) async {
    await pumpCard(tester);
    expect(find.byType(HomeCardFrame), findsNothing);

    env.loop = 'MENUS';
    await unmount(tester);
    await pumpCard(tester);
    expect(find.byType(HomeCardFrame), findsNothing);
    await unmount(tester);
  });

  testWidgets('queueing shows the ticking timer', (tester) async {
    env
      ..loop = 'MENUS'
      ..party = partyJson();
    await pumpCard(tester);

    expect(find.text(HomeStrings.cardLive), findsOneWidget);
    expect(find.text('Đang tìm trận · 01:32'), findsOneWidget);

    env.clock.advance(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Đang tìm trận · 01:33'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('agent select: pill, map, my agent and the countdown', (
    tester,
  ) async {
    env
      ..loop = 'PREGAME'
      ..pregame = pregameMatchJson(myAgent: jett, myState: 'selected');
    await pumpCard(tester);

    expect(find.text(LiveGameStrings.statusAgentSelect), findsOneWidget);
    expect(find.text('Ascent'), findsOneWidget);
    expect(find.text(LiveGameStrings.youHover('Jett')), findsOneWidget);
    expect(find.text(LiveGameStrings.timeLeft('0:42')), findsOneWidget);

    // A second later the countdown moved on.
    env.clock.advance(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(LiveGameStrings.timeLeft('0:41')), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a locked agent says so', (tester) async {
    env
      ..loop = 'PREGAME'
      ..pregame = pregameMatchJson(myAgent: jett, myState: 'locked');
    await pumpCard(tester);
    expect(find.text(LiveGameStrings.youLocked('Jett')), findsOneWidget);
    await unmount(tester);
  });

  group('in a match', () {
    setUp(() {
      env
        ..loop = 'INGAME'
        ..core = coreMatchJson();
    });

    testWidgets('shows the score with team labels when it is fresh', (
      tester,
    ) async {
      env.presence = scorePresence(env.clock.now());
      await pumpCard(tester);

      expect(find.text(LiveGameStrings.statusInProgress), findsOneWidget);
      expect(find.text('Ascent'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      // Never colour alone: the teams are named.
      expect(find.text(HomeStrings.liveAllyLabel), findsOneWidget);
      expect(find.text(HomeStrings.liveEnemyLabel), findsOneWidget);
      expect(find.byType(LiveRefreshRing), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('no score when the setting is off', (tester) async {
      await env.prefs.setJson(
        PrefKeys.appSettings,
        const AppSettings(showLiveScore: false).toJson(),
      );
      env.presence = scorePresence(env.clock.now());
      await pumpCard(tester);
      expect(find.text(LiveGameStrings.statusInProgress), findsOneWidget);
      expect(find.text(HomeStrings.liveAllyLabel), findsNothing);
      await unmount(tester);
    });

    testWidgets('no score when the presence is stale or 0 – 0', (tester) async {
      env.presence = scorePresence(
        env.clock.now().subtract(const Duration(minutes: 5)),
      );
      await pumpCard(tester);
      expect(find.text(HomeStrings.liveAllyLabel), findsNothing);
      await unmount(tester);

      env.presence = scorePresence(env.clock.now(), ally: 0, enemy: 0);
      await pumpCard(tester);
      expect(find.text(HomeStrings.liveAllyLabel), findsNothing);
      await unmount(tester);
    });
  });

  testWidgets('a tap opens the match sheet; Home has no lock or quit', (
    tester,
  ) async {
    env
      ..loop = 'PREGAME'
      ..pregame = pregameMatchJson(myAgent: jett, myState: 'selected');
    await pumpCard(tester);
    expect(find.text(LiveGameStrings.quitMatch), findsNothing);

    await tester.tap(find.text(HomeStrings.cardLive));
    await settle(tester);
    expect(find.byType(LiveGameSheet), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 30));
  });

  testWidgets('no overflow at 320 dp with 200 % text in every phase', (
    tester,
  ) async {
    env.presence = scorePresence(env.clock.now());
    for (final setup in <void Function()>[
      () => env
        ..loop = 'MENUS'
        ..party = partyJson(),
      () => env
        ..loop = 'PREGAME'
        ..pregame = pregameMatchJson(myAgent: jett, myState: 'locked'),
      () => env
        ..loop = 'INGAME'
        ..core = coreMatchJson(),
    ]) {
      setup();
      await pumpCard(tester, width: 320, textScale: 2);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    }
  });
}
