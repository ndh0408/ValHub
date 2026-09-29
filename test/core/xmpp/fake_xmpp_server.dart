import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:valvn/core/xmpp/xmpp_client.dart';
import 'package:valvn/core/xmpp/xmpp_service.dart';
import 'package:valvn/core/xmpp/xmpp_transport.dart';

const me = 'aaaaaaaa-0000-4000-8000-000000000001';
const friendA = 'f0000000-0000-4000-8000-00000000000a';
const friendB = 'f0000000-0000-4000-8000-00000000000b';
const friendC = 'f0000000-0000-4000-8000-00000000000c';

String jidOf(String puuid, [String? resource]) =>
    '$puuid@jp1.pvp.net${resource == null ? '' : '/$resource'}';

/// Base64 presence payload for `<p>`.
String presencePayload(Map<String, Object?> json) =>
    base64.encode(utf8.encode(jsonEncode(json)));

/// A Valorant presence stanza from [puuid].
String valorantPresence(
  String puuid, {
  String resource = 'RC-1',
  Map<String, Object?>? json,
  String show = 'chat',
  int? stamp,
}) =>
    '<presence from="${jidOf(puuid, resource)}" id="p-$puuid">'
    '<games><valorant><st>$show</st>'
    '<s.t>${stamp ?? 1790000000000}</s.t><s.p>valorant</s.p><s.r>PC</s.r>'
    '<p>${presencePayload(json ?? nestedPresence())}</p><pty/></valorant>'
    '</games><show>$show</show><platform>riot</platform><status/></presence>';

Map<String, Object?> nestedPresence({
  String loop = 'MENUS',
  String map = '',
  String queue = 'competitive',
  String partyState = 'DEFAULT',
  int ally = 0,
  int enemy = 0,
  bool idle = false,
  String card = '1711d20d-4b1c-c64a-14be-d4ae58a457c6',
}) => {
  'isIdle': idle,
  'isValid': true,
  'matchPresenceData': {
    'matchMap': map,
    'provisioningFlow': 'Matchmaking',
    'queueId': queue,
    'sessionLoopState': loop,
  },
  'partyPresenceData': {
    'isPartyOwner': true,
    'partyId': '62D30F62-98C0-4F6F-8380-350A84AAC00E',
    'partySize': 2,
    'maxPartySize': 5,
    'partyState': partyState,
    'queueEntryTime': '2026.09.28-11.58.30',
    'partyOwnerMatchScoreAllyTeam': ally,
    'partyOwnerMatchScoreEnemyTeam': enemy,
  },
  'playerPresenceData': {
    'accountLevel': 98,
    'competitiveTier': 18,
    'playerCardId': card,
  },
};

const rosterItems =
    '<item jid="$friendA@jp1.pvp.net" puuid="$friendA" subscription="both">'
    '<state>online</state><last_online>2026-09-28 10:00:04.505</last_online>'
    '<id name="Bạn A" tagline="VN1"/></item>'
    '<item jid="$friendB@jp1.pvp.net" puuid="$friendB" subscription="both">'
    '<last_online>2026-09-20 08:00:00.000</last_online>'
    '<platforms><riot name="Bee" tagline="0001"/></platforms></item>'
    '<item jid="$friendC@jp1.pvp.net" subscription="both"/>'
    '<item jid="dddddddd-0000-4000-8000-00000000000d@jp1.pvp.net" '
    'subscription="pending_in"><id name="Lạ" tagline="X"/></item>';

/// Scripted Riot chat server behind a fake socket. Answers the handshake,
/// roster and archive; everything it receives lands in [written].
class FakeXmppServer {
  FakeXmppServer({
    this.saslFailures = 0,
    this.roster = rosterItems,
    this.chunkSeed,
    this.archive = '',
  });

  /// How many SASL attempts fail before one succeeds.
  int saslFailures;
  String roster;
  String archive;

  /// When set, every response is split into random chunks.
  final int? chunkSeed;

  final List<String> written = [];
  final List<String> authTokens = [];
  final List<FakeSocket> sockets = [];
  int connects = 0;

  /// Makes the next connect attempts throw (socket errors).
  int failConnects = 0;

  FakeSocket? get socket => sockets.isEmpty ? null : sockets.last;

  Future<XmppSocket> connect(XmppEndpoint endpoint) async {
    connects++;
    if (failConnects > 0) {
      failConnects--;
      throw const SocketExceptionLike();
    }
    final s = FakeSocket(this, chunkSeed == null ? null : Random(chunkSeed));
    sockets.add(s);
    return s;
  }

  static final _id = RegExp(r'id="([^"]+)"');

  void onWrite(FakeSocket s, String data) {
    written.add(data);
    if (data.trim().isEmpty) return; // keep-alive
    if (data.contains('<stream:stream')) {
      s.serverOpenedStreams++;
      s.send(
        "<?xml version='1.0'?><stream:stream from='jp1.pvp.net' id='s${s.serverOpenedStreams}' "
        "version='1.0' xmlns='jabber:client' "
        "xmlns:stream='http://etherx.jabber.org/streams'>",
      );
      s.send(
        s.authenticated
            ? '<stream:features><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"/>'
                  '<session xmlns="urn:ietf:params:xml:ns:xmpp-session"/>'
                  '</stream:features>'
            : '<stream:features><mechanisms xmlns="urn:ietf:params:xml:ns:xmpp-sasl">'
                  '<mechanism>X-Riot-RSO-PAS</mechanism></mechanisms>'
                  '</stream:features>',
      );
      return;
    }
    if (data.startsWith('<auth')) {
      authTokens.add(
        RegExp(r'<rso_token>([^<]*)</rso_token>').firstMatch(data)?[1] ?? '',
      );
      if (saslFailures > 0) {
        saslFailures--;
        s.send(
          '<failure xmlns="urn:ietf:params:xml:ns:xmpp-sasl">'
          '<not-authorized/></failure>',
        );
        return;
      }
      s.authenticated = true;
      s.send('<success xmlns="urn:ietf:params:xml:ns:xmpp-sasl"/>');
      return;
    }
    final id = _id.firstMatch(data)?[1];
    if (data.contains('xmpp-bind')) {
      s.send(
        '<iq id="$id" type="result"><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind">'
        '<jid>${jidOf(me, 'RC-VALVN')}</jid></bind></iq>',
      );
    } else if (data.contains('xmpp-session') ||
        data.contains('urn:riotgames:entitlements')) {
      s.send('<iq id="$id" type="result"/>');
    } else if (data.contains('jabber:iq:riotgames:roster')) {
      s.send(
        '<iq id="$id" type="result"><query xmlns="jabber:iq:riotgames:roster">'
        '$roster</query></iq>',
      );
    } else if (data.contains('jabber:iq:riotgames:archive')) {
      s.send(
        '<iq id="$id" type="result"><query xmlns="jabber:iq:riotgames:archive">'
        '$archive</query></iq>',
      );
    }
  }
}

class SocketExceptionLike implements Exception {
  const SocketExceptionLike();
}

class FakeSocket implements XmppSocket {
  FakeSocket(this.server, this._random);

  final FakeXmppServer server;
  final Random? _random;
  final StreamController<String> _input = StreamController<String>();
  bool authenticated = false;
  int serverOpenedStreams = 0;
  bool closed = false;

  @override
  Stream<String> get input => _input.stream;

  @override
  void write(String data) {
    if (closed) return;
    server.onWrite(this, data);
  }

  /// Server → client, optionally in random chunks.
  void send(String data) {
    if (closed) return;
    final r = _random;
    if (r == null) {
      _input.add(data);
      return;
    }
    var i = 0;
    while (i < data.length) {
      final n = 1 + r.nextInt(12);
      final end = min(i + n, data.length);
      _input.add(data.substring(i, end));
      i = end;
    }
  }

  /// The server drops the connection.
  void drop() {
    if (closed) return;
    closed = true;
    unawaited(_input.close());
  }

  @override
  Future<void> close() async {
    if (closed) return;
    closed = true;
    unawaited(_input.close());
  }
}

/// Credentials `access-N` / `pas-N` / `ent-N` for the N-th call.
class FakeCredentials implements XmppCredentialSource {
  int calls = 0;
  final List<String> invalidated = [];
  Object? error;

  @override
  Future<XmppCredentials> credentials(String puuid) async {
    calls++;
    final e = error;
    if (e != null) throw e;
    return XmppCredentials(
      puuid: puuid,
      accessToken: 'access-$calls',
      pasToken: 'pas-$calls',
      entitlementsToken: 'ent-$calls',
      endpoint: const XmppEndpoint(
        host: 'jp1.chat.si.riotgames.com',
        domain: 'jp1',
      ),
    );
  }

  @override
  Future<void> invalidate(
    String puuid, {
    required String failedAccessToken,
  }) async {
    invalidated.add(failedAccessToken);
  }
}
