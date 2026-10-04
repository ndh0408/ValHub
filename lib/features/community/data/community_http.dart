import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/util/json.dart';
import 'community_exception.dart';

/// Whether [url] can be used as the community server base URL.
bool isUsableCommunityUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  return uri != null &&
      uri.scheme == 'https' &&
      uri.host.isNotEmpty &&
      !uri.host.contains('replace.');
}

/// Low-level JSON transport to the community server: builds the URL,
/// attaches the bearer token, decodes bodies defensively (HTML error pages,
/// empty 204s) and maps every failure to a [CommunityException].
///
/// Never logs headers or bodies (the dio's session-log interceptor only
/// records method, host, path template and status).
class CommunityHttp {
  CommunityHttp({required this._dio, required String baseUrl})
    : baseUrl = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');

  final Dio _dio;
  final String baseUrl;

  bool get isEnabled => isUsableCommunityUrl(baseUrl);

  /// Sends one request and returns the decoded JSON body (`null` when the
  /// body is empty, e.g. `204`).
  Future<Object?> send(
    String method,
    String path, {
    String? token,
    Map<String, Object?>? query,
    Object? json,
    List<int>? bytes,
    String? contentType,
    String? idempotencyKey,
  }) async {
    if (!isEnabled) throw const CommunityException(CommunityException.disabled);
    final q = <String, String>{
      if (query != null)
        for (final e in query.entries)
          if (e.value != null && '${e.value}'.isNotEmpty) e.key: '${e.value}',
    };
    final base = Uri.parse('$baseUrl$path');
    final uri = q.isEmpty ? base : base.replace(queryParameters: q);
    final headers = <String, Object>{
      'Accept': 'application/json',
      'Idempotency-Key': ?idempotencyKey,
      if (token != null) 'Authorization': 'Bearer $token',
      if (bytes != null) Headers.contentLengthHeader: bytes.length,
    };
    try {
      final res = await _dio.requestUri<String>(
        uri,
        data: bytes != null
            ? Stream<List<int>>.value(bytes)
            : (json == null ? null : jsonEncode(json)),
        options: Options(
          method: method,
          responseType: ResponseType.plain,
          contentType:
              contentType ??
              (json == null ? null : 'application/json; charset=utf-8'),
          headers: headers,
        ),
      );
      final text = (res.data ?? '').trim();
      // Empty 204s and a JSON `null` (e.g. `GET /v1/lfg/mine` without a post).
      if (text.isEmpty || text == 'null') return null;
      final decoded = tryDecodeJson(text);
      if (decoded == null) {
        throw CommunityException(
          CommunityException.badResponse,
          status: res.statusCode,
        );
      }
      return decoded;
    } on DioException catch (e) {
      throw CommunityException.fromDio(e);
    }
  }
}
