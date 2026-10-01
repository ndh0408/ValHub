import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/geo/countries.dart';
import 'package:valvn/core/geo/regions.dart';

void main() {
  test(
    'all country assets cover 249 ISO countries and the marked XK extension',
    () {
      final data = jsonDecode(
        File('assets/data/countries.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final rows = (data['countries'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, v as Map<String, dynamic>),
      );
      expect(rows.length, 250);
      expect(rows['XK']!['nonIso'], true);
      final sources = (data['sources'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, v as Map<String, dynamic>),
      );
      for (final entry in rows.entries) {
        final country = CountryInfo.parse(entry.key, entry.value)!;
        expect(normalizeCountry(country.alpha3), country.code);
        expect(country.shardHint, RegionTable.shardFor(country.regionHint));
        if (country.availability == CountryAvailability.available) {
          expect(entry.value['src'], isNotEmpty);
          expect(entry.value['conf'], isNot('unverified'));
          for (final source in (entry.value['src'] as List).cast<String>()) {
            expect(sources[source]!['kind'], 'official');
            expect(
              Uri.parse(sources[source]!['url'] as String).scheme,
              'https',
            );
          }
        }
      }
      final locales = Directory('assets/l10n/countries')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'));
      expect(locales.length, 18);
      for (final file in locales) {
        final names =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        expect(
          (names['names'] as Map).keys.toSet(),
          rows.keys.toSet(),
          reason: file.path,
        );
        expect(
          (names['order'] as List).toSet(),
          rows.keys.toSet(),
          reason: file.path,
        );
        expect((names['order'] as List).length, 250);
        expect(
          (names['names'] as Map).values.every(
            (v) => v is String && v.isNotEmpty,
          ),
          true,
        );
      }
    },
  );

  test('country normalization rejects pseudo and unrelated codes', () {
    expect(normalizeCountry('vnm'), 'VN');
    expect(normalizeCountry(' USA '), 'US');
    expect(normalizeCountry('xk'), 'XK');
    for (final invalid in [
      'ZZ',
      'UK',
      'EL',
      'EU',
      '001',
      'zzzz',
      '',
      42,
      null,
    ]) {
      expect(normalizeCountry(invalid), isNull);
    }
  });

  test(
    'legacy accounts recompute shards and never assume a missing region',
    () {
      final a = Account.fromJson({
        'puuid': 'account',
        'region': 'latam',
        'shard': 'ap',
        'country': 'usa',
      })!;
      expect(a.region, 'latam');
      expect(a.shard, 'na');
      expect(a.country, 'US');
      final missing = Account.fromJson({'puuid': 'account'})!;
      expect(missing.needsRegionSelection, true);
      expect(missing.region, '');
      expect(missing.shard, '');
      expect(
        Account.fromJson({'puuid': 'account', 'country': 'ZZ'})!.country,
        isNull,
      );
    },
  );

  test('country and updated auto detection do not replace manual routing', () {
    final a = Account.fromJson({'puuid': 'account', 'region': 'ap'})!;
    final manual = a.copyWith(
      regionMode: RegionMode.manual,
      manualRegion: 'br',
    );
    final updated = manual.copyWith(detectedRegion: 'eu', country: 'KR');
    expect(updated.region, 'br');
    expect(updated.shard, 'na');
    expect(updated.autoRegion, 'eu');
    expect(Account.fromJson(updated.toJson()), updated);
    final auto = updated.copyWith(regionMode: RegionMode.auto);
    expect(auto.region, 'eu');
    expect(auto.shard, 'eu');
  });
}
