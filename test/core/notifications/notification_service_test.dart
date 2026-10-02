import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/l10n/gen/app_localizations_vi.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/prefs.dart';

import '../../helpers/test_prefs.dart';

class RecordingAndroid extends AndroidFlutterLocalNotificationsPlugin {
  final channels = <String, AndroidNotificationChannel>{};
  int deletions = 0;
  int permissionPrompts = 0;
  bool failNext = false;
  @override
  Future<void> createNotificationChannel(
    AndroidNotificationChannel channel,
  ) async {
    if (failNext) {
      failNext = false;
      throw StateError('simulated channel update failure');
    }
    channels[channel.id] = channel;
  }

  @override
  Future<void> deleteNotificationChannel({required String channelId}) async =>
      deletions++;
  @override
  Future<bool?> requestNotificationsPermission() async {
    permissionPrompts++;
    return true;
  }
}

class ProbeNotificationMessages extends AppLocalizationsVi {
  ProbeNotificationMessages(super.locale);
  @override
  String get notificationChannelStoreResetName => 'QA reset';
  @override
  String get notificationChannelStoreResetDescription => 'QA reminder';
  @override
  String get notificationPrivateAccount => 'QA private account';
  @override
  String get notificationLfgJoinedTitle => 'QA party join';
}

class RecordingPlugin extends Mock implements FlutterLocalNotificationsPlugin {
  final android = RecordingAndroid();
  @override
  T? resolvePlatformSpecificImplementation<
    T extends FlutterLocalNotificationsPlatform
  >() => T == AndroidFlutterLocalNotificationsPlugin ? android as T : null;
  DidReceiveNotificationResponseCallback? onTap;
  NotificationDetails? details;
  String? title;
  String? body;
  int shows = 0;
  int initializations = 0;
  Completer<void>? initializationGate;
  bool pendingFails = false;
  final pending = <int, PendingNotificationRequest>{};
  final cancelled = <int>[];
  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) async {
    initializations++;
    await initializationGate?.future;
    onTap = onDidReceiveNotificationResponse;
    return true;
  }

  @override
  Future<NotificationAppLaunchDetails?>
  getNotificationAppLaunchDetails() async =>
      const NotificationAppLaunchDetails(false);
  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  }) async {
    shows++;
    this.title = title;
    this.body = body;
    details = notificationDetails;
  }

  @override
  Future<void> cancel({required int id, String? tag}) async {
    cancelled.add(id);
    pending.remove(id);
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    if (pendingFails) throw StateError('probe unavailable');
    return pending.values.toList();
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? title,
    String? body,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    pending[id] = PendingNotificationRequest(id, title, body, payload);
  }
}

void main() {
  late Prefs prefs;
  late RecordingPlugin plugin;
  late NotificationService service;
  const account = Account(
    puuid: 'a',
    gameName: 'Tên',
    tagLine: '日本語',
    region: 'ap',
    shard: 'ap',
  );
  setUp(() async {
    tzdata.initializeTimeZones();
    prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [account.toJson()]);
    plugin = RecordingPlugin();
    service = NotificationService(plugin: plugin, prefs: prefs);
  });
  tearDown(() => service.dispose());

  test(
    'channel refresh updates metadata with stable ids and no permission/delete',
    () async {
      await service.init();
      expect(
        plugin.android.channels.keys.toSet(),
        NotificationChannel.values.map((c) => c.id).toSet(),
      );
      await service.refreshChannels(ProbeNotificationMessages('qa'));
      final channel =
          plugin.android.channels[NotificationChannel.storeReset.id]!;
      expect(channel.name, 'QA reset');
      expect(channel.description, 'QA reminder');
      expect(plugin.android.deletions, 0);
      expect(plugin.android.permissionPrompts, 0);
      await service.showNow(
        id: 123,
        title: 'Tên#日本語',
        body: 'Tên#日本語',
        channel: NotificationChannel.storeReset,
        accountPuuid: account.puuid,
      );
      expect(plugin.title, 'QA private account');
      expect(plugin.details!.android!.channelName, 'QA reset');
    },
  );

  test('channel refresh recovers after a native failure', () async {
    await service.init();
    plugin.android.failNext = true;
    await expectLater(
      service.refreshChannels(ProbeNotificationMessages('qa')),
      throwsStateError,
    );
    await service.refreshChannels(ProbeNotificationMessages('qa'));
    expect(
      plugin.android.channels[NotificationChannel.storeReset.id]!.name,
      'QA reset',
    );
    expect(plugin.initializations, 1);
    expect(plugin.android.deletions, 0);
  });

  Future<void> schedule(int id, {String body = 'body'}) => service.scheduleAt(
    id: id,
    at: DateTime.now().add(const Duration(days: 1)),
    title: 'title',
    body: body,
    channel: NotificationChannel.storeReset,
    accountPuuid: account.puuid,
  );

  test(
    'parallel schedules preserve the 60-slot budget; replacement works',
    () async {
      await Future.wait([for (var i = 0; i < 70; i++) schedule(i)]);
      expect(plugin.pending.length, NotificationService.maxPending);
      expect(plugin.pending.containsKey(60), isFalse);
      await schedule(0, body: 'replacement');
      expect(plugin.pending.length, NotificationService.maxPending);
      expect(plugin.pending[0]!.body, 'replacement');
    },
  );

  test(
    'failed pending probe preserves old reminders and next schedule recovers',
    () async {
      await schedule(0);
      plugin.pendingFails = true;
      await expectLater(schedule(0, body: 'new'), throwsStateError);
      expect(plugin.pending[0]!.body, 'body');
      plugin.pendingFails = false;
      await schedule(0, body: 'new');
      expect(plugin.pending[0]!.body, 'new');
    },
  );

  test(
    'concurrent init waits for native completion and migrates once',
    () async {
      plugin.initializationGate = Completer<void>();
      final first = service.init();
      final second = service.init();
      final queued = schedule(1);
      await Future<void>.delayed(Duration.zero);
      expect(plugin.initializations, 1);
      expect(plugin.pending, isEmpty);
      plugin.initializationGate!.complete();
      await Future.wait([first, second, queued]);
      expect(plugin.initializations, 1);
      for (final day in [5, 6]) {
        expect(
          plugin.cancelled
              .where((id) => id == NotificationIds.storeResetDay('a', day))
              .length,
          1,
        );
      }
      expect(prefs.getInt('app.notificationScheduleSchema'), 2);
      expect(plugin.pending.keys, [1]);
      await service.init();
      expect(plugin.initializations, 1);
    },
  );

  test('private visibility; Riot IDs removed on both platforms', () async {
    await service.showNow(
      id: 1,
      title: 'Tên#日本語',
      body: 'For Tên#日本語',
      channel: NotificationChannel.account,
      accountPuuid: 'a',
    );
    expect(plugin.details!.android!.visibility, NotificationVisibility.private);
    expect(plugin.title, isNot(contains('Tên#日本語')));
    expect(plugin.body, isNot(contains('Tên#日本語')));
    await service.cancelForAccount('a');
    expect(plugin.cancelled, contains(1));
  });

  test('legacy LFG alerts use their own opt-in channel', () async {
    Future<void> show() => service.showNow(
      id: 2,
      title: 'someone joined',
      body: 'party',
      channel: NotificationChannel.account,
      payload: '/community?section=lfg&account=a',
      accountPuuid: 'a',
    );
    await show();
    expect(plugin.shows, 0);
    await prefs.setJson(
      PrefKeys.appSettings,
      const AppSettings(lfgNotifications: true).toJson(),
    );
    await show();
    expect(plugin.shows, 1);
    expect(plugin.details!.android!.channelId, NotificationChannel.lfg.id);
  });

  test('a Riot game name containing spaces is removed completely', () async {
    final spaced = account.copyWith(gameName: 'Tên Có Khoảng Trắng');
    await prefs.setJson(PrefKeys.accounts, [spaced.toJson()]);
    await service.showNow(
      id: 4,
      title: spaced.riotId,
      body: 'For ${spaced.riotId}',
      channel: NotificationChannel.wishlist,
      accountPuuid: spaced.puuid,
    );
    expect(plugin.title, isNot(contains(spaced.gameName)));
    expect(plugin.body, isNot(contains('Tên')));
  });

  test('removed-account notification never opens another account', () async {
    final taps = <String>[];
    final sub = service.taps.listen(taps.add);
    await service.init();
    plugin.onTap!(
      const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        payload: '/store?account=gone',
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(taps, isEmpty);
    plugin.onTap!(
      const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        payload: '/store?account=a',
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(taps, ['/store?account=a']);
    await sub.cancel();
  });

  test('late alert for a removed account is dropped', () async {
    await prefs.setJson(PrefKeys.accounts, []);
    await service.showNow(
      id: 3,
      title: 'title',
      body: 'body',
      channel: NotificationChannel.account,
      accountPuuid: 'a',
    );
    expect(plugin.shows, 0);
    expect(prefs.keys.where((key) => key.startsWith('acct.a.')), isEmpty);
  });
}
