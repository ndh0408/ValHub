import 'package:flutter/foundation.dart';

import '../util/json.dart';

/// One VALORANT Points top-up package sold in Vietnam.
@immutable
class VpPackage {
  const VpPackage({required this.vp, required this.vnd});

  /// Total VP received (base + bonus).
  final int vp;

  /// Price in VND.
  final int vnd;

  /// VND per VP of this package.
  double get rate => vnd / vp;
}

/// Official Vietnamese VP top-up price list, from remote config
/// (`vpPricesVnd`). Used only to show "≈ 268.000 ₫" next to VP prices,
/// always labelled as an estimate. `null` in [RemoteConfig] = hidden.
@immutable
class VpPriceTable {
  const VpPriceTable({
    required this.packages,
    this.sourceName,
    this.sourceUrl,
    this.updatedAt,
  });

  /// Parses `{packages: [{vp, vnd}], sourceName, sourceUrl, updatedAt}`.
  /// Returns `null` when there is no usable package (feature hidden).
  static VpPriceTable? fromJson(Object? json) {
    final m = asMap(json);
    if (m == null) return null;
    final packages = <VpPackage>[
      for (final p in asMapList(m['packages']))
        if ((asInt(p['vp']) ?? 0) > 0 && (asInt(p['vnd']) ?? 0) > 0)
          VpPackage(vp: asInt(p['vp'])!, vnd: asInt(p['vnd'])!),
    ]..sort((a, b) => a.vp.compareTo(b.vp));
    if (packages.isEmpty) return null;
    return VpPriceTable(
      packages: List.unmodifiable(packages),
      sourceName: asNonEmptyString(m['sourceName']),
      sourceUrl: asNonEmptyString(m['sourceUrl']),
      updatedAt: asDateTime(m['updatedAt']),
    );
  }

  final List<VpPackage> packages;
  final String? sourceName;
  final String? sourceUrl;
  final DateTime? updatedAt;

  /// The package with the lowest VND per VP.
  VpPackage get bestValue => packages.reduce((a, b) => b.rate < a.rate ? b : a);

  /// Estimated VND for [vp] at the best-value rate, rounded to the nearest
  /// 1.000 ₫. `null` for non-positive amounts.
  int? estimateVnd(num vp) {
    if (!vp.isFinite || vp <= 0) return null;
    final raw = vp * bestValue.rate;
    final rounded = (raw / 1000).round() * 1000;
    return rounded < 1000 ? 1000 : rounded;
  }

  JsonMap toJson() => {
    'packages': [
      for (final p in packages) {'vp': p.vp, 'vnd': p.vnd},
    ],
    'sourceName': sourceName,
    'sourceUrl': sourceUrl,
    'updatedAt': updatedAt?.toIso8601String(),
  };
}
