import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// The only UI locale ValVN ships.
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
