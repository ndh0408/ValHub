import 'package:valvn/core/l10n/account_labels.dart';

import 'dart:async';
import 'dart:collection' show UnmodifiableListView;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, visibleForTesting;
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    hide AndroidOptions;
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../accounts/account.dart';
import '../accounts/account_data_warmup.dart';
import '../geo/region_picker.dart';
import '../accounts/account_providers.dart';
import '../accounts/account_widgets.dart';
import '../accounts/login_note.dart';
import '../config/app_constants.dart';
import '../config/remote_config.dart';
import '../logging/session_log.dart';
import '../network/riot_exception.dart';
import '../theme/app_theme.dart';
import '../ui/adaptive.dart';
import '../ui/empty_view.dart';
import '../ui/error_view.dart';
import '../ui/sub_page.dart';
import '../ui/val_widgets.dart';
import 'auth_callback.dart';
import 'cookie_jar.dart';
import 'login_page_scripts.dart';
import 'remember_me.dart';
import '../l10n/locale_controller.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// S02 "Đăng nhập Riot": Riot's official login page in a WebView
/// (SUMMARY §3.2). The app never sees the password; it only reads the
/// callback tokens and the `auth.riotgames.com` cookies, which are stored
/// on the device (secure storage) and never sent anywhere else.
///
/// Route: `/login` (add account) or `/login?reauth=<puuid>` (re-login).
/// After a successful login: return to the screen that opened the login
/// (re-login from Collection / Settings, "Thêm tài khoản") instead of jumping
/// to the Store. Only the first sign-in (from /welcome) goes to the Store.
@visibleForTesting
bool shouldPopAfterLogin({required bool hadAccounts, required bool canPop}) =>
    hadAccounts && canPop;

/// Clears everything the login WebView keeps between runs: cookies, and where
/// the platform supports it web storage (localStorage, IndexedDB, caches).
/// Every step is best effort (the plugin is missing in tests).
Future<void> clearLoginWebViewData() async {
  try {
    await CookieManager.instance().deleteAllCookies();
  } on Object {
    // Plugin unavailable (tests): continue.
  }
  try {
    if (WebStorageManager.isMethodSupported(
      PlatformWebStorageManagerMethod.deleteAllData,
    )) {
      await WebStorageManager.instance().deleteAllData();
    } else if (WebStorageManager.isMethodSupported(
      PlatformWebStorageManagerMethod.removeDataModifiedSince,
    )) {
      await WebStorageManager.instance().removeDataModifiedSince(
        dataTypes: WebsiteDataType.values,
        date: DateTime.fromMillisecondsSinceEpoch(0),
      );
    }
  } on Object {
    // Web storage cannot be cleared on this platform: cookies were.
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.reauthPuuid});

  /// PUUID of the saved account being signed in again (validated against the
  /// access-token `sub`).
  final String? reauthPuuid;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

enum _Phase { preparing, web, finishing, failed }

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _state = randomHex();
  String _nonce = randomHex();
  _Phase _phase = _Phase.preparing;
  double _progress = 0;
  bool _completed = false;

  /// [_autoFillReauth] runs at most once per screen.
  bool _autoFillTried = false;
  String? _errorMessage;
  InAppWebViewController? _controller;

  // Read once while mounted: failures after the user closed the screen must
  // still be logged without touching `ref` (unsafe once unmounted).
  late final SessionLog _log = ref.read(sessionLogProvider);

  /// False on the very first sign-in (pushed from /welcome): that one lands
  /// on the Store; every other login returns to where the user was.
  late final bool _hadAccounts = ref.read(hasAccountsProvider);

  @override
  void initState() {
    super.initState();
    _log;
    _hadAccounts;
    unawaited(_prepare());
  }

  /// Starts every login from a clean cookie store and web storage so a second
  /// account never reuses the previous account's SSO session.
  Future<void> _prepare() async {
    await clearLoginWebViewData();
    if (mounted) setState(() => _phase = _Phase.web);
  }

  @override
  void dispose() {
    // Closing the page mid-flow must not leave the Riot session in the
    // shared WebView (cookies, local storage, IndexedDB, HTTP cache).
    unawaited(clearLoginWebViewData());
    super.dispose();
  }

  Future<void> _restart() async {
    setState(() {
      _state = randomHex();
      _nonce = randomHex();
      _completed = false;
      _errorMessage = null;
      _progress = 0;
      _phase = _Phase.preparing;
    });
    await _prepare();
  }

  String get _userAgent =>
      ref.read(remoteConfigProvider).webViewUserAgent ??
      (defaultTargetPlatform == TargetPlatform.iOS
          ? RiotClientConstants.webViewUserAgentIos
          : RiotClientConstants.webViewUserAgentAndroid);

  void _fail(String message, {String? logDetail}) {
    _log.add('login.failed', detail: logDetail);
    if (mounted) {
      setState(() {
        _phase = _Phase.failed;
        _errorMessage = message;
      });
    }
  }

  /// Funnel for `shouldOverrideUrlLoading`, `onLoadStart` and
  /// `onUpdateVisitedHistory`; runs once.
  Future<bool> _maybeFinish(WebUri? url) async {
    if (!mounted || _completed || url == null) return false;
    final uri = Uri.tryParse(url.toString());
    if (!isAuthCallback(uri)) return false;
    _completed = true;
    unawaited(_controller?.stopLoading());
    await _handleCallback(uri!);
    return true;
  }

  Future<void> _handleCallback(Uri uri) async {
    if (!mounted) return;
    final l10n = context.l10n;
    setState(() => _phase = _Phase.finishing);
    final result = validateCallback(
      parseCallbackParams(uri),
      expectedState: _state,
      expectedNonce: _nonce,
      expectedPuuid: widget.reauthPuuid,
    );
    switch (result) {
      case CallbackRejected(failure: CallbackFailure.riotError, :final error):
        await _clearWebCookies();
        return _fail(l10n.authLoginCancelledByRiot, logDetail: error);
      case CallbackRejected(failure: CallbackFailure.stateMismatch):
        await _clearWebCookies();
        return _fail(l10n.authStateMismatch, logDetail: 'state_mismatch');
      case CallbackRejected(failure: CallbackFailure.invalidTokens):
      case CallbackRejected(failure: CallbackFailure.nonceMismatch):
        await _clearWebCookies();
        return _fail(l10n.authLoginFailedBody, logDetail: 'invalid_callback');
      case CallbackRejected(
        failure: CallbackFailure.accountMismatch,
        :final tokens?,
      ):
        final cookies = await _captureCookies();
        if (!mounted) return;
        final addNew = await _confirmAddAsNew();
        if (!mounted) return;
        if (addNew != true) {
          context.pop();
          return;
        }
        return _complete(tokens, cookies);
      case CallbackRejected():
        return _fail(l10n.authLoginFailedBody);
      case CallbackSuccess(:final tokens):
        final cookies = await _captureCookies();
        return _complete(tokens, cookies);
    }
  }

  /// Reads the `auth.riotgames.com` cookies (HttpOnly included) after a short
  /// delay for the iOS cookie store, retries once if `ssid` is missing, then
  /// clears the WebView store (SUMMARY §3.2 step 6).
  Future<RiotCookieJar> _captureCookies() async {
    var jar = const RiotCookieJar();
    for (final delay in const [300, 700]) {
      await Future<void>.delayed(Duration(milliseconds: delay));
      if (!mounted) return jar;
      try {
        final list = await CookieManager.instance().getCookies(
          url: WebUri(AuthConstants.cookieUrl),
        );
        jar = jar.withAll({
          for (final c in list)
            if (c.name.isNotEmpty && '${c.value}'.isNotEmpty)
              c.name: '${c.value}',
        });
      } on Object {
        // Try again once.
      }
      if (jar.has(AuthConstants.sessionCookie)) break;
    }
    if (mounted) await _clearWebCookies();
    return jar;
  }

  Future<void> _clearWebCookies() => clearLoginWebViewData();

  Future<void> _complete(AuthTokens tokens, RiotCookieJar cookies) async {
    if (!mounted) return;
    final l10n = context.l10n;
    try {
      final wasSaved = ref.read(accountProvider(tokens.puuid)) != null;
      final account = await ref
          .read(accountsProvider.notifier)
          .completeLogin(tokens: tokens, cookies: cookies);
      if (!mounted) return;
      if (account.needsRegionSelection) {
        await showRegionPicker(context, account);
        if (!mounted) return;
      }
      await ref
          .read(accountDataWarmupProvider)
          .afterLogin(account.puuid, refresh: wasSaved);
      if (!mounted) return;
      if (!cookies.has(AuthConstants.sessionCookie)) {
        showAppSnackBar(context, l10n.authMissingCookies);
      } else if (widget.reauthPuuid != null) {
        showAppSnackBar(context, l10n.authReloginDone);
      }
      if (shouldPopAfterLogin(
        hadAccounts: _hadAccounts,
        canPop: context.canPop(),
      )) {
        context.pop(true);
      } else {
        // The default tab (`/` redirects to the landing page).
        context.go('/');
      }
    } on MaxAccountsException catch (e) {
      _fail(e.message(l10n), logDetail: 'max_accounts');
    } on RiotException catch (e) {
      if (!mounted) return;
      _fail(
        describeError(l10n, e).message,
        logDetail: e.runtimeType.toString(),
      );
    } on Object catch (e) {
      _fail(l10n.authLoginFailedBody, logDetail: e.runtimeType.toString());
    }
  }

  Future<bool?> _confirmAddAsNew() => showConfirmDialog(
    context,
    title: context.l10n.authDifferentAccountTitle,
    message: context.l10n.authDifferentAccountBody,
    confirmLabel: context.l10n.authAddAsNew,
  );

  Future<NavigationActionPolicy> _shouldOverride(
    NavigationAction action,
  ) async {
    if (!mounted) return NavigationActionPolicy.CANCEL;
    final l10n = context.l10n;
    final url = action.request.url;
    if (await _maybeFinish(url)) return NavigationActionPolicy.CANCEL;
    if (!mounted) return NavigationActionPolicy.CANCEL;
    if (url == null || !action.isForMainFrame) {
      return NavigationActionPolicy.ALLOW;
    }
    final scheme = url.scheme.toLowerCase();
    if (scheme == 'about' || scheme == 'data' || scheme == 'blob') {
      return NavigationActionPolicy.ALLOW;
    }
    if (scheme == 'https' && isAllowedLoginHost(url.host)) {
      return NavigationActionPolicy.ALLOW;
    }
    // Help pages, legal links, app deep links: open outside the login WebView.
    final external = Uri.tryParse(url.toString());
    if (external != null && (scheme == 'https' || scheme == 'http')) {
      unawaited(launchUrl(external, mode: LaunchMode.externalApplication));
      if (mounted) showAppSnackBar(context, l10n.authOpenedInBrowser);
    }
    return NavigationActionPolicy.CANCEL;
  }

  /// Ticks "Stay signed in" on Riot's own login page so the account keeps a
  /// sliding 30-day session instead of dying after a day (see
  /// [rememberMeScript]).
  Future<void> _tickRememberMe(
    InAppWebViewController controller,
    WebUri? url,
  ) async {
    if (!mounted || _completed) return;
    if (!shouldTickRememberMe(Uri.tryParse(url?.toString() ?? ''))) return;
    try {
      await controller.evaluateJavascript(source: rememberMeScript);
      // Riot's storage banner covers half of the form: close it (essential
      // cookies only, as the banner itself offers).
      await controller.evaluateJavascript(source: consentBannerScript);
    } on Object {
      // The page navigated away meanwhile.
    }
    unawaited(_autoFillReauth(controller));
  }

  /// Signing in again to an account with a saved login note: its username
  /// and password are typed into Riot's form as soon as the form appears,
  /// once per screen; the player only presses Riot's sign-in button (and
  /// solves Riot's captcha if it asks). Never for a different account.
  Future<void> _autoFillReauth(InAppWebViewController controller) async {
    final puuid = widget.reauthPuuid;
    if (puuid == null || _autoFillTried || !mounted || _completed) return;
    // build() watches this provider, so it has loaded by the time Riot's
    // page has.
    final saved =
        ref.read(savedLoginNotesProvider(puuid)).value ??
        const <(Account, LoginNote)>[];
    if (!saved.any((e) => e.$1.puuid == puuid)) return;
    _autoFillTried = true;
    final l10n = context.l10n;
    final note = await ref.read(loginNoteProvider(puuid).future);
    if (!mounted) return;
    if (note == null) {
      showAppSnackBar(context, l10n.accountQuickFillLocked);
      return;
    }
    if (note.username.isEmpty || note.password.isEmpty) return;
    // Riot's page renders its form after load: try for about five seconds.
    for (var attempt = 0; attempt < 10; attempt++) {
      if (!mounted || _completed) return;
      final url = await controller.getUrl();
      final host = url?.host ?? '';
      if (url?.scheme != 'https' ||
          (host != 'auth.riotgames.com' &&
              host != 'authenticate.riotgames.com')) {
        return;
      }
      Object? ok;
      try {
        ok = await controller.evaluateJavascript(
          source: loginNoteFillScript(note),
        );
      } on Object {
        ok = false;
      }
      if (ok == true) {
        if (mounted) showAppSnackBar(context, l10n.accountQuickFillDone);
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Types a saved login note into Riot's page (only on a Riot host; the
  /// values never leave the device otherwise).
  Future<void> _quickFill(List<(Account, LoginNote)> saved) async {
    if (!mounted) return;
    final l10n = context.l10n;
    final controller = _controller;
    if (controller == null || saved.isEmpty) return;
    var selected = saved.first.$1;
    if (saved.length > 1 || saved.first.$1.puuid != widget.reauthPuuid) {
      final picked = await _pickNote(saved);
      if (picked == null || !mounted) return;
      selected = picked;
    }
    ref.invalidate(loginNoteProvider(selected.puuid));
    final note = await ref.read(loginNoteProvider(selected.puuid).future);
    if (!mounted) return;
    if (note == null) {
      // The device unlock failed or the phone has no screen lock: say so
      // instead of silently doing nothing.
      showAppSnackBar(context, l10n.accountQuickFillLocked);
      return;
    }
    // Recheck the destination AFTER unlocking; navigation may have changed.
    final url = await controller.getUrl();
    final host = url?.host ?? '';
    // Riot's own pages only (never Google / Facebook / Apple sign-in).
    if (url?.scheme != 'https' ||
        (host != 'auth.riotgames.com' &&
            host != 'authenticate.riotgames.com')) {
      if (mounted) showAppSnackBar(context, l10n.accountQuickFillNotReady);
      return;
    }
    Object? ok;
    try {
      ok = await controller.evaluateJavascript(
        source: loginNoteFillScript(note),
      );
    } on Object {
      ok = false;
    }
    if (!mounted) return;
    showAppSnackBar(
      context,
      ok == true ? l10n.accountQuickFillDone : l10n.accountQuickFillNotReady,
    );
  }

  Future<Account?> _pickNote(List<(Account, LoginNote)> saved) =>
      showValSheet<Account>(
        context,
        title: context.l10n.accountQuickFillTitle,
        subtitle: context.l10n.accountQuickFillSubtitle,
        builder: (context, _) => ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
          children: [
            GroupedSection(
              children: [
                for (final (account, _) in saved)
                  GroupedRow(
                    title: account.displayRiotId(context.l10n),
                    subtitle: context.l10n.accountLoginNote,
                    leading: AccountAvatar(
                      account: account,
                      size: 40,
                      circle: true,
                    ),
                    onTap: () => Navigator.of(context).pop(account),
                  ),
              ],
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final saved =
        ref.watch(savedLoginNotesProvider(widget.reauthPuuid)).value ??
        const <(Account, LoginNote)>[];
    final socialHint = ref
        .watch(remoteConfigProvider)
        .flag(RemoteFlags.socialLoginHint, fallback: true);
    final onWeb = _phase == _Phase.web;
    // Riot's page fills the screen like a native sign-in: only a close
    // button, the official-host badge and (with a saved note) quick fill
    // float over it.
    final scaffold = Scaffold(
      backgroundColor: onWeb ? _riotPageBackground : null,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: !onWeb,
              child: switch (_phase) {
                _Phase.preparing => _CenteredStatus(
                  message: context.l10n.authPreparing,
                ),
                _Phase.finishing => _CenteredStatus(
                  message: context.l10n.authLoadingAccount,
                ),
                _Phase.failed => _FailedView(
                  message: _errorMessage ?? context.l10n.authLoginFailedBody,
                  hint: socialHint ? context.l10n.authSocialLoginHint : null,
                  onRetry: _restart,
                ),
                _Phase.web => _webView(),
              },
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (onWeb && _progress < 1)
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: _progress),
                    duration: ValMotion.medium,
                    builder: (context, v, _) =>
                        LinearProgressIndicator(value: v, minHeight: 2),
                  )
                else
                  const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                  child: Row(
                    children: [
                      _OverlayCloseButton(
                        onWeb: onWeb,
                        onPressed: () => context.canPop()
                            ? context.pop()
                            : context.go('/welcome'),
                      ),
                      const Spacer(),
                      _OfficialBadge(onWeb: onWeb),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (onWeb && saved.isNotEmpty)
            PositionedDirectional(
              end: 16,
              bottom: 16 + MediaQuery.paddingOf(context).bottom,
              child: FloatingActionButton.extended(
                heroTag: null,
                onPressed: () => unawaited(_quickFill(saved)),
                icon: const Icon(Icons.key),
                label: Text(context.l10n.accountQuickFill),
              ),
            ),
        ],
      ),
    );
    // Light status-bar icons over Riot's dark page.
    return onWeb
        ? AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: scaffold,
          )
        : scaffold;
  }

  Widget _webView() => InAppWebView(
    key: ValueKey(_state),
    initialUrlRequest: URLRequest(
      url: WebUri(
        buildAuthorizeUrl(
          state: _state,
          nonce: _nonce,
          uiLocales: ref.read(appLocaleProvider).riotUiLocale,
        ),
      ),
    ),
    initialUserScripts: UnmodifiableListView([
      UserScript(
        source: riotLocaleScript(ref.read(appLocaleProvider).tag),
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      ),
    ]),
    initialSettings: InAppWebViewSettings(
      useShouldOverrideUrlLoading: true,
      javaScriptEnabled: true,
      thirdPartyCookiesEnabled: true,
      sharedCookiesEnabled: true,
      incognito: false,
      supportZoom: false,
      supportMultipleWindows: false,
      userAgent: _userAgent,
    ),
    onWebViewCreated: (controller) => _controller = controller,
    shouldOverrideUrlLoading: (controller, action) => _shouldOverride(action),
    onLoadStart: (controller, url) => unawaited(_maybeFinish(url)),
    onUpdateVisitedHistory: (controller, url, isReload) =>
        unawaited(_maybeFinish(url)),
    onLoadStop: (controller, url) =>
        unawaited(_tickRememberMe(controller, url)),
    onCreateWindow: (controller, action) async {
      final url = action.request.url;
      if (url != null) {
        _log.add('login.popup');
        await controller.loadUrl(urlRequest: URLRequest(url: url));
      }
      return false;
    },
    onProgressChanged: (controller, progress) {
      if (mounted) setState(() => _progress = progress / 100);
    },
    onReceivedError: (controller, request, error) {
      if (_completed) return;
      final uri = Uri.tryParse(request.url.toString());
      if (isCallbackLocation(uri)) return; // the cancelled callback navigation
      if (request.isForMainFrame ?? true) {
        _fail(
          context.l10n.authPageLoadFailed,
          logDetail: error.type.toString(),
        );
      }
    },
  );
}

/// Behind Riot's page while it loads (its own header is this dark navy), so
/// the switch from the app to the page does not flash white.
const Color _riotPageBackground = Color(0xFF111823);

/// Round close button floating over Riot's page.
class _OverlayCloseButton extends StatelessWidget {
  const _OverlayCloseButton({required this.onWeb, required this.onPressed});

  final bool onWeb;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: context.l10n.commonClose,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: onWeb
            ? Colors.black.withValues(alpha: 0.45)
            : scheme.surfaceContainerHighest,
        foregroundColor: onWeb ? Colors.white : scheme.onSurface,
        minimumSize: const Size.square(kMinInteractiveDimension),
      ),
      icon: const Icon(Icons.close),
    );
  }
}

/// A round lock next to the close button: the page is Riot's own and the
/// app never sees the password. Kept as a small circle so it never covers
/// Riot's logo; the full "Trang chính thức · auth.riotgames.com" is its
/// tooltip and spoken label.
class _OfficialBadge extends StatelessWidget {
  const _OfficialBadge({required this.onWeb});

  final bool onWeb;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label =
        '${context.l10n.authLoginTitle}. ${context.l10n.authOfficialHost}';
    return Tooltip(
      message: context.l10n.authOfficialHost,
      triggerMode: TooltipTriggerMode.tap,
      child: Semantics(
        label: label,
        excludeSemantics: true,
        child: Container(
          width: kMinInteractiveDimension,
          height: kMinInteractiveDimension,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onWeb
                ? Colors.black.withValues(alpha: 0.45)
                : scheme.surfaceContainerHighest,
          ),
          child: Icon(Icons.lock, size: 20, color: valColorsOf(context).win),
        ),
      ),
    );
  }
}

class _CenteredStatus extends StatelessWidget {
  const _CenteredStatus({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
              ),
              alignment: Alignment.center,
              child: const SizedBox.square(
                dimension: 32,
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FailedView extends StatelessWidget {
  const _FailedView({required this.message, required this.onRetry, this.hint});

  final String message;
  final Future<void> Function() onRetry;

  /// "Google / Facebook sign-in failing? Use your Riot username."
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StateIcon(
                icon: Icons.error_outline,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.authLoginFailed,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              if (hint != null) ...[
                const SizedBox(height: 12),
                Text(
                  hint!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => unawaited(onRetry()),
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
