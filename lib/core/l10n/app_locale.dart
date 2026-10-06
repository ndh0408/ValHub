/// The 18 VALORANT languages and everything that differs per language
/// (docs/design/I18N.md 3.7).
///
/// This table is the ONLY place that may hard-code a locale code: Flutter
/// `Locale`, ARB file, valorant-api `language=`, community-server code, Riot
/// `ui_locales` / status code, `intl` tag, text direction, autonym, font
/// fallback and ML Kit code. Everything else derives from it.
library;

import 'dart:ui' show Locale, TextDirection;

/// A language the app can (eventually) be shown in.
///
/// [tag] is the persisted value (`settings.appLocale`) AND the valorant-api
/// `language=` value, so no mapping table is needed for content requests.
///
/// Pseudo-locales (`en_XA`, `ar_XB`) are not values of this enum yet: they are
/// dev/test-only, never persisted and never listed (I18N.md 12.3, decision 8 in
/// 18.3); lane LT adds them together with `l10n_pseudo`.
enum AppLocale {
  ar(
    flutter: Locale('ar'),
    arbCode: 'ar',
    tag: 'ar-AE',
    communityCode: 'ar',
    riotUiLocale: 'ar',
    riotStatusCode: 'ar_AE',
    // `ar_EG` etc. would switch to Arabic-Indic digits: `ar` keeps Latin ones.
    intlTag: 'ar',
    nativeName: 'العربية',
    mlKitCode: 'ar',
    isRtl: true,
    needsFontFallback: true,
    regionalFormats: false,
  ),
  de(
    flutter: Locale('de'),
    arbCode: 'de',
    tag: 'de-DE',
    communityCode: 'de',
    riotUiLocale: 'de',
    riotStatusCode: 'de_DE',
    intlTag: 'de',
    nativeName: 'Deutsch',
    mlKitCode: 'de',
  ),
  en(
    flutter: Locale('en'),
    arbCode: 'en',
    tag: 'en-US',
    communityCode: 'en',
    riotUiLocale: 'en',
    riotStatusCode: 'en_US',
    intlTag: 'en_US',
    nativeName: 'English',
    mlKitCode: 'en',
  ),
  es(
    flutter: Locale('es'),
    arbCode: 'es',
    tag: 'es-ES',
    communityCode: 'es',
    riotUiLocale: 'es',
    riotStatusCode: 'es_ES',
    intlTag: 'es',
    nativeName: 'Español (España)',
    mlKitCode: 'es',
  ),
  esMx(
    flutter: Locale('es', 'MX'),
    arbCode: 'es_MX',
    tag: 'es-MX',
    // The community server only knows `es`.
    communityCode: 'es',
    riotUiLocale: 'es-419',
    riotStatusCode: 'es_MX',
    intlTag: 'es_MX',
    nativeName: 'Español (Latinoamérica)', // l10n-allow: endonym
    mlKitCode: 'es',
  ),
  fr(
    flutter: Locale('fr'),
    arbCode: 'fr',
    tag: 'fr-FR',
    communityCode: 'fr',
    riotUiLocale: 'fr',
    riotStatusCode: 'fr_FR',
    intlTag: 'fr',
    nativeName: 'Français',
    mlKitCode: 'fr',
  ),
  id(
    flutter: Locale('id'),
    arbCode: 'id',
    tag: 'id-ID',
    communityCode: 'id',
    riotUiLocale: 'id',
    riotStatusCode: 'id_ID',
    intlTag: 'id',
    nativeName: 'Bahasa Indonesia',
    mlKitCode: 'id',
  ),
  it(
    flutter: Locale('it'),
    arbCode: 'it',
    tag: 'it-IT',
    communityCode: 'it',
    riotUiLocale: 'it',
    riotStatusCode: 'it_IT',
    intlTag: 'it',
    nativeName: 'Italiano',
    mlKitCode: 'it',
  ),
  ja(
    flutter: Locale('ja'),
    arbCode: 'ja',
    tag: 'ja-JP',
    communityCode: 'ja',
    riotUiLocale: 'ja',
    riotStatusCode: 'ja_JP',
    intlTag: 'ja',
    nativeName: '日本語',
    mlKitCode: 'ja',
    needsFontFallback: true,
  ),
  ko(
    flutter: Locale('ko'),
    arbCode: 'ko',
    tag: 'ko-KR',
    communityCode: 'ko',
    riotUiLocale: 'ko',
    riotStatusCode: 'ko_KR',
    intlTag: 'ko',
    nativeName: '한국어',
    mlKitCode: 'ko',
    needsFontFallback: true,
  ),
  pl(
    flutter: Locale('pl'),
    arbCode: 'pl',
    tag: 'pl-PL',
    communityCode: 'pl',
    riotUiLocale: 'pl',
    riotStatusCode: 'pl_PL',
    intlTag: 'pl',
    nativeName: 'Polski',
    mlKitCode: 'pl',
  ),
  // Brazilian Portuguese only: VALORANT does not offer pt-PT.
  pt(
    flutter: Locale('pt'),
    arbCode: 'pt',
    tag: 'pt-BR',
    communityCode: 'pt',
    riotUiLocale: 'pt-BR',
    riotStatusCode: 'pt_BR',
    intlTag: 'pt_BR',
    nativeName: 'Português (Brasil)', // l10n-allow: endonym
    mlKitCode: 'pt',
  ),
  ru(
    flutter: Locale('ru'),
    arbCode: 'ru',
    tag: 'ru-RU',
    communityCode: 'ru',
    riotUiLocale: 'ru',
    riotStatusCode: 'ru_RU',
    intlTag: 'ru',
    nativeName: 'Русский',
    mlKitCode: 'ru',
    needsFontFallback: true,
  ),
  th(
    flutter: Locale('th'),
    arbCode: 'th',
    tag: 'th-TH',
    communityCode: 'th',
    riotUiLocale: 'th',
    riotStatusCode: 'th_TH',
    intlTag: 'th',
    nativeName: 'ไทย',
    mlKitCode: 'th',
    needsFontFallback: true,
  ),
  tr(
    flutter: Locale('tr'),
    arbCode: 'tr',
    tag: 'tr-TR',
    communityCode: 'tr',
    riotUiLocale: 'tr',
    riotStatusCode: 'tr_TR',
    intlTag: 'tr',
    nativeName: 'Türkçe',
    mlKitCode: 'tr',
  ),
  // The template language: its ARB is the source of truth for every message.
  vi(
    flutter: Locale('vi'),
    arbCode: 'vi',
    tag: 'vi-VN',
    communityCode: 'vi',
    riotUiLocale: 'vi',
    riotStatusCode: 'vi_VN',
    intlTag: 'vi',
    nativeName: 'Tiếng Việt', // l10n-allow: endonym
    mlKitCode: 'vi',
  ),
  // Simplified Chinese.
  zh(
    flutter: Locale('zh'),
    arbCode: 'zh',
    tag: 'zh-CN',
    communityCode: 'zh-CN',
    riotUiLocale: 'zh-Hans',
    riotStatusCode: 'zh_CN',
    intlTag: 'zh_CN',
    nativeName: '简体中文',
    // ML Kit has a single Chinese, shared with `zhHant` (V8, verified in W5).
    mlKitCode: 'zh',
    needsFontFallback: true,
  ),
  // Traditional Chinese. Built with `fromSubtags`: gen-l10n's
  // `lookupAppLocalizations` picks the `zh_Hant` class only when the script is
  // explicit.
  zhHant(
    flutter: Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    arbCode: 'zh_Hant',
    tag: 'zh-TW',
    communityCode: 'zh-TW',
    riotUiLocale: 'zh-Hant',
    riotStatusCode: 'zh_TW',
    // intl has no `zh_Hant` data: Taiwan's is the closest.
    intlTag: 'zh_TW',
    nativeName: '繁體中文',
    mlKitCode: 'zh',
    needsFontFallback: true,
  );

  const AppLocale({
    required this.flutter,
    required this.arbCode,
    required this.tag,
    required this.communityCode,
    required this.riotUiLocale,
    required this.riotStatusCode,
    required this.intlTag,
    required this.nativeName,
    required this.mlKitCode,
    this.isRtl = false,
    this.needsFontFallback = false,
    this.regionalFormats = true,
  });

  /// The Flutter locale handed to `MaterialApp.locale` and to
  /// `lookupAppLocalizations`.
  final Locale flutter;

  /// ARB / gen-l10n locale suffix: the file is `lib/l10n/arb/app_<arbCode>.arb`
  /// and equals `flutter.toString()` (`es_MX`, `zh_Hant`).
  final String arbCode;

  /// Persisted value of `settings.appLocale` and the valorant-api `language=`
  /// value (`vi-VN`). Case-sensitive.
  final String tag;

  /// Language code of the community server (`docs/community-api.md`).
  final String communityCode;

  /// Riot login page `ui_locales` value (`docs/research/riot-auth.md`).
  final String riotUiLocale;

  /// Riot platform-status translation locale (`vi_VN`). Format to verify
  /// against the live payload in W5 (I18N.md 11.4, V7).
  final String riotStatusCode;

  /// `intl` locale id used for numbers and dates.
  final String intlTag;

  /// The language's own name, never translated (language picker).
  final String nativeName;

  /// BCP-47 code of the ML Kit `TranslateLanguage` (its `bcpCode`).
  final String mlKitCode;

  /// Right-to-left script.
  final bool isRtl;

  /// The bundled fonts (Be Vietnam Pro, Anton) lack this script: the theme
  /// must add a system font fallback (I18N.md 8.2).
  final bool needsFontFallback;

  /// Whether the device region may refine [intlTag] (`en_GB`, `de_AT`).
  /// False for `ar`, whose regional tags switch to Arabic-Indic digits.
  final bool regionalFormats;

  /// valorant-api `language=` value; same as [tag].
  String get apiCode => tag;

  TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;

  /// Whether users can pick / receive this locale (see [kShippedLocales]).
  bool get shipped => kShippedLocales.contains(this);

  /// The locale whose persisted [tag] is [value] (`vi-VN`), else `null`.
  /// Exact match: tags are written by the app itself.
  static AppLocale? fromTag(String? value) {
    if (value == null) return null;
    final v = value.trim();
    for (final l in values) {
      if (l.tag == v) return l;
    }
    return null;
  }

  /// The app locale that best matches a platform [locale], or `null` when
  /// none of the 18 languages does (`nb`, `hi`, ...). Ignores [kShippedLocales].
  ///
  /// - `zh`: an explicit script decides (`Hant` -> [zhHant], `Hans` -> [zh]);
  ///   without a script Taiwan, Hong Kong and Macau -> [zhHant], else [zh].
  /// - `es`: no country or `ES` -> [es]; every other region (`es-419`,
  ///   `es-US`, `es-MX`, `es-AR`, ...) -> [esMx].
  /// - `pt`: every region -> [pt] (VALORANT only offers Brazilian).
  /// - the legacy Android code `in` is Indonesian (`id`).
  static AppLocale? fromLocale(Locale locale) {
    final lang = switch (locale.languageCode.toLowerCase()) {
      'in' => 'id',
      final c => c,
    };
    final country = locale.countryCode?.toUpperCase();
    final script = locale.scriptCode;
    switch (lang) {
      case 'zh':
        final traditional = script != null && script.isNotEmpty
            ? script == 'Hant'
            : const {'TW', 'HK', 'MO'}.contains(country);
        return traditional ? zhHant : zh;
      case 'es':
        return country == null || country.isEmpty || country == 'ES'
            ? es
            : esMx;
      default:
        for (final l in values) {
          if (l.flutter.languageCode == lang) return l;
        }
        return null;
    }
  }
}

/// Locales users can see: the picker lists exactly these, and locale
/// resolution only ever returns them (I18N.md 3.1 principle 6).
///
/// All 18 VALORANT languages ship (owner decision 07/10/2026): the device
/// language is used when it is one of them, otherwise English. Translations
/// other than Vietnamese are not yet reviewed by native speakers.
const Set<AppLocale> kShippedLocales = {
  AppLocale.ar,
  AppLocale.de,
  AppLocale.en,
  AppLocale.es,
  AppLocale.esMx,
  AppLocale.fr,
  AppLocale.id,
  AppLocale.it,
  AppLocale.ja,
  AppLocale.ko,
  AppLocale.pl,
  AppLocale.pt,
  AppLocale.ru,
  AppLocale.th,
  AppLocale.tr,
  AppLocale.vi,
  AppLocale.zh,
  AppLocale.zhHant,
};

/// The locale to show for the device's preferred [device] locales.
///
/// Walks the list in preference order and returns the first that maps to a
/// [shipped] locale; otherwise English if it is shipped (the product is
/// global), else Vietnamese. `shipped` always contains `en` or `vi`.
AppLocale resolve(
  List<Locale> device, {
  Set<AppLocale> shipped = kShippedLocales,
}) {
  for (final l in device) {
    final m = AppLocale.fromLocale(l);
    if (m != null && shipped.contains(m)) return m;
  }
  return shipped.contains(AppLocale.en) ? AppLocale.en : AppLocale.vi;
}
