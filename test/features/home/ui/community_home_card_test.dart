import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/features/community/community_previews.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/home/home_strings.dart';
import 'package:valvn/features/home/providers/home_refresh.dart';
import 'package:valvn/features/home/ui/cards/community_home_card.dart';
import 'package:valvn/features/home/ui/home_card_frame.dart';
import 'package:valvn/features/skin_detail/skin_detail_sheet.dart';

import '../home_test_env.dart';

Widget _card() => const CommunityHomeCard(puuid: Fx.puuid);

void main() {
  late HomeTestEnv env;

  setUp(() async {
    env = await HomeTestEnv.create();
  });

  testWidgets('two LFG rows and three hot skins with votes', (tester) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmCommunity(AsyncData(homeCommunitySnapshot()))],
    );
    expect(find.text(HomeStrings.cardCommunity), findsOneWidget);
    expect(find.text(HomeStrings.lfgTitle), findsOneWidget);
    expect(find.text('Đồng Đội Một#VN9'), findsOneWidget);
    expect(find.text('Đồng Đội Hai#VN9'), findsOneWidget);
    // Mode, spots needed and the time left of the first post.
    expect(
      find.textContaining(CommunityStrings.modeLabel('competitive')),
      findsWidgets,
    );
    expect(find.textContaining(HomeStrings.lfgNeeds(2)), findsOneWidget);
    expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);

    expect(find.text(HomeStrings.trendingTitle), findsOneWidget);
    expect(find.text(HomeStrings.trendingVotes(120)), findsOneWidget);
    expect(find.text(HomeStrings.trendingVotes(90)), findsOneWidget);
    expect(find.text(HomeStrings.trendingVotes(45)), findsOneWidget);
    homeExpectNoException(tester);
    await homeUnmount(tester);
  });

  testWidgets('wishlisted trending skins carry a heart', (tester) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [
        vmCommunity(
          AsyncData(
            homeCommunitySnapshot(lfg: false, wishlist: {Fx.reaverVandal}),
          ),
        ),
      ],
    );
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    // Only the skins section is shown.
    expect(find.text(HomeStrings.lfgTitle), findsNothing);
    await homeUnmount(tester);
  });

  testWidgets('taps: LFG and ranking open the Community tab, skins a sheet', (
    tester,
  ) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmCommunity(AsyncData(homeCommunitySnapshot()))],
    );

    await tester.tap(find.text('Đồng Đội Một#VN9'));
    await homeSettle(tester);
    expect(find.text('route /community?section=lfg'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing, reason: 'a tab switch');
    await homeUnmount(tester);

    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmCommunity(AsyncData(homeCommunitySnapshot()))],
    );
    await tester.tap(find.text(HomeStrings.openLfg));
    await homeSettle(tester);
    expect(find.text('route /community?section=lfg'), findsOneWidget);
    await homeUnmount(tester);

    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmCommunity(AsyncData(homeCommunitySnapshot()))],
    );
    await tester.tap(find.text(HomeStrings.openRanking));
    await homeSettle(tester);
    expect(find.text('route /community?section=skins'), findsOneWidget);
    await homeUnmount(tester);

    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmCommunity(AsyncData(homeCommunitySnapshot()))],
    );
    await tester.tap(find.text(HomeStrings.trendingVotes(120)));
    await homeSettle(tester);
    expect(find.byType(SkinDetailSheet), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('there is no way to join a party from Home', (tester) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmCommunity(AsyncData(homeCommunitySnapshot()))],
    );
    expect(find.byType(FilledButton), findsNothing);
    expect(find.textContaining('ABC123'), findsNothing);
    await homeUnmount(tester);
  });

  testWidgets('hidden when empty', (tester) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmCommunity(const AsyncData(null))],
    );
    expect(find.byType(HomeCardFrame), findsNothing);
    await homeUnmount(tester);
  });

  group('the 60 s LFG poller', () {
    var lfgCalls = 0;

    setUp(() => lfgCalls = 0);

    // `vmWith` overrides the community snapshot; the poller test needs the
    // real one to watch the previews.
    List<Override> realCommunity() => [
      vmLive(null),
      vmStore(const AsyncLoading()),
      vmRank(const AsyncData(null)),
      vmBp(const AsyncData(null)),
      ...vmFriends(const AsyncData(null)),
      vmOthers(null),
      vmStatus(null),
      matchingLfgPreviewProvider.overrideWith((ref, puuid) async {
        lfgCalls++;
        return [homeLfg('1')];
      }),
      trendingSkinsProvider.overrideWith((ref, period) async => const []),
    ];

    testWidgets('refetches every minute while Home is visible', (tester) async {
      await pumpHomeScreen(tester, env, overrides: realCommunity());
      await homePastGate(tester);
      expect(find.text('Đồng Đội Một#VN9'), findsOneWidget);
      final before = lfgCalls;
      expect(before, 1);

      await tester.pump(kHomeLfgRefresh);
      await homeSettle(tester);
      expect(lfgCalls, before + 1);
      await homeUnmount(tester);
    });

    testWidgets('does nothing while the app is in the background', (
      tester,
    ) async {
      await pumpHomeScreen(tester, env, overrides: realCommunity());
      await homePastGate(tester);
      final before = lfgCalls;

      env.foreground.foreground = false;
      await tester.pump(kHomeLfgRefresh);
      await tester.pump(kHomeLfgRefresh);
      await homeSettle(tester);
      expect(lfgCalls, before);
      await homeUnmount(tester);
    });
  });
}
