import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/locale_controller.dart';
import '../util/json.dart';
import 'country_data.g.dart';
export 'country_data.g.dart' show countryAlpha3To2;
import 'regions.dart';

String? normalizeCountry(Object? value) {
  if (value is! String) return null;
  final code = value.trim();
  if (code.length == 3) return countryAlpha3To2[code.toLowerCase()];
  final upper = code.toUpperCase();
  return countryAlpha3To2.values.contains(upper) ? upper : null;
}

enum CountryAvailability { available, restricted, separate, unknown, na }

class CountryInfo {
  const CountryInfo({
    required this.code,
    required this.alpha3,
    required this.availability,
    this.regionHint,
    this.nonIso = false,
  });
  final String code;
  final String alpha3;
  final CountryAvailability availability;
  final String? regionHint;
  final bool nonIso;
  bool get isSupported =>
      availability == CountryAvailability.available && regionHint != null;
  String? get shardHint => RegionTable.shardFor(regionHint);

  static CountryInfo? parse(String code, Object? json) {
    final row = asMap(json);
    if (row == null || normalizeCountry(code) == null) return null;
    final a3 = asNonEmptyString(row['a3']);
    if (a3 == null || normalizeCountry(a3) != code) return null;
    return CountryInfo(
      code: code,
      alpha3: a3,
      regionHint: RegionTable.normalize(row['region']),
      availability:
          CountryAvailability.values
              .where((v) => v.name == row['status'])
              .firstOrNull ??
          CountryAvailability.unknown,
      nonIso: asBool(row['nonIso']) ?? false,
    );
  }
}

class CountryNames {
  const CountryNames({
    required this.names,
    required this.english,
    required this.order,
  });
  final Map<String, String> names;
  final Map<String, String> english;
  final List<String> order;
  String name(String code) => names[code] ?? english[code] ?? code;
}

final countriesProvider = FutureProvider<Map<String, CountryInfo>>((ref) async {
  final json = asMap(
    jsonDecode(await rootBundle.loadString('assets/data/countries.json')),
  );
  final rows = asMap(json?['countries']) ?? {};
  return Map.unmodifiable({
    for (final e in rows.entries) e.key: ?CountryInfo.parse(e.key, e.value),
  });
});

final countryNamesProvider = FutureProvider<CountryNames>((ref) async {
  final locale = ref.watch(appLocaleProvider).arbCode.replaceAll('_', '-');
  Future<JsonMap> load(String tag) async =>
      asMap(
        jsonDecode(
          await rootBundle.loadString('assets/l10n/countries/$tag.json'),
        ),
      ) ??
      {};
  final en = await load('en');
  final data = locale == 'en' ? en : await load(locale);
  Map<String, String> names(JsonMap d) => {
    for (final e in (asMap(d['names']) ?? {}).entries)
      e.key: ?asString(e.value),
  };
  return CountryNames(
    names: names(data),
    english: names(en),
    order: asList(data['order']).whereType<String>().toList(growable: false),
  );
});
