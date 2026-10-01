import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_10y.dart' as data;
import 'package:timezone/timezone.dart' as tz;
import 'package:valvn/core/util/format.dart';

void main() {
  test('spring and autumn count calendar dates across 23/25-hour days', () {
    data.initializeTimeZones();
    final ny = tz.getLocation('America/New_York');
    final spring = tz.TZDateTime(ny, 2026, 3, 8);
    final next = tz.TZDateTime(ny, 2026, 3, 9);
    expect(next.difference(spring).inHours, 23);
    expect(calendarDayDifference(next, spring), 1);
    final fall = tz.TZDateTime(ny, 2026, 11, 1);
    final after = tz.TZDateTime(ny, 2026, 11, 2);
    expect(after.difference(fall).inHours, 25);
    expect(calendarDayDifference(after, fall), 1);
    expect(calendarDayDifference(spring, next), -1);
  });
}
