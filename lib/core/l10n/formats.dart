/// Locale-aware numbers, dates, clock and case (docs/design/I18N.md 7).
///
/// [AppFormats] is a plain object of one language, format tag and clock
/// setting: no `BuildContext`, no `MediaQuery`, so it also works in the
/// background isolate. Access it through `context.fmt` (an [AppFormatsScope]
/// above `MaterialApp`, else the ambient `Localizations`), or
/// `ref.watch(formatsProvider)` in providers. Never cache it: a language
/// switch replaces it.
///
/// Vietnamese stays byte-identical to `core/util/format.dart` (dates
/// `dd/MM/yyyy`, clock `HH:mm`, comma decimals, weekday names); every other
/// language uses the CLDR patterns of `intl`, by design.
///
/// Words and game currency labels come from [l10n], including in headless tasks.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/gen/app_localizations.dart';
import '../util/format.dart' show calendarDayDifference, roundToMinute;
import '../util/search_text.dart' show foldForSearch;
import 'app_locale.dart';
import 'intl_init.dart';
import 'locale_boot.dart' show resolveFormatTag;
import 'locale_controller.dart';

/// Left-to-right isolate (U+2066): keeps scores, timers, Riot IDs and amounts
/// in their reading order inside right-to-left text.
final String _lri = String.fromCharCode(0x2066);

/// Pop directional isolate (U+2069).
final String _pdi = String.fromCharCode(0x2069);

@immutable
final class AppFormats {
  AppFormats._(this.locale, this.tag, this.h24, this._messages);

  /// [tag] is an `intl` locale id (`vi`, `en_GB`); [h24] the device's 24-hour
  /// clock setting.
  factory AppFormats.create(
    AppLocale locale,
    String tag, {
    bool h24 = false,
    AppLocalizations? messages,
  }) => AppFormats._(locale, tag, h24, messages);

  final AppLocalizations? _messages;

  /// The formats in effect below [context].
  ///
  /// An [AppFormatsScope] wins. Without one (a bare test harness, a sub-tree)
  /// they derive from the ambient `Localizations` locale and
  /// `MediaQuery.alwaysUse24HourFormat`, both of which register a dependency
  /// so the widget rebuilds when they change. Throws a [FlutterError] when
  /// there is no `Localizations` at all.
  static AppFormats of(BuildContext context) {
    final scoped = AppFormatsScope.maybeOf(context);
    if (scoped != null) return scoped;
    final locale = Localizations.maybeLocaleOf(context);
    if (locale == null) {
      throw FlutterError(
        'AppFormats missing: build under MaterialApp (Localizations) or wrap '
        'the tree in an AppFormatsScope.',
      );
    }
    final app = AppLocale.fromLocale(locale) ?? AppLocale.en;
    final h24 = MediaQuery.maybeAlwaysUse24HourFormatOf(context) ?? false;
    return _memo(app, resolveFormatTag(app, [locale]), h24);
  }

  // A pure function of its inputs, memoised so `context.fmt` in a list row
  // does not rebuild `NumberFormat`/`DateFormat` on every call.
  static final Map<(AppLocale, String, bool), AppFormats> _memoized = {};

  static AppFormats _memo(AppLocale app, String tag, bool h24) => _memoized
      .putIfAbsent((app, tag, h24), () => AppFormats._(app, tag, h24, null));

  /// The UI language.
  final AppLocale locale;

  /// `intl` locale id for numbers and dates.
  final String tag;

  /// The device's 24-hour clock setting (Vietnamese is always 24 h).
  final bool h24;

  /// The generated messages of [locale], for the methods that need words.
  /// Looked up on first use, so an [AppFormats] of a locale without generated
  /// messages (until W1's scaffold) still formats numbers and dates.
  late final AppLocalizations l10n =
      _messages ?? lookupAppLocalizations(locale.flutter);

  bool get _vi => locale == AppLocale.vi;

  // --- numbers -------------------------------------------------------------

  /// `1162500` -> `1.162.500` (vi), `1,162,500` (en). Non-finite -> `0`.
  String number(num value) => _decimal.format(_finite(value));

  String vp(num amount) => bidi('${number(amount)} ${l10n.contentCurrencyVp}');
  String kc(num amount) => bidi('${number(amount)} ${l10n.contentCurrencyKc}');
  String rp(num amount) => bidi('${number(amount)} ${l10n.contentCurrencyRp}');
  String rr(int amount) => bidi(l10n.profileRrValue(number(amount)));
  String estimatedVp(num amount) => bidi(
    '${l10n.commonEstimatePrefix} ${number(amount)} ${l10n.contentCurrencyVp}',
  );

  String estimatedPrice(num amount, String iso) =>
      bidi('${l10n.commonEstimatePrefix} ${currency(amount, iso)}');
  String listJoin(Iterable<String> items) =>
      items.join(l10n.commonListSeparator);

  String inlineFacts(Iterable<String> items) =>
      items.join(l10n.profileSeparator);

  String nonEmptyFacts(Iterable<String> items) =>
      inlineFacts(items.where((item) => item.trim().isNotEmpty));

  String unreadBadge(int count) =>
      count > 99 ? '${number(99)}+' : number(count);

  String sentence(String text) {
    if (text.isEmpty) return text;
    final first = String.fromCharCode(text.runes.first);
    return upper(first) + text.substring(first.length);
  }

  String durationCoarse(Duration duration) {
    if (duration.isNegative) duration = Duration.zero;
    if (duration.inDays >= 1) return l10n.commonDays(duration.inDays);
    if (duration.inHours >= 1) return l10n.commonHours(duration.inHours);
    if (duration.inMinutes >= 1) return l10n.commonMinutes(duration.inMinutes);
    return l10n.commonSeconds(duration.inSeconds);
  }

  /// The language's compact form: `1200000` -> `1.2M` (en). Non-finite -> `0`.
  String compact(num value) => _compact.format(_finite(value));

  /// `+24`, `−17` (U+2212 minus), `0`.
  String signed(int value) {
    if (value > 0) return '+${number(value)}';
    if (value < 0) return '−${number(-value)}';
    return '0';
  }

  /// Fraction to percent: `0.256` -> `26%`, or `25,6%` (vi) / `25.6%` (en)
  /// with one decimal. Non-finite -> `0%`.
  String percent(num fraction, {int decimals = 0}) {
    if (_vi) {
      // The exact algorithm of the old `formatPercent`: keeps Vietnamese
      // byte-identical (rounding of ties included).
      final text = (fraction.isFinite ? fraction * 100 : 0).toStringAsFixed(
        decimals,
      );
      return '${text.replaceAll('.', _decimal.symbols.DECIMAL_SEP)}%';
    }
    return _guardNumber(
      (t) => NumberFormat.decimalPercentPattern(
        locale: t,
        decimalDigits: decimals,
      ),
    ).format(_finite(fraction));
  }

  /// [amount] of [iso] (ISO 4217) in the language's currency format with the
  /// currency's usual decimals: `268000, 'VND'` -> `268.000 ₫` (vi),
  /// `16.1, 'USD'` -> `$16.10` (en_US). Isolated for right-to-left text.
  String currency(num amount, String iso) {
    NumberFormat f;
    try {
      f = NumberFormat.simpleCurrency(locale: tag, name: iso);
    } on Object {
      f = NumberFormat.simpleCurrency(locale: 'en_US', name: iso);
    }
    return bidi(f.format(_finite(amount)));
  }

  /// Decimal digits normally used for [iso] (VND 0, USD 2, JPY 0).
  static int currencyDecimalDigits(String iso) {
    try {
      return NumberFormat.simpleCurrency(
            locale: 'en_US',
            name: iso,
          ).decimalDigits ??
          2;
    } on Object {
      return 2;
    }
  }

  // --- dates and clock (instants are shown in the device time zone) --------

  /// Past activity relative to [now], using device-local calendar days.
  /// Future values read as "just now"; old activity uses the locale's date.
  String relative(DateTime then, DateTime now) {
    final localThen = then.toLocal();
    final localNow = now.toLocal();
    final diff = localNow.difference(localThen);
    if (diff.inMinutes < 1) return l10n.commonJustNow;
    if (diff.inMinutes < 60) return l10n.commonMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.commonHoursAgo(diff.inHours);
    final days = DateTime.utc(localNow.year, localNow.month, localNow.day)
        .difference(
          DateTime.utc(localThen.year, localThen.month, localThen.day),
        )
        .inDays;
    if (days <= 1) return l10n.commonYesterday;
    if (days < 7) return l10n.commonDaysAgo(days);
    return date(localThen);
  }

  /// `22/09/2026` (vi), `9/22/2026` (en_US).
  String date(DateTime d) => _yMd.format(d.toLocal());

  /// `22/09` (vi), `9/22` (en_US).
  String dayMonth(DateTime d) => _md.format(d.toLocal());

  /// `14:05` (vi, always 24 h); other languages use 24 h when the device does
  /// (`14:05`), else their own 12/24 h clock (`2:05 PM`).
  String time(DateTime d) => _time.format(d.toLocal());

  /// Date and time in the language's order: `22/09/2026 14:05` (vi).
  String dateTime(DateTime d) => _dateTime.format(d.toLocal());

  /// `Thứ Hai` (vi), `Monday` (en): the local weekday of [d].
  String weekday(DateTime d) => _weekday.format(d.toLocal());

  /// The language's short weekday: `Mon` (en).
  String weekdayShort(DateTime d) => _weekdayShort.format(d.toLocal());

  /// VI badges retain the compact T2–CN captions; other scripts use CLDR.
  String dayBadge(DateTime d) => _vi
      ? [
          l10n.profileWeekdayShortItem0,
          l10n.profileWeekdayShortItem1,
          l10n.profileWeekdayShortItem2,
          l10n.profileWeekdayShortItem3,
          l10n.profileWeekdayShortItem4,
          l10n.profileWeekdayShortItem5,
          l10n.profileWeekdayShortItem6,
        ][d.toLocal().weekday - 1]
      : weekdayShort(d);

  String deviceTimeZone(Duration offset) {
    final sign = offset.isNegative ? '−' : '+';
    final absolute = offset.abs();
    final minutes = absolute.inMinutes.remainder(60);
    final zone = minutes == 0
        ? 'UTC$sign${absolute.inHours}'
        : 'UTC$sign${absolute.inHours}:${_two(minutes)}';
    return l10n.profileDeviceTimeZone(bidi(zone));
  }

  String weekdayLower(DateTime d) {
    final word = weekday(d);
    if (word.isEmpty || locale == AppLocale.de) return word;
    final first = String.fromCharCode(word.runes.first);
    return lower(first) + word.substring(first.length);
  }

  String weekdayDate(DateTime d) => '${weekday(d)}, ${dayMonth(d)}';

  /// Calendar-day grouping, independent of DST and elapsed 24-hour periods.
  String dayHeader(DateTime d, DateTime now) {
    final days = calendarDayDifference(now.toLocal(), d.toLocal());
    if (days == 0) return l10n.commonToday;
    if (days == 1) return l10n.commonYesterdayTitle;
    return weekdayDate(d);
  }

  String absoluteWall(DateTime at) {
    final local = roundToMinute(at).toLocal();
    return l10n.commonWallTime(
      time(local),
      '${weekdayLower(local)} ${dayMonth(local)}',
    );
  }

  String wallTime(DateTime at, DateTime now) {
    final local = roundToMinute(at).toLocal();
    final days = calendarDayDifference(local, now.toLocal());
    final day = switch (days) {
      0 => l10n.commonTodayLower,
      1 => l10n.commonTomorrow,
      _ => '${weekdayLower(local)} ${dayMonth(local)}',
    };
    return l10n.commonWallTime(time(local), day);
  }

  /// Status events use the same device-local calendar boundary as list headers.
  String statusTime(DateTime at, DateTime now) {
    final local = at.toLocal();
    final days = calendarDayDifference(local, now.toLocal());
    if (days == -1) {
      return l10n.commonWallTime(time(local), l10n.commonYesterday);
    }
    if (days.abs() < 7) return wallTime(local, now);
    return dateTime(local);
  }

  String updatedAt(DateTime at, DateTime now) {
    final sameDay = calendarDayDifference(at.toLocal(), now.toLocal()) == 0;
    return l10n.commonUpdatedAt(
      sameDay ? time(at) : '${time(at)}, ${dayMonth(at)}',
    );
  }

  String countdown(Duration duration) {
    if (duration.isNegative) duration = Duration.zero;
    final clock = countdownClock(duration);
    return duration.inDays > 0
        ? '${l10n.commonDays(duration.inDays)} $clock'
        : clock;
  }

  /// `11:54:37`: the clock part of a countdown. Hours wrap at 24; the days
  /// belong to the caller. A negative [d] reads `00:00:00`.
  String countdownClock(Duration d) {
    if (d.isNegative) d = Duration.zero;
    final h = d.inHours.remainder(24);
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${_two(h)}:${_two(m)}:${_two(s)}';
  }

  /// `01:32` (minutes:seconds, minutes padded) or `1:32` when [padMinutes] is
  /// false. Hours fold into minutes. A negative [d] reads `00:00`.
  String minutesSeconds(Duration d, {bool padMinutes = true}) {
    if (d.isNegative) d = Duration.zero;
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '${padMinutes ? _two(m) : '$m'}:${_two(s)}';
  }

  // --- case, direction, order ---------------------------------------------

  /// Upper-cases for display. Turkish maps `i` to `İ`; `ß` becomes `SS` (the
  /// Dart VM's `toUpperCase` leaves `ß` untouched).
  String upper(String s) => locale == AppLocale.tr
      ? s.replaceAll('i', 'İ').toUpperCase()
      : s.replaceAll('ß', 'SS').toUpperCase();

  /// Lower-cases for display. Turkish maps `I` to `ı` and `İ` to `i`.
  String lower(String s) => locale == AppLocale.tr
      ? s.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase()
      : s.toLowerCase();

  /// Title case for ALL-CAPS game data: `KIM CƯƠNG 1` -> `Kim Cương 1`.
  /// Collapses whitespace; a no-op for scripts without case.
  String titleCase(String input) {
    return input
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) {
          final lowered = lower(w);
          final first = String.fromCharCode(lowered.runes.first);
          return upper(first) + lowered.substring(first.length);
        })
        .join(' ');
  }

  /// Keeps a score (`8 - 4`), timer, `Name#TAG` Riot ID or amount in its
  /// reading order inside right-to-left text; unchanged in left-to-right
  /// languages.
  String bidi(String s) => locale.isRtl ? '$_lri$s$_pdi' : s;

  /// A key that sorts names for display: folded like search (accents, case,
  /// width) with the raw name as tie-breaker. Dart has no locale collation;
  /// for ja/zh/ko/th/ar the order is by folded code unit, which is acceptable
  /// because every list also has search.
  String sortKey(String s) => '${foldForSearch(s)}\u0000$s';

  // --- formatters (lazily built, once per instance) -------------------------

  late final NumberFormat _decimal = _guardNumber(NumberFormat.decimalPattern);

  late final NumberFormat _compact = _guardNumber(
    (t) => NumberFormat.compact(locale: t),
  );

  late final DateFormat _yMd = _vi
      ? _guardDate((t) => DateFormat('dd/MM/y', t))
      : _guardDate(DateFormat.yMd);

  late final DateFormat _md = _vi
      ? _guardDate((t) => DateFormat('dd/MM', t))
      : _guardDate(DateFormat.Md);

  late final DateFormat _time = _vi
      ? _guardDate((t) => DateFormat('HH:mm', t))
      : _guardDate(h24 ? DateFormat.Hm : DateFormat.jm);

  late final DateFormat _dateTime = _vi
      ? _guardDate((t) => DateFormat('dd/MM/y HH:mm', t))
      : _guardDate(
          (t) => h24 ? DateFormat.yMd(t).add_Hm() : DateFormat.yMd(t).add_jm(),
        );

  late final DateFormat _weekday = _guardDate(DateFormat.EEEE);

  late final DateFormat _weekdayShort = _guardDate(DateFormat.E);

  /// Falls back to `en_US` when `intl` has no data for [tag].
  NumberFormat _guardNumber(NumberFormat Function(String tag) build) {
    try {
      return build(tag);
    } on Object {
      return build('en_US');
    }
  }

  DateFormat _guardDate(DateFormat Function(String tag) build) {
    registerIntlData();
    try {
      return build(tag);
    } on Object {
      return build('en_US');
    }
  }

  static num _finite(num v) => v.isFinite ? v : 0;

  static String _two(int n) => n.toString().padLeft(2, '0');

  @override
  bool operator ==(Object other) =>
      other is AppFormats &&
      other.locale == locale &&
      other.tag == tag &&
      other.h24 == h24 &&
      other._messages == _messages;

  @override
  int get hashCode => Object.hash(locale, tag, h24, _messages);

  @override
  String toString() => 'AppFormats(${locale.name}, $tag, h24: $h24)';
}

/// Provides [AppFormats] to the tree; placed above `MaterialApp` so dialogs
/// and overlays see it too. `context.fmt` prefers it over the ambient
/// `Localizations`.
class AppFormatsScope extends InheritedWidget {
  const AppFormatsScope({
    super.key,
    required this.formats,
    required super.child,
  });

  final AppFormats formats;

  /// The scope's formats, registering a dependency; `null` without a scope.
  static AppFormats? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppFormatsScope>()?.formats;

  @override
  bool updateShouldNotify(AppFormatsScope oldWidget) =>
      formats != oldWidget.formats;
}

/// The formats of the current language, format tag and clock setting. Watch
/// it; never `read` it, so dependents rebuild on a language change.
final formatsProvider = Provider<AppFormats>(
  (ref) => AppFormats.create(
    ref.watch(appLocaleProvider),
    ref.watch(formatTagProvider),
    h24: ref.watch(use24hProvider),
  ),
);
