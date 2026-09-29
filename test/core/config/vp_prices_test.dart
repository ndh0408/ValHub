import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/config/local_price.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/core/config/vp_prices.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/prefs.dart';

import '../../helpers/test_prefs.dart';

void main() {
  final vn = {
    'currency': 'vnd',
    'source': 'https://example.vn/gia',
    'updated': '2026-08-07',
    'packs': [
      {'vp': 6550, 'price': 1000000},
      {'vp': 52, 'price': 10000},
      {'vp': 13250, 'price': 2000000},
      {'vp': 0, 'price': 1000},
      {'vp': 'x'},
      null,
    ],
  };
  final us = {
    'currency': 'USD',
    'packs': [
      {'vp': 475, 'price': 4.99},
      {'vp': 11000, 'price': 99.99},
    ],
  };

  group('VpPriceTable', () {
    test('parses defensively and sorts by VP', () {
      final t = VpPriceTable.fromJson(vn)!;
      expect(t.currency, 'VND');
      expect(t.packs.map((p) => p.vp), [52, 6550, 13250]);
      expect(t.source, 'https://example.vn/gia');
      expect(t.updated!.toLocal(), DateTime(2026, 8, 7));
      expect(t.bestValue.vp, 13250);
    });

    test('rejects a bad currency or no usable pack', () {
      expect(VpPriceTable.fromJson(null), isNull);
      expect(VpPriceTable.fromJson({...vn, 'currency': 'dong'}), isNull);
      expect(
        VpPriceTable.fromJson({'currency': 'USD', 'packs': <Object>[]}),
        isNull,
      );
    });
  });

  group('VpPriceCatalog', () {
    test('keys by upper-case ISO country, skips invalid entries', () {
      final c = VpPriceCatalog.fromJson({
        'vn': vn,
        'US': us,
        'XYZ': us,
        'DE': {'currency': 'EUR'},
      });
      expect(c.byCountry.keys, unorderedEquals(['VN', 'US']));
      expect(c.forCountry('vn')!.currency, 'VND');
      expect(c.forCountry(null), isNull);
      expect(c.forCountry('FR'), isNull);
    });

    test('remote config parses, merges and round-trips', () {
      final c = RemoteConfig.fromJson({
        'vpPrices': {'VN': vn},
      });
      final remote = RemoteConfig.fromJson({
        'vpPrices': {'US': us},
      });
      final merged = c.merge(remote);
      expect(merged.vpPrices.byCountry.keys, unorderedEquals(['VN', 'US']));
      expect(
        c.merge(RemoteConfig.defaults).vpPrices.forCountry('VN'),
        isNotNull,
      );
      final again = RemoteConfig.fromJson(merged.toJson());
      expect(again.vpPrices.forCountry('US')!.packs, hasLength(2));
      expect(
        RemoteConfig.fromJson(<String, Object>{}).vpPrices.isEmpty,
        isTrue,
      );
    });
  });

  group('estimates', () {
    test('best-value rate, 3 significant digits', () {
      final vnd = LocalPrice(
        table: VpPriceTable.fromJson(vn)!,
        source: LocalPriceSource.official,
      );
      // 1775 × 2.000.000 / 13.250 = 267.924,5 → 268.000
      expect(vnd.estimate(1775), 268000);
      expect(vnd.format(1775, locale: 'vi'), '≈ 268.000\u00A0₫');
      expect(vnd.estimate(0), isNull);
      expect(vnd.estimate(-5), isNull);

      final usd = LocalPrice(
        table: VpPriceTable.fromJson(us)!,
        source: LocalPriceSource.official,
      );
      // 1775 × 99.99 / 11000 = 16.134… → 16.1
      expect(usd.estimate(1775), 16.1);
      expect(usd.format(1775, locale: 'en_US'), r'≈ $16.10');
    });

    test('roundEstimate respects the minor unit', () {
      expect(roundEstimate(267924.5, minorDigits: 0), 268000);
      expect(roundEstimate(0.126, minorDigits: 2), 0.13);
      expect(roundEstimate(12.3456, minorDigits: 2), 12.3);
      expect(roundEstimate(0, minorDigits: 2), 0);
    });

    test('parseLocalizedAmount understands common notations', () {
      expect(parseLocalizedAmount('100.000', minorDigits: 0), 100000);
      expect(parseLocalizedAmount('100 000', minorDigits: 0), 100000);
      expect(parseLocalizedAmount('4,99'), 4.99);
      expect(parseLocalizedAmount('4.99'), 4.99);
      expect(parseLocalizedAmount('1.000'), 1000);
      expect(parseLocalizedAmount('1.234,56'), 1234.56);
      expect(parseLocalizedAmount('1,234.56'), 1234.56);
      expect(parseLocalizedAmount('0'), isNull);
      expect(parseLocalizedAmount('abc'), isNull);
      expect(parseLocalizedAmount(''), isNull);
    });
  });

  group('localPriceProvider', () {
    Future<ProviderContainer> container({
      String? country,
      RemoteConfig? config,
    }) async {
      final prefs = await createTestPrefs();
      return ProviderContainer.test(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          deviceCountryProvider.overrideWithValue(country),
          remoteConfigProvider.overrideWithValue(
            config ??
                RemoteConfig.fromJson({
                  'vpPrices': {'VN': vn, 'US': us},
                }),
          ),
        ],
      );
    }

    test('uses the verified table of the device country', () async {
      final c = await container(country: 'US');
      expect(c.read(localPriceProvider)!.currency, 'USD');
      expect(c.read(localPriceProvider)!.country, 'US');
    });

    test('hidden for an unverified country', () async {
      final c = await container(country: 'FR');
      expect(c.read(localPriceProvider), isNull);
    });

    test('the user price wins and is persisted', () async {
      final c = await container(country: 'FR');
      await c
          .read(vpPriceOverrideProvider.notifier)
          .set(const VpPriceOverride(currency: 'EUR', vp: 1000, price: 9.99));
      final price = c.read(localPriceProvider)!;
      expect(price.isUserProvided, isTrue);
      expect(price.currency, 'EUR');
      expect(
        VpPriceOverride.fromJson(
          c.read(prefsProvider).getJson(PrefKeys.vpPriceOverride),
        ),
        const VpPriceOverride(currency: 'EUR', vp: 1000, price: 9.99),
      );
      await c.read(vpPriceOverrideProvider.notifier).clear();
      expect(c.read(localPriceProvider), isNull);
    });

    test('turning estimates off hides them', () async {
      final c = await container(country: 'VN');
      expect(c.read(localPriceProvider), isNotNull);
      await c
          .read(appSettingsProvider.notifier)
          .update((s) => s.copyWith(showPriceEstimate: false));
      expect(c.read(localPriceProvider), isNull);
      expect(c.read(localPriceSourceProvider), isNotNull);
    });
  });
}
