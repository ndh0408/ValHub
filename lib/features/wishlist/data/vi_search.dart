/// Accent-insensitive search for Vietnamese names ("vo cuc" finds
/// "Vô Cực", "DAO" finds "Dao Reaver").
library;

const _groups = <String, String>{
  'a': 'àáảãạăằắẳẵặâầấẩẫậ',
  'e': 'èéẻẽẹêềếểễệ',
  'i': 'ìíỉĩị',
  'o': 'òóỏõọôồốổỗộơờớởỡợ',
  'u': 'ùúủũụưừứửữự',
  'y': 'ỳýỷỹỵ',
  'd': 'đ',
};

final Map<int, String> _fold = {
  for (final e in _groups.entries)
    for (final rune in e.value.runes) rune: e.key,
};

bool _isCombiningMark(int rune) => rune >= 0x0300 && rune <= 0x036F;

/// Lowercases [input], strips Vietnamese diacritics (precomposed or
/// combining) and collapses whitespace.
String foldForSearch(String input) {
  final out = StringBuffer();
  var lastSpace = true;
  for (final rune in input.toLowerCase().runes) {
    if (_isCombiningMark(rune)) continue;
    final folded = _fold[rune];
    final isSpace =
        rune == 0x20 || rune == 0x09 || rune == 0x0A || rune == 0xA0;
    if (isSpace) {
      if (!lastSpace) out.write(' ');
      lastSpace = true;
      continue;
    }
    lastSpace = false;
    if (folded != null) {
      out.write(folded);
    } else {
      out.writeCharCode(rune);
    }
  }
  return out.toString().trimRight();
}

/// Folded, non-empty search tokens of [query].
List<String> searchTokens(String query) => [
  for (final t in foldForSearch(query).split(' '))
    if (t.isNotEmpty) t,
];

/// Whether every token occurs in [foldedText] (any order).
bool matchesTokens(String foldedText, List<String> tokens) =>
    tokens.every(foldedText.contains);
