import 'dart:async';
import 'dart:convert';

import '../../../core/accounts/account.dart';
import '../../../core/auth/session_manager.dart';
import '../../../core/storage/secure_store.dart';
import '../../../core/util/json.dart';
import 'community_exception.dart';
import 'community_http.dart';
import 'community_models.dart';

/// Community sessions, one per signed-in account (docs/community-api.md
/// "Privacy and identity").
///
/// On first use the account's Riot **access token** (from [SessionManager])
/// is sent once to `POST /v1/auth/riot`; the server verifies it with Riot and
/// returns its own session token, kept in secure storage under
/// `SecureKeys.community(puuid)` (wiped with the account). Tokens are never
/// logged; [CommunitySession.toString] omits them.
class CommunityAuth {
  CommunityAuth({
    required this._http,
    required this._store,
    required this._sessions,
    required this._account,
    required this._now,
  });

  final CommunityHttp _http;
  final SecureStore _store;
  final SessionManager _sessions;
  final Account? Function(String puuid) _account;
  final DateTime Function() _now;

  final Map<String, CommunitySession> _memory = {};
  final Map<String, Future<CommunitySession>> _inFlight = {};

  /// A valid community token for [puuid]. With [signIn] false only a cached
  /// token is returned (`null` when there is none), so read-only screens can
  /// call the "auth optional" endpoints without talking to Riot.
  Future<String?> token(String puuid, {bool signIn = true}) async {
    final cached = await cachedSession(puuid);
    if (cached != null) return cached.token;
    if (!signIn) return null;
    return (await session(puuid)).token;
  }

  /// The cached, unexpired session of [puuid] (memory, then secure store).
  Future<CommunitySession?> cachedSession(String puuid) async {
    final id = puuid.toLowerCase();
    final now = _now();
    final inMemory = _memory[id];
    if (inMemory != null && !inMemory.isExpired(now)) return inMemory;
    try {
      final raw = await _store.read(SecureKeys.community(id));
      final stored = CommunitySession.fromJson(tryDecodeJson(raw));
      if (stored != null && !stored.isExpired(now)) {
        return _memory[id] = stored;
      }
    } on Object {
      // Keychain unavailable: sign in again.
    }
    return null;
  }

  /// A valid session, signing in with the Riot access token when needed.
  /// Concurrent callers share one sign-in.
  Future<CommunitySession> session(String puuid) async {
    final id = puuid.toLowerCase();
    final cached = await cachedSession(id);
    if (cached != null) return cached;
    final running = _inFlight[id];
    if (running != null) return running;
    final future = _signIn(id);
    _inFlight[id] = future;
    try {
      return await future;
    } finally {
      if (identical(_inFlight[id], future)) unawaited(_inFlight.remove(id));
    }
  }

  /// The server rejected [failedToken] (401): forget it so the next call
  /// signs in again. A newer token is kept.
  Future<void> invalidate(String puuid, String failedToken) async {
    final id = puuid.toLowerCase();
    final current = _memory[id];
    if (current != null && current.token != failedToken) return;
    _memory.remove(id);
    try {
      final stored = CommunitySession.fromJson(
        tryDecodeJson(await _store.read(SecureKeys.community(id))),
      );
      if (stored == null || stored.token == failedToken) {
        await _store.delete(SecureKeys.community(id));
      }
    } on Object {
      // Best effort.
    }
  }

  Future<CommunitySession> _signIn(String puuid) async {
    final account = _account(puuid);
    var riot = await _sessions.session(puuid);
    Future<Object?> post(String accessToken) => _http.send(
      'POST',
      '/v1/auth/riot',
      json: {
        'accessToken': accessToken,
        'region': communityRegion(account?.region ?? riot.region),
        'cardId': ?account?.cardId,
        'rankTier': ?account?.rankTier,
      },
    );
    Object? body;
    try {
      body = await post(riot.accessToken);
    } on CommunityException catch (e) {
      if (e.code != CommunityException.riotRejected) rethrow;
      // Riot refused a token that looked valid: refresh it once.
      riot = await _sessions.refreshAfterAuthFailure(
        puuid,
        failedAccessToken: riot.accessToken,
      );
      body = await post(riot.accessToken);
    }
    final session = CommunitySession.fromJson(body);
    if (session == null) {
      throw const CommunityException(CommunityException.badResponse);
    }
    _memory[puuid] = session;
    try {
      await _store.write(
        SecureKeys.community(puuid),
        jsonEncode(session.toJson()),
      );
    } on Object {
      // Kept in memory for this run.
    }
    return session;
  }
}
