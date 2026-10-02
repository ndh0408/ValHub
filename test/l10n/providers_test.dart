import 'dart:convert';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/core/l10n/formats.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/l10n/locale_boot.dart';
import 'package:valvn/core/l10n/locale_controller.dart';
import 'package:valvn/core/storage/prefs.dart';

import '../helpers/test_locale.dart';
import '../helpers/test_prefs.dart';

const _viBoot = L10nBoot(
  choice: LocaleChoice.fixed(AppLocale.vi),
  locale: AppLocale.vi,
  formatTag: 'vi',
);

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final dispatcher = binding.platformDispatcher;

  ProviderContainer make([List<Override> overrides = const []]) {
    final c = ProviderContainer(overrides: overrides);
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    // Deterministic clock setting whatever the host says.
    dispatcher.alwaysUse24HourFormatTestValue = false;
    addTearDown(dispatcher.clearAlwaysUse24HourTestValue);
  });

  group(
    'defaults (no overrides): follow the pinned device, stay Vietnamese',
    () {
      test('locale, format tag, messages and formats', () {
        final c = make();
        expect(c.read(deviceLocalesProvider), [testLocale.flutter]);
        // kShippedLocales is {vi}: whatever the device says, the UI is vi.
        expect(c.read(appLocaleProvider), AppLocale.vi);
        expect(c.read(formatTagProvider), 'vi');
        expect(c.read(l10nProvider).localeName, 'vi');
        expect(
          c.read(formatsProvider),
          AppFormats.create(AppLocale.vi, 'vi', h24: false),
        );
        expect(c.read(use24hProvider), isFalse);
        expect(c.read(localeControllerProvider), const LocaleChoice.system());
      });

      test('the default boot persists nothing', () async {
        final prefs = await createTestPrefs();
        final c = make([prefsProvider.overrideWithValue(prefs)]);
        c.read(l10nBootProvider);
        c.read(appLocaleProvider);
        c.read(effectiveLocaleProvider);
        expect(prefs.containsKey(PrefKeys.appLocale), isFalse);
        expect(prefs.containsKey(PrefKeys.effectiveLocale), isFalse);
      });
    },
  );

  group('deviceLocalesProvider', () {
    test('follows the platform locales', () {
      final c = make();
      final seen = <List<Locale>>[];
      final sub = c.listen(deviceLocalesProvider, (_, next) => seen.add(next));
      addTearDown(sub.close);

      dispatcher.localesTestValue = [
        const Locale('en', 'GB'),
        const Locale('de'),
      ];
      expect(c.read(deviceLocalesProvider), [
        const Locale('en', 'GB'),
        const Locale('de'),
      ]);
      expect(seen, hasLength(1));

      // The same list again is not a change.
      dispatcher.localesTestValue = [
        const Locale('en', 'GB'),
        const Locale('de'),
      ];
      expect(seen, hasLength(1));

      dispatcher.localesTestValue = [const Locale('ja')];
      expect(c.read(deviceLocalesProvider), [const Locale('ja')]);
      expect(seen, hasLength(2));
    });

    test('the state cannot be mutated by a consumer', () {
      final c = make();
      expect(
        () => c.read(deviceLocalesProvider).add(const Locale('xx')),
        throwsUnsupportedError,
      );
    });

    test(
      'the UI language stays vi for any device while only vi is shipped',
      () {
        final c = make();
        c.listen(appLocaleProvider, (_, _) {});
        for (final device in [
          [const Locale('en', 'US')],
          [const Locale('ja')],
          [const Locale('ar', 'EG')],
          [const Locale('hi'), const Locale('de')],
          const <Locale>[],
        ]) {
          dispatcher.localesTestValue = device;
          expect(c.read(appLocaleProvider), AppLocale.vi, reason: '$device');
          expect(c.read(formatTagProvider), 'vi', reason: '$device');
          expect(c.read(l10nProvider).localeName, 'vi');
        }
      },
    );
  });

  group('use24hProvider', () {
    test('tracks the device clock setting', () {
      final c = make();
      expect(c.read(use24hProvider), isFalse);
      dispatcher.alwaysUse24HourFormatTestValue = true;
      dispatcher.onMetricsChanged?.call();
      expect(c.read(use24hProvider), isTrue);
      dispatcher.alwaysUse24HourFormatTestValue = false;
      dispatcher.onMetricsChanged?.call();
      expect(c.read(use24hProvider), isFalse);
    });

    test('formatsProvider follows it', () async {
      final c = make();
      final seen = <AppFormats>[];
      final sub = c.listen(formatsProvider, (_, next) => seen.add(next));
      addTearDown(sub.close);
      dispatcher.alwaysUse24HourFormatTestValue = true;
      dispatcher.onMetricsChanged?.call();
      // A derived provider recomputes on the next microtask.
      await pumpEventQueue();
      expect(seen.single, AppFormats.create(AppLocale.vi, 'vi', h24: true));
    });
  });

  group('LocaleController', () {
    test('starts from the boot value', () {
      final c = make([l10nBootProvider.overrideWithValue(_viBoot)]);
      expect(
        c.read(localeControllerProvider),
        const LocaleChoice.fixed(AppLocale.vi),
      );
    });

    test('persists a change and keeps the shipped filter', () async {
      final prefs = await createTestPrefs();
      final c = make([
        prefsProvider.overrideWithValue(prefs),
        l10nBootProvider.overrideWithValue(_viBoot),
      ]);
      c.listen(appLocaleProvider, (_, _) {});
      final controller = c.read(localeControllerProvider.notifier);

      await controller.set(const LocaleChoice.system());
      expect(c.read(localeControllerProvider), const LocaleChoice.system());
      expect(prefs.getString(PrefKeys.appLocale), 'system');

      // Not shipped: stored (it applies once en ships) but the UI stays vi.
      await controller.set(const LocaleChoice.fixed(AppLocale.en));
      expect(
        c.read(localeControllerProvider),
        const LocaleChoice.fixed(AppLocale.en),
      );
      expect(prefs.getString(PrefKeys.appLocale), 'en-US');
      expect(c.read(appLocaleProvider), AppLocale.vi);
    });

    test('setting the current choice writes nothing', () async {
      final prefs = await createTestPrefs({PrefKeys.appLocale: 'sentinel'});
      final c = make([
        prefsProvider.overrideWithValue(prefs),
        l10nBootProvider.overrideWithValue(_viBoot),
      ]);
      await c
          .read(localeControllerProvider.notifier)
          .set(const LocaleChoice.fixed(AppLocale.vi));
      expect(prefs.getString(PrefKeys.appLocale), 'sentinel');
    });
  });

  group('EffectiveLocale (background handoff)', () {
    const sample = EffectiveLocale(
      app: AppLocale.de,
      formatTag: 'de_AT',
      h24: true,
      content: 'en-US',
    );

    test('has the documented JSON shape', () {
      expect(sample.toJson(), {
        'v': 1,
        'app': 'de-DE',
        'format': 'de_AT',
        'h24': true,
        'content': 'en-US',
      });
    });

    test('the content language defaults to the UI language', () {
      const e = EffectiveLocale(app: AppLocale.ja, formatTag: 'ja', h24: false);
      expect(e.content, 'ja-JP');
      expect(e.toJson()['content'], 'ja-JP');
    });

    test('round-trips through the preferences', () async {
      final prefs = await createTestPrefs();
      expect(EffectiveLocale.read(prefs), isNull);
      await sample.write(prefs);
      expect(EffectiveLocale.read(prefs), sample);
      expect(
        prefs.getString(PrefKeys.effectiveLocale),
        contains('"app":"de-DE"'),
      );
    });

    test('a missing or lenient field falls back, a broken one is rejected', () {
      final lenient = EffectiveLocale.tryParse({
        'v': 1,
        'app': 'vi-VN',
        'format': 'vi',
      });
      expect(
        lenient,
        const EffectiveLocale(app: AppLocale.vi, formatTag: 'vi', h24: false),
      );
      expect(lenient!.content, 'vi-VN');
      expect(
        EffectiveLocale.tryParse({
          'v': 1,
          'app': 'vi-VN',
          'format': 'vi',
          'h24': 'true',
        })!.h24,
        isTrue,
      );
      for (final bad in <Object?>[
        null,
        'text',
        5,
        <Object?>[],
        <String, Object?>{},
        {'v': 2, 'app': 'vi-VN', 'format': 'vi'}, // newer schema
        {'v': 1, 'app': 'zz-ZZ', 'format': 'vi'}, // unknown locale
        {'v': 1, 'app': 'vi-VN'}, // no format
        {'v': 1, 'app': 'vi-VN', 'format': '  '},
        {'app': 'vi-VN', 'format': 'vi'}, // no version
      ]) {
        expect(EffectiveLocale.tryParse(bad), isNull, reason: '$bad');
      }
    });

    test('corrupt stored text reads as absent', () async {
      final prefs = await createTestPrefs({
        PrefKeys.effectiveLocale: '<html>oops',
      });
      expect(EffectiveLocale.read(prefs), isNull);
      final json = jsonEncode({'v': 1, 'app': 'vi-VN', 'format': 'vi'});
      await prefs.setString(PrefKeys.effectiveLocale, json);
      expect(EffectiveLocale.read(prefs)?.app, AppLocale.vi);
    });

    test('effectiveLocaleProvider composes the runtime state', () async {
      final prefs = await createTestPrefs();
      final c = make([prefsProvider.overrideWithValue(prefs)]);
      expect(
        c.read(effectiveLocaleProvider),
        const EffectiveLocale(app: AppLocale.vi, formatTag: 'vi', h24: false),
      );
      dispatcher.alwaysUse24HourFormatTestValue = true;
      dispatcher.onMetricsChanged?.call();
      expect(c.read(effectiveLocaleProvider).h24, isTrue);
    });
  });
}
