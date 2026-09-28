import 'dart:async';
import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/widgets.dart';

import '../accounts/account_repository.dart';
import '../auth/account_lock.dart';
import '../auth/bootstrap_client.dart';
import '../auth/reauth_client.dart';
import '../auth/session_manager.dart';
import '../config/client_version.dart';
import '../config/remote_config.dart';
import '../content/content_repository.dart';
import '../l10n/locale.dart';
import '../logging/session_log.dart';
import '../network/dio_factory.dart';
import '../notifications/notification_service.dart';
import '../riot/pvp_api.dart';
import '../settings/app_settings.dart';
import '../storage/json_file_cache.dart';
import '../storage/prefs.dart';
import '../storage/secure_store.dart';
import '../wishlist/wishlist_store.dart';

/// Plain (Riverpod-free) services for background isolates (workmanager).
///
/// ```dart
/// Future<bool> runWishlistCheck() async {
///   final ctx = await BackgroundContext.instance();
///   for (final account in ctx.accounts.loadAll()) {
///     final store = await ctx.pvp.storefront(account.puuid);
///     …
///   }
///   return true;
/// }
/// ```
class BackgroundContext {
  BackgroundContext._({
    required this.prefs,
    required this.remoteConfig,
    required this.secureStore,
    required this.log,
    required this.versions,
    required this.accounts,
    required this.sessions,
    required this.pvp,
    required this.content,
    required this.notifications,
    required this.wishlist,
  });

  static Future<BackgroundContext>? _instance;

  /// One shared context per isolate (created on first use).
  static Future<BackgroundContext> instance() => _instance ??= _create();

  static Future<BackgroundContext> _create() async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    await initAppLocale();
    await initTimeZone();
    final prefs = await Prefs.create();
    final remote = await RemoteConfigLoader(prefs).load();
    final secure = FlutterSecureStore();
    final log = SessionLog.persistent();
    await log.load();
    final versions = ClientVersionRepository(
      prefs: prefs,
      remoteConfig: () => remote,
    );
    final accounts = AccountRepository(
      prefs: prefs,
      secureStore: secure,
      fileCache: JsonFileCache.appSupport('cache'),
    );
    final sessions = SessionManager(
      secureStore: secure,
      accounts: accounts,
      reauthClient: RiotReauthClient(userAgent: () => versions.apiUserAgent),
      bootstrapClient: RiotBootstrapClient(
        userAgent: () => versions.apiUserAgent,
      ),
      versions: versions,
      remoteConfig: () => remote,
      lock: PrefsAccountLock(),
      log: log,
    );
    final notifications = NotificationService(prefs: prefs);
    await notifications.init();
    return BackgroundContext._(
      prefs: prefs,
      remoteConfig: remote,
      secureStore: secure,
      log: log,
      versions: versions,
      accounts: accounts,
      sessions: sessions,
      pvp: PvpApi(
        sessions: sessions,
        dio: createPvpDio(sessions: sessions, log: log),
      ),
      content: ContentRepository(versions: versions, prefs: prefs),
      notifications: notifications,
      wishlist: WishlistRepository(prefs),
    );
  }

  final Prefs prefs;
  final RemoteConfig remoteConfig;
  final SecureStore secureStore;
  final SessionLog log;
  final ClientVersionRepository versions;
  final AccountRepository accounts;
  final SessionManager sessions;
  final PvpApi pvp;
  final ContentRepository content;
  final NotificationService notifications;
  final WishlistRepository wishlist;

  /// Current app settings (read fresh from disk).
  AppSettings get settings => readAppSettings(prefs);

  /// Flushes the session log; call at the end of every task.
  Future<void> finish() => log.flush();
}
