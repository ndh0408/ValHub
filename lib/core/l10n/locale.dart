import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// The only UI locale ValHub ships.
const appLocale = Locale('vi');

/// Locale id used for `intl` formatting.
const appIntlLocale = 'vi';

/// Sets `Intl.defaultLocale` and loads Vietnamese date symbols.
///
/// Call once in `main()` and again at the start of every background isolate
/// (GlobalMaterialLocalizations only initialises the UI isolate).
Future<void> initAppLocale() async {
  Intl.defaultLocale = appIntlLocale;
  await initializeDateFormatting(appIntlLocale);
}

/// Locale id for number / date formatting: the UI locale set in
/// `Intl.defaultLocale` (see [initAppLocale]), else [appIntlLocale].
String currentIntlLocale() => Intl.defaultLocale ?? appIntlLocale;

/// ISO 3166-1 alpha-2 region of the device's primary locale ("VN", "US",
/// "JP"), upper case; `null` when the platform does not report one.
String? deviceCountryCode() {
  final code = PlatformDispatcher.instance.locale.countryCode?.trim();
  return code == null || code.isEmpty ? null : code.toUpperCase();
}
