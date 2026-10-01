import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/accounts/account_providers.dart';
import '../core/accounts/account_data_warmup.dart';
import '../core/accounts/account_link_guard.dart';
import '../core/auth/auth_routes.dart';
import '../core/l10n/account_strings.dart';

import 'package:go_router/go_router.dart';

import '../core/config/client_version.dart';
import '../core/content/content_repository.dart';
import '../core/l10n/common_strings.dart';
import '../core/notifications/progress_notifications.dart';
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

class _ValVnAppState extends ConsumerState<ValVnApp>
    with WidgetsBindingObserver {
  StreamSubscription<String>? _taps;
  AppLifecycleListener? _lifecycle;
  DeepLink? _pendingLink;
  late final GoRouter _router;
  final _messenger = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _router = ref.read(routerProvider);
    _router.routerDelegate.addListener(_resumePendingLink);
    final notifications = ref.read(notificationServiceProvider);
    _taps = notifications.taps.listen(_openDeepLink);
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final launch = notifications.takeLaunchPayload();
      final external =
          WidgetsBinding.instance.platformDispatcher.defaultRouteName;
      if (launch != null) {
        _openDeepLink(launch);
      } else if (Uri.tryParse(external)?.scheme == 'valvn') {
        _openDeepLink(external);
      }
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
    _navigateLink(link);
  }

  void _navigateLink(DeepLink link) {
    if (!mounted) return;
    final decision = accountLinkDecision(
      accountPuuid: link.accountPuuid,
      signedIn: ref.read(accountsProvider).map((a) => a.puuid),
      // The route information provider keeps the underlying branch URI for
      // imperative pushes. The delegate's state is the visible top page.
      currentPath: _router.state.uri.path,
    );
    switch (decision) {
      case AccountLinkDecision.deferLogin:
        _pendingLink = link;
      case AccountLinkDecision.unknownAccount:
        _pendingLink = null;
        _messenger.currentState?.showSnackBar(
          const SnackBar(content: Text(AccountStrings.linkAccountMissing)),
        );
      case AccountLinkDecision.open:
        _pendingLink = null;
        if (link.accountPuuid case final id?) {
          ref.read(activePuuidProvider.notifier).select(id);
        }
        openAppLink(_router, link);
    }
  }

  void _resumePendingLink() {
    final link = _pendingLink;
    if (link == null || _router.state.uri.path == AuthRoutes.login) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && identical(_pendingLink, link)) _navigateLink(link);
    });
  }

  @override
  Future<bool> didPushRouteInformation(
    RouteInformation routeInformation,
  ) async {
    if (routeInformation.uri.scheme != 'valvn') return false;
    _openDeepLink(routeInformation.uri.toString());
    return true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.routerDelegate.removeListener(_resumePendingLink);
    unawaited(_taps?.cancel());
    _lifecycle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: _messenger,
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
        child: ProgressNotificationHost(
          child: AccountDataWarmupHost(child: child ?? const SizedBox.shrink()),
        ),
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
