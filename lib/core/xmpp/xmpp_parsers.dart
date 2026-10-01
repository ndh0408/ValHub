import '../geo/region_data.g.dart';

import 'dart:convert';

import 'package:xml/xml.dart';

import '../auth/jwt.dart';
import '../domain/competitive/names.dart';
import '../util/json.dart';
import 'xmpp_models.dart';
import 'xmpp_transport.dart';

// Everything here is pure and never throws: Riot's chat payloads are
// undocumented (SUMMARY U9, U10), so every field is optional.

// ------------------------------------------------------------------ helpers

/// First direct child element whose local name is [local] (prefix and
/// namespace ignored).
XmlElement? xmlChild(XmlElement? parent, String local) {
  if (parent == null) return null;
  for (final c in parent.childElements) {
    if (c.name.local == local) return c;
  }
  return null;
}

/// Every direct child element named [local].
Iterable<XmlElement> xmlChildren(XmlElement? parent, String local) =>
    parent == null
    ? const []
    : parent.childElements.where((c) => c.name.local == local);

/// Trimmed inner text of the child [local], `null` when missing or blank.
String? xmlChildText(XmlElement? parent, String local) {
  final t = xmlChild(parent, local)?.innerText.trim();
  return (t == null || t.isEmpty) ? null : t;
}

String? _attr(XmlElement? e, String name) {
  final v = e?.getAttribute(name)?.trim();
  return (v == null || v.isEmpty) ? null : v;
}

final _tzSuffix = RegExp(r'(Z|[+-]\d{2}:?\d{2})$', caseSensitive: false);

/// Riot chat timestamps, all read as UTC:
/// - `2025-03-11 22:00:04.505` / ISO-8601 without an offset (UTC);
/// - ISO-8601 with `Z` / an offset;
/// - epoch milliseconds or seconds (numbers or numeric strings).
/// `null` for anything else and for the year-1 placeholder.
DateTime? parseRiotTimestamp(Object? raw) {
  if (raw is num) return _fromEpoch(raw);
  final s = asString(raw)?.trim();
  if (s == null || s.isEmpty) return null;
  final n = num.tryParse(s);
  if (n != null) return _fromEpoch(n);
  var iso = s.replaceFirst(' ', 'T');
  if (!_tzSuffix.hasMatch(iso)) iso = '${iso}Z';
  final d = DateTime.tryParse(iso)?.toUtc();
  return (d == null || d.year <= 1) ? null : d;
}

DateTime? _fromEpoch(num n) {
  if (!n.isFinite || n <= 0) return null;
  // < 1e11 → seconds (until year 5138), otherwise milliseconds.
  final ms = n < 1e11 ? (n * 1000).toInt() : n.toInt();
  return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
}

/// Party `queueEntryTime` in presence (`2026.04.23-22.40.57`, UTC) or any
/// format [parseRiotTimestamp] accepts. The `0001.01.01-00.00.00`
/// placeholder is `null`.
DateTime? parseQueueEntryTime(Object? raw) {
  final s = asString(raw)?.trim();
  if (s == null || s.isEmpty) return null;
  final m = RegExp(r'^(\d{4})\.(\d{2})\.(\d{2})-(\d{2})\.(\d{2})\.(\d{2})')
      .firstMatch(s);
  if (m != null) {
    final p = [for (var i = 1; i <= 6; i++) int.parse(m[i]!)];
    if (p[0] <= 1) return null;
    return DateTime.utc(p[0], p[1], p[2], p[3], p[4], p[5]);
  }
  return parseRiotTimestamp(s);
}

// ------------------------------------------------------------- presence JSON

String? _nonEmpty(Object? v) => asNonEmptyString(v);

/// A Valorant presence JSON (nested 2024+ format, falling back to the old
/// flat keys field by field). `null` when [json] is not an object.
PresenceSnapshot? presenceSnapshotFromJson(Object? json) {
  final root = asMap(json);
  if (root == null) return null;
  final match = asMap(root['matchPresenceData']) ?? const <String, Object?>{};
  final party = asMap(root['partyPresenceData']) ?? const <String, Object?>{};
  final player = asMap(root['playerPresenceData']) ?? const <String, Object?>{};

  Object? first(List<Object?> values) {
    for (final v in values) {
      if (v == null) continue;
      if (v is String && v.trim().isEmpty) continue;
      return v;
    }
    return null;
  }

  final loop = first([
    match['sessionLoopState'],
    root['sessionLoopState'],
    party['partyOwnerSessionLoopState'],
    root['partyOwnerSessionLoopState'],
  ]);
  return PresenceSnapshot(
    isIdle: asBool(root['isIdle']) ?? false,
    isValid: asBool(root['isValid']) ?? true,
    loopState: LoopState.parse(asString(loop)),
    matchMap: _nonEmpty(
      first([
        match['matchMap'],
        root['matchMap'],
        party['partyOwnerMatchMap'],
        root['partyOwnerMatchMap'],
      ]),
    ),
    queueId: asString(first([match['queueId'], root['queueId']]))
        ?.trim()
        .toLowerCase(),
    provisioningFlow: _nonEmpty(
      first([
        match['provisioningFlow'],
        root['provisioningFlow'],
        party['partyOwnerProvisioningFlow'],
      ]),
    ),
    partyId: lowerUuid(first([party['partyId'], root['partyId']])),
    partyState: _nonEmpty(first([party['partyState'], root['partyState']])),
    partySize: asInt(first([party['partySize'], root['partySize']])),
    maxPartySize: asInt(first([party['maxPartySize'], root['maxPartySize']])),
    partyAccessibility: _nonEmpty(
      first([party['partyAccessibility'], root['partyAccessibility']]),
    ),
    queueEntryTime: parseQueueEntryTime(
      first([party['queueEntryTime'], root['queueEntryTime']]),
    ),
    isPartyOwner:
        asBool(first([party['isPartyOwner'], root['isPartyOwner']])) ?? false,
    allyScore: asInt(
      first([
        party['partyOwnerMatchScoreAllyTeam'],
        root['partyOwnerMatchScoreAllyTeam'],
      ]),
    ),
    enemyScore: asInt(
      first([
        party['partyOwnerMatchScoreEnemyTeam'],
        root['partyOwnerMatchScoreEnemyTeam'],
      ]),
    ),
    playerCardId: lowerUuid(
      first([player['playerCardId'], root['playerCardId']]),
    ),
    playerTitleId: lowerUuid(
      first([player['playerTitleId'], root['playerTitleId']]),
    ),
    accountLevel: asInt(first([player['accountLevel'], root['accountLevel']])),
    competitiveTier: asInt(
      first([player['competitiveTier'], root['competitiveTier']]),
    ),
    leaderboardPosition: asInt(
      first([player['leaderboardPosition'], root['leaderboardPosition']]),
    ),
    customGameName: _nonEmpty(
      first([party['customGameName'], root['customGameName']]),
    ),
  );
}

/// Decodes the `<p>` payload: base64 (standard or URL-safe, padding
/// optional) JSON, or plain JSON. `null` when undecodable.
PresenceSnapshot? decodeValorantPresence(String? payload) {
  final s = payload?.trim() ?? '';
  if (s.isEmpty) return null;
  if (s.startsWith('{')) return presenceSnapshotFromJson(tryDecodeJson(s));
  try {
    final bytes = base64.decode(
      base64.normalize(s.replaceAll(RegExp(r'\s'), '')),
    );
    return presenceSnapshotFromJson(
      tryDecodeJson(utf8.decode(bytes, allowMalformed: true)),
    );
  } on FormatException {
    return null;
  }
}

// ----------------------------------------------------------------- presence

/// Parses one `<presence>` stanza. `null` for subscription / probe / error
/// presences and senders that are not `puuid@domain` JIDs.
FriendPresence? parsePresence(
  XmlElement presence, {
  required DateTime receivedAt,
}) {
  if (presence.name.local != 'presence') return null;
  final from = Jid.parse(presence.getAttribute('from'));
  if (from == null) return null;
  final type = _attr(presence, 'type')?.toLowerCase();
  if (type != null && type != 'available' && type != 'unavailable') {
    return null;
  }
  if (type == 'unavailable') {
    return FriendPresence(
      puuid: from.puuid,
      resource: from.resource,
      available: false,
      show: PresenceShow.unknown,
      receivedAt: receivedAt,
    );
  }
  final games = xmlChild(presence, 'games');
  final valorant = xmlChild(games, 'valorant');
  final gameEl =
      valorant ??
      games?.childElements
          .where((e) => e.name.local != 'keystone')
          .firstOrNull ??
      xmlChild(games, 'keystone');
  final showText = xmlChildText(presence, 'show') ?? xmlChildText(gameEl, 'st');
  final snapshot = valorant == null
      ? null
      : decodeValorantPresence(xmlChildText(valorant, 'p'));
  return FriendPresence(
    puuid: from.puuid,
    resource: from.resource,
    show: PresenceShow.parse(showText),
    status: xmlChildText(presence, 'status'),
    product: gameEl?.name.local,
    platform: xmlChildText(gameEl, 's.r'),
    // A Valorant element whose payload cannot be decoded still means "in
    // Valorant": keep an empty snapshot so the UI says "Trực tuyến".
    valorant: valorant == null ? null : (snapshot ?? const PresenceSnapshot()),
    timestamp: parseRiotTimestamp(xmlChildText(gameEl, 's.t')),
    receivedAt: receivedAt,
  );
}

/// The presence that best describes a user with several resources online:
/// Valorant first, then any game, then the most recent.
FriendPresence? bestPresence(Iterable<FriendPresence> presences) {
  FriendPresence? best;
  int rank(FriendPresence p) => p.inValorant
      ? 3
      : (p.product != null && p.product != 'keystone')
      ? 2
      : 1;
  for (final p in presences) {
    if (!p.available) continue;
    if (best == null) {
      best = p;
      continue;
    }
    final r = rank(p);
    final br = rank(best);
    if (r > br ||
        (r == br &&
            (p.timestamp ?? p.receivedAt).isAfter(
              best.timestamp ?? best.receivedAt,
            ))) {
      best = p;
    }
  }
  return best;
}

// ------------------------------------------------------------------- roster

/// One roster `<item>`. `null` when neither a `puuid` attribute nor a
/// `puuid@domain` JID is present.
RosterEntry? parseRosterItem(XmlElement item) {
  final jid = Jid.parse(item.getAttribute('jid'));
  final puuid = lowerUuid(item.getAttribute('puuid')) ?? jid?.puuid;
  if (puuid == null || puuid.isEmpty) return null;
  final id = xmlChild(item, 'id');
  final riot = xmlChild(xmlChild(item, 'platforms'), 'riot');
  final name =
      RiotName.of(_attr(id, 'name'), _attr(id, 'tagline')) ??
      RiotName.of(_attr(riot, 'name'), _attr(riot, 'tagline')) ??
      RiotName.of(_attr(item, 'name'), _attr(item, 'tagline'));
  final groupEl = xmlChild(item, 'group');
  return RosterEntry(
    puuid: puuid,
    jid: jid?.bare ?? puuid,
    name: name,
    subscription: _attr(item, 'subscription'),
    lastOnline: parseRiotTimestamp(xmlChildText(item, 'last_online')),
    state: xmlChildText(item, 'state')?.toLowerCase(),
    note: xmlChildText(item, 'note'),
    group: groupEl == null
        ? null
        : (_attr(groupEl, 'name') ?? xmlChildText(item, 'group')),
  );
}

/// Every roster `<item>` under [root] (an `<iq>` or its `<query>`).
List<RosterEntry> parseRosterItems(XmlElement root) {
  final query = root.name.local == 'query' ? root : xmlChild(root, 'query');
  return [
    for (final item in xmlChildren(query, 'item')) ?parseRosterItem(item),
  ];
}

// -------------------------------------------------------------------- chat

/// One `<message>` with a `<body>` between the signed-in user
/// ([ownPuuid]) and someone else. `null` for group chat, errors, receipts
/// and bodies that are empty.
ChatMessage? parseChatMessage(
  XmlElement message, {
  required String ownPuuid,
  required DateTime receivedAt,
}) {
  if (message.name.local != 'message') return null;
  final type = _attr(message, 'type')?.toLowerCase();
  if (type != null && type != 'chat' && type != 'normal') return null;
  final body = xmlChild(message, 'body')?.innerText;
  if (body == null || body.trim().isEmpty) return null;
  final from = Jid.parse(message.getAttribute('from'));
  final to = Jid.parse(message.getAttribute('to'));
  final own = ownPuuid.toLowerCase();
  final outgoing = from?.puuid == own;
  final friend = outgoing ? to?.puuid : from?.puuid;
  if (friend == null || friend == own) return null;
  final at =
      parseRiotTimestamp(_attr(message, 'stamp')) ??
      parseRiotTimestamp(_attr(xmlChild(message, 'delay'), 'stamp')) ??
      parseRiotTimestamp(_attr(xmlChild(message, 'x'), 'stamp')) ??
      receivedAt;
  final id =
      _attr(message, 'id') ??
      'm-${at.millisecondsSinceEpoch}-${Object.hash(friend, body)}';
  return ChatMessage(
    id: id,
    friendPuuid: friend,
    outgoing: outgoing,
    body: body,
    at: at,
    status: outgoing ? ChatMessageStatus.sent : ChatMessageStatus.received,
  );
}

/// Messages of an archive result (`<iq><query xmlns=…archive><message/>…`),
/// oldest first.
List<ChatMessage> parseArchive(
  XmlElement root, {
  required String ownPuuid,
  required DateTime receivedAt,
}) {
  final out = <ChatMessage>[
    for (final m in root.descendantElements.where(
      (e) => e.name.local == 'message',
    ))
      ?parseChatMessage(m, ownPuuid: ownPuuid, receivedAt: receivedAt),
  ]..sort((a, b) => a.at.compareTo(b.at));
  return out;
}

// ----------------------------------------------------------------- endpoint

/// Chat host prefixes by game region when client config lacks the PAS
/// affinity (SUMMARY §6.5, from GinzaTech/Vshop).
const kChatFallbackHosts = regionChatAffinities;

final _hostPattern = RegExp(r'^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9-]+)+$');

/// `jp1`, `euw1`, `na2`: an affinity / XMPP domain prefix.
final _labelPattern = RegExp(r'^[a-z0-9]([a-z0-9-]{0,30}[a-z0-9])?$');

/// Domains the chat client may send its tokens to (SASL sends the access, PAS
/// and entitlements tokens): Riot's chat hosts live under these (AR-023).
const kChatHostSuffixes = ['.riotgames.com', '.pvp.net'];

/// Whether [host] is a syntactically valid host under a Riot chat domain
/// (`*.riotgames.com`, `*.pvp.net`). `riotgames.com.evil.net` is not.
bool isAllowedChatHost(String host) {
  final h = host.toLowerCase();
  return _hostPattern.hasMatch(h) &&
      kChatHostSuffixes.any((suffix) => h.endsWith(suffix));
}

Object? _configValue(JsonMap config, String group, String key) =>
    config['$group.$key'] ?? asMap(config[group])?[key];

/// Chat server for one account from the PAS token (A-7, `affinity` claim)
/// and client config (A-8: `chat.affinities`, `chat.affinity_domains`,
/// `chat.port`), with the region fallback table. `null` when nothing
/// usable is known.
XmppEndpoint? resolveXmppEndpoint({
  required String? pasToken,
  required Object? clientConfig,
  String? region,
  void Function(String reason)? onRejected,
}) {
  var affinity = asNonEmptyString(decodeJwtPayload(pasToken)?['affinity'])
      ?.toLowerCase();
  if (affinity != null && !_labelPattern.hasMatch(affinity)) {
    onRejected?.call('affinity');
    affinity = null;
  }
  final config = asMap(clientConfig) ?? const <String, Object?>{};
  final hosts = asMap(_configValue(config, 'chat', 'affinities'));
  final domains = asMap(_configValue(config, 'chat', 'affinity_domains'));
  final port = asInt(_configValue(config, 'chat', 'port'));

  String? host = affinity == null
      ? null
      : asNonEmptyString(hosts?[affinity])?.toLowerCase();
  if (host != null && !isAllowedChatHost(host)) {
    // A host outside Riot's chat domains would receive three tokens: use the
    // region table instead.
    onRejected?.call('host');
    host = null;
  }
  String? domain = affinity == null
      ? null
      : asNonEmptyString(domains?[affinity])?.toLowerCase();
  if (domain != null && !_labelPattern.hasMatch(domain)) {
    onRejected?.call('domain');
    domain = null;
  }

  if (host == null) {
    final prefix = kChatFallbackHosts[region?.toLowerCase()];
    if (prefix == null && affinity == null) return null;
    host = '${prefix ?? affinity}.chat.si.riotgames.com';
    domain ??= affinity ?? prefix;
  }
  domain ??= affinity ?? host.split('.').first;
  if (!isAllowedChatHost(host)) return null;
  return XmppEndpoint(
    host: host,
    domain: domain,
    port: (port == null || port <= 0 || port > 65535) ? 5223 : port,
    affinity: affinity,
  );
}
