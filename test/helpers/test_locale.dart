import 'package:valvn/core/l10n/app_locale.dart';

/// The `TEST_LOCALE` value: `--dart-define=TEST_LOCALE=en` runs the suite a
/// second time with an English device (docs/design/I18N.md 12.1). Default `vi`.
const String kTestLocaleName = String.fromEnvironment(
  'TEST_LOCALE',
  defaultValue: 'vi',
);

/// The locale the suite pins as the DEVICE locale.
///
/// [kTestLocaleName] may be an [AppLocale.name] (`en`, `esMx`), a persisted tag
/// (`en-US`) or an ARB code (`es_MX`).
final AppLocale testLocale = parseTestLocale(kTestLocaleName);

/// See [kTestLocaleName].
AppLocale parseTestLocale(String value) {
  for (final l in AppLocale.values) {
    if (l.name == value || l.tag == value || l.arbCode == value) return l;
  }
  throw ArgumentError.value(
    value,
    'TEST_LOCALE',
    'expected one of ${AppLocale.values.map((l) => l.name).join(', ')}',
  );
}
