/// First-frame language decision and the upgrade pin
/// (docs/design/I18N.md 6.4).
///
/// `main()` reads the preferences synchronously BEFORE `runApp`, so the very
/// first frame is already in the right language.
library;

import 'dart:async';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart' show immutable;
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

import '../storage/prefs.dart';
import 'app_locale.dart';
import 'intl_init.dart';

/// Persisted [LocaleChoice] meaning "follow the device language".
const String kLocaleChoiceSystem = 'system';

/// The user's language setting: follow the device, or a fixed [AppLocale].
///
/// Persisted as [raw] under `PrefKeys.appLocale`.
@immutable
final class LocaleChoice {
  /// Follow the device language.
  const LocaleChoice.system() : locale = null;

  /// Always use [locale] (while it is shipped).
  const LocaleChoice.fixed(AppLocale this.locale);

  /// The chosen locale; `null` when following the device.
  final AppLocale? locale;

  bool get isSystem => locale == null;

  /// The persisted value: [kLocaleChoiceSystem] or an [AppLocale.tag].
  String get raw => locale?.tag ?? kLocaleChoiceSystem;

  /// Reads a persisted value. Anything unknown (a newer app version's tag,
  /// corrupt data, `null`) follows the device.
  static LocaleChoice parse(String? raw) {
    final l = AppLocale.fromTag(raw);
    return l == null ? const LocaleChoice.system() : LocaleChoice.fixed(l);
  }

  @override
  bool operator ==(Object other) =>
      other is LocaleChoice && other.locale == locale;

  @override
  int get hashCode => locale.hashCode;

  @override
  String toString() => 'LocaleChoice($raw)';
}

/// The locale shown for [choice] on a device whose preferred locales are
/// [device]: the fixed locale when it is shipped, else the device resolution.
AppLocale resolveChoice(
  LocaleChoice choice,
  List<Locale> device, {
  Set<AppLocale> shipped = kShippedLocales,
}) {
  final fixed = choice.locale;
  if (fixed != null && shipped.contains(fixed)) return fixed;
  return resolve(device, shipped: shipped);
}

/// The `intl` locale id for numbers and dates of [app] on a device whose
/// preferred locales are [device].
///
/// Normally [AppLocale.intlTag]. With [regional] (the default, owner decision
/// 10 in I18N.md 18.3) a device region refines it, so an English app on a
/// British phone formats `en_GB` and a German one in Austria `de_AT`: the
/// device's first locale must map to [app] itself (so a manual `zh` choice on
/// a `zh_TW` phone stays Simplified) and `intl` must have data for
/// `language_COUNTRY`. Locales with [AppLocale.regionalFormats] off (`ar`) and
/// the vast majority of `language_COUNTRY` ids that `intl` lacks (`vi_VN`,
/// `es_AR`, `zh_SG`) keep [AppLocale.intlTag].
String resolveFormatTag(
  AppLocale app,
  List<Locale> device, {
  bool regional = true,
}) {
  if (regional && app.regionalFormats && device.isNotEmpty) {
    final first = device.first;
    final country = first.countryCode?.toUpperCase();
    if (country != null &&
        country.isNotEmpty &&
        AppLocale.fromLocale(first) == app) {
      registerIntlData();
      final candidate = '${app.flutter.languageCode}_$country';
      if (DateFormat.localeExists(candidate) &&
          NumberFormat.localeExists(candidate)) {
        return candidate;
      }
    }
  }
  return app.intlTag;
}

/// What `main()` decided before the first frame; provided through
/// `l10nBootProvider`.
@immutable
final class L10nBoot {
  const L10nBoot({
    required this.choice,
    required this.locale,
    required this.formatTag,
  });

  /// Decision for a device without persisted preferences: follow the device.
  /// The default of `l10nBootProvider` (tests, previews); production
  /// overrides it with [L10nBootstrap.load].
  factory L10nBoot.system(
    List<Locale> device, {
    Set<AppLocale> shipped = kShippedLocales,
  }) {
    final locale = resolve(device, shipped: shipped);
    return L10nBoot(
      choice: const LocaleChoice.system(),
      locale: locale,
      formatTag: resolveFormatTag(locale, device),
    );
  }

  /// The persisted language setting.
  final LocaleChoice choice;

  /// The UI language of the first frame.
  final AppLocale locale;

  /// `intl` locale id of the first frame (see [resolveFormatTag]).
  final String formatTag;
}

/// Reads (and on the very first run decides) the language setting.
abstract final class L10nBootstrap {
  /// Synchronous: [prefs] is a write-through cache.
  ///
  /// When `settings.appLocale` is absent the choice is decided ONCE and
  /// persisted, so a later change of the phone language never re-pins:
  /// - an existing install (install marker, settings or accounts present) is
  ///   pinned to Vietnamese, the only language it ever showed, so upgrading
  ///   never flips an existing user to the phone's English (upgrade pin);
  /// - a fresh install follows the device (`system`).
  ///
  /// Must run BEFORE `_wipeSecretsAfterReinstall` in `main()`: that sets the
  /// install marker, which would make every fresh install look existing.
  static L10nBoot load(
    Prefs prefs,
    List<Locale> deviceLocales, {
    Set<AppLocale> shipped = kShippedLocales,
  }) {
    var raw = prefs.getString(PrefKeys.appLocale);
    if (raw == null) {
      final existing =
          (prefs.getBool(PrefKeys.installMarker) ?? false) ||
          prefs.containsKey(PrefKeys.appSettings) ||
          prefs.containsKey(PrefKeys.accounts);
      raw = existing ? AppLocale.vi.tag : kLocaleChoiceSystem;
      // The cache already serves the new value; a failed disk write only means
      // the decision is taken again on the next launch.
      unawaited(
        prefs.setString(PrefKeys.appLocale, raw).onError<Object>((_, _) {}),
      );
    }
    final choice = LocaleChoice.parse(raw);
    final locale = resolveChoice(choice, deviceLocales, shipped: shipped);
    return L10nBoot(
      choice: choice,
      locale: locale,
      formatTag: resolveFormatTag(locale, deviceLocales),
    );
  }
}
