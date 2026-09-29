import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/core/xmpp/xmpp.dart';

import 'fake_xmpp_server.dart';

Future<void> _tick([int n = 5]) async {
  for (var i = 0; i < n; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late FakeXmppServer server;
  late FakeCredentials creds;
  late XmppService service;

  XmppService build({
    List<Duration> backoff = const [Duration(milliseconds: 1)],
    Duration keepAlive = const Duration(seconds: 120),
  }) => XmppService(
    puuid: me.toUpperCase(),
    credentials: creds,
    connector: server.connect,
    clock: FixedClock(DateTime.utc(2026, 9, 28, 12)),
    backoff: backoff,
    keepAliveInterval: keepAlive,
    stepTimeout: const Duration(seconds: 2),
  );

  setUp(() {
    server = FakeXmppServer(chunkSeed: 7);
    creds = FakeCredentials();
    service = build();
  });

  tearDown(() => service.dispose());

  test('connects: SASL, stream restart, bind, entitlements, roster, '
      'presence (chunked input)', () async {
    service.start();
    await service.waitUntilConnected();
    final s = service.snapshot;
    expect(s.connection.status, XmppStatus.connected);
    expect(s.rosterLoaded, isTrue);
    expect(s.roster.keys, unorderedEquals([friendA, friendB, friendC]));
    expect(s.roster[friendA]!.name?.riotId, 'Bạn A#VN1');

    final w = server.written.join('\n');
    expect(
      RegExp('<stream:stream to="jp1.pvp.net"').allMatches(w),
      hasLength(2),
    );
    expect(w, contains('mechanism="X-Riot-RSO-PAS"'));
    expect(w, contains('<rso_token>access-1</rso_token>'));
    expect(w, contains('<pas_token>pas-1</pas_token>'));
    expect(w, contains('<token xmlns="">ent-1</token>'));
    expect(w, contains('last_state="true"'));
    expect(server.written.last, '<presence/>');
    expect(service.store.ownResource, 'RC-VALVN');
    expect(server.socket!.serverOpenedStreams, 2);
  });

  test('applies presences, own presence and live messages', () async {
    service.start();
    await service.waitUntilConnected();
    final socket = server.socket!;
    socket
      ..send(valorantPresence(friendA))
      ..send(
        valorantPresence(
          me,
          resource: 'RC-GAME',
          json: nestedPresence(loop: 'INGAME', ally: 7, enemy: 5),
        ),
      )
      // Our own echo is ignored.
      ..send(valorantPresence(me, resource: 'RC-VALVN'))
      ..send(
        '<message from="${jidOf(friendA, 'RC-1')}" to="${jidOf(me)}" '
        'type="chat" id="x1"><body>alo</body></message>',
      );
    await _tick();
    var s = service.snapshot;
    expect(s.presences.keys, [friendA]);
    expect(s.ownPresence?.resource, 'RC-GAME');
    expect(s.ownPresence?.valorant?.allyScore, 7);
    expect(s.unread[friendA], 1);
    expect(service.store.conversation(friendA).messages.single.body, 'alo');

    service.setActiveConversation(friendA);
    await _tick();
    expect(service.snapshot.unread, isEmpty);

    socket.send(
      '<presence from="${jidOf(friendA, 'RC-1')}" type="unavailable"/>',
    );
    await _tick();
    s = service.snapshot;
    expect(s.presences, isEmpty);
    // Went offline just now.
    expect(s.roster[friendA]!.lastOnline, DateTime.utc(2026, 9, 28, 12));
  });

  test('streams emit the current value first, then changes', () async {
    final states = <XmppStatus>[];
    final sub = service.connectionStates.listen((s) => states.add(s.status));
    service.start();
    await service.waitUntilConnected();
    await _tick();
    await sub.cancel();
    expect(states.first, XmppStatus.idle);
    expect(states, contains(XmppStatus.connecting));
    expect(states.last, XmppStatus.connected);
  });

  test('sends messages and loads the archive', () async {
    server.archive =
        '<message from="${jidOf(friendA)}" to="${jidOf(me)}" id="a1" '
        'stamp="2026-09-28 10:00:00"><body>cũ</body></message>';
    service.start();
    await service.waitUntilConnected();
    final sent = await service.sendMessage(friendA, '  <3 & bye  ');
    expect(sent.body, '<3 & bye');
    expect(sent.outgoing, isTrue);
    expect(
      server.written.last,
      allOf(
        contains('to="$friendA@jp1.pvp.net"'),
        contains('type="chat"'),
        contains('<body>&lt;3 &amp; bye</body>'),
      ),
    );
    await service.loadHistory(friendA);
    final conv = service.store.conversation(friendA);
    expect(conv.historyLoaded, isTrue);
    expect(conv.messages.map((m) => m.body), ['cũ', '<3 & bye']);
    expect(service.snapshot.unread, isEmpty);
  });

  test('sendMessage fails while offline', () async {
    expect(
      () => service.sendMessage(friendA, 'hi'),
      throwsA(isA<TransientException>()),
    );
  });

  test(
    'SASL refusal forces one re-auth and reconnects with new tokens',
    () async {
      server.saslFailures = 1;
      service.start();
      await service.waitUntilConnected();
      expect(creds.invalidated, ['access-1']);
      expect(server.authTokens, ['access-1', 'access-2']);
      expect(service.connection.status, XmppStatus.connected);
    },
  );

  test('a second SASL refusal gives up with a 401', () async {
    server.saslFailures = 5;
    service.start();
    await expectLater(
      service.waitUntilConnected(),
      throwsA(isA<RiotApiException>().having((e) => e.status, 'status', 401)),
    );
    expect(service.connection.status, XmppStatus.failed);
    expect(creds.invalidated, hasLength(1));
  });

  test('NeedsLoginException stops without retrying', () async {
    creds.error = const NeedsLoginException(reason: 'dead');
    service.start();
    await expectLater(
      service.waitUntilConnected(),
      throwsA(isA<NeedsLoginException>()),
    );
    expect(service.connection.status, XmppStatus.needsLogin);
    service.start();
    await _tick();
    expect(creds.calls, 1);
  });

  test(
    'reconnects with fresh tokens after the server drops the socket',
    () async {
      service.start();
      await service.waitUntilConnected();
      server.socket!.drop();
      await _tick();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await service.waitUntilConnected();
      expect(server.connects, 2);
      expect(server.authTokens, ['access-1', 'access-2']);
      expect(service.snapshot.roster, hasLength(3));
    },
  );

  test('network failures retry with backoff, then fail', () async {
    server.failConnects = 10;
    service = build(
      backoff: const [Duration(milliseconds: 1), Duration(milliseconds: 1)],
    );
    service.start();
    for (
      var i = 0;
      i < 20 && service.connection.status != XmppStatus.failed;
      i++
    ) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(service.connection.status, XmppStatus.failed);
    expect(service.connection.error, isA<TransientException>());
    expect(server.connects, 3);

    server.failConnects = 0;
    await service.retryNow();
    await service.waitUntilConnected();
    expect(service.connection.status, XmppStatus.connected);
  });

  test(
    'stop closes the stream but keeps the roster; start reconnects',
    () async {
      service.start();
      await service.waitUntilConnected();
      await service.stop();
      expect(server.written.last, '</stream:stream>');
      expect(server.socket!.closed, isTrue);
      expect(service.connection.status, XmppStatus.idle);
      expect(service.snapshot.roster, hasLength(3));
      service.start();
      await service.waitUntilConnected();
      expect(server.connects, 2);
    },
  );

  test('writes a keep-alive space', () async {
    service = build(keepAlive: const Duration(milliseconds: 5));
    service.start();
    await service.waitUntilConnected();
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(server.written, contains(' '));
  });

  test('roster pushes are applied and acknowledged', () async {
    service.start();
    await service.waitUntilConnected();
    server.socket!.send(
      '<iq type="set" id="push1"><query xmlns="jabber:iq:riotgames:roster">'
      '<item jid="$friendB@jp1.pvp.net" subscription="remove"/>'
      '</query></iq>',
    );
    await _tick();
    expect(service.snapshot.roster.keys, isNot(contains(friendB)));
    expect(server.written.last, '<iq type="result" id="push1"/>');
  });

  test('a stream error drops the connection and reconnects', () async {
    service.start();
    await service.waitUntilConnected();
    final completer = Completer<void>();
    final sub = service.connectionStates.listen((s) {
      if (s.status == XmppStatus.reconnecting && !completer.isCompleted) {
        completer.complete();
      }
    });
    server.socket!.send(
      '<stream:error><conflict xmlns="urn:ietf:params:xml:ns:xmpp-streams"/>'
      '</stream:error>',
    );
    await completer.future.timeout(const Duration(seconds: 1));
    await sub.cancel();
    await service.waitUntilConnected();
    expect(server.connects, 2);
  });
}
