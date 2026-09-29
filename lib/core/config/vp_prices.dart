import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../util/json.dart';

/// One VALORANT Points pack: [vp] (base + bonus) for [price] in the table's
/// currency (major units: 100000 VND, 4.99 USD).
@immutable
class VpPack {
  const VpPack({required this.vp, required this.price});

  final int vp;
  final double price;

  /// Price of one VP with this pack.
  double get pricePerVp => price / vp;

  @override
  bool operator ==(Object other) =>
      other is VpPack && other.vp == vp && other.price == price;

  @override
  int get hashCode => Object.hash(vp, price);
}

final RegExp _currencyCode = RegExp(r'^[A-Z]{3}$');

/// Upper-case ISO 4217 code, or `null` when [value] is not one.
String? normalizeCurrencyCode(Object? value) {
  final s = asString(value)?.trim().toUpperCase();
  return s != null && _currencyCode.hasMatch(s) ? s : null;
}

/// VP packs sold in one country, in its currency. Only used to show an
/// estimate ("≈ 268.000 ₫") next to VP prices.
@immutable
class VpPriceTable {
  const VpPriceTable({
    required this.currency,
    required this.packs,
    this.source,
    this.updated,
  });

  /// Parses `{currency, packs: [{vp, price}], source, updated}`; `null` when
  /// the currency or every pack is unusable.
  static VpPriceTable? fromJson(Object? json) {
    final m = asMap(json);
    if (m == null) return null;
    final currency = normalizeCurrencyCode(m['currency']);
    if (currency == null) return null;
    final packs = <VpPack>[
      for (final p in asMapList(m['packs']))
        if ((asInt(p['vp']) ?? 0) > 0 &&
            (asDouble(p['price']) ?? 0) > 0 &&
            asDouble(p['price'])!.isFinite)
          VpPack(vp: asInt(p['vp'])!, price: asDouble(p['price'])!),
    ]..sort((a, b) => a.vp.compareTo(b.vp));
    if (packs.isEmpty) return null;
    return VpPriceTable(
      currency: currency,
      packs: List.unmodifiable(packs),
      source: asNonEmptyString(m['source']),
      updated: asDateTime(m['updated']),
    );
  }

  /// ISO 4217 code ("VND", "USD").
  final String currency;
  final List<VpPack> packs;

  /// Where the prices come from (URL), when published.
  final String? source;
  final DateTime? updated;

  /// The pack with the lowest price per VP.
  VpPack get bestValue =>
      packs.reduce((a, b) => b.pricePerVp < a.pricePerVp ? b : a);

  /// Price of [vp] at the best-value rate (not rounded), `null` for
  /// non-positive amounts.
  double? estimate(num vp) {
    if (!vp.isFinite || vp <= 0) return null;
    return vp * bestValue.pricePerVp;
  }

  JsonMap toJson() => {
    'currency': currency,
    'packs': [
      for (final p in packs) {'vp': p.vp, 'price': p.price},
    ],
    'source': source,
    'updated': updated?.toIso8601String(),
  };
}

/// Official VP pack prices per country (ISO 3166-1 alpha-2, upper case),
/// from remote config `vpPrices`. Countries are only listed once their
/// prices have been verified from an official or reputable source.
@immutable
class VpPriceCatalog {
  const VpPriceCatalog([this.byCountry = const {}]);

  factory VpPriceCatalog.fromJson(Object? json) {
    final m = asMap(json);
    if (m == null) return const VpPriceCatalog();
    final out = <String, VpPriceTable>{};
    for (final e in m.entries) {
      final country = e.key.trim().toUpperCase();
      if (!RegExp(r'^[A-Z]{2}$').hasMatch(country)) continue;
      final table = VpPriceTable.fromJson(e.value);
      if (table != null) out[country] = table;
    }
    return VpPriceCatalog(Map.unmodifiable(out));
  }

  final Map<String, VpPriceTable> byCountry;

  bool get isEmpty => byCountry.isEmpty;

  /// The table of [country] (any case), if verified.
  VpPriceTable? forCountry(String? country) =>
      country == null ? null : byCountry[country.trim().toUpperCase()];

  /// [other]'s countries win.
  VpPriceCatalog merge(VpPriceCatalog other) =>
      other.isEmpty ? this : VpPriceCatalog({...byCountry, ...other.byCountry});

  JsonMap toJson() => {
    for (final e in byCountry.entries) e.key: e.value.toJson(),
  };
}

/// The user's own pack price ("Giá gói VP của bạn"): [price] in [currency]
/// for [vp]. Lets players anywhere get an estimate from what they really pay.
@immutable
class VpPriceOverride {
  const VpPriceOverride({
    required this.currency,
    required this.vp,
    required this.price,
  });

  static VpPriceOverride? fromJson(Object? json) {
    final m = asMap(json);
    if (m == null) return null;
    final currency = normalizeCurrencyCode(m['currency']);
    final vp = asInt(m['vp']) ?? 0;
    final price = asDouble(m['price']) ?? 0;
    if (currency == null || vp <= 0 || price <= 0 || !price.isFinite) {
      return null;
    }
    return VpPriceOverride(currency: currency, vp: vp, price: price);
  }

  final String currency;
  final int vp;
  final double price;

  VpPriceTable toTable() => VpPriceTable(
    currency: currency,
    packs: [VpPack(vp: vp, price: price)],
  );

  JsonMap toJson() => {'currency': currency, 'vp': vp, 'price': price};

  @override
  bool operator ==(Object other) =>
      other is VpPriceOverride &&
      other.currency == currency &&
      other.vp == vp &&
      other.price == price;

  @override
  int get hashCode => Object.hash(currency, vp, price);
}

/// Rounds an estimate to 3 significant digits, never finer than the
/// currency's minor unit ([minorDigits]): 267924.5 VND → 268000,
/// 16.13 USD → 16.1.
double roundEstimate(double value, {int minorDigits = 2}) {
  if (!value.isFinite || value <= 0) return 0;
  final magnitude = (math.log(value) / math.ln10).floor();
  final step = math.max(
    math.pow(10, magnitude - 2).toDouble(),
    math.pow(10, -minorDigits).toDouble(),
  );
  final rounded = (value / step).round() * step;
  // Trim binary noise (16.100000000000001).
  return double.parse(rounded.toStringAsFixed(math.max(0, minorDigits)));
}

/// Parses a typed price in any common notation: `100.000`, `100 000`,
/// `100,000`, `4,99`, `4.99`, `1.234,56`, `1,234.56`. A lone separator
/// followed by more digits than the currency's [minorDigits] is a thousands
/// separator (`1.000` USD → 1000, `100.000` VND → 100000). `null` when it is
/// not a positive number.
double? parseLocalizedAmount(String input, {int minorDigits = 2}) {
  final s = input.replaceAll(RegExp(r'[\s   ]'), '');
  if (s.isEmpty || !RegExp(r'^[0-9.,]+$').hasMatch(s)) return null;
  final lastComma = s.lastIndexOf(',');
  final lastDot = s.lastIndexOf('.');
  String normalized;
  if (lastComma >= 0 && lastDot >= 0) {
    final decimal = lastComma > lastDot ? ',' : '.';
    final thousands = decimal == ',' ? '.' : ',';
    normalized = s.replaceAll(thousands, '').replaceAll(decimal, '.');
  } else if (lastComma >= 0 || lastDot >= 0) {
    final sep = lastComma >= 0 ? ',' : '.';
    final count = sep.allMatches(s).length;
    final after = s.length - s.lastIndexOf(sep) - 1;
    final isDecimal = count == 1 && after > 0 && after <= minorDigits;
    normalized = isDecimal ? s.replaceAll(sep, '.') : s.replaceAll(sep, '');
  } else {
    normalized = s;
  }
  final value = double.tryParse(normalized);
  return value == null || !value.isFinite || value <= 0 ? null : value;
}
