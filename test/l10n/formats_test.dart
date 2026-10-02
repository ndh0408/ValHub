import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/core/l10n/formats.dart';
import 'package:valvn/core/util/format.dart' as legacy;

/// A Tuesday afternoon in the device time zone (no UTC conversion involved).
final _tue = DateTime(2026, 9, 22, 14, 5, 9);

AppFormats fmt(AppLocale l, String tag, {bool h24 = false}) =>
    AppFormats.create(l, tag, h24: h24);

void main() {
  group('vi stays byte-identical to core/util/format.dart', () {
    final vi = fmt(AppLocale.vi, 'vi');

    test('relative activity preserves thresholds, future and calendar-day behavior', () {
      for (final duration in [
        const Duration(minutes: -5),
        Duration.zero,
        const Duration(seconds: 59),
        const Duration(minutes: 1),
        const Duration(minutes: 59),
        const Duration(hours: 1),
        const Duration(hours: 23),
        const Duration(hours: 24),
        const Duration(days: 2),
        const Duration(days: 6),
        const Duration(days: 7),
      ]) {
        final then = _tue.subtract(duration);
        expect(
          vi.relative(then, _tue),
          legacy.formatRelative(then, _tue, locale: 'vi'),
          reason: '$duration',
        );
      }
    });

    test('numbers, signs and non-finite values', () {
      for (final v in <num>[
        0,
        1,
        12,
        999,
        1000,
        1234,
        12345,
        1162500,
        -5,
        -1234567,
        0.5,
        1234.5678,
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(
          vi.number(v),
          legacy.formatNumber(v, locale: 'vi'),
          reason: '$v',
        );
      }
      for (final v in [-1000, -17, 0, 1, 24, 1234]) {
        expect(vi.signed(v), legacy.formatSigned(v), reason: '$v');
      }
    });

    test('percent, ties included', () {
      for (final f in <num>[
        0,
        0.1,
        0.256,
        0.5,
        0.999,
        1,
        1.5,
        0.125,
        0.0005,
        2.675,
      ]) {
        for (final d in [0, 1, 2]) {
          expect(
            vi.percent(f, decimals: d),
            legacy.formatPercent(f, decimals: d, locale: 'vi'),
            reason: '$f/$d',
          );
        }
      }
      expect(vi.percent(double.nan), '0%');
      expect(vi.percent(0.256, decimals: 1), '25,6%');
    });

    test('currency', () {
      for (final (amount, iso) in <(num, String)>[
        (268000, 'VND'),
        (16.1, 'USD'),
        (0, 'VND'),
        (1234.5, 'EUR'),
        (double.nan, 'VND'),
      ]) {
        expect(
          vi.currency(amount, iso),
          legacy.formatCurrency(amount, iso, locale: 'vi'),
          reason: '$amount $iso',
        );
      }
      expect(
        AppFormats.currencyDecimalDigits('VND'),
        legacy.currencyDecimalDigits('VND'),
      );
      expect(AppFormats.currencyDecimalDigits('USD'), 2);
      expect(AppFormats.currencyDecimalDigits('JPY'), 0);
    });

    test('dates, times and weekdays for every weekday and edge instants', () {
      final instants = [
        DateTime(2026, 1, 5, 0, 0),
        DateTime(2026, 12, 31, 23, 59),
        DateTime(2026, 9, 22, 14, 5, 9),
        DateTime(2027, 3, 1, 9, 7),
        DateTime.utc(2026, 9, 22, 14, 5),
        DateTime.utc(2026, 1, 1),
        // Every weekday: 2026-09-21 is a Monday.
        for (var i = 0; i < 7; i++) DateTime(2026, 9, 21 + i, 7),
      ];
      for (final d in instants) {
        expect(vi.date(d), legacy.formatDate(d, locale: 'vi'), reason: '$d');
        expect(vi.dayMonth(d), legacy.formatDayMonth(d, locale: 'vi'));
        expect(vi.time(d), legacy.formatTime(d, locale: 'vi'));
        expect(vi.dateTime(d), legacy.formatDateTime(d, locale: 'vi'));
        expect(vi.weekday(d), legacy.formatWeekday(d, locale: 'vi'));
      }
    });

    test('Vietnamese is 24 h whatever the device says', () {
      final h12 = fmt(AppLocale.vi, 'vi');
      final h24 = fmt(AppLocale.vi, 'vi', h24: true);
      expect(h12.time(_tue), '14:05');
      expect(h24.time(_tue), '14:05');
      expect(h12.dateTime(_tue), '22/09/2026 14:05');
      expect(h24.dateTime(_tue), '22/09/2026 14:05');
    });

    test('clock digits', () {
      const durations = [
        Duration.zero,
        Duration(seconds: 59),
        Duration(seconds: 61),
        Duration(seconds: 3599),
        Duration(hours: 1),
        Duration(hours: 11, minutes: 54, seconds: 37),
        Duration(hours: 23, minutes: 59, seconds: 59),
        Duration(hours: 25),
        Duration(days: 2, hours: 15, minutes: 9, seconds: 24),
        Duration(seconds: -30),
      ];
      for (final d in durations) {
        expect(
          vi.minutesSeconds(d),
          legacy.formatMinutesSeconds(d),
          reason: '$d',
        );
        expect(
          vi.minutesSeconds(d, padMinutes: false),
          legacy.formatMinutesSeconds(d, padMinutes: false),
        );
        // The legacy countdown prefixes the days; the clock part is ours.
        expect(legacy.formatCountdown(d), endsWith(vi.countdownClock(d)));
      }
      expect(
        vi.countdownClock(const Duration(hours: 11, minutes: 54, seconds: 37)),
        '11:54:37',
      );
      expect(
        vi.countdownClock(
          const Duration(days: 2, hours: 15, minutes: 9, seconds: 24),
        ),
        '15:09:24',
      );
      expect(vi.countdownClock(const Duration(seconds: -1)), '00:00:00');
    });

    test('title case matches viTitleCase', () {
      for (final s in [
        'KIM CƯƠNG 1',
        'THƯỢNG NHÂN',
        'radiant',
        '  a   b ',
        '',
        'ĐỒNG 2',
      ]) {
        expect(vi.titleCase(s), legacy.viTitleCase(s), reason: s);
      }
    });
  });

  group('CLDR goldens (the intl data of the pinned version)', () {
    test('en_US, 12 h and 24 h', () {
      final h12 = fmt(AppLocale.en, 'en_US');
      expect(h12.number(1162500.5), '1,162,500.5');
      expect(h12.compact(1200000), '1.2M');
      expect(h12.signed(-17), '\u{2212}17');
      expect(h12.signed(24), '+24');
      expect(h12.percent(0.256), '26%');
      expect(h12.percent(0.256, decimals: 1), '25.6%');
      expect(h12.currency(16.1, 'USD'), r'$16.10');
      expect(h12.date(_tue), '9/22/2026');
      expect(h12.dayMonth(_tue), '9/22');
      expect(h12.time(_tue), '2:05\u{202f}PM');
      expect(h12.dateTime(_tue), '9/22/2026 2:05\u{202f}PM');
      expect(h12.weekday(_tue), 'Tuesday');
      expect(h12.weekdayShort(_tue), 'Tue');

      final h24 = fmt(AppLocale.en, 'en_US', h24: true);
      expect(h24.time(_tue), '14:05');
      expect(h24.dateTime(_tue), '9/22/2026 14:05');
    });

    test('a regional tag changes the pattern, not the language', () {
      final gb = fmt(AppLocale.en, 'en_GB');
      expect(gb.date(_tue), '22/09/2026');
      expect(gb.time(_tue), '14:05');
      final at = fmt(AppLocale.de, 'de_AT');
      expect(at.number(1162500.5), '1\u{a0}162\u{a0}500,5');
      expect(at.date(_tue), '22.9.2026');
    });

    test('de', () {
      final f = fmt(AppLocale.de, 'de');
      expect(f.number(1162500.5), '1.162.500,5');
      expect(f.percent(0.256, decimals: 1), '25,6\u{a0}%');
      expect(f.date(_tue), '22.9.2026');
      expect(f.dayMonth(_tue), '22.9.');
      expect(f.time(_tue), '14:05');
      expect(f.weekday(_tue), 'Dienstag');
      expect(f.weekdayShort(_tue), 'Di');
    });

    test('ar keeps Latin digits and isolates amounts', () {
      final f = fmt(AppLocale.ar, 'ar');
      expect(f.number(1162500.5), '1,162,500.5');
      expect(
        f.weekday(_tue),
        '\u{627}\u{644}\u{62b}\u{644}\u{627}\u{62b}\u{627}\u{621}',
      );
      expect(f.date(_tue), '22\u{200f}/9\u{200f}/2026');
      // The currency is isolated (LRI ... PDI) so the symbol cannot jump.
      final money = f.currency(268000, 'VND');
      expect(money.startsWith('\u{2066}'), isTrue);
      expect(money.endsWith('\u{2069}'), isTrue);
      expect(money, contains('268,000'));
    });

    test('th prints Gregorian years (decision 5)', () {
      final f = fmt(AppLocale.th, 'th');
      expect(f.date(_tue), '22/9/2026');
      expect(f.time(_tue), '14:05 \u{e19}.');
      expect(
        f.weekday(_tue),
        '\u{e27}\u{e31}\u{e19}\u{e2d}\u{e31}\u{e07}\u{e04}\u{e32}\u{e23}',
      );
    });

    test('ja', () {
      final f = fmt(AppLocale.ja, 'ja');
      expect(f.date(_tue), '2026/9/22');
      expect(f.time(_tue), '14:05');
      expect(f.compact(1200000), '120\u{4e07}');
      expect(f.weekday(_tue), '\u{706b}\u{66dc}\u{65e5}');
    });

    test('zh_Hant uses the zh_TW data', () {
      final f = fmt(AppLocale.zhHant, 'zh_TW');
      expect(f.date(_tue), '2026/9/22');
      expect(f.compact(1200000), '120\u{842c}');
      expect(f.weekday(_tue), '\u{661f}\u{671f}\u{4e8c}');
    });

    test('tr', () {
      final f = fmt(AppLocale.tr, 'tr');
      expect(f.number(1162500.5), '1.162.500,5');
      expect(f.percent(0.256, decimals: 1), '%25,6');
      expect(f.date(_tue), '22.09.2026');
      expect(f.weekday(_tue), 'Sal\u{131}');
    });

    test('an unknown tag falls back to en_US instead of throwing', () {
      final f = fmt(AppLocale.en, 'xx_YY');
      expect(f.number(1234.5), '1,234.5');
      expect(f.date(_tue), '9/22/2026');
      expect(f.currency(16.1, 'USD'), r'$16.10');
    });

    test('non-finite numbers read 0', () {
      for (final l in AppLocale.values) {
        final f = fmt(l, l.intlTag);
        expect(f.number(double.nan), '0', reason: l.name);
        expect(f.number(double.infinity), '0');
        expect(f.compact(double.nan), '0');
        expect(f.percent(double.nan), contains('0'));
      }
    });

    test('every locale formats every value without throwing', () {
      for (final l in AppLocale.values) {
        for (final h24 in [false, true]) {
          final f = fmt(l, l.intlTag, h24: h24);
          for (final s in [
            f.number(1234567.891),
            f.compact(1234567),
            f.signed(-1),
            f.percent(0.5, decimals: 1),
            f.currency(1234.5, 'EUR'),
            f.date(_tue),
            f.dayMonth(_tue),
            f.time(_tue),
            f.dateTime(_tue),
            f.weekday(_tue),
            f.weekdayShort(_tue),
          ]) {
            expect(s, isNotEmpty, reason: l.name);
          }
        }
      }
    });
  });

  group('case, direction and order', () {
    test('Turkish dotted and dotless i', () {
      final tr = fmt(AppLocale.tr, 'tr');
      expect(tr.upper('istanbul \u{131}spanak'), '\u{130}STANBUL ISPANAK');
      expect(tr.lower('\u{130}STANBUL ISPANAK'), 'istanbul \u{131}spanak');
      expect(tr.titleCase('\u{130}STANBUL ILIK'), '\u{130}stanbul Il\u{131}k');
    });

    test('other languages use the plain mapping', () {
      final en = fmt(AppLocale.en, 'en_US');
      expect(en.upper('istanbul'), 'ISTANBUL');
      expect(en.lower('ISTANBUL'), 'istanbul');
      expect(fmt(AppLocale.de, 'de').upper('stra\u{df}e'), 'STRASSE');
    });

    test('title case is a no-op for scripts without case', () {
      for (final l in [
        AppLocale.ja,
        AppLocale.zh,
        AppLocale.ar,
        AppLocale.th,
      ]) {
        final f = fmt(l, l.intlTag);
        expect(
          f.titleCase('\u{30c0}\u{30a4}\u{30e4}'),
          '\u{30c0}\u{30a4}\u{30e4}',
        );
      }
      expect(fmt(AppLocale.en, 'en_US').titleCase('  a   b '), 'A B');
      expect(fmt(AppLocale.en, 'en_US').titleCase(''), '');
    });

    test('bidi isolates only in right-to-left languages', () {
      final ar = fmt(AppLocale.ar, 'ar');
      expect(ar.bidi('8 - 4'), '\u{2066}8 - 4\u{2069}');
      for (final l in AppLocale.values.where((l) => !l.isRtl)) {
        expect(fmt(l, l.intlTag).bidi('8 - 4'), '8 - 4', reason: l.name);
      }
    });

    test('sortKey folds accents and case, the raw name breaks ties', () {
      final f = fmt(AppLocale.vi, 'vi');
      final names = [
        '\u{110}\u{1ee9}c',
        'duc',
        '\u{c1}nh',
        'anh',
        'B\u{1ea3}o',
        'bao',
      ];
      names.sort((a, b) => f.sortKey(a).compareTo(f.sortKey(b)));
      // Same folded key -> raw code units decide ('B' < 'b', 'a' < 'Á').
      expect(names, [
        'anh',
        '\u{c1}nh',
        'B\u{1ea3}o',
        'bao',
        'duc',
        '\u{110}\u{1ee9}c',
      ]);
      // A prefix sorts before its extension.
      expect(f.sortKey('ab').compareTo(f.sortKey('abc')), lessThan(0));
    });
  });

  group('value semantics', () {
    test('equality follows locale, tag and clock', () {
      expect(fmt(AppLocale.en, 'en_GB'), fmt(AppLocale.en, 'en_GB'));
      expect(
        fmt(AppLocale.en, 'en_GB').hashCode,
        fmt(AppLocale.en, 'en_GB').hashCode,
      );
      expect(fmt(AppLocale.en, 'en_GB'), isNot(fmt(AppLocale.en, 'en_US')));
      expect(
        fmt(AppLocale.en, 'en_US'),
        isNot(fmt(AppLocale.en, 'en_US', h24: true)),
      );
      expect(fmt(AppLocale.en, 'en_US'), isNot(fmt(AppLocale.de, 'en_US')));
    });

    test('l10n is the generated messages of the locale', () {
      expect(fmt(AppLocale.vi, 'vi').l10n.localeName, 'vi');
    });
  });

  group('AppFormats.of', () {
    Widget probe(
      void Function(BuildContext) onBuild, {
      Locale? locale,
      bool? h24,
    }) {
      Widget child = Builder(
        builder: (context) {
          onBuild(context);
          return const SizedBox.shrink();
        },
      );
      if (h24 != null) {
        child = MediaQuery(
          data: MediaQueryData(alwaysUse24HourFormat: h24),
          child: child,
        );
      }
      if (locale == null) return child;
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Localizations(
          locale: locale,
          delegates: const [DefaultWidgetsLocalizations.delegate],
          child: child,
        ),
      );
    }

    testWidgets('derives from the ambient Localizations and MediaQuery', (
      tester,
    ) async {
      late AppFormats got;
      await tester.pumpWidget(
        probe(
          (c) => got = AppFormats.of(c),
          locale: const Locale('en', 'GB'),
          h24: true,
        ),
      );
      expect(got.locale, AppLocale.en);
      expect(got.tag, 'en_GB');
      expect(got.h24, isTrue);
      expect(got.date(_tue), '22/09/2026');
    });

    testWidgets('reads the 12 h setting from MediaQuery', (tester) async {
      late AppFormats got;
      await tester.pumpWidget(
        probe(
          (c) => got = AppFormats.of(c),
          locale: const Locale('en', 'US'),
          h24: false,
        ),
      );
      expect(got.time(_tue), '2:05\u{202f}PM');
    });

    testWidgets('works without a MediaQuery', (tester) async {
      late AppFormats got;
      await tester.pumpWidget(
        probe((c) => got = AppFormats.of(c), locale: const Locale('de')),
      );
      expect(got.locale, AppLocale.de);
      expect(got.h24, isFalse);
    });

    testWidgets('an unsupported language formats like English', (tester) async {
      late AppFormats got;
      await tester.pumpWidget(
        probe((c) => got = AppFormats.of(c), locale: const Locale('nb')),
      );
      expect(got.locale, AppLocale.en);
    });

    testWidgets('the same inputs give the same instance (memoised)', (
      tester,
    ) async {
      late AppFormats a;
      await tester.pumpWidget(
        probe((c) => a = AppFormats.of(c), locale: const Locale('ja')),
      );
      late AppFormats b;
      await tester.pumpWidget(
        probe((c) => b = AppFormats.of(c), locale: const Locale('ja')),
      );
      expect(identical(a, b), isTrue);
    });

    testWidgets('a scope wins over the ambient locale', (tester) async {
      late AppFormats got;
      final scoped = fmt(AppLocale.tr, 'tr');
      await tester.pumpWidget(
        AppFormatsScope(
          formats: scoped,
          child: probe(
            (c) => got = AppFormats.of(c),
            locale: const Locale('en'),
          ),
        ),
      );
      expect(got, same(scoped));
    });

    testWidgets('dependents rebuild when the scope changes', (tester) async {
      var builds = 0;
      late AppFormats got;
      // ONE child instance: its Builder is rebuilt only when the scope
      // notifies it (a fresh widget would rebuild it regardless).
      final child = probe((c) {
        builds++;
        got = AppFormats.of(c);
      });
      Widget build(AppFormats f) => AppFormatsScope(formats: f, child: child);
      await tester.pumpWidget(build(fmt(AppLocale.en, 'en_US')));
      expect(got.locale, AppLocale.en);
      final first = builds;
      // Equal formats: no rebuild of dependents.
      await tester.pumpWidget(build(fmt(AppLocale.en, 'en_US')));
      expect(builds, first);
      await tester.pumpWidget(build(fmt(AppLocale.de, 'de')));
      expect(got.locale, AppLocale.de);
      expect(builds, greaterThan(first));
    });

    testWidgets('dependents rebuild when the ambient locale changes', (
      tester,
    ) async {
      late AppFormats got;
      await tester.pumpWidget(
        probe((c) => got = AppFormats.of(c), locale: const Locale('vi')),
      );
      expect(got.date(_tue), '22/09/2026');
      await tester.pumpWidget(
        probe((c) => got = AppFormats.of(c), locale: const Locale('de')),
      );
      expect(got.date(_tue), '22.9.2026');
    });

    testWidgets('throws a clear error without any Localizations', (
      tester,
    ) async {
      await tester.pumpWidget(probe((c) => AppFormats.of(c)));
      final error = tester.takeException();
      expect(error, isA<FlutterError>());
      expect((error! as FlutterError).message, contains('AppFormats missing'));
    });
  });
}
