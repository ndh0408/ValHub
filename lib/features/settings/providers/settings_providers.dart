import 'dart:ui' show Rect;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/storage/json_file_cache.dart';
import '../data/cache_stats.dart';

/// App package info (version, build number) for "Phiên bản" (S70, S72).
final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

/// "Xóa bộ nhớ đệm" backend. Overridden with a fake in widget tests (no
/// `path_provider` platform channel there).
final cacheServiceProvider = Provider<CacheService>(
  (ref) => CacheService(responses: ref.watch(jsonFileCacheProvider)),
);

/// Combined size of the offline-response cache and the media cache
/// ("Xóa bộ nhớ đệm (32 MB)", S70). Invalidate after clearing.
final cacheSizeBytesProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(cacheServiceProvider).sizeBytes(),
);

/// Whether the OS currently allows ValVN to post notifications. Invalidate
/// after a permission request and when the app resumes (the user may have
/// changed it in the system settings).
final notificationsAllowedProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(notificationServiceProvider).areEnabled(),
);

/// Opens [Uri] outside the app. Returns `false` when nothing could open it.
typedef ExternalUrlOpener = Future<bool> Function(Uri uri);

final externalUrlOpenerProvider = Provider<ExternalUrlOpener>(
  (ref) => (uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  },
);

/// Shares plain text through the OS share sheet (`share_plus`).
/// [origin] anchors the iPad popover.
typedef TextSharer = Future<void> Function(
  String text, {
  String? subject,
  Rect? origin,
});

final textSharerProvider = Provider<TextSharer>(
  (ref) => (text, {subject, origin}) async {
    await SharePlus.instance.share(
      ShareParams(text: text, subject: subject, sharePositionOrigin: origin),
    );
  },
);

/// The three notification switches of S70 ("THÔNG BÁO").
enum NotificationToggle { storeReset, wishlist, nightMarket }

extension NotificationToggleX on NotificationToggle {
  bool valueIn(AppSettings s) => switch (this) {
    NotificationToggle.storeReset => s.storeResetNotifications,
    NotificationToggle.wishlist => s.wishlistNotifications,
    NotificationToggle.nightMarket => s.nightMarketNotifications,
  };

  AppSettings apply(AppSettings s, bool on) => switch (this) {
    NotificationToggle.storeReset => s.copyWith(storeResetNotifications: on),
    NotificationToggle.wishlist => s.copyWith(wishlistNotifications: on),
    NotificationToggle.nightMarket => s.copyWith(nightMarketNotifications: on),
  };
}

/// Whether any notification preference is switched on.
bool anyNotificationEnabled(AppSettings s) =>
    NotificationToggle.values.any((t) => t.valueIn(s)) ||
    s.wishlistNotificationsByAccount.values.any((enabled) => enabled);

/// Settings actions that touch more than one core service.
final settingsControllerProvider = Provider<SettingsController>(
  SettingsController.new,
);

class SettingsController {
  SettingsController(this._ref);

  final Ref _ref;

  /// Sets the wishlist alert only for [puuid].
  Future<void> setWishlistNotification(String puuid, bool on) async {
    final id = puuid.toLowerCase();
    await _ref
        .read(appSettingsProvider.notifier)
        .update(
          (s) => s.copyWith(
            wishlistNotificationsByAccount: {
              ...s.wishlistNotificationsByAccount,
              id: on,
            },
          ),
        );
  }

  /// Persists a notification switch. Turning one off also cancels the
  /// reminders already scheduled for it on every account, so a disabled
  /// preference never fires later.
  Future<void> setNotification(NotificationToggle toggle, bool on) async {
    await _ref
        .read(appSettingsProvider.notifier)
        .update((s) => toggle.apply(s, on));
    if (on) return;
    final service = _ref.read(notificationServiceProvider);
    final accounts = _ref.read(accountsProvider);
    for (final account in accounts) {
      final id = switch (toggle) {
        NotificationToggle.storeReset => NotificationIds.storeReset(
          account.puuid,
        ),
        NotificationToggle.nightMarket => NotificationIds.nightMarket(
          account.puuid,
        ),
        // Wishlist hits are shown immediately by the background check;
        // nothing is scheduled ahead.
        NotificationToggle.wishlist => null,
      };
      if (id != null) await service.cancel(id);
    }
  }
}
