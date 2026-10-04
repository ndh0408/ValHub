import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/config/local_price.dart';
import 'package:valvn/core/config/vp_prices.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/core/l10n/formats.dart';
import 'package:valvn/core/l10n/labels/competitive_labels.dart';
import 'package:valvn/core/l10n/labels/economy_labels.dart';
import 'package:valvn/core/ui/countdown_text.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/core/util/format.dart' as old;
import 'package:valvn/features/profile/data/performance_view.dart';
import 'package:valvn/features/profile/profile_strings.dart';
import 'package:valvn/l10n/gen/app_localizations_vi.dart';

import '../helpers/l10n.dart';

// Explicit resource markers exercise reload/fallback, not shipped translations.
class _Messages extends AppLocalizationsVi {
  _Messages(this.marker);
  final String marker;
  @override
  String commonDays(int n) => '$marker-days-$n';
  @override
  String get commonTodayLower => '$marker-today';
  @override
  String get commonToday => '$marker-header';
  @override
  String get commonTomorrow => '$marker-tomorrow';
  @override
  String commonWallTime(String time, String day) => '$day/$time';
}

void main() {
  final vi = AppFormats.create(AppLocale.vi, 'vi');
  final messages = AppLocalizationsVi();
  final now = DateTime(2026, 12, 31, 23, 59, 30);

  test(
    'calendar headers and rounded wall times preserve VI across year boundary',
    () {
      for (final delta in [-10, -7, -2, -1, 0, 1, 2, 6, 7, 10]) {
        final at = now.add(Duration(days: delta, seconds: 29));
        expect(
          vi.dayHeader(at, now),
          old.formatDayHeader(at, now, locale: 'vi', messages: tl),
        );
        expect(
          vi.wallTime(at, now),
          old.formatWallTime(at, now, locale: 'vi', messages: tl),
        );
        expect(
          vi.weekdayDate(at),
          old.formatWeekdayDate(at, locale: 'vi', messages: tl),
        );
        expect(
          vi.updatedAt(at, now),
          old.formatUpdatedAt(at, now, locale: 'vi', messages: tl),
        );
      }
      // Expiry rounding can change the calendar day; headers do not round.
      expect(vi.wallTime(now, now), '00:00 ngày mai');
      expect(vi.dayHeader(now, now), 'Hôm nay');
      expect(vi.dayHeader(now.toUtc(), now.toUtc()), 'Hôm nay');
    },
  );

  test('countdowns and estimated game prices retain VI thresholds and finite handling', () {
    for (final duration in [
      const Duration(seconds: -1),
      Duration.zero,
      const Duration(seconds: 59),
      const Duration(hours: 23, minutes: 59, seconds: 59),
      const Duration(days: 1),
      const Duration(days: 12, hours: 3, minutes: 4, seconds: 5),
    ]) {
      expect(
        vi.countdown(duration),
        old.formatCountdown(duration, messages: tl),
      );
      expect(
        vi.durationCoarse(duration),
        old.formatDurationCoarse(duration, messages: tl),
      );
    }
    for (final amount in <num>[
      0,
      1775,
      1234567,
      -10,
      double.nan,
      double.infinity,
    ]) {
      expect(
        vi.estimatedVp(amount),
        old.formatEstimatedVp(amount, messages: tl),
      );
      expect(
        vi.estimatedPrice(amount, 'VND'),
        old.formatEstimatedPrice(amount, 'VND', locale: 'vi', messages: tl),
      );
    }
  });

  test(
    'unknown results and optional semantics preserve data and all VI captions',
    () {
      for (final draws in [-1, 0, 1, 10]) {
        for (final unknown in [-1, 0, 1, 10]) {
          expect(
            messages.winLossSummary(3, 2, draws, unknown),
            ProfileStrings.winsLosses(3, 2, draws, unknown),
          );
        }
      }
      for (final score in <String?>[null, '', '13 – 7']) {
        expect(
          messages.matchFacts('Ascent', 'Thắng', score),
          ProfileStrings.matchSemantics('Ascent', 'Thắng', score),
        );
      }
      for (final weapon in <String?>[null, '', 'Vandal']) {
        expect(
          messages.profileKillDescription(
            'Jett',
            'Sova',
            weapon == null || weapon.isEmpty ? 'no' : 'yes',
            weapon ?? '',
            '0:42',
          ),
          ProfileStrings.killSemantics('Jett', 'Sova', weapon, '0:42'),
        );
      }
      for (final period in PerfPeriod.values) {
        expect(
          messages.profilePerformancePeriodLabel(period.name),
          ProfileStrings.performancePeriod(period),
        );
      }
      for (final segment in PerfSegment.values) {
        expect(
          messages.profilePerformanceSegmentLabel(segment.name),
          ProfileStrings.performanceSegment(segment),
        );
      }
    },
  );

  test('device offsets retain fractional and negative zones; weekday badges stay VI', () {
    for (final offset in [
      Duration.zero,
      const Duration(hours: 7),
      const Duration(hours: 5, minutes: 45),
      const Duration(hours: -3, minutes: -30),
    ]) {
      expect(vi.deviceTimeZone(offset), ProfileStrings.timeZoneLabel(offset));
    }
    for (var i = 0; i < 7; i++) {
      final at = DateTime(2026, 9, 21 + i);
      expect(vi.dayBadge(at), ProfileStrings.weekdayShort[i]);
    }
  });

  test('non-VI dates/clocks use explicit format locale with supplied fallback messages', () {
    final en = AppFormats.create(
      AppLocale.en,
      'en_US',
      messages: _Messages('M'),
    );
    final at = DateTime(2026, 9, 22, 14, 5);
    expect(en.wallTime(at, at), 'M-today/2:05\u202fPM');
    expect(en.dayHeader(at, at), 'M-header');
    expect(
      en.countdown(const Duration(days: 2, hours: 3)),
      'M-days-2 03:00:00',
    );
    expect(en.dayBadge(at), 'Tue');
    final h24 = AppFormats.create(
      AppLocale.en,
      'en_US',
      h24: true,
      messages: _Messages('M'),
    );
    expect(h24.wallTime(at, at), 'M-today/14:05');
    final de = AppFormats.create(AppLocale.de, 'de', messages: messages);
    expect(de.weekdayLower(at), 'Dienstag');
    expect(de.dayBadge(at), de.weekdayShort(at));
  });

  test('estimates retain configured ISO and underlying VP conversion', () {
    for (final iso in ['USD', 'JPY', 'VND']) {
      final price = LocalPrice(
        table: VpPriceTable(
          currency: iso,
          packs: const [VpPack(vp: 1000, price: 10)],
        ),
        source: LocalPriceSource.user,
      );
      expect(
        price.estimateText(vi, 2000),
        vi.estimatedPrice(price.estimate(2000)!, iso),
      );
      expect(price.packPriceText(vi, 10), vi.currency(10, iso));
      expect(price.estimateText(vi, 0), isNull);
    }
  });

  testWidgets(
    'retained default countdown refreshes resources without resetting expiry state',
    (tester) async {
      final clock = FixedClock(DateTime(2026, 9, 22));
      var expired = 0;
      final child = CountdownText(
        expiresAt: clock.now().add(const Duration(days: 1)),
        onExpired: () => expired++,
      );
      Widget build(String marker) => ProviderScope(
        overrides: [clockProvider.overrideWithValue(clock)],
        child: AppFormatsScope(
          formats: AppFormats.create(
            AppLocale.vi,
            'vi',
            messages: _Messages(marker),
          ),
          child: testL10nApp(child),
        ),
      );
      await tester.pumpWidget(build('A'));
      final state = tester.state(find.byType(CountdownText));
      expect(find.text('A-days-1 00:00:00'), findsOneWidget);
      await tester.pumpWidget(build('B'));
      expect(tester.state(find.byType(CountdownText)), same(state));
      expect(find.text('B-days-1 00:00:00'), findsOneWidget);
      clock.advance(const Duration(days: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(expired, 1);
      expect(find.text('00:00:00'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'explicit countdown override remains authoritative after resource change',
    (tester) async {
      final clock = FixedClock(now);
      final child = CountdownText(
        expiresAt: now.add(const Duration(days: 1)),
        format: (duration) => 'custom-${duration.inDays}',
      );
      Widget build(String marker) => ProviderScope(
        overrides: [clockProvider.overrideWithValue(clock)],
        child: AppFormatsScope(
          formats: AppFormats.create(
            AppLocale.vi,
            'vi',
            messages: _Messages(marker),
          ),
          child: testL10nApp(child),
        ),
      );
      await tester.pumpWidget(build('A'));
      expect(find.text('custom-1'), findsOneWidget);
      await tester.pumpWidget(build('B'));
      expect(find.text('custom-1'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
