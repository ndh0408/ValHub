import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../geo/country_preference.dart';
export '../geo/country_preference.dart' show deviceCountryProvider;
import '../settings/app_settings.dart';
import '../storage/prefs.dart';
import '../util/format.dart';
import '../../l10n/gen/app_localizations.dart';
import 'remote_config.dart';
import 'vp_prices.dart';

/// Where a [LocalPrice] comes from.
enum LocalPriceSource {
  /// The verified pack prices of the device's country (remote config).
  official,

  /// The price the user typed in Settings ("Giá gói VP của bạn").
  user,
}

/// Converts VP amounts to an estimated price in a local currency.
@immutable
class LocalPrice {
  const LocalPrice({required this.table, required this.source, this.country});

  final VpPriceTable table;
  final LocalPriceSource source;

  /// ISO 3166-1 alpha-2 country of an official table.
  final String? country;

  String get currency => table.currency;
  bool get isUserProvided => source == LocalPriceSource.user;

  /// Estimated price of [vp], rounded to 3 significant digits (never finer
  /// than the currency's minor unit); `null` for non-positive amounts.
  double? estimate(num vp) {
    final raw = table.estimate(vp);
    if (raw == null) return null;
    return roundEstimate(raw, minorDigits: currencyDecimalDigits(currency));
  }

  /// `≈ 268.000 ₫` for [vp], or `null`.
  String? format(num vp, {required AppLocalizations messages, String? locale}) {
    final value = estimate(vp);
    return value == null
        ? null
        : formatEstimatedPrice(
            value,
            currency,
            locale: locale,
            messages: messages,
          );
  }

  /// A pack price in this currency: `100.000 ₫`.
  String formatPrice(num price, {String? locale}) =>
      formatCurrency(price, currency, locale: locale);
}

/// The user's own pack price, persisted in prefs.
final vpPriceOverrideProvider =
    NotifierProvider<VpPriceOverrideNotifier, VpPriceOverride?>(
      VpPriceOverrideNotifier.new,
    );

class VpPriceOverrideNotifier extends Notifier<VpPriceOverride?> {
  @override
  VpPriceOverride? build() => VpPriceOverride.fromJson(
    ref.watch(prefsProvider).getJson(PrefKeys.vpPriceOverride),
  );

  Future<void> set(VpPriceOverride value) async {
    state = value;
    await ref
        .read(prefsProvider)
        .setJson(PrefKeys.vpPriceOverride, value.toJson());
  }

  Future<void> clear() async {
    state = null;
    await ref.read(prefsProvider).remove(PrefKeys.vpPriceOverride);
  }
}

/// The price table estimates are computed from, ignoring the "show" switch:
/// the user's own price first, else the verified table of the device's
/// country, else `null`.
final localPriceSourceProvider = Provider<LocalPrice?>((ref) {
  final override = ref.watch(vpPriceOverrideProvider);
  if (override != null) {
    return LocalPrice(table: override.toTable(), source: LocalPriceSource.user);
  }
  final country = ref.watch(selectedCountryProvider);
  final table = ref.watch(
    remoteConfigProvider.select((c) => c.vpPrices.forCountry(country)),
  );
  if (table == null) return null;
  return LocalPrice(
    table: table,
    source: LocalPriceSource.official,
    country: country,
  );
});

/// What the UI shows next to VP prices: [localPriceSourceProvider] unless
/// the user turned the estimates off. `null` hides every estimate.
final localPriceProvider = Provider<LocalPrice?>((ref) {
  final enabled = ref.watch(
    appSettingsProvider.select((s) => s.showPriceEstimate),
  );
  return enabled ? ref.watch(localPriceSourceProvider) : null;
});
