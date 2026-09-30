import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/core/l10n/locale_boot.dart';
import 'package:valvn/core/storage/prefs.dart';

import '../helpers/test_prefs.dart';
import 'resolve_test.dart' show loc;

final _both = {AppLocale.vi, AppLocale.en};

void main() {
  group('L10nBootstrap upgrade pin', () {
    test('a fresh install follows the device and persists that once', () async {
      final prefs = await createTestPrefs();
      final boot = L10nBootstrap.load(prefs, [loc('en-US')], shipped: _both);
      expect(boot.choice, const LocaleChoice.system());
      expect(boot.locale, AppLocale.en);
      expect(prefs.getString(PrefKeys.appLocale), 'system');
    });

    test(
      'while only vi is shipped a fresh install is still Vietnamese',
      () async {
        final prefs = await createTestPrefs();
        final boot = L10nBootstrap.load(prefs, [loc('en-US')]);
        expect(boot.locale, AppLocale.vi);
        expect(boot.choice.isSystem, isTrue);
        expect(prefs.getString(PrefKeys.appLocale), 'system');
      },
    );

    for (final (name, values) in <(String, Map<String, Object>)>[
      ('the install marker', {PrefKeys.installMarker: true}),
      ('saved settings', {PrefKeys.appSettings: '{}'}),
      ('saved accounts', {PrefKeys.accounts: '[]'}),
    ]) {
      test(
        'an existing install ($name) keeps Vietnamese on an English phone',
        () async {
          final prefs = await createTestPrefs(values);
          final boot = L10nBootstrap.load(prefs, [
            loc('en-US'),
          ], shipped: _both);
          expect(boot.choice, LocaleChoice.fixed(AppLocale.vi));
          expect(boot.locale, AppLocale.vi);
          expect(prefs.getString(PrefKeys.appLocale), AppLocale.vi.tag);
        },
      );
    }

    test('the install marker written later does not re-pin a system choice', () async {
      // main(): L10nBootstrap.load runs first; _wipeSecretsAfterReinstall then
      // sets the marker. The next launch must not treat the install as old.
      final prefs = await createTestPrefs();
      L10nBootstrap.load(prefs, [loc('en-US')], shipped: _both);
      await prefs.setBool(PrefKeys.installMarker, true);
      final second = L10nBootstrap.load(prefs, [loc('en-US')], shipped: _both);
      expect(second.choice, const LocaleChoice.system());
      expect(second.locale, AppLocale.en);
      expect(prefs.getString(PrefKeys.appLocale), 'system');
    });

    test('a decided choice is never overwritten', () async {
      final prefs = await createTestPrefs({
        PrefKeys.appLocale: 'de-DE',
        PrefKeys.installMarker: true,
      });
      final boot = L10nBootstrap.load(
        prefs,
        [loc('en-US')],
        shipped: {...AppLocale.values},
      );
      expect(boot.choice, LocaleChoice.fixed(AppLocale.de));
      expect(boot.locale, AppLocale.de);
      expect(prefs.getString(PrefKeys.appLocale), 'de-DE');
    });

    test(
      'a fixed locale that is not shipped resolves like the device',
      () async {
        final prefs = await createTestPrefs({PrefKeys.appLocale: 'ja-JP'});
        final boot = L10nBootstrap.load(prefs, [loc('en-US')], shipped: _both);
        expect(boot.choice, LocaleChoice.fixed(AppLocale.ja));
        expect(boot.locale, AppLocale.en);
        // Kept, so it applies as soon as ja ships.
        expect(prefs.getString(PrefKeys.appLocale), 'ja-JP');
      },
    );

    test(
      'an unknown persisted value follows the device and is left alone',
      () async {
        final prefs = await createTestPrefs({PrefKeys.appLocale: 'xx-XX'});
        final boot = L10nBootstrap.load(prefs, [loc('en-US')], shipped: _both);
        expect(boot.choice, const LocaleChoice.system());
        expect(boot.locale, AppLocale.en);
        expect(prefs.getString(PrefKeys.appLocale), 'xx-XX');
      },
    );

    test('a value of the wrong type counts as undecided', () async {
      final prefs = await createTestPrefs({
        PrefKeys.appLocale: 5,
        PrefKeys.installMarker: true,
      });
      final boot = L10nBootstrap.load(prefs, [loc('en-US')], shipped: _both);
      expect(boot.choice, LocaleChoice.fixed(AppLocale.vi));
      expect(prefs.getString(PrefKeys.appLocale), AppLocale.vi.tag);
    });

    test('the decision is readable synchronously right after load', () async {
      final prefs = await createTestPrefs({PrefKeys.installMarker: true});
      L10nBootstrap.load(prefs, const []);
      expect(prefs.getString(PrefKeys.appLocale), 'vi-VN');
    });
  });

  group('LocaleChoice', () {
    test('parses what it persists', () {
      expect(LocaleChoice.parse('system'), const LocaleChoice.system());
      for (final l in AppLocale.values) {
        final choice = LocaleChoice.fixed(l);
        expect(choice.raw, l.tag);
        expect(LocaleChoice.parse(choice.raw), choice);
        expect(choice.isSystem, isFalse);
      }
      expect(const LocaleChoice.system().raw, kLocaleChoiceSystem);
    });

    test('anything unknown follows the device', () {
      for (final bad in [null, '', 'vi', 'nonsense']) {
        expect(LocaleChoice.parse(bad), const LocaleChoice.system());
      }
    });

    test('value equality', () {
      expect(
        LocaleChoice.fixed(AppLocale.vi),
        LocaleChoice.fixed(AppLocale.vi),
      );
      expect(
        LocaleChoice.fixed(AppLocale.vi),
        isNot(LocaleChoice.fixed(AppLocale.en)),
      );
      expect(
        const LocaleChoice.system(),
        isNot(LocaleChoice.fixed(AppLocale.vi)),
      );
    });
  });

  group('resolveChoice', () {
    test('a shipped fixed locale wins over the device', () {
      expect(
        resolveChoice(LocaleChoice.fixed(AppLocale.vi), [
          loc('ja'),
        ], shipped: _both),
        AppLocale.vi,
      );
    });

    test('system follows the device, fixed-but-unshipped falls back to it', () {
      expect(
        resolveChoice(const LocaleChoice.system(), [
          loc('en-GB'),
        ], shipped: _both),
        AppLocale.en,
      );
      expect(
        resolveChoice(LocaleChoice.fixed(AppLocale.ja), [
          loc('en-GB'),
        ], shipped: _both),
        AppLocale.en,
      );
    });
  });

  group('resolveFormatTag (regional formats, decision 10)', () {
    String tag(AppLocale app, String device, {bool regional = true}) =>
        resolveFormatTag(app, [loc(device)], regional: regional);

    test('the device region refines the language', () {
      expect(tag(AppLocale.en, 'en-GB'), 'en_GB');
      expect(tag(AppLocale.en, 'en-AU'), 'en_AU');
      expect(tag(AppLocale.de, 'de-AT'), 'de_AT');
      expect(tag(AppLocale.pt, 'pt-PT'), 'pt_PT');
      expect(tag(AppLocale.fr, 'fr-CA'), 'fr_CA');
      expect(tag(AppLocale.esMx, 'es-419'), 'es_419');
      expect(tag(AppLocale.esMx, 'es-US'), 'es_US');
      expect(tag(AppLocale.zhHant, 'zh-Hant-HK'), 'zh_HK');
    });

    test('without regional data the language default is used', () {
      // intl has no vi_VN, es_AR, zh_SG, en_001 ...
      expect(tag(AppLocale.vi, 'vi-VN'), 'vi');
      expect(tag(AppLocale.esMx, 'es-AR'), 'es_MX');
      expect(tag(AppLocale.zh, 'zh-Hans-SG'), 'zh_CN');
      expect(tag(AppLocale.en, 'en-001'), 'en_US');
      expect(tag(AppLocale.en, 'en'), 'en_US');
    });

    test('a device in another language does not change the format', () {
      expect(tag(AppLocale.vi, 'en-GB'), 'vi');
      expect(tag(AppLocale.en, 'de-AT'), 'en_US');
    });

    test('a manual choice keeps its own script and region family', () {
      // Simplified Chinese chosen on a Traditional (Taiwan) phone.
      expect(tag(AppLocale.zh, 'zh-TW'), 'zh_CN');
      // Spain Spanish chosen on a Mexican phone.
      expect(tag(AppLocale.es, 'es-MX'), 'es');
    });

    test('Arabic never takes a regional tag (Arabic-Indic digits)', () {
      expect(tag(AppLocale.ar, 'ar-EG'), 'ar');
      expect(tag(AppLocale.ar, 'ar-AE'), 'ar');
    });

    test('the switch can turn regional formats off', () {
      expect(tag(AppLocale.en, 'en-GB', regional: false), 'en_US');
    });

    test('an empty device list uses the language default', () {
      expect(resolveFormatTag(AppLocale.en, const <Locale>[]), 'en_US');
    });
  });

  group('L10nBoot', () {
    test('system() follows the device without persisting anything', () {
      final boot = L10nBoot.system(
        [loc('de-AT')],
        shipped: {...AppLocale.values},
      );
      expect(boot.locale, AppLocale.de);
      expect(boot.formatTag, 'de_AT');
      expect(boot.choice.isSystem, isTrue);
    });

    test('load() carries the format tag of the resolved locale', () async {
      final prefs = await createTestPrefs();
      final boot = L10nBootstrap.load(prefs, [loc('en-GB')], shipped: _both);
      expect(boot.locale, AppLocale.en);
      expect(boot.formatTag, 'en_GB');
    });
  });
}
