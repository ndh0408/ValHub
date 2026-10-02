import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/l10n/notification_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/wishlist/background/wishlist_alerts.dart';
import 'package:valvn/features/wishlist/background/wishlist_check.dart';
import 'package:valvn/features/wishlist/background/wishlist_check_state.dart';
import 'package:valvn/features/wishlist/wishlist_strings.dart';

import '../../../core/domain/economy/economy_fixtures.dart';
import '../../../helpers/test_prefs.dart';

const puuid1 = Fx.puuid;
const puuid2 = 'aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee';

const account1 = Account(
  puuid: puuid1,
  gameName: 'Người Chơi',
  tagLine: 'VN2',
  region: 'ap',
  shard: 'ap',
);
const account2 = Account(
  puuid: puuid2,
  gameName: 'Phụ',
  tagLine: 'ALT',
  region: 'ap',
  shard: 'ap',
);

class NotifyCall {
  NotifyCall(
    this.id,
    this.title,
    this.body,
    this.channel,
    this.payload,
    this.puuid,
  );

  final int id;
  final String title;
  final String body;
  final NotificationChannel channel;
  final String payload;
  final String puuid;
}

class FakeEnv implements WishlistCheckEnv {
  FakeEnv(this.prefs, {required this.accountList, required this.now0});

  @override
  final Prefs prefs;
  List<Account> accountList;
  DateTime now0;

  /// Added to the clock on every `now()` call (budget tests).
  Duration tick = Duration.zero;
  final wishlists = <String, Set<String>>{};
  final sessionErrors = <String, Object>{};
  final storefrontErrors = <String, Object>{};
  Object? storefrontJson;
  Object? contentError;
  Object? accountsError;
  bool notifyThrows = false;

  final notifications = <NotifyCall>[];
  final markedNeedsLogin = <String>[];
  final storefrontCalls = <String>[];
  final logs = <String>[];
  int contentLoads = 0;

  @override
  DateTime now() {
    final t = now0;
    now0 = now0.add(tick);
    return t;
  }

  @override
  Future<void> reload() async {}

  @override
  List<Account> accounts() {
    if (accountsError != null) throw accountsError!;
    return accountList;
  }

  @override
  Set<String> wishlist(String puuid) => wishlists[puuid] ?? const {};

  @override
  Future<void> ensureSession(String puuid) async {
    final e = sessionErrors[puuid];
    if (e != null) throw e;
  }

  @override
  Future<Object?> storefront(String puuid) async {
    storefrontCalls.add(puuid);
    final e = storefrontErrors[puuid];
    if (e != null) throw e;
    return storefrontJson ?? economyFixture('storefront.json');
  }

  @override
  Future<ContentDb> loadContent(String language) async {
    contentLoads++;
    if (contentError != null) throw contentError!;
    return economyContent();
  }

  @override
  Future<void> notify({
    required int id,
    required String title,
    required String body,
    required NotificationChannel channel,
    required String payload,
    required String accountPuuid,
  }) async {
    if (notifyThrows) throw StateError('plugin');
    notifications.add(
      NotifyCall(id, title, body, channel, payload, accountPuuid),
    );
  }

  @override
  Future<void> markNeedsLogin(String puuid) async {
    markedNeedsLogin.add(puuid);
    accountList = [
      for (final a in accountList)
        a.puuid == puuid ? a.copyWith(needsLogin: true) : a,
    ];
  }

  @override
  void log(String event, {String? detail}) => logs.add('$event $detail');
}

Future<Prefs> prefsWith({bool enabled = true, bool nightMarket = false}) =>
    createTestPrefs({
      PrefKeys.appSettings:
          '{"wishlistNotifications": $enabled, '
          '"nightMarketNotifications": $nightMarket}',
    });

void main() {
  final monday = DateTime.utc(2026, 9, 28, 5);

  Future<FakeEnv> env({
    bool enabled = true,
    bool nightMarket = false,
    List<Account> accounts = const [account1],
    Map<String, Set<String>> wishlists = const {
      puuid1: {Fx.aresSentinels, Fx.reaverVandal},
    },
  }) async {
    final e = FakeEnv(
      await prefsWith(enabled: enabled, nightMarket: nightMarket),
      accountList: accounts,
      now0: monday,
    );
    e.wishlists.addAll(wishlists);
    return e;
  }

  test('does nothing while the setting is off', () async {
    final e = await env(enabled: false);
    final report = await WishlistChecker(e).run();
    expect(report.disabled, isTrue);
    expect(report.ok, isTrue);
    expect(e.storefrontCalls, isEmpty);
    expect(e.contentLoads, 0);
  });

  test('checks only accounts with wishlist alerts enabled', () async {
    final e = await env(
      enabled: false,
      accounts: const [account1, account2],
      wishlists: const {
        puuid1: {Fx.aresSentinels},
        puuid2: {Fx.aresSentinels},
      },
    );
    await e.prefs.setJson(
      PrefKeys.appSettings,
      const AppSettings(wishlistNotificationsByAccount: {puuid2: true})
          .toJson(),
    );
    final report = await WishlistChecker(e).run();
    expect(report.checked, 1);
    expect(e.storefrontCalls, [puuid2]);
  });

  test('notifies each hit with its account and deep link', () async {
    final e = await env();
    final report = await WishlistChecker(e).run();
    expect(report.ok, isTrue);
    expect(report.checked, 1);
    expect(report.alerts, 2);
    expect(e.notifications.map((n) => n.title), [
      WishlistStrings.notifDailyTitle,
      WishlistStrings.notifNightMarketTitle,
    ]);
    expect(
      e.notifications.every((n) => n.channel == NotificationChannel.wishlist),
      isTrue,
    );
    expect(e.notifications.every((n) => n.puuid == puuid1), isTrue);
    expect(e.notifications.first.body, contains('Người Chơi#VN2'));
    expect(e.notifications.first.payload, contains('account=$puuid1'));
    expect(
      e.notifications.first.id,
      NotificationIds.wishlistHit(puuid1, Fx.aresSentinels),
    );
    expect(e.notifications.last.body, contains('giảm 22%'));
    expect(e.logs.last, startsWith('wishlist.check'));
    expect(e.logs.join(), isNot(contains(puuid1)), reason: 'no PUUID in logs');
    // Prices seen in the storefront feed the B9 chain.
    expect(ObservedPriceStore(e.prefs).read(), isNotEmpty);
  });

  test('at most once until the returned storefront reset', () async {
    final e = await env();
    await WishlistChecker(e).run();
    expect(e.storefrontCalls, [puuid1]);

    e.now0 = monday.add(const Duration(minutes: 10));
    final again = await WishlistChecker(e).run();
    expect(again.checked, 0);
    expect(e.storefrontCalls, [puuid1], reason: 'same UTC day');
    expect(e.contentLoads, 1, reason: 'no content load when nothing is due');
    expect(e.notifications, hasLength(2));
  });

  test(
    'next day: new daily hit notified, live Night Market hit not repeated',
    () async {
      final e = await env();
      await WishlistChecker(e).run();
      expect(e.notifications, hasLength(2));

      e.now0 = DateTime.utc(2026, 9, 29, 1);
      final next = await WishlistChecker(e).run();
      expect(next.checked, 1);
      expect(e.storefrontCalls, hasLength(2));
      // The same fixture again: its daily offer is "new" for the new day,
      // the Night Market offer is still the one already notified.
      expect(e.notifications.skip(2).map((n) => n.title), [
        WishlistStrings.notifDailyTitle,
      ]);
    },
  );

  test('many hits → a single summary notification', () async {
    final e = await env(
      wishlists: const {
        puuid1: {
          Fx.aresSentinels,
          Fx.aresPrism,
          Fx.reaverVandal,
          Fx.odinNeoFrontier,
        },
      },
    );
    final report = await WishlistChecker(e).run();
    expect(report.alerts, 1);
    expect(e.notifications.single.id, wishlistSummaryId(puuid1));
    expect(e.notifications.single.title, WishlistStrings.notifSummaryTitle(4));
  });

  test('a skin on sale in two places gives one notification', () async {
    final e = await env(
      wishlists: const {
        puuid1: {Fx.reaverVandal},
      },
    );
    final json = economyFixture('storefront.json');
    json['SkinsPanelLayout'] = {
      'SingleItemOffers': [Fx.reaverL1],
      'SingleItemOffersRemainingDurationInSeconds': 3600,
    };
    e.storefrontJson = json;
    await WishlistChecker(e).run();
    expect(e.notifications, hasLength(1));
    expect(e.notifications.single.title, WishlistStrings.notifDailyTitle);
    final notified = WishlistCheckState(e.prefs).notified(puuid1, monday);
    expect(
      notified.keys,
      containsAll([
        'daily:${Fx.reaverVandal}',
        'nightMarket:${Fx.reaverVandal}',
      ]),
    );
  });

  test('skips needsLogin accounts and empty wishlists', () async {
    final e = await env(
      accounts: [account1.copyWith(needsLogin: true), account2],
      wishlists: const {
        puuid1: {Fx.aresSentinels},
      },
    );
    final report = await WishlistChecker(e).run();
    expect(report.checked, 0);
    expect(e.storefrontCalls, isEmpty);
    expect(e.contentLoads, 0);
    expect(e.notifications, isEmpty);
  });

  test('re-auth failure: mark needsLogin and notify once', () async {
    final e = await env(
      accounts: const [account1, account2],
      wishlists: const {
        puuid1: {Fx.aresSentinels},
        puuid2: {Fx.reaverVandal},
      },
    );
    e.sessionErrors[puuid1] = const NeedsLoginException(puuid: puuid1);
    final report = await WishlistChecker(e).run();
    expect(report.needsLogin, 1);
    expect(report.checked, 1, reason: 'the other account still runs');
    expect(e.markedNeedsLogin, [puuid1]);
    final expired = e.notifications.where(
      (n) => n.channel == NotificationChannel.account,
    );
    expect(expired, hasLength(1));
    expect(expired.single.title, NotificationStrings.sessionExpiredTitle);
    expect(
      expired.single.body,
      NotificationStrings.sessionExpiredBody('Người Chơi#VN2'),
    );
    expect(expired.single.id, NotificationIds.sessionExpired(puuid1));
    expect(expired.single.payload, '/login?reauth=$puuid1');
    expect(WishlistCheckState(e.prefs).needsLoginNotified(puuid1), isTrue);

    // Even if the account is not flagged (another isolate reset it), the
    // "Cần đăng nhập lại" notification is not repeated.
    e.accountList = const [account1];
    e.now0 = DateTime.utc(2026, 9, 29, 1);
    await WishlistChecker(e).run();
    expect(
      e.notifications.where((n) => n.channel == NotificationChannel.account),
      hasLength(1),
    );

    // After a successful check the flag is cleared again.
    e.sessionErrors.clear();
    e.accountList = const [account1];
    e.now0 = DateTime.utc(2026, 9, 30, 1);
    await WishlistChecker(e).run();
    expect(WishlistCheckState(e.prefs).needsLoginNotified(puuid1), isFalse);
  });

  test('NeedsLoginException from the storefront call is handled too', () async {
    final e = await env();
    e.storefrontErrors[puuid1] = const NeedsLoginException();
    final report = await WishlistChecker(e).run();
    expect(report.needsLogin, 1);
    expect(report.ok, isTrue);
    expect(e.markedNeedsLogin, [puuid1]);
  });

  test('transient errors ask for a retry and are not marked as done', () async {
    final e = await env(
      accounts: const [account1, account2],
      wishlists: const {
        puuid1: {Fx.aresSentinels},
        puuid2: {Fx.aresSentinels},
      },
    );
    e.storefrontErrors[puuid1] = const TransientException(status: 503);
    final report = await WishlistChecker(e).run();
    expect(report.ok, isFalse);
    expect(report.failed, 1);
    expect(report.checked, 1);
    final state = WishlistCheckState(e.prefs);
    expect(state.checkedToday(puuid1, monday), isFalse);
    expect(state.checkedToday(puuid2, monday), isTrue);

    e.storefrontErrors.clear();
    await WishlistChecker(e).run();
    expect(state.checkedToday(puuid1, monday), isTrue);
  });

  test(
    'maintenance and bad data: no retry storm, tried again next run',
    () async {
      final e = await env();
      e.storefrontErrors[puuid1] = const MaintenanceException();
      final report = await WishlistChecker(e).run();
      expect(report.ok, isTrue);
      expect(report.failed, 1);
      expect(WishlistCheckState(e.prefs).checkedToday(puuid1, monday), isFalse);

      e.storefrontErrors.clear();
      e.storefrontJson = '<html>Cloudflare</html>';
      final odd = await WishlistChecker(e).run();
      expect(odd.checked, 1, reason: 'unparseable storefront = no hits');
      expect(e.notifications, isEmpty);
    },
  );

  test('content failure: retry later without any storefront call', () async {
    final e = await env();
    e.contentError = const TransientException();
    final report = await WishlistChecker(e).run();
    expect(report.ok, isFalse);
    expect(e.storefrontCalls, isEmpty);
  });

  test('never throws, even when every dependency fails', () async {
    final e = await env();
    e.notifyThrows = true;
    final report = await WishlistChecker(e).run();
    expect(report.checked, 1);
    expect(report.alerts, 0);

    final broken = await env();
    broken.accountsError = StateError('prefs');
    final r2 = await WishlistChecker(broken).run();
    expect(r2.ok, isFalse);
  });

  test('stops starting accounts once the time budget is spent', () async {
    final e = await env(
      accounts: const [account1, account2],
      wishlists: const {
        puuid1: {Fx.aresSentinels},
        puuid2: {Fx.aresSentinels},
      },
    );
    e.tick = const Duration(seconds: 20);
    final report = await WishlistChecker(
      e,
      budget: const Duration(seconds: 25),
    ).run();
    expect(e.storefrontCalls, isEmpty);
    expect(report.retry, isTrue);
  });

  test('uses the item language from the settings', () async {
    final prefs = await createTestPrefs({
      PrefKeys.appSettings:
          '{"wishlistNotifications": true, "itemLanguage": "en"}',
    });
    final e = _LanguageEnv(prefs, accountList: const [account1], now0: monday)
      ..wishlists[puuid1] = {Fx.aresSentinels};
    await WishlistChecker(e).run();
    expect(e.languages, [ItemLanguage.en.apiCode]);
  });

  test('uses the persisted content handoff independently of the UI and legacy setting', () async {
    final prefs = await createTestPrefs({
      PrefKeys.appSettings:
          '{"wishlistNotifications": true, "itemLanguage": "en"}',
      PrefKeys.effectiveLocale:
          '{"v":1,"app":"vi-VN","format":"vi","h24":true,"content":"ja-JP"}',
    });
    final e = _LanguageEnv(prefs, accountList: const [account1], now0: monday)
      ..wishlists[puuid1] = {Fx.aresSentinels};
    await WishlistChecker(e).run();
    expect(e.languages, ['ja-JP']);
    expect(e.notifications.single.title, 'Skin trong wishlist đã xuất hiện!');
  });

  group('"Chợ Đêm đã mở!"', () {
    List<NotifyCall> nightMarketNotices(FakeEnv e) => [
      for (final n in e.notifications)
        if (n.channel == NotificationChannel.nightMarket) n,
    ];

    test('both settings off → disabled', () async {
      final e = await env(enabled: false);
      final report = await WishlistChecker(e).run();
      expect(report.disabled, isTrue);
      expect(e.storefrontCalls, isEmpty);
    });

    test('sent for every account, even with an empty wishlist', () async {
      final e = await env(
        enabled: false,
        nightMarket: true,
        accounts: const [account1, account2],
        wishlists: const {},
      );
      final report = await WishlistChecker(e).run();
      expect(report.ok, isTrue);
      expect(report.nightMarkets, 2);
      expect(e.contentLoads, 0, reason: 'no skin names needed');
      final notices = nightMarketNotices(e);
      expect(notices, hasLength(2));
      expect(notices.first.title, NotificationStrings.nightMarketOpenTitle);
      expect(notices.first.body, contains('Người Chơi#VN2'));
      expect(
        notices.first.body,
        contains('3 thẻ'),
        reason: 'offers in the fixture',
      );
      expect(notices.first.id, NotificationIds.nightMarket(puuid1));
      expect(notices.first.payload, contains('segment=nightmarket'));
      expect(notices.first.payload, contains('account=$puuid1'));
      expect(notices.last.puuid, puuid2);
      expect(e.notifications, hasLength(2), reason: 'no wishlist alerts');
    });

    test('once per Night Market, again when a new one opens', () async {
      final e = await env(enabled: false, nightMarket: true);
      await WishlistChecker(e).run();
      expect(nightMarketNotices(e), hasLength(1));

      // Next days: the same Night Market (≈ 12.8 days left) is not repeated.
      e.now0 = DateTime.utc(2026, 9, 29, 5);
      await WishlistChecker(e).run();
      e.now0 = DateTime.utc(2026, 10, 5, 5);
      await WishlistChecker(e).run();
      expect(e.storefrontCalls, hasLength(3));
      expect(nightMarketNotices(e), hasLength(1));

      // Weeks later a new Night Market opens.
      e.now0 = DateTime.utc(2026, 12, 1, 5);
      await WishlistChecker(e).run();
      expect(nightMarketNotices(e), hasLength(2));
    });

    test('no Night Market in the storefront → nothing', () async {
      final e = await env(enabled: false, nightMarket: true)
        ..storefrontJson = (Map.of(economyFixture('storefront.json'))
          ..remove('BonusStore'));
      final report = await WishlistChecker(e).run();
      expect(report.checked, 1);
      expect(report.nightMarkets, 0);
      expect(e.notifications, isEmpty);
    });

    test('with the wishlist check on: one storefront read for both', () async {
      final e = await env(nightMarket: true);
      final report = await WishlistChecker(e).run();
      expect(e.storefrontCalls, [puuid1]);
      expect(report.nightMarkets, 1);
      expect(report.alerts, 2);
      expect(
        e.notifications.first.channel,
        NotificationChannel.nightMarket,
        reason: 'the opening notice comes before the skin alerts',
      );
    });

    test('a failed notification is retried at the next check', () async {
      final e = await env(enabled: false, nightMarket: true)
        ..notifyThrows = true;
      final first = await WishlistChecker(e).run();
      expect(first.nightMarkets, 0);

      e
        ..notifyThrows = false
        ..now0 = DateTime.utc(2026, 9, 29, 5);
      final next = await WishlistChecker(e).run();
      expect(next.nightMarkets, 1);
    });
  });

  group('WishlistCheckState', () {
    test('UTC day and next midnight', () {
      expect(
        WishlistCheckState.utcDay(DateTime.utc(2026, 9, 28, 13)),
        '2026-09-28',
      );
      // 06:59 in Vietnam (UTC+7) is still the previous UTC day.
      expect(
        WishlistCheckState.utcDay(DateTime.utc(2026, 9, 28, 13).toLocal()),
        '2026-09-28',
      );
      expect(
        WishlistCheckState.nextUtcMidnight(DateTime.utc(2026, 12, 31, 5)),
        DateTime.utc(2027),
      );
    });

    test('notified entries expire', () async {
      final prefs = await createTestPrefs();
      final state = WishlistCheckState(prefs);
      await state.saveNotified(puuid1, {
        'a': DateTime.utc(2026, 9, 28, 10),
        'b': DateTime.utc(2026, 9, 30),
      });
      expect(state.notified(puuid1, monday).keys, ['a', 'b']);
      expect(state.notified(puuid1, DateTime.utc(2026, 9, 29)).keys, ['b']);
      await prefs.setString(WishlistCheckState.notifiedKey(puuid1), 'garbage');
      expect(state.notified(puuid1, monday), isEmpty);
    });
  });
}

class _LanguageEnv extends FakeEnv {
  _LanguageEnv(super.prefs, {required super.accountList, required super.now0});

  final languages = <String>[];

  @override
  Future<ContentDb> loadContent(String language) {
    languages.add(language);
    return super.loadContent(language);
  }
}
