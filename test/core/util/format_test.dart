import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/util/format.dart';

void main() {
  group('numbers', () {
    test('vi decimal grouping uses dots', () {
      expect(formatNumber(1162500), '1.162.500');
      expect(formatNumber(875), '875');
      expect(formatNumber(0), '0');
      expect(formatNumber(double.nan), '0');
    });

    test('currency labels follow the number', () {
      expect(formatVp(2175), '2.175 VP');
      expect(formatKc(2113), '2.113 KC');
      expect(formatRp(40), '40 RP');
      expect(formatEstimatedVp(2475), '≈ 2.475 VP');
    });

    test('signed RR uses the U+2212 minus', () {
      expect(formatSignedRr(24), '+24 RR');
      expect(formatSignedRr(-17), '−17 RR');
      expect(formatSignedRr(0), '0 RR');
      expect(formatSigned(1500), '+1.500');
    });

    test('percent formats', () {
      expect(formatDiscountPercent(32), '-32%');
      expect(formatPercent(0.256), '26%');
      expect(formatPercent(0.5, decimals: 1), '50,0%');
    });
  });

  group('countdowns', () {
    test('under a day: HH:MM:SS', () {
      expect(
        formatCountdown(const Duration(hours: 11, minutes: 54, seconds: 37)),
        '11:54:37',
      );
      expect(formatCountdown(const Duration(seconds: 5)), '00:00:05');
    });

    test('a day or more: "N ngày HH:MM:SS"', () {
      expect(
        formatCountdown(
          const Duration(days: 2, hours: 15, minutes: 9, seconds: 24),
        ),
        '2 ngày 15:09:24',
      );
    });

    test('negative clamps to zero', () {
      expect(formatCountdown(const Duration(seconds: -3)), '00:00:00');
    });

    test('short timers', () {
      expect(
        formatMinutesSeconds(const Duration(minutes: 1, seconds: 32)),
        '01:32',
      );
      expect(
        formatMinutesSeconds(const Duration(seconds: 42), padMinutes: false),
        '0:42',
      );
    });

    test('coarse durations', () {
      expect(formatDurationCoarse(const Duration(minutes: 38)), '38 phút');
      expect(
        formatDurationCoarse(const Duration(hours: 5, minutes: 2)),
        '5 giờ',
      );
      expect(formatDurationCoarse(const Duration(days: 16)), '16 ngày');
    });
  });

  group('relative time', () {
    final now = DateTime(2026, 9, 28, 14);

    test('recent', () {
      expect(
        formatRelative(now.subtract(const Duration(seconds: 20)), now),
        'vừa xong',
      );
      expect(
        formatRelative(now.subtract(const Duration(minutes: 5)), now),
        '5 phút trước',
      );
      expect(
        formatRelative(now.subtract(const Duration(hours: 18)), now),
        '18 giờ trước',
      );
    });

    test('days', () {
      expect(formatRelative(DateTime(2026, 9, 27, 1), now), 'hôm qua');
      expect(formatRelative(DateTime(2026, 9, 25, 9), now), '3 ngày trước');
      expect(formatRelative(DateTime(2026, 9, 1, 9), now), '01/09/2026');
    });

    test('future instants read as just now', () {
      expect(
        formatRelative(now.add(const Duration(minutes: 3)), now),
        'vừa xong',
      );
    });
  });

  group('dates', () {
    test('weekday dates', () {
      expect(formatWeekdayDate(DateTime(2026, 9, 22)), 'Thứ Ba, 22/09');
      expect(formatWeekdayDate(DateTime(2026, 9, 28)), 'Thứ Hai, 28/09');
      expect(formatWeekday(DateTime(2026, 9, 27)), 'Chủ Nhật');
    });

    test('day headers', () {
      final now = DateTime(2026, 9, 28, 10);
      expect(formatDayHeader(DateTime(2026, 9, 28, 1), now), 'Hôm nay');
      expect(formatDayHeader(DateTime(2026, 9, 27, 23), now), 'Hôm qua');
      expect(formatDayHeader(DateTime(2026, 9, 22, 8), now), 'Thứ Ba, 22/09');
    });

    test('date / time', () {
      final d = DateTime(2026, 9, 2, 7, 5);
      expect(formatDate(d), '02/09/2026');
      expect(formatTime(d), '07:05');
      expect(formatDateTime(d), '02/09/2026 07:05');
    });

    test('updated at', () {
      final now = DateTime(2026, 9, 28, 16);
      expect(
        formatUpdatedAt(DateTime(2026, 9, 28, 14, 5), now),
        'Cập nhật lúc 14:05',
      );
      expect(
        formatUpdatedAt(DateTime(2026, 9, 27, 14, 5), now),
        'Cập nhật lúc 14:05, 27/09',
      );
    });
  });

  group('text', () {
    test('Vietnamese title case', () {
      expect(viTitleCase('KIM CƯƠNG 1'), 'Kim Cương 1');
      expect(viTitleCase('THƯỢNG NHÂN 3'), 'Thượng Nhân 3');
      expect(viTitleCase('ĐỒNG 2'), 'Đồng 2');
      expect(viTitleCase('  BẤT   TỬ '), 'Bất Tử');
    });

    test('cleanDisplayText trims and collapses', () {
      expect(cleanDisplayText('\nShotgun'), 'Shotgun');
      expect(cleanDisplayText('  Tài  Lộc  '), 'Tài Lộc');
      expect(cleanDisplayText('   '), isNull);
      expect(cleanDisplayText(null), isNull);
    });

    test('raw localisation keys are detected', () {
      expect(isRawLocKey('Coin_EP2_A1'), isTrue);
      expect(isRawLocKey('Playercard_CNYear3_DisplayName'), isTrue);
      expect(isRawLocKey('Vandal Reaver'), isFalse);
      expect(isRawLocKey('AggrobotSkateboard'), isFalse);
    });

    test('multi-line names', () {
      const s = 'Vandal Reaver Cấp 4\r\n(Dạng 1 Ánh Đỏ)';
      expect(firstLine(s), 'Vandal Reaver Cấp 4');
      expect(restLines(s), '(Dạng 1 Ánh Đỏ)');
      expect(restLines('one line'), isNull);
    });
  });
}
