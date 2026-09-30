/// `intl` initialisation for the UI isolate and for background isolates
/// (docs/design/I18N.md 6.4, 10).
library;

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

bool _registered = false;

/// Registers `intl`'s bundled number and date data for EVERY locale.
///
/// Idempotent and synchronous in effect: the bundled data is compiled in, and
/// `initializeDateFormatting` ignores its arguments and returns an already
/// completed future. Safe to call before [initIntl], e.g. to ask
/// `DateFormat.localeExists` while choosing a regional format tag.
void registerIntlData() {
  if (_registered) return;
  _registered = true;
  initializeDateFormatting().ignore();
}

/// Registers the data and makes [tag] (an `intl` locale id such as `vi`,
/// `en_GB`) `Intl.defaultLocale`.
///
/// Call once in `main()` after `L10nBootstrap.load`, and at the start of every
/// background isolate: `GlobalMaterialLocalizations` only initialises the UI
/// isolate.
Future<void> initIntl(String tag) async {
  registerIntlData();
  Intl.defaultLocale = tag;
}
