/// Runtime locale state: the user's choice, the device's locales, the derived
/// UI language and format tag, and the handoff to background isolates
/// (docs/design/I18N.md 6.2, 6.3, 10).
library;

import 'dart:async';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:flutter/widgets.dart'
    show WidgetsBinding, WidgetsBindingObserver;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/prefs.dart';
import '../settings/app_settings.dart';
import '../util/json.dart';
import 'app_locale.dart';
import 'locale_boot.dart';

/// What `main()` decided before the first frame (`L10nBootstrap.load`);
/// overridden there. The default follows the device and persists nothing, so
/// tests and previews need no setup.
final l10nBootProvider = Provider<L10nBoot>(
  (ref) => L10nBoot.system(ref.read(deviceLocalesProvider)),
);

/// The device's preferred locales, most preferred first.
///
/// Read from `WidgetsBinding.instance.platformDispatcher` (NOT
/// `PlatformDispatcher.instance`, so the test binding's `localesTestValue`
/// applies) and refreshed on `didChangeLocales`.
final deviceLocalesProvider =
    NotifierProvider<DeviceLocalesNotifier, List<Locale>>(
      DeviceLocalesNotifier.new,
    );

class DeviceLocalesNotifier extends Notifier<List<Locale>>
    with WidgetsBindingObserver {
  @override
  List<Locale> build() {
    final binding = WidgetsBinding.instance;
    binding.addObserver(this);
    ref.onDispose(() => binding.removeObserver(this));
    return List.unmodifiable(binding.platformDispatcher.locales);
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    final next = WidgetsBinding.instance.platformDispatcher.locales;
    if (!listEquals(state, next)) state = List.unmodifiable(next);
  }
}

/// The device's "24-hour clock" setting (raw: `AppFormats` decides where a
/// language overrides it, e.g. Vietnamese is always 24 h).
final use24hProvider = NotifierProvider<Use24hNotifier, bool>(
  Use24hNotifier.new,
);

class Use24hNotifier extends Notifier<bool> with WidgetsBindingObserver {
  @override
  bool build() {
    final binding = WidgetsBinding.instance;
    binding.addObserver(this);
    ref.onDispose(() => binding.removeObserver(this));
    return binding.platformDispatcher.alwaysUse24HourFormat;
  }

  // There is no dedicated callback: `MediaQuery` refreshes
  // `alwaysUse24HourFormat` from the same platform-configuration callbacks
  // that follow, so re-reading on each of them tracks it exactly.
  void _refresh() {
    final next =
        WidgetsBinding.instance.platformDispatcher.alwaysUse24HourFormat;
    if (state != next) state = next;
  }

  @override
  void didChangeMetrics() => _refresh();

  @override
  void didChangeTextScaleFactor() => _refresh();

  @override
  void didChangePlatformBrightness() => _refresh();

  @override
  void didChangeAccessibilityFeatures() => _refresh();

  @override
  void didChangeLocales(List<Locale>? locales) => _refresh();
}

/// The user's language setting: follow the device or a fixed locale.
///
/// Starts from the persisted value `main()` loaded ([l10nBootProvider]).
final localeControllerProvider =
    NotifierProvider<LocaleController, LocaleChoice>(LocaleController.new);

class LocaleController extends Notifier<LocaleChoice> {
  Future<void> _writes = Future.value();
  late LocaleChoice _committed;
  @override
  LocaleChoice build() => _committed = ref.read(l10nBootProvider).choice;

  /// Switches the language and persists the choice.
  ///
  /// W5 (I18N.md 6.5) adds the rest of the switch procedure: content reload,
  /// notification channels and store-reset reminder, screen-reader
  /// announcement.
  Future<void> set(LocaleChoice choice) {
    if (choice == state) return _writes;
    final prefs = ref.read(prefsProvider);
    state = choice;
    final task = _writes.then((_) async {
      try {
        await prefs.setString(PrefKeys.appLocale, choice.raw);
        _committed = choice;
      } on Object {
        if (ref.mounted && state == choice) state = _committed;
        rethrow;
      }
    });
    _writes = task.catchError((Object _) {});
    return task;
  }
}

/// The language the UI is shown in: the chosen locale while it is shipped,
/// else the device's resolution ([resolveChoice]). Watch it; never cache the
/// result.
final appLocaleProvider = Provider<AppLocale>(
  (ref) => resolveChoice(
    ref.watch(localeControllerProvider),
    ref.watch(deviceLocalesProvider),
  ),
);

/// The `intl` locale id for numbers and dates ([resolveFormatTag]).
final formatTagProvider = Provider<String>(
  (ref) => resolveFormatTag(
    ref.watch(appLocaleProvider),
    ref.watch(deviceLocalesProvider),
  ),
);

/// Independent item-name language, including unshipped UI languages.
final contentLocaleProvider = Provider<AppLocale>((ref) {
  final choice = ref.watch(appSettingsProvider.select((s) => s.contentLocale));
  return AppLocale.fromTag(choice) ?? ref.watch(appLocaleProvider);
});

/// Everything a background isolate needs to speak the user's language
/// (I18N.md 6.2, 10).
///
/// The UI isolate writes it whenever any part changes; a background isolate
/// reads it through [read] instead of the headless engine's locale, which is
/// unverified and never relied on.
@immutable
final class EffectiveLocale {
  const EffectiveLocale({
    required this.app,
    required this.formatTag,
    required this.h24,
    this._content,
  });

  /// Current schema version of the persisted JSON.
  static const int version = 1;

  /// The UI language.
  final AppLocale app;

  /// `intl` locale id for numbers and dates.
  final String formatTag;

  /// The device's 24-hour clock setting.
  final bool h24;

  final String? _content;

  /// valorant-api `language=` code, independently selected or following UI.
  String get content => _content ?? app.apiCode;

  Map<String, Object?> toJson() => {
    'v': version,
    'app': app.tag,
    'format': formatTag,
    'h24': h24,
    'content': content,
  };

  /// Parses defensively: anything malformed or from a newer schema is `null`
  /// and the reader falls back to `settings.appLocale`.
  static EffectiveLocale? tryParse(Object? json) {
    final m = asMap(json);
    if (m == null || asInt(m['v']) != version) return null;
    final app = AppLocale.fromTag(asString(m['app']));
    final format = asNonEmptyString(m['format']);
    if (app == null || format == null) return null;
    return EffectiveLocale(
      app: app,
      formatTag: format,
      h24: asBool(m['h24']) ?? false,
      content: asNonEmptyString(m['content']),
    );
  }

  /// The handoff persisted in [prefs], or `null` when absent or unreadable.
  static EffectiveLocale? read(Prefs prefs) =>
      tryParse(prefs.getJson(PrefKeys.effectiveLocale));

  Future<void> write(Prefs prefs) =>
      prefs.setJson(PrefKeys.effectiveLocale, toJson());

  @override
  bool operator ==(Object other) =>
      other is EffectiveLocale &&
      other.app == app &&
      other.formatTag == formatTag &&
      other.h24 == h24 &&
      other.content == content;

  @override
  int get hashCode => Object.hash(app, formatTag, h24, content);

  @override
  String toString() =>
      'EffectiveLocale(${app.tag}, $formatTag, h24: $h24, content: $content)';
}

/// The current [EffectiveLocale]. `ValVnApp` listens to it and writes it to
/// the preferences on every change (W5).
final effectiveLocaleProvider = Provider<EffectiveLocale>(
  (ref) => EffectiveLocale(
    app: ref.watch(appLocaleProvider),
    formatTag: ref.watch(formatTagProvider),
    h24: ref.watch(use24hProvider),
    content: ref.watch(contentLocaleProvider).apiCode,
  ),
);
