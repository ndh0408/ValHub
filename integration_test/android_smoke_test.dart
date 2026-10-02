import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/geo/country_picker.dart';
import 'package:valvn/core/geo/country_preference.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/l10n/locale.dart';
import 'package:valvn/l10n/gen/app_localizations_vi.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/settings/ui/sections/country_section.dart';
import 'package:valvn/features/settings/settings_routes.dart';
import 'package:valvn/features/settings/settings_strings.dart';
import 'package:valvn/features/settings/legal/legal_strings.dart';
import 'package:valvn/features/settings/legal/legal_info.dart';

// Run only on an isolated emulator. Uses real Android preferences, Keystore,
// notification scheduling and bundled CLDR assets. No Riot login or tokens;
// a passing smoke test is not evidence of live Riot/Community E2E behavior.
class _ProbeChannelMessages extends AppLocalizationsVi {
  _ProbeChannelMessages() : super('qa');
  @override
  String get notificationChannelStoreResetName => 'ValHub channel QA';
  @override
  String get notificationChannelStoreResetDescription =>
      'Synthetic channel metadata';
}

Future<void> waitForNativeCondition(
  WidgetTester tester,
  bool Function() completed,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!completed() && DateTime.now().isBefore(deadline)) {
    // pumpAndSettle waits for frames, not asynchronous platform disk writes.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await tester.pump();
  }
  expect(completed(), isTrue, reason: 'Native condition did not finish');
}

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
      await waitForNativeCondition(
        tester,
        () => tester.view.viewInsets.bottom > 0,
      );
      // Feed the real controller: tester.enterText uses TestTextInput while
      // this binding leaves the native IME registered. Mixing the two can
      // overwrite the query with a late native editing update.
      tester.widget<TextField>(search).controller!.text = 'japan';
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(search).controller!.text, 'japan');
      final japan = find.byKey(const ValueKey('JP'));
      // The IME reduces the viewport. A lazy sliver result can be below the
      // filter header even when the query is correct; reach it as a user does.
      await tester.scrollUntilVisible(
        japan,
        120,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('country-picker-scroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.ensureVisible(japan);
      await tester.pumpAndSettle();
      await tester.tap(japan);
      await tester.pumpAndSettle();
      await waitForNativeCondition(
        tester,
        () => container.read(selectedCountryProvider) == 'JP',
      );
      expect(find.byType(CountryPicker), findsNothing);
      expect(container.read(selectedCountryProvider), 'JP');
      final reloaded = await Prefs.create();
      expect(reloaded.getString(CountryPreference.key), 'JP');
      expect(find.text('Nhật Bản'), findsOneWidget);
      await tester.tap(find.byType(ListTile).last);
      await tester.pumpAndSettle();
      await waitForNativeCondition(
        tester,
        () => container.read(selectedCountryProvider) == 'VN',
      );
      expect(container.read(selectedCountryProvider), 'VN');
      await prefs.reload();
      expect(prefs.getString(CountryPreference.key), isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Community picker uses bundled names, all countries and separate preference',
    (tester) async {
      await initAppLocale();
      final prefs = await Prefs.create();
      final previous = prefs.getString(CountryPreference.key);
      await prefs.setString(CountryPreference.key, 'JP');
      addTearDown(() async {
        if (previous == null) {
          await prefs.remove(CountryPreference.key);
        } else {
          await prefs.setString(CountryPreference.key, previous);
        }
      });
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      String? picked;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: appLocale,
            supportedLocales: const [appLocale],
            localizationsDelegates: appLocalizationsDelegates,
            theme: buildDarkTheme(),
            home: Builder(
              builder: (context) => Scaffold(
                body: SafeArea(
                  child: TextButton(
                    onPressed: () async =>
                        picked = await showCountrySelection<String>(
                          context,
                          builder: (_, fullHeight) => CountryPicker.community(
                            // Synthetic activity only; this test never calls Community/Riot.
                            activity: const AsyncData([
                              CountryActivity(code: 'US', posts: 2, authors: 1),
                            ]),
                            onRetryActivity: null,
                            myCountry: 'VN',
                            fullHeight: fullHeight,
                          ),
                        ),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('country-VN')), findsOneWidget);
      expect(find.byKey(const ValueKey('country-JP')), findsNothing);
      final search = find.byType(TextField);
      await tester.tap(search);
      tester.widget<TextField>(search).controller!.text = 'hoa ky';
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('country-US')), findsOneWidget);
      tester.widget<TextField>(search).controller!.clear();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('country-all')));
      await tester.pumpAndSettle();
      tester.widget<TextField>(search).controller!.text = 'germany';
      await tester.pumpAndSettle();
      final germany = find.byKey(const ValueKey('country-DE'));
      await tester.ensureVisible(germany);
      await tester.pumpAndSettle();
      await tester.tap(germany);
      await tester.pumpAndSettle();
      expect(picked, 'DE');
      expect(prefs.getString(CountryPreference.key), 'JP');
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

  testWidgets('native channel rename retains ids and existing importance', (
    tester,
  ) async {
    final plugin = FlutterLocalNotificationsPlugin();
    final service = NotificationService(plugin: plugin);
    addTearDown(service.dispose);
    await service.init();
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()!;
    final before = (await android.getNotificationChannels())!;
    final original = before.singleWhere(
      (c) => c.id == NotificationChannel.storeReset.id,
    );
    addTearDown(
      () => service.refreshChannels(lookupAppLocalizations(appLocale)),
    );
    await service.refreshChannels(_ProbeChannelMessages());
    final after = (await android.getNotificationChannels())!;
    final renamed = after.singleWhere((c) => c.id == original.id);
    expect(renamed.name, 'ValHub channel QA');
    expect(renamed.description, 'Synthetic channel metadata');
    expect(renamed.importance, original.importance);
    expect(renamed.playSound, original.playSound);
    expect(renamed.enableVibration, original.enableVibration);
    expect(after.map((c) => c.id).toSet(), before.map((c) => c.id).toSet());
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
      await schedule(id, 'ValHub native QA');
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
  testWidgets('About presents ValHub without the source attribution card', (
    tester,
  ) async {
    await initAppLocale();
    final prefs = await Prefs.create();
    final router = GoRouter(
      initialLocation: SettingsRoutes.about,
      routes: settingsBranchRoutes,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [prefsProvider.overrideWithValue(prefs)],
        child: MaterialApp.router(
          locale: appLocale,
          supportedLocales: const [appLocale],
          localizationsDelegates: appLocalizationsDelegates,
          theme: buildDarkTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, -2400),
      2000,
    );
    await tester.pumpAndSettle();
    expect(find.text(LegalInfo.copyrightNotice), findsOneWidget);
    expect(find.text(SettingsStrings.aboutCreditContent), findsNothing);
    expect(find.text(SettingsStrings.aboutCreditRiot), findsNothing);
    expect(find.text(SettingsStrings.aboutCreditDocs), findsNothing);
    expect(find.text(LegalStrings.creditsHeader), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
