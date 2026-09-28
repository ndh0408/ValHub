/// Defensive JSON helpers.
///
/// Riot and valorant-api payloads are treated as untrusted: every field may be
/// missing, `null`, of the wrong type, or (for error bodies) not JSON at all.
/// These helpers never throw; they return `null` (or an empty collection) when
/// a value does not have the expected shape.
library;

import 'dart:convert';

/// A decoded JSON object.
typedef JsonMap = Map<String, dynamic>;

/// Returns [value] as a [JsonMap] when it is a map with string keys.
JsonMap? asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    final out = <String, dynamic>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is String) out[key] = entry.value;
    }
    return out;
  }
  return null;
}

/// Returns [value] as a list, or an empty list when it is `null` or not a list.
List<Object?> asList(Object? value) =>
    value is List ? List<Object?>.from(value) : const <Object?>[];

/// Returns every element of [value] that is a JSON object.
List<JsonMap> asMapList(Object? value) => [
  for (final element in asList(value)) ?asMap(element),
];

/// Returns every element of [value] that is a non-empty string.
List<String> asStringList(Object? value) => [
  for (final element in asList(value))
    if (element is String && element.isNotEmpty) element,
];

/// Returns [value] as a string. Numbers and booleans are converted; anything
/// else yields `null`.
String? asString(Object? value) => switch (value) {
  final String s => s,
  final num n => n.toString(),
  final bool b => b.toString(),
  _ => null,
};

/// Like [asString] but also maps empty or whitespace-only strings to `null`.
String? asNonEmptyString(Object? value) {
  final s = asString(value)?.trim();
  return (s == null || s.isEmpty) ? null : s;
}

/// Returns [value] as an `int`. Accepts any [num] (truncated) and numeric
/// strings.
int? asInt(Object? value) => switch (value) {
  final int i => i,
  final num n when n.isFinite => n.toInt(),
  final String s => int.tryParse(s.trim()) ?? _finiteDouble(s)?.toInt(),
  _ => null,
};

/// Returns [value] as a `double`. Accepts any [num] and numeric strings.
double? asDouble(Object? value) => switch (value) {
  final num n => n.toDouble(),
  final String s => _finiteDouble(s),
  _ => null,
};

/// Returns [value] as a [num] (numbers and numeric strings).
num? asNum(Object? value) => switch (value) {
  final num n => n,
  final String s => num.tryParse(s.trim()),
  _ => null,
};

double? _finiteDouble(String s) {
  final d = double.tryParse(s.trim());
  return (d == null || !d.isFinite) ? null : d;
}

/// Returns [value] as a `bool`. Accepts booleans, `"true"`/`"false"` and
/// `0`/`1`.
bool? asBool(Object? value) => switch (value) {
  final bool b => b,
  final num n => n != 0,
  final String s => switch (s.trim().toLowerCase()) {
    'true' || '1' => true,
    'false' || '0' => false,
    _ => null,
  },
  _ => null,
};

/// Returns [value] as a lowercase, trimmed UUID (or any id string). Riot sends
/// some ids uppercase; valorant-api always lowercase. Empty strings and the
/// all-zero UUID are *kept* (callers decide), but whitespace-only strings
/// yield `null`.
String? lowerUuid(Object? value) {
  final s = asString(value)?.trim();
  return (s == null || s.isEmpty) ? null : s.toLowerCase();
}

/// Returns [value] as a UTC [DateTime]. Accepts ISO-8601 strings and epoch
/// milliseconds (numbers or numeric strings). Riot's `0001-01-01T00:00:00Z`
/// placeholder is treated as absent.
DateTime? asDateTime(Object? value) {
  DateTime? result;
  if (value is num && value.isFinite) {
    result = DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
  } else if (value is String) {
    final s = value.trim();
    if (s.isEmpty) return null;
    final asNumber = int.tryParse(s);
    result = asNumber != null
        ? DateTime.fromMillisecondsSinceEpoch(asNumber, isUtc: true)
        : DateTime.tryParse(s)?.toUtc();
  }
  if (result == null || result.year <= 1) return null;
  return result;
}

/// Walks [path] (string keys and int indices) into [root].
Object? pick(Object? root, List<Object> path) {
  Object? current = root;
  for (final segment in path) {
    if (segment is String) {
      final map = asMap(current);
      if (map == null) return null;
      current = map[segment];
    } else if (segment is int) {
      final list = asList(current);
      if (segment < 0 || segment >= list.length) return null;
      current = list[segment];
    } else {
      return null;
    }
  }
  return current;
}

/// Decodes [source] as JSON, returning `null` for empty or non-JSON input
/// (for example a Cloudflare HTML error page).
Object? tryDecodeJson(String? source) {
  if (source == null) return null;
  final trimmed = source.trimLeft();
  if (trimmed.isEmpty) return null;
  final first = trimmed.codeUnitAt(0);
  // Only objects, arrays and JSON strings are worth decoding here.
  if (first != 0x7B /* { */ &&
      first != 0x5B /* [ */ &&
      first != 0x22 /* " */ ) {
    return null;
  }
  try {
    return jsonDecode(trimmed);
  } on FormatException {
    return null;
  }
}

/// Unwraps the valorant-api envelope `{"status":200,"data":…}`.
Object? vapiData(Object? envelope) => asMap(envelope)?['data'];

/// Ergonomic typed accessors on [JsonMap].
extension JsonMapX on JsonMap {
  JsonMap? map(String key) => asMap(this[key]);
  List<Object?> list(String key) => asList(this[key]);
  List<JsonMap> maps(String key) => asMapList(this[key]);
  List<String> strings(String key) => asStringList(this[key]);
  String? str(String key) => asString(this[key]);
  String? text(String key) => asNonEmptyString(this[key]);
  int? integer(String key) => asInt(this[key]);
  double? dbl(String key) => asDouble(this[key]);
  num? number(String key) => asNum(this[key]);
  bool? boolean(String key) => asBool(this[key]);
  String? uuid(String key) => lowerUuid(this[key]);
  DateTime? dateTime(String key) => asDateTime(this[key]);
}
