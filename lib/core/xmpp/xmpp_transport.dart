import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Where to open the chat socket (SUMMARY §6.5).
@immutable
class XmppEndpoint {
  const XmppEndpoint({
    required this.host,
    required this.domain,
    this.port = 5223,
    this.affinity,
  });

  /// TLS host, e.g. `jp1.chat.si.riotgames.com`.
  final String host;
  final int port;

  /// XMPP domain prefix (`jp1`): the stream is opened with
  /// `to="{domain}.pvp.net"` and JIDs are `{puuid}@{domain}.pvp.net`.
  final String domain;

  /// PAS `affinity` claim this endpoint was derived from (diagnostics only).
  final String? affinity;

  /// Full server domain, e.g. `jp1.pvp.net`.
  String get serverDomain => '$domain.pvp.net';

  @override
  bool operator ==(Object other) =>
      other is XmppEndpoint &&
      other.host == host &&
      other.port == port &&
      other.domain == domain;

  @override
  int get hashCode => Object.hash(host, port, domain);

  @override
  String toString() => 'XmppEndpoint($host:$port, $domain)';
}

/// One open, already-encrypted chat socket.
///
/// [input] delivers decoded UTF-8 text in arbitrary chunks (a stanza can be
/// split anywhere, several stanzas can share a chunk) and completes when the
/// socket closes (with an error for network failures).
abstract interface class XmppSocket {
  Stream<String> get input;

  void write(String data);

  Future<void> close();
}

/// Opens an [XmppSocket] to [endpoint]. Replaced by a fake in tests.
typedef XmppConnector = Future<XmppSocket> Function(XmppEndpoint endpoint);

/// Production connector: direct TLS (`SecureSocket`, no STARTTLS) to
/// `{host}:5223`.
class SecureSocketConnector {
  const SecureSocketConnector({this.timeout = const Duration(seconds: 15)});

  final Duration timeout;

  Future<XmppSocket> call(XmppEndpoint endpoint) async {
    final socket = await SecureSocket.connect(
      endpoint.host,
      endpoint.port,
      timeout: timeout,
    );
    socket.setOption(SocketOption.tcpNoDelay, true);
    return _IoXmppSocket(socket);
  }
}

class _IoXmppSocket implements XmppSocket {
  _IoXmppSocket(this._socket)
    : input = const Utf8Decoder(allowMalformed: true).bind(_socket) {
    // Write errors surface on `done`; the read side reports the failure.
    unawaited(_socket.done.then<void>((_) {}, onError: (Object _) {}));
  }

  final SecureSocket _socket;
  bool _closed = false;

  @override
  final Stream<String> input;

  @override
  void write(String data) {
    if (_closed) return;
    try {
      _socket.add(utf8.encode(data));
    } on Object {
      // The socket is already gone; the input stream reports it.
    }
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    try {
      await _socket.close().timeout(const Duration(seconds: 2));
    } on Object {
      // ignore: close failures leave nothing to clean up but the socket.
    } finally {
      _socket.destroy();
    }
  }
}
