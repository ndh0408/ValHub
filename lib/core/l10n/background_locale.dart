import 'dart:ui' show Locale;

import '../settings/app_settings.dart';
import '../storage/prefs.dart';
import '../util/json.dart';
import 'app_locale.dart';
import 'formats.dart';
import 'l10n.dart' show AppLocalizations, lookupAppLocalizations;
import 'locale_boot.dart';
import 'locale_controller.dart';

/// Uses the UI's persisted handoff, never the headless engine's device locale.
/// Missing, future-version or corrupt snapshots fall back without writing prefs.
final class BackgroundLocale {
  BackgroundLocale._(this.effective)
    : l10n = lookupAppLocalizations(effective.app.flutter),
      formats = AppFormats.create(
        effective.app,
        effective.formatTag,
        h24: effective.h24,
      );

  factory BackgroundLocale.fromPrefs(Prefs? prefs) {
    final snapshot = prefs == null ? null : EffectiveLocale.read(prefs);
    final app = snapshot != null && kShippedLocales.contains(snapshot.app)
        ? snapshot.app
        : resolveChoice(
            LocaleChoice.parse(prefs?.getString(PrefKeys.appLocale)),
            const [],
          );
    var format = app.intlTag;
    if (snapshot != null && snapshot.app == app) {
      final candidate = snapshot.formatTag;
      final parts = candidate.split('_');
      if (candidate == app.intlTag ||
          (parts.length == 2 &&
              resolveFormatTag(app, [Locale(parts[0], parts[1])]) ==
                  candidate)) {
        format = candidate;
      }
    }
    final content = AppLocale.fromTag(snapshot?.content);
    final settings = prefs == null ? null : readAppSettings(prefs);
    final hasContentChoice =
        asMap(prefs?.getJson(PrefKeys.appSettings))
            ?.containsKey('contentLocale') ??
        false;
    return BackgroundLocale._(
      EffectiveLocale(
        app: app,
        formatTag: format,
        h24: snapshot?.h24 ?? false,
        content: hasContentChoice
            ? settings!.contentLanguage(app).apiCode
            : content != null
            ? content.apiCode
            : settings?.contentLanguage(app).apiCode ?? app.apiCode,
      ),
    );
  }

  final EffectiveLocale effective;
  final AppLocalizations l10n;
  final AppFormats formats;
}
