import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/auth/auth_callback.dart';
import 'package:valvn/core/auth/auth_providers.dart';
import 'package:valvn/core/auth/bootstrap_client.dart';
import 'package:valvn/core/auth/cookie_jar.dart';
import 'package:valvn/core/auth/riot_session.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/riot/riot_hosts.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/wishlist/wishlist_store.dart';

import '../../helpers/test_prefs.dart';

class MockSessions extends Mock implements SessionManager {}

class FakeNotifications extends NotificationService {
  final cancelled = <String>[];

  @override
  Future<void> cancelForAccount(String puuid) async => cancelled.add(puuid);
}

String _puuid(int i) =>
    '00000000-0000-0000-0000-${i.toString().padLeft(12, '0')}';

Account _account(int i) => Account(
  puuid: _puuid(i),
  gameName: 'P$i',
  tagLine: 'VN',
  region: 'ap',
  shard: 'ap',
);

void main() {
  setUpAll(() {
    registerFallbackValue(const RiotCookieJar());
    registerFallbackValue(
      AuthTokens(
        accessToken: 'a',
        idToken: 'i',
        expiresAt: DateTime(2100),
        puuid: 'p',
      ),
    );
  });

  late Prefs prefs;
  late MemorySecureStore secure;
  late MockSessions sessions;
  late FakeNotifications notifications;
  late Directory tmp;

  setUp(() async {
    prefs = await createTestPrefs();
    secure = MemorySecureStore();
    sessions = MockSessions();
    notifications = FakeNotifications();
    tmp = await Directory.systemTemp.createTemp('valvn_test');
    when(() => sessions.events).thenAnswer((_) => const Stream.empty());
    when(() => sessions.forget(any())).thenAnswer((_) async {});
  });

  tearDown(() => tmp.delete(recursive: true));

  ProviderContainer container() => ProviderContainer.test(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      secureStoreProvider.overrideWithValue(secure),
      sessionManagerProvider.overrideWithValue(sessions),
      notificationServiceProvider.overrideWithValue(notifications),
      jsonFileCacheProvider.overrideWithValue(JsonFileCache(() async => tmp)),
    ],
  );

  AuthTokens tokens(int i) => AuthTokens(
    accessToken: 'a',
    idToken: 'i',
    expiresAt: DateTime(2100),
    puuid: _puuid(i),
  );

  void stubLogin(int i) {
    when(
      () => sessions.establishFromLogin(
        tokens: any(named: 'tokens'),
        cookies: any(named: 'cookies'),
      ),
    ).thenAnswer(
      (_) async => LoginEstablished(
        session: RiotSession(
          puuid: _puuid(i),
          accessToken: 'a',
          idToken: 'i',
          entitlementsToken: 'e',
          expiresAt: DateTime(2100),
          hosts: RiotHosts.forRegion('ap'),
          clientVersion: 'v',
          userAgent: 'ua',
        ),
        userInfo: RiotUserInfo(
          puuid: _puuid(i),
          gameName: 'New$i',
          tagLine: 'VN1',
        ),
        hasSessionCookie: true,
      ),
    );
  }

  test('completeLogin adds the account and makes it active', () async {
    final c = container();
    stubLogin(1);
    final account = await c
        .read(accountsProvider.notifier)
        .completeLogin(
          tokens: tokens(1),
          cookies: const RiotCookieJar({'ssid': 's'}),
        );
    expect(account.riotId, 'New1#VN1');
    expect(c.read(accountsProvider), hasLength(1));
    expect(c.read(activeAccountProvider)?.puuid, _puuid(1));
    expect(c.read(hasAccountsProvider), isTrue);
  });

  test('the 11th account is refused before any cookie is stored', () async {
    await prefs.setJson(PrefKeys.accounts, [
      for (var i = 0; i < 10; i++) _account(i).toJson(),
    ]);
    final c = container();
    await expectLater(
      c
          .read(accountsProvider.notifier)
          .completeLogin(
            tokens: tokens(42),
            cookies: const RiotCookieJar({'ssid': 's'}),
          ),
      throwsA(
        isA<MaxAccountsException>().having(
          (e) => e.message,
          'message',
          'Đã đạt tối đa 10 tài khoản.',
        ),
      ),
    );
    verifyNever(
      () => sessions.establishFromLogin(
        tokens: any(named: 'tokens'),
        cookies: any(named: 'cookies'),
      ),
    );
  });

  test('re-login of an existing account is allowed when full and clears needsLogin', () async {
    await prefs.setJson(PrefKeys.accounts, [
      for (var i = 0; i < 10; i++)
        _account(i).copyWith(needsLogin: i == 3).toJson(),
    ]);
    final c = container();
    stubLogin(3);
    await c
        .read(accountsProvider.notifier)
        .completeLogin(
          tokens: tokens(3),
          cookies: const RiotCookieJar({'ssid': 's'}),
        );
    expect(
      c
          .read(accountsProvider)
          .firstWhere((a) => a.puuid == _puuid(3))
          .needsLogin,
      isFalse,
    );
  });

  test(
    'remove wipes secrets, per-account prefs and caches but keeps the wishlist',
    () async {
      await prefs.setJson(PrefKeys.accounts, [
        _account(1).toJson(),
        _account(2).toJson(),
      ]);
      await prefs.setString(PrefKeys.activePuuid, _puuid(1));
      await prefs.setString(PrefKeys.account(_puuid(1), 'something'), 'x');
      await WishlistRepository(prefs).write(_puuid(1), {'skin-a'});
      secure.values[SecureKeys.cookies(_puuid(1))] = '{}';
      secure.values[SecureKeys.cookies(_puuid(2))] = '{}';
      final cache = JsonFileCache(() async => tmp);
      await cache.write(JsonFileCache.accountKey(_puuid(1), 'storefront'), {
        'x': 1,
      });

      final c = container();
      await c
          .read(accountsProvider.notifier)
          .remove(_puuid(1), keepLocalData: true);

      expect(c.read(accountsProvider).map((a) => a.puuid), [_puuid(2)]);
      expect(c.read(activePuuidProvider), _puuid(2));
      expect(secure.values.containsKey(SecureKeys.cookies(_puuid(1))), isFalse);
      expect(secure.values.containsKey(SecureKeys.cookies(_puuid(2))), isTrue);
      expect(prefs.getString(PrefKeys.account(_puuid(1), 'something')), isNull);
      expect(WishlistRepository(prefs).read(_puuid(1)), {'skin-a'});
      expect(
        await cache.read(JsonFileCache.accountKey(_puuid(1), 'storefront')),
        isNull,
      );
      expect(notifications.cancelled, [_puuid(1)]);
      verify(() => sessions.forget(_puuid(1))).called(1);
    },
  );

  test(
    'active account falls back to the first one and persists switches',
    () async {
      await prefs.setJson(PrefKeys.accounts, [
        _account(1).toJson(),
        _account(2).toJson(),
      ]);
      await prefs.setString(PrefKeys.activePuuid, 'gone');
      final c = container();
      expect(c.read(activePuuidProvider), _puuid(1));
      c.read(activePuuidProvider.notifier).select(_puuid(2));
      expect(c.read(activeAccountProvider)?.gameName, 'P2');
      expect(prefs.getString(PrefKeys.activePuuid), _puuid(2));
    },
  );

  test('corrupt stored metadata is skipped', () async {
    await prefs.setJson(PrefKeys.accounts, [
      {'puuid': null},
      'junk',
      _account(1).toJson(),
      _account(1).toJson(),
    ]);
    expect(container().read(accountsProvider), hasLength(1));
  });

  test('Account JSON round-trip and Riot ID', () {
    final a = _account(7)
        .copyWith(platform: GamePlatform.playstation, level: 222, rankTier: 18);
    expect(Account.fromJson(a.toJson()), a);
    expect(a.riotId, 'P7#VN');
    expect(a.platform.label, 'PlayStation');
    expect(a.toString(), isNot(contains(a.puuid)));
    expect(Account.fromJson({'puuid': 'X', 'region': 'latam'})!.shard, 'na');
  });
}
