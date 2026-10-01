import '../util/search_text.dart';
import 'countries.dart';

/// Null means no match. Prefixes precede word prefixes, then substrings;
/// callers retain CLDR/server order among equal ranks.
int? countrySearchRank(CountryInfo country, CountryNames names, String query) {
  final tokens = searchTokens(query);
  if (tokens.isEmpty) return 0;
  final fields = [
    names.name(country.code),
    names.english[country.code] ?? '',
    country.code,
    country.alpha3,
    ...?names.aliases[country.code],
  ].map(foldForSearch).toList();
  if (!matchesTokens(fields.join(' '), tokens)) return null;
  final folded = tokens.join(' ');
  if (fields.any((field) => field.startsWith(folded))) return 0;
  if (fields.any(
    (field) => field.split(' ').any((word) => word.startsWith(folded)),
  )) {
    return 1;
  }
  return 2;
}

List<String> searchCountryCodes(
  Iterable<String> candidates, {
  required Map<String, CountryInfo> countries,
  required CountryNames names,
  String query = '',
  bool isoOnly = false,
}) {
  final ranked = <({String code, int rank, int position})>[];
  final seen = <String>{};
  for (final code in candidates) {
    final country = countries[code];
    if (country == null ||
        !seen.add(code) ||
        (isoOnly && (country.nonIso || code == 'XK'))) {
      continue;
    }
    final rank = countrySearchRank(country, names, query);
    if (rank != null) {
      ranked.add((code: code, rank: rank, position: ranked.length));
    }
  }
  ranked.sort((a, b) {
    final rank = a.rank.compareTo(b.rank);
    return rank != 0 ? rank : a.position.compareTo(b.position);
  });
  return [for (final row in ranked) row.code];
}
