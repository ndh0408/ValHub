import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/app/deep_links.dart';

void main() {
  test('custom scheme links resolve allowed routes and reject auth or foreign schemes', () {
    expect(
      parseDeepLink('valvn://store?account=ABC&segment=nightmarket'),
      const DeepLink(
        location: '/store?segment=nightmarket',
        accountPuuid: 'abc',
      ),
    );
    expect(parseDeepLink('valvn:///post/p1').location, '/post/p1');
    expect(parseDeepLink('valvn://login').location, '/');
    expect(parseDeepLink('valvn://evil.example/store').location, '/');
    expect(parseDeepLink('valvn://user@store').location, '/');
    expect(parseDeepLink('valvn://store:80').location, '/');
  });

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

  test('external or malformed payloads fall back to the default tab', () {
    expect(parseDeepLink('https://evil.example/x').location, '/');
    expect(parseDeepLink('store').location, '/');
    expect(parseDeepLink('').location, '/');
  });

  test('a nonce makes every tap a distinct location', () {
    final a = parseDeepLink('/store?segment=daily&nav=old', nonce: '1');
    final b = parseDeepLink('/store?segment=daily', nonce: '2');
    expect(a.location, '/store?segment=daily&nav=1');
    expect(b.location, '/store?segment=daily&nav=2');
    expect(parseDeepLink('/store').location, '/store');
  });

  test('a Home focus link keeps its card and nonce', () {
    expect(
      parseDeepLink('/home?focus=battlepass&account=ABC', nonce: '7'),
      const DeepLink(
        location: '/home?focus=battlepass&nav=7',
        accountPuuid: 'abc',
      ),
    );
  });

  group('planLinkNavigation', () {
    test('Battle Pass and Settings open the Hồ sơ tab, then push the page', () {
      expect(
        planLinkNavigation('/settings'),
        const LinkNavigation('/profile', push: '/settings'),
      );
      expect(
        planLinkNavigation('/settings?nav=1'),
        const LinkNavigation('/profile', push: '/settings?nav=1'),
      );
      expect(
        planLinkNavigation('/settings/about/privacy'),
        const LinkNavigation('/profile', push: '/settings/about/privacy'),
      );
      expect(
        planLinkNavigation('/battlepass'),
        const LinkNavigation('/profile', push: '/battlepass'),
      );
      expect(
        planLinkNavigation('/battlepass/rewards?contract=x'),
        const LinkNavigation(
          '/profile',
          push: '/battlepass/rewards?contract=x',
        ),
      );
    });

    test('everything else is a plain go', () {
      expect(
        planLinkNavigation('/store?segment=nightmarket'),
        const LinkNavigation('/store?segment=nightmarket'),
      );
      expect(
        planLinkNavigation('/home?focus=store'),
        const LinkNavigation('/home?focus=store'),
      );
      expect(planLinkNavigation('/'), const LinkNavigation('/'));
      expect(
        planLinkNavigation('/collection/wishlist?skin=s'),
        const LinkNavigation('/collection/wishlist?skin=s'),
      );
    });

    test('a path that only starts like a hosted root is not hosted', () {
      expect(
        planLinkNavigation('/settingsx'),
        const LinkNavigation('/settingsx'),
      );
      expect(
        planLinkNavigation('/battlepassy/rewards'),
        const LinkNavigation('/battlepassy/rewards'),
      );
    });
  });
}
