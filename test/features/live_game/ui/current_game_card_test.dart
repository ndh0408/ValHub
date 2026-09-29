import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/live_game/current_game_card.dart';
import 'package:valvn/features/live_game/live_game_sheet.dart';
import 'package:valvn/features/live_game/live_game_strings.dart';

import '../live_game_test_env.dart';

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
      const Padding(padding: EdgeInsets.all(16), child: CurrentGameCard()),
      width: width,
      textScale: textScale,
    );
    await settle(tester);
  }

  testWidgets('not in a match', (tester) async {
    await pumpCard(tester);
    expect(find.text('TRẬN HIỆN TẠI'), findsOneWidget);
    expect(find.text('Không trong trận'), findsOneWidget);
  });

  testWidgets('lobby and queue timer', (tester) async {
    env.loop = 'MENUS';
    await pumpCard(tester);
    expect(find.text('Đang ở sảnh chờ'), findsOneWidget);
  });

  testWidgets('queueing shows mm:ss since the queue started', (tester) async {
    env
      ..loop = 'MENUS'
      ..party = partyJson();
    await pumpCard(tester);
    expect(find.text('Đang tìm trận · 01:32'), findsOneWidget);
  });

  testWidgets('agent select shows the map', (tester) async {
    env
      ..loop = 'PREGAME'
      ..pregame = pregameMatchJson();
    await pumpCard(tester);
    expect(find.text('Đang chọn đặc vụ · Ascent'), findsOneWidget);
  });

  testWidgets('in a match: map and live score', (tester) async {
    env
      ..loop = 'INGAME'
      ..core = coreMatchJson()
      ..presence = scorePresence(env.clock.now());
    await pumpCard(tester);
    expect(find.text('Đang đấu · Ascent · 8 – 4'), findsOneWidget);
  });

  testWidgets('live score hidden when the setting is off', (tester) async {
    await env.prefs.setJson(
      PrefKeys.appSettings,
      const AppSettings(showLiveScore: false).toJson(),
    );
    env
      ..loop = 'INGAME'
      ..core = coreMatchJson()
      ..presence = scorePresence(env.clock.now());
    await pumpCard(tester);
    expect(find.text('Đang đấu · Ascent'), findsOneWidget);
  });

  testWidgets('status error keeps the card usable', (tester) async {
    env.sessionError = Exception('boom');
    await pumpCard(tester);
    expect(find.text('Chưa cập nhật được trạng thái trận'), findsOneWidget);
  });

  testWidgets('tap opens the live-game sheet', (tester) async {
    await pumpCard(tester);
    await tester.tap(find.byType(CurrentGameCard));
    await settle(tester);
    expect(find.byType(LiveGameSheet), findsOneWidget);
    expect(find.text('Bạn không ở trong trận nào'), findsOneWidget);
  });

  testWidgets('no overflow at 320 dp with 130 % text', (tester) async {
    env
      ..loop = 'INGAME'
      ..core = coreMatchJson()
      ..presence = scorePresence(env.clock.now());
    await pumpCard(tester, width: 320, textScale: 1.3);
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Đang đấu'), findsOneWidget);
  });

  testWidgets('a status chip names a running match', (tester) async {
    env
      ..loop = 'INGAME'
      ..core = coreMatchJson();
    await pumpCard(tester);
    expect(find.text(LiveGameStrings.statusInProgress), findsOneWidget);
  });

  testWidgets('a status chip names agent select', (tester) async {
    env
      ..loop = 'PREGAME'
      ..pregame = pregameMatchJson();
    await pumpCard(tester);
    expect(find.text(LiveGameStrings.statusAgentSelect), findsOneWidget);
  });

  testWidgets('no chip outside a match', (tester) async {
    await pumpCard(tester);
    expect(find.text(LiveGameStrings.statusInProgress), findsNothing);
    expect(find.text(LiveGameStrings.statusAgentSelect), findsNothing);
  });

  testWidgets('fits 320 dp at 200 % text on the light theme', (tester) async {
    env
      ..loop = 'INGAME'
      ..core = coreMatchJson()
      ..presence = scorePresence(env.clock.now());
    await pumpLive(
      tester,
      env,
      const Padding(padding: EdgeInsets.all(16), child: CurrentGameCard()),
      width: 320,
      textScale: 2,
      theme: buildLightTheme(),
    );
    await settle(tester);
    expect(tester.takeException(), isNull);
  });
}
