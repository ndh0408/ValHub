import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/live_game/live_game_overlay_host.dart';
import 'package:valvn/features/live_game/live_game_sheet.dart';
import 'package:valvn/features/live_game/providers/live_game_providers.dart';

import '../live_game_test_env.dart';

void main() {
  late LiveTestEnv env;

  setUpAll(registerLiveFallbacks);

  setUp(() async {
    env = await LiveTestEnv.create();
  });

  Future<void> pumpHost(WidgetTester tester) async {
    await pumpLive(
      tester,
      env,
      const LiveGameOverlayHost(child: Center(child: Text('tab'))),
    );
    await settle(tester);
  }

  Future<void> nextPoll(WidgetTester tester) async {
    await tester.pump(kLivePollSlow + const Duration(seconds: 1));
    await settle(tester, frames: 10);
  }

  testWidgets('polls in the background of the tabs', (tester) async {
    await pumpHost(tester);
    expect(find.text('tab'), findsOneWidget);
    verify(() => env.api.gameSession(me)).called(1);
    await nextPoll(tester);
    verify(() => env.api.gameSession(me)).called(1);
  });

  testWidgets('opens the sheet when a match is found (lobby → pregame)', (
    tester,
  ) async {
    env
      ..loop = 'MENUS'
      ..party = partyJson();
    await pumpHost(tester);
    expect(find.byType(LiveGameSheet), findsNothing);

    env
      ..loop = 'PREGAME'
      ..party = null
      ..pregame = pregameMatchJson();
    await nextPoll(tester);
    expect(find.byType(LiveGameSheet), findsOneWidget);
    expect(find.text('Đang chọn đặc vụ'), findsOneWidget);
    // Opening the sheet never changes anything on the account.
    verifyNever(() => env.api.pregameSelectAgent(any(), any(), any()));
    verifyNever(() => env.api.pregameLockAgent(any(), any(), any()));
    verifyNever(() => env.api.pregameQuit(any(), any()));
  });

  testWidgets('does nothing when the setting is off', (tester) async {
    await env.prefs.setJson(
      PrefKeys.appSettings,
      const AppSettings(autoOpenLiveGame: false).toJson(),
    );
    env.loop = 'MENUS';
    await pumpHost(tester);
    env
      ..loop = 'PREGAME'
      ..pregame = pregameMatchJson();
    await nextPoll(tester);
    expect(find.byType(LiveGameSheet), findsNothing);
  });

  testWidgets('not when the app starts during agent select', (tester) async {
    env
      ..loop = 'PREGAME'
      ..pregame = pregameMatchJson();
    await pumpHost(tester);
    await nextPoll(tester);
    expect(find.byType(LiveGameSheet), findsNothing);
  });

  testWidgets('no account → no polling', (tester) async {
    env = await LiveTestEnv.create(accounts: const []);
    await pumpHost(tester);
    verifyNever(() => env.api.gameSession(any()));
  });
}
