import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/features/profile/profile_routes.dart';
import 'package:valvn/features/profile/profile_strings.dart';
import 'package:valvn/features/profile/ui/match_detail_screen.dart';
import 'package:valvn/features/profile/ui/widgets/profile_widgets.dart';

import '../profile_test_env.dart';

void main() {
  setUpAll(registerProfileFallbacks);

  late ProfileTestEnv env;

  setUp(() async {
    env = await ProfileTestEnv.create();
  });

  testWidgets('competitive: header, your summary and both teams', (
    tester,
  ) async {
    await env.history.merge(me, [
      CompetitiveUpdate.fromJson(
        updateRow(compMatch, start: DateTime.utc(2026, 9, 28, 4), earned: 24),
      )!,
    ]);
    await pumpProfile(
      tester,
      env,
      const MatchDetailScreen(matchId: compMatch),
      height: 2000,
    );
    await settle(tester);

    // Header: map (also the art placeholder's caption in tests), score,
    // result.
    expect(find.text('ASCENT'), findsWidgets);
    expect(find.text(ProfileStrings.score(2, 1)), findsOneWidget);
    expect(find.byType(OutcomeTag), findsWidgets);
    expect(find.text(CompetitiveStrings.victory), findsWidgets);

    // Summary: K/D/A, ACS, HS%, ADR, first bloods and +24 RR.
    expect(find.text(ProfileStrings.yourSummary), findsOneWidget);
    expect(find.text(ProfileStrings.kdaLabel), findsOneWidget);
    expect(find.text(ProfileStrings.adr), findsOneWidget);
    expect(find.text(ProfileStrings.firstBloods), findsOneWidget);
    expect(find.text('+24 RR'), findsOneWidget);

    // Scoreboard: your team first, names resolved via name-service.
    expect(find.text(ProfileStrings.yourTeam), findsOneWidget);
    expect(find.text(ProfileStrings.enemyTeam), findsOneWidget);
    expect(find.text('Đồng Đội'), findsOneWidget);
    expect(find.text('Đối Thủ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('round timeline tab lists every round', (tester) async {
    await pumpProfile(
      tester,
      env,
      const MatchDetailScreen(matchId: compMatch),
      height: 2000,
    );
    await settle(tester);

    await tester.tap(find.text(ProfileStrings.roundTimeline));
    await settle(tester);

    expect(find.text(ProfileStrings.firstHalf), findsOneWidget);
    expect(find.text(CompetitiveStrings.roundElimination), findsOneWidget);
    expect(find.text(CompetitiveStrings.roundDetonate), findsOneWidget);
    expect(find.text(CompetitiveStrings.roundDefuse), findsOneWidget);
    // Running score after the last round.
    expect(find.text(ProfileStrings.score(2, 1)), findsWidgets);
    // Ceremony of round 3 from valorant-api vi-VN.
    expect(find.text('NGƯỜI HẠ MÀN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deathmatch: one ranked list, kills score, no round tab', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      env,
      const MatchDetailScreen(matchId: dmMatch),
      height: 2000,
    );
    await settle(tester);

    expect(find.text(ProfileStrings.allPlayers), findsOneWidget);
    expect(find.text(ProfileStrings.roundTimeline), findsNothing);
    // Your kills vs the best other player's kills (R12).
    expect(find.text(ProfileStrings.score(25, 40)), findsOneWidget);
    expect(find.text(ProfileStrings.placement(2)), findsOneWidget);
    expect(find.text(CompetitiveStrings.defeat), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a match still being processed says so and can retry', (
    tester,
  ) async {
    var calls = 0;
    when(() => env.api.matchDetails(any(), any())).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw const NotFoundException();
      return competitiveFixtureMap('match_competitive');
    });
    await pumpProfile(
      tester,
      env,
      const MatchDetailScreen(matchId: compMatch),
      height: 2000,
    );
    await settle(tester);
    expect(find.text(CompetitiveStrings.matchPending), findsOneWidget);

    await tester.tap(find.text(CommonStrings.retry));
    await settle(tester);
    expect(find.text(ProfileStrings.yourSummary), findsOneWidget);
  });

  testWidgets('other errors show the error view', (tester) async {
    when(() => env.api.matchDetails(any(), any()))
        .thenThrow(const TransientException(reason: 'timeout'));
    await pumpProfile(tester, env, const MatchDetailScreen(matchId: compMatch));
    await settle(tester);
    expect(find.text(CommonStrings.errorTimeout), findsOneWidget);
    expect(find.text(CommonStrings.retry), findsOneWidget);
  });

  testWidgets('another player\'s point of view via ?player=', (tester) async {
    await pumpProfileRouter(
      tester,
      env,
      routes: [
        ...profileTopLevelRoutes,
        GoRoute(path: '/', builder: (_, _) => const SizedBox()),
      ],
      initialLocation: ProfileRoutes.matchFullScreen(compMatch, player: mate),
      height: 2000,
    );
    await settle(tester);
    expect(find.text(ProfileStrings.playerSummary), findsOneWidget);
    expect(find.text('Đồng Đội'), findsNWidgets(2));

    // Tapping a scoreboard row opens that player's profile.
    await tester.tap(find.text('Đối Thủ'));
    await settle(tester, frames: 20);
    expect(find.text(ProfileStrings.playerProfileTitle), findsOneWidget);
  });

  testWidgets('incognito player seen live stays anonymous, profile too', (
    tester,
  ) async {
    await MatchPrivacyStore(env.prefs)
        .record(me, compMatch, const MatchPrivacy(incognito: {enemy1}));
    final router = await pumpProfileRouter(
      tester,
      env,
      routes: [
        ...profileTopLevelRoutes,
        GoRoute(path: '/', builder: (_, _) => const SizedBox()),
      ],
      initialLocation: ProfileRoutes.matchFullScreen(compMatch),
      height: 2000,
    );
    await settle(tester);
    expect(find.text('Đối Thủ'), findsNothing);
    expect(find.text('Đồng Đội'), findsOneWidget);
    expect(find.text(CompetitiveStrings.incognitoPlayer), findsOneWidget);
    // Its Riot ID is never looked up.
    final looked = verify(() => env.api.names(any(), captureAny())).captured;
    expect(
      looked.expand((l) => l as Iterable).map((s) => '$s'.toLowerCase()),
      isNot(contains(enemy1)),
    );

    await tester.tap(find.text(CompetitiveStrings.incognitoPlayer));
    await settle(tester, frames: 20);
    expect(find.text(ProfileStrings.playerProfileTitle), findsOneWidget);
    final pushed = router.routerDelegate.currentConfiguration.last;
    expect(
      pushed.matchedLocation,
      ProfileRoutes.player(enemy1).split('?').first,
    );
    // Profile opened with ?hidden=1: no Riot ID, anonymous label.
    expect(find.text('Đối Thủ'), findsNothing);
    expect(find.textContaining('Đối Thủ'), findsNothing);
    expect(find.text(CompetitiveStrings.incognitoPlayer), findsWidgets);
  });
}
