import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/home/data/home_card.dart';
import 'package:valvn/features/home/data/home_layout.dart';
import 'package:valvn/features/home/providers/home_layout_provider.dart';

import '../../../helpers/test_prefs.dart';
import '../home_test_env.dart';

import 'package:valvn/core/accounts/account_providers.dart';

/// A [Prefs] whose writes fail (a full disk, a locked store…).
class _FailingPrefs extends Prefs {
  _FailingPrefs(super.prefs);

  @override
  Future<void> setString(String key, String value) =>
      Future.error(StateError('disk full'));

  @override
  Future<void> setBool(String key, bool value) =>
      Future.error(StateError('disk full'));

  @override
  Future<void> remove(String key) => Future.error(StateError('disk full'));
}

ProviderContainer _container(Prefs prefs) =>
    ProviderContainer.test(overrides: [prefsProvider.overrideWithValue(prefs)]);

void main() {
  test('the keys follow the f.<feature>.<name> convention', () {
    expect(kHomeLayoutPrefKey, 'f.home.layout');
    expect(kHomeFriendsPrefKey, 'f.home.friendsLive');
  });

  group('layout', () {
    test('starts with the IA order when nothing is stored', () async {
      final prefs = await createTestPrefs();
      expect(_container(prefs).read(homeLayoutProvider), HomeLayout.defaults);
    });

    test('persists every change to Prefs and reloads from it', () async {
      final prefs = await createTestPrefs();
      final c = _container(prefs);
      final notifier = c.read(homeLayoutProvider.notifier);

      await notifier.setHidden(HomeCardId.community, hidden: true);
      await notifier.move(0, 3);
      final layout = c.read(homeLayoutProvider);
      expect(layout.isHidden(HomeCardId.community), isTrue);
      expect(layout.order.first, HomeCardId.store);

      expect(
        HomeLayout.fromJson(prefs.getJson(kHomeLayoutPrefKey)),
        layout,
        reason: 'written through at once',
      );
      // A new container over the same prefs (the next launch).
      expect(_container(prefs).read(homeLayoutProvider), layout);

      await notifier.reset();
      expect(c.read(homeLayoutProvider), HomeLayout.defaults);
      expect(
        HomeLayout.fromJson(prefs.getJson(kHomeLayoutPrefKey)),
        HomeLayout.defaults,
      );
    });

    test('a corrupt stored value falls back to the defaults', () async {
      final prefs = await createTestPrefs({kHomeLayoutPrefKey: '{nope'});
      expect(_container(prefs).read(homeLayoutProvider), HomeLayout.defaults);
      final other = await createTestPrefs({kHomeLayoutPrefKey: '"text"'});
      expect(_container(other).read(homeLayoutProvider), HomeLayout.defaults);
    });

    test('a failed write keeps the state for this session', () async {
      await createTestPrefs();
      final real = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(),
      );
      final c = _container(_FailingPrefs(real));
      final notifier = c.read(homeLayoutProvider.notifier);

      await notifier.setHidden(HomeCardId.rank, hidden: true);
      expect(c.read(homeLayoutProvider).isHidden(HomeCardId.rank), isTrue);
      await notifier.move(0, 4);
      expect(c.read(homeLayoutProvider).order.first, HomeCardId.store);
    });

    test('is app-wide: not stored under an account key', () async {
      final prefs = await createTestPrefs();
      final c = _container(prefs);
      await c
          .read(homeLayoutProvider.notifier)
          .setHidden(HomeCardId.live, hidden: true);
      expect(prefs.keys.where((k) => k.contains('home')), {kHomeLayoutPrefKey});
    });
  });

  group('friends consent', () {
    String key(String id) => PrefKeys.account(id, 'home.friendsLive');
    test(
      'asks separately after switching accounts and ignores legacy consent',
      () async {
        final env = await HomeTestEnv.create(accounts: [homeMe, homeAlt1]);
        await env.prefs.setBool(kHomeFriendsPrefKey, true);
        final c = ProviderContainer.test(overrides: env.overrides);
        expect(c.read(homeFriendsConsentProvider), isNull);
        await c.read(homeFriendsConsentProvider.notifier).set(allowed: true);
        expect(c.read(homeFriendsConsentProvider), isTrue);
        expect(env.prefs.getBool(key(homeMe.puuid)), isTrue);
        c.read(activePuuidProvider.notifier).select(homeAlt1.puuid);
        expect(c.read(homeFriendsConsentProvider), isNull);
        await c.read(homeFriendsConsentProvider.notifier).set(allowed: false);
        expect(c.read(homeFriendsConsentProvider), isFalse);
        c.read(activePuuidProvider.notifier).select(homeMe.puuid);
        expect(c.read(homeFriendsConsentProvider), isTrue);
      },
    );
    test('undo removes only the current account answer', () async {
      final env = await HomeTestEnv.create(friendsConsent: false);
      final c = ProviderContainer.test(overrides: env.overrides);
      expect(c.read(homeFriendsConsentProvider), isFalse);
      await c.read(homeFriendsConsentProvider.notifier).clear();
      expect(c.read(homeFriendsConsentProvider), isNull);
      expect(env.prefs.containsKey(key(homeMe.puuid)), isFalse);
    });
    test('without an account no consent can be granted', () async {
      final prefs = await createTestPrefs();
      final c = _container(prefs);
      await c.read(homeFriendsConsentProvider.notifier).set(allowed: true);
      expect(c.read(homeFriendsConsentProvider), isNull);
      expect(prefs.containsKey(kHomeFriendsPrefKey), isFalse);
    });
  });
}
