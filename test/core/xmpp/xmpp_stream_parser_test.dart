import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:valvn/core/xmpp/xmpp_stream_parser.dart';

const _stream =
    "<?xml version='1.0'?><stream:stream from='jp1.pvp.net' id='1' "
    "version='1.0' xmlns='jabber:client' "
    "xmlns:stream='http://etherx.jabber.org/streams'>";

const _stanzas =
    '<stream:features><mechanisms xmlns="urn:ietf:params:xml:ns:xmpp-sasl">'
    '<mechanism>X-Riot-RSO-PAS</mechanism></mechanisms></stream:features> '
    '<message from="a@jp1.pvp.net/RC" type="chat" id="m1">'
    '<body>Xin chào &amp; hẹn gặp &lt;3 — 🎮 a &gt; b</body></message>'
    '<presence from="b@jp1.pvp.net/RC" attr="x&gt;y"/>'
    '<iq type="result" id="r1"><query xmlns="jabber:iq:riotgames:roster">'
    '<item jid="c@jp1.pvp.net"><id name="Đức" tagline="VN"/></item>'
    '</query></iq>';

List<XmppStreamEvent> _feed(XmppStreamParser p, List<String> chunks) => [
  for (final c in chunks) ...p.add(c),
];

void _expectStanzas(List<XmppStreamEvent> events) {
  final stanzas = events.whereType<XmppStanza>().toList();
  expect(events.first, isA<XmppStreamOpened>());
  expect(stanzas.map((s) => s.element.name.local).toList(), [
    'features',
    'message',
    'presence',
    'iq',
  ]);
  final body = stanzas[1].element.findAllElements('body').single.innerText;
  expect(body, 'Xin chào & hẹn gặp <3 — 🎮 a > b');
  expect(stanzas[2].element.getAttribute('attr'), 'x>y');
  expect(
    stanzas[3].element.findAllElements('id').single.getAttribute('name'),
    'Đức',
  );
}

void main() {
  test('parses a whole stream in one chunk', () {
    final p = XmppStreamParser();
    _expectStanzas(_feed(p, [_stream + _stanzas]));
  });

  test('parses the stream split at every position', () {
    const input = _stream + _stanzas;
    for (var cut = 1; cut < input.length; cut++) {
      final p = XmppStreamParser();
      _expectStanzas(_feed(p, [input.substring(0, cut), input.substring(cut)]));
    }
  });

  test('parses the stream fed one character at a time', () {
    final p = XmppStreamParser();
    const input = _stream + _stanzas;
    _expectStanzas(_feed(p, [for (final c in input.split('')) c]));
  });

  test('recognises a stream restart and a closed stream', () {
    final p = XmppStreamParser();
    final events = _feed(p, [
      _stream,
      '<success xmlns="urn:ietf:params:xml:ns:xmpp-sasl"/>',
      _stream,
      '<stream:features/>',
      '  ',
      '</stream:stream>',
    ]);
    expect(events.map((e) => e.runtimeType).toList(), [
      XmppStreamOpened,
      XmppStanza,
      XmppStreamOpened,
      XmppStanza,
      XmppStreamClosed,
    ]);
    expect(
      (events.first as XmppStreamOpened).attributes['from'],
      'jp1.pvp.net',
    );
  });

  test('ignores whitespace keep-alives between stanzas', () {
    final p = XmppStreamParser();
    final events = _feed(p, [_stream, ' ', '\n', '<presence/>', ' ']);
    expect(events.whereType<XmppStanza>(), hasLength(1));
  });

  test('reset drops a half-received stanza', () {
    final p = XmppStreamParser()..add(_stream);
    expect(p.add('<message><body>hal'), isEmpty);
    p.reset();
    final events = _feed(p, [_stream, '<presence/>']);
    expect(
      events.whereType<XmppStanza>().single.element.name.local,
      'presence',
    );
  });

  test('throws on endless garbage', () {
    final p = XmppStreamParser(maxPendingChars: 100);
    expect(() {
      for (var i = 0; i < 20; i++) {
        p.add('<<<<<<<<<<');
      }
    }, throwsFormatException);
  });
}
