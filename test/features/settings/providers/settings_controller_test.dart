import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/settings/providers/settings_providers.dart';

import '../../../helpers/test_prefs.dart';
import '../settings_fakes.dart';

void main() {
  late Prefs prefs;
  late SettingsTestEnv env;
  late ProviderContainer container;

  setUp(() async {
    prefs = await createTestPrefs();
    env = SettingsTestEnv(prefs);
    await seedAccounts(prefs, [testAccount(1), testAccount(2)]);
    container = ProviderContainer.test(overrides: env.overrides);
  });

  group('NotificationToggle', () {
    test('reads and writes the matching AppSettings field', () {
      const base = AppSettings();
      for (final t in NotificationToggle.values) {
        expect(t.valueIn(base), isFalse);
        final on = t.apply(base, true);
        expect(t.valueIn(on), isTrue);
        // Only that field changed.
        for (final other in NotificationToggle.values.where((o) => o != t)) {
          expect(other.valueIn(on), isFalse);
        }
      }
    });

    test('anyNotificationEnabled', () {
      expect(anyNotificationEnabled(const AppSettings()), isFalse);
      expect(
        anyNotificationEnabled(
          const AppSettings(nightMarketNotifications: true),
        ),
        isTrue,
      );
    });
  });

  group('SettingsController.setNotification', () {
    test('wishlist choice is independent for each account', () async {
      final controller = container.read(settingsControllerProvider);
      await controller.setWishlistNotification(testPuuid(1), true);
      expect(
        readAppSettings(prefs).wishlistNotificationsFor(testPuuid(1)),
        isTrue,
      );
      expect(
        readAppSettings(prefs).wishlistNotificationsFor(testPuuid(2)),
        isFalse,
      );
      await controller.setWishlistNotification(testPuuid(2), true);
      await controller.setWishlistNotification(testPuuid(1), false);
      expect(
        readAppSettings(prefs).wishlistNotificationsFor(testPuuid(1)),
        isFalse,
      );
      expect(
        readAppSettings(prefs).wishlistNotificationsFor(testPuuid(2)),
        isTrue,
      );
    });

    test('turning on persists without cancelling anything', () async {
      await container
          .read(settingsControllerProvider)
          .setNotification(NotificationToggle.storeReset, true);

      expect(readAppSettings(prefs).storeResetNotifications, isTrue);
      expect(env.notifications.cancelled, isEmpty);
    });

    test('turning Night Market off cancels it for every account', () async {
      final controller = container.read(settingsControllerProvider);
      await controller.setNotification(NotificationToggle.nightMarket, true);
      await controller.setNotification(NotificationToggle.nightMarket, false);

      expect(readAppSettings(prefs).nightMarketNotifications, isFalse);
      expect(env.notifications.cancelled, [
        NotificationIds.nightMarket(testPuuid(1)),
        NotificationIds.nightMarket(testPuuid(2)),
      ]);
    });

    test('turning the wishlist check off has nothing to cancel', () async {
      await container
          .read(settingsControllerProvider)
          .setNotification(NotificationToggle.wishlist, false);

      expect(env.notifications.cancelled, isEmpty);
      expect(readAppSettings(prefs).wishlistNotifications, isFalse);
    });
  });
}
