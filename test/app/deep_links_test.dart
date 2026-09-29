import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/app/deep_links.dart';

void main() {
  test('extracts the account and keeps other query parameters', () {
    expect(
      parseDeepLink('/store?account=ABC&segment=nightmarket'),
      const DeepLink(
        location: '/store?segment=nightmarket',
        accountPuuid: 'abc',
      ),
    );
    expect(
      parseDeepLink('/store/bundle/x'),
      const DeepLink(location: '/store/bundle/x'),
    );
    expect(
      parseDeepLink('/settings?account='),
      const DeepLink(location: '/settings'),
    );
  });

  test('external or malformed payloads fall back to /store', () {
    expect(parseDeepLink('https://evil.example/x').location, '/store');
    expect(parseDeepLink('store').location, '/store');
    expect(parseDeepLink('').location, '/store');
  });

  test('a nonce makes every tap a distinct location', () {
    final a = parseDeepLink('/store?segment=daily&nav=old', nonce: '1');
    final b = parseDeepLink('/store?segment=daily', nonce: '2');
    expect(a.location, '/store?segment=daily&nav=1');
    expect(b.location, '/store?segment=daily&nav=2');
    expect(parseDeepLink('/store').location, '/store');
  });
}
