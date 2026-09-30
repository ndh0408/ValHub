import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/features/community/data/community_models.dart'
    show kLfgLanguages;
import 'package:valvn/l10n/gen/app_localizations.dart';

void main() {
  test('exactly the 18 VALORANT languages, in table order', () {
    expect(AppLocale.values.map((l) => l.tag).toList(), [
      'ar-AE',
      'de-DE',
      'en-US',
      'es-ES',
      'es-MX',
      'fr-FR',
      'id-ID',
      'it-IT',
      'ja-JP',
      'ko-KR',
      'pl-PL',
      'pt-BR',
      'ru-RU',
      'th-TH',
      'tr-TR',
      'vi-VN',
      'zh-CN',
      'zh-TW',
    ]);
  });

  test('every code that must be unique is unique', () {
    for (final code in <String Function(AppLocale)>[
      (l) => l.tag,
      (l) => l.arbCode,
      (l) => l.flutter.toString(),
      (l) => l.riotStatusCode,
      (l) => l.intlTag,
      (l) => l.nativeName,
      (l) => l.name,
    ]) {
      final all = AppLocale.values.map(code).toList();
      expect(all.toSet().length, all.length, reason: all.toString());
    }
    // Two locales share a code on purpose: es/esMx -> community `es`,
    // zh/zhHant -> ML Kit `zh`.
    expect(
      AppLocale.values.map((l) => l.communityCode).toSet().length,
      lessThan(AppLocale.values.length),
    );
  });

  test('the ARB file name equals the Flutter locale', () {
    for (final l in AppLocale.values) {
      expect(l.flutter.toString(), l.arbCode, reason: l.name);
    }
  });

  test('tag is a language-COUNTRY valorant-api code', () {
    for (final l in AppLocale.values) {
      expect(l.tag, matches(RegExp(r'^[a-z]{2}-[A-Z]{2}$')), reason: l.name);
      expect(l.apiCode, l.tag);
    }
  });

  test('Traditional Chinese keeps its script so gen-l10n picks zh_Hant', () {
    expect(AppLocale.zhHant.flutter.scriptCode, 'Hant');
    expect(AppLocale.zhHant.flutter.languageCode, 'zh');
    expect(AppLocale.zhHant.flutter.countryCode, isNull);
    expect(AppLocale.zh.flutter.scriptCode, isNull);
    expect(AppLocale.esMx.flutter, const Locale('es', 'MX'));
  });

  test('every community code is one the server accepts', () {
    for (final l in AppLocale.values) {
      expect(kLfgLanguages, contains(l.communityCode), reason: l.name);
    }
    expect(AppLocale.esMx.communityCode, 'es');
    expect(AppLocale.zh.communityCode, 'zh-CN');
    expect(AppLocale.zhHant.communityCode, 'zh-TW');
  });

  test('Riot codes follow docs/research/riot-auth.md', () {
    // The 23 documented `ui_locales`; all 18 of ours are among them.
    const supported = {
      'en',
      'cs',
      'de',
      'el',
      'es',
      'es-419',
      'fr',
      'hu',
      'it',
      'ms',
      'pl',
      'pt-BR',
      'ro',
      'ru',
      'tr',
      'ja',
      'ko',
      'id',
      'th',
      'vi',
      'zh-Hans',
      'zh-Hant',
      'ar',
    };
    for (final l in AppLocale.values) {
      expect(supported, contains(l.riotUiLocale), reason: l.name);
      expect(l.riotStatusCode, matches(RegExp(r'^[a-z]{2}_[A-Z]{2}$')));
    }
    expect(AppLocale.esMx.riotUiLocale, 'es-419');
    expect(AppLocale.pt.riotUiLocale, 'pt-BR');
  });

  test('intl has number and date data for every intl tag', () {
    // Also proves the doc's claim that `zh_Hant` has none while `zh_TW` has.
    for (final l in AppLocale.values) {
      expect(NumberFormat.localeExists(l.intlTag), isTrue, reason: l.name);
      expect(DateFormat.localeExists(l.intlTag), isTrue, reason: l.name);
    }
    expect(DateFormat.localeExists('zh_Hant'), isFalse);
  });

  test('only Arabic is right-to-left and it keeps Latin digits', () {
    expect(AppLocale.values.where((l) => l.isRtl), [AppLocale.ar]);
    expect(AppLocale.ar.textDirection, TextDirection.rtl);
    expect(AppLocale.vi.textDirection, TextDirection.ltr);
    expect(AppLocale.ar.intlTag, 'ar');
    expect(AppLocale.ar.regionalFormats, isFalse);
    expect(AppLocale.values.where((l) => !l.regionalFormats), [AppLocale.ar]);
  });

  test('scripts missing from the bundled fonts need a fallback', () {
    // Be Vietnam Pro / Anton cover Latin (incl. Vietnamese) only.
    expect(
      AppLocale.values.where((l) => l.needsFontFallback).map((l) => l.name),
      unorderedEquals(['ar', 'ja', 'ko', 'ru', 'th', 'zh', 'zhHant']),
    );
  });

  test('ML Kit codes are BCP-47 codes with a single Chinese', () {
    for (final l in AppLocale.values) {
      expect(l.mlKitCode, matches(RegExp(r'^[a-z]{2}$')), reason: l.name);
    }
    expect(AppLocale.zh.mlKitCode, AppLocale.zhHant.mlKitCode);
  });

  test('fromTag round-trips the persisted value and rejects the rest', () {
    for (final l in AppLocale.values) {
      expect(AppLocale.fromTag(l.tag), l);
      expect(AppLocale.fromTag(' ${l.tag} '), l);
    }
    for (final bad in [null, '', 'system', 'vi', 'vi_VN', 'VI-vn', 'xx-XX']) {
      expect(AppLocale.fromTag(bad), isNull, reason: '$bad');
    }
  });

  test('fromLocale maps every own Flutter locale back to itself', () {
    for (final l in AppLocale.values) {
      expect(AppLocale.fromLocale(l.flutter), l, reason: l.name);
    }
  });

  test('every generated locale is an AppLocale', () {
    // Catches a mistyped ARB file name (app_pt_BR.arb instead of app_pt.arb).
    final known = AppLocale.values.map((l) => l.flutter).toSet();
    for (final generated in AppLocalizations.supportedLocales) {
      expect(known, contains(generated));
    }
    // The template language is always generated.
    expect(AppLocalizations.supportedLocales, contains(AppLocale.vi.flutter));
  });

  test('shipped mirrors kShippedLocales', () {
    for (final l in AppLocale.values) {
      expect(l.shipped, kShippedLocales.contains(l));
    }
    expect(AppLocale.vi.shipped, isTrue);
    expect(AppLocale.en.shipped, isFalse);
  });
}
