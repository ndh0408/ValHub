import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/core/config/vp_prices.dart';

void main() {
  final json = {
    'sourceName': 'Nguồn',
    'sourceUrl': 'https://example.vn/gia',
    'updatedAt': '2026-08-07',
    'packages': [
      {'vp': 6550, 'vnd': 1000000},
      {'vp': 52, 'vnd': 10000},
      {'vp': 13250, 'vnd': 2000000},
      {'vp': 0, 'vnd': 1000},
      {'vp': 'x'},
      null,
    ],
  };

  test('parses defensively and sorts by VP', () {
    final t = VpPriceTable.fromJson(json)!;
    expect(t.packages.map((p) => p.vp), [52, 6550, 13250]);
    expect(t.sourceUrl, 'https://example.vn/gia');
    expect(t.updatedAt!.toLocal(), DateTime(2026, 8, 7));
  });

  test('estimates with the best-value package, rounded to 1.000 ₫', () {
    final t = VpPriceTable.fromJson(json)!;
    expect(t.bestValue.vp, 13250);
    // 1775 × 2.000.000 / 13.250 = 267.924,5 → 268.000
    expect(t.estimateVnd(1775), 268000);
    expect(t.estimateVnd(0), isNull);
    expect(t.estimateVnd(-5), isNull);
    expect(t.estimateVnd(1), 1000);
  });

  test('missing or empty table hides the feature', () {
    expect(VpPriceTable.fromJson(null), isNull);
    expect(VpPriceTable.fromJson({'packages': <Object>[]}), isNull);
    expect(RemoteConfig.fromJson(<String, Object>{}).vpPrices, isNull);
  });

  test('remote config parses, merges and round-trips the table', () {
    final c = RemoteConfig.fromJson({'vpPricesVnd': json});
    expect(c.vpPrices!.packages, hasLength(3));
    expect(RemoteConfig.defaults.merge(c).vpPrices, isNotNull);
    expect(c.merge(RemoteConfig.defaults).vpPrices, isNotNull);
    final again = RemoteConfig.fromJson(c.toJson());
    expect(again.vpPrices!.estimateVnd(1775), 268000);
  });
}
