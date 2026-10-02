import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;

import 'core/ui/release_error_view.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/accounts/account_maintenance.dart';
import 'core/accounts/account_repository.dart';
import 'core/background/background_tasks.dart';
import 'core/config/remote_config.dart';
import 'core/l10n/intl_init.dart';
import 'core/l10n/l10n.dart' show lookupAppLocalizations;
import 'core/l10n/locale_boot.dart';
import 'core/l10n/locale_controller.dart' show l10nBootProvider;
import 'core/logging/session_log.dart';
import 'core/network/retry_policy.dart';
import 'core/notifications/notification_service.dart';
import 'core/settings/app_settings.dart';
import 'core/storage/prefs.dart';
import 'core/storage/secure_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await Prefs.create();

  // Language first (docs/design/I18N.md 6.4): the preferences are read
  // synchronously, so even the first frame is in the right language. It MUST
  // run before _wipeSecretsAfterReinstall, which sets the install marker: the
  // upgrade pin uses that marker to tell an existing install (keeps Vietnamese)
  // from a fresh one.
  final boot = L10nBootstrap.load(
    prefs,
    WidgetsBinding.instance.platformDispatcher.locales,
  );
  await initIntl(boot.formatTag);
  await initTimeZone();

  final secureStore = FlutterSecureStore();
  await _wipeSecretsAfterReinstall(prefs, secureStore);
  await migrateWishlistNotificationsPerAccount(prefs);

  final remoteLoader = RemoteConfigLoader(prefs);
  final remoteConfig = await remoteLoader.load();
  unawaited(remoteLoader.refresh()); // applied on next launch

  final sessionLog = SessionLog.persistent();
  await sessionLog.load();
  secureStore.onError = secureErrorToLog(sessionLog);
  sessionLog.add('app.start');
  FlutterError.onError = (details) {
    sessionLog.add(
      'app.flutter.error',
      detail: details.exception.runtimeType.toString(),
    );
    if (!kReleaseMode) FlutterError.presentError(details);
  };
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    sessionLog.add('app.async.error', detail: error.runtimeType.toString());
    return kReleaseMode;
  };
  if (kReleaseMode) {
    final fallbackResources = lookupAppLocalizations(boot.locale.flutter);
    ErrorWidget.builder = (_) =>
        ReleaseErrorView(fallbackResources: fallbackResources);
  }

  final notifications = NotificationService(
    prefs: prefs,
    l10n: lookupAppLocalizations(boot.locale.flutter),
  );
  await notifications.init();
  await runAccountStartupMaintenance(
    prefs: prefs,
    secureStore: secureStore,
    notifications: notifications,
    log: sessionLog,
  );

  final accounts = AccountRepository(prefs: prefs, secureStore: secureStore);
  unawaited(syncBackgroundWork(hasAccounts: accounts.loadAll().isNotEmpty));

  runApp(
    ProviderScope(
      retry: riotRetry,
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        l10nBootProvider.overrideWithValue(boot),
        secureStoreProvider.overrideWithValue(secureStore),
        remoteConfigProvider.overrideWithValue(remoteConfig),
        sessionLogProvider.overrideWithValue(sessionLog),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const ValVnApp(),
    ),
  );
}

/// iOS Keychain items survive uninstall: wipe them on the first launch of a
/// fresh install so stale accounts never reappear (FS §8).
Future<void> _wipeSecretsAfterReinstall(Prefs prefs, SecureStore secure) async {
  if (prefs.getBool(PrefKeys.installMarker) ?? false) return;
  try {
    await secure.deleteAll();
  } on Object {
    // Keychain unavailable: nothing to wipe.
  }
  await prefs.setBool(PrefKeys.installMarker, true);
}
