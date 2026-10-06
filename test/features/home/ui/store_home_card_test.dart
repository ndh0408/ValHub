import '../../../helpers/l10n.dart';

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/ui/countdown_ring.dart';
import 'package:valvn/core/util/format.dart';
import 'package:valvn/features/home/home_strings.dart';
import 'package:valvn/features/home/ui/cards/store_home_card.dart';
import 'package:valvn/features/home/ui/home_card_frame.dart';
import 'package:valvn/features/skin_detail/skin_detail_sheet.dart';

import '../home_test_env.dart';

Widget _card() => const StoreHomeCard(puuid: Fx.puuid);

void main() {
  late HomeTestEnv env;

  setUp(() async {
    env = await HomeTestEnv.create();
  });

  testWidgets('four tiles, the reset countdown, the total and the wallet', (
    tester,
  ) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmStore(AsyncData(homeStoreSummary()))],
    );

    expect(find.text(HomeStrings.cardStore), findsOneWidget);
    expect(find.byType(HomeSkinTile), findsNWidgets(4));
    expect(find.text(HomeStrings.storeResetsIn('04:50:01')), findsOneWidget);
    expect(find.byType(CountdownRing), findsOneWidget);
    expect(
      find.textContaining(HomeStrings.storeTotal(formatVp(6500, messages: tl))),
      findsOneWidget,
    );
    // 2.440 VP buys ONE of the offers (1.275 + 1.275 = 2.550 > 2.440), never
    // "4 skin" (PR-04).
    expect(
      find.textContaining(
        HomeStrings.storeWalletCanBuy(formatVp(2440, messages: tl), 1),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('đủ mua tối đa 4'), findsNothing);
    // Prices sit on the tiles.
    expect(find.text('2.175'), findsOneWidget);
    homeExpectNoException(tester);
    await homeUnmount(tester);
  });

  testWidgets('no wallet: only the total', (tester) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmStore(AsyncData(homeStoreSummary(wallet: null)))],
    );
    expect(
      find.textContaining(HomeStrings.storeTotal(formatVp(6500, messages: tl))),
      findsOneWidget,
    );
    expect(find.textContaining('Ví'), findsNothing);
    await homeUnmount(tester);
  });

  testWidgets('the countdown ends: "Đang làm mới…" until the new store', (
    tester,
  ) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmStore(AsyncData(homeStoreSummary()))],
    );
    env.clock.advance(const Duration(seconds: 17402));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(HomeStrings.storeRefreshing), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('a store that never arrives after the reset is called out', (
    tester,
  ) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmStore(AsyncData(homeStoreSummary()))],
    );
    env.clock.advance(const Duration(seconds: 17402));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(tl.homeStoreRefreshing), findsOneWidget);
    await tester.pump(const Duration(seconds: 91));
    expect(find.text(tl.homeStoreRefreshing), findsNothing);
    expect(find.text(tl.homeStoreOutdated), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('a saved store from before the reset shows no skins', (
    tester,
  ) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [
        vmStore(
          AsyncData(
            homeStoreSummary(
              cache: true,
              now: homeNow.add(const Duration(days: 1)),
            ),
          ),
        ),
      ],
    );
    expect(find.text(tl.homeStoreOutdated), findsOneWidget);
    expect(find.byType(HomeSkinTile), findsNothing);
    expect(find.text(tl.homeStoreRefreshing), findsNothing);
    expect(find.byType(CountdownRing), findsNothing);
    homeExpectNoException(tester);
    await homeUnmount(tester);
  });

  group('wishlist', () {
    testWidgets('a daily hit: banner with its place; tap opens the store', (
      tester,
    ) async {
      final router = await pumpHomeCard(
        tester,
        env,
        _card(),
        overrides: [
          vmStore(AsyncData(homeStoreSummary(wishlist: {Fx.aresPrism}))),
        ],
      );
      expect(find.text(HomeStrings.storeWishlistHit), findsOneWidget);
      expect(find.text('cửa hàng hằng ngày'), findsOneWidget);
      // A heart on the wishlisted tile (not colour alone: the banner text).
      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);

      await tester.tap(find.text(HomeStrings.storeWishlistHit));
      await homeSettle(tester);
      expect(find.text('route /store?segment=daily'), findsOneWidget);
      expect(router.state.uri.path, '/store');
      // A tab switch, not a pushed page.
      expect(find.byType(BackButton), findsNothing);
      await homeUnmount(tester);
    });

    testWidgets('several hits are counted; a bundle hit pushes the bundle', (
      tester,
    ) async {
      final summary = homeStoreSummary(
        wishlist: {Fx.odinNeoFrontier, Fx.daoReaver, Fx.aresPrism},
      );
      await pumpHomeCard(
        tester,
        env,
        _card(),
        overrides: [vmStore(AsyncData(summary))],
      );
      expect(find.text(HomeStrings.storeWishlistHits(3)), findsOneWidget);

      // Only a bundle hit: it opens the bundle page above Home.
      final bundleOnly = homeStoreSummary(wishlist: {Fx.odinNeoFrontier});
      await homeUnmount(tester);
      await pumpHomeCard(
        tester,
        env,
        _card(),
        overrides: [vmStore(AsyncData(bundleOnly))],
      );
      await tester.tap(find.text(HomeStrings.storeWishlistHit));
      await homeSettle(tester);
      expect(find.text('route /store/bundle/${Fx.bundleId}'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      await homeUnmount(tester);
    });
  });

  group('Night Market', () {
    testWidgets('unseen: the count, "Mới" and no spoiler', (tester) async {
      await pumpHomeCard(
        tester,
        env,
        _card(),
        overrides: [vmStore(AsyncData(homeStoreSummary()))],
      );
      expect(find.text(HomeStrings.nightMarketTitle), findsOneWidget);
      expect(find.text(HomeStrings.nightMarketWaiting(3)), findsOneWidget);
      expect(find.text(HomeStrings.nightMarketNew), findsOneWidget);
      // The best deal (−41 %) stays hidden until the user opened it.
      expect(find.textContaining('-41%'), findsNothing);
      await homeUnmount(tester);
    });

    testWidgets('after opening it: the best deal with the old price', (
      tester,
    ) async {
      final ids = homeStorefront().nightMarket!.offers.map(
        (o) => o.bonusOfferId,
      );
      await pumpHomeCard(
        tester,
        env,
        _card(),
        overrides: [vmStore(AsyncData(homeStoreSummary(seen: ids.toSet())))],
      );
      expect(find.text(HomeStrings.nightMarketNew), findsNothing);
      expect(find.textContaining('-41%'), findsOneWidget);
      expect(find.textContaining(formatVp(2094, messages: tl)), findsOneWidget);
      expect(find.textContaining(formatVp(3550, messages: tl)), findsOneWidget);
      await homeUnmount(tester);
    });

    testWidgets('tapping the row opens the Night Market segment', (
      tester,
    ) async {
      await pumpHomeCard(
        tester,
        env,
        _card(),
        overrides: [vmStore(AsyncData(homeStoreSummary()))],
      );
      await tester.tap(find.text(HomeStrings.nightMarketWaiting(3)));
      await homeSettle(tester);
      expect(find.text('route /store?segment=nightmarket'), findsOneWidget);
      await homeUnmount(tester);
    });
  });

  testWidgets('a tile opens the skin sheet; the card opens the store', (
    tester,
  ) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmStore(AsyncData(homeStoreSummary()))],
    );
    await tester.tap(find.byType(HomeSkinTile).first);
    await homeSettle(tester);
    expect(find.byType(SkinDetailSheet), findsOneWidget);
    await homeUnmount(tester);

    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmStore(AsyncData(homeStoreSummary()))],
    );
    await tester.tap(find.text(HomeStrings.cardStore));
    await homeSettle(tester);
    expect(find.text('route /store?segment=daily'), findsOneWidget);
    await homeUnmount(tester);
  });

  testWidgets('an offline copy says when it was updated', (tester) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmStore(AsyncData(homeStoreSummary(cache: true)))],
    );
    expect(
      find.text(CommonStrings.updatedAt(formatTime(homeNow))),
      findsOneWidget,
    );
    await homeUnmount(tester);
  });

  testWidgets('loading: a skeleton with the same structure', (tester) async {
    await pumpHomeCard(
      tester,
      env,
      _card(),
      overrides: [vmStore(const AsyncLoading())],
    );
    expect(find.byType(HomeCardSkeleton), findsOneWidget);
    expect(find.byType(HomeSkinTile), findsNothing);
    await homeUnmount(tester);
  });

  group('real pipeline (storefront, wallet, wishlist, content)', () {
    testWidgets('error without data shows "Thử lại", which refetches', (
      tester,
    ) async {
      var fail = true;
      when(() => env.api.storefront(any())).thenAnswer((_) async {
        if (fail) throw const TransientException(reason: 'offline');
        return economyFixture('storefront.json');
      });
      when(() => env.api.wallet(any()))
          .thenAnswer((_) async => economyFixture('wallet.json'));
      await pumpHomeCard(tester, env, _card());

      expect(find.text(CommonStrings.retry), findsOneWidget);
      expect(find.byType(HomeSkinTile), findsNothing);

      fail = false;
      await tester.tap(find.text(CommonStrings.retry));
      await homeSettle(tester);
      expect(find.byType(HomeSkinTile), findsNWidgets(4));
      verify(() => env.api.storefront(any())).called(2);
      await homeUnmount(tester);
    });

    testWidgets('a content miss is reported once per storefront', (
      tester,
    ) async {
      final json = jsonDecode(
        economyFixtureText('storefront.json')
            .replaceAll(Fx.aresPrismL1, Fx.unknownLevel),
      ) as Map<String, dynamic>;
      when(() => env.api.storefront(any())).thenAnswer((_) async => json);
      when(() => env.api.wallet(any()))
          .thenAnswer((_) async => economyFixture('wallet.json'));
      await pumpHomeCard(tester, env, _card());
      expect(find.text(CommonStrings.unknownItem), findsOneWidget);
      expect(env.misses.count, 1);
      await homeSettle(tester);
      expect(env.misses.count, 1, reason: 'same storefront, no second report');
      await homeUnmount(tester);
    });

    testWidgets('the wishlist marks the tile', (tester) async {
      when(() => env.api.storefront(any()))
          .thenAnswer((_) async => economyFixture('storefront.json'));
      when(() => env.api.wallet(any()))
          .thenAnswer((_) async => economyFixture('wallet.json'));
      await pumpHomeCard(
        tester,
        env,
        Consumer(
          builder: (context, ref, _) {
            ref
                .read(wishlistProvider(Fx.puuid).notifier)
                .add(Fx.aresPrism)
                .ignore();
            return _card();
          },
        ),
      );
      await homeSettle(tester);
      expect(find.text(HomeStrings.storeWishlistHit), findsOneWidget);
      await homeUnmount(tester);
    });
  });
}
