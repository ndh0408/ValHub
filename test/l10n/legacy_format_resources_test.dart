import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/util/format.dart';
import 'package:valvn/features/settings/data/server_status.dart';
import 'package:valvn/l10n/gen/app_localizations_vi.dart';

class _Messages extends AppLocalizationsVi {
  @override
  String commonDays(int n) => 'days:$n';
  @override
  String commonMinutes(int n) => 'minutes:$n';
  @override
  String get commonJustNow => 'recent';
  @override
  String get commonYesterday => 'yesterday';
  @override
  String get commonTodayLower => 'today';
  @override
  String get commonWeekdaysItem0 => 'weekday';
  @override
  String get contentCurrencyVp => 'credits';
  @override
  String get commonEstimatePrefix => 'estimate';
  @override
  String commonWallTime(String time, String day) => '$day/$time';
}

void main() {
  final messages = _Messages();
  test(
    'compatibility algorithms use explicit resources for durations and money',
    () {
      expect(
        formatCountdown(
          const Duration(days: 2, seconds: 5),
          messages: messages,
        ),
        'days:2 00:00:05',
      );
      expect(
        formatDurationCoarse(const Duration(minutes: 5), messages: messages),
        'minutes:5',
      );
      expect(formatVp(240, messages: messages), '240 credits');
      expect(
        formatEstimatedVp(240, messages: messages),
        'estimate 240 credits',
      );
    },
  );
  test('relative, weekday and status helpers use provided resources', () {
    final now = DateTime(2026, 10, 5, 14, 5);
    expect(formatRelative(now, now, messages: messages), 'recent');
    expect(formatWeekday(now, locale: 'vi', messages: messages), 'weekday');
    expect(
      formatWallTime(now, now, locale: 'vi', messages: messages),
      'today/14:05',
    );
    expect(
      formatStatusTime(
        now.subtract(const Duration(days: 1)),
        now,
        messages: messages,
      ),
      'yesterday/14:05',
    );
  });
}
