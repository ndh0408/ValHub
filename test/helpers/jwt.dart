import 'dart:convert';

String _b64(Object json) => base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');

/// An unsigned JWT with [payload] (signature is not checked by the app).
String fakeJwt(Map<String, Object?> payload) =>
    '${_b64({'alg': 'RS256', 'kid': 'test'})}.${_b64(payload)}.c2ln';
