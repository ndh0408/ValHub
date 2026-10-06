import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/auth/cookie_jar.dart';

void main() {
  final now = DateTime.utc(2026, 9, 28);

  test('merges rotated cookies and keeps the others', () {
    const jar = RiotCookieJar({'ssid': 'old', 'tdid': 't', 'asid': 'a'});
    final next = jar.merge([
      'ssid=new; Path=/; Max-Age=2592000; Secure; HttpOnly; SameSite=None',
      'clid=uw1; Path=/; Max-Age=2592000',
      'csid=c1; Expires=Thu, 29 Oct 2026 00:00:00 GMT; Path=/',
    ], now: now);
    expect(next.cookies, {
      'ssid': 'new',
      'tdid': 't',
      'asid': 'a',
      'clid': 'uw1',
      'csid': 'c1',
    });
    expect(jar['ssid'], 'old', reason: 'jars are immutable');
  });

  test('expired cookies are removed', () {
    const jar = RiotCookieJar({
      'ssid': 's',
      'sub': 'x',
      'ccid': 'c',
      'tmp': 't',
    });
    final next = jar.merge([
      'sub=; Path=/; Max-Age=0',
      'ccid=gone; Expires=Thu, 01 Jan 1970 00:00:00 GMT',
      'tmp=bye; Expires=Thu, 01-Jan-1970 00:00:00 GMT',
    ], now: now);
    expect(next.cookies, {'ssid': 's'});
  });

  test('malformed headers are ignored, quoted values unquoted', () {
    const jar = RiotCookieJar();
    final next = jar.merge([
      'garbage',
      '=noname',
      'q="quoted"; Path=/',
    ], now: now);
    expect(next.cookies, {'q': 'quoted'});
    expect(jar.merge(null), same(jar));
  });

  test('header and JSON round-trip', () {
    const jar = RiotCookieJar({'ssid': 's', 'tdid': 't'});
    expect(jar.header, 'ssid=s; tdid=t');
    expect(RiotCookieJar.decode(jar.encode()), jar);
    expect(RiotCookieJar.decode('<html>'), const RiotCookieJar());
    expect(RiotCookieJar.decode(null).isEmpty, isTrue);
  });

  test('toString never prints values', () {
    const jar = RiotCookieJar({'ssid': 'secret-value'});
    expect(jar.toString(), isNot(contains('secret-value')));
  });

  group('cookieLifetime (Stay signed in evidence)', () {
    test('Max-Age gives the lifetime and wins over Expires', () {
      expect(
        cookieLifetime(
          [
            'clid=x; Max-Age=60',
            'ssid=s; Expires=Thu, 29 Oct 2026 00:00:00 GMT; Max-Age=2592000',
          ],
          'ssid',
          now: now,
        ),
        const Duration(days: 30),
      );
    });

    test('Expires alone counts from now', () {
      expect(
        cookieLifetime(
          ['ssid=s; Expires=Thu, 01 Oct 2026 00:00:00 GMT; Path=/'],
          'ssid',
          now: now,
        ),
        const Duration(days: 3),
      );
    });

    test('a browser-session or deleted cookie is zero', () {
      expect(
        cookieLifetime(['ssid=s; Path=/; Secure'], 'ssid', now: now),
        Duration.zero,
      );
      expect(
        cookieLifetime(['ssid=; Max-Age=0'], 'ssid', now: now),
        Duration.zero,
      );
    });

    test('null when no header sets the cookie', () {
      expect(cookieLifetime(null, 'ssid'), isNull);
      expect(cookieLifetime(['clid=x; Max-Age=60'], 'ssid', now: now), isNull);
    });
  });
}
