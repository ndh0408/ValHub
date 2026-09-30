import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/l10n.dart';

/// V5 (docs/design/I18N.md 18.4): the device-locale pin of
/// `test/flutter_test_config.dart` survives the framework's own resets and is
/// re-applied when a test clears all test values.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final pinned = [testLocale.flutter];

  group('the device locale is pinned for every test', () {
    // The tests below are ORDER DEPENDENT on purpose: one wipes the pin the
    // way a test that calls clearAllTestValues() does, the next proves the
    // per-test setUp pinned it again. `flutter test` runs a file's tests in
    // declaration order.
    test('pinned at the start of a plain test', () {
      expect(binding.platformDispatcher.locales, pinned);
      // What deviceLocalesProvider reads:
      expect(WidgetsBinding.instance.platformDispatcher.locales, pinned);
    });

    test('a test may change and clear the test values (its own business)', () {
      binding.platformDispatcher.localesTestValue = [const Locale('xx')];
      expect(binding.platformDispatcher.locales, [const Locale('xx')]);
      binding.platformDispatcher.clearAllTestValues();
      expect(binding.platformDispatcher.locales, isNot([const Locale('xx')]));
    });

    test('pinned again after a test cleared everything', () {
      expect(binding.platformDispatcher.locales, pinned);
    });

    testWidgets('a widget test starts pinned (reset() does not clear it)', (
      tester,
    ) async {
      // setUp ran before the body, then the framework called
      // TestWidgetsFlutterBinding.reset(): the pin must still be there.
      expect(tester.platformDispatcher.locales, pinned);
    });

    testWidgets('a widget test may clear it too', (tester) async {
      tester.platformDispatcher.localesTestValue = [const Locale('xx')];
      expect(tester.platformDispatcher.locales, [const Locale('xx')]);
      tester.platformDispatcher.clearAllTestValues();
      expect(tester.platformDispatcher.locales, isNot([const Locale('xx')]));
    });

    testWidgets('pinned again after the widget test cleared everything', (
      tester,
    ) async {
      expect(tester.platformDispatcher.locales, pinned);
    });
  });

  group('the pin reaches real widgets', () {
    testWidgets('a MaterialApp without a locale follows the device', (
      tester,
    ) async {
      const supported = [Locale('en', 'US'), Locale('vi')];
      late Locale resolved;
      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: supported,
          // material_ui's only: AppLocalizations has just `vi` until W1, and
          // this test is about the device locale, not about our messages.
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Builder(
            builder: (context) {
              resolved = Localizations.localeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      final device = testLocale.flutter.languageCode;
      final expected = supported.any((l) => l.languageCode == device)
          ? device
          : 'en';
      expect(resolved.languageCode, expected);
    });
  });

  group('TEST_LOCALE parsing', () {
    test('accepts names, tags and ARB codes', () {
      expect(parseTestLocale('vi').tag, 'vi-VN');
      expect(parseTestLocale('en').tag, 'en-US');
      expect(parseTestLocale('en-US').tag, 'en-US');
      expect(parseTestLocale('esMx').tag, 'es-MX');
      expect(parseTestLocale('es_MX').tag, 'es-MX');
      expect(parseTestLocale('zhHant').tag, 'zh-TW');
      expect(parseTestLocale('zh_Hant').tag, 'zh-TW');
    });

    test('rejects anything else with the valid names', () {
      expect(
        () => parseTestLocale('klingon'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('zhHant'),
          ),
        ),
      );
    });

    test('the default is Vietnamese', () {
      // Unless the run was started with --dart-define=TEST_LOCALE=<x>.
      if (kTestLocaleName == 'vi') {
        expect(testLocale.tag, 'vi-VN');
      }
    });
  });
}
