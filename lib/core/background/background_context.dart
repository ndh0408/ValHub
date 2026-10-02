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
import '../l10n/background_locale.dart';
import '../l10n/formats.dart';
import '../l10n/intl_init.dart';
import '../l10n/l10n.dart' show AppLocalizations;
import '../logging/session_log.dart';
import '../network/auth_traffic.dart';
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
    required this.locale,
  });

  static Future<BackgroundContext>? _instance;

  /// One shared context per isolate (created on first use).
  static Future<BackgroundContext> instance() => _instance ??= _create();

  static Future<BackgroundContext> _create() async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    await initTimeZone();
    final prefs = await Prefs.create();
    final locale = BackgroundLocale.fromPrefs(prefs);
    await initIntl(locale.effective.formatTag);
    final remote = await RemoteConfigLoader(prefs).load();
    final secure = FlutterSecureStore();
    final log = SessionLog.persistent();
    await log.load();
    secure.onError = secureErrorToLog(log);
    final versions = ClientVersionRepository(
      prefs: prefs,
      remoteConfig: () => remote,
    );
    final accounts = AccountRepository(
      prefs: prefs,
      secureStore: secure,
      fileCache: JsonFileCache.appSupport('cache'),
    );
    // One throttle for every auth-host call of this isolate.
    final authLimiter = createAuthLimiter();
    final sessions = SessionManager(
      secureStore: secure,
      accounts: accounts,
      reauthClient: RiotReauthClient(
        userAgent: () => versions.apiUserAgent,
        limiter: authLimiter,
      ),
      bootstrapClient: RiotBootstrapClient(
        userAgent: () => versions.apiUserAgent,
        limiter: authLimiter,
      ),
      versions: versions,
      remoteConfig: () => remote,
      lock: PrefsAccountLock(),
      log: log,
    );
    final notifications = NotificationService(prefs: prefs, l10n: locale.l10n);
    await notifications.init();
    // Use validated last-known-good headers when the version endpoint is down.
    if (versions.current.fetchedAt == null ||
        DateTime.now().difference(versions.current.fetchedAt!) >
            const Duration(hours: 24)) {
      unawaited(versions.refresh());
    }
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
      locale: locale,
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
  BackgroundLocale locale;
  AppLocalizations get l10n => locale.l10n;
  AppFormats get formats => locale.formats;

  /// A cached background context must pick up choices made since its last job.
  Future<void> reloadLocale() async {
    await prefs.reload();
    locale = BackgroundLocale.fromPrefs(prefs);
    await initIntl(locale.effective.formatTag);
    await notifications.refreshChannels(l10n);
  }

  /// Current app settings (read fresh from disk).
  AppSettings get settings => readAppSettings(prefs);

  /// Flushes the session log; call at the end of every task.
  Future<void> finish() => log.flush();
}
