import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/accounts/account_providers.dart';
import '../core/accounts/account_data_warmup.dart';
import '../core/accounts/account_link_guard.dart';
import '../core/auth/auth_routes.dart';

import 'package:go_router/go_router.dart';

import '../core/config/client_version.dart';
import '../core/content/content_repository.dart';
import '../core/notifications/progress_notifications.dart';
import '../core/l10n/l10n.dart' show appLocalizationsDelegates, l10nProvider;
import '../core/l10n/app_locale.dart' show kShippedLocales;
import '../core/l10n/formats.dart';
import '../core/l10n/intl_init.dart';
import '../core/l10n/locale_controller.dart';
import '../core/logging/session_log.dart';
import '../core/notifications/notification_service.dart';
import '../core/storage/prefs.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_mode_provider.dart';
import 'deep_links.dart';
import 'router.dart';

/// Root widget: Material 3 (material_ui) router app, shipped locale,
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
  Future<void> _localeWrites = Future<void>.value();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final prefs = ref.read(prefsProvider);
    final log = ref.read(sessionLogProvider);
    ref.listenManual(effectiveLocaleProvider, (_, next) {
      unawaited(initIntl(next.formatTag));
      // Native preferences finish asynchronously. Serialize snapshots so an
      // older write cannot overwrite a rapid content/clock/language change.
      // Capture dependencies here: a queued write can outlive this widget.
      _localeWrites = _localeWrites.then((_) => next.write(prefs)).onError((
        Object error,
        StackTrace stack,
      ) {
        log.add('l10n.persist.failed', detail: error.runtimeType.toString());
      });
    }, fireImmediately: true);
    ref.listenManual(l10nProvider, (_, next) {
      unawaited(
        ref.read(notificationServiceProvider).refreshChannels(next).catchError((
          Object error,
        ) {
          log.add('l10n.channels.failed', detail: error.runtimeType.toString());
        }),
      );
    }, fireImmediately: true);
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
          SnackBar(
            content: Text(ref.read(l10nProvider).accountLinkAccountMissing),
          ),
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
    return AppFormatsScope(
      formats: ref.watch(formatsProvider),
      child: MaterialApp.router(
        scaffoldMessengerKey: _messenger,
        title: ref.watch(l10nProvider).commonAppName,
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: ref.watch(themeModeProvider),
        // Only genuinely shipped translations are eligible. Runtime wiring
        // does not make an untranslated locale available to users.
        locale: ref.watch(appLocaleProvider).flutter,
        supportedLocales: [
          for (final locale in kShippedLocales) locale.flutter,
        ],
        // AppLocalizations + material_ui's delegates. Never the generated
        // `AppLocalizations.localizationsDelegates` (legacy Material).
        localizationsDelegates: appLocalizationsDelegates,
        // Legacy-Material packages (fl_chart, video_player, inappwebview) still
        // resolve flutter/material Theme/Localizations; bridge them (FS §2).
        // ignore: deprecated_member_use
        builder: (context, child) => MaterialUiCompatibilityBridge(
          child: ProgressNotificationHost(
            child: AccountDataWarmupHost(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
        routerConfig: ref.watch(routerProvider),
      ),
    );
  }
}
