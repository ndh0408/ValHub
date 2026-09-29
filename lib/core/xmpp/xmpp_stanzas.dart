/// Outbound XMPP stanzas (SUMMARY §6.5, EP §16). Every interpolated value is
/// XML-escaped; nothing here is ever logged (tokens, JIDs, message bodies).
abstract final class XmppStanzas {
  static const saslNs = 'urn:ietf:params:xml:ns:xmpp-sasl';
  static const bindNs = 'urn:ietf:params:xml:ns:xmpp-bind';
  static const sessionNs = 'urn:ietf:params:xml:ns:xmpp-session';
  static const entitlementsNs = 'urn:riotgames:entitlements';
  static const rosterNs = 'jabber:iq:riotgames:roster';
  static const archiveNs = 'jabber:iq:riotgames:archive';

  /// Single-space keep-alive, written every ~120 s.
  static const keepAlive = ' ';

  static const streamClose = '</stream:stream>';

  /// Stream header, sent at connect and again after SASL success.
  static String streamOpen(String serverDomain) =>
      '<?xml version="1.0" encoding="UTF-8"?>'
      '<stream:stream to="${escape(serverDomain)}" xml:lang="en" '
      'version="1.0" xmlns="jabber:client" '
      'xmlns:stream="http://etherx.jabber.org/streams">';

  /// SASL `X-Riot-RSO-PAS` with the access token and the PAS token.
  static String auth({required String accessToken, required String pasToken}) =>
      '<auth mechanism="X-Riot-RSO-PAS" xmlns="$saslNs">'
      '<rso_token>${escape(accessToken)}</rso_token>'
      '<pas_token>${escape(pasToken)}</pas_token>'
      '</auth>';

  static String bind(String id) =>
      '<iq id="${escape(id)}" type="set"><bind xmlns="$bindNs"/></iq>';

  static String session(String id) =>
      '<iq id="${escape(id)}" type="set"><session xmlns="$sessionNs"/></iq>';

  static String entitlements(String id, String entitlementsToken) =>
      '<iq id="${escape(id)}" type="set">'
      '<entitlements xmlns="$entitlementsNs">'
      '<token xmlns="">${escape(entitlementsToken)}</token>'
      '</entitlements></iq>';

  static String rosterQuery(String id) =>
      '<iq type="get" id="${escape(id)}">'
      '<query xmlns="$rosterNs" last_state="true"/></iq>';

  /// Initial (available) presence.
  static const presence = '<presence/>';

  /// Chat history with one friend ([withJid] = bare JID).
  static String archiveQuery(String id, String withJid) =>
      '<iq type="get" id="${escape(id)}">'
      '<query xmlns="$archiveNs"><with>${escape(withJid)}</with></query></iq>';

  static String message({
    required String id,
    required String to,
    required String body,
  }) =>
      '<message id="${escape(id)}" to="${escape(to)}" type="chat">'
      '<body>${escape(body)}</body></message>';

  /// Empty `result` for a server `get`/`set` iq (roster push, ping).
  static String iqResult(String id, {String? to}) =>
      '<iq type="result" id="${escape(id)}"'
      '${to == null ? '' : ' to="${escape(to)}"'}/>';

  /// Escapes text and attribute values (`& < > " '`). Characters XML 1.0
  /// forbids (C0 controls except tab/newline/CR) are dropped.
  static String escape(String input) {
    final out = StringBuffer();
    for (final rune in input.runes) {
      switch (rune) {
        case 0x26:
          out.write('&amp;');
        case 0x3C:
          out.write('&lt;');
        case 0x3E:
          out.write('&gt;');
        case 0x22:
          out.write('&quot;');
        case 0x27:
          out.write('&apos;');
        case 0x09 || 0x0A || 0x0D:
          out.writeCharCode(rune);
        case < 0x20 || 0xFFFE || 0xFFFF:
          break;
        default:
          out.writeCharCode(rune);
      }
    }
    return out.toString();
  }
}
