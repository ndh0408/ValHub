/// Locale-aware formatting helpers (VF §8.0 rules 6–7, SUMMARY §8.8 X9).
///
/// All functions are pure; pass `now` explicitly (from `clockProvider`) so they
/// are testable. Numbers, dates and times take an optional `locale` (an
/// `intl` locale id such as `vi`, `en_US`, `ja`); it defaults to the current
/// UI locale ([currentIntlLocale]). Instants are always shown in the device
/// time zone (`toLocal()`). Relative words ("hôm nay", "3 ngày trước") still
/// come from the Vietnamese string tables until the i18n phase.
library;

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../l10n/common_strings.dart';
import '../l10n/content_strings.dart';
import '../l10n/locale.dart';

final Map<String, NumberFormat> _decimals = {};

String _loc(String? locale) =>
    Intl.canonicalizedLocale(locale ?? currentIntlLocale());

bool _isVi(String locale) => locale == 'vi' || locale.startsWith('vi_');

bool _dateSymbolsReady = false;

/// `DateFormat` for a non-Vietnamese [locale] (date symbols are loaded on
/// first use; the bundled `intl` data covers every VALORANT language).
DateFormat _dateFormat(String locale, DateFormat Function(String l) build) {
  if (!_dateSymbolsReady) {
    _dateSymbolsReady = true;
    // Synchronous for the bundled local data; the future is already done.
    initializeDateFormatting().ignore();
  }
  try {
    return build(locale);
  } on Object {
    return build('en_US');
  }
}

/// `1162500` → `1.162.500` (vi), `1,162,500` (en). Non-finite values
/// format as `0`.
String formatNumber(num value, {String? locale}) {
  final l = _loc(locale);
  final f = _decimals.putIfAbsent(l, () {
    try {
      return NumberFormat.decimalPattern(l);
    } on Object {
      return NumberFormat.decimalPattern('en_US');
    }
  });
  return f.format(value.isFinite ? value : 0);
}

/// [amount] of [currency] (ISO 4217) in the locale's currency format and
/// with the currency's usual decimals: `268000, 'VND'` → `268.000 ₫` (vi),
/// `16.1, 'USD'` → `$16.10` (en_US).
String formatCurrency(num amount, String currency, {String? locale}) {
  final l = _loc(locale);
  NumberFormat f;
  try {
    f = NumberFormat.simpleCurrency(locale: l, name: currency);
  } on Object {
    f = NumberFormat.simpleCurrency(locale: 'en_US', name: currency);
  }
  return f.format(amount.isFinite ? amount : 0);
}

/// Decimal digits normally used for [currency] (VND 0, USD 2, JPY 0).
int currencyDecimalDigits(String currency) {
  try {
    return NumberFormat.simpleCurrency(
          locale: 'en_US',
          name: currency,
        ).decimalDigits ??
        2;
  } on Object {
    return 2;
  }
}

/// A price that is only an estimate: `≈ 268.000 ₫`.
String formatEstimatedPrice(num amount, String currency, {String? locale}) =>
    '${CommonStrings.estimatePrefix} '
    '${formatCurrency(amount, currency, locale: locale)}';

/// `2175` → `2.175 VP`.
String formatVp(num amount) =>
    '${formatNumber(amount)} ${ContentStrings.currencyVp}';

/// `2113` → `2.113 KC`.
String formatKc(num amount) =>
    '${formatNumber(amount)} ${ContentStrings.currencyKc}';

/// `40` → `40 RP`.
String formatRp(num amount) =>
    '${formatNumber(amount)} ${ContentStrings.currencyRp}';

/// Price that is only an estimate: `≈ 2.175 VP`.
String formatEstimatedVp(num amount) =>
    '${CommonStrings.estimatePrefix} ${formatVp(amount)}';

/// `+24 RR`, `−17 RR` (U+2212 minus), `0 RR`.
String formatSignedRr(int rr) => '${formatSigned(rr)} RR';

/// `+24`, `−17` (U+2212 minus), `0`.
String formatSigned(int value) {
  if (value > 0) return '+${formatNumber(value)}';
  if (value < 0) return '−${formatNumber(-value)}';
  return '0';
}

/// Integer percent discount badge: `32` → `-32%`.
String formatDiscountPercent(num percent) => '-${percent.round()}%';

/// Fraction → percent: `0.256` → `26%` (`25,6%` in vi / `25.6%` in en
/// with one decimal).
String formatPercent(num fraction, {int decimals = 0, String? locale}) {
  final value = fraction.isFinite ? fraction * 100 : 0;
  final text = value.toStringAsFixed(decimals);
  final l = _loc(locale);
  String separator;
  try {
    separator = NumberFormat.decimalPattern(l).symbols.DECIMAL_SEP;
  } on Object {
    separator = '.';
  }
  return '${text.replaceAll('.', separator)}%';
}

String _two(int n) => n.toString().padLeft(2, '0');

/// Countdown text (VF §8.0 rule 7):
/// - under a day: `11:54:37`
/// - a day or more: `2 ngày 15:09:24`
/// Negative durations render as `00:00:00`.
String formatCountdown(Duration d) {
  if (d.isNegative) d = Duration.zero;
  final days = d.inDays;
  final h = d.inHours.remainder(24);
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  final clock = '${_two(h)}:${_two(m)}:${_two(s)}';
  return days > 0 ? '${CommonStrings.days(days)} $clock' : clock;
}

/// Short timer: `01:32` (minutes:seconds, minutes padded) or `0:42` when
/// [padMinutes] is false. Hours are folded into minutes.
String formatMinutesSeconds(Duration d, {bool padMinutes = true}) {
  if (d.isNegative) d = Duration.zero;
  final m = d.inMinutes;
  final s = d.inSeconds.remainder(60);
  return '${padMinutes ? _two(m) : '$m'}:${_two(s)}';
}

/// Coarse duration: `38 phút`, `2 giờ`, `5 ngày`.
String formatDurationCoarse(Duration d) {
  if (d.isNegative) d = Duration.zero;
  if (d.inDays >= 1) return CommonStrings.days(d.inDays);
  if (d.inHours >= 1) return CommonStrings.hours(d.inHours);
  if (d.inMinutes >= 1) return CommonStrings.minutes(d.inMinutes);
  return CommonStrings.seconds(d.inSeconds);
}

/// Relative past time: `vừa xong`, `5 phút trước`, `18 giờ trước`, `hôm qua`,
/// `3 ngày trước`, then `22/09/2026`. Future instants read as `vừa xong`.
String formatRelative(DateTime then, DateTime now, {String? locale}) {
  final localThen = then.toLocal();
  final localNow = now.toLocal();
  final diff = localNow.difference(localThen);
  if (diff.inMinutes < 1) return CommonStrings.justNow;
  if (diff.inMinutes < 60) return CommonStrings.minutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return CommonStrings.hoursAgo(diff.inHours);
  final dayDiff = _dateOnly(localNow).difference(_dateOnly(localThen)).inDays;
  if (dayDiff <= 1) return CommonStrings.yesterday;
  if (dayDiff < 7) return CommonStrings.daysAgo(dayDiff);
  return formatDate(localThen, locale: locale);
}

DateTime _dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// Calendar-day distance, independent of a 23/25-hour DST transition.
int calendarDayDifference(DateTime later, DateTime earlier) =>
    _dateOnly(later).difference(_dateOnly(earlier)).inDays;

/// `22/09/2026` (vi), `9/22/2026` (en_US) — device time zone.
String formatDate(DateTime d, {String? locale}) {
  final t = d.toLocal();
  final l = _loc(locale);
  if (_isVi(l)) return '${_two(t.day)}/${_two(t.month)}/${t.year}';
  return _dateFormat(l, DateFormat.yMd).format(t);
}

/// `22/09` (vi), `9/22` (en_US) — device time zone.
String formatDayMonth(DateTime d, {String? locale}) {
  final t = d.toLocal();
  final l = _loc(locale);
  if (_isVi(l)) return '${_two(t.day)}/${_two(t.month)}';
  return _dateFormat(l, DateFormat.Md).format(t);
}

/// `14:05` (vi, 24-hour), `2:05 PM` (en_US) — the locale's clock, device
/// time zone.
String formatTime(DateTime d, {String? locale}) {
  final t = d.toLocal();
  final l = _loc(locale);
  if (_isVi(l)) return '${_two(t.hour)}:${_two(t.minute)}';
  return _dateFormat(l, DateFormat.jm).format(t);
}

/// `22/09/2026 14:05` (device time zone, locale order).
String formatDateTime(DateTime d, {String? locale}) =>
    '${formatDate(d, locale: locale)} ${formatTime(d, locale: locale)}';

/// `Thứ Hai` (vi), `Monday` (en) for the local weekday of [d].
String formatWeekday(DateTime d, {String? locale}) {
  final t = d.toLocal();
  final l = _loc(locale);
  if (_isVi(l)) return CommonStrings.weekdays[t.weekday - 1];
  return _dateFormat(l, DateFormat.EEEE).format(t);
}

/// `Thứ Hai, 22/09` (device time zone).
String formatWeekdayDate(DateTime d, {String? locale}) =>
    '${formatWeekday(d, locale: locale)}, '
    '${formatDayMonth(d, locale: locale)}';

/// [d] rounded to the nearest minute (half up). Countdowns count down to
/// 06:59:41 when the store resets at 07:00:00 (the remaining seconds are
/// received a moment late), so reset / expiry times are shown rounded.
DateTime roundToMinute(DateTime d) {
  final ms = (d.millisecondsSinceEpoch + 30000) ~/ 60000 * 60000;
  return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: d.isUtc);
}

/// Wall-clock moment of a reset or expiry in the device time zone, with the
/// locale's clock: `07:00 hôm nay`, `07:00 ngày mai`, else
/// `23:59 thứ Hai 06/10`.
String formatWallTime(DateTime at, DateTime now, {String? locale}) {
  final t = roundToMinute(at).toLocal();
  final dayDiff = _dateOnly(t).difference(_dateOnly(now.toLocal())).inDays;
  final String day;
  if (dayDiff == 0) {
    day = CommonStrings.todayLower;
  } else if (dayDiff == 1) {
    day = CommonStrings.tomorrow;
  } else {
    day =
        '${formatWeekdayLower(t, locale: locale)} '
        '${formatDayMonth(t, locale: locale)}';
  }
  return CommonStrings.wallTime(formatTime(t, locale: locale), day);
}

/// `thứ Hai`, `chủ Nhật` — the weekday written mid-sentence (the first
/// letter lower-cased where the language capitalises weekdays).
String formatWeekdayLower(DateTime d, {String? locale}) {
  final w = formatWeekday(d, locale: locale);
  if (w.isEmpty) return w;
  final l = _loc(locale);
  // German capitalises nouns, weekdays included.
  if (l.startsWith('de')) return w;
  return w[0].toLowerCase() + w.substring(1);
}

/// Day header for grouped lists: `Hôm nay`, `Hôm qua`, else
/// `Thứ Hai, 22/09` (VF S42).
String formatDayHeader(DateTime d, DateTime now, {String? locale}) {
  final dayDiff = _dateOnly(now.toLocal())
      .difference(_dateOnly(d.toLocal()))
      .inDays;
  if (dayDiff == 0) return CommonStrings.today;
  if (dayDiff == 1) return CommonStrings.yesterdayTitle;
  return formatWeekdayDate(d, locale: locale);
}

/// `Cập nhật lúc 14:05` today, `Cập nhật lúc 14:05, 22/09` otherwise.
String formatUpdatedAt(DateTime at, DateTime now, {String? locale}) {
  final sameDay = _dateOnly(at.toLocal()) == _dateOnly(now.toLocal());
  final time = sameDay
      ? formatTime(at, locale: locale)
      : '${formatTime(at, locale: locale)}, '
            '${formatDayMonth(at, locale: locale)}';
  return CommonStrings.updatedAt(time);
}

/// Vietnamese-aware title case for ALL-CAPS game data:
/// `KIM CƯƠNG 1` → `Kim Cương 1`, `THƯỢNG NHÂN` → `Thượng Nhân`.
String viTitleCase(String input) {
  return input
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) {
        final lower = w.toLowerCase();
        return lower[0].toUpperCase() + lower.substring(1);
      })
      .join(' ');
}

/// Cleans a valorant-api display string (CA §16): trims whitespace and
/// newlines, collapses internal runs of spaces. Returns `null` when empty.
String? cleanDisplayText(String? input) {
  if (input == null) return null;
  final s = input.trim().replaceAll(RegExp(r'[ \t]+'), ' ');
  return s.isEmpty ? null : s;
}

final RegExp _rawLocKey = RegExp(r'^[A-Za-z0-9]+(_[A-Za-z0-9]+)+$');

/// True for leaked localisation keys such as `Coin_EP2_A1` or
/// `Playercard_CNYear3_DisplayName` (CA §16).
bool isRawLocKey(String? s) => s != null && _rawLocKey.hasMatch(s.trim());

/// First line of a multi-line API name (`"Vandal Reaver Cấp 4\n(Dạng 1 …)"`).
String firstLine(String s) => s.split('\n').first.trim();

/// Remaining lines of a multi-line API name, or `null`.
String? restLines(String s) {
  final parts = s.split('\n');
  if (parts.length < 2) return null;
  final rest = parts.skip(1).join('\n').trim();
  return rest.isEmpty ? null : rest;
}
