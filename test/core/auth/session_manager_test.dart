import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_repository.dart';
import 'package:valvn/core/auth/auth_callback.dart';
import 'package:valvn/core/auth/bootstrap_client.dart';
import 'package:valvn/core/auth/cookie_jar.dart';
import 'package:valvn/core/auth/account_lock.dart';
import 'package:valvn/core/auth/reauth_client.dart';
import 'package:valvn/core/auth/reauth_cooldown.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/config/client_version.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/core/network/async_semaphore.dart';
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
      cooldown: ReauthCooldown(clock: clock, jitter: () => 0),
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

  test('an unexplained failure retries once with the previous jar', () async {
    secure.values[SecureKeys.previousCookies(_puuid)] = const RiotCookieJar({
      'ssid': 'prev',
    }).encode();
    when(() => reauth.reauth(any(), postFirst: any(named: 'postFirst')))
        .thenAnswer((inv) async {
          final jar = inv.positionalArguments.first as RiotCookieJar;
          return jar['ssid'] == 'prev'
              ? ReauthOk(
                  _tokens(clock.now()),
                  const RiotCookieJar({'ssid': 'rotated'}),
                )
              : const ReauthTransient(
                  'callback_without_token',
                  RiotCookieJar({'ssid': 'old'}),
                );
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

  test('sign-out during a re-auth persists nothing afterwards', () async {
    final gate = Completer<ReauthOutcome>();
    when(() => reauth.reauth(any(), postFirst: any(named: 'postFirst')))
        .thenAnswer((_) => gate.future);
    final pending = manager.session(_puuid);
    // Sign-out order of AccountsNotifier.remove: metadata, then forget.
    await accounts.removeMetadata(_puuid);
    final forgetting = manager.forget(_puuid);
    gate.complete(
      ReauthOk(_tokens(clock.now()), const RiotCookieJar({'ssid': 'rotated'})),
    );
    await expectLater(pending, throwsA(isA<NeedsLoginException>()));
    await forgetting;
    expect(secure.values.keys.where((k) => k.contains(_puuid)), isEmpty);
    expect(manager.peek(_puuid), isNull);
  });

  test('forget alone blocks a running re-auth from writing back', () async {
    final gate = Completer<ReauthOutcome>();
    when(() => reauth.reauth(any(), postFirst: any(named: 'postFirst')))
        .thenAnswer((_) => gate.future);
    final pending = manager.session(_puuid);
    final forgetting = manager.forget(_puuid);
    gate.complete(
      ReauthOk(_tokens(clock.now()), const RiotCookieJar({'ssid': 'rotated'})),
    );
    await expectLater(pending, throwsA(isA<NeedsLoginException>()));
    await forgetting;
    expect(secure.values.keys.where((k) => k.contains(_puuid)), isEmpty);
  });

  test('establishFromLogin stores nothing when bootstrap fails', () async {
    secure.values.clear();
    when(() => bootstrap.fetchUserInfo(any()))
        .thenThrow(const TransientException(reason: 'network'));
    await expectLater(
      manager.establishFromLogin(
        tokens: _tokens(clock.now()),
        cookies: const RiotCookieJar({'ssid': 'fresh'}),
      ),
      throwsA(isA<TransientException>()),
    );
    expect(secure.values, isEmpty);
  });

  group('reportAuthFailureAfterReauth', () {
    setUp(() {
      when(
        () => reauth.reauth(any(), postFirst: any(named: 'postFirst')),
      ).thenAnswer(
        (_) async =>
            ReauthOk(_tokens(clock.now()), const RiotCookieJar({'ssid': 'n'})),
      );
    });

    test('same region: marks needsLogin, no more re-auth loops', () async {
      when(() => bootstrap.fetchRegion(any(), any()))
          .thenAnswer((_) async => 'ap');
      final s = await manager.session(_puuid);
      await manager.reportAuthFailureAfterReauth(
        _puuid,
        accessToken: s.accessToken,
      );
      // Region re-checked (unchanged) → needsLogin.
      verify(() => bootstrap.fetchRegion(any(), any())).called(1);
      expect(accounts.find(_puuid)!.needsLogin, isTrue);
      await expectLater(
        manager.refreshAfterAuthFailure(
          _puuid,
          failedAccessToken: s.accessToken,
        ),
        throwsA(isA<NeedsLoginException>()),
      );
      verify(() => reauth.reauth(any(), postFirst: any(named: 'postFirst')))
          .called(1);
    });

    test('changed region: moves the account instead of marking it', () async {
      when(() => bootstrap.fetchRegion(any(), any()))
          .thenAnswer((_) async => 'eu');
      final s = await manager.session(_puuid);
      await manager.reportAuthFailureAfterReauth(
        _puuid,
        accessToken: s.accessToken,
      );
      final account = accounts.find(_puuid)!;
      expect(account.needsLogin, isFalse);
      expect(account.region, 'eu');
      expect(manager.peek(_puuid)!.hosts.pd, 'https://pd.eu.a.pvp.net');
    });

    test('ignored for a superseded token', () async {
      final s = await manager.session(_puuid);
      await manager.reportAuthFailureAfterReauth(
        _puuid,
        accessToken: '${s.accessToken}-old',
      );
      verifyNever(() => bootstrap.fetchRegion(any(), any()));
      expect(accounts.find(_puuid)!.needsLogin, isFalse);
    });
  });

  group('traffic shaping (AR-001)', () {
    var reauthCount = 0;
    setUp(() => reauthCount = 0);

    void stubReauth(ReauthOutcome Function(RiotCookieJar jar) answer) {
      when(() => reauth.reauth(any(), postFirst: any(named: 'postFirst')))
          .thenAnswer((inv) async {
            reauthCount++;
            return answer(inv.positionalArguments.first as RiotCookieJar);
          });
    }

    // (mocktail's verify() consumes the calls it counts, so count by hand.)
    int reauthCalls() => reauthCount;

    ReauthTransient blocked(
      String reason, {
      int? status,
      Duration? retryAfter,
    }) => ReauthTransient(
      reason,
      const RiotCookieJar({'ssid': 'old', 'tdid': 't'}),
      status: status,
      retryAfter: retryAfter,
    );

    for (final (name, outcome) in [
      ('Cloudflare', blocked('cloudflare', status: 403)),
      ('429', blocked('rate_limited', status: 429)),
      ('5xx', blocked('server', status: 502)),
      ('a timeout', blocked('timeout')),
    ]) {
      test(
        '$name: no immediate second attempt, a 30 s cooldown starts',
        () async {
          // Even with a previous jar to try.
          secure.values[SecureKeys.previousCookies(
            _puuid,
          )] = const RiotCookieJar({'ssid': 'prev'})
              .encode();
          stubReauth((_) => outcome);
          await expectLater(
            manager.session(_puuid),
            throwsA(isA<TransientException>()),
          );
          expect(reauthCalls(), 1);
          expect(
            manager.reauthCooldownRemaining(_puuid),
            const Duration(seconds: 30),
          );
          expect(accounts.find(_puuid)!.needsLogin, isFalse);
        },
      );
    }

    test(
      'during the cooldown nothing goes to Riot and the wait shrinks',
      () async {
        stubReauth((_) => blocked('cloudflare', status: 403));
        await expectLater(
          manager.session(_puuid),
          throwsA(isA<TransientException>()),
        );
        clock.advance(const Duration(seconds: 10));
        await expectLater(
          manager.session(_puuid),
          throwsA(
            isA<TransientException>()
                .having((e) => e.reason, 'reason', 'reauth_cooldown')
                .having(
                  (e) => e.retryAfter,
                  'retryAfter',
                  const Duration(seconds: 20),
                ),
          ),
        );
        await expectLater(
          manager.refreshAfterAuthFailure(_puuid, failedAccessToken: 'x'),
          throwsA(isA<TransientException>()),
        );
        expect(reauthCalls(), 1);
      },
    );

    test(
      'after the cooldown it tries again; failures double the wait',
      () async {
        var attempts = 0;
        stubReauth((jar) {
          attempts++;
          return attempts < 3
              ? blocked('cloudflare', status: 403)
              : ReauthOk(
                  _tokens(clock.now()),
                  const RiotCookieJar({'ssid': 'new'}),
                );
        });
        await expectLater(
          manager.session(_puuid),
          throwsA(isA<TransientException>()),
        );
        clock.advance(const Duration(seconds: 31));
        await expectLater(
          manager.session(_puuid),
          throwsA(isA<TransientException>()),
        );
        expect(
          manager.reauthCooldownRemaining(_puuid),
          const Duration(seconds: 60),
        );
        clock.advance(const Duration(seconds: 61));
        final session = await manager.session(_puuid);
        expect(session.entitlementsToken, 'ENT');
        expect(reauthCalls(), 3);
        expect(manager.reauthCooldownRemaining(_puuid), isNull);
      },
    );

    test('Retry-After wins over the exponential delay', () async {
      stubReauth(
        (_) => blocked(
          'rate_limited',
          status: 429,
          retryAfter: const Duration(seconds: 90),
        ),
      );
      await expectLater(
        manager.session(_puuid),
        throwsA(
          isA<TransientException>().having(
            (e) => e.retryAfter,
            'retryAfter',
            const Duration(seconds: 90),
          ),
        ),
      );
      expect(
        manager.reauthCooldownRemaining(_puuid),
        const Duration(seconds: 90),
      );
    });

    test('a still-valid token is returned while cooling down', () async {
      var fail = false;
      stubReauth(
        (_) => fail
            ? blocked('cloudflare', status: 403)
            : ReauthOk(
                _tokens(clock.now()),
                const RiotCookieJar({'ssid': 'new'}),
              ),
      );
      final first = await manager.session(_puuid);
      fail = true;
      clock.advance(const Duration(minutes: 56)); // 4 min left: refresh due
      // The early refresh fails: the old token is still good.
      final second = await manager.session(_puuid);
      expect(second.accessToken, first.accessToken);
      expect(reauthCalls(), 2);
      clock.advance(const Duration(seconds: 10)); // still cooling down
      final third = await manager.session(_puuid);
      expect(third.accessToken, first.accessToken);
      expect(reauthCalls(), 2, reason: 'no request during the cooldown');
      // Cooldown over but the token expired at 60 min: a new attempt, which
      // fails, and now there is nothing valid to return.
      clock.advance(const Duration(minutes: 4));
      await expectLater(
        manager.session(_puuid),
        throwsA(isA<TransientException>()),
      );
      expect(reauthCalls(), 3);
    });

    test(
      'a token another isolate stored is used during the cooldown',
      () async {
        stubReauth((_) => blocked('cloudflare', status: 403));
        await expectLater(
          manager.session(_puuid),
          throwsA(isA<TransientException>()),
        );
        secure.values
          ..[SecureKeys.accessToken(_puuid)] = 'FROM_BACKGROUND'
          ..[SecureKeys.idToken(_puuid)] = 'ID'
          ..[SecureKeys.entitlementsToken(_puuid)] = 'ENT2'
          ..[SecureKeys.tokenExpiry(_puuid)] = clock
              .now()
              .add(const Duration(minutes: 40))
              .millisecondsSinceEpoch
              .toString();
        final session = await manager.session(_puuid);
        expect(session.accessToken, 'FROM_BACKGROUND');
        expect(reauthCalls(), 1);
      },
    );

    test(
      'a token the server just rejected is never served from the cache',
      () async {
        var fail = false;
        stubReauth(
          (_) => fail
              ? blocked('cloudflare', status: 403)
              : ReauthOk(
                  _tokens(clock.now()),
                  const RiotCookieJar({'ssid': 'new'}),
                ),
        );
        final good = await manager.session(_puuid);
        fail = true;
        await expectLater(
          manager.refreshAfterAuthFailure(
            _puuid,
            failedAccessToken: good.accessToken,
          ),
          throwsA(isA<TransientException>()),
        );
        await expectLater(
          manager.refreshAfterAuthFailure(
            _puuid,
            failedAccessToken: good.accessToken,
          ),
          throwsA(
            isA<TransientException>().having(
              (e) => e.reason,
              'reason',
              'reauth_cooldown',
            ),
          ),
        );
      },
    );

    test(
      'a host cooldown reported by the client is not a new failure',
      () async {
        stubReauth(
          (_) => blocked('cooldown', retryAfter: const Duration(seconds: 45)),
        );
        await expectLater(
          manager.session(_puuid),
          throwsA(isA<TransientException>()),
        );
        expect(
          manager.reauthCooldownRemaining(_puuid),
          const Duration(seconds: 45),
        );
        clock.advance(const Duration(seconds: 46));
        await expectLater(
          manager.session(_puuid),
          throwsA(isA<TransientException>()),
        );
        // The host's own wait was applied and no failure was counted.
        expect(
          manager.reauthCooldownRemaining(_puuid),
          const Duration(seconds: 45),
        );
      },
    );

    test('a lock timeout is not a failure of the account', () async {
      final lockedOut = SessionManager(
        secureStore: secure,
        accounts: accounts,
        reauthClient: reauth,
        bootstrapClient: bootstrap,
        versions: ClientVersionRepository(
          prefs: prefs,
          remoteConfig: () => RemoteConfig.defaults,
        ),
        lock: _ThrowingLock(),
        clock: clock,
      );
      await expectLater(
        lockedOut.session(_puuid),
        throwsA(
          isA<TransientException>().having(
            (e) => e.reason,
            'reason',
            'lock_timeout',
          ),
        ),
      );
      expect(lockedOut.reauthCooldownRemaining(_puuid), isNull);
    });

    test(
      'needsLogin and unknown accounts fail before the lock and network',
      () async {
        final lock = _CountingLock();
        final guarded = SessionManager(
          secureStore: secure,
          accounts: accounts,
          reauthClient: reauth,
          bootstrapClient: bootstrap,
          versions: ClientVersionRepository(
            prefs: prefs,
            remoteConfig: () => RemoteConfig.defaults,
          ),
          lock: lock,
          clock: clock,
        );
        await expectLater(
          guarded.session('00000000-0000-0000-0000-000000000000'),
          throwsA(
            isA<NeedsLoginException>().having(
              (e) => e.reason,
              'reason',
              'unknown_account',
            ),
          ),
        );
        await accounts.patch(_puuid, (a) => a.copyWith(needsLogin: true));
        await expectLater(
          guarded.session(_puuid),
          throwsA(
            isA<NeedsLoginException>().having(
              (e) => e.reason,
              'reason',
              'marked',
            ),
          ),
        );
        await expectLater(
          guarded.refreshAfterAuthFailure(_puuid, failedAccessToken: 'x'),
          throwsA(isA<NeedsLoginException>()),
        );
        expect(lock.runs, 0);
        verifyNever(
          () => reauth.reauth(any(), postFirst: any(named: 'postFirst')),
        );
      },
    );

    test('a failed bootstrap keeps the tokens: the retry does not rotate cookies again', () async {
      stubReauth(
        (_) => ReauthOk(
          _tokens(clock.now()),
          const RiotCookieJar({'ssid': 'rotated'}),
        ),
      );
      var bootstrapCalls = 0;
      when(() => bootstrap.fetchEntitlementsToken(any())).thenAnswer((_) async {
        bootstrapCalls++;
        if (bootstrapCalls == 1) {
          throw const TransientException(status: 503, reason: 'server');
        }
        return 'ENT2';
      });
      await expectLater(
        manager.session(_puuid),
        throwsA(isA<TransientException>()),
      );
      // The rotated cookies were stored before the bootstrap failed.
      expect(
        RiotCookieJar.decode(secure.values[SecureKeys.cookies(_puuid)])['ssid'],
        'rotated',
      );
      clock.advance(const Duration(seconds: 31));
      final session = await manager.session(_puuid);
      expect(session.entitlementsToken, 'ENT2');
      expect(
        reauthCalls(),
        1,
        reason: 'the tokens were kept: no second re-auth',
      );
      expect(bootstrapCalls, 2);
    });

    test('the kept tokens serve one retry only', () async {
      stubReauth(
        (_) => ReauthOk(
          _tokens(clock.now()),
          const RiotCookieJar({'ssid': 'rotated'}),
        ),
      );
      when(() => bootstrap.fetchEntitlementsToken(any()))
          .thenThrow(const TransientException(status: 503, reason: 'server'));
      await expectLater(
        manager.session(_puuid),
        throwsA(isA<TransientException>()),
      );
      clock.advance(const Duration(seconds: 31)); // bootstrap retry, fails
      await expectLater(
        manager.session(_puuid),
        throwsA(isA<TransientException>()),
      );
      expect(reauthCalls(), 1);
      clock.advance(const Duration(minutes: 2)); // tokens dropped: re-auth
      await expectLater(
        manager.session(_puuid),
        throwsA(isA<TransientException>()),
      );
      expect(reauthCalls(), 2);
    });

    test('expired kept tokens are not reused', () async {
      stubReauth(
        (_) => ReauthOk(
          _tokens(clock.now()),
          const RiotCookieJar({'ssid': 'rotated'}),
        ),
      );
      var fail = true;
      when(() => bootstrap.fetchEntitlementsToken(any())).thenAnswer((_) async {
        if (fail) throw const TransientException(reason: 'network');
        return 'ENT';
      });
      await expectLater(
        manager.session(_puuid),
        throwsA(isA<TransientException>()),
      );
      fail = false;
      clock.advance(const Duration(hours: 2));
      final session = await manager.session(_puuid);
      expect(session.entitlementsToken, 'ENT');
      expect(reauthCalls(), 2);
    });

    test('a jar of another account is never stored under this one', () async {
      const other = '99999999-9999-9999-9999-999999999999';
      stubReauth(
        (_) => ReauthOk(
          AuthTokens(
            accessToken: fakeJwt({'sub': other}),
            idToken: fakeJwt({'nonce': '1'}),
            expiresAt: clock.now().add(const Duration(hours: 1)),
            puuid: other,
          ),
          const RiotCookieJar({'ssid': 'foreign'}),
        ),
      );
      await expectLater(
        manager.session(_puuid),
        throwsA(
          isA<NeedsLoginException>().having(
            (e) => e.reason,
            'reason',
            'puuid_mismatch',
          ),
        ),
      );
      expect(
        RiotCookieJar.decode(secure.values[SecureKeys.cookies(_puuid)])['ssid'],
        'old',
        reason: 'the foreign jar must not overwrite this account\'s cookies',
      );
      expect(
        secure.values.containsKey(SecureKeys.previousCookies(_puuid)),
        isFalse,
      );
      expect(accounts.find(_puuid)!.needsLogin, isTrue);
    });

    test('forget and a new login clear the cooldown', () async {
      stubReauth((_) => blocked('cloudflare', status: 403));
      await expectLater(
        manager.session(_puuid),
        throwsA(isA<TransientException>()),
      );
      expect(manager.reauthCooldownRemaining(_puuid), isNotNull);
      when(() => bootstrap.fetchUserInfo(any())).thenAnswer(
        (_) async =>
            const RiotUserInfo(puuid: _puuid, gameName: 'T', tagLine: 'V'),
      );
      when(() => bootstrap.fetchRegion(any(), any()))
          .thenAnswer((_) async => 'ap');
      await manager.establishFromLogin(
        tokens: _tokens(clock.now()),
        cookies: const RiotCookieJar({'ssid': 'fresh'}),
      );
      expect(manager.reauthCooldownRemaining(_puuid), isNull);
      stubReauth((_) => blocked('cloudflare', status: 403));
      clock.advance(const Duration(hours: 2));
      await expectLater(
        manager.session(_puuid),
        throwsA(isA<TransientException>()),
      );
      expect(manager.reauthCooldownRemaining(_puuid), isNotNull);
      await manager.forget(_puuid);
      expect(manager.reauthCooldownRemaining(_puuid), isNull);
    });

    test(
      'at most two re-auths run at once, whatever the account count',
      () async {
        const ids = [
          '11111111-1111-1111-1111-111111111111',
          '22222222-2222-2222-2222-222222222222',
          '33333333-3333-3333-3333-333333333333',
          '44444444-4444-4444-4444-444444444444',
        ];
        for (final id in ids) {
          await accounts.upsert(
            Account(
              puuid: id,
              gameName: 'A',
              tagLine: 'B',
              region: 'ap',
              shard: 'ap',
            ),
          );
          secure.values[SecureKeys.cookies(id)] = RiotCookieJar({
            'ssid': 's-$id',
          }).encode();
        }
        var running = 0;
        var peak = 0;
        final gates = <String, Completer<void>>{
          for (final id in ids) id: Completer<void>(),
        };
        when(() => reauth.reauth(any(), postFirst: any(named: 'postFirst')))
            .thenAnswer((inv) async {
              final jar = inv.positionalArguments.first as RiotCookieJar;
              final id = jar['ssid']!.substring(2);
              running++;
              peak = running > peak ? running : peak;
              await gates[id]!.future;
              running--;
              return ReauthOk(
                AuthTokens(
                  accessToken: fakeJwt({'sub': id}),
                  idToken: fakeJwt({'nonce': '1'}),
                  expiresAt: clock.now().add(const Duration(hours: 1)),
                  puuid: id,
                ),
                RiotCookieJar({'ssid': 'n-$id'}),
              );
            });
        final futures = [for (final id in ids) manager.session(id)];
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(running, SessionManager.reauthConcurrency);
        gates[ids[0]]!.complete();
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(running, 2, reason: 'the third re-auth took the freed slot');
        for (final id in ids) {
          if (!gates[id]!.isCompleted) gates[id]!.complete();
        }
        await Future.wait(futures);
        expect(peak, 2);
      },
    );

    test('the gate is injectable (one at a time)', () async {
      final serial = SessionManager(
        secureStore: secure,
        accounts: accounts,
        reauthClient: reauth,
        bootstrapClient: bootstrap,
        versions: ClientVersionRepository(
          prefs: prefs,
          remoteConfig: () => RemoteConfig.defaults,
        ),
        clock: clock,
        reauthGate: AsyncSemaphore(1),
      );
      stubReauth(
        (_) =>
            ReauthOk(_tokens(clock.now()), const RiotCookieJar({'ssid': 'n'})),
      );
      expect((await serial.session(_puuid)).entitlementsToken, 'ENT');
    });
  });

  group('isBlockingReauthTransient', () {
    const jar = RiotCookieJar({'ssid': 's'});
    test('429, Cloudflare, 5xx, timeouts and cooldowns block', () {
      for (final t in [
        const ReauthTransient('rate_limited', jar, status: 429),
        const ReauthTransient('cloudflare', jar, status: 403),
        const ReauthTransient('server', jar, status: 500),
        const ReauthTransient('server', jar, status: 503),
        const ReauthTransient('timeout', jar),
        const ReauthTransient('network', jar),
        const ReauthTransient('cooldown', jar),
      ]) {
        expect(isBlockingReauthTransient(t), isTrue, reason: t.reason);
      }
    });

    test('unexplained answers do not', () {
      for (final t in [
        const ReauthTransient('callback_without_token', jar),
        const ReauthTransient('http_200', jar),
        const ReauthTransient('non_json_200', jar),
        const ReauthTransient('previous_jar_unverified', jar),
      ]) {
        expect(isBlockingReauthTransient(t), isFalse, reason: t.reason);
      }
    });
  });
}

/// Counts how many times the cross-isolate lock was taken.
class _CountingLock implements AccountLock {
  int runs = 0;

  @override
  Future<T> run<T>(String puuid, Future<T> Function() body) {
    runs++;
    return body();
  }
}

class _ThrowingLock implements AccountLock {
  @override
  Future<T> run<T>(String puuid, Future<T> Function() body) =>
      throw const TransientException(reason: 'lock_timeout');
}
