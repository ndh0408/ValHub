import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/background/background_tasks.dart';
import 'core/config/remote_config.dart';
import 'core/l10n/locale.dart';
import 'core/logging/session_log.dart';
import 'core/network/retry_policy.dart';
import 'core/notifications/notification_service.dart';
import 'core/settings/app_settings.dart';
import 'core/storage/prefs.dart';
import 'core/storage/secure_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAppLocale();
  await initTimeZone();

  final prefs = await Prefs.create();
  final secureStore = FlutterSecureStore();
  await _wipeSecretsAfterReinstall(prefs, secureStore);
  await migrateWishlistNotificationsPerAccount(prefs);

  final remoteLoader = RemoteConfigLoader(prefs);
  final remoteConfig = await remoteLoader.load();
  unawaited(remoteLoader.refresh()); // applied on next launch

  final sessionLog = SessionLog.persistent();
  await sessionLog.load();
  sessionLog.add('app.start');

  final notifications = NotificationService(prefs: prefs);
  await notifications.init();

  unawaited(initBackgroundWork());

  runApp(
    ProviderScope(
      retry: riotRetry,
      overrides: [
        prefsProvider.overrideWithValue(prefs),
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
