import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/geo/countries.dart';
import 'package:valvn/core/geo/country_picker.dart';
import 'package:valvn/core/geo/country_preference.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/l10n/l10n.dart';

import '../../helpers/test_prefs.dart';

void main() {
  Future<void> mount(WidgetTester tester, {bool largeRtl = false}) async {
    final prefs = await createTestPrefs();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          activeAccountProvider.overrideWithValue(null),
          deviceCountryProvider.overrideWithValue('DE'),
          countriesProvider.overrideWith(
            (ref) async => const {
              'DE': CountryInfo(
                code: 'DE',
                alpha3: 'DEU',
                availability: CountryAvailability.unknown,
                regionHint: 'eu',
              ),
              'VN': CountryInfo(
                code: 'VN',
                alpha3: 'VNM',
                availability: CountryAvailability.available,
                regionHint: 'ap',
              ),
              'JP': CountryInfo(
                code: 'JP',
                alpha3: 'JPN',
                availability: CountryAvailability.available,
                regionHint: 'ap',
              ),
            },
          ),
          countryNamesProvider.overrideWith(
            (ref) async => const CountryNames(
              names: {'DE': 'Đức', 'VN': 'Việt Nam', 'JP': 'Nhật Bản'},
              english: {'DE': 'Germany', 'VN': 'Vietnam', 'JP': 'Japan'},
              order: ['DE', 'VN', 'JP'],
            ),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('vi'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: appLocalizationsDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(largeRtl ? 2 : 1),
              viewInsets: EdgeInsets.only(bottom: largeRtl ? 120 : 0),
            ),
            child: Directionality(
              textDirection: largeRtl ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            ),
          ),
          home: const Scaffold(body: CountryPicker()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'supports English/ISO search and keeps an unknown suggested country selectable',
    (tester) async {
      await mount(tester);
      expect(find.byKey(const ValueKey('DE')), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'vnm');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('VN')), findsOneWidget);
      expect(find.byKey(const ValueKey('DE')), findsNothing);
      await tester.enterText(find.byType(TextField), 'viet nam');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('VN')), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'japan');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('JP')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'scrolls header and rows in RTL landscape with 200 percent text and keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(720, 360);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await mount(tester, largeRtl: true);
      final scrollable = find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('VN')),
        150,
        scrollable: scrollable,
      );
      expect(find.byKey(const ValueKey('VN')), findsOneWidget);
      final iso = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const ValueKey('VN')),
          matching: find.text('VN'),
        ),
      );
      expect(iso.textDirection, TextDirection.ltr);
      expect(tester.takeException(), isNull);
    },
  );
}
