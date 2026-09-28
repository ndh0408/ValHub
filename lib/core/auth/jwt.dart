import 'dart:convert';

import '../util/json.dart';

/// Decodes the payload of a JWT **without** verifying its signature (we only
/// read our own tokens: `sub`, `exp`, `nonce`, `affinity`). Returns `null` for
/// anything that is not a well-formed JWT.
JsonMap? decodeJwtPayload(String? token) {
  if (token == null) return null;
  final parts = token.split('.');
  if (parts.length < 2 || parts[1].isEmpty) return null;
  try {
    final normalized = base64Url.normalize(parts[1]);
    return asMap(tryDecodeJson(utf8.decode(base64Url.decode(normalized))));
  } on FormatException {
    return null;
  }
}

/// `sub` claim (for Riot access tokens: the PUUID), lowercased.
String? jwtSubject(String? token) => lowerUuid(decodeJwtPayload(token)?['sub']);

/// `exp` claim as a UTC instant.
DateTime? jwtExpiry(String? token) {
  final exp = asInt(decodeJwtPayload(token)?['exp']);
  return exp == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
}

/// `nonce` claim (id tokens).
String? jwtNonce(String? token) => asString(decodeJwtPayload(token)?['nonce']);
