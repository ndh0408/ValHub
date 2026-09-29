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
  }) async =>
      CommunityAuthor.fromJson(
        await _send(
          'PATCH',
          '/v1/me',
          puuid: puuid,
          json: {'cardId': ?cardId, 'rankTier': ?rankTier, 'region': ?region},
        ),
      ) ??
      (throw const CommunityException(CommunityException.badResponse));

  // ----------------------------------------------------------------- LFG

  /// `GET /v1/lfg` (active posts, newest first).
  Future<CommunityPage<LfgPost>> lfg(
    String puuid, {
    required String region,
    String? mode,
    String? cursor,
    int limit = 20,
  }) async => CommunityPage.fromJson(
    await _send(
      'GET',
      '/v1/lfg',
      puuid: puuid,
      query: {
        'region': region,
        'mode': mode,
        'cursor': cursor,
        'limit': limit.clamp(1, 50),
      },
    ),
    LfgPost.fromJson,
  );

  /// `POST /v1/lfg` (replaces the user's previous post).
  Future<LfgPost> createLfg(
    String puuid, {
    required String region,
    required String mode,
    required String partyCode,
    required int slots,
    int? rankTier,
    String? note,
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
          },
        ),
      ) ??
      (throw const CommunityException(CommunityException.badResponse));

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
        'weapon': weapon,
        'period': period.query,
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

  /// `GET /v1/skins/votes?ids=…` (≤ 50 ids; auth optional).
  Future<Map<String, SkinVote>> skinVotes(
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
    final votes = [
      for (final e in asList(asMap(body)?['items'] ?? body))
        ?SkinVote.fromJson(e),
    ];
    return {for (final v in votes) v.skinUuid: v};
  }

  // ----------------------------------------------------------------- feed

  /// `GET /v1/posts` (newest first).
  Future<CommunityPage<CommunityPost>> posts(
    String puuid, {
    PostKind? kind,
    String? cursor,
    int limit = 20,
  }) async => CommunityPage.fromJson(
    await _send(
      'GET',
      '/v1/posts',
      puuid: puuid,
      query: {
        'kind': kind?.name,
        'cursor': cursor,
        'limit': limit.clamp(1, 50),
      },
    ),
    CommunityPost.fromJson,
  );

  /// `GET /v1/posts/{id}`.
  Future<CommunityPost> post(String puuid, String id) async =>
      CommunityPost.fromJson(
        await _send(
          'GET',
          '/v1/posts/${Uri.encodeComponent(id)}',
          puuid: puuid,
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
  }) async =>
      CommunityPost.fromJson(
        await _send(
          'POST',
          '/v1/posts',
          puuid: puuid,
          json: {
            'kind': kind.name,
            'body': body.trim(),
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
    String puuid,
    String postId, {
    String? cursor,
    int limit = 30,
  }) async => CommunityPage.fromJson(
    await _send(
      'GET',
      '/v1/posts/${Uri.encodeComponent(postId)}/comments',
      puuid: puuid,
      query: {'cursor': cursor, 'limit': limit.clamp(1, 50)},
    ),
    CommunityComment.fromJson,
  );

  /// `POST /v1/posts/{id}/comments` (≤ 500 chars).
  Future<CommunityComment> addComment(
    String puuid,
    String postId,
    String body,
  ) async =>
      CommunityComment.fromJson(
        await _send(
          'POST',
          '/v1/posts/${Uri.encodeComponent(postId)}/comments',
          puuid: puuid,
          json: {'body': body.trim()},
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
      return _auth.token(puuid, signIn: auth == _Auth.required || signIn);
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
enum ReportTarget { post, comment, lfg }

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
