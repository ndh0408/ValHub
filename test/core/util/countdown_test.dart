import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/util/countdown.dart';

void main() {
  final received = DateTime.utc(2026, 9, 28, 0, 0, 0);

  test('expiresAt = receivedAt + seconds', () {
    expect(
      expiresAtFrom(3600, received),
      received.add(const Duration(hours: 1)),
    );
    expect(
      expiresAtFrom('90', received),
      received.add(const Duration(seconds: 90)),
    );
    expect(
      expiresAtFrom(1.5, received),
      received.add(const Duration(milliseconds: 1500)),
    );
    expect(expiresAtFrom(null, received), isNull);
    expect(expiresAtFrom('x', received), isNull);
  });

  test('Deadline remaining / expired', () {
    final d = Deadline.fromSeconds(60, receivedAt: received)!;
    expect(
      d.remaining(received.add(const Duration(seconds: 20))),
      const Duration(seconds: 40),
    );
    expect(
      d.remaining(received.add(const Duration(minutes: 5))),
      Duration.zero,
    );
    expect(d.isExpired(received.add(const Duration(seconds: 59))), isFalse);
    expect(d.isExpired(received.add(const Duration(seconds: 60))), isTrue);
    expect(Deadline.fromSeconds(null, receivedAt: received), isNull);
  });

  test('earliest ignores nulls', () {
    final a = DateTime(2026);
    final b = DateTime(2025);
    expect(earliest([a, null, b]), b);
    expect(earliest([null]), isNull);
  });
}
