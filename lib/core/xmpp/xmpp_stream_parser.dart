import 'dart:convert';

import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

/// Something the incremental parser recognised on the XMPP stream.
sealed class XmppStreamEvent {
  const XmppStreamEvent();
}

/// `<stream:stream …>` (initial, or re-opened after SASL success).
final class XmppStreamOpened extends XmppStreamEvent {
  const XmppStreamOpened(this.attributes);

  final Map<String, String> attributes;
}

/// One complete top-level element (a stanza, `<stream:features>`,
/// `<success/>`, `<stream:error>` …).
final class XmppStanza extends XmppStreamEvent {
  const XmppStanza(this.element);

  final XmlElement element;
}

/// `</stream:stream>`: the server ended the stream.
final class XmppStreamClosed extends XmppStreamEvent {
  const XmppStreamClosed();
}

/// Incremental parser for one XMPP connection (package:xml events).
///
/// - Input can be split anywhere (inside tags, attribute values, entities or
///   multi-byte characters already decoded by the transport): only text up
///   to the last `>` is handed to the event decoder, the rest waits for the
///   next chunk.
/// - The `<stream:stream>` root never closes, so children of the root are
///   emitted one by one as [XmppStanza]s. A second `<stream:stream>` (stream
///   restart after SASL) is recognised wherever it appears.
/// - Whitespace keep-alives, the XML declaration, comments and processing
///   instructions between stanzas are ignored.
/// - Throws [FormatException] when more than [maxPendingChars] characters
///   arrive without completing anything (garbage / hostile input).
class XmppStreamParser {
  XmppStreamParser({this.maxPendingChars = 2 * 1024 * 1024}) {
    _start();
  }

  final int maxPendingChars;

  late StringConversionSink _decoder;
  final List<XmlEvent> _decoded = [];
  String _pending = '';
  int _sinceLastEvent = 0;

  List<XmlEvent>? _current;
  int _stanzaDepth = 0;

  void _start() {
    _decoder = XmlEventDecoder().startChunkedConversion(
      _EventSink(_decoded.addAll),
    );
    _pending = '';
    _sinceLastEvent = 0;
    _current = null;
    _stanzaDepth = 0;
  }

  /// Drops every buffered byte and starts over (new connection).
  void reset() => _start();

  /// Feeds one chunk and returns the events it completed (possibly none).
  List<XmppStreamEvent> add(String chunk) {
    if (chunk.isEmpty) return const [];
    _pending += chunk;
    final cut = _pending.lastIndexOf('>');
    if (cut < 0) {
      _checkBudget(chunk.length);
      return const [];
    }
    final feed = _pending.substring(0, cut + 1);
    _pending = _pending.substring(cut + 1);
    _decoded.clear();
    try {
      _decoder.add(feed);
    } on XmlException catch (e) {
      throw FormatException('xmpp: ${e.message}');
    }
    if (_decoded.isEmpty) {
      _checkBudget(feed.length);
      return const [];
    }
    _sinceLastEvent = _pending.length;
    final out = <XmppStreamEvent>[];
    for (final e in List<XmlEvent>.of(_decoded)) {
      _handle(e, out);
    }
    _decoded.clear();
    return out;
  }

  void _checkBudget(int added) {
    _sinceLastEvent += added;
    if (_sinceLastEvent > maxPendingChars) {
      throw const FormatException('xmpp: stanza too large or malformed');
    }
  }

  static bool _isStreamTag(String name) =>
      name == 'stream:stream' ||
      (name.endsWith(':stream') && name.startsWith('stream'));

  void _handle(XmlEvent e, List<XmppStreamEvent> out) {
    final current = _current;
    if (current != null) {
      current.add(e);
      if (e is XmlStartElementEvent && !e.isSelfClosing) {
        _stanzaDepth++;
      } else if (e is XmlEndElementEvent) {
        _stanzaDepth--;
        if (_stanzaDepth <= 0) {
          _current = null;
          _stanzaDepth = 0;
          final element = _build(current);
          if (element != null) out.add(XmppStanza(element));
        }
      }
      return;
    }
    switch (e) {
      case XmlStartElementEvent() when _isStreamTag(e.name):
        out.add(
          XmppStreamOpened({for (final a in e.attributes) a.name: a.value}),
        );
      case XmlStartElementEvent() when e.isSelfClosing:
        final element = _build([e]);
        if (element != null) out.add(XmppStanza(element));
      case XmlStartElementEvent():
        _current = [e];
        _stanzaDepth = 1;
      case XmlEndElementEvent() when _isStreamTag(e.name):
        out.add(const XmppStreamClosed());
      default:
        // Declarations, whitespace keep-alives, comments, stray end tags.
        break;
    }
  }

  static XmlElement? _build(List<XmlEvent> events) {
    try {
      return const XmlNodeDecoder()
          .convert(events)
          .whereType<XmlElement>()
          .firstOrNull;
    } on XmlException {
      return null;
    }
  }
}

class _EventSink implements Sink<List<XmlEvent>> {
  _EventSink(this._onAdd);

  final void Function(List<XmlEvent>) _onAdd;

  @override
  void add(List<XmlEvent> data) => _onAdd(data);

  @override
  void close() {}
}
