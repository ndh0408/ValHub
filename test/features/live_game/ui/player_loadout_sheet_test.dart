import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/live_game/live_game_strings.dart';
import 'package:valvn/features/live_game/player_loadout_sheet.dart';

import '../live_game_test_env.dart';

void main() {
  late LiveTestEnv env;

  setUpAll(registerLiveFallbacks);

  setUp(() async {
    env = await LiveTestEnv.create();
  });

  Future<void> pumpLoadout(
    WidgetTester tester, {
    String player = me,
    bool pregame = false,
    double width = 360,
    double textScale = 1,
    ThemeData? theme,
  }) async {
    await pumpLive(
      tester,
      env,
      PlayerLoadoutSheet(
        matchId: liveMatchId,
        playerPuuid: player,
        pregame: pregame,
        playerName: 'Tôi#VN1',
      ),
      width: width,
      textScale: textScale,
      theme: theme,
    );
    await settle(tester);
  }

  testWidgets('skins with buddies, card title and sprays', (tester) async {
    await pumpLoadout(tester);
    expect(find.text('Trang bị của Tôi#VN1'), findsOneWidget);
    expect(find.text('Vũ khí'), findsOneWidget);
    expect(find.text('Vandal Reaver'), findsOneWidget);
    expect(find.text('Vandal'), findsOneWidget);
    expect(find.text('Hình phun sơn'), findsOneWidget);
    expect(find.text('Tài Lộc'), findsOneWidget);
    expect(find.text('Jett'), findsOneWidget);
    verify(() => env.api.coreGameLoadouts(me, liveMatchId)).called(1);
    verifyNever(() => env.api.pregameLoadouts(any(), any()));
  });

  testWidgets('agent select reads the pregame loadouts', (tester) async {
    await pumpLoadout(tester, pregame: true);
    verify(() => env.api.pregameLoadouts(me, liveMatchId)).called(1);
    expect(
      find.text('Không có thông tin trang bị của người chơi này.'),
      findsOneWidget,
    );
  });

  testWidgets('player missing from the loadouts → empty state', (tester) async {
    await pumpLoadout(tester, player: enemy1);
    expect(
      find.text('Không có thông tin trang bị của người chơi này.'),
      findsOneWidget,
    );
  });

  testWidgets('errors offer "Thử lại"', (tester) async {
    when(() => env.api.coreGameLoadouts(any(), any()))
        .thenThrow(const TransientException(reason: 'network'));
    await pumpLoadout(tester);
    expect(find.text('Thử lại'), findsOneWidget);
    when(() => env.api.coreGameLoadouts(any(), any()))
        .thenAnswer((_) async => coreLoadoutsJson());
    await tester.tap(find.text('Thử lại'));
    await settle(tester);
    expect(find.text('Vandal Reaver'), findsOneWidget);
  });

  testWidgets('no overflow at 320 dp with 130 % text', (tester) async {
    await pumpLoadout(tester, width: 320, textScale: 1.3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('says where the loadout comes from', (tester) async {
    await pumpLoadout(tester);
    expect(find.text(LiveGameStrings.loadoutFromMatch), findsOneWidget);
    await pumpLoadout(tester, pregame: true);
    expect(find.text(LiveGameStrings.loadoutFromAgentSelect), findsOneWidget);
  });

  testWidgets('fits 360 dp at 200 % text, dark and light', (tester) async {
    await pumpLoadout(tester, textScale: 2);
    expect(tester.takeException(), isNull);
    await pumpLoadout(tester, textScale: 2, theme: buildLightTheme());
    expect(tester.takeException(), isNull);
    expect(find.text('Vandal Reaver'), findsOneWidget);
  });
}
