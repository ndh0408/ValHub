import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/accounts/account_widgets.dart';
import 'package:valvn/core/l10n/account_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/wishlist/wishlist_store.dart';
import 'package:valvn/core/xmpp/xmpp_providers.dart' show appForegroundProvider;
import 'package:valvn/features/home/home_strings.dart';
import 'package:valvn/features/home/providers/home_refresh.dart';
import 'package:valvn/features/home/ui/cards/other_accounts_home_card.dart';
import 'package:valvn/features/home/ui/home_card_frame.dart';

import '../../../core/domain/economy/economy_fixtures.dart';
import '../home_test_env.dart';

Widget _card() => const OtherAccountsHomeCard();

/// G-1 answers 404: every account's game is not running.
void _offline(HomeTestEnv env) =>
    when(() => env.api.gameSession(any()))
        .thenAnswer((_) async => throw const NotFoundException());

void main() {
  testWidgets('a single account: no card', (tester) async {
    final env = await HomeTestEnv.create();
    await pumpHomeCard(tester, env, _card());
    expect(find.byType(HomeCardFrame), findsNothing);
    await homeUnmount(tester);
  });

  group('rows', () {
    testWidgets('activity as text and colour, a wishlist badge, sign-in', (
      tester,
    ) async {
      final env = await HomeTestEnv.create(
        accounts: [homeMe, homeAlt1, homeAlt2],
      );
      await pumpHomeCard(
        tester,
        env,
        _card(),
        overrides: [vmOthers(homeOtherAccounts())],
      );
      expect(find.text(HomeStrings.cardOtherAccounts), findsNothing);
      expect(find.text(HomeStrings.otherAccountsTitle(2)), findsOneWidget);
      expect(find.text(homeAlt1.riotId), findsOneWidget);
      expect(find.text(homeAlt2.riotId), findsOneWidget);
      // The activity is spelled out (never only a coloured dot).
      expect(find.textContaining(AccountStrings.statusInMatch), findsOneWidget);
      expect(find.text(HomeStrings.otherWishlistHit), findsOneWidget);
      expect(find.text(AccountStrings.needsLogin), findsOneWidget);
      homeExpectNoException(tester);
      await homeUnmount(tester);
    });

    testWidgets('a row switches the active account', (tester) async {
      final env = await HomeTestEnv.create(
        accounts: [homeMe, homeAlt1, homeAlt2],
      );
      await pumpHomeCard(
        tester,
        env,
        _card(),
        overrides: [vmOthers(homeOtherAccounts(hit: false))],
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(OtherAccountsHomeCard)),
      );
      expect(container.read(activePuuidProvider), homeMe.puuid);

      await tester.tap(find.text(homeAlt1.riotId));
      await homeSettle(tester);
      expect(container.read(activePuuidProvider), homeAlt1.puuid);
      await homeUnmount(tester);
    });

    testWidgets('a sign-in row goes to the login of that account', (
      tester,
    ) async {
      final env = await HomeTestEnv.create(
        accounts: [homeMe, homeAlt1, homeAlt2],
      );
      await pumpHomeCard(
        tester,
        env,
        _card(),
        overrides: [vmOthers(homeOtherAccounts())],
      );
      await tester.tap(find.text(homeAlt2.riotId));
      await homeSettle(tester);
      expect(
        find.text('route /login?reauth=${homeAlt2.puuid}'),
        findsOneWidget,
      );
      expect(find.byType(BackButton), findsOneWidget);
      await homeUnmount(tester);
    });

    testWidgets('the hit badge selects the account and opens the store', (
      tester,
    ) async {
      final env = await HomeTestEnv.create(
        accounts: [homeMe, homeAlt1, homeAlt2],
      );
      await pumpHomeCard(
        tester,
        env,
        _card(),
        overrides: [vmOthers(homeOtherAccounts())],
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(OtherAccountsHomeCard)),
      );
      await tester.tap(find.text(HomeStrings.otherWishlistHit));
      await homeSettle(tester);
      expect(container.read(activePuuidProvider), homeAlt1.puuid);
      expect(find.text('route /store?segment=daily'), findsOneWidget);
      await homeUnmount(tester);
    });

    testWidgets('"+n tài khoản" opens the switcher', (tester) async {
      final env = await HomeTestEnv.create(
        accounts: [homeMe, homeAlt1, homeAlt2],
      );
      await pumpHomeCard(
        tester,
        env,
        _card(),
        overrides: [vmOthers(homeOtherAccounts(more: 2))],
      );
      expect(find.text(HomeStrings.otherAccountsTitle(4)), findsOneWidget);
      await tester.tap(find.text(HomeStrings.otherMore(2)));
      await homeSettle(tester);
      expect(find.byType(AccountSwitcherSheet), findsOneWidget);
      await homeUnmount(tester);
    });
  });

  group('real pipeline (saved storefronts, wishlist, activity)', () {
    Future<HomeTestEnv> withAlts({bool needsLogin = false}) async {
      final alt2 = needsLogin ? homeAlt2.copyWith(needsLogin: true) : homeAlt2;
      final env = await HomeTestEnv.create(accounts: [homeMe, homeAlt1, alt2]);
      _offline(env);
      // Alt 1 saved its store just now and wishes for a skin in it.
      env.files.entries[JsonFileCache.accountKey(
        homeAlt1.puuid,
        'economy_storefront',
      )] = CachedJson(
        economyFixture('storefront.json'),
        homeNow,
      );
      await env.prefs.setStringList(WishlistRepository.key(homeAlt1.puuid), [
        Fx.aresPrism,
      ]);
      return env;
    }

    testWidgets('the wishlist hit comes from the saved store, no network', (
      tester,
    ) async {
      final env = await withAlts();
      await pumpHomeCard(tester, env, _card());
      expect(find.text(HomeStrings.otherWishlistHit), findsOneWidget);
      verifyNever(() => env.api.storefront(any()));
      verifyNever(() => env.api.wallet(any()));
      await homeUnmount(tester);
    });

    testWidgets('activity is polled every 2 minutes, only for shown rows', (
      tester,
    ) async {
      final env = await withAlts(needsLogin: true);
      await pumpHomeCard(tester, env, _card());
      // One check for the account that can be checked; none for the one that
      // has to sign in again.
      verify(() => env.api.gameSession(homeAlt1.puuid)).called(1);
      verifyNever(() => env.api.gameSession(homeAlt2.puuid));

      await tester.pump(kHomeAccountsRefresh);
      await homeSettle(tester);
      verify(() => env.api.gameSession(homeAlt1.puuid)).called(1);
      verifyNever(() => env.api.gameSession(homeAlt2.puuid));
      await homeUnmount(tester);
    });

    testWidgets('the poller pauses in the background', (tester) async {
      final env = await withAlts();
      await pumpHomeCard(tester, env, _card());
      clearInteractions(env.api);
      // The poller only reads the flag when it ticks: initialize it first.
      ProviderScope.containerOf(
        tester.element(find.byType(OtherAccountsHomeCard)),
      ).read(appForegroundProvider);
      env.foreground.foreground = false;
      await tester.pump(kHomeAccountsRefresh);
      await tester.pump(kHomeAccountsRefresh);
      await homeSettle(tester);
      verifyNever(() => env.api.gameSession(any()));
      await homeUnmount(tester);
    });
  });

  testWidgets('no overflow at 200 % text on 320 dp', (tester) async {
    final env = await HomeTestEnv.create(
      accounts: [homeMe, homeAlt1, homeAlt2],
    );
    await pumpHomeCard(
      tester,
      env,
      _card(),
      size: const Size(320, 700),
      textScale: 2,
      overrides: [vmOthers(homeOtherAccounts(more: 3))],
    );
    homeExpectNoException(tester);
    await homeUnmount(tester);
  });
}
