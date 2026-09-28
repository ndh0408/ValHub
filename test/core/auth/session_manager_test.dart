import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_repository.dart';
import 'package:valvn/core/auth/auth_callback.dart';
import 'package:valvn/core/auth/bootstrap_client.dart';
import 'package:valvn/core/auth/cookie_jar.dart';
import 'package:valvn/core/auth/reauth_client.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/config/client_version.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/util/clock.dart';

import '../../helpers/jwt.dart';
import '../../helpers/test_prefs.dart';

class MockReauth extends Mock implements RiotReauthClient {}

class MockBootstrap extends Mock implements RiotBootstrapClient {}

const _puuid = '41c322a1-b328-495b-a004-5ccd3e45eae8';

AuthTokens _tokens(DateTime now, {String access = 'A1'}) => AuthTokens(
  accessToken: fakeJwt({'sub': _puuid, 'jti': access}),
  idToken: fakeJwt({'nonce': '1'}),
  expiresAt: now.add(const Duration(hours: 1)),
  puuid: _puuid,
);

void main() {
  setUpAll(() => registerFallbackValue(const RiotCookieJar()));

  late Prefs prefs;
  late MemorySecureStore secure;
  late AccountRepository accounts;
  late MockReauth reauth;
  late MockBootstrap bootstrap;
  late FixedClock clock;
  late SessionManager manager;

  setUp(() async {
    prefs = await createTestPrefs();
    secure = MemorySecureStore({
      SecureKeys.cookies(_puuid): const RiotCookieJar({
        'ssid': 'old',
        'tdid': 't',
      }).encode(),
    });
    accounts = AccountRepository(prefs: prefs, secureStore: secure);
    await accounts.upsert(
      const Account(
        puuid: _puuid,
        gameName: 'Tên',
        tagLine: 'VN1',
        region: 'ap',
        shard: 'ap',
      ),
    );
    reauth = MockReauth();
    bootstrap = MockBootstrap();
    clock = FixedClock(DateTime(2026, 9, 28, 12));
    when(() => bootstrap.fetchEntitlementsToken(any()))
        .thenAnswer((_) async => 'ENT');
    manager = SessionManager(
      secureStore: secure,
      accounts: accounts,
      reauthClient: reauth,
      bootstrapClient: bootstrap,
      versions: ClientVersionRepository(
        prefs: prefs,
        remoteConfig: () => RemoteConfig.defaults,
      ),
      clock: clock,
    );
  });

  test(
    're-auth persists rotated cookies before bootstrap, keeps the previous jar',
    () async {
      when(() => reauth.reauth(any(), postFirst: any(named: 'postFirst')))
          .thenAnswer(
            (_) async => ReauthOk(
              _tokens(clock.now()),
              const RiotCookieJar({'ssid': 'new', 'tdid': 't'}),
            ),
          );
      String? cookiesAtBootstrap;
      when(() => bootstrap.fetchEntitlementsToken(any())).thenAnswer((_) async {
        cookiesAtBootstrap = secure.values[SecureKeys.cookies(_puuid)];
        return 'ENT';
      });

      final session = await manager.session(_puuid);

      expect(session.entitlementsToken, 'ENT');
      expect(session.hosts.pd, 'https://pd.ap.a.pvp.net');
      expect(
        session.gameHeaders['X-Riot-ClientVersion'],
        'release-13.06-shipping-13-5435758',
      );
      expect(RiotCookieJar.decode(cookiesAtBootstrap)['ssid'], 'new');
      expect(
        RiotCookieJar.decode(
          secure.values[SecureKeys.previousCookies(_puuid)],
        )['ssid'],
        'old',
      );
      expect(secure.values[SecureKeys.entitlementsToken(_puuid)], 'ENT');
      expect(session.toString(), isNot(contains(session.accessToken)));
    },
  );

  test('cached session is reused until < 5 min remain', () async {
    when(
      () => reauth.reauth(any(), postFirst: any(named: 'postFirst')),
    ).thenAnswer(
      (_) async =>
          ReauthOk(_tokens(clock.now()), const RiotCookieJar({'ssid': 'n'})),
    );
    await manager.session(_puuid);
    clock.advance(const Duration(minutes: 30));
    await manager.session(_puuid);
    verify(() => reauth.reauth(any(), postFirst: any(named: 'postFirst')))
        .called(1);

    clock.advance(const Duration(minutes: 26)); // 4 min left
    await manager.session(_puuid);
    verify(() => reauth.reauth(any(), postFirst: any(named: 'postFirst')))
        .called(1);
  });

  test('concurrent callers share one re-auth (single-flight)', () async {
    final gate = Completer<ReauthOutcome>();
    when(() => reauth.reauth(any(), postFirst: any(named: 'postFirst')))
        .thenAnswer((_) => gate.future);
    final a = manager.session(_puuid);
    final b = manager.session(_puuid);
    gate.complete(
      ReauthOk(_tokens(clock.now()), const RiotCookieJar({'ssid': 'n'})),
    );
    final results = await Future.wait([a, b]);
    expect(identical(results[0], results[1]), isTrue);
    verify(() => reauth.reauth(any(), postFirst: any(named: 'postFirst')))
        .called(1);
  });

  test('dead cookies mark the account once and never loop', () async {
    when(() => reauth.reauth(any(), postFirst: any(named: 'postFirst')))
        .thenAnswer(
          (_) async => const ReauthNeedsLogin(
            'login_required',
            RiotCookieJar({'ssid': 'old'}),
          ),
        );
    final events = <SessionEvent>[];
    final sub = manager.events.listen(events.add);

    await expectLater(
      manager.session(_puuid),
      throwsA(isA<NeedsLoginException>()),
    );
    expect(accounts.find(_puuid)!.needsLogin, isTrue);
    await expectLater(
      manager.session(_puuid),
      throwsA(isA<NeedsLoginException>()),
    );
    // First attempt + one retry; the second call does not hit Riot again.
    verify(() => reauth.reauth(any(), postFirst: any(named: 'postFirst')))
        .called(2);
    await Future<void>.delayed(Duration.zero);
    expect(events.whereType<SessionNeedsLogin>(), hasLength(1));
    await sub.cancel();
  });

  test('transient failure retries once with the previous jar', () async {
    secure.values[SecureKeys.previousCookies(_puuid)] = const RiotCookieJar({
      'ssid': 'prev',
    }).encode();
    when(
      () => reauth.reauth(any(), postFirst: any(named: 'postFirst')),
    ).thenAnswer((inv) async {
      final jar = inv.positionalArguments.first as RiotCookieJar;
      return jar['ssid'] == 'prev'
          ? ReauthOk(
              _tokens(clock.now()),
              const RiotCookieJar({'ssid': 'rotated'}),
            )
          : const ReauthTransient('cloudflare', RiotCookieJar({'ssid': 'old'}));
    });
    final session = await manager.session(_puuid);
    expect(session.entitlementsToken, 'ENT');
    expect(
      RiotCookieJar.decode(secure.values[SecureKeys.cookies(_puuid)])['ssid'],
      'rotated',
    );
    expect(
      RiotCookieJar.decode(
        secure.values[SecureKeys.previousCookies(_puuid)],
      )['ssid'],
      'prev',
    );
  });

  test('persistent transient errors keep the session and surface TransientException', () async {
    when(() => reauth.reauth(any(), postFirst: any(named: 'postFirst')))
        .thenAnswer(
          (_) async => const ReauthTransient(
            'rate_limited',
            RiotCookieJar({'ssid': 'old'}),
            retryAfter: Duration(seconds: 30),
          ),
        );
    await expectLater(
      manager.session(_puuid),
      throwsA(
        isA<TransientException>().having(
          (e) => e.retryAfter,
          'retryAfter',
          const Duration(seconds: 30),
        ),
      ),
    );
    expect(accounts.find(_puuid)!.needsLogin, isFalse);
    expect(
      RiotCookieJar.decode(secure.values[SecureKeys.cookies(_puuid)])['ssid'],
      'old',
    );
  });

  test('auth failure with a stale token reuses the newer session', () async {
    var n = 0;
    when(() => reauth.reauth(any(), postFirst: any(named: 'postFirst')))
        .thenAnswer(
          (_) async => ReauthOk(
            _tokens(clock.now(), access: 'A${++n}'),
            const RiotCookieJar({'ssid': 'n'}),
          ),
        );
    final first = await manager.session(_puuid);
    final second = await manager.refreshAfterAuthFailure(
      _puuid,
      failedAccessToken: first.accessToken,
    );
    expect(second.accessToken, isNot(first.accessToken));
    final third = await manager.refreshAfterAuthFailure(
      _puuid,
      failedAccessToken: first.accessToken,
    );
    expect(third.accessToken, second.accessToken);
    verify(() => reauth.reauth(any(), postFirst: any(named: 'postFirst')))
        .called(2);
  });

  test('token cache from another isolate is used without re-auth', () async {
    secure.values
      ..[SecureKeys.accessToken(_puuid)] = 'CACHED'
      ..[SecureKeys.idToken(_puuid)] = 'ID'
      ..[SecureKeys.entitlementsToken(_puuid)] = 'ENT2'
      ..[SecureKeys.tokenExpiry(_puuid)] = clock
          .now()
          .add(const Duration(minutes: 40))
          .millisecondsSinceEpoch
          .toString();
    final session = await manager.session(_puuid);
    expect(session.accessToken, 'CACHED');
    verifyNever(() => reauth.reauth(any(), postFirst: any(named: 'postFirst')));
  });

  test(
    'establishFromLogin stores cookies, token cache and bootstrap data',
    () async {
      when(() => bootstrap.fetchUserInfo(any())).thenAnswer(
        (_) async =>
            const RiotUserInfo(puuid: _puuid, gameName: 'Tên', tagLine: 'VN1'),
      );
      when(() => bootstrap.fetchRegion(any(), any()))
          .thenAnswer((_) async => 'ap');
      final result = await manager.establishFromLogin(
        tokens: _tokens(clock.now()),
        cookies: const RiotCookieJar({'ssid': 'fresh', 'tdid': 't'}),
      );
      expect(result.hasSessionCookie, isTrue);
      expect(result.userInfo.gameName, 'Tên');
      expect(result.session.region, 'ap');
      expect(
        RiotCookieJar.decode(secure.values[SecureKeys.cookies(_puuid)])['ssid'],
        'fresh',
      );
      expect(
        RiotCookieJar.decode(
          secure.values[SecureKeys.previousCookies(_puuid)],
        )['ssid'],
        'old',
      );
    },
  );

  test('forget wipes every secret of the account', () async {
    secure.values[SecureKeys.accessToken(_puuid)] = 'x';
    await manager.forget(_puuid);
    expect(secure.values.keys.where((k) => k.contains(_puuid)), isEmpty);
  });
}
