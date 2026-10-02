import 'dart:async';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, visibleForTesting;
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    hide AndroidOptions;
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
import '../l10n/account_strings.dart';
import '../l10n/auth_strings.dart';
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
    if (_completed || url == null) return false;
    final uri = Uri.tryParse(url.toString());
    if (!isAuthCallback(uri)) return false;
    _completed = true;
    unawaited(_controller?.stopLoading());
    await _handleCallback(uri!);
    return true;
  }

  Future<void> _handleCallback(Uri uri) async {
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
        return _fail(AuthStrings.loginCancelledByRiot, logDetail: error);
      case CallbackRejected(failure: CallbackFailure.stateMismatch):
        await _clearWebCookies();
        return _fail(AuthStrings.stateMismatch, logDetail: 'state_mismatch');
      case CallbackRejected(failure: CallbackFailure.invalidTokens):
      case CallbackRejected(failure: CallbackFailure.nonceMismatch):
        await _clearWebCookies();
        return _fail(
          AuthStrings.loginFailedBody,
          logDetail: 'invalid_callback',
        );
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
        return _fail(AuthStrings.loginFailedBody);
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
    await _clearWebCookies();
    return jar;
  }

  Future<void> _clearWebCookies() => clearLoginWebViewData();

  Future<void> _complete(AuthTokens tokens, RiotCookieJar cookies) async {
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
        showAppSnackBar(context, AuthStrings.missingCookies);
      } else if (widget.reauthPuuid != null) {
        showAppSnackBar(context, AuthStrings.reloginDone);
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
      _fail(e.message, logDetail: 'max_accounts');
    } on RiotException catch (e) {
      _fail(describeError(e).message, logDetail: e.runtimeType.toString());
    } on Object catch (e) {
      _fail(AuthStrings.loginFailedBody, logDetail: e.runtimeType.toString());
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
    final url = action.request.url;
    if (await _maybeFinish(url)) return NavigationActionPolicy.CANCEL;
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
      if (mounted) showAppSnackBar(context, AuthStrings.openedInBrowser);
    }
    return NavigationActionPolicy.CANCEL;
  }

  /// Types a saved login note into Riot's page (only on a Riot host; the
  /// values never leave the device otherwise).
  Future<void> _quickFill(List<(Account, LoginNote)> saved) async {
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
    if (note == null || !mounted) return;
    // Recheck the destination AFTER unlocking; navigation may have changed.
    final url = await controller.getUrl();
    final host = url?.host ?? '';
    // Riot's own pages only (never Google / Facebook / Apple sign-in).
    if (url?.scheme != 'https' ||
        (host != 'auth.riotgames.com' &&
            host != 'authenticate.riotgames.com')) {
      if (mounted) showAppSnackBar(context, AccountStrings.quickFillNotReady);
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
      ok == true
          ? AccountStrings.quickFillDone
          : AccountStrings.quickFillNotReady,
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
                    title: account.riotId,
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
    return Scaffold(
      appBar: AppBar(
        title: const _LoginTitle(),
        leadingWidth: 64,
        leading: Center(
          child: SheetCloseButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/welcome'),
          ),
        ),
        bottom: _phase == _Phase.web && _progress < 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: _progress),
                  duration: ValMotion.medium,
                  builder: (context, v, _) =>
                      LinearProgressIndicator(value: v, minHeight: 3),
                ),
              )
            : null,
      ),
      body: switch (_phase) {
        _Phase.preparing => _CenteredStatus(
          message: context.l10n.authPreparing,
        ),
        _Phase.finishing => _CenteredStatus(
          message: context.l10n.authLoadingAccount,
        ),
        _Phase.failed => _FailedView(
          message: _errorMessage ?? context.l10n.authLoginFailedBody,
          onRetry: _restart,
        ),
        _Phase.web => Column(
          children: [
            _Hint(
              text: context.l10n.authRememberMeHint,
              secondary: socialHint ? context.l10n.authSocialLoginHint : null,
              action: saved.isEmpty
                  ? null
                  : FilledButton.tonalIcon(
                      onPressed: () => unawaited(_quickFill(saved)),
                      icon: const Icon(Icons.key, size: 18),
                      label: Text(context.l10n.accountQuickFill),
                    ),
            ),
            Expanded(child: _webView()),
          ],
        ),
      },
    );
  }

  Widget _webView() => InAppWebView(
    key: ValueKey(_state),
    initialUrlRequest: URLRequest(
      url: WebUri(buildAuthorizeUrl(state: _state, nonce: _nonce)),
    ),
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

class _Hint extends StatelessWidget {
  const _Hint({required this.text, this.secondary, this.action});

  final String text;
  final String? secondary;

  /// "Điền nhanh" when a login note is saved.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final light = theme.brightness == Brightness.light;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(ValRadius.card),
        border: light ? Border.all(color: valColorsOf(context).hairline) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primary.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: legibleAccent(context, scheme.primary, min: 3),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (secondary != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            secondary!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (action != null)
              Align(alignment: AlignmentDirectional.centerEnd, child: action),
          ],
        ),
      ),
    );
  }
}

/// "Đăng nhập Riot" with a lock and the official host underneath, so it
/// is clear the page is Riot's own.
class _LoginTitle extends StatelessWidget {
  const _LoginTitle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final win = valColorsOf(context).win;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.authLoginTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 12, color: win),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                context.l10n.authOfficialHost,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
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
  const _FailedView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

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
