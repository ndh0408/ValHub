import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/features/store/providers/store_reset_reminder.dart';
import 'package:valvn/features/store/store_strings.dart';

import '../../core/domain/economy/economy_fixtures.dart';
import 'store_test_harness.dart';

class _ThrowingNotificationService extends NotificationService {
  @override
  Future<void> scheduleAt({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required NotificationChannel channel,
    String? payload,
    String? accountPuuid,
    String? tag,
  }) async => throw StateError('plugin');
}

void main() {
  final store = Storefront.fromJson(
    economyFixture('storefront.json'),
    receivedAt: t0,
  );

  group('storeResetReminderFor', () {
    test('one minute after the daily reset, with the VF §6.9 copy', () {
      final r = storeResetReminderFor(
        account: testAccount,
        store: store,
        now: t0,
      )!;
      expect(r.id, NotificationIds.storeReset(Fx.puuid));
      expect(r.at, t0.add(const Duration(seconds: 17401, minutes: 1)));
      expect(r.title, 'Cửa hàng đã làm mới');
      expect(r.body, 'Xem 4 skin mới hôm nay của Người Chơi#VN2.');
      expect(r.payload, '/store?account=${Fx.puuid}');
      expect(r.accountPuuid, Fx.puuid);
    });

    test('null without a reset time or once it has passed', () {
      expect(
        storeResetReminderFor(
          account: testAccount,
          store: Storefront.fromJson(const {}, receivedAt: t0),
          now: t0,
        ),
        isNull,
      );
      expect(
        storeResetReminderFor(
          account: testAccount,
          store: store,
          now: t0.add(const Duration(hours: 5)),
        ),
        isNull,
      );
    });

    test('generic body when the daily shop is empty', () {
      expect(
        StoreStrings.resetNotificationBody(0, 'A#1'),
        'Xem skin mới hôm nay của A#1.',
      );
    });
  });

  group('scheduleStoreResetReminder', () {
    test('schedules on the store-reset channel', () async {
      final service = RecordingNotificationService();
      final ok = await scheduleStoreResetReminder(
        service,
        account: testAccount,
        store: store,
        now: t0,
      );
      expect(ok, isTrue);
      expect(service.calls.single.channel, NotificationChannel.storeReset);
    });

    test('is best effort: platform failures return false', () async {
      final ok = await scheduleStoreResetReminder(
        _ThrowingNotificationService(),
        account: testAccount,
        store: store,
        now: t0,
      );
      expect(ok, isFalse);
    });

    test('nothing to schedule returns false', () async {
      final service = RecordingNotificationService();
      final ok = await scheduleStoreResetReminder(
        service,
        account: testAccount,
        store: Storefront.fromJson(const {}, receivedAt: t0),
        now: t0,
      );
      expect(ok, isFalse);
      expect(service.calls, isEmpty);
    });
  });
}
