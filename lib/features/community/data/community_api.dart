import 'dart:typed_data';

import '../../../core/util/json.dart';
import 'community_auth.dart';
import 'community_exception.dart';
import 'community_http.dart';
import 'community_models.dart';

/// How a request authenticates.
enum _Auth {
  /// Bearer token required: signs in on first use.
  required,

  /// Token sent when one is cached (or [CommunityApi] may sign in).
  optional,
}

/// Every endpoint of docs/community-api.md. Methods that act as a user take
/// the signed-in account's [puuid] (whose community session is used); a
/// `401` triggers one re-sign-in and a single retry.
///
/// Throws [CommunityException] (server / transport) or a Riot exception when
/// the Riot session needed to sign in is unavailable (e.g. needs login).
class CommunityApi {
  CommunityApi({required this._http, required this._auth});

  final CommunityHttp _http;
  final CommunityAuth _auth;

  bool get isEnabled => _http.isEnabled;

  CommunityAuth get auth => _auth;

  // ------------------------------------------------------------- profile

  /// `GET /v1/me`.
  Future<CommunityAuthor> me(String puuid) async =>
      CommunityAuthor.fromJson(await _send('GET', '/v1/me', puuid: puuid)) ??
      (throw const CommunityException(CommunityException.badResponse));

  /// `PATCH /v1/me`.
  Future<CommunityAuthor> updateMe(
    String puuid, {
    String? cardId,
    int? rankTier,
    String? region,
    String? language,
  }) async =>
      CommunityAuthor.fromJson(
        await _send(
          'PATCH',
          '/v1/me',
          puuid: puuid,
          json: {
            'cardId': ?cardId,
            'rankTier': ?rankTier,
            'region': ?region,
            'language': ?language,
          },
        ),
      ) ??
      (throw const CommunityException(CommunityException.badResponse));

  // ----------------------------------------------------------------- LFG

  /// `GET /v1/lfg` (open posts, newest first). [rank] keeps posts whose
  /// range contains it (or that have none).
  Future<CommunityPage<LfgPost>> lfg(
    String puuid, {
    required String region,
    String? mode,
    int? rank,
    String? role,
    bool? mic,
    String? language,
    String? cursor,
    int limit = 20,
  }) async => CommunityPage.fromJson(
    await _send(
      'GET',
      '/v1/lfg',
      puuid: puuid,
      query: {
        'scope': CommunityScope.region.name,
        'region': region,
        'mode': mode,
        'rank': rank,
        'role': role,
        'mic': mic,
        'language': language,
        'cursor': cursor,
        'limit': limit.clamp(1, 50),
      },
    ),
    LfgPost.fromJson,
  );

  /// `GET /v1/lfg/mine` (the user's own post, whatever its status).
  Future<LfgPost?> myLfg(String puuid) async =>
      LfgPost.fromJson(await _send('GET', '/v1/lfg/mine', puuid: puuid));

  /// `POST /v1/lfg` (replaces the user's previous post).
  Future<LfgPost> createLfg(
    String puuid, {
    required String region,
    required String mode,
    required String partyCode,
    required int slots,
    int? rankTier,
    String? note,
    int? rankMin,
    int? rankMax,
    List<String> roles = const [],
    bool? mic,
    String? language,
    int? partySize,
    List<String> agents = const [],
  }) async =>
      LfgPost.fromJson(
        await _send(
          'POST',
          '/v1/lfg',
          puuid: puuid,
          json: {
            'region': region,
            'mode': mode,
            'partyCode': partyCode.trim().toUpperCase(),
            'slots': slots.clamp(1, 4),
            'rankTier': ?rankTier,
            if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
            'rankMin': ?rankMin,
            'rankMax': ?rankMax,
            if (roles.isNotEmpty) 'roles': roles.toSet().take(4).toList(),
            'mic': ?mic,
            'language': ?language,
            'partySize': ?partySize,
            if (agents.isNotEmpty) 'agents': agents.take(5).toList(),
          },
        ),
      ) ??
      (throw const CommunityException(CommunityException.badResponse));

  /// `PATCH /v1/lfg/{id}` (own post; also the "still active" heartbeat).
  Future<LfgPost> updateLfg(
    String puuid,
    String id, {
    int? partySize,
    int? slots,
    String? note,
    LfgStatus? status,
  }) async =>
      LfgPost.fromJson(
        await _send(
          'PATCH',
          '/v1/lfg/${Uri.encodeComponent(id)}',
          puuid: puuid,
          json: {
            'partySize': ?partySize,
            'slots': ?slots,
            'note': ?note,
            'status': ?status?.query,
          },
        ),
      ) ??
      (throw const CommunityException(CommunityException.badResponse));

  /// `POST /v1/lfg/{id}/join` after a successful Riot join. Returns the
  /// join count.
  Future<int> recordLfgJoin(String puuid, String id) async =>
      asInt(
        asMap(
          await _send(
            'POST',
            '/v1/lfg/${Uri.encodeComponent(id)}/join',
            puuid: puuid,
            json: const <String, Object?>{},
          ),
        )?['joins'],
      ) ??
      0;

  /// `DELETE /v1/lfg/{id}` (own post).
  Future<void> deleteLfg(String puuid, String id) =>
      _send('DELETE', '/v1/lfg/${Uri.encodeComponent(id)}', puuid: puuid);

  // ----------------------------------------------------------- skin votes

  /// `PUT /v1/skins/{skinUuid}/vote`.
  Future<SkinVote> vote(
    String puuid,
    String skinUuid, {
    String? weaponUuid,
  }) async => _vote(
    skinUuid,
    await _send(
      'PUT',
      '/v1/skins/${Uri.encodeComponent(skinUuid)}/vote',
      puuid: puuid,
      json: {'weaponUuid': ?weaponUuid},
    ),
    voted: true,
  );

  /// `DELETE /v1/skins/{skinUuid}/vote`.
  Future<SkinVote> unvote(String puuid, String skinUuid) async => _vote(
    skinUuid,
    await _send(
      'DELETE',
      '/v1/skins/${Uri.encodeComponent(skinUuid)}/vote',
      puuid: puuid,
    ),
    voted: false,
  );

  SkinVote _vote(String skinUuid, Object? body, {required bool voted}) {
    final m = asMap(body);
    return SkinVote(
      skinUuid: lowerUuid(m?['skinUuid']) ?? skinUuid.toLowerCase(),
      votes: (asNum(m?['votes'])?.round() ?? 0).clamp(0, 1 << 31),
      voted: asBool(m?['voted']) ?? voted,
    );
  }

  /// `GET /v1/skins/top` (auth optional: `voted` needs a session). With
  /// [signIn] false only a cached session is used.
  Future<List<TopSkin>> topSkins({
    String? puuid,
    String? weapon,
    TopPeriod period = TopPeriod.all,
    TopSort sort = TopSort.votes,
    ScopeFilter? scope,
    int limit = 50,
    bool signIn = true,
  }) async {
    final body = await _send(
      'GET',
      '/v1/skins/top',
      puuid: puuid,
      auth: _Auth.optional,
      signIn: signIn,
      query: {
        ...?scope?.query,
        'weapon': weapon,
        'period': period.query,
        'sort': sort.query,
        'limit': limit.clamp(1, 100),
      },
    );
    final items = asList(asMap(body)?['items'] ?? body);
    final out = <TopSkin>[];
    final seen = <String>{};
    for (var i = 0; i < items.length; i++) {
      final row = TopSkin.fromJson(items[i], i);
      if (row != null && seen.add(row.skinUuid)) out.add(row);
    }
    out.sort((a, b) => a.rank.compareTo(b.rank));
    return out;
  }

  /// `GET /v1/skins/votes?ids=…` (≤ 50 ids; auth optional): votes and
  /// rating of each skin.
  Future<Map<String, SkinStats>> skinVotes(
    Iterable<String> ids, {
    String? puuid,
    bool signIn = false,
  }) async {
    final list = {for (final id in ids) id.toLowerCase()}.take(50).toList();
    if (list.isEmpty) return const {};
    final body = await _send(
      'GET',
      '/v1/skins/votes',
      puuid: puuid,
      auth: _Auth.optional,
      signIn: signIn,
      query: {'ids': list.join(',')},
    );
    final stats = [
      for (final e in asList(asMap(body)?['items'] ?? body))
        ?SkinStats.fromJson(e),
    ];
    return {for (final s in stats) s.skinUuid: s};
  }

  // --------------------------------------------------------- skin reviews

  String _skinPath(String skinUuid, String rest) =>
      '/v1/skins/${Uri.encodeComponent(skinUuid.toLowerCase())}/$rest';

  /// `GET /v1/skins/{uuid}/summary` (auth optional; `myReview` / `voted`
  /// need a session).
  Future<SkinSummary> skinSummary(
    String skinUuid, {
    String? puuid,
    ScopeFilter? scope,
    bool signIn = true,
  }) async => SkinSummary.fromJson(
    await _send(
      'GET',
      _skinPath(skinUuid, 'summary'),
      puuid: puuid,
      auth: _Auth.optional,
      signIn: signIn,
      query: scope?.query,
    ),
    skinUuid,
  );

  /// `GET /v1/skins/{uuid}/reviews` (auth optional).
  Future<CommunityPage<SkinReview>> skinReviews(
    String skinUuid, {
    String? puuid,
    ReviewSort sort = ReviewSort.newest,
    ScopeFilter? scope,
    String? cursor,
    int limit = 20,
    bool signIn = true,
  }) async => CommunityPage.fromJson(
    await _send(
      'GET',
      _skinPath(skinUuid, 'reviews'),
      puuid: puuid,
      auth: _Auth.optional,
      signIn: signIn,
      query: {
        ...?scope?.query,
        'sort': sort.query,
        'cursor': cursor,
        'limit': limit.clamp(1, 50),
      },
    ),
    SkinReview.fromJson,
  );

  /// `PUT /v1/skins/{uuid}/review` (create or replace the own review).
  Future<SkinReview> putReview(
    String puuid,
    String skinUuid, {
    required int rating,
    String? weaponUuid,
    String body = '',
    String? language,
  }) async =>
      SkinReview.fromJson(
        await _send(
          'PUT',
          _skinPath(skinUuid, 'review'),
          puuid: puuid,
          json: {
            'weaponUuid': ?weaponUuid,
            'rating': rating.clamp(1, 5),
            if (body.trim().isNotEmpty) 'body': body.trim(),
            if (body.trim().isNotEmpty) 'language': ?language,
          },
        ),
      ) ??
      (throw const CommunityException(CommunityException.badResponse));

  /// `DELETE /v1/skins/{uuid}/review` (the own review of that skin).
  Future<void> deleteMyReview(String puuid, String skinUuid) =>
      _send('DELETE', _skinPath(skinUuid, 'review'), puuid: puuid);

  /// `PUT` / `DELETE /v1/reviews/{id}/like` ("Hữu ích"; not own).
  Future<LikeResult> setReviewLiked(
    String puuid,
    String id, {
    required bool liked,
  }) async {
    final m = asMap(
      await _send(
        liked ? 'PUT' : 'DELETE',
        '/v1/reviews/${Uri.encodeComponent(id)}/like',
        puuid: puuid,
      ),
    );
    return (
      likes: (asNum(m?['likes'])?.round() ?? 0).clamp(0, 1 << 31),
      liked: asBool(m?['liked']) ?? liked,
    );
  }

  /// `DELETE /v1/reviews/{id}` (own review).
  Future<void> deleteReview(String puuid, String id) =>
      _send('DELETE', '/v1/reviews/${Uri.encodeComponent(id)}', puuid: puuid);
  // ------------------------------------------------------------ scopes

  /// `GET /v1/communities` (countries with activity this week, most
  /// posts first; auth optional).
  Future<List<CountryCommunity>> communities({
    String? puuid,
    bool signIn = false,
  }) async {
    final body = await _send(
      'GET',
      '/v1/communities',
      puuid: puuid,
      auth: _Auth.optional,
      signIn: signIn,
      query: {'period': 'week'},
    );
    final seen = <String>{};
    return [
      for (final e in asList(asMap(body)?['items'] ?? body))
        if (CountryCommunity.fromJson(e) case final c? when seen.add(c.country))
          c,
    ];
  }

  // ----------------------------------------------------------------- feed

  /// `GET /v1/posts` (newest first).
  Future<CommunityPage<CommunityPost>> posts(
    String? puuid, {
    PostKind? kind,
    ScopeFilter? scope,
    String? cursor,
    int limit = 20,
  }) async => CommunityPage.fromJson(
    await _send(
      'GET',
      '/v1/posts',
      puuid: puuid,
      auth: _Auth.optional,
      query: {
        ...?scope?.query,
        'kind': kind?.name,
        'cursor': cursor,
        'limit': limit.clamp(1, 50),
      },
    ),
    CommunityPost.fromJson,
  );

  /// `GET /v1/posts/{id}`.
  Future<CommunityPost> post(String? puuid, String id) async =>
      CommunityPost.fromJson(
        await _send(
          'GET',
          '/v1/posts/${Uri.encodeComponent(id)}',
          puuid: puuid,
          auth: _Auth.optional,
        ),
      ) ??
      (throw const CommunityException(CommunityException.notFound));

  /// `POST /v1/posts`.
  Future<CommunityPost> createPost(
    String puuid, {
    required PostKind kind,
    String body = '',
    List<String> media = const [],
    PostPayload? payload,
    String? language,
  }) async =>
      CommunityPost.fromJson(
        await _send(
          'POST',
          '/v1/posts',
          puuid: puuid,
          json: {
            'kind': kind.name,
            'body': body.trim(),
            'language': ?language,
            if (media.isNotEmpty) 'media': media.take(4).toList(),
            if (kind.hasOffers) 'payload': ?payload?.toJson(kind),
          },
        ),
      ) ??
      (throw const CommunityException(CommunityException.badResponse));

  /// `DELETE /v1/posts/{id}` (own post).
  Future<void> deletePost(String puuid, String id) =>
      _send('DELETE', '/v1/posts/${Uri.encodeComponent(id)}', puuid: puuid);

  /// `PUT` / `DELETE /v1/posts/{id}/like`.
  Future<LikeResult> setLiked(
    String puuid,
    String id, {
    required bool liked,
  }) async {
    final m = asMap(
      await _send(
        liked ? 'PUT' : 'DELETE',
        '/v1/posts/${Uri.encodeComponent(id)}/like',
        puuid: puuid,
      ),
    );
    return (
      likes: (asNum(m?['likes'])?.round() ?? 0).clamp(0, 1 << 31),
      liked: asBool(m?['liked']) ?? liked,
    );
  }

  /// `GET /v1/posts/{id}/comments` (oldest first).
  Future<CommunityPage<CommunityComment>> comments(
    String? puuid,
    String postId, {
    String? cursor,
    int limit = 30,
  }) async => CommunityPage.fromJson(
    await _send(
      'GET',
      '/v1/posts/${Uri.encodeComponent(postId)}/comments',
      puuid: puuid,
      auth: _Auth.optional,
      query: {'cursor': cursor, 'limit': limit.clamp(1, 50)},
    ),
    CommunityComment.fromJson,
  );

  /// `POST /v1/posts/{id}/comments` (≤ 500 chars).
  Future<CommunityComment> addComment(
    String puuid,
    String postId,
    String body, {
    String? language,
  }) async =>
      CommunityComment.fromJson(
        await _send(
          'POST',
          '/v1/posts/${Uri.encodeComponent(postId)}/comments',
          puuid: puuid,
          json: {'body': body.trim(), 'language': ?language},
        ),
      ) ??
      (throw const CommunityException(CommunityException.badResponse));

  /// `DELETE /v1/comments/{id}` (own comment).
  Future<void> deleteComment(String puuid, String id) =>
      _send('DELETE', '/v1/comments/${Uri.encodeComponent(id)}', puuid: puuid);

  /// `POST /v1/reports`.
  Future<void> report(
    String puuid, {
    required ReportTarget targetType,
    required String targetId,
    required String reason,
  }) => _send(
    'POST',
    '/v1/reports',
    puuid: puuid,
    json: {
      'targetType': targetType.name,
      'targetId': targetId,
      'reason': reason,
    },
  );

  /// `POST /v1/media` (raw JPEG / PNG / WebP bytes, ≤ 2 MB).
  Future<PostMedia> uploadMedia(String puuid, Uint8List bytes) async {
    final type = imageMimeType(bytes);
    if (type == null) {
      throw const CommunityException(CommunityException.imageType);
    }
    if (bytes.length > maxMediaBytes) {
      throw const CommunityException(CommunityException.imageTooLarge);
    }
    return PostMedia.fromJson(
          await _send(
            'POST',
            '/v1/media',
            puuid: puuid,
            bytes: bytes,
            contentType: type,
          ),
        ) ??
        (throw const CommunityException(CommunityException.badResponse));
  }

  /// Server upload limit.
  static const maxMediaBytes = 2 * 1024 * 1024;

  // ------------------------------------------------------------ transport

  Future<Object?> _send(
    String method,
    String path, {
    String? puuid,
    _Auth auth = _Auth.required,
    bool signIn = true,
    Map<String, Object?>? query,
    Object? json,
    List<int>? bytes,
    String? contentType,
  }) async {
    if (!_http.isEnabled) {
      throw const CommunityException(CommunityException.disabled);
    }
    Future<String?> tokenFor() async {
      if (puuid == null) return null;
      if (auth == _Auth.required) return _auth.token(puuid);
      // Optional auth: without the user's consent nothing is sent (no token,
      // no Authorization header). A failed sign-in (e.g. Riot needs
      // login) must not hide public data either: read anonymously.
      if (!_auth.hasConsent(puuid)) return null;
      try {
        return await _auth.token(puuid, signIn: signIn);
      } on Object {
        return null;
      }
    }

    final token = await tokenFor();
    try {
      return await _http.send(
        method,
        path,
        token: token,
        query: query,
        json: json,
        bytes: bytes,
        contentType: contentType,
      );
    } on CommunityException catch (e) {
      if (puuid == null || token == null || !e.isAuthFailure) rethrow;
      // Expired / revoked community session: sign in again, retry once.
      await _auth.invalidate(puuid, token);
      return _http.send(
        method,
        path,
        token: await tokenFor(),
        query: query,
        json: json,
        bytes: bytes,
        contentType: contentType,
      );
    }
  }
}

/// `targetType` of a report.
enum ReportTarget { post, comment, lfg, review }

/// MIME type from the file signature (JPEG, PNG, WebP), else `null`.
String? imageMimeType(List<int> bytes) {
  if (bytes.length >= 3 &&
      bytes[0] == 0xFF &&
      bytes[1] == 0xD8 &&
      bytes[2] == 0xFF) {
    return 'image/jpeg';
  }
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47) {
    return 'image/png';
  }
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 && // R
      bytes[1] == 0x49 && // I
      bytes[2] == 0x46 && // F
      bytes[3] == 0x46 && // F
      bytes[8] == 0x57 && // W
      bytes[9] == 0x45 && // E
      bytes[10] == 0x42 && // B
      bytes[11] == 0x50) {
    return 'image/webp';
  }
  return null;
}
