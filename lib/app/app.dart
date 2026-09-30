import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/accounts/account_providers.dart';
import '../core/config/client_version.dart';
import '../core/content/content_repository.dart';
import '../core/l10n/common_strings.dart';
import '../core/l10n/l10n.dart' show appLocalizationsDelegates;
import '../core/l10n/locale.dart';
import '../core/notifications/notification_service.dart';
import '../core/storage/prefs.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_mode_provider.dart';
import 'deep_links.dart';
import 'router.dart';

/// Root widget: Material 3 (material_ui) router app, Vietnamese locale,
/// dark Valorant theme, notification deep links, resume hooks.
class ValVnApp extends ConsumerStatefulWidget {
  const ValVnApp({super.key});

  @override
  ConsumerState<ValVnApp> createState() => _ValVnAppState();
}

class _ValVnAppState extends ConsumerState<ValVnApp> {
  StreamSubscription<String>? _taps;
  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    final notifications = ref.read(notificationServiceProvider);
    _taps = notifications.taps.listen(_openDeepLink);
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final launch = notifications.takeLaunchPayload();
      if (launch != null) _openDeepLink(launch);
    });
    unawaited(ref.read(clientVersionRepositoryProvider).refresh());
  }

  /// Another isolate (background task) may have changed prefs.
  Future<void> _onResume() async {
    await ref.read(prefsProvider).reload();
    if (!mounted) return;
    ref.read(accountsProvider.notifier).reload();
    ref.retryContentIfFailed();
    unawaited(ref.read(clientVersionRepositoryProvider).refresh());
  }

  void _openDeepLink(String payload) {
    final link = parseDeepLink(
      payload,
      nonce: '${DateTime.now().microsecondsSinceEpoch}',
    );
    final account = link.accountPuuid;
    if (account != null &&
        ref.read(accountsProvider).any((a) => a.puuid == account)) {
      ref.read(activePuuidProvider.notifier).select(account);
    }
    openAppLink(ref.read(routerProvider), link);
  }

  @override
  void dispose() {
    unawaited(_taps?.cancel());
    _lifecycle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: CommonStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ref.watch(themeModeProvider),
      // Still Vietnamese-only: `kShippedLocales` is `{vi}` and the locale
      // providers are not read here until wave W5 (docs/design/I18N.md).
      locale: appLocale,
      supportedLocales: const [appLocale],
      // AppLocalizations + material_ui's delegates. Never the generated
      // `AppLocalizations.localizationsDelegates` (legacy Material).
      localizationsDelegates: appLocalizationsDelegates,
      // Legacy-Material packages (fl_chart, video_player, inappwebview) still
      // resolve flutter/material Theme/Localizations; bridge them (FS §2).
      // ignore: deprecated_member_use
      builder: (context, child) => MaterialUiCompatibilityBridge(
        child: child ?? const SizedBox.shrink(),
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
