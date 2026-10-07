import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/xmpp/xmpp_providers.dart';
import 'package:valvn/features/community/providers/lfg_providers.dart'
    show kLfgRefreshInterval;
import 'package:valvn/features/community/ui/lfg/lfg_poster_sync.dart';

import '../community_test_env.dart';

/// The app as the OS reports it: in the background.
class _Background extends AppForegroundNotifier {
  @override
  bool build() => false;
}

void main() {
  late CommunityTestEnv env;

  setUp(() async {
    env = await CommunityTestEnv.create();
    env.server.json('GET /v1/lfg/mine', lfgJson('mine'));
    when(() => env.pvp.partyPlayer(any())).thenAnswer((_) async => {});
  });

  Future<void> pumpSync(WidgetTester tester) async {
    await pumpCommunity(
      tester,
      env,
      const LfgPosterSync(account: meAccount, child: SizedBox()),
    );
    // Two refresh intervals: at least one tick runs.
    for (var i = 0; i < 3; i++) {
      await tester.pump(kLfgRefreshInterval);
    }
  }

  testWidgets('the open app keeps reading the party for the post', (
    tester,
  ) async {
    await pumpSync(tester);
    verify(() => env.pvp.partyPlayer(mePuuid)).called(greaterThan(0));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'a backgrounded app neither reads the party nor renews the post',
    (tester) async {
      env.extraOverrides = [
        appForegroundProvider.overrideWith(_Background.new),
      ];
      await pumpSync(tester);
      verifyNever(() => env.pvp.partyPlayer(any()));
      expect(env.server.calls('PATCH /v1/lfg/mine'), isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
