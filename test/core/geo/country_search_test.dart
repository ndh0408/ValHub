import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/geo/countries.dart';
import 'package:valvn/core/geo/country_search.dart';

void main() {
  const countries = {
    'VN': CountryInfo(
      code: 'VN',
      alpha3: 'VNM',
      availability: CountryAvailability.available,
    ),
    'JP': CountryInfo(
      code: 'JP',
      alpha3: 'JPN',
      availability: CountryAvailability.available,
    ),
    'CG': CountryInfo(
      code: 'CG',
      alpha3: 'COG',
      availability: CountryAvailability.unknown,
    ),
    'CD': CountryInfo(
      code: 'CD',
      alpha3: 'COD',
      availability: CountryAvailability.unknown,
    ),
    'XK': CountryInfo(
      code: 'XK',
      alpha3: 'XKX',
      availability: CountryAvailability.unknown,
      nonIso: true,
    ),
  };
  const names = CountryNames(
    names: {
      'VN': 'Việt Nam',
      'JP': 'Nhật Bản',
      'CG': 'Congo',
      'CD': 'Cộng hòa Dân chủ Congo',
      'XK': 'Kosovo',
    },
    english: {
      'VN': 'Vietnam',
      'JP': 'Japan',
      'CG': 'Congo',
      'CD': 'Democratic Republic of the Congo',
    },
    order: ['CD', 'CG', 'VN', 'JP', 'XK'],
    aliases: {
      'JP': ['Nippon'],
    },
  );
  List<String> search(String query, {bool isoOnly = false}) =>
      searchCountryCodes(
        names.order,
        countries: countries,
        names: names,
        query: query,
        isoOnly: isoOnly,
      );

  test('folded local/English names, alpha-2/3 and aliases', () {
    expect(search('VIỆT'), ['VN']);
    expect(search('viet nam'), ['VN']);
    expect(search('Vietnam'), ['VN']);
    expect(search('vnm'), ['VN']);
    expect(search('japan'), ['JP']);
    expect(search('jpn'), ['JP']);
    expect(search('nippon'), ['JP']);
    expect(search('zzz'), isEmpty);
  });
  test(
    'prefix outranks a later word while equal matches retain input order',
    () {
      expect(search('congo'), ['CG', 'CD']);
      expect(search(''), names.order);
      expect(
        searchCountryCodes(
          ['VN', 'JP', 'VN'],
          countries: countries,
          names: names,
        ),
        ['VN', 'JP'],
      );
    },
  );
  test(
    'Community excludes non-ISO XK even when it is a pinned/search result',
    () {
      expect(search('Kosovo'), ['XK']);
      expect(search('Kosovo', isoOnly: true), isEmpty);
      expect(
        searchCountryCodes(
          ['XK'],
          countries: {
            'XK': CountryInfo(
              code: 'XK',
              alpha3: 'XKX',
              availability: CountryAvailability.unknown,
            ),
          },
          names: names,
          isoOnly: true,
        ),
        isEmpty,
      );
    },
  );
}
