import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../accounts/account_providers.dart';
import '../l10n/locale.dart';
import '../storage/prefs.dart';
import 'countries.dart';

/// Device locale only; no IP location request. Override in tests where the platform has no country.
final deviceCountryProvider = Provider<String?>(
  (ref) => normalizeCountry(deviceCountryCode()),
);

/// Local preference for names/prices/pre-login hints. Never modifies Riot hosts or Community identity.
final countryPreferenceProvider = NotifierProvider<CountryPreference, String?>(
  CountryPreference.new,
);

class CountryPreference extends Notifier<String?> {
  static const key = 'geo.country';
  @override
  String? build() => normalizeCountry(ref.watch(prefsProvider).getString(key));

  Future<void> set(String? value) async {
    final code = normalizeCountry(value);
    if (value != null && code == null) return;
    final prefs = ref.read(prefsProvider);
    if (code == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, code);
    }
    if (ref.mounted) state = code;
  }
}

/// Explicit choice > authenticated account country > device locale. Country remains separate from region.
final selectedCountryProvider = Provider<String?>(
  (ref) =>
      ref.watch(countryPreferenceProvider) ??
      normalizeCountry(ref.watch(activeAccountProvider)?.country) ??
      normalizeCountry(ref.watch(deviceCountryProvider)),
);

String countryFlag(String? code) {
  final normalized = normalizeCountry(code);
  if (normalized == null) return '';
  return String.fromCharCodes([
    for (final unit in normalized.codeUnits) 0x1F1E6 + unit - 0x41,
  ]);
}
