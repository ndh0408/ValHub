/// Diacritic-insensitive search for Vietnamese text.
///
/// Players type "thuong gioi", "thượng giới" or "THUONG GIOI" and expect to
/// find "Phantom Thượng Giới". [foldSearchText] lowercases, strips every
/// Vietnamese tone / vowel mark (including `đ` → `d`) and collapses
/// whitespace; [matchesSearch] checks that every word of the query appears
/// in one of the candidate texts.
library;

const _from =
    'àáạảãâầấậẩẫăằắặẳẵ'
    'èéẹẻẽêềếệểễ'
    'ìíịỉĩ'
    'òóọỏõôồốộổỗơờớợởỡ'
    'ùúụủũưừứựửữ'
    'ỳýỵỷỹ'
    'đ';
const _to =
    'aaaaaaaaaaaaaaaaa'
    'eeeeeeeeeee'
    'iiiii'
    'ooooooooooooooooo'
    'uuuuuuuuuuu'
    'yyyyy'
    'd';

final Map<int, int> _fold = () {
  assert(_from.length == _to.length, 'diacritic table mismatch');
  final map = <int, int>{};
  for (var i = 0; i < _from.length; i++) {
    map[_from.codeUnitAt(i)] = _to.codeUnitAt(i);
  }
  // Latin letters with diacritics that show up in skin names from other
  // locales (en-US item language): "Pokémon", "Señor", "Über".
  const extraFrom = 'çñäëïöüÿåøœæ';
  const extraTo = 'cnaeiouyaooa';
  for (var i = 0; i < extraFrom.length; i++) {
    map[extraFrom.codeUnitAt(i)] = extraTo.codeUnitAt(i);
  }
  return map;
}();

// Combining marks (NFD input, e.g. text pasted from some keyboards):
// U+0300–U+036F.
bool _isCombining(int c) => c >= 0x0300 && c <= 0x036F;

final RegExp _spaces = RegExp(r'\s+');

/// `"  Phantom THƯỢNG   Giới "` → `"phantom thuong gioi"`.
///
/// Pure and allocation-light; safe to call for every row of a list on each
/// keystroke (cache it with [SearchIndex] for big lists).
String foldSearchText(String input) {
  if (input.isEmpty) return input;
  final lower = input.toLowerCase();
  final out = StringBuffer();
  for (final c in lower.codeUnits) {
    if (_isCombining(c)) continue;
    final mapped = _fold[c];
    out.writeCharCode(mapped ?? c);
  }
  return out.toString().trim().replaceAll(_spaces, ' ');
}

/// The words of a folded query (empty for a blank query).
List<String> searchTokens(String query) {
  final folded = foldSearchText(query);
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
  final haystack = candidates
      .whereType<String>()
      .map(foldSearchText)
      .join(' \u0000 ');
  return tokens.every(haystack.contains);
}

/// Whether every token occurs in [foldedText] (any order).
bool matchesTokens(String foldedText, List<String> tokens) =>
    tokens.every(foldedText.contains);

/// Accent-insensitive name comparison (ties broken by the raw text), so
/// "Ánh" sorts before "Bạc".
int compareNames(String a, String b) {
  final c = foldSearchText(a).compareTo(foldSearchText(b));
  return c != 0 ? c : a.compareTo(b);
}

/// Pre-folded search keys for a list, so typing does not re-fold every row.
class SearchIndex<T> {
  SearchIndex(Iterable<T> items, Iterable<String?> Function(T item) keys)
    : _entries = [
        for (final item in items)
          (
            item: item,
            key: keys(item)
                .whereType<String>()
                .map(foldSearchText)
                .join(' \u0000 '),
          ),
      ];

  final List<({T item, String key})> _entries;

  /// Items whose keys contain every word of [query], in the original order.
  List<T> filter(String query) {
    final tokens = searchTokens(query);
    if (tokens.isEmpty) return [for (final e in _entries) e.item];
    return [
      for (final e in _entries)
        if (tokens.every(e.key.contains)) e.item,
    ];
  }
}
