import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/auth/auth_providers.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/core/xmpp/xmpp.dart';

import '../../helpers/test_prefs.dart';
import 'fake_xmpp_server.dart';

class MockPvpApi extends Mock implements PvpApi {}

class MockSessionManager extends Mock implements SessionManager {}

class TestForeground extends AppForegroundNotifier {
  @override
  bool build() => true;

  void set(bool value) => state = value;
}

const _account = Account(
  puuid: me,
  gameName: 'Tôi',
  tagLine: 'VN1',
  region: 'ap',
  shard: 'ap',
);

Future<void> _settle() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
}

void main() {
  setUpAll(() => registerFallbackValue(<String>[]));

  late FakeXmppServer server;
  late FakeCredentials creds;
  late MockPvpApi api;
  late ProviderContainer container;

  setUp(() async {
    server = FakeXmppServer();
    creds = FakeCredentials();
    api = MockPvpApi();
    final sessions = MockSessionManager();
    when(() => sessions.events).thenAnswer((_) => const Stream.empty());
    when(() => api.names(any(), any())).thenAnswer(
      (_) async => [
        {'Subject': friendC, 'GameName': 'Cường', 'TagLine': 'VN2'},
      ],
    );
    final prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [_account.toJson()]);
    await prefs.setString(PrefKeys.activePuuid, me);
    container = ProviderContainer.test(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        secureStoreProvider.overrideWithValue(MemorySecureStore()),
        sessionManagerProvider.overrideWithValue(sessions),
        pvpApiProvider.overrideWithValue(api),
        clockProvider.overrideWithValue(
          FixedClock(DateTime.utc(2026, 9, 28, 12)),
        ),
        appForegroundProvider.overrideWith(TestForeground.new),
        xmppConnectorProvider.overrideWithValue(server.connect),
        xmppCredentialSourceProvider.overrideWithValue(creds),
      ],
    );
  });

  test(
    'friendsProvider: loading, then the roster with resolved names',
    () async {
      final sub = container.listen(friendsProvider, (_, _) {});
      expect(sub.read().isLoading, isTrue);
      await _settle();
      final view = sub.read().requireValue;
      expect(view.offline.map((f) => f.name?.riotId), [
        'Bạn A#VN1',
        'Bee#0001',
        'Cường#VN2',
      ]);
      expect(view.connection.status, XmppStatus.connected);

      server.socket!.send(valorantPresence(friendB));
      await _settle();
      expect(sub.read().requireValue.online.single.puuid, friendB);
      expect(container.read(onlineFriendsProvider).single.puuid, friendB);
      sub.close();
    },
  );

  test(
    'disconnects in the background and reconnects in the foreground',
    () async {
      final sub = container.listen(friendsProvider, (_, _) {});
      await _settle();
      final service = container.read(xmppServiceProvider)!;
      expect(service.isConnected, isTrue);

      (container.read(appForegroundProvider.notifier) as TestForeground).set(
        false,
      );
      await _settle();
      expect(service.isConnected, isFalse);
      expect(server.socket!.closed, isTrue);
      expect(sub.read().requireValue.offline, hasLength(3)); // roster kept

      (container.read(appForegroundProvider.notifier) as TestForeground).set(
        true,
      );
      await _settle();
      expect(service.isConnected, isTrue);
      expect(server.connects, 2);
      sub.close();
    },
  );

  test('needsLogin stops the chat; signing in again reconnects', () async {
    final sub = container.listen(friendsProvider, (_, _) {});
    await _settle();
    await container
        .read(accountsProvider.notifier)
        .updateAccount(me, (a) => a.copyWith(needsLogin: true));
    await _settle();
    final service = container.read(xmppServiceProvider)!;
    expect(service.connection.status, XmppStatus.needsLogin);

    await container
        .read(accountsProvider.notifier)
        .updateAccount(me, (a) => a.copyWith(needsLogin: false));
    await _settle();
    expect(service.connection.status, XmppStatus.connected);
    expect(creds.calls, 2);
    sub.close();
  });

  test(
    'conversationProvider loads the archive and marks messages read',
    () async {
      server.archive =
          '<message from="${jidOf(friendA)}" to="${jidOf(me)}" id="h1" '
          'stamp="2026-09-28 10:00:00"><body>xin chào</body></message>';
      final friends = container.listen(friendsProvider, (_, _) {});
      await _settle();
      server.socket!.send(
        '<message from="${jidOf(friendA, 'RC')}" type="chat" id="n1">'
        '<body>mới</body></message>',
      );
      await _settle();
      expect(friends.read().requireValue.byPuuid(friendA)!.unread, 1);

      final conv = container.listen(conversationProvider(friendA), (_, _) {});
      await _settle();
      expect(conv.read().requireValue.messages.map((m) => m.body), [
        'xin chào',
        'mới',
      ]);
      expect(friends.read().requireValue.byPuuid(friendA)!.unread, 0);
      conv.close();
      friends.close();
    },
  );

  test('ownPresenceProvider follows the game client presence', () async {
    final own = container.listen(ownPresenceProvider, (_, _) {});
    await _settle();
    server.socket!.send(
      valorantPresence(
        me,
        resource: 'RC-GAME',
        json: nestedPresence(loop: 'INGAME', ally: 4, enemy: 2),
      ),
    );
    await _settle();
    expect(own.read().value?.valorant?.hasScore, isTrue);
    own.close();
  });
}
