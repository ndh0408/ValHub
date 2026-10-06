import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../util/json.dart';

/// Minimal `name → value` cookie jar for `*.riotgames.com`, persisted per
/// account in secure storage (never in plain files; SUMMARY §3.5).
///
/// Immutable: [merge] returns a new jar.
@immutable
class RiotCookieJar {
  const RiotCookieJar([this.cookies = const {}]);

  /// Decodes the JSON written by [encode]. Corrupt input yields an empty jar.
  factory RiotCookieJar.decode(String? json) {
    final map = asMap(tryDecodeJson(json));
    if (map == null) return const RiotCookieJar();
    return RiotCookieJar({
      for (final e in map.entries)
        if (e.value is String && (e.value as String).isNotEmpty)
          e.key: e.value as String,
    });
  }

  final Map<String, String> cookies;

  bool get isEmpty => cookies.isEmpty;
  bool get isNotEmpty => cookies.isNotEmpty;
  bool has(String name) => cookies.containsKey(name);
  String? operator [](String name) => cookies[name];

  /// `Cookie:` header value.
  String get header =>
      cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

  String encode() => jsonEncode(cookies);

  /// Merges `Set-Cookie` headers. Expired cookies (`Max-Age<=0`, an
  /// `Expires` in the past, or an empty value) are removed.
  RiotCookieJar merge(Iterable<String>? setCookieHeaders, {DateTime? now}) {
    if (setCookieHeaders == null) return this;
    final next = Map<String, String>.of(cookies);
    final at = (now ?? DateTime.now()).toUtc();
    for (final raw in setCookieHeaders) {
      final parsed = parseSetCookie(raw, now: at);
      if (parsed == null) continue;
      if (parsed.expired) {
        next.remove(parsed.name);
      } else {
        next[parsed.name] = parsed.value;
      }
    }
    return RiotCookieJar(next);
  }

  /// Adds or replaces cookies from a plain map (e.g. the WebView store).
  RiotCookieJar withAll(Map<String, String> values) =>
      RiotCookieJar({...cookies, ...values});

  @override
  bool operator ==(Object other) =>
      other is RiotCookieJar && mapEquals(other.cookies, cookies);

  @override
  int get hashCode => Object.hashAllUnordered(
    cookies.entries.map((e) => Object.hash(e.key, e.value)),
  );

  /// Never prints values.
  @override
  String toString() => 'RiotCookieJar(${cookies.keys.join(', ')})';
}

/// One parsed `Set-Cookie` header.
@immutable
class SetCookie {
  const SetCookie(
    this.name,
    this.value, {
    required this.expired,
    this.lifetime,
  });

  final String name;
  final String value;
  final bool expired;

  /// How long the cookie lives (`Max-Age` wins over `Expires`); `null` for a
  /// cookie that ends with the browser session.
  final Duration? lifetime;
}

/// Lifetime that [setCookieHeaders] give cookie [name]: `null` when no header
/// sets it, [Duration.zero] when it is a browser-session cookie (no
/// `Max-Age` / `Expires`) or is being deleted. Riot's SSO cookie (`ssid`)
/// only slides for weeks when the user ticked "Stay signed in", so this is
/// the token-free evidence of what Riot granted.
Duration? cookieLifetime(
  Iterable<String>? setCookieHeaders,
  String name, {
  DateTime? now,
}) {
  if (setCookieHeaders == null) return null;
  Duration? found;
  for (final raw in setCookieHeaders) {
    final parsed = parseSetCookie(raw, now: now);
    if (parsed == null || parsed.name != name) continue;
    found = parsed.expired ? Duration.zero : parsed.lifetime ?? Duration.zero;
  }
  return found;
}

/// Parses a single `Set-Cookie` header value. Returns `null` when malformed.
SetCookie? parseSetCookie(String raw, {DateTime? now}) {
  final parts = raw.split(';');
  final first = parts.first;
  final eq = first.indexOf('=');
  if (eq <= 0) return null;
  final name = first.substring(0, eq).trim();
  var value = first.substring(eq + 1).trim();
  if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
    value = value.substring(1, value.length - 1);
  }
  if (name.isEmpty) return null;
  var expired = value.isEmpty;
  final at = (now ?? DateTime.now()).toUtc();
  Duration? maxAge;
  Duration? untilExpires;
  for (final attr in parts.skip(1)) {
    final i = attr.indexOf('=');
    final key = (i < 0 ? attr : attr.substring(0, i)).trim().toLowerCase();
    final v = i < 0 ? '' : attr.substring(i + 1).trim();
    if (key == 'max-age') {
      final seconds = int.tryParse(v);
      if (seconds != null && seconds <= 0) expired = true;
      if (seconds != null && seconds > 0) maxAge = Duration(seconds: seconds);
    } else if (key == 'expires') {
      final when = _parseCookieDate(v);
      if (when != null && !when.isAfter(at)) expired = true;
      if (when != null && when.isAfter(at)) untilExpires = when.difference(at);
    }
  }
  return SetCookie(
    name,
    value,
    expired: expired,
    lifetime: expired ? null : maxAge ?? untilExpires,
  );
}

const _months = {
  'jan': 1,
  'feb': 2,
  'mar': 3,
  'apr': 4,
  'may': 5,
  'jun': 6,
  'jul': 7,
  'aug': 8,
  'sep': 9,
  'oct': 10,
  'nov': 11,
  'dec': 12,
};

/// Lenient cookie-date parser: `Thu, 01 Jan 1970 00:00:00 GMT`,
/// `Thu, 01-Jan-1970 00:00:00 GMT`.
DateTime? _parseCookieDate(String input) {
  final m = RegExp(
    r'(\d{1,2})[ -]([A-Za-z]{3})[a-z]*[ -](\d{2,4})\s+(\d{1,2}):(\d{2}):(\d{2})',
  ).firstMatch(input);
  if (m == null) return null;
  final month = _months[m[2]!.toLowerCase()];
  if (month == null) return null;
  var year = int.parse(m[3]!);
  if (year < 100) year += year < 70 ? 2000 : 1900;
  return DateTime.utc(
    year,
    month,
    int.parse(m[1]!),
    int.parse(m[4]!),
    int.parse(m[5]!),
    int.parse(m[6]!),
  );
}
