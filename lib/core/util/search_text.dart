/// Language-independent search folding for every VALORANT language.
///
/// Players type without accents, in another case or on another keyboard
/// width and still expect a match: "thuong gioi" → "Thượng Giới",
/// "cafe" → "Café", "strasse" → "Straße", "sehir" → "Şehir",
/// "ＲＥＡＶＥＲ" → "Reaver", "ёлка" → "елка", "مرحبا" with harakat → without.
/// [foldForSearch] applies the same folding to the query and to the
/// candidates; [matchesSearch] checks that every word of the query occurs.
///
/// Folding (in order): Unicode lowercase; canonical decomposition of
/// precomposed Latin / Greek / Cyrillic / Arabic letters with the combining
/// marks dropped (generated table, `search_fold_table.dart`); combining
/// marks already present in the text (NFD input, Hebrew points, Arabic
/// harakat) and the Arabic tatweel are removed; đ/ð → d, ß → ss, æ → ae,
/// œ → oe, ø → o, ł → l, dotless ı / İ → i, final ς → σ; full-width ASCII
/// and the ideographic space → half-width; whitespace collapsed. Japanese
/// kana, Hangul and CJK ideographs are left untouched.
library;

import 'search_fold_table.dart';

bool _isStripped(int c) =>
    (c >= 0x0300 && c <= 0x036F) || // combining diacritical marks
    (c >= 0x0483 && c <= 0x0489) || // Cyrillic combining marks
    (c >= 0x0591 && c <= 0x05BD) || // Hebrew points and accents
    c == 0x05BF ||
    c == 0x05C1 ||
    c == 0x05C2 ||
    c == 0x05C4 ||
    c == 0x05C5 ||
    c == 0x05C7 ||
    (c >= 0x0610 && c <= 0x061A) || // Arabic signs
    (c >= 0x064B && c <= 0x065F) || // Arabic harakat
    c == 0x0670 || // Arabic superscript alef
    c == 0x0640 || // Arabic tatweel
    (c >= 0x06D6 && c <= 0x06DC) ||
    (c >= 0x06DF && c <= 0x06E4) ||
    c == 0x06E7 ||
    c == 0x06E8 ||
    (c >= 0x06EA && c <= 0x06ED) ||
    (c >= 0x1AB0 && c <= 0x1AFF) || // combining marks extended
    (c >= 0x1DC0 && c <= 0x1DFF) || // combining marks supplement
    (c >= 0x20D0 && c <= 0x20FF) || // combining marks for symbols
    (c >= 0xFE20 && c <= 0xFE2F); // combining half marks

bool _isSpace(int c) =>
    c == 0x20 ||
    c == 0x09 ||
    c == 0x0A ||
    c == 0x0D ||
    c == 0xA0 ||
    c == 0x3000 ||
    (c >= 0x2000 && c <= 0x200A) ||
    c == 0x202F;

/// `"  Phantom THƯỢNG   Giới "` → `"phantom thuong gioi"`.
///
/// Pure; cheap enough to run on every row for each keystroke, but big
/// lists should fold once ([SearchIndex]).
String foldForSearch(String input) {
  if (input.isEmpty) return input;
  final out = StringBuffer();
  var pendingSpace = false;
  for (final rune in input.toLowerCase().runes) {
    if (_isSpace(rune)) {
      pendingSpace = out.isNotEmpty;
      continue;
    }
    if (_isStripped(rune)) continue;
    var c = rune;
    // Full-width ASCII (！ … ～) → half-width.
    if (c >= 0xFF01 && c <= 0xFF5E) c -= 0xFEE0;
    // Full-width upper-case letters are only lower-cased after the shift.
    if (c >= 0x41 && c <= 0x5A) c += 0x20;
    if (pendingSpace) {
      out.writeCharCode(0x20);
      pendingSpace = false;
    }
    final folded = kSearchFoldTable[c];
    if (folded != null) {
      out.write(folded);
    } else {
      out.writeCharCode(c);
    }
  }
  return out.toString();
}

/// The words of a folded query (empty for a blank query).
List<String> searchTokens(String query) {
  final folded = foldForSearch(query);
  if (folded.isEmpty) return const [];
  return folded.split(' ');
}

/// True when every word of [query] occurs in at least one of [candidates]
/// (after folding). A blank query matches everything.
///
/// ```dart
/// matchesSearch('thuong gioi', ['Phantom Thượng Giới'])   // true
/// matchesSearch('THƯỢNG vandal', ['Vandal Thượng Giới'])  // true
/// ```
bool matchesSearch(String query, Iterable<String?> candidates) {
  final tokens = searchTokens(query);
  if (tokens.isEmpty) return true;
  return matchesTokens(_joinKeys(candidates), tokens);
}

/// Whether every token occurs in [foldedText] (any order).
bool matchesTokens(String foldedText, List<String> tokens) =>
    tokens.every(foldedText.contains);

/// Accent-insensitive name comparison (ties broken by the raw text), so
/// "Ánh" sorts before "Bạc".
int compareNames(String a, String b) {
  final c = foldForSearch(a).compareTo(foldForSearch(b));
  return c != 0 ? c : a.compareTo(b);
}

// A separator no folded query can contain, so a word never matches across
// two candidates.
String _joinKeys(Iterable<String?> candidates) =>
    candidates.whereType<String>().map(foldForSearch).join(' \u0000 ');

/// Pre-folded search keys for a list, so typing does not re-fold every row.
class SearchIndex<T> {
  SearchIndex(Iterable<T> items, Iterable<String?> Function(T item) keys)
    : _entries = [
        for (final item in items) (item: item, key: _joinKeys(keys(item))),
      ];

  final List<({T item, String key})> _entries;

  /// Items whose keys contain every word of [query], in the original order.
  List<T> filter(String query) {
    final tokens = searchTokens(query);
    if (tokens.isEmpty) return [for (final e in _entries) e.item];
    return [
      for (final e in _entries)
        if (matchesTokens(e.key, tokens)) e.item,
    ];
  }
}
