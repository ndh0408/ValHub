import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/prefs.dart';

import '../../helpers/test_prefs.dart';

class RecordingPlugin extends Mock implements FlutterLocalNotificationsPlugin {
  DidReceiveNotificationResponseCallback? onTap;
  NotificationDetails? details;
  String? title;
  String? body;
  int shows = 0;
  final cancelled = <int>[];
  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) async {
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
  Future<void> cancel({required int id, String? tag}) async =>
      cancelled.add(id);
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
    prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [account.toJson()]);
    plugin = RecordingPlugin();
    service = NotificationService(plugin: plugin, prefs: prefs);
  });
  tearDown(() => service.dispose());

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
