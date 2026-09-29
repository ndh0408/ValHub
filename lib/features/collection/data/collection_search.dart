/// Accent-insensitive search for Vietnamese item names ("cafe xanh mat"
/// finds "Vandal Cafe Xanh Mát").
library;

const _groups = <String, String>{
  'a': 'àáạảãâầấậẩẫăằắặẳẵ',
  'e': 'èéẹẻẽêềếệểễ',
  'i': 'ìíịỉĩ',
  'o': 'òóọỏõôồốộổỗơờớợởỡ',
  'u': 'ùúụủũưừứựửữ',
  'y': 'ỳýỵỷỹ',
  'd': 'đ',
};

final Map<int, String> _fold = {
  for (final e in _groups.entries)
    for (final rune in e.value.runes) rune: e.key,
};

/// Lowercases [input], strips Vietnamese diacritics and collapses spaces.
String foldSearchText(String input) {
  final lower = input.toLowerCase();
  final out = StringBuffer();
  var lastSpace = true;
  for (final rune in lower.runes) {
    final isSpace = rune == 0x20 || rune == 0x09 || rune == 0x0A;
    if (isSpace) {
      if (!lastSpace) out.write(' ');
      lastSpace = true;
      continue;
    }
    lastSpace = false;
    out.write(_fold[rune] ?? String.fromCharCode(rune));
  }
  return out.toString().trimRight();
}

/// Whether every word of [query] occurs in one of [texts] (accent- and
/// case-insensitive). An empty query matches everything.
bool matchesSearch(String query, Iterable<String?> texts) {
  final words = foldSearchText(query).split(' ').where((w) => w.isNotEmpty);
  if (words.isEmpty) return true;
  final haystack = [
    for (final t in texts)
      if (t != null && t.isNotEmpty) foldSearchText(t),
  ].join(' | ');
  return words.every(haystack.contains);
}

/// Accent-insensitive name comparison (ties broken by the raw text).
int compareNames(String a, String b) {
  final c = foldSearchText(a).compareTo(foldSearchText(b));
  return c != 0 ? c : a.compareTo(b);
}
