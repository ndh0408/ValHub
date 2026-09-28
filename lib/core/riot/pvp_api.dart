import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../auth/session_manager.dart';
import '../config/app_constants.dart';
import '../logging/session_log.dart';
import '../network/dio_factory.dart';
import '../network/error_classifier.dart';
import '../network/rate_limiter.dart';
import '../network/riot_exception.dart';
import '../util/json.dart';
import 'riot_hosts.dart';

/// One method per Riot game-client endpoint in SUMMARY §6.2 (P-*), §6.3 (S-*),
/// §6.4 (G-*), plus the public status JSON (X-1) and the chat bootstrap calls
/// (A-7, A-8).
///
/// Contract:
/// - [puuid] is the signed-in account whose session is used; "Any" endpoints
///   take the target player separately (`subject`).
/// - Results are decoded JSON (`JsonMap` / `List`); typed parsing belongs to
///   the domain / feature layers.
/// - Only [RiotException] subtypes are thrown. `404` = [NotFoundException]
///   (use `.orNullIfNotFound()` for the "not in game" endpoints).
/// - Mutations (PUT/POST/DELETE) are never retried automatically and must
///   only ever be triggered by an explicit user action.
class PvpApi {
  PvpApi({
    required this._sessions,
    required this._dio,
    Dio? publicDio,
    HostRateLimiter? limiter,
    Future<void> Function(Duration)? delay,
  }) : _publicDio = publicDio ?? createBaseDio(),
       _limiter = limiter ?? HostRateLimiter(),
       _delay = delay ?? Future<void>.delayed;

  final SessionManager _sessions;
  final Dio _dio;
  final Dio _publicDio;
  final HostRateLimiter _limiter;
  final Future<void> Function(Duration) _delay;

  // ------------------------------------------------------------------ PD (§6.2)

  /// P-1 `POST /store/v3/storefront/{puuid}` with body `{}` (400 without it).
  Future<JsonMap> storefront(String puuid) => _map(
    puuid,
    'POST',
    (h) => '${h.pd}/store/v3/storefront/$puuid',
    data: const <String, dynamic>{},
    idempotent: true,
  );

  /// P-2 `GET /store/v1/wallet/{puuid}` → `Balances{currencyId: n}`.
  Future<JsonMap> wallet(String puuid) =>
      _map(puuid, 'GET', (h) => '${h.pd}/store/v1/wallet/$puuid');

  /// P-3 `GET /store/v1/entitlements/{puuid}/{itemTypeId}` (one type per call).
  Future<JsonMap> entitlements(String puuid, String itemTypeId) => _map(
    puuid,
    'GET',
    (h) => '${h.pd}/store/v1/entitlements/$puuid/${itemTypeId.toLowerCase()}',
  );

  /// P-4 `GET /store/v1/entitlements/{puuid}` (all types; optional).
  Future<JsonMap> allEntitlements(String puuid) =>
      _map(puuid, 'GET', (h) => '${h.pd}/store/v1/entitlements/$puuid');

  /// P-5 `GET /store/v1/offers/` (global price list; UNVERIFIED in 2026).
  Future<JsonMap> offers(String puuid) =>
      _map(puuid, 'GET', (h) => '${h.pd}/store/v1/offers/');

  /// P-6 `GET /favorites/v1/players/{puuid}/favorites`.
  Future<JsonMap> favorites(String puuid) => _map(
    puuid,
    'GET',
    (h) => '${h.pd}/favorites/v1/players/$puuid/favorites',
  );

  /// P-7 `GET /contract-definitions/v3/item-upgrades` (RP costs).
  Future<JsonMap> itemUpgrades(String puuid) => _map(
    puuid,
    'GET',
    (h) => '${h.pd}/contract-definitions/v3/item-upgrades',
  );

  /// P-8 `GET /personalization/v3/players/{puuid}/playerloadout`.
  Future<JsonMap> playerLoadout(String puuid) => _map(
    puuid,
    'GET',
    (h) => '${h.pd}/personalization/v3/players/$puuid/playerloadout',
  );

  /// P-8 `PUT /personalization/v3/players/{puuid}/playerloadout`.
  ///
  /// [loadout] must be the WHOLE raw object from a fresh [playerLoadout],
  /// mutated in place (unknown keys round-tripped). Returns the new loadout.
  Future<JsonMap> putPlayerLoadout(String puuid, JsonMap loadout) => _map(
    puuid,
    'PUT',
    (h) => '${h.pd}/personalization/v3/players/$puuid/playerloadout',
    data: loadout,
  );

  /// P-9 `GET /account-xp/v1/players/{puuid}` → `Progress.{Level,XP}`.
  Future<JsonMap> accountXp(String puuid) =>
      _map(puuid, 'GET', (h) => '${h.pd}/account-xp/v1/players/$puuid');

  /// P-10 `PUT /name-service/v2/players` body `["puuid", …]` →
  /// `[{Subject, GameName, TagLine, DisplayName}]`. Batched by 50.
  Future<List<JsonMap>> names(String puuid, Iterable<String> subjects) async {
    final unique = {for (final s in subjects) s.toLowerCase()}.toList();
    final out = <JsonMap>[];
    for (
      var i = 0;
      i < unique.length;
      i += RiotClientConstants.nameServiceBatch
    ) {
      final end = (i + RiotClientConstants.nameServiceBatch).clamp(
        0,
        unique.length,
      );
      final data = await _send(
        puuid,
        'PUT',
        (h) => '${h.pd}/name-service/v2/players',
        data: unique.sublist(i, end),
        idempotent: true,
      );
      out.addAll(asMapList(data));
    }
    return out;
  }

  /// P-11 `GET /mmr/v1/players/{subject}` (any player; default: self).
  Future<JsonMap> mmr(String puuid, {String? subject}) =>
      _map(puuid, 'GET', (h) => '${h.pd}/mmr/v1/players/${subject ?? puuid}');

  /// P-12 `GET /mmr/v1/players/{subject}/competitiveupdates` (page ≤ 20).
  Future<JsonMap> competitiveUpdates(
    String puuid, {
    String? subject,
    int startIndex = 0,
    int endIndex = RiotClientConstants.maxPageSize,
    String queue = 'competitive',
  }) {
    final (start, end) = _page(startIndex, endIndex);
    return _map(
      puuid,
      'GET',
      (h) => '${h.pd}/mmr/v1/players/${subject ?? puuid}/competitiveupdates',
      query: {'startIndex': start, 'endIndex': end, 'queue': queue},
    );
  }

  /// P-13 `GET /match-history/v1/history/{subject}` (page ≤ 20; optional
  /// server-side queue filter).
  Future<JsonMap> matchHistory(
    String puuid, {
    String? subject,
    int startIndex = 0,
    int endIndex = RiotClientConstants.maxPageSize,
    String? queue,
  }) {
    final (start, end) = _page(startIndex, endIndex);
    return _map(
      puuid,
      'GET',
      (h) => '${h.pd}/match-history/v1/history/${subject ?? puuid}',
      query: {'startIndex': start, 'endIndex': end, 'queue': ?queue},
    );
  }

  /// P-14 `GET /match-details/v1/matches/{matchId}` (immutable; cache
  /// forever; 404 right after a match = not processed yet).
  Future<JsonMap> matchDetails(String puuid, String matchId) =>
      _map(puuid, 'GET', (h) => '${h.pd}/match-details/v1/matches/$matchId');

  /// P-15 `GET /contracts/v1/contracts/{puuid}`.
  Future<JsonMap> contracts(String puuid) =>
      _map(puuid, 'GET', (h) => '${h.pd}/contracts/v1/contracts/$puuid');

  /// P-16 `GET /daily-ticket/v1/{puuid}`.
  Future<JsonMap> dailyTicket(String puuid) =>
      _map(puuid, 'GET', (h) => '${h.pd}/daily-ticket/v1/$puuid');

  /// P-16 `POST /daily-ticket/v1/{puuid}/renew` with `{}`. Only when the GET
  /// returned 404 or `RemainingLifetimeSeconds <= 0`, at most once a day.
  Future<JsonMap> renewDailyTicket(String puuid) => _map(
    puuid,
    'POST',
    (h) => '${h.pd}/daily-ticket/v1/$puuid/renew',
    data: const <String, dynamic>{},
  );

  /// P-17 `GET /restrictions/v3/penalties` (token identifies the player).
  Future<JsonMap> penalties(String puuid) =>
      _map(puuid, 'GET', (h) => '${h.pd}/restrictions/v3/penalties');

  // -------------------------------------------------------------- shared (§6.3)

  /// S-1 `GET /content-service/v3/content` → `Seasons[]`, `Events[]`.
  Future<JsonMap> content(String puuid) =>
      _map(puuid, 'GET', (h) => '${h.shared}/content-service/v3/content');

  /// S-2 `GET /v1/config/{region}` → `Collapsed{…}`.
  Future<JsonMap> config(String puuid) =>
      _map(puuid, 'GET', (h) => '${h.shared}/v1/config/${h.region}');

  // ----------------------------------------------------------------- GLZ (§6.4)

  /// G-1 `GET /session/v1/sessions/{puuid}` (404 = game not running).
  Future<JsonMap> gameSession(String puuid) =>
      _map(puuid, 'GET', (h) => '${h.glz}/session/v1/sessions/$puuid');

  /// G-2 `GET /pregame/v1/players/{puuid}` → `{MatchID}` (404 = no).
  Future<JsonMap> pregamePlayer(String puuid) =>
      _map(puuid, 'GET', (h) => '${h.glz}/pregame/v1/players/$puuid');

  /// G-3 `GET /pregame/v1/matches/{matchId}`.
  Future<JsonMap> pregameMatch(String puuid, String matchId) =>
      _map(puuid, 'GET', (h) => '${h.glz}/pregame/v1/matches/$matchId');

  /// G-4 `POST /pregame/v1/matches/{matchId}/select/{agentId}` (hover).
  Future<JsonMap> pregameSelectAgent(
    String puuid,
    String matchId,
    String agentId,
  ) => _map(
    puuid,
    'POST',
    (h) => '${h.glz}/pregame/v1/matches/$matchId/select/$agentId',
  );

  /// G-5 `POST /pregame/v1/matches/{matchId}/lock/{agentId}` (lock; owned
  /// agents only; user hold gesture only).
  Future<JsonMap> pregameLockAgent(
    String puuid,
    String matchId,
    String agentId,
  ) => _map(
    puuid,
    'POST',
    (h) => '${h.glz}/pregame/v1/matches/$matchId/lock/$agentId',
  );

  /// G-6 `POST /pregame/v1/matches/{matchId}/quit` — DODGE, PENALTY.
  /// Confirm with the user first.
  Future<JsonMap> pregameQuit(String puuid, String matchId) =>
      _map(puuid, 'POST', (h) => '${h.glz}/pregame/v1/matches/$matchId/quit');

  /// G-7 `GET /pregame/v1/matches/{matchId}/loadouts`.
  Future<JsonMap> pregameLoadouts(String puuid, String matchId) => _map(
    puuid,
    'GET',
    (h) => '${h.glz}/pregame/v1/matches/$matchId/loadouts',
  );

  /// G-8 `GET /core-game/v1/players/{puuid}` → `{MatchID}` (404 = no).
  Future<JsonMap> coreGamePlayer(String puuid) =>
      _map(puuid, 'GET', (h) => '${h.glz}/core-game/v1/players/$puuid');

  /// G-9 `GET /core-game/v1/matches/{matchId}`.
  Future<JsonMap> coreGameMatch(String puuid, String matchId) =>
      _map(puuid, 'GET', (h) => '${h.glz}/core-game/v1/matches/$matchId');

  /// G-10 `GET /core-game/v1/matches/{matchId}/loadouts`.
  Future<JsonMap> coreGameLoadouts(String puuid, String matchId) => _map(
    puuid,
    'GET',
    (h) => '${h.glz}/core-game/v1/matches/$matchId/loadouts',
  );

  /// G-11 `POST /core-game/v1/players/{puuid}/disassociate/{matchId}` —
  /// LEAVE A RUNNING MATCH, PENALTY. Confirm with the user first.
  Future<JsonMap> coreGameDisassociate(String puuid, String matchId) => _map(
    puuid,
    'POST',
    (h) => '${h.glz}/core-game/v1/players/$puuid/disassociate/$matchId',
  );

  /// G-12 `GET /parties/v1/players/{puuid}` → `CurrentPartyID`, `Invites`…
  Future<JsonMap> partyPlayer(String puuid) =>
      _map(puuid, 'GET', (h) => '${h.glz}/parties/v1/players/$puuid');

  /// G-13 `GET /parties/v1/parties/{partyId}`.
  Future<JsonMap> party(String puuid, String partyId) =>
      _map(puuid, 'GET', (h) => '${h.glz}/parties/v1/parties/$partyId');

  /// G-14 `POST /parties/v1/parties/{partyId}/queue` body `{"queueId":…}`.
  Future<JsonMap> partyChangeQueue(
    String puuid,
    String partyId,
    String queueId,
  ) => _map(
    puuid,
    'POST',
    (h) => '${h.glz}/parties/v1/parties/$partyId/queue',
    data: {'queueId': queueId},
  );

  /// G-15 `POST /parties/v1/parties/{partyId}/matchmaking/join`.
  Future<JsonMap> partyJoinMatchmaking(String puuid, String partyId) => _map(
    puuid,
    'POST',
    (h) => '${h.glz}/parties/v1/parties/$partyId/matchmaking/join',
  );

  /// G-15 `POST /parties/v1/parties/{partyId}/matchmaking/leave`.
  Future<JsonMap> partyLeaveMatchmaking(String puuid, String partyId) => _map(
    puuid,
    'POST',
    (h) => '${h.glz}/parties/v1/parties/$partyId/matchmaking/leave',
  );

  /// G-16 `POST /parties/v1/parties/{partyId}/members/{puuid}/setReady`.
  Future<JsonMap> partySetReady(
    String puuid,
    String partyId, {
    required bool ready,
  }) => _map(
    puuid,
    'POST',
    (h) => '${h.glz}/parties/v1/parties/$partyId/members/$puuid/setReady',
    data: {'ready': ready},
  );

  /// G-17 `POST /parties/v1/parties/{partyId}/invites/name/{gameName}/tag/{tagLine}`.
  Future<JsonMap> partyInviteByRiotId(
    String puuid,
    String partyId, {
    required String gameName,
    required String tagLine,
  }) => _map(
    puuid,
    'POST',
    (h) =>
        '${h.glz}/parties/v1/parties/$partyId/invites/name/'
        '${Uri.encodeComponent(gameName)}/tag/${Uri.encodeComponent(tagLine)}',
  );

  /// G-18 `POST /parties/v1/parties/{partyId}/invitecode` (generate).
  Future<JsonMap> partyGenerateInviteCode(String puuid, String partyId) => _map(
    puuid,
    'POST',
    (h) => '${h.glz}/parties/v1/parties/$partyId/invitecode',
  );

  /// G-18 `DELETE /parties/v1/parties/{partyId}/invitecode` (disable).
  Future<JsonMap> partyDisableInviteCode(String puuid, String partyId) => _map(
    puuid,
    'DELETE',
    (h) => '${h.glz}/parties/v1/parties/$partyId/invitecode',
  );

  /// G-19 `POST /parties/v1/players/joinbycode/{code}`.
  Future<JsonMap> partyJoinByCode(String puuid, String code) => _map(
    puuid,
    'POST',
    (h) =>
        '${h.glz}/parties/v1/players/joinbycode/${Uri.encodeComponent(code)}',
  );

  /// G-20 `POST /parties/v1/players/{puuid}/joinparty/{partyId}` (accept an
  /// invite; UNVERIFIED — behind flag `party_accept_invite`).
  Future<JsonMap> partyAcceptInvite(String puuid, String partyId) => _map(
    puuid,
    'POST',
    (h) => '${h.glz}/parties/v1/players/$puuid/joinparty/$partyId',
  );

  /// G-21 `POST /parties/v1/parties/{partyId}/request/{requestId}/decline`.
  Future<JsonMap> partyDeclineRequest(
    String puuid,
    String partyId,
    String requestId,
  ) => _map(
    puuid,
    'POST',
    (h) => '${h.glz}/parties/v1/parties/$partyId/request/$requestId/decline',
  );

  /// G-22 `DELETE /parties/v1/players/{subject}`: leave (own PUUID, default)
  /// or kick another member (owner only).
  Future<JsonMap> partyRemovePlayer(String puuid, {String? subject}) => _map(
    puuid,
    'DELETE',
    (h) => '${h.glz}/parties/v1/players/${subject ?? puuid}',
  );

  /// G-23 `POST /parties/v1/parties/{partyId}/accessibility`.
  Future<JsonMap> partySetAccessibility(
    String puuid,
    String partyId, {
    required bool open,
  }) => _map(
    puuid,
    'POST',
    (h) => '${h.glz}/parties/v1/parties/$partyId/accessibility',
    data: {'accessibility': open ? 'OPEN' : 'CLOSED'},
  );

  /// G-24 `POST /parties/v1/parties/{partyId}/members/{puuid}/refreshCompetitiveTier`.
  Future<JsonMap> partyRefreshCompetitiveTier(
    String puuid,
    String partyId,
  ) => _map(
    puuid,
    'POST',
    (h) =>
        '${h.glz}/parties/v1/parties/$partyId/members/$puuid/refreshCompetitiveTier',
  );

  // --------------------------------------------------------- chat bootstrap (A-7/8)

  /// A-7 `GET riot-geo…/pas/v1/service/chat` → raw PAS JWT (`affinity` claim).
  Future<String> chatPasToken(String puuid) async {
    final data = await _send(
      puuid,
      'GET',
      (_) => AuthConstants.pasChatUrl,
      responseType: ResponseType.plain,
    );
    final token = asNonEmptyString(data);
    if (token == null) throw const TransientException(reason: 'no_pas_token');
    return token.replaceAll('"', '');
  }

  /// A-8 `GET clientconfig…/api/v1/config/player?app=Riot%20Client` →
  /// `chat.affinities`, `chat.affinity_domains`, `chat.port`.
  Future<JsonMap> chatClientConfig(String puuid) =>
      _map(puuid, 'GET', (_) => AuthConstants.clientConfigUrl);

  // ------------------------------------------------------------- public (X-1)

  /// X-1 public status JSON for [region] (no auth): `{maintenances[],
  /// incidents[]}`. Some regions answer 403 (→ [TransientException]).
  Future<JsonMap> platformStatus(String region) async {
    final url = AppConstants.statusUrlTemplate.replaceAll(
      '{region}',
      region.toLowerCase(),
    );
    try {
      final res = await _publicDio.get<Object?>(url);
      return asMap(res.data) ?? asMap(tryDecodeJson(asString(res.data))) ?? {};
    } on Object catch (e) {
      throw classifyError(e);
    }
  }

  // ------------------------------------------------------------------ plumbing

  static (int, int) _page(int start, int end) {
    final s = start < 0 ? 0 : start;
    var e = end <= s ? s + RiotClientConstants.maxPageSize : end;
    if (e - s > RiotClientConstants.maxPageSize) {
      e = s + RiotClientConstants.maxPageSize;
    }
    return (s, e);
  }

  Future<JsonMap> _map(
    String puuid,
    String method,
    String Function(RiotHosts hosts) url, {
    Object? data,
    Map<String, dynamic>? query,
    bool? idempotent,
  }) async {
    final body = await _send(
      puuid,
      method,
      url,
      data: data,
      query: query,
      idempotent: idempotent,
    );
    if (body == null) return <String, dynamic>{};
    if (body is String) {
      if (body.trim().isEmpty) return <String, dynamic>{};
      final decoded = asMap(tryDecodeJson(body));
      if (decoded == null) throw const TransientException(reason: 'non_json');
      return decoded;
    }
    return asMap(body) ?? <String, dynamic>{'data': body};
  }

  Future<Object?> _send(
    String puuid,
    String method,
    String Function(RiotHosts hosts) url, {
    Object? data,
    Map<String, dynamic>? query,
    bool? idempotent,
    ResponseType? responseType,
  }) async {
    final id = puuid.toLowerCase();
    final RiotHosts hosts;
    try {
      hosts = (await _sessions.session(id)).hosts;
    } on Object catch (e) {
      throw classifyError(e);
    }
    final uri = Uri.parse(url(hosts));
    final canRetry = idempotent ?? method == 'GET';
    for (var attempt = 0; ; attempt++) {
      await _limiter.acquire(uri.host);
      try {
        final res = await _dio.requestUri<Object?>(
          query == null || query.isEmpty
              ? uri
              : uri.replace(
                  queryParameters: {
                    ...uri.queryParameters,
                    for (final e in query.entries) e.key: '${e.value}',
                  },
                ),
          data: data,
          options: Options(
            method: method,
            responseType: responseType,
            contentType: data == null ? null : Headers.jsonContentType,
            extra: {RequestExtras.puuid: id},
          ),
        );
        return res.data;
      } on Object catch (e) {
        var error = classifyError(e);
        if (error is NeedsLoginException && error.puuid == null) {
          error = NeedsLoginException(puuid: id, reason: error.reason);
        }
        if (error is TransientException && error.status == 429) {
          _limiter.cooldown(
            uri.host,
            error.retryAfter ?? const Duration(seconds: 10),
          );
        }
        final wait = _inlineRetryDelay(error, attempt);
        if (!canRetry || wait == null) throw error;
        await _delay(wait);
      } finally {
        _limiter.release(uri.host);
      }
    }
  }

  /// At most 2 quick retries for transient failures of idempotent calls;
  /// longer waits are left to the caller (Riverpod `retry`).
  static Duration? _inlineRetryDelay(RiotException error, int attempt) {
    if (error is! TransientException || attempt >= 2) return null;
    if (error.reason == 'cancelled') return null;
    final retryAfter = error.retryAfter;
    if (retryAfter != null) {
      return retryAfter <= const Duration(seconds: 10) ? retryAfter : null;
    }
    return Duration(seconds: attempt == 0 ? 1 : 3);
  }
}

/// App-wide [PvpApi].
final pvpApiProvider = Provider<PvpApi>((ref) {
  final sessions = ref.watch(sessionManagerProvider);
  final log = ref.watch(sessionLogProvider);
  return PvpApi(
    sessions: sessions,
    dio: createPvpDio(sessions: sessions, log: log),
    publicDio: createBaseDio(log: log),
  );
});
