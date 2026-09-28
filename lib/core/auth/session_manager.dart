import 'dart:async';

import 'package:flutter/foundation.dart';

import '../accounts/account.dart';
import '../accounts/account_repository.dart';
import '../config/client_version.dart';
import '../config/remote_config.dart';
import '../logging/session_log.dart';
import '../network/riot_exception.dart';
import '../riot/riot_hosts.dart';
import '../storage/secure_store.dart';
import '../util/clock.dart';
import '../util/json.dart';
import 'account_lock.dart';
import 'auth_callback.dart';
import 'bootstrap_client.dart';
import 'cookie_jar.dart';
import 'reauth_client.dart';
import 'riot_session.dart';

/// Emitted when an account's login state changes.
sealed class SessionEvent {
  const SessionEvent(this.puuid);
  final String puuid;
}

/// The account's cookies died; it is now marked `needsLogin`.
final class SessionNeedsLogin extends SessionEvent {
  const SessionNeedsLogin(super.puuid);
}

/// The account (previously `needsLogin`) has a working session again.
final class SessionRestored extends SessionEvent {
  const SessionRestored(super.puuid);
}

/// Combines the first re-auth attempt with its single retry:
/// - retry ok → ok;
/// - both needsLogin → needsLogin;
/// - first transient, retry needsLogin with the SAME jar → needsLogin;
/// - otherwise transient (an older jar being dead proves nothing about the
///   current one, and a Cloudflare block proves nothing either).
@visibleForTesting
ReauthOutcome resolveReauthRetry(
  ReauthOutcome first,
  ReauthOutcome retry, {
  required bool retriedWithPrevious,
}) {
  if (first is ReauthOk) return first;
  if (retry is ReauthOk) return retry;
  if (first is ReauthNeedsLogin && retry is ReauthNeedsLogin) return first;
  if (first is ReauthTransient &&
      retry is ReauthNeedsLogin &&
      !retriedWithPrevious) {
    return retry;
  }
  if (retry is ReauthTransient) return retry;
  if (first is ReauthTransient) return first;
  // first needsLogin (current jar), retry transient with the previous jar.
  return ReauthTransient('previous_jar_unverified', first.jar);
}

/// Result of [SessionManager.establishFromLogin].
@immutable
class LoginEstablished {
  const LoginEstablished({
    required this.session,
    required this.userInfo,
    required this.hasSessionCookie,
  });

  final RiotSession session;
  final RiotUserInfo userInfo;

  /// False when `ssid` was not captured: the session works for this hour but
  /// cannot be renewed silently (riot-auth §1.6).
  final bool hasSessionCookie;
}

/// Owns every account's Riot session (SUMMARY §3.3–§3.5):
///
/// - in-memory token cache, refreshed when < 5 min are left;
/// - single-flight re-auth per PUUID (in-process) + [AccountLock]
///   (cross-isolate);
/// - persists rotated cookies BEFORE using the new tokens, keeps the previous
///   jar and retries once with it;
/// - marks accounts `needsLogin` exactly once and never loops.
///
/// Plain class: the UI gets it from `sessionManagerProvider`, background
/// isolates construct it directly (see `BackgroundContext`).
class SessionManager {
  SessionManager({
    required SecureStore secureStore,
    required this._accounts,
    required RiotReauthClient reauthClient,
    required RiotBootstrapClient bootstrapClient,
    required this._versions,
    RemoteConfig Function()? remoteConfig,
    AccountLock? lock,
    this._log,
    this._clock = const Clock(),
  }) : _secure = secureStore,
       _reauth = reauthClient,
       _bootstrap = bootstrapClient,
       _config = remoteConfig ?? (() => RemoteConfig.defaults),
       _lock = lock ?? LocalAccountLock();

  final SecureStore _secure;
  final AccountRepository _accounts;
  final RiotReauthClient _reauth;
  final RiotBootstrapClient _bootstrap;
  final ClientVersionRepository _versions;
  final RemoteConfig Function() _config;
  final AccountLock _lock;
  final SessionLog? _log;
  final Clock _clock;

  final Map<String, RiotSession> _cache = {};
  final Map<String, Future<RiotSession>> _inFlight = {};
  final StreamController<SessionEvent> _events =
      StreamController<SessionEvent>.broadcast();

  /// Login-state changes (needsLogin / restored).
  Stream<SessionEvent> get events => _events.stream;

  /// A valid session for [puuid], refreshing silently when needed.
  ///
  /// Throws [NeedsLoginException] (cookies dead; never retried) or
  /// [TransientException] (keep the session, retry later).
  Future<RiotSession> session(String puuid) async {
    final id = puuid.toLowerCase();
    final cached = _cache[id];
    if (cached != null && !cached.isExpiringSoon(_clock.now())) {
      return _withCurrentVersion(cached);
    }
    try {
      return await _singleFlight(id, failedAccessToken: null);
    } on TransientException {
      // Early refresh failed transiently: keep using the old token while it
      // is still valid (it has < 5 min left).
      if (cached != null && _clock.now().isBefore(cached.expiresAt)) {
        return _withCurrentVersion(cached);
      }
      rethrow;
    }
  }

  /// Forces a re-auth after the server rejected [failedAccessToken]
  /// (401 / 400 BAD_CLAIMS). Concurrent callers share one re-auth; if another
  /// caller already replaced that token, the newer session is returned
  /// without a second re-auth.
  Future<RiotSession> refreshAfterAuthFailure(
    String puuid, {
    required String failedAccessToken,
  }) {
    final id = puuid.toLowerCase();
    final cached = _cache[id];
    if (cached != null &&
        cached.accessToken != failedAccessToken &&
        !cached.isExpiringSoon(_clock.now())) {
      return Future.value(_withCurrentVersion(cached));
    }
    _cache.remove(id);
    return _singleFlight(id, failedAccessToken: failedAccessToken);
  }

  /// The cached session without any network call (may be expired or null).
  RiotSession? peek(String puuid) => _cache[puuid.toLowerCase()];

  /// Drops the in-memory session (e.g. after the app was backgrounded long).
  void invalidate(String puuid) => _cache.remove(puuid.toLowerCase());

  /// Drops the session and deletes the account's secrets (sign-out).
  Future<void> forget(String puuid) async {
    final id = puuid.toLowerCase();
    _cache.remove(id);
    for (final key in SecureKeys.allFor(id)) {
      await _secure.delete(key);
    }
  }

  Future<void> dispose() => _events.close();

  RiotSession _withCurrentVersion(RiotSession s) {
    final version = _versions.current.riotClientVersion;
    final ua = _versions.apiUserAgent;
    return (s.clientVersion == version && s.userAgent == ua)
        ? s
        : s.copyWith(clientVersion: version, userAgent: ua);
  }

  Future<RiotSession> _singleFlight(String id, {String? failedAccessToken}) {
    final existing = _inFlight[id];
    if (existing != null) return existing;
    final future = _lock
        .run(id, () => _refresh(id, failedAccessToken: failedAccessToken))
        // removeWhere returns void: returning the removed future itself
        // would make whenComplete wait on itself (deadlock).
        .whenComplete(() => _inFlight.removeWhere((key, _) => key == id));
    _inFlight[id] = future;
    return future;
  }

  Future<RiotSession> _refresh(String id, {String? failedAccessToken}) async {
    final account = _accounts.find(id);
    if (account == null) {
      throw NeedsLoginException(puuid: id, reason: 'unknown_account');
    }
    if (account.needsLogin) {
      throw NeedsLoginException(puuid: id, reason: 'marked');
    }

    // Another isolate (or an earlier run) may already hold fresh tokens.
    final stored = await _readTokenCache(id, account);
    if (stored != null &&
        !stored.isExpiringSoon(_clock.now()) &&
        stored.accessToken != failedAccessToken) {
      _cache[id] = stored;
      return stored;
    }

    final started = _clock.now();
    final jar = RiotCookieJar.decode(
      await _secure.read(SecureKeys.cookies(id)),
    );
    final prevRaw = await _secure.read(SecureKeys.previousCookies(id));
    final prev = prevRaw == null ? null : RiotCookieJar.decode(prevRaw);
    final postFirst = _config().flag(RemoteFlags.reauthPostFirst);

    final first = await _reauth.reauth(jar, postFirst: postFirst);
    var outcome = first;
    var usedPrevious = false;
    if (first is! ReauthOk) {
      // One retry: with the previous jar when it differs, else the same jar
      // (~7–9 % of re-auths fail sporadically; SUMMARY §3.4).
      final hasPrev = prev != null && prev.isNotEmpty && prev != jar;
      final retry = await _reauth.reauth(
        hasPrev ? prev : jar,
        postFirst: postFirst,
      );
      outcome = resolveReauthRetry(first, retry, retriedWithPrevious: hasPrev);
      usedPrevious = hasPrev && outcome is ReauthOk;
    }

    switch (outcome) {
      case ReauthOk(:final tokens, jar: final rotated):
        // Persist rotated cookies BEFORE using the tokens.
        if (usedPrevious) {
          await _secure.write(SecureKeys.cookies(id), rotated.encode());
        } else {
          if (jar.isNotEmpty) {
            await _secure.write(SecureKeys.previousCookies(id), jar.encode());
          }
          await _secure.write(SecureKeys.cookies(id), rotated.encode());
        }
        if (tokens.puuid != id) {
          // The jar belongs to another account (should never happen).
          await _markNeedsLogin(id, 'puuid_mismatch');
          throw NeedsLoginException(puuid: id, reason: 'puuid_mismatch');
        }
        final session = await _buildSession(account, tokens);
        _log?.add(
          'reauth.ok',
          elapsed: _clock.now().difference(started),
          detail: usedPrevious ? 'previous_jar' : null,
        );
        return session;
      case ReauthNeedsLogin(:final reason):
        _log?.add(
          'reauth.needsLogin',
          elapsed: _clock.now().difference(started),
          detail: reason,
        );
        await _markNeedsLogin(id, reason);
        throw NeedsLoginException(puuid: id, reason: reason);
      case ReauthTransient(:final reason, :final retryAfter, :final status):
        _log?.add(
          'reauth.transient',
          status: status,
          elapsed: _clock.now().difference(started),
          detail: reason,
        );
        throw TransientException(
          retryAfter: retryAfter,
          status: status,
          reason: reason,
        );
    }
  }

  Future<RiotSession> _buildSession(
    Account account,
    AuthTokens tokens, {
    String? knownRegion,
  }) async {
    final entitlements = await _bootstrap.fetchEntitlementsToken(
      tokens.accessToken,
    );
    var region = knownRegion ?? account.region;
    if (!supportedRegions.contains(region)) {
      region = await _bootstrap.fetchRegion(tokens.accessToken, tokens.idToken);
      await _accounts.patch(
        account.puuid,
        (a) => a.copyWith(region: region, shard: shardForRegion(region)),
      );
    }
    final session = RiotSession(
      puuid: account.puuid,
      accessToken: tokens.accessToken,
      idToken: tokens.idToken,
      entitlementsToken: entitlements,
      expiresAt: tokens.expiresAt,
      hosts: RiotHosts.forRegion(region),
      clientVersion: _versions.current.riotClientVersion,
      userAgent: _versions.apiUserAgent,
    );
    await _writeTokenCache(session);
    _cache[account.puuid] = session;
    if (account.needsLogin) {
      await _accounts.patch(
        account.puuid,
        (a) => a.copyWith(needsLogin: false),
      );
      _events.add(SessionRestored(account.puuid));
    }
    return session;
  }

  /// After a successful WebView login (SUMMARY §3.2 steps 6–7): stores the
  /// cookie jar, fetches entitlements, Riot ID and region. Does **not** add
  /// the account; the caller does (after checking the 10-account limit).
  Future<LoginEstablished> establishFromLogin({
    required AuthTokens tokens,
    required RiotCookieJar cookies,
  }) async {
    final id = tokens.puuid;
    return _lock.run(id, () async {
      final old = await _secure.read(SecureKeys.cookies(id));
      if (old != null) await _secure.write(SecureKeys.previousCookies(id), old);
      await _secure.write(SecureKeys.cookies(id), cookies.encode());

      final userInfo = await _bootstrap.fetchUserInfo(tokens.accessToken);
      final region = await _bootstrap.fetchRegion(
        tokens.accessToken,
        tokens.idToken,
      );
      final entitlements = await _bootstrap.fetchEntitlementsToken(
        tokens.accessToken,
      );
      final session = RiotSession(
        puuid: id,
        accessToken: tokens.accessToken,
        idToken: tokens.idToken,
        entitlementsToken: entitlements,
        expiresAt: tokens.expiresAt,
        hosts: RiotHosts.forRegion(region),
        clientVersion: _versions.current.riotClientVersion,
        userAgent: _versions.apiUserAgent,
      );
      await _writeTokenCache(session);
      _cache[id] = session;
      _log?.add('login.ok', detail: cookies.has('ssid') ? null : 'no_ssid');
      return LoginEstablished(
        session: session,
        userInfo: userInfo,
        hasSessionCookie: cookies.has('ssid'),
      );
    });
  }

  Future<void> _markNeedsLogin(String id, String reason) async {
    _cache.remove(id);
    await _clearTokenCache(id);
    final before = _accounts.find(id);
    if (before != null && !before.needsLogin) {
      await _accounts.patch(id, (a) => a.copyWith(needsLogin: true));
      _events.add(SessionNeedsLogin(id));
    }
  }

  Future<void> _writeTokenCache(RiotSession s) async {
    await _secure.write(SecureKeys.accessToken(s.puuid), s.accessToken);
    await _secure.write(SecureKeys.idToken(s.puuid), s.idToken);
    await _secure.write(
      SecureKeys.entitlementsToken(s.puuid),
      s.entitlementsToken,
    );
    await _secure.write(
      SecureKeys.tokenExpiry(s.puuid),
      s.expiresAt.millisecondsSinceEpoch.toString(),
    );
  }

  Future<void> _clearTokenCache(String id) async {
    await _secure.delete(SecureKeys.accessToken(id));
    await _secure.delete(SecureKeys.idToken(id));
    await _secure.delete(SecureKeys.entitlementsToken(id));
    await _secure.delete(SecureKeys.tokenExpiry(id));
  }

  Future<RiotSession?> _readTokenCache(String id, Account account) async {
    final access = await _secure.read(SecureKeys.accessToken(id));
    final idToken = await _secure.read(SecureKeys.idToken(id));
    final ent = await _secure.read(SecureKeys.entitlementsToken(id));
    final expiryMs = asInt(await _secure.read(SecureKeys.tokenExpiry(id)));
    if (access == null || idToken == null || ent == null || expiryMs == null) {
      return null;
    }
    if (!supportedRegions.contains(account.region)) return null;
    return RiotSession(
      puuid: id,
      accessToken: access,
      idToken: idToken,
      entitlementsToken: ent,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(expiryMs),
      hosts: account.hosts,
      clientVersion: _versions.current.riotClientVersion,
      userAgent: _versions.apiUserAgent,
    );
  }
}
