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
  Future<Prefs> mount(
    WidgetTester tester, {
    bool largeRtl = false,
    CountryPicker picker = const CountryPicker(),
    String? savedCountry,
    ValueChanged<String?>? onPicked,
  }) async {
    final prefs = await createTestPrefs();
    if (savedCountry != null) {
      await prefs.setString(CountryPreference.key, savedCountry);
    }
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
              'XK': CountryInfo(
                code: 'XK',
                alpha3: 'XKX',
                nonIso: true,
                availability: CountryAvailability.unknown,
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
              names: {
                'DE': 'Đức',
                'VN': 'Việt Nam',
                'JP': 'Nhật Bản',
                'XK': 'Kosovo',
              },
              english: {'DE': 'Germany', 'VN': 'Vietnam', 'JP': 'Japan'},
              order: ['DE', 'VN', 'JP', 'XK'],
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
          home: onPicked == null
              ? Scaffold(body: picker)
              : Builder(
                  builder: (context) => Scaffold(
                    body: TextButton(
                      onPressed: () async => onPicked(
                        await showCountrySelection<String>(
                          context,
                          builder: (_, fullHeight) => CountryPicker.community(
                            activity: picker.activity!,
                            onRetryActivity: picker.onRetryActivity,
                            myCountry: picker.myCountry,
                            fullHeight: fullHeight,
                          ),
                        ),
                      ),
                      child: const Text('open'),
                    ),
                  ),
                ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return prefs;
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
      // Rows name the country; the ISO code is not shown.
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('VN')),
          matching: find.text('VN'),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Community pins account country, offers inactive ISO countries and keeps local preference',
    (tester) async {
      String? picked;
      final prefs = await mount(
        tester,
        savedCountry: 'JP',
        onPicked: (value) => picked = value,
        picker: const CountryPicker.community(
          activity: AsyncData([]),
          onRetryActivity: null,
          myCountry: 'VN',
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('country-VN')), findsOneWidget);
      expect(find.byKey(const ValueKey('country-DE')), findsNothing);
      expect(find.byKey(const ValueKey('country-JP')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('country-all')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('country-DE')), findsOneWidget);
      expect(find.byKey(const ValueKey('country-XK')), findsNothing);
      await tester.enterText(find.byType(TextField), 'deu');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('country-DE')));
      await tester.pumpAndSettle();
      expect(picked, 'DE');
      expect(prefs.getString(CountryPreference.key), 'JP');
    },
  );

  testWidgets('Community activity error can retry or use all countries', (
    tester,
  ) async {
    var retried = false;
    await mount(
      tester,
      picker: CountryPicker.community(
        activity: AsyncError(StateError('offline'), StackTrace.empty),
        onRetryActivity: () => retried = true,
      ),
    );
    expect(find.textContaining('Chưa tải được hoạt động'), findsOneWidget);
    await tester.tap(find.text('Thử lại'));
    expect(retried, isTrue);
    await tester.tap(find.byKey(const ValueKey('country-all')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Chưa tải được hoạt động'), findsNothing);
    expect(find.byKey(const ValueKey('country-DE')), findsOneWidget);
  });

  testWidgets('IME keeps last committed results until composition ends', (
    tester,
  ) async {
    await mount(tester);
    final search = find.byType(TextField);
    await tester.enterText(search, 'japan');
    await tester.pumpAndSettle();
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'viet',
        composing: TextRange(start: 0, end: 4),
        selection: TextSelection.collapsed(offset: 4),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('JP')), findsOneWidget);
    expect(find.byKey(const ValueKey('VN')), findsNothing);
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'viet',
        selection: TextSelection.collapsed(offset: 4),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('VN')), findsOneWidget);
    expect(find.byKey(const ValueKey('JP')), findsNothing);
  });

  testWidgets('empty Community search resets filters to all ISO countries', (
    tester,
  ) async {
    await mount(
      tester,
      picker: const CountryPicker.community(
        activity: AsyncData([]),
        onRetryActivity: null,
      ),
    );
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bỏ lọc'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const ValueKey('country-all')))
          .selected,
      isTrue,
    );
    expect(find.byKey(const ValueKey('country-DE')), findsOneWidget);
  });

  testWidgets('short windows open a full page and retain back navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(720, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await mount(
      tester,
      largeRtl: true,
      onPicked: (_) {},
      picker: const CountryPicker.community(
        activity: AsyncData([]),
        onRetryActivity: null,
        myCountry: 'VN',
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<CountryPicker>(find.byType(CountryPicker)).fullHeight,
      isTrue,
    );
    expect(find.byType(BottomSheet), findsNothing);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'result announcements debounce while visual count stays current',
    (tester) async {
      await mount(tester);
      final live = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.liveRegion == true,
      );
      expect(tester.widget<Semantics>(live).properties.label, '3 quốc gia');
      await tester.enterText(find.byType(TextField), 'japan');
      await tester.pump();
      expect(find.text('1 quốc gia'), findsOneWidget);
      expect(tester.widget<Semantics>(live).properties.label, '3 quốc gia');
      await tester.pump(const Duration(milliseconds: 299));
      expect(tester.widget<Semantics>(live).properties.label, '3 quốc gia');
      await tester.pump(const Duration(milliseconds: 1));
      expect(tester.widget<Semantics>(live).properties.label, '1 quốc gia');
    },
  );
}
