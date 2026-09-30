/// Riot login URL building, callback detection, parsing and validation
/// (SUMMARY §3.1–§3.2, riot-auth §1.1–§1.4). Pure Dart; unit-tested.
library;

import 'dart:math';

import 'package:flutter/foundation.dart';

import '../config/app_constants.dart';
import '../util/json.dart';
import 'jwt.dart';

/// 32 random bytes as lowercase hex (used for `state` and `nonce`).
String randomHex([int bytes = 32, Random? random]) {
  final r = random ?? Random.secure();
  final buffer = StringBuffer();
  for (var i = 0; i < bytes; i++) {
    buffer.write(r.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

String _enc(String v) => Uri.encodeComponent(v);

/// Interactive login URL (A-1). Spaces are encoded as `%20` to match the
/// documented URL exactly.
String buildAuthorizeUrl({required String state, required String nonce}) =>
    '${AuthConstants.authorizeUrl}'
    '?redirect_uri=${_enc(AuthConstants.redirectUri)}'
    '&client_id=${_enc(AuthConstants.clientId)}'
    '&response_type=${_enc(AuthConstants.responseType)}'
    '&scope=${_enc(AuthConstants.scope)}'
    '&nonce=${_enc(nonce)}'
    '&state=${_enc(state)}'
    '&ui_locales=${_enc(AuthConstants.uiLocales)}';

/// Silent re-auth URL (A-2): `nonce=1&prompt=none`.
final String reauthAuthorizeUrl =
    '${AuthConstants.authorizeUrl}'
    '?redirect_uri=${_enc(AuthConstants.redirectUri)}'
    '&client_id=${_enc(AuthConstants.clientId)}'
    '&response_type=${_enc(AuthConstants.responseType)}'
    '&scope=${_enc(AuthConstants.scope)}'
    '&nonce=${AuthConstants.reauthNonce}'
    '&prompt=none';

final RegExp _callbackPath = RegExp(
  r'^/(?:[a-z]{2}-[a-z]{2}/)?opt_in/?$',
  caseSensitive: false,
);

/// Strict callback matcher (SUMMARY §3.1 "Callback match"): https,
/// `playvalorant.com` / `www.playvalorant.com`, path `/opt_in` or
/// `/{locale}/opt_in`, and a fragment (or query) carrying `access_token` or
/// `error`.
bool isAuthCallback(Uri? uri) {
  if (uri == null) return false;
  if (uri.scheme.toLowerCase() != 'https') return false;
  final host = uri.host.toLowerCase();
  if (host != 'playvalorant.com' && host != 'www.playvalorant.com') {
    return false;
  }
  if (!_callbackPath.hasMatch(uri.path)) return false;
  final params = parseCallbackParams(uri);
  return params.containsKey('access_token') || params.containsKey('error');
}

/// True when [uri] is a callback URL by host/path alone (used to ignore load
/// errors of the cancelled navigation).
bool isCallbackLocation(Uri? uri) =>
    uri != null &&
    uri.scheme.toLowerCase() == 'https' &&
    (uri.host.toLowerCase() == 'playvalorant.com' ||
        uri.host.toLowerCase() == 'www.playvalorant.com') &&
    _callbackPath.hasMatch(uri.path);

/// Parses the callback fragment (or, as a fallback, the query) into
/// `name → all values` so duplicates can be detected.
Map<String, List<String>> parseCallbackParams(Uri uri) {
  final raw = uri.fragment.isNotEmpty ? uri.fragment : uri.query;
  return parseParamString(raw);
}

/// Parses an `a=1&b=2` string (form encoding, `+` = space) into multi-values.
Map<String, List<String>> parseParamString(String raw) {
  final out = <String, List<String>>{};
  for (final pair in raw.split('&')) {
    if (pair.isEmpty) continue;
    final i = pair.indexOf('=');
    final rawKey = i < 0 ? pair : pair.substring(0, i);
    final rawValue = i < 0 ? '' : pair.substring(i + 1);
    final key = _decode(rawKey);
    if (key.isEmpty) continue;
    (out[key] ??= []).add(_decode(rawValue));
  }
  return out;
}

String _decode(String s) {
  try {
    return Uri.decodeQueryComponent(s);
  } on Object {
    return s;
  }
}

/// Tokens extracted from a valid callback.
@immutable
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.idToken,
    required this.expiresAt,
    required this.puuid,
  });

  /// Builds tokens from callback params; `null` when a token is missing.
  static AuthTokens? fromParams(
    Map<String, List<String>> params, {
    required DateTime receivedAt,
  }) {
    final access = _single(params, 'access_token');
    final id = _single(params, 'id_token');
    if (access == null || id == null) return null;
    final puuid = jwtSubject(access);
    if (puuid == null) return null;
    final expiresIn = asInt(_single(params, 'expires_in'));
    final expiresAt = expiresIn != null && expiresIn > 0
        ? receivedAt.add(Duration(seconds: expiresIn))
        : (jwtExpiry(access)?.toLocal() ??
              receivedAt.add(AuthConstants.defaultTokenLifetime));
    return AuthTokens(
      accessToken: access,
      idToken: id,
      expiresAt: expiresAt,
      puuid: puuid,
    );
  }

  final String accessToken;
  final String idToken;
  final DateTime expiresAt;

  /// Lowercase PUUID (access-token `sub`).
  final String puuid;

  @override
  String toString() => 'AuthTokens(expiresAt: $expiresAt)';
}

String? _single(Map<String, List<String>> params, String key) {
  final values = params[key];
  if (values == null || values.length != 1) return null;
  final v = values.single.trim();
  return v.isEmpty ? null : v;
}

/// Why a callback was rejected.
enum CallbackFailure {
  /// Riot returned `error=…` (e.g. `access_denied`, `login_required`).
  riotError,

  /// `state` missing or different from ours (possible CSRF / stale page).
  stateMismatch,

  /// `access_token` / `id_token` missing, empty or duplicated.
  invalidTokens,

  /// `id_token.nonce` does not match ours.
  nonceMismatch,

  /// Re-login signed into a different account than [expectedPuuid].
  accountMismatch,
}

/// Result of [validateCallback].
sealed class CallbackResult {
  const CallbackResult();
}

final class CallbackSuccess extends CallbackResult {
  const CallbackSuccess(this.tokens);
  final AuthTokens tokens;
}

final class CallbackRejected extends CallbackResult {
  const CallbackRejected(
    this.failure, {
    this.error,
    this.actualPuuid,
    this.tokens,
  });

  final CallbackFailure failure;

  /// Riot's `error` value for [CallbackFailure.riotError].
  final String? error;

  /// PUUID of the account that actually signed in (account mismatch).
  final String? actualPuuid;

  /// The (valid) tokens for [CallbackFailure.accountMismatch], so the caller
  /// can offer "add as a new account".
  final AuthTokens? tokens;
}

/// Validates a callback (SUMMARY §3.2 step 5).
CallbackResult validateCallback(
  Map<String, List<String>> params, {
  required String expectedState,
  required String expectedNonce,
  String? expectedPuuid,
  DateTime? receivedAt,
}) {
  final error = params['error'];
  if (error != null) {
    return CallbackRejected(
      CallbackFailure.riotError,
      error: error.isEmpty ? null : error.first,
    );
  }
  if (_single(params, 'state') != expectedState) {
    return const CallbackRejected(CallbackFailure.stateMismatch);
  }
  final tokens = AuthTokens.fromParams(
    params,
    receivedAt: receivedAt ?? DateTime.now(),
  );
  if (tokens == null) {
    return const CallbackRejected(CallbackFailure.invalidTokens);
  }
  if (jwtNonce(tokens.idToken) != expectedNonce) {
    return const CallbackRejected(CallbackFailure.nonceMismatch);
  }
  if (expectedPuuid != null && tokens.puuid != expectedPuuid.toLowerCase()) {
    return CallbackRejected(
      CallbackFailure.accountMismatch,
      actualPuuid: tokens.puuid,
      tokens: tokens,
    );
  }
  return CallbackSuccess(tokens);
}

/// Hosts the login WebView may navigate the **main frame** to
/// (SUMMARY §3.2 step 3). Everything else opens in the system browser.
///
/// Every entry is an exact host or a `.domain` suffix: a prefix match such as
/// `lolstatic*` would let `lolstatic.evil.com` through (AR-021).
bool isAllowedLoginHost(String host) {
  final h = host.toLowerCase();
  bool under(String domain) => h == domain || h.endsWith('.$domain');
  return under('riotgames.com') ||
      under('playvalorant.com') ||
      h == 'accounts.google.com' ||
      h == 'appleid.apple.com' ||
      h == 'login.live.com' ||
      under('playstation.com') ||
      under('facebook.com') ||
      under('hcaptcha.com') ||
      under('lolstatic.com') ||
      h == 'lolstatic-a.akamaihd.net';
}
