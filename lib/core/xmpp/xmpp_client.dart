import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

import '../network/riot_exception.dart';
import 'xmpp_models.dart';
import 'xmpp_parsers.dart';
import 'xmpp_stanzas.dart';
import 'xmpp_stream_parser.dart';
import 'xmpp_transport.dart';

/// SASL was refused (`<failure>`): the tokens are stale or revoked.
final class XmppAuthException implements Exception {
  const XmppAuthException(this.condition);

  /// `not-authorized`, `account-disabled`, … (never contains tokens).
  final String condition;

  @override
  String toString() => 'XmppAuthException($condition)';
}

/// The server sent `<stream:error>` or an `<iq type="error">`.
final class XmppProtocolException implements Exception {
  const XmppProtocolException(this.condition);

  final String condition;

  @override
  String toString() => 'XmppProtocolException($condition)';
}

/// Tokens for one connection. Never logged ([toString] hides them).
@immutable
class XmppCredentials {
  const XmppCredentials({
    required this.puuid,
    required this.accessToken,
    required this.pasToken,
    required this.entitlementsToken,
    required this.endpoint,
  });

  final String puuid;
  final String accessToken;
  final String pasToken;
  final String entitlementsToken;
  final XmppEndpoint endpoint;

  @override
  String toString() => 'XmppCredentials(${endpoint.host})';
}

/// Maps socket / protocol failures to the app's [RiotException]s.
RiotException xmppError(Object error) => switch (error) {
  final RiotException e => e,
  TimeoutException() => const TransientException(reason: 'timeout'),
  XmppAuthException(:final condition) => RiotApiException(
    401,
    errorCode: 'xmpp_$condition',
  ),
  XmppProtocolException(:final condition) => TransientException(
    reason: 'xmpp_$condition',
  ),
  FormatException() => const TransientException(reason: 'xmpp_malformed'),
  _ => const TransientException(reason: 'network'),
};

class _Waiter {
  _Waiter(this.test);

  final bool Function(XmlElement) test;
  final completer = Completer<XmlElement>();
}

/// One XMPP connection to Riot chat (SUMMARY §6.5):
///
/// TLS socket → stream → SASL `X-Riot-RSO-PAS` → stream restart → bind →
/// session → entitlements. After [connect] returns, [stanzas] delivers every
/// presence / message / unsolicited iq (buffered until listened), [sendIq]
/// correlates requests by id, and a single space is written every
/// [keepAliveInterval]. Pings and roster pushes are acknowledged here.
///
/// A client is single-use: after [done] completes, create a new one.
class XmppClient {
  XmppClient({
    required this.connector,
    this.keepAliveInterval = const Duration(seconds: 120),
    this.stepTimeout = const Duration(seconds: 15),
    this.onLog,
  }) {
    // Nobody may be listening when the connection drops.
    _done.future.ignore();
  }

  final XmppConnector connector;
  final Duration keepAliveInterval;
  final Duration stepTimeout;

  /// Token-free lifecycle events (`xmpp.connected`, `xmpp.closed` …).
  final void Function(String event, String? detail)? onLog;

  final XmppStreamParser _parser = XmppStreamParser();
  final StreamController<XmlElement> _stanzas = StreamController<XmlElement>();
  final Completer<void> _done = Completer<void>();
  final List<_Waiter> _waiters = [];
  final Map<String, Completer<XmlElement>> _pendingIq = {};

  XmppSocket? _socket;
  StreamSubscription<String>? _sub;
  Timer? _keepAlive;
  bool _ready = false;
  bool _closed = false;
  int _nextId = 0;

  /// Full JID bound by the server (`{puuid}@{domain}/{resource}`).
  Jid? boundJid;

  /// Presences, messages and unsolicited iqs after the handshake.
  Stream<XmlElement> get stanzas => _stanzas.stream;

  /// Completes when the connection ends: normally after [close], with an
  /// error when the socket or the stream failed.
  Future<void> get done => _done.future;

  bool get isOpen => _ready && !_closed;

  String nextId(String prefix) => '${prefix}_${++_nextId}';

  /// Opens the socket and runs the handshake. Throws [XmppAuthException],
  /// [XmppProtocolException], [TimeoutException] or socket errors.
  Future<Jid> connect(XmppCredentials c) async {
    final serverDomain = c.endpoint.serverDomain;
    try {
      final socket = await connector(c.endpoint).timeout(stepTimeout);
      if (_closed) {
        unawaited(socket.close());
        throw const XmppProtocolException('closed');
      }
      _socket = socket;
      _sub = socket.input.listen(
        _onChunk,
        onError: (Object e) => _fail(e),
        onDone: () => _fail(const XmppProtocolException('socket-closed')),
        cancelOnError: true,
      );

      // 1. Stream + features.
      _write(XmppStanzas.streamOpen(serverDomain));
      await _waitFor((e) => e.name.local == 'features');

      // 2. SASL.
      _write(
        XmppStanzas.auth(accessToken: c.accessToken, pasToken: c.pasToken),
      );
      final sasl = await _waitFor(
        (e) => e.name.local == 'success' || e.name.local == 'failure',
      );
      if (sasl.name.local == 'failure') {
        final condition =
            sasl.childElements.firstOrNull?.name.local ?? 'not-authorized';
        throw XmppAuthException(condition);
      }

      // 3. Restart the stream.
      _write(XmppStanzas.streamOpen(serverDomain));
      await _waitFor((e) => e.name.local == 'features');

      // 4. Bind + session.
      final bind = await sendIq((id) => XmppStanzas.bind(id), prefix: 'bind');
      boundJid =
          Jid.parse(xmlChildText(xmlChild(bind, 'bind'), 'jid')) ??
          Jid.parse(bind.getAttribute('to'));
      await _tolerant(sendIq((id) => XmppStanzas.session(id), prefix: 'sess'));

      // 5. Entitlements.
      await _tolerant(
        sendIq(
          (id) => XmppStanzas.entitlements(id, c.entitlementsToken),
          prefix: 'ent',
        ),
      );

      _ready = true;
      _keepAlive = Timer.periodic(keepAliveInterval, (_) {
        _write(XmppStanzas.keepAlive);
      });
      onLog?.call('xmpp.connected', c.endpoint.host);
      final jid = boundJid;
      if (jid == null) throw const XmppProtocolException('no-jid');
      return jid;
    } on Object catch (e) {
      _fail(e);
      rethrow;
    }
  }

  /// Sends an iq built by [build] with a fresh id and waits for the
  /// matching `result` (an `error` result throws [XmppProtocolException]).
  Future<XmlElement> sendIq(
    String Function(String id) build, {
    String prefix = 'iq',
    Duration? timeout,
  }) {
    if (_closed) {
      return Future.error(const XmppProtocolException('closed'));
    }
    final id = nextId(prefix);
    final completer = Completer<XmlElement>();
    _pendingIq[id] = completer;
    _write(build(id));
    return completer.future.timeout(
      timeout ?? stepTimeout,
      onTimeout: () {
        _pendingIq.remove(id);
        throw TimeoutException('iq');
      },
    );
  }

  /// Writes a raw stanza (no-op once closed).
  void send(String stanza) => _write(stanza);

  /// Ends the stream politely and closes the socket.
  Future<void> close() async {
    if (_closed) return;
    if (_ready) _write(XmppStanzas.streamClose);
    _finish(null);
    await _socket?.close();
  }

  // ------------------------------------------------------------ internals

  Future<void> _tolerant(Future<XmlElement> f) async {
    try {
      await f;
    } on XmppProtocolException {
      // Optional step refused by the server: carry on.
    }
  }

  Future<XmlElement> _waitFor(bool Function(XmlElement) test) {
    if (_closed) return Future.error(const XmppProtocolException('closed'));
    final w = _Waiter(test);
    _waiters.add(w);
    return w.completer.future.timeout(
      stepTimeout,
      onTimeout: () {
        _waiters.remove(w);
        throw TimeoutException('handshake');
      },
    );
  }

  void _write(String data) {
    if (_closed) return;
    _socket?.write(data);
  }

  void _onChunk(String chunk) {
    final List<XmppStreamEvent> events;
    try {
      events = _parser.add(chunk);
    } on FormatException catch (e) {
      _fail(e);
      return;
    }
    for (final e in events) {
      if (_closed) return;
      switch (e) {
        case XmppStreamClosed():
          _fail(const XmppProtocolException('stream-closed'));
        case XmppStreamOpened():
          break;
        case XmppStanza(:final element):
          _onStanza(element);
      }
    }
  }

  void _onStanza(XmlElement el) {
    final local = el.name.local;
    if (local == 'error' && el.name.prefix == 'stream') {
      final condition =
          el.childElements.firstOrNull?.name.local ?? 'stream-error';
      _fail(XmppProtocolException(condition));
      return;
    }
    if (local == 'iq') {
      final id = el.getAttribute('id');
      final type = el.getAttribute('type');
      final pending = id == null ? null : _pendingIq[id];
      if (pending != null && (type == 'result' || type == 'error')) {
        _pendingIq.remove(id);
        if (type == 'error') {
          final err = xmlChild(el, 'error');
          pending.completeError(
            XmppProtocolException(
              err?.childElements.firstOrNull?.name.local ?? 'iq-error',
            ),
          );
        } else {
          pending.complete(el);
        }
        return;
      }
      if (id != null && (type == 'get' || type == 'set')) {
        // Pings and roster pushes: acknowledge, then pass on.
        _write(XmppStanzas.iqResult(id, to: el.getAttribute('from')));
      }
    }
    for (final w in List<_Waiter>.of(_waiters)) {
      if (w.test(el)) {
        _waiters.remove(w);
        w.completer.complete(el);
        return;
      }
    }
    if (!_stanzas.isClosed) _stanzas.add(el);
  }

  void _fail(Object error) {
    if (_closed) return;
    onLog?.call('xmpp.closed', xmppError(error).toString());
    _finish(error);
    unawaited(_socket?.close());
  }

  void _finish(Object? error) {
    if (_closed) return;
    _closed = true;
    _ready = false;
    _keepAlive?.cancel();
    _keepAlive = null;
    unawaited(_sub?.cancel());
    _sub = null;
    final err = error ?? const XmppProtocolException('closed');
    for (final w in _waiters) {
      if (!w.completer.isCompleted) w.completer.completeError(err);
    }
    _waiters.clear();
    for (final c in _pendingIq.values) {
      if (!c.isCompleted) c.completeError(err);
    }
    _pendingIq.clear();
    unawaited(_stanzas.close());
    if (!_done.isCompleted) {
      if (error == null) {
        _done.complete();
      } else {
        _done.completeError(error);
      }
    }
  }
}
