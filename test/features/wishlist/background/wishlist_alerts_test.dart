import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/app/deep_links.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/features/wishlist/background/wishlist_alerts.dart';
import 'package:valvn/features/wishlist/wishlist_strings.dart';

import '../../../core/domain/economy/economy_fixtures.dart';
import '../wishlist_test_harness.dart';

void main() {
  final now = DateTime.utc(2026, 9, 28, 5);
  late ContentDb db;
  late Storefront store;

  setUp(() {
    db = economyContent();
    store = Storefront.fromJson(
      economyFixture('storefront.json'),
      receivedAt: now,
    );
  });

  WishlistHit hitFor(String skin) => findWishlistHits(store, {skin}, db).first;

  test('withAccountParam keeps existing parameters', () {
    expect(withAccountParam('/store', 'p1'), '/store?account=p1');
    expect(
      withAccountParam('/store?segment=nightmarket', 'p1'),
      '/store?segment=nightmarket&account=p1',
    );
  });

  test('daily hit: VF §6.9 copy with the time left and a skin deep link', () {
    final alert = wishlistHitAlert(
      hitFor(Fx.aresSentinels),
      account: testAccount,
      db: db,
      now: now,
    );
    expect(alert.title, WishlistStrings.notifDailyTitle);
    expect(
      alert.body,
      'Ares Sentinels of Light đang có trong cửa hàng của Người Chơi#VN2 '
      '— còn 4 giờ.',
    );
    expect(alert.id, NotificationIds.wishlistHit(Fx.puuid, Fx.aresSentinels));
    final link = parseDeepLink(alert.payload);
    expect(link.accountPuuid, Fx.puuid);
    expect(link.location, '/collection/wishlist?skin=${Fx.aresSentinels}');
  });

  test('daily hit after the reset has no "còn" part', () {
    final alert = wishlistHitAlert(
      hitFor(Fx.aresSentinels),
      account: testAccount,
      db: db,
      now: now.add(const Duration(days: 1)),
    );
    expect(
      alert.body,
      'Ares Sentinels of Light đang có trong cửa hàng của Người Chơi#VN2.',
    );
  });

  test('Night Market hit: discount, price and the NM segment', () {
    final alert = wishlistHitAlert(
      hitFor(Fx.reaverVandal),
      account: testAccount,
      db: db,
      now: now,
    );
    expect(alert.title, WishlistStrings.notifNightMarketTitle);
    expect(alert.body, 'Vandal Reaver giảm 22% còn 1.385 VP (Người Chơi#VN2).');
    final link = parseDeepLink(alert.payload);
    expect(link.location, '/store?segment=nightmarket');
    expect(link.accountPuuid, Fx.puuid);
  });

  test('bundle hit: bundle name and the bundle page', () {
    final alert = wishlistHitAlert(
      hitFor(Fx.odinNeoFrontier),
      account: testAccount,
      db: db,
      now: now,
    );
    expect(alert.title, WishlistStrings.notifBundleTitle);
    expect(
      alert.body,
      'Odin Neo Frontier nằm trong bundle Neo Frontier (Người Chơi#VN2).',
    );
    expect(
      parseDeepLink(alert.payload).location,
      '/store/bundle/${Fx.bundleId}',
    );
  });

  test(
    'bundle unknown to the content and unknown skins degrade gracefully',
    () {
      final bundle = wishlistHitAlert(
        hitFor(Fx.phantomTocChien),
        account: testAccount,
        db: db,
        now: now,
      );
      expect(
        bundle.body,
        'Phantom Tốc Chiến nằm trong một bundle đang bán (Người Chơi#VN2).',
      );
      final raw = findWishlistHits(store, {Fx.magepunkL1}, ContentDb.empty());
      final unknown = wishlistHitAlert(
        raw.single,
        account: testAccount,
        db: ContentDb.empty(),
        now: now,
      );
      expect(unknown.body, startsWith('Vật phẩm không xác định'));
    },
  );

  test('Night Market copy without a price', () {
    expect(
      WishlistStrings.notifNightMarketBody('A', null, null, 'B#1'),
      'A đang có trong Chợ Đêm của B#1.',
    );
    expect(
      WishlistStrings.notifNightMarketBody('A', 0, '1.000 VP', 'B#1'),
      'A chỉ còn 1.000 VP (B#1).',
    );
  });

  test('more than 3 hits → one summary opening the wishlist', () {
    final hits = findWishlistHits(store, {
      Fx.aresSentinels,
      Fx.aresPrism,
      Fx.reaverVandal,
      Fx.odinNeoFrontier,
    }, db);
    final alerts = buildWishlistAlerts(
      hits,
      account: testAccount,
      db: db,
      now: now,
    );
    expect(alerts, hasLength(1));
    final summary = alerts.single;
    expect(summary.id, wishlistSummaryId(Fx.puuid));
    expect(summary.title, '4 skin trong wishlist đang được bán!');
    expect(
      summary.body,
      'Ares Sentinels of Light, Ares Prism và 2 skin khác đang có trong '
      'cửa hàng của Người Chơi#VN2.',
    );
    final link = parseDeepLink(summary.payload);
    expect(link.location, '/collection/wishlist');
    expect(link.accountPuuid, Fx.puuid);

    final few = buildWishlistAlerts(
      hits.take(3).toList(),
      account: testAccount,
      db: db,
      now: now,
    );
    expect(few, hasLength(3));
    expect(
      buildWishlistAlerts(const [], account: testAccount, db: db, now: now),
      isEmpty,
    );
  });
}
