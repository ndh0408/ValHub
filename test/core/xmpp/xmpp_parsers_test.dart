import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/names.dart';
import 'package:valvn/core/xmpp/xmpp_models.dart';
import 'package:valvn/core/xmpp/xmpp_parsers.dart';
import 'package:xml/xml.dart';

import '../../helpers/jwt.dart';
import 'fake_xmpp_server.dart';

XmlElement _el(String xml) => XmlDocument.parse(xml).rootElement;

final _now = DateTime.utc(2026, 9, 28, 12);

void main() {
  group('timestamps', () {
    test('parseRiotTimestamp reads Riot, ISO and epoch formats as UTC', () {
      expect(
        parseRiotTimestamp('2025-03-11 22:00:04.505'),
        DateTime.utc(2025, 3, 11, 22, 0, 4, 505),
      );
      expect(
        parseRiotTimestamp('2026-09-28T10:00:00+07:00'),
        DateTime.utc(2026, 9, 28, 3),
      );
      expect(parseRiotTimestamp('1790000000000'), isNotNull);
      expect(
        parseRiotTimestamp(1790000000),
        DateTime.fromMillisecondsSinceEpoch(1790000000000, isUtc: true),
      );
      expect(parseRiotTimestamp('0001-01-01 00:00:00'), isNull);
      expect(parseRiotTimestamp('garbage'), isNull);
      expect(parseRiotTimestamp(null), isNull);
    });

    test('parseQueueEntryTime reads the presence format', () {
      expect(
        parseQueueEntryTime('2026.04.23-22.40.57'),
        DateTime.utc(2026, 4, 23, 22, 40, 57),
      );
      expect(parseQueueEntryTime('0001.01.01-00.00.00'), isNull);
      expect(parseQueueEntryTime(''), isNull);
    });
  });

  group('presence JSON', () {
    test('nested 2024+ format', () {
      final p = presenceSnapshotFromJson(
        nestedPresence(
          loop: 'INGAME',
          map: '/Game/Maps/Ascent/Ascent',
          ally: 8,
          enemy: 4,
        ),
      )!;
      expect(p.loopState, LoopState.ingame);
      expect(p.matchMap, '/Game/Maps/Ascent/Ascent');
      expect(p.queueId, 'competitive');
      expect(p.partyId, '62d30f62-98c0-4f6f-8380-350a84aac00e');
      expect(p.partySize, 2);
      expect(p.maxPartySize, 5);
      expect(p.isPartyOwner, isTrue);
      expect(p.allyScore, 8);
      expect(p.enemyScore, 4);
      expect(p.hasScore, isTrue);
      expect(p.competitiveTier, 18);
      expect(p.accountLevel, 98);
      expect(p.playerCardId, '1711d20d-4b1c-c64a-14be-d4ae58a457c6');
      expect(p.queueEntryTime, DateTime.utc(2026, 9, 28, 11, 58, 30));
    });

    test('old flat format as a fallback', () {
      final p = presenceSnapshotFromJson({
        'isIdle': 'true',
        'sessionLoopState': 'PREGAME',
        'partyOwnerMatchMap': '/Game/Maps/Bonsai/Bonsai',
        'queueId': 'Unrated',
        'partyState': 'DEFAULT',
        'partySize': '3',
        'competitiveTier': 12.0,
        'playerCardId': 'ABC',
        'partyOwnerMatchScoreAllyTeam': 0,
        'partyOwnerMatchScoreEnemyTeam': 0,
      })!;
      expect(p.isIdle, isTrue);
      expect(p.loopState, LoopState.pregame);
      expect(p.matchMap, '/Game/Maps/Bonsai/Bonsai');
      expect(p.queueId, 'unrated');
      expect(p.partySize, 3);
      expect(p.competitiveTier, 12);
      expect(p.playerCardId, 'abc');
      expect(p.hasScore, isFalse);
    });

    test('0 – 0 in a match is not a score (U9)', () {
      final p = presenceSnapshotFromJson(nestedPresence(loop: 'INGAME'))!;
      expect(p.hasScore, isFalse);
    });

    test('decodes base64 (padded, unpadded, URL-safe) and plain JSON', () {
      final json = jsonEncode({'sessionLoopState': 'INGAME', 'x': '???>>>'});
      final std = base64.encode(utf8.encode(json));
      final url = base64Url.encode(utf8.encode(json)).replaceAll('=', '');
      expect(decodeValorantPresence(std)?.loopState, LoopState.ingame);
      expect(decodeValorantPresence(url)?.loopState, LoopState.ingame);
      expect(decodeValorantPresence(json)?.loopState, LoopState.ingame);
      expect(decodeValorantPresence('%%%not base64'), isNull);
      expect(decodeValorantPresence(base64.encode(utf8.encode('[1]'))), isNull);
      expect(decodeValorantPresence(''), isNull);
    });
  });

  group('presence stanza', () {
    test('Valorant presence', () {
      final p = parsePresence(
        _el(
          valorantPresence(
            friendA,
            json: nestedPresence(loop: 'INGAME', ally: 3, enemy: 1),
          ),
        ),
        receivedAt: _now,
      )!;
      expect(p.puuid, friendA);
      expect(p.resource, 'RC-1');
      expect(p.available, isTrue);
      expect(p.show, PresenceShow.chat);
      expect(p.product, 'valorant');
      expect(p.platform, 'PC');
      expect(p.inValorant, isTrue);
      expect(p.valorant!.allyScore, 3);
      expect(p.timestamp, isNotNull);
    });

    test('away and League presences', () {
      final away = parsePresence(
        _el(valorantPresence(friendA, show: 'away')),
        receivedAt: _now,
      )!;
      expect(away.isAway, isTrue);

      final lol = parsePresence(
        _el(
          '<presence from="${jidOf(friendB, 'RC-2')}"><games>'
          '<keystone><st>chat</st></keystone>'
          '<league_of_legends><st>dnd</st><s.t>1</s.t></league_of_legends>'
          '</games></presence>',
        ),
        receivedAt: _now,
      )!;
      expect(lol.product, 'league_of_legends');
      expect(lol.show, PresenceShow.dnd);
      expect(lol.inValorant, isFalse);
    });

    test('undecodable Valorant payload still counts as in Valorant', () {
      final p = parsePresence(
        _el(
          '<presence from="${jidOf(friendA, 'RC')}"><games><valorant>'
          '<p>!!!</p></valorant></games></presence>',
        ),
        receivedAt: _now,
      )!;
      expect(p.inValorant, isTrue);
      expect(p.valorant!.loopState, LoopState.unknown);
    });

    test('unavailable, subscription and malformed presences', () {
      final off = parsePresence(
        _el('<presence from="${jidOf(friendA, 'RC-1')}" type="unavailable"/>'),
        receivedAt: _now,
      )!;
      expect(off.available, isFalse);
      expect(
        parsePresence(
          _el('<presence from="${jidOf(friendA)}" type="subscribe"/>'),
          receivedAt: _now,
        ),
        isNull,
      );
      expect(
        parsePresence(_el('<presence from="nobody"/>'), receivedAt: _now),
        isNull,
      );
      expect(parsePresence(_el('<message/>'), receivedAt: _now), isNull);
    });

    test('bestPresence prefers Valorant, then the newest', () {
      final keystone = FriendPresence(
        puuid: friendA,
        resource: 'a',
        product: 'keystone',
        receivedAt: _now,
      );
      final valorant = FriendPresence(
        puuid: friendA,
        resource: 'b',
        product: 'valorant',
        valorant: const PresenceSnapshot(),
        receivedAt: _now.subtract(const Duration(hours: 1)),
      );
      expect(bestPresence([keystone, valorant]), valorant);
      expect(bestPresence([keystone]), keystone);
      expect(bestPresence(const []), isNull);
    });
  });

  group('roster', () {
    test('parses items, names and last_online', () {
      final items = parseRosterItems(
        _el(
          '<iq type="result"><query xmlns="jabber:iq:riotgames:roster">'
          '$rosterItems</query></iq>',
        ),
      );
      expect(items, hasLength(4));
      final a = items[0];
      expect(a.puuid, friendA);
      expect(a.jid, '$friendA@jp1.pvp.net');
      expect(a.name, const RiotName(gameName: 'Bạn A', tagLine: 'VN1'));
      expect(a.lastOnline, DateTime.utc(2026, 9, 28, 10, 0, 4, 505));
      expect(a.state, 'online');
      expect(a.isFriend, isTrue);
      expect(items[1].name?.riotId, 'Bee#0001');
      expect(items[2].puuid, friendC);
      expect(items[2].name, isNull);
      expect(items[2].lastOnline, isNull);
      expect(items[3].isFriend, isFalse);
    });

    test('skips items without an id and handles removals', () {
      final items = parseRosterItems(
        _el(
          '<query><item/><item jid="$friendA@jp1.pvp.net" '
          'subscription="remove"/></query>',
        ),
      );
      expect(items.single.isRemoval, isTrue);
      expect(items.single.isFriend, isFalse);
    });
  });

  group('messages', () {
    test('incoming and outgoing chat messages', () {
      final incoming = parseChatMessage(
        _el(
          '<message from="${jidOf(friendA, 'RC-1')}" to="${jidOf(me)}" '
          'stamp="2026-09-28 11:00:00.000" id="1:1" type="chat">'
          '<body>chào &amp; tạm biệt</body></message>',
        ),
        ownPuuid: me,
        receivedAt: _now,
      )!;
      expect(incoming.outgoing, isFalse);
      expect(incoming.friendPuuid, friendA);
      expect(incoming.body, 'chào & tạm biệt');
      expect(incoming.at, DateTime.utc(2026, 9, 28, 11));
      expect(incoming.id, '1:1');

      final outgoing = parseChatMessage(
        _el(
          '<message from="${jidOf(me, 'RC-9')}" to="${jidOf(friendA)}">'
          '<body>ok</body><delay stamp="2026-09-28T11:05:00Z"/></message>',
        ),
        ownPuuid: me.toUpperCase(),
        receivedAt: _now,
      )!;
      expect(outgoing.outgoing, isTrue);
      expect(outgoing.friendPuuid, friendA);
      expect(outgoing.at, DateTime.utc(2026, 9, 28, 11, 5));
      expect(outgoing.id, startsWith('m-'));
    });

    test('ignores group chat, errors and empty bodies', () {
      for (final xml in [
        '<message from="${jidOf(friendA)}" type="groupchat"><body>x</body></message>',
        '<message from="${jidOf(friendA)}" type="error"><body>x</body></message>',
        '<message from="${jidOf(friendA)}"><body>   </body></message>',
        '<message from="${jidOf(friendA)}"/>',
        '<message from="garbage"><body>x</body></message>',
      ]) {
        expect(
          parseChatMessage(_el(xml), ownPuuid: me, receivedAt: _now),
          isNull,
          reason: xml,
        );
      }
    });

    test('archive results are sorted oldest first', () {
      final history = parseArchive(
        _el(
          '<iq type="result"><query xmlns="jabber:iq:riotgames:archive">'
          '<message from="${jidOf(friendA)}" to="${jidOf(me)}" id="2" '
          'stamp="2026-09-28 11:00:00"><body>b</body></message>'
          '<message from="${jidOf(me)}" to="${jidOf(friendA)}" id="1" '
          'stamp="2026-09-28 10:00:00"><body>a</body></message>'
          '</query></iq>',
        ),
        ownPuuid: me,
        receivedAt: _now,
      );
      expect(history.map((m) => m.body), ['a', 'b']);
      expect(history.first.outgoing, isTrue);
    });
  });

  group('endpoint', () {
    final pas = fakeJwt({'affinity': 'jp1', 'sub': me});

    test('uses the PAS affinity and flat client-config keys', () {
      final e = resolveXmppEndpoint(
        pasToken: pas,
        clientConfig: {
          'chat.affinities': {'jp1': 'jp1.chat.si.riotgames.com'},
          'chat.affinity_domains': {'jp1': 'jp1'},
          'chat.port': 5223,
        },
        region: 'ap',
      )!;
      expect(e.host, 'jp1.chat.si.riotgames.com');
      expect(e.domain, 'jp1');
      expect(e.serverDomain, 'jp1.pvp.net');
      expect(e.port, 5223);
      expect(e.affinity, 'jp1');
    });

    test('reads nested client-config keys', () {
      final e = resolveXmppEndpoint(
        pasToken: pas,
        clientConfig: {
          'chat': {
            'affinities': {'jp1': 'JP1.chat.si.riotgames.com'},
            'affinity_domains': {'jp1': 'jp1'},
            'port': '5224',
          },
        },
      )!;
      expect(e.host, 'jp1.chat.si.riotgames.com');
      expect(e.port, 5224);
    });

    test('falls back to the region table', () {
      final e = resolveXmppEndpoint(
        pasToken: 'not-a-jwt',
        clientConfig: null,
        region: 'eu',
      )!;
      expect(e.host, 'euw1.chat.si.riotgames.com');
      expect(e.domain, 'euw1');

      final withAffinity = resolveXmppEndpoint(
        pasToken: pas,
        clientConfig: {'chat.affinities': <String, Object?>{}},
        region: 'ap',
      )!;
      expect(withAffinity.host, 'jp1.chat.si.riotgames.com');
      expect(withAffinity.domain, 'jp1');
    });

    test('rejects hostile hosts and unknown regions', () {
      final e = resolveXmppEndpoint(
        pasToken: pas,
        clientConfig: {
          'chat.affinities': {'jp1': 'evil.com/"><x'},
        },
        region: 'ap',
      )!;
      expect(e.host, 'jp1.chat.si.riotgames.com');
      expect(
        resolveXmppEndpoint(pasToken: null, clientConfig: null, region: 'pbe'),
        isNull,
      );
    });
  });
}
