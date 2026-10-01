import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/geo/country_preference.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/community/data/community_models.dart';

import '../../helpers/test_prefs.dart';

void main() {
  const account = Account(
    puuid: 'a',
    gameName: 'A',
    tagLine: 'A',
    region: 'ap',
    shard: 'ap',
    country: 'VN',
  );
  test('country choice persists and clears to account then device; routing stays unchanged', () async {
    final prefs = await createTestPrefs();
    final container = ProviderContainer.test(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        deviceCountryProvider.overrideWithValue('US'),
        activeAccountProvider.overrideWithValue(account),
      ],
    );
    expect(container.read(selectedCountryProvider), 'VN');
    await container.read(countryPreferenceProvider.notifier).set('jpn');
    expect(container.read(selectedCountryProvider), 'JP');
    expect(prefs.getString('geo.country'), 'JP');
    expect(container.read(activeAccountProvider)!.region, 'ap');
    expect(container.read(activeAccountProvider)!.country, 'VN');
    await container.read(countryPreferenceProvider.notifier).set('ZZ');
    expect(container.read(selectedCountryProvider), 'JP');
    await container.read(countryPreferenceProvider.notifier).set(null);
    expect(container.read(selectedCountryProvider), 'VN');
    container.updateOverrides([
      prefsProvider.overrideWithValue(prefs),
      deviceCountryProvider.overrideWithValue('US'),
      activeAccountProvider.overrideWithValue(null),
    ]);
    expect(container.read(selectedCountryProvider), 'US');
    expect(prefs.getString('geo.country'), isNull);
  });
  test(
    'stored invalid codes and missing device locale produce unknown',
    () async {
      final prefs = await createTestPrefs();
      await prefs.setString('geo.country', 'invalid');
      final container = ProviderContainer.test(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          deviceCountryProvider.overrideWithValue('ZZ'),
          activeAccountProvider.overrideWithValue(null),
        ],
      );
      expect(container.read(selectedCountryProvider), isNull);
      expect(countryFlag('ZZ'), '');
      expect(countryFlag('vnm'), '🇻🇳');
    },
  );
  test(
    'manual connection override never changes Community matchmaking identity',
    () {
      final manual = account.copyWith(
        regionMode: RegionMode.manual,
        manualRegion: 'eu',
      );
      expect(manual.region, 'eu');
      expect(communityAccountRegion(manual), 'ap');
    },
  );
}
