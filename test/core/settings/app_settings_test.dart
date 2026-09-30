import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/theme_mode_provider.dart';

import '../../helpers/test_prefs.dart';

void main() {
  test('defaults: dark theme, vi item names', () {
    const s = AppSettings();
    expect(s.themeMode, ThemeMode.dark);
    expect(s.itemLanguage.apiCode, 'vi-VN');
    expect(AppSettings.fromJson('junk'), s);
  });

  test('persisted through prefs and exposed as themeModeProvider', () async {
    final prefs = await createTestPrefs();
    final c = ProviderContainer.test(
      overrides: [prefsProvider.overrideWithValue(prefs)],
    );
    await c.read(appSettingsProvider.notifier).setThemeMode(ThemeMode.light);
    await c.read(appSettingsProvider.notifier).setItemLanguage(ItemLanguage.en);
    expect(c.read(themeModeProvider), ThemeMode.light);
    final reread = readAppSettings(prefs);
    expect(reread.themeMode, ThemeMode.light);
    expect(reread.itemLanguage.apiCode, 'en-US');
  });

  group('migrateWishlistNotificationsPerAccount', () {
    const a = '00000000-0000-0000-0000-000000000001';
    const b = '00000000-0000-0000-0000-000000000002';
    const c2 = '00000000-0000-0000-0000-000000000003';

    Map<String, Object?> account(String puuid) => {
      'puuid': puuid,
      'gameName': 'P',
      'tagLine': 'VN',
      'region': 'ap',
      'shard': 'ap',
    };

    test(
      'legacy "on" becomes an explicit choice per account; new ones start off',
      () async {
        final prefs = await createTestPrefs();
        await prefs.setJson(PrefKeys.accounts, [account(a), account(b)]);
        await prefs.setJson(
          PrefKeys.appSettings,
          const AppSettings(wishlistNotifications: true).toJson(),
        );

        await migrateWishlistNotificationsPerAccount(prefs);
        final s = readAppSettings(prefs);
        expect(s.wishlistNotifications, isFalse);
        expect(s.wishlistNotificationsFor(a), isTrue);
        expect(s.wishlistNotificationsFor(b), isTrue);
        // An account added after the upgrade does not inherit the old switch.
        expect(s.wishlistNotificationsFor(c2), isFalse);
      },
    );

    test(
      'keeps an explicit per-account "off" and is a one-time upgrade',
      () async {
        final prefs = await createTestPrefs();
        await prefs.setJson(PrefKeys.accounts, [account(a), account(b)]);
        await prefs.setJson(
          PrefKeys.appSettings,
          const AppSettings(
            wishlistNotifications: true,
            wishlistNotificationsByAccount: {a: false},
          ).toJson(),
        );
        await migrateWishlistNotificationsPerAccount(prefs);
        var s = readAppSettings(prefs);
        expect(s.wishlistNotificationsFor(a), isFalse);
        expect(s.wishlistNotificationsFor(b), isTrue);

        // A later run never touches what the user chose afterwards.
        await prefs.setJson(
          PrefKeys.appSettings,
          s
              .copyWith(wishlistNotificationsByAccount: {a: false, b: false})
              .toJson(),
        );
        await migrateWishlistNotificationsPerAccount(prefs);
        s = readAppSettings(prefs);
        expect(s.wishlistNotificationsFor(b), isFalse);
      },
    );

    test('legacy "off" or no accounts: nothing turns on; junk accounts are ignored', () async {
      final prefs = await createTestPrefs();
      await migrateWishlistNotificationsPerAccount(prefs);
      expect(readAppSettings(prefs).wishlistNotificationsByAccount, isEmpty);

      final prefs2 = await createTestPrefs();
      await prefs2.setJson(PrefKeys.accounts, ['junk', 5, account(a)]);
      await prefs2.setJson(
        PrefKeys.appSettings,
        const AppSettings(wishlistNotifications: true).toJson(),
      );
      await migrateWishlistNotificationsPerAccount(prefs2);
      expect(readAppSettings(prefs2).wishlistNotificationsByAccount.keys, [a]);
    });
  });
}
