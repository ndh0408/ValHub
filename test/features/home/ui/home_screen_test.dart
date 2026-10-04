import '../../../helpers/l10n.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/accounts/account_widgets.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/util/format.dart';
import 'package:valvn/core/ui/maintenance_banner.dart';
import 'package:valvn/features/community/community_previews.dart';
import 'package:valvn/features/home/data/home_card.dart';
import 'package:valvn/features/home/data/home_live.dart';
import 'package:valvn/features/home/home_strings.dart';
import 'package:valvn/features/home/providers/home_card_providers.dart';
import 'package:valvn/features/home/providers/home_refresh.dart';
import 'package:valvn/features/home/ui/cards/battlepass_home_card.dart';
import 'package:valvn/features/home/ui/cards/community_home_card.dart';
import 'package:valvn/features/home/ui/cards/friends_home_card.dart';
import 'package:valvn/features/home/ui/cards/live_home_card.dart';
import 'package:valvn/features/home/ui/cards/other_accounts_home_card.dart';
import 'package:valvn/features/home/ui/cards/rank_home_card.dart';
import 'package:valvn/features/home/ui/cards/server_status_home_card.dart';
import 'package:valvn/features/home/ui/cards/store_home_card.dart';
import 'package:valvn/features/home/ui/home_card_frame.dart';
import 'package:valvn/features/live_game/data/live_game_models.dart';

import '../home_test_env.dart';

final _cards = <HomeCardId, Type>{
  HomeCardId.live: LiveHomeCard,
  HomeCardId.store: StoreHomeCard,
  HomeCardId.rank: RankHomeCard,
  HomeCardId.battlePass: BattlePassHomeCard,
  HomeCardId.friends: FriendsHomeCard,
  HomeCardId.community: CommunityHomeCard,
  HomeCardId.otherAccounts: OtherAccountsHomeCard,
  HomeCardId.serverStatus: ServerStatusHomeCard,
};

Finder _card(HomeCardId id) => find.byType(_cards[id]!);

/// Top edge of a card in the page (works for cards below the fold).
double _top(WidgetTester tester, HomeCardId id) =>
    tester.getTopLeft(_card(id)).dy;

const _liveIngame = HomeLiveSnapshot(
  phase: LivePhase.ingame,
  queueId: 'competitive',
  mapName: 'Ascent',
);

void main() {
  group('header', () {
    testWidgets('title, account chip with name, ⚙', (tester) async {
      final env = await HomeTestEnv.create();
      await pumpHomeScreen(tester, env, overrides: vmEmpty());

      expect(find.text(HomeStrings.title), findsOneWidget);
      expect(find.text(homeMe.gameName), findsOneWidget);
      expect(find.byTooltip(CommonStrings.tabSettings), findsOneWidget);
      // The server-status card replaces the maintenance banner.
      expect(find.byType(MaintenanceBanner), findsNothing);
      homeExpectNoException(tester);
      await homeUnmount(tester);
    });

    testWidgets('the chip shows only the avatar on a 320 dp phone', (
      tester,
    ) async {
      final env = await HomeTestEnv.create();
      await pumpHomeScreen(
        tester,
        env,
        overrides: vmEmpty(),
        size: const Size(320, 640),
      );
      expect(find.text(homeMe.gameName), findsNothing);
      expect(
        tester.widget<AccountChip>(find.byType(AccountChip)).showName,
        isFalse,
      );
      homeExpectNoException(tester);
      await homeUnmount(tester);
    });

    testWidgets('⚙ pushes Cài đặt on top of Trang chủ; Back returns', (
      tester,
    ) async {
      final env = await HomeTestEnv.create();
      await pumpHomeScreen(tester, env, overrides: vmEmpty());

      await tester.tap(find.byTooltip(CommonStrings.tabSettings));
      await homeSettle(tester);
      expect(find.text('route /settings'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await homeSettle(tester);
      expect(find.text(HomeStrings.title), findsOneWidget);
      await homeUnmount(tester);
    });
  });

  testWidgets('every card in the default order (IA order)', (tester) async {
    final env = await HomeTestEnv.create(
      accounts: [homeMe, homeAlt1, homeAlt2],
    );
    await pumpHomeScreen(
      tester,
      env,
      overrides: vmFull(
        live: _liveIngame,
        status: homeServerStatus(status: 'scheduled'),
      ),
    );
    await homePastGate(tester);

    // The live match is pinned on top; a non-blocking status keeps its place.
    final order = [
      HomeCardId.live,
      HomeCardId.store,
      HomeCardId.rank,
      HomeCardId.battlePass,
      HomeCardId.friends,
      HomeCardId.community,
      HomeCardId.otherAccounts,
      HomeCardId.serverStatus,
    ];
    for (final id in order) {
      expect(_card(id), findsOneWidget, reason: id.name);
    }
    final tops = [for (final id in order) _top(tester, id)];
    expect(tops, [...tops]..sort());
    homeExpectNoException(tester);
    await homeUnmount(tester);
  });

  testWidgets('a custom order and hidden cards from the saved layout', (
    tester,
  ) async {
    final env = await HomeTestEnv.create(
      layout: {
        'v': 1,
        'order': [
          'rank',
          'store',
          'battlepass',
          'live',
          'friends',
          'community',
          'accounts',
          'status',
        ],
        'hidden': ['store'],
      },
    );
    await pumpHomeScreen(tester, env, overrides: vmFull());
    await homePastGate(tester);

    expect(_card(HomeCardId.store), findsNothing);
    expect(
      _top(tester, HomeCardId.rank),
      lessThan(_top(tester, HomeCardId.battlePass)),
    );
    await homeUnmount(tester);
  });

  testWidgets('core cards show skeletons while loading, optional ones wait', (
    tester,
  ) async {
    final env = await HomeTestEnv.create();
    await pumpHomeScreen(
      tester,
      env,
      overrides: vmWith(
        store: const AsyncLoading(),
        rank: const AsyncLoading(),
        bp: const AsyncLoading(),
        friends: const AsyncLoading(),
        community: const AsyncLoading(),
      ),
    );
    expect(find.byType(HomeCardSkeleton), findsNWidgets(3));
    expect(_card(HomeCardId.friends), findsNothing);
    expect(_card(HomeCardId.community), findsNothing);
    await homeUnmount(tester);
  });

  testWidgets('a skeleton never appears for a card that is user-hidden', (
    tester,
  ) async {
    final env = await HomeTestEnv.create(
      layout: {
        'v': 1,
        'order': [for (final c in HomeCardId.values) c.storageId],
        'hidden': ['store', 'rank'],
      },
    );
    await pumpHomeScreen(
      tester,
      env,
      overrides: vmWith(
        store: const AsyncLoading(),
        rank: const AsyncLoading(),
        bp: const AsyncLoading(),
      ),
    );
    expect(find.byType(HomeCardSkeleton), findsOneWidget); // Battle Pass
    await homeUnmount(tester);
  });

  group('session and status', () {
    testWidgets(
      'needs login: one banner, Riot cards hidden, the rest still shown',
      (tester) async {
        final env = await HomeTestEnv.create(
          accounts: [homeMe.copyWith(needsLogin: true), homeAlt1],
        );
        final router = await pumpHomeScreen(
          tester,
          env,
          overrides: vmFull(live: _liveIngame),
        );
        await homePastGate(tester);

        // One banner (the other-accounts card also says "Cần đăng nhập lại"
        // for an account of its own).
        expect(
          find.widgetWithText(FilledButton, CommonStrings.signInAgain),
          findsOneWidget,
        );
        expect(
          find.text(HomeStrings.needsLoginBody(homeMe.riotId)),
          findsOneWidget,
        );
        for (final id in [
          HomeCardId.live,
          HomeCardId.rank,
          HomeCardId.friends,
        ]) {
          expect(_card(id), findsNothing, reason: id.name);
        }
        expect(_card(HomeCardId.community), findsOneWidget);
        expect(_card(HomeCardId.store), findsOneWidget);
        expect(_card(HomeCardId.battlePass), findsOneWidget);
        expect(_card(HomeCardId.otherAccounts), findsOneWidget);

        await tester.tap(find.text(CommonStrings.signInAgain));
        await homeSettle(tester);
        expect(
          find.text('route /login?reauth=${homeMe.puuid}'),
          findsOneWidget,
        );
        expect(router.state.uri.path, isNot('/home'));
        await homeUnmount(tester);
      },
    );

    testWidgets(
      'blocking maintenance: status pinned, cards without data hidden',
      (tester) async {
        final env = await HomeTestEnv.create();
        await pumpHomeScreen(
          tester,
          env,
          overrides: vmWith(
            store: AsyncError(Exception('x'), StackTrace.empty),
            rank: AsyncError(Exception('x'), StackTrace.empty),
            bp: AsyncData(homeBpSnapshot()),
            status: homeServerStatus(),
          ),
        );

        expect(_card(HomeCardId.serverStatus), findsOneWidget);
        // Pinned above the user's order: before the Battle Pass card.
        expect(
          _top(tester, HomeCardId.serverStatus),
          lessThan(_top(tester, HomeCardId.battlePass)),
        );
        // Errors of cards without data would repeat the notice: hidden.
        expect(_card(HomeCardId.store), findsNothing);
        expect(_card(HomeCardId.rank), findsNothing);
        // Cards with data stay.
        expect(_card(HomeCardId.battlePass), findsOneWidget);
        expect(find.byType(MaintenanceBanner), findsNothing);
        await homeUnmount(tester);
      },
    );

    testWidgets('without a blocking status errors show a retry', (
      tester,
    ) async {
      final env = await HomeTestEnv.create();
      await pumpHomeScreen(
        tester,
        env,
        overrides: vmWith(store: AsyncError(Exception('x'), StackTrace.empty)),
      );
      expect(_card(HomeCardId.store), findsOneWidget);
      expect(find.text(CommonStrings.retry), findsOneWidget);
      await homeUnmount(tester);
    });
  });

  group('empty states', () {
    testWidgets('every card switched off: the empty state with the sheet', (
      tester,
    ) async {
      final env = await HomeTestEnv.create(
        layout: {
          'v': 1,
          'order': [for (final c in HomeCardId.values) c.storageId],
          'hidden': [for (final c in HomeCardId.values) c.storageId],
        },
      );
      await pumpHomeScreen(tester, env, overrides: vmFull());
      expect(find.text(HomeStrings.allHiddenTitle), findsOneWidget);
      expect(find.text(HomeStrings.allHiddenBody), findsOneWidget);
      await tester.tap(
        find.widgetWithText(FilledButton, HomeStrings.customize),
      );
      await homeSettle(tester);
      // The customize sheet lists the cards again.
      expect(find.text(HomeStrings.resetLayout), findsOneWidget);
      await homeUnmount(tester);
    });

    testWidgets('nothing to show: the quiet state, pull-to-refresh hint', (
      tester,
    ) async {
      final env = await HomeTestEnv.create();
      await pumpHomeScreen(tester, env, overrides: vmEmpty());
      await homePastGate(tester);
      expect(find.text(HomeStrings.quietTitle), findsOneWidget);
      expect(find.text(HomeStrings.quietBody), findsOneWidget);
      expect(find.text(HomeStrings.allHiddenTitle), findsNothing);
      await homeUnmount(tester);
    });

    testWidgets('no active account: the sign-in empty state', (tester) async {
      final env = await HomeTestEnv.create(accounts: const []);
      await pumpHomeScreen(tester, env, overrides: vmEmpty());
      expect(find.text(CommonStrings.errorNoAccount), findsOneWidget);
      await homeUnmount(tester);
    });
  });

  testWidgets('switching the account rebuilds the cards from the top', (
    tester,
  ) async {
    final env = await HomeTestEnv.create(accounts: [homeMe, homeAlt1]);
    final other = homeStoreSummary(wallet: 777);
    await pumpHomeScreen(
      tester,
      env,
      size: const Size(360, 420),
      overrides: vmFull(
        storeOverride: homeStoreSummaryProvider.overrideWith(
          (ref, puuid) => puuid == homeMe.puuid
              ? AsyncData(homeStoreSummary(wallet: 2440))
              : AsyncData(other),
        ),
      ),
    );
    await homePastGate(tester);
    expect(find.textContaining(formatVp(2440, messages: tl)), findsOneWidget);

    // Scroll down, then switch.
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -600));
    await homeSettle(tester);
    expect(
      tester.state<ScrollableState>(scrollable).position.pixels,
      greaterThan(100),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    container.read(activePuuidProvider.notifier).select(homeAlt1.puuid);
    await homeSettle(tester);

    expect(find.textContaining(formatVp(777, messages: tl)), findsOneWidget);
    expect(find.textContaining(formatVp(2440, messages: tl)), findsNothing);
    expect(tester.state<ScrollableState>(scrollable).position.pixels, 0);
    await homeUnmount(tester);
  });

  group('focus link', () {
    testWidgets('/home?focus=battlepass scrolls the card into view', (
      tester,
    ) async {
      final env = await HomeTestEnv.create();
      await pumpHomeScreen(
        tester,
        env,
        size: const Size(360, 420),
        overrides: vmFull(),
        focus: HomeCardId.battlePass,
      );
      await homeSettle(tester, frames: 20);

      final rect = tester.getRect(_card(HomeCardId.battlePass));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.top, lessThan(420));
      expect(
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .pixels,
        greaterThan(0),
      );
      await homeUnmount(tester);
    });

    testWidgets('a new nonce applies the same focus again', (tester) async {
      final env = await HomeTestEnv.create();
      final router = await pumpHomeScreen(
        tester,
        env,
        size: const Size(360, 420),
        overrides: vmFull(),
        focus: HomeCardId.battlePass,
      );
      await homeSettle(tester, frames: 20);

      final scrollable = find.byType(Scrollable).first;
      final position = tester.state<ScrollableState>(scrollable).position;
      position.jumpTo(0);
      await homeSettle(tester);
      expect(position.pixels, 0);

      router.go('/home?focus=battlepass&nav=2');
      await homeSettle(tester, frames: 20);
      expect(position.pixels, greaterThan(0));
      await homeUnmount(tester);
    });

    testWidgets('a hidden card leaves the scroll at the top', (tester) async {
      final env = await HomeTestEnv.create(
        layout: {
          'v': 1,
          'order': [for (final c in HomeCardId.values) c.storageId],
          'hidden': ['battlepass'],
        },
      );
      await pumpHomeScreen(
        tester,
        env,
        size: const Size(360, 420),
        overrides: vmFull(),
        focus: HomeCardId.battlePass,
      );
      await homeSettle(tester, frames: 20);
      expect(
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .pixels,
        0,
      );
      await homeUnmount(tester);
    });

    testWidgets('reduced motion: scrolls without a pulse animation', (
      tester,
    ) async {
      final env = await HomeTestEnv.create();
      await pumpHomeScreen(
        tester,
        env,
        size: const Size(360, 420),
        overrides: vmFull(),
        focus: HomeCardId.battlePass,
        disableAnimations: true,
      );
      await homeSettle(tester, frames: 4);
      expect(
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .pixels,
        greaterThan(0),
      );
      await homeUnmount(tester);
    });
  });

  testWidgets(
    'a pinned card appearing while scrolled does not move the visible cards',
    (tester) async {
      final env = await HomeTestEnv.create();
      final overrides = vmFull(
        liveOverride: homeLiveSnapshotProvider.overrideWith(
          (ref, puuid) => ref.watch(_liveToggle),
        ),
      );
      await pumpHomeScreen(
        tester,
        env,
        size: const Size(360, 420),
        overrides: overrides,
      );
      await homePastGate(tester);

      final scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, const Offset(0, -260));
      await homeSettle(tester);
      final before = tester.getTopLeft(_card(HomeCardId.rank)).dy;
      expect(
        tester.state<ScrollableState>(scrollable).position.pixels,
        greaterThan(100),
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      container.read(_liveToggle.notifier).set(_liveIngame);
      await homeSettle(tester);

      expect(_card(HomeCardId.live), findsOneWidget);
      final after = tester.getTopLeft(_card(HomeCardId.rank)).dy;
      expect(after, closeTo(before, 0.5));
      await homeUnmount(tester);
    },
  );

  testWidgets('the account chip opens the switcher sheet', (tester) async {
    final env = await HomeTestEnv.create(accounts: [homeMe, homeAlt1]);
    await pumpHomeScreen(tester, env, overrides: vmEmpty());
    await tester.tap(find.text(homeMe.gameName));
    await homeSettle(tester);
    expect(find.text(homeAlt1.riotId), findsWidgets);
    await homeUnmount(tester);
  });

  testWidgets('LFG polling runs only while the community card is in view', (
    tester,
  ) async {
    var reads = 0;
    final env = await HomeTestEnv.create();
    await pumpHomeScreen(
      tester,
      env,
      overrides: [
        ...vmFull(),
        matchingLfgPreviewProvider.overrideWith((ref, id) async {
          reads++;
          return const [];
        }),
      ],
    );
    await homePastGate(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    final subscription = container.listen(
      matchingLfgPreviewProvider(homeMe.puuid),
      (_, _) {},
    );
    await tester.pump();
    expect(reads, 1);
    expect(_top(tester, HomeCardId.community), greaterThan(780));
    await tester.pump(kHomeLfgRefresh);
    await tester.pump();
    expect(reads, 1);
    await tester.ensureVisible(_card(HomeCardId.community));
    await homeSettle(tester);
    await tester.pump(kHomeLfgRefresh);
    await tester.pump();
    expect(reads, 2);
    subscription.close();
    homeExpectNoException(tester);
    await homeUnmount(tester);
  });

  testWidgets('pull to refresh reloads only the cards shown', (tester) async {
    final env = await HomeTestEnv.create(
      layout: {
        'v': 1,
        'order': [for (final c in HomeCardId.values) c.storageId],
        'hidden': ['store', 'rank'],
      },
    );
    await pumpHomeScreen(
      tester,
      env,
      overrides: vmWith(
        store: AsyncData(homeStoreSummary()),
        rank: AsyncData(homeRankSnapshot()),
        bp: AsyncData(homeBpSnapshot()),
      ),
    );
    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 500),
      800,
    );
    await homeSettle(tester, frames: 20);
    homeExpectNoException(tester);
    await homeUnmount(tester);
  });
}

/// A live snapshot a test switches on while the page is scrolled.
final _liveToggle = NotifierProvider<_LiveToggle, HomeLiveSnapshot?>(
  _LiveToggle.new,
);

class _LiveToggle extends Notifier<HomeLiveSnapshot?> {
  @override
  HomeLiveSnapshot? build() => null;

  void set(HomeLiveSnapshot? value) => state = value;
}
