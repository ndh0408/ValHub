import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/core/l10n/background_locale.dart';
import 'package:valvn/core/l10n/locale_controller.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/prefs.dart';

import '../helpers/test_prefs.dart';

void main() {
  test(
    'a missing handoff never relies on the headless device locale',
    () async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.localesTestValue = const [Locale('ja')];
      addTearDown(binding.platformDispatcher.clearLocalesTestValue);
      final prefs = await createTestPrefs();
      await prefs.setJson(
        PrefKeys.appSettings,
        const AppSettings(itemLanguage: ItemLanguage.en).toJson(),
      );
      final locale = BackgroundLocale.fromPrefs(prefs);
      // Not the Japanese headless device: the English fallback.
      expect(locale.effective.app, AppLocale.en);
      expect(locale.effective.content, 'en-US');
      expect(locale.formats.number(2175), '2,175');
      expect(prefs.getString(PrefKeys.appLocale), isNull);
      expect(prefs.containsKey(PrefKeys.effectiveLocale), isFalse);
      expect(prefs.containsKey(PrefKeys.installMarker), isFalse);
    },
  );

  test('valid persisted choices survive a headless launch', () async {
    final prefs = await createTestPrefs();
    await const EffectiveLocale(
      app: AppLocale.vi,
      formatTag: 'vi',
      h24: true,
      content: 'en-US',
    ).write(prefs);
    final locale = BackgroundLocale.fromPrefs(prefs);
    expect(locale.effective, EffectiveLocale.read(prefs));
    expect(locale.l10n.commonAppName, 'ValHub');
    expect(locale.formats.h24, isTrue);
    expect(locale.formats.durationCoarse(const Duration(hours: 2)), '2 giờ');
  });

  for (final bad in [
    <String, Object?>{'v': 2, 'app': 'vi-VN', 'format': 'vi'},
    <String, Object?>{'v': 1, 'app': 'unknown', 'format': 'vi'},
    <String, Object?>{'v': 1, 'app': 'vi-VN', 'format': null},
  ]) {
    test('invalid/future snapshot falls back safely: $bad', () async {
      final prefs = await createTestPrefs();
      await prefs.setString(PrefKeys.appLocale, 'vi-VN');
      await prefs.setJson(PrefKeys.effectiveLocale, bad);
      final locale = BackgroundLocale.fromPrefs(prefs);
      expect(locale.effective.app, AppLocale.vi);
      expect(locale.effective.formatTag, 'vi');
      expect(locale.effective.content, 'vi-VN');
      expect(prefs.getJson(PrefKeys.effectiveLocale), bad);
    });
  }

  for (final badFormat in ['en_US', 'vi_invalid', '../../../secret', '']) {
    test(
      'snapshot format is constrained to its UI locale: $badFormat',
      () async {
        final prefs = await createTestPrefs();
        // An unreadable snapshot falls back to the persisted choice.
        await prefs.setString(PrefKeys.appLocale, 'vi-VN');
        await const EffectiveLocale(
          app: AppLocale.vi,
          formatTag: 'vi',
          h24: false,
        ).write(prefs);
        final json = EffectiveLocale.read(prefs)!.toJson();
        json['format'] = badFormat;
        await prefs.setJson(PrefKeys.effectiveLocale, json);
        final locale = BackgroundLocale.fromPrefs(prefs);
        expect(locale.effective.formatTag, 'vi');
        expect(locale.formats.number(2175), '2.175');
      },
    );
  }

  test('a snapshot of a shipped UI language is used as written', () async {
    final prefs = await createTestPrefs();
    await prefs.setString(PrefKeys.appLocale, 'en-US');
    await const EffectiveLocale(
      app: AppLocale.en,
      formatTag: 'en_GB',
      h24: true,
      content: 'ja-JP',
    ).write(prefs);
    final locale = BackgroundLocale.fromPrefs(prefs);
    expect(locale.effective.app, AppLocale.en);
    expect(locale.effective.formatTag, 'en_GB');
    expect(locale.effective.content, 'ja-JP');
    expect(prefs.getString(PrefKeys.appLocale), 'en-US');
  });

  test(
    'unknown content tag falls back to the legacy item-name preference',
    () async {
      final prefs = await createTestPrefs();
      await prefs.setJson(
        PrefKeys.appSettings,
        const AppSettings(itemLanguage: ItemLanguage.en).toJson(),
      );
      await const EffectiveLocale(
        app: AppLocale.vi,
        formatTag: 'vi',
        h24: false,
        content: 'invented-language',
      ).write(prefs);
      expect(BackgroundLocale.fromPrefs(prefs).effective.content, 'en-US');
    },
  );
}
