import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/l10n/formats.dart';

import 'test_locale.dart';

export 'test_locale.dart' show kTestLocaleName, parseTestLocale, testLocale;

/// The locale [tl] and [testL10nApp] use.
///
/// [testLocale] (the pinned DEVICE locale) while its ARB is generated,
/// otherwise Vietnamese: until `kShippedLocales` grows the app itself is
/// Vietnamese whatever the device says, and W1 scaffolds the other 17 locales.
final Locale testUiLocale =
    AppLocalizations.supportedLocales.contains(testLocale.flutter)
    ? testLocale.flutter
    : AppLocale.vi.flutter;

/// The generated messages under test: `expect(find.text(tl.commonRetry), ...)`
/// instead of a literal, so the assertion follows the ARB.
///
/// The literal `find.text('...')` assertions of older tests stay valid: they
/// run under `vi` (docs/design/I18N.md 12.1).
final AppLocalizations tl = lookupAppLocalizations(testUiLocale);

/// Display formats for the same generated test resources; no global app locale.
final AppFormats tf = AppFormats.create(
  AppLocale.fromLocale(testUiLocale) ?? AppLocale.vi,
  testUiLocale.toString(),
  messages: tl,
);

/// A `MaterialApp` with the app's localization delegates, for new tests.
///
/// Every `MaterialApp` in a test must use [appLocalizationsDelegates]; without
/// it `context.l10n` throws.
Widget testL10nApp(
  Widget home, {
  Locale? locale,
  ThemeMode themeMode = ThemeMode.system,
  ThemeData? theme,
  ThemeData? darkTheme,
  TransitionBuilder? builder,
}) => MaterialApp(
  locale: locale ?? testUiLocale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: appLocalizationsDelegates,
  themeMode: themeMode,
  theme: theme,
  darkTheme: darkTheme,
  builder: builder,
  home: home,
);

/// Pins the DEVICE locale to [testLocale] before every test.
///
/// Called once by `test/flutter_test_config.dart`; tests never call it. It is
/// a `setUp` (not a one-off assignment) because a test that calls
/// `tester.platformDispatcher.clearAllTestValues()` wipes the value for
/// itself, and the next test must start pinned again. The framework's own
/// `TestWidgetsFlutterBinding.reset()` does not touch it
/// (`test/l10n/harness_test.dart`).
void setUpL10nTests() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    binding.platformDispatcher.localesTestValue = [testLocale.flutter];
  });
}
