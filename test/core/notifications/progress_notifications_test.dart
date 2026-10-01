import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/domain/progress_events.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/notifications/progress_notifications.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/util/clock.dart';

import '../../helpers/test_prefs.dart';

class Notifications extends NotificationService {
  final shown = <NotificationChannel>[];
  final scheduled = <int, DateTime>{};
  final payloads = <String?>[];
  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required NotificationChannel channel,
    String? payload,
    String? accountPuuid,
    String? tag,
  }) async {
    shown.add(channel);
    payloads.add(payload);
  }

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
  }) async {
    scheduled[id] = at;
    payloads.add(payload);
  }

  @override
  Future<void> cancel(int id, {String? tag}) async {
    scheduled.remove(id);
  }
}

void main() {
  const account = Account(
    puuid: 'own',
    gameName: 'Me',
    tagLine: 'TAG',
    region: 'ap',
    shard: 'ap',
  );
  final now = DateTime.utc(2026, 10, 1);
  late Prefs prefs;
  late Notifications notifications;
  late ProgressNotificationPlanner planner;
  setUp(() async {
    prefs = await createTestPrefs();
    await prefs.setJson(
      PrefKeys.appSettings,
      const AppSettings(
        rankNotifications: true,
        battlePassNotifications: true,
      ).toJson(),
    );
    notifications = Notifications();
    planner = ProgressNotificationPlanner(
      prefs,
      notifications,
      FixedClock(now),
    );
  });
  test('rank baseline is silent, changed tier notifies once, season reset stays silent', () async {
    Future<void> record(String season, int tier) => planner.observe(
      RankObserved('own', season, tier),
      account: () => account,
    );
    await record('season', 12);
    expect(notifications.shown, isEmpty);
    await record('season', 13);
    await record('season', 13);
    expect(notifications.shown, [NotificationChannel.rank]);
    expect(notifications.payloads.single, '/profile?account=own');
    await record('next-season', 14);
    expect(notifications.shown.length, 1);
  });
  test(
    'one end reminder per account is replaced and completion cancels it',
    () async {
      Future<void> record(int level, {String pass = 'pass'}) => planner.observe(
        PassObserved('own', pass, level, 55, now.add(const Duration(days: 5))),
        account: () => account,
      );
      await record(9);
      expect(notifications.shown, isEmpty);
      expect(
        notifications.scheduled.values.single,
        now.add(const Duration(days: 4)),
      );
      await record(10);
      expect(notifications.shown, [NotificationChannel.battlePass]);
      await record(10);
      expect(notifications.shown.length, 1);
      expect(notifications.scheduled.length, 1);
      await record(55);
      expect(notifications.scheduled, isEmpty);
      await record(20, pass: 'another-pass');
      expect(notifications.shown.length, 2);
    },
  );
  test(
    'disabled categories and removed accounts do not produce alerts',
    () async {
      await prefs.setJson(PrefKeys.appSettings, const AppSettings().toJson());
      await planner.observe(
        const RankObserved('own', 's', 12),
        account: () => account,
      );
      await planner.observe(
        const RankObserved('own', 's', 13),
        account: () => account,
      );
      await planner.observe(
        PassObserved('own', 'pass', 10, 55, now.add(const Duration(days: 5))),
        account: () => account,
      );
      expect(notifications.shown, isEmpty);
      expect(notifications.scheduled, isEmpty);
      await planner.observe(
        const RankObserved('gone', 's', 20),
        account: () => null,
      );
      expect(
        prefs.containsKey(PrefKeys.account('gone', 'notification.rankSeen')),
        false,
      );
    },
  );
}
