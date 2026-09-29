import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/battlepass/data/daily_ticket.dart';

import '../bp_fixtures.dart';

void main() {
  group('DailyTicket.fromJson', () {
    test('parses the DailyRewards wrapper', () {
      final t = DailyTicket.fromJson(dailyTicketJson(), receivedAt: t0);
      expect(t.milestones, hasLength(4));
      expect(t.milestones.map((m) => m.progress), [4, 3, 0, 0]);
      expect(t.milestones.first.bonusApplied, isTrue);
      expect(t.milestones.first.isComplete, isTrue);
      expect(t.completedCount, 1);
      expect(t.currentIndex, 1);
      expect(t.currentCharges, 3);
      expect(t.isAllComplete, isFalse);
      expect(t.hasMilestones, isTrue);
      expect(t.expiresAt, t0.add(const Duration(seconds: 13177)));
      expect(t.isExpired(t0), isFalse);
      expect(t.isExpired(t0.add(const Duration(seconds: 13177))), isTrue);
    });

    test('falls back to the root object (SUMMARY U6)', () {
      final t = DailyTicket.fromJson(
        dailyTicketJson(wrapped: false, progress: [4, 4, 4, 4]),
        receivedAt: t0,
      );
      expect(t.completedCount, 4);
      expect(t.isAllComplete, isTrue);
      expect(t.currentIndex, isNull);
      expect(t.currentCharges, 0);
    });

    test('pads, truncates and clamps milestones', () {
      final short = DailyTicket.fromJson(
        dailyTicketJson(progress: [9, -2]),
        receivedAt: t0,
      );
      expect(short.milestones.map((m) => m.progress), [4, 0, 0, 0]);
      final long = DailyTicket.fromJson(
        dailyTicketJson(progress: [4, 4, 4, 4, 4, 4]),
        receivedAt: t0,
      );
      expect(long.milestones, hasLength(4));
      expect(long.milestones.first.fraction, 1);
      expect(short.milestones[1].fraction, 0);
    });

    test('never throws on odd payloads', () {
      for (final json in <Object?>[
        null,
        '<html>',
        const <Object?>[],
        const {'DailyRewards': null},
        const {
          'DailyRewards': {'Milestones': 'x', 'RemainingLifetimeSeconds': 'y'},
        },
      ]) {
        final t = DailyTicket.fromJson(json, receivedAt: t0);
        expect(t.milestones, hasLength(4));
        expect(t.completedCount, 0);
        expect(t.expiresAt, isNull);
        expect(t.hasMilestones, isFalse);
        expect(t.isExpired(t0), isFalse);
      }
    });

    test('an expired ticket (remaining <= 0)', () {
      final t = DailyTicket.fromJson(
        dailyTicketJson(remaining: -20),
        receivedAt: t0,
      );
      expect(t.isExpired(t0), isTrue);
    });
  });

  group('canRenewDailyTicket', () {
    final live = DailyTicket.fromJson(dailyTicketJson(), receivedAt: t0);
    final expired = DailyTicket.fromJson(
      dailyTicketJson(remaining: 0),
      receivedAt: t0,
    );

    test('only when missing or expired', () {
      expect(canRenewDailyTicket(ticket: live, now: t0), isFalse);
      expect(canRenewDailyTicket(ticket: null, now: t0), isTrue);
      expect(canRenewDailyTicket(ticket: expired, now: t0), isTrue);
    });

    test('at most once per day', () {
      expect(
        canRenewDailyTicket(
          ticket: null,
          now: t0,
          lastRenewAt: t0.subtract(const Duration(hours: 3)),
        ),
        isFalse,
      );
      expect(
        canRenewDailyTicket(
          ticket: expired,
          now: t0,
          lastRenewAt: t0.subtract(kDailyTicketRenewInterval),
        ),
        isTrue,
      );
    });
  });
}
