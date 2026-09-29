import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/features/profile/profile_routes.dart';
import 'package:valvn/features/profile/profile_strings.dart';
import 'package:valvn/features/profile/ui/player_profile_screen.dart';
import 'package:valvn/features/profile/ui/widgets/match_card.dart';
import 'package:valvn/features/profile/ui/widgets/rank_card.dart';

import '../profile_test_env.dart';

void main() {
  setUpAll(registerProfileFallbacks);

  late ProfileTestEnv env;

  setUp(() async {
    env = await ProfileTestEnv.create();
    env.historyByQueue[null] = {
      'Subject': enemy1,
      'Total': 1,
      'History': [
        {
          'MatchID': compMatch,
          'GameStartTime': 1790568000000,
          'QueueID': 'competitive',
        },
      ],
    };
  });

  testWidgets('another player: name, level, rank and recent matches', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      env,
      const PlayerProfileScreen(puuid: enemy1),
      height: 1800,
    );
    await settle(tester, frames: 12);

    expect(find.text(ProfileStrings.playerProfileTitle), findsOneWidget);
    expect(find.textContaining('Đối Thủ'), findsWidgets);
    expect(find.byType(RankCard), findsOneWidget);
    expect(find.text(ProfileStrings.currentRank), findsOneWidget);
    expect(find.text(ProfileStrings.recentMatches), findsOneWidget);
    expect(find.byType(MatchCard), findsOneWidget);
    // Their side lost 1 – 2.
    expect(find.text(ProfileStrings.score(1, 2)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('incognito players stay anonymous', (tester) async {
    await pumpProfile(
      tester,
      env,
      const PlayerProfileScreen(puuid: enemy1, hideName: true),
      height: 1800,
    );
    await settle(tester, frames: 12);
    expect(find.text(CompetitiveStrings.incognitoPlayer), findsOneWidget);
    expect(find.textContaining('#0001'), findsNothing);
  });

  testWidgets('own account uses the account XP header', (tester) async {
    await pumpProfile(
      tester,
      env,
      const PlayerProfileScreen(puuid: me),
      height: 1800,
    );
    await settle(tester, frames: 12);
    expect(find.text(ProfileStrings.level(222)), findsOneWidget);
    expect(find.textContaining('Tôi'), findsWidgets);
  });

  testWidgets('route parses ?hidden=1 and opens matches above the tab bar', (
    tester,
  ) async {
    final router = await pumpProfileRouter(
      tester,
      env,
      routes: [
        ...profileTopLevelRoutes,
        GoRoute(path: '/', builder: (_, _) => const SizedBox()),
      ],
      initialLocation: ProfileRoutes.player(enemy1, hidden: true),
      height: 1800,
    );
    await settle(tester, frames: 12);
    expect(find.text(CompetitiveStrings.incognitoPlayer), findsOneWidget);

    await tester.tap(find.byType(MatchCard));
    await settle(tester, frames: 20);
    // The detail shows the match from this player's side (they lost).
    expect(find.text(ProfileStrings.matchDetailTitle), findsOneWidget);
    expect(find.text(ProfileStrings.playerSummary), findsOneWidget);
    expect(find.text(CompetitiveStrings.defeat), findsWidgets);
    router.pop();
    await settle(tester, frames: 20);
    expect(find.text(ProfileStrings.playerProfileTitle), findsOneWidget);
  });

  testWidgets('a long Vietnamese name does not overflow at 360 dp', (
    tester,
  ) async {
    env = await ProfileTestEnv.create(
      accounts: const [
        Account(
          puuid: me,
          gameName: 'Người Chơi Có Cái Tên Rất Là Dài Dòng',
          tagLine: 'VIỆTNAM',
          region: 'ap',
          shard: 'ap',
        ),
      ],
    );
    await pumpProfile(
      tester,
      env,
      const PlayerProfileScreen(puuid: me),
      height: 1800,
    );
    await settle(tester, frames: 12);
    expect(tester.takeException(), isNull);
    expect(find.text(CommonStrings.errorNotFound), findsNothing);
  });
}
