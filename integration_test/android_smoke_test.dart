import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/geo/country_picker.dart';
import 'package:valvn/core/geo/country_preference.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/l10n/locale.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/settings/ui/sections/country_section.dart';

// Run only on an isolated emulator. Uses real Android preferences, Keystore,
// notification scheduling and bundled CLDR assets. No Riot login or tokens;
// a passing smoke test is not evidence of live Riot/Community E2E behavior.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'country search, native keyboard, persistence and automatic reset',
    (tester) async {
      await initAppLocale();
      final prefs = await Prefs.create();
      final previousCountry = prefs.getString(CountryPreference.key);
      final previousFilter = prefs.getBool('geo.supportedOnly');
      await prefs.remove(CountryPreference.key);
      addTearDown(() async {
        if (previousCountry == null) {
          await prefs.remove(CountryPreference.key);
        } else {
          await prefs.setString(CountryPreference.key, previousCountry);
        }
        if (previousFilter == null) {
          await prefs.remove('geo.supportedOnly');
        } else {
          await prefs.setBool('geo.supportedOnly', previousFilter);
        }
      });
      final container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          activeAccountProvider.overrideWithValue(null),
          deviceCountryProvider.overrideWithValue('VN'),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: appLocale,
            supportedLocales: const [appLocale],
            localizationsDelegates: appLocalizationsDelegates,
            theme: buildDarkTheme(),
            home: const Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(child: SettingsCountrySection()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Việt Nam'), findsOneWidget);
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      expect(find.byType(CountryPicker), findsOneWidget);
      final search = find.byType(TextField);
      await tester.tap(search);
      await tester.pumpAndSettle();
      await tester.enterText(search, 'japan');
      await tester.pumpAndSettle();
      final japan = find.byKey(const ValueKey('JP'));
      await tester.ensureVisible(japan);
      await tester.tap(japan);
      await tester.pumpAndSettle();
      expect(find.byType(CountryPicker), findsNothing);
      expect(container.read(selectedCountryProvider), 'JP');
      final reloaded = await Prefs.create();
      expect(reloaded.getString(CountryPreference.key), 'JP');
      expect(find.text('Nhật Bản'), findsOneWidget);
      await tester.tap(find.byType(ListTile).last);
      await tester.pumpAndSettle();
      expect(container.read(selectedCountryProvider), 'VN');
      await prefs.reload();
      expect(prefs.getString(CountryPreference.key), isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Android Keystore isolates and erases only the selected secret', (
    tester,
  ) async {
    final secure = FlutterSecureStore();
    final prefix = 'qa.native.${DateTime.now().microsecondsSinceEpoch}';
    final first = '$prefix.a';
    final second = '$prefix.b';
    addTearDown(() async {
      await secure.delete(first);
      await secure.delete(second);
    });
    await secure.write(first, 'synthetic-a');
    await secure.write(second, 'synthetic-b');
    expect(await FlutterSecureStore().read(first), 'synthetic-a');
    await secure.delete(first);
    expect(await secure.containsKey(first), isFalse);
    expect(await secure.read(second), 'synthetic-b');
  });

  testWidgets('native schedules enforce 60 slots and allow replacement', (
    tester,
  ) async {
    await initTimeZone();
    final service = NotificationService();
    await service.init();
    final ids = [for (var i = 0; i < 61; i++) 1900000000 + i];
    addTearDown(() async {
      for (final id in ids) {
        await service.cancel(id);
      }
      await service.dispose();
    });
    expect(
      await service.pendingIds(),
      isEmpty,
      reason: 'This test requires a clean, isolated emulator.',
    );
    Future<void> schedule(int id, String title) => service.scheduleAt(
      id: id,
      at: DateTime.now().add(const Duration(days: 1)),
      title: title,
      body: 'Synthetic QA notification; no real player data.',
      channel: NotificationChannel.storeReset,
      payload: '/store',
    );
    for (final id in ids.take(60)) {
      await schedule(id, 'ValVN native QA');
    }
    expect(await service.pendingIds(), ids.take(60).toSet());
    await schedule(ids.last, 'Must not exceed budget');
    expect((await service.pendingIds()).length, 60);
    expect(await service.pendingIds(), isNot(contains(ids.last)));
    await schedule(ids.first, 'Replacement still works');
    expect(await service.pendingIds(), ids.take(60).toSet());
    for (final id in ids.take(60)) {
      await service.cancel(id);
    }
    expect(await service.pendingIds(), isEmpty);
  });
}
