import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/auth/auth_callback.dart';
import 'package:valvn/core/auth/jwt.dart';

import '../../helpers/jwt.dart';

const _puuid = '41c322a1-b328-495b-a004-5ccd3e45eae8';
const _state = 'state123';
const _nonce = 'nonce456';

String _access({String sub = _puuid}) =>
    fakeJwt({'sub': sub, 'exp': 2000000000});
String _id({String nonce = _nonce}) => fakeJwt({'sub': _puuid, 'nonce': nonce});

Uri _callback({
  String path = '/opt_in',
  String host = 'playvalorant.com',
  String? access,
  String? id,
  String state = _state,
  String extra = '',
}) => Uri.parse(
  'https://$host$path#access_token=${access ?? _access()}'
  '&scope=openid&iss=https%3A%2F%2Fauth.riotgames.com'
  '&id_token=${id ?? _id()}&token_type=Bearer&session_state=abc'
  '&expires_in=3600&state=$state$extra',
);

void main() {
  group('authorize URL', () {
    test('login URL matches SUMMARY §3.2 with %20 encoding', () {
      final url = buildAuthorizeUrl(state: 's', nonce: 'n');
      expect(
        url,
        'https://auth.riotgames.com/authorize?redirect_uri=https%3A%2F%2Fplayvalorant.com%2Fopt_in'
        '&client_id=play-valorant-web-prod&response_type=token%20id_token'
        '&scope=account%20openid&nonce=n&state=s&ui_locales=vi',
      );
    });

    test('re-auth URL uses nonce=1&prompt=none', () {
      expect(reauthAuthorizeUrl, endsWith('&nonce=1&prompt=none'));
      expect(reauthAuthorizeUrl, contains('response_type=token%20id_token'));
    });

    test('randomHex is 64 lowercase hex chars for 32 bytes', () {
      final s = randomHex(32, Random(1));
      expect(s, hasLength(64));
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(s), isTrue);
      expect(randomHex(), isNot(randomHex()));
    });
  });

  group('callback matcher', () {
    test('accepts /opt_in, trailing slash and localized paths', () {
      expect(isAuthCallback(_callback()), isTrue);
      expect(isAuthCallback(_callback(path: '/opt_in/')), isTrue);
      expect(isAuthCallback(_callback(path: '/vi-vn/opt_in/')), isTrue);
      expect(isAuthCallback(_callback(path: '/en-US/opt_in')), isTrue);
      expect(isAuthCallback(_callback(host: 'www.playvalorant.com')), isTrue);
    });

    test('accepts error fragments', () {
      expect(
        isAuthCallback(
          Uri.parse(
            'https://playvalorant.com/opt_in#error=interaction_required'
            '&iss=https%3A%2F%2Fauth.riotgames.com&error_description=login_required',
          ),
        ),
        isTrue,
      );
    });

    test('rejects look-alikes and callbacks without tokens', () {
      expect(
        isAuthCallback(
          Uri.parse('http://playvalorant.com/opt_in#access_token=x'),
        ),
        isFalse,
      );
      expect(
        isAuthCallback(
          Uri.parse('https://evilplayvalorant.com/opt_in#access_token=x'),
        ),
        isFalse,
      );
      expect(
        isAuthCallback(
          Uri.parse('https://playvalorant.com.evil.io/opt_in#access_token=x'),
        ),
        isFalse,
      );
      expect(
        isAuthCallback(
          Uri.parse('https://playvalorant.com/opt_in_other#access_token=x'),
        ),
        isFalse,
      );
      expect(
        isAuthCallback(
          Uri.parse(
            'https://playvalorant.com/vi-vn/news/opt_in#access_token=x',
          ),
        ),
        isFalse,
      );
      expect(
        isAuthCallback(Uri.parse('https://playvalorant.com/opt_in')),
        isFalse,
      );
      expect(
        isAuthCallback(Uri.parse('https://auth.riotgames.com/authorize?x=1')),
        isFalse,
      );
      expect(isAuthCallback(null), isFalse);
    });

    test('query fallback when there is no fragment', () {
      expect(
        isAuthCallback(
          Uri.parse('https://playvalorant.com/opt_in?access_token=x'),
        ),
        isTrue,
      );
    });
  });

  group('parser', () {
    test('decodes form-encoded values and keeps duplicates', () {
      final p = parseParamString('a=1&b=x%20y&b=z&c=a+b&empty=&=bad');
      expect(p['a'], ['1']);
      expect(p['b'], ['x y', 'z']);
      expect(p['c'], ['a b']);
      expect(p['empty'], ['']);
      expect(p.containsKey(''), isFalse);
    });
  });

  group('validator', () {
    final received = DateTime(2026, 9, 28, 12);

    CallbackResult validate(Uri uri, {String? expectedPuuid}) =>
        validateCallback(
          parseCallbackParams(uri),
          expectedState: _state,
          expectedNonce: _nonce,
          expectedPuuid: expectedPuuid,
          receivedAt: received,
        );

    test('valid callback yields tokens and the PUUID', () {
      final r = validate(_callback(path: '/vi-vn/opt_in/'));
      expect(r, isA<CallbackSuccess>());
      final tokens = (r as CallbackSuccess).tokens;
      expect(tokens.puuid, _puuid);
      expect(tokens.expiresAt, received.add(const Duration(hours: 1)));
    });

    test('error fragment is a Riot error', () {
      final r = validate(
        Uri.parse(
          'https://playvalorant.com/opt_in#error=access_denied&state=$_state',
        ),
      );
      expect(r, isA<CallbackRejected>());
      expect((r as CallbackRejected).failure, CallbackFailure.riotError);
      expect(r.error, 'access_denied');
    });

    test('state mismatch or missing state is rejected', () {
      final r = validate(_callback(state: 'other'));
      expect((r as CallbackRejected).failure, CallbackFailure.stateMismatch);
      final missing = validate(
        Uri.parse('https://playvalorant.com/opt_in#access_token=${_access()}'),
      );
      expect(
        (missing as CallbackRejected).failure,
        CallbackFailure.stateMismatch,
      );
    });

    test('duplicated or missing tokens are rejected', () {
      final dup = validate(_callback(extra: '&access_token=${_access()}'));
      expect((dup as CallbackRejected).failure, CallbackFailure.invalidTokens);
      final dupState = validate(_callback(extra: '&state=$_state'));
      expect(
        (dupState as CallbackRejected).failure,
        CallbackFailure.stateMismatch,
      );
      final noId = validate(
        Uri.parse(
          'https://playvalorant.com/opt_in#access_token=${_access()}&state=$_state',
        ),
      );
      expect((noId as CallbackRejected).failure, CallbackFailure.invalidTokens);
    });

    test('nonce must match the id_token claim', () {
      final r = validate(_callback(id: _id(nonce: 'wrong')));
      expect((r as CallbackRejected).failure, CallbackFailure.nonceMismatch);
    });

    test('re-login into a different account is reported with its tokens', () {
      final r = validate(
        _callback(),
        expectedPuuid: 'aaaaaaaa-0000-0000-0000-000000000000',
      );
      expect((r as CallbackRejected).failure, CallbackFailure.accountMismatch);
      expect(r.actualPuuid, _puuid);
      expect(r.tokens, isNotNull);
      final same = validate(_callback(), expectedPuuid: _puuid.toUpperCase());
      expect(same, isA<CallbackSuccess>());
    });
  });

  group('jwt', () {
    test('decodes payload claims without verification', () {
      final token = fakeJwt({'sub': 'ABC', 'exp': 1700000000, 'nonce': 'n'});
      expect(jwtSubject(token), 'abc');
      expect(
        jwtExpiry(token),
        DateTime.fromMillisecondsSinceEpoch(1700000000000, isUtc: true),
      );
      expect(jwtNonce(token), 'n');
    });

    test('garbage yields null', () {
      expect(decodeJwtPayload('not-a-jwt'), isNull);
      expect(decodeJwtPayload('a.!!!.c'), isNull);
      expect(decodeJwtPayload(null), isNull);
    });
  });

  test('login navigation allowlist', () {
    expect(isAllowedLoginHost('auth.riotgames.com'), isTrue);
    expect(isAllowedLoginHost('authenticate.riotgames.com'), isTrue);
    expect(isAllowedLoginHost('playvalorant.com'), isTrue);
    expect(isAllowedLoginHost('accounts.google.com'), isTrue);
    expect(isAllowedLoginHost('newassets.hcaptcha.com'), isTrue);
    expect(isAllowedLoginHost('lolstatic-a.akamaihd.net'), isTrue);
    expect(isAllowedLoginHost('support-valorant.riotgames.com'), isTrue);
    expect(isAllowedLoginHost('riotgames.com.evil.io'), isFalse);
    expect(isAllowedLoginHost('example.com'), isFalse);
  });

  test('lolstatic hosts: exact or .lolstatic.com suffix only (AR-021)', () {
    expect(isAllowedLoginHost('lolstatic.com'), isTrue);
    expect(isAllowedLoginHost('static.lolstatic.com'), isTrue);
    expect(isAllowedLoginHost('LOLSTATIC-A.AKAMAIHD.NET'), isTrue);
    for (final bad in [
      'lolstatic.evil.com',
      'lolstatic-evil.com',
      'lolstatic',
      'lolstatic.com.evil.io',
      'evillolstatic.com',
      'lolstatic-b.akamaihd.net',
      'x.lolstatic-a.akamaihd.net',
    ]) {
      expect(isAllowedLoginHost(bad), isFalse, reason: bad);
    }
  });
}
