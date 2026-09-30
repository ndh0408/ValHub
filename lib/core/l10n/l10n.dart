/// The public i18n API (docs/design/I18N.md 3.2, 3.6).
///
/// - widgets: `context.l10n.<key>` and `context.fmt`;
/// - providers: `ref.watch(l10nProvider)` / `ref.watch(formatsProvider)`
///   (never `ref.read`, so they follow a language switch);
/// - background isolate: `BackgroundContext.l10n` (wave W2);
/// - tests: `tl` from `test/helpers/l10n.dart`.
///
/// There is deliberately no global "current language" accessor.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' show GlobalMaterialLocalizations;

import '../../l10n/gen/app_localizations.dart';
import 'formats.dart';
import 'locale_controller.dart';

export '../../l10n/gen/app_localizations.dart'
    show AppLocalizations, lookupAppLocalizations;

extension L10nContext on BuildContext {
  /// The generated messages of the ambient locale. Do not cache the result
  /// across a language switch (`static final`, `late final`, `Notifier`
  /// state); hoist it into a local before an `await` instead of touching
  /// `context` afterwards.
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      (throw FlutterError(
        'AppLocalizations missing: build under MaterialApp with '
        'localizationsDelegates: appLocalizationsDelegates, and make sure the '
        'locale is one of AppLocalizations.supportedLocales.',
      ));

  /// Numbers, dates, clock and case in the ambient language
  /// ([AppFormats.of]).
  AppFormats get fmt => AppFormats.of(this);
}

/// The delegates every `MaterialApp` of this app (and of its tests) uses.
///
/// NEVER use `AppLocalizations.localizationsDelegates`: the generated list
/// names the legacy `flutter_localizations` Material delegate, which does not
/// localize `material_ui` widgets (`material_delegate_test` proves it).
/// `GlobalMaterialLocalizations.delegates` is `material_ui`'s and already
/// includes the widgets and Cupertino delegates.
const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

/// The messages of the current UI language for code without a `BuildContext`.
/// Watch it; never `read` it and never keep the result in a `static`, a
/// `late final` or `Notifier` state.
final l10nProvider = Provider<AppLocalizations>(
  (ref) => lookupAppLocalizations(ref.watch(appLocaleProvider).flutter),
);
