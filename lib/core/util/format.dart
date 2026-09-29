/// Vietnamese formatting helpers (VF §8.0 rules 6–7, SUMMARY §8.8 X9).
///
/// All functions are pure; pass `now` explicitly (from `clockProvider`) so they
/// are testable.
library;

import 'package:intl/intl.dart';

import '../l10n/common_strings.dart';
import '../l10n/content_strings.dart';

final NumberFormat _decimal = NumberFormat.decimalPattern('vi');

/// `1162500` → `1.162.500`. Non-finite values format as `0`.
String formatNumber(num value) => _decimal.format(value.isFinite ? value : 0);

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

/// `1290000` → `1.290.000 ₫`.
String formatVnd(num amount) =>
    '${formatNumber(amount)} ${CommonStrings.vndSymbol}';

/// `≈ 1.290.000 ₫` (VND estimate of a VP price).
String formatEstimatedVnd(num amount) =>
    '${CommonStrings.estimatePrefix} ${formatVnd(amount)}';

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

/// Fraction → percent: `0.256` → `26%`.
String formatPercent(num fraction, {int decimals = 0}) {
  final value = fraction.isFinite ? fraction * 100 : 0;
  return '${value.toStringAsFixed(decimals).replaceAll('.', ',')}%';
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
String formatRelative(DateTime then, DateTime now) {
  final localThen = then.toLocal();
  final localNow = now.toLocal();
  final diff = localNow.difference(localThen);
  if (diff.inMinutes < 1) return CommonStrings.justNow;
  if (diff.inMinutes < 60) return CommonStrings.minutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return CommonStrings.hoursAgo(diff.inHours);
  final dayDiff = _dateOnly(localNow).difference(_dateOnly(localThen)).inDays;
  if (dayDiff <= 1) return CommonStrings.yesterday;
  if (dayDiff < 7) return CommonStrings.daysAgo(dayDiff);
  return formatDate(localThen);
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// `22/09/2026` (local time).
String formatDate(DateTime d) {
  final l = d.toLocal();
  return '${_two(l.day)}/${_two(l.month)}/${l.year}';
}

/// `22/09` (local time).
String formatDayMonth(DateTime d) {
  final l = d.toLocal();
  return '${_two(l.day)}/${_two(l.month)}';
}

/// `14:05` (24-hour, local time).
String formatTime(DateTime d) {
  final l = d.toLocal();
  return '${_two(l.hour)}:${_two(l.minute)}';
}

/// `22/09/2026 14:05` (local time).
String formatDateTime(DateTime d) => '${formatDate(d)} ${formatTime(d)}';

/// `Thứ Hai` for the local weekday of [d].
String formatWeekday(DateTime d) =>
    CommonStrings.weekdays[d.toLocal().weekday - 1];

/// `Thứ Hai, 22/09` (local time).
String formatWeekdayDate(DateTime d) =>
    '${formatWeekday(d)}, ${formatDayMonth(d)}';

/// Local wall-clock moment for resets and expiries, 24 h, on the device
/// time zone (UTC+7 for Vietnamese players):
/// `07:00 hôm nay`, `07:00 ngày mai`, else `23:59 thứ Hai 06/10`.
String formatWallTime(DateTime at, DateTime now) {
  final l = at.toLocal();
  final dayDiff = _dateOnly(l).difference(_dateOnly(now.toLocal())).inDays;
  final String day;
  if (dayDiff == 0) {
    day = CommonStrings.todayLower;
  } else if (dayDiff == 1) {
    day = CommonStrings.tomorrow;
  } else {
    day = '${formatWeekdayLower(l)} ${formatDayMonth(l)}';
  }
  return CommonStrings.wallTime(formatTime(l), day);
}

/// `thứ Hai`, `chủ Nhật` — the weekday written mid-sentence.
String formatWeekdayLower(DateTime d) {
  final w = formatWeekday(d);
  return w[0].toLowerCase() + w.substring(1);
}

/// Day header for grouped lists: `Hôm nay`, `Hôm qua`, else
/// `Thứ Hai, 22/09` (VF S42).
String formatDayHeader(DateTime d, DateTime now) {
  final dayDiff = _dateOnly(now.toLocal())
      .difference(_dateOnly(d.toLocal()))
      .inDays;
  if (dayDiff == 0) return CommonStrings.today;
  if (dayDiff == 1) return CommonStrings.yesterdayTitle;
  return formatWeekdayDate(d);
}

/// `Cập nhật lúc 14:05` today, `Cập nhật lúc 14:05, 22/09` otherwise.
String formatUpdatedAt(DateTime at, DateTime now) {
  final sameDay = _dateOnly(at.toLocal()) == _dateOnly(now.toLocal());
  final time = sameDay
      ? formatTime(at)
      : '${formatTime(at)}, ${formatDayMonth(at)}';
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
