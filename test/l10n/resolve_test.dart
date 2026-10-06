import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/l10n/app_locale.dart';

/// `zh-Hant-TW` -> `Locale.fromSubtags(zh, Hant, TW)`; `es-419` -> country 419.
Locale loc(String tag) {
  final parts = tag.split('-');
  String? script;
  String? country;
  for (final part in parts.skip(1)) {
    if (part.length == 4) {
      script = part;
    } else {
      country = part;
    }
  }
  return Locale.fromSubtags(
    languageCode: parts.first,
    scriptCode: script,
    countryCode: country,
  );
}

final Set<AppLocale> _allShipped = AppLocale.values.toSet();

void main() {
  group('AppLocale.fromLocale / resolve with every locale shipped', () {
    // input -> expected; the table from docs/design/I18N.md 6.1.
    const cases = <String, AppLocale>{
      'zh-Hant-TW': AppLocale.zhHant,
      'zh-TW': AppLocale.zhHant,
      'zh-HK': AppLocale.zhHant,
      'zh-MO': AppLocale.zhHant,
      'zh-Hant': AppLocale.zhHant,
      'zh-Hant-HK': AppLocale.zhHant,
      'zh-Hans-CN': AppLocale.zh,
      'zh-CN': AppLocale.zh,
      'zh-SG': AppLocale.zh,
      'zh': AppLocale.zh,
      // An explicit script beats the region: Simplified in Hong Kong.
      'zh-Hans-HK': AppLocale.zh,
      'es-419': AppLocale.esMx,
      'es-ES': AppLocale.es,
      'es': AppLocale.es,
      'es-US': AppLocale.esMx,
      'es-MX': AppLocale.esMx,
      'es-AR': AppLocale.esMx,
      'in': AppLocale.id,
      'id-ID': AppLocale.id,
      'pt-PT': AppLocale.pt,
      'pt-BR': AppLocale.pt,
      'pt': AppLocale.pt,
      'ar-EG': AppLocale.ar,
      'ar-AE': AppLocale.ar,
      'ar': AppLocale.ar,
      'fr-CA': AppLocale.fr,
      'fr': AppLocale.fr,
      'de-AT': AppLocale.de,
      'de-CH': AppLocale.de,
      'en-GB': AppLocale.en,
      'en-US': AppLocale.en,
      'en': AppLocale.en,
      'it-IT': AppLocale.it,
      'ja-JP': AppLocale.ja,
      'ko-KR': AppLocale.ko,
      'pl-PL': AppLocale.pl,
      'ru-RU': AppLocale.ru,
      'th-TH': AppLocale.th,
      'tr-TR': AppLocale.tr,
      'vi-VN': AppLocale.vi,
      'vi': AppLocale.vi,
    };

    cases.forEach((input, expected) {
      test('$input -> ${expected.name}', () {
        expect(AppLocale.fromLocale(loc(input)), expected);
        expect(resolve([loc(input)], shipped: _allShipped), expected);
      });
    });

    test('language codes are matched case-insensitively', () {
      expect(AppLocale.fromLocale(const Locale('DE', 'de')), AppLocale.de);
    });

    test('unsupported languages match nothing', () {
      for (final tag in ['nb', 'no', 'hi', 'sv', 'nl', 'und', 'he']) {
        expect(AppLocale.fromLocale(loc(tag)), isNull, reason: tag);
      }
    });

    test('an unsupported language resolves to English', () {
      expect(resolve([loc('nb')], shipped: _allShipped), AppLocale.en);
      expect(resolve(const [], shipped: _allShipped), AppLocale.en);
    });
  });

  group('device locale lists', () {
    test('an unsupported first choice continues down the list', () {
      expect(
        resolve([loc('hi'), loc('ja')], shipped: _allShipped),
        AppLocale.ja,
      );
      expect(
        resolve([loc('nb'), loc('sv'), loc('de-AT')], shipped: _allShipped),
        AppLocale.de,
      );
    });

    test('a list with nothing supported ends at English', () {
      expect(resolve([loc('hi')], shipped: _allShipped), AppLocale.en);
    });

    test('the first supported entry wins over later ones', () {
      expect(
        resolve([loc('fr-CA'), loc('ja')], shipped: _allShipped),
        AppLocale.fr,
      );
    });
  });

  group('shipped filter', () {
    test('all 18 VALORANT languages ship', () {
      expect(kShippedLocales, AppLocale.values.toSet());
      expect(
        kShippedLocales.contains(AppLocale.en),
        isTrue,
        reason: 'resolve() falls back to English',
      );
    });

    test('every device gets its own language, anything else English', () {
      for (final (tag, want) in [
        ('en-US', AppLocale.en),
        ('en-GB', AppLocale.en),
        ('ja', AppLocale.ja),
        ('ar-EG', AppLocale.ar),
        ('zh-Hant-TW', AppLocale.zhHant),
        ('zh-CN', AppLocale.zh),
        ('es-419', AppLocale.esMx),
        ('es-ES', AppLocale.es),
        ('pt-PT', AppLocale.pt),
        ('th-TH', AppLocale.th),
        ('nb', AppLocale.en),
        ('vi-VN', AppLocale.vi),
      ]) {
        expect(resolve([loc(tag)]), want, reason: tag);
      }
      expect(resolve(const []), AppLocale.en);
      // The first supported entry of the device list wins.
      expect(resolve([loc('hi'), loc('ja')]), AppLocale.ja);
      expect(resolve([loc('nl'), loc('de')]), AppLocale.de);
    });

    test('a locale that is not shipped is skipped, the next one may win', () {
      final shipped = {AppLocale.vi, AppLocale.de};
      expect(resolve([loc('ja'), loc('de')], shipped: shipped), AppLocale.de);
      expect(resolve([loc('ja')], shipped: shipped), AppLocale.vi);
    });

    test('the fallback is English once en is shipped', () {
      final shipped = {AppLocale.vi, AppLocale.en};
      expect(resolve([loc('hi')], shipped: shipped), AppLocale.en);
      expect(resolve([loc('vi-VN')], shipped: shipped), AppLocale.vi);
      expect(resolve(const [], shipped: shipped), AppLocale.en);
    });
  });
}
