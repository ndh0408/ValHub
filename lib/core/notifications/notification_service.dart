import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/notification_strings.dart';
import '../storage/prefs.dart';

/// Initialises the `timezone` database and the local zone (fallback
/// `Asia/Ho_Chi_Minh`). Call once per isolate before scheduling.
Future<void> initTimeZone() async {
  tzdata.initializeTimeZones();
  try {
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
  } on Object {
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
  }
}

/// Status-bar icon (white silhouette, `android/app/src/main/res/drawable-*`;
/// kept from resource shrinking by `res/raw/keep.xml`).
const _androidSmallIcon = '@drawable/ic_stat_valvn';

/// Accent tint of Android notifications (Valorant red).
const _accent = Color(0xFFFF4655);

/// Android channels (ids never change after release).
enum NotificationChannel {
  storeReset(
    'store_reset',
    NotificationStrings.channelStoreResetName,
    NotificationStrings.channelStoreResetDescription,
  ),
  wishlist(
    'wishlist',
    NotificationStrings.channelWishlistName,
    NotificationStrings.channelWishlistDescription,
  ),
  nightMarket(
    'night_market',
    NotificationStrings.channelNightMarketName,
    NotificationStrings.channelNightMarketDescription,
  ),
  account(
    'account',
    NotificationStrings.channelAccountName,
    NotificationStrings.channelAccountDescription,
  );

  const NotificationChannel(this.id, this.channelName, this.description);

  final String id;
  final String channelName;
  final String description;
}

/// Stable notification ids (31-bit FNV-1a of a key).
abstract final class NotificationIds {
  static int forKey(String key) {
    var hash = 0x811c9dc5;
    for (final unit in key.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  static int storeReset(String puuid) => forKey('store_reset:$puuid');
  static int nightMarket(String puuid) => forKey('night_market:$puuid');
  static int wishlistHit(String puuid, String skinUuid) =>
      forKey('wishlist:$puuid:$skinUuid');
  static int sessionExpired(String puuid) => forKey('session_expired:$puuid');
}

/// Local notifications (SUMMARY §8.2 B8/W2, VF §6.9).
///
/// - Inexact scheduling only (`inexactAllowWhileIdle`, no exact-alarm
///   permission).
/// - Payload = an app route location (e.g. `/store?account=<puuid>`);
///   taps are published on [taps] and routed by the app shell.
/// - Notifications created with an `accountPuuid` are tracked so sign-out can
///   cancel them ([cancelForAccount]).
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin, this._prefs})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final Prefs? _prefs;
  final StreamController<String> _taps = StreamController<String>.broadcast();
  bool _initialized = false;
  String? _launchPayload;

  /// Route locations from tapped notifications.
  Stream<String> get taps => _taps.stream;

  /// Payload of the notification that cold-started the app (read once).
  String? takeLaunchPayload() {
    final p = _launchPayload;
    _launchPayload = null;
    return p;
  }

  /// Initialises the plugin without prompting for permission.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(_androidSmallIcon),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) _taps.add(payload);
        },
      );
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        _launchPayload = launch?.notificationResponse?.payload;
      }
    } on Object catch (e) {
      debugPrint('NotificationService.init failed: ${e.runtimeType}');
    }
  }

  /// Asks for permission (Android 13+ runtime dialog / iOS prompt). Returns
  /// whether notifications are allowed. Show the priming sheet first.
  Future<bool> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        return await android?.requestNotificationsPermission() ?? false;
      }
      if (Platform.isIOS) {
        final ios = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        return await ios?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } on Object {
      return false;
    }
    return false;
  }

  /// Whether notifications are currently allowed.
  Future<bool> areEnabled() async {
    try {
      if (Platform.isAndroid) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        return await android?.areNotificationsEnabled() ?? false;
      }
      if (Platform.isIOS) {
        final ios = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        final options = await ios?.checkPermissions();
        return options?.isEnabled ?? false;
      }
    } on Object {
      return false;
    }
    return false;
  }

  /// Opens the OS notification settings for the app ("Mở cài đặt").
  Future<void> openSystemSettings() async {
    try {
      if (Platform.isAndroid) {
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.openAppNotificationSettings();
      } else if (Platform.isIOS) {
        await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.openAppNotificationSettings();
      }
    } on Object {
      // Nothing else to do.
    }
  }

  NotificationDetails _details(NotificationChannel channel, {String? tag}) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.channelName,
          channelDescription: channel.description,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: _androidSmallIcon,
          color: _accent,
          tag: tag,
        ),
        iOS: const DarwinNotificationDetails(),
      );

  /// Schedules a one-off notification at [at] (inexact; may be minutes late
  /// in Doze). Replaces any pending notification with the same [id].
  Future<void> scheduleAt({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required NotificationChannel channel,
    String? payload,
    String? accountPuuid,
    String? tag,
  }) async {
    await init();
    if (!at.isAfter(DateTime.now())) return;
    await _plugin.cancel(id: id, tag: tag);
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: _details(channel, tag: tag),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
    await _track(accountPuuid, id);
  }

  /// Shows a notification immediately.
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required NotificationChannel channel,
    String? payload,
    String? accountPuuid,
    String? tag,
  }) async {
    await init();
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details(channel, tag: tag),
      payload: payload,
    );
    await _track(accountPuuid, id);
  }

  Future<void> cancel(int id, {String? tag}) async {
    await init();
    await _plugin.cancel(id: id, tag: tag);
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  /// Ids of pending (scheduled) notifications.
  Future<Set<int>> pendingIds() async {
    await init();
    try {
      final pending = await _plugin.pendingNotificationRequests();
      return {for (final p in pending) p.id};
    } on Object {
      return const {};
    }
  }

  /// Cancels every notification created for [puuid] (sign-out).
  Future<void> cancelForAccount(String puuid) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final key = PrefKeys.account(puuid, 'notificationIds');
    // From disk: the background isolate may have tracked ids since the
    // last reload.
    final ids = {
      ...?prefs.getStringList(key),
      ...?await prefs.getStringListFromDisk(key),
    };
    for (final raw in ids) {
      final id = int.tryParse(raw);
      if (id != null) await cancel(id);
    }
    await prefs.remove(key);
  }

  Future<void> _track(String? puuid, int id) async {
    final prefs = _prefs;
    if (prefs == null || puuid == null) return;
    final key = PrefKeys.account(puuid, 'notificationIds');
    final ids = {...?prefs.getStringList(key), '$id'};
    await prefs.setStringList(key, ids.toList());
  }

  Future<void> dispose() => _taps.close();
}

/// App-wide [NotificationService]; `main()` calls `init()`.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService(prefs: ref.watch(prefsProvider));
  ref.onDispose(service.dispose);
  return service;
});
