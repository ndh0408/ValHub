import 'dart:async';

import 'package:xml/xml.dart';

import '../auth/session_manager.dart';
import '../network/riot_exception.dart';
import '../riot/pvp_api.dart';
import '../util/clock.dart';
import '../util/json.dart';
import 'xmpp_client.dart';
import 'xmpp_models.dart';
import 'xmpp_parsers.dart';
import 'xmpp_stanzas.dart';
import 'xmpp_store.dart';
import 'xmpp_transport.dart';

/// Tokens and chat endpoint for one account.
abstract interface class XmppCredentialSource {
  /// Fresh (or still valid) credentials. Throws [NeedsLoginException] /
  /// [TransientException].
  Future<XmppCredentials> credentials(String puuid);

  /// The chat server refused [failedAccessToken]: force a silent re-auth
  /// so the next [credentials] call returns new tokens.
  Future<void> invalidate(String puuid, {required String failedAccessToken});
}

/// Production [XmppCredentialSource]: session tokens from [SessionManager],
/// PAS token (A-7) and client config (A-8) from [PvpApi].
class RiotXmppCredentialSource implements XmppCredentialSource {
  RiotXmppCredentialSource({required this._sessions, required this._api});

  final SessionManager _sessions;
  final PvpApi _api;
  final Map<String, JsonMap> _configs = {};

  @override
  Future<XmppCredentials> credentials(String puuid) async {
    final session = await _sessions.session(puuid);
    final pas = await _api.chatPasToken(puuid);
    var config = _configs[puuid];
    if (config == null) {
      try {
        config = await _api.chatClientConfig(puuid);
        _configs[puuid] = config;
      } on TransientException {
        // The region fallback table still gives a host.
        config = const {};
      } on RiotApiException {
        config = const {};
      }
    }
    final endpoint = resolveXmppEndpoint(
      pasToken: pas,
      clientConfig: config,
      region: session.region,
    );
    if (endpoint == null) {
      throw const TransientException(reason: 'xmpp_no_endpoint');
    }
    return XmppCredentials(
      puuid: puuid,
      accessToken: session.accessToken,
      pasToken: pas,
      entitlementsToken: session.entitlementsToken,
      endpoint: endpoint,
    );
  }

  @override
  Future<void> invalidate(
    String puuid, {
    required String failedAccessToken,
  }) async {
    _configs.remove(puuid);
    await _sessions.refreshAfterAuthFailure(
      puuid,
      failedAccessToken: failedAccessToken,
    );
  }
}

/// Riot chat for one signed-in account (SUMMARY §6.5, §10):
///
/// - [start] connects (TLS → SASL → bind → session → entitlements →
///   roster → `<presence/>`) and keeps the connection up, retrying with
///   [backoff] and fresh tokens on every attempt;
/// - a SASL refusal forces one silent re-auth, then retries once;
///   [NeedsLoginException] stops everything ([XmppStatus.needsLogin]);
/// - [stop] disconnects (app backgrounded) but keeps roster and
///   conversations in memory; [reconnect] drops the socket and connects
///   again with fresh tokens (after a re-auth);
/// - state lives in [store]; streams: [connectionStates], [rosterChanges],
///   [presenceChanges], [ownPresenceChanges], [messages], [snapshots].
///
/// Nothing is logged but host names and error kinds.
class XmppService {
  XmppService({
    required String puuid,
    required this._credentials,
    XmppConnector? connector,
    Clock clock = const Clock(),
    this.onLog,
    this.keepAliveInterval = const Duration(seconds: 120),
    this.stepTimeout = const Duration(seconds: 15),
    this.backoff = const [
      Duration(seconds: 2),
      Duration(seconds: 5),
      Duration(seconds: 15),
      Duration(seconds: 30),
      Duration(seconds: 60),
    ],
  }) : puuid = puuid.toLowerCase(),
       _connector = connector ?? const SecureSocketConnector().call,
       _clock = clock,
       store = XmppStore(ownPuuid: puuid, now: clock.now);

  final String puuid;
  final XmppCredentialSource _credentials;
  final XmppConnector _connector;
  final Clock _clock;
  final void Function(String event, String? detail)? onLog;
  final Duration keepAliveInterval;
  final Duration stepTimeout;

  /// Delays between automatic reconnects; after the last one the service
  /// stays [XmppStatus.failed] until [retryNow] / [refresh].
  final List<Duration> backoff;

  final XmppStore store;

  XmppClient? _client;
  XmppEndpoint? _endpoint;
  Future<void>? _connecting;
  Timer? _retry;
  StreamSubscription<XmlElement>? _stanzaSub;
  int _attempt = 0;
  int _generation = 0;
  int _sent = 0;
  bool _wanted = false;
  bool _disposed = false;

  // --------------------------------------------------------------- state

  XmppSnapshot get snapshot => store.snapshot;

  XmppConnectionState get connection => store.connection;

  bool get isConnected => _client?.isOpen ?? false;

  /// Whether the service is supposed to be connected (foreground + used).
  bool get isStarted => _wanted;

  Stream<XmppSnapshot> get snapshots => store.snapshots;

  Stream<XmppConnectionState> get connectionStates => store.connectionStates;

  Stream<Map<String, RosterEntry>> get rosterChanges => store.rosterChanges;

  Stream<Map<String, FriendPresence>> get presenceChanges =>
      store.presenceChanges;

  Stream<FriendPresence?> get ownPresenceChanges => store.ownPresenceChanges;

  Stream<ChatMessage> get messages => store.messages;

  Stream<Conversation> watchConversation(String friendPuuid) =>
      store.watchConversation(friendPuuid);

  // ----------------------------------------------------------- lifecycle

  /// Connects unless already connected / connecting.
  void start() {
    if (_disposed) return;
    _wanted = true;
    if (isConnected || _connecting != null || _retry != null) return;
    if (connection.status == XmppStatus.needsLogin) return;
    unawaited(_connect());
  }

  /// Disconnects (app backgrounded / nobody listening). Roster and
  /// conversations stay in memory.
  Future<void> stop() async {
    _wanted = false;
    _generation++;
    // The running attempt is now stale (it exits on the generation check);
    // forget it so a start() right after this one connects again instead
    // of waiting on an attempt that will never connect.
    _connecting = null;
    _retry?.cancel();
    _retry = null;
    _attempt = 0;
    final client = _client;
    _client = null;
    await _stanzaSub?.cancel();
    _stanzaSub = null;
    await client?.close();
    if (connection.status != XmppStatus.needsLogin) {
      store.setConnection(XmppConnectionState.idle);
    }
  }

  /// Drops the socket and connects again with fresh tokens (after a
  /// re-auth / re-login). No-op while stopped unless [force].
  Future<void> reconnect({bool force = false}) async {
    final wanted = _wanted || force;
    await stop();
    if (connection.status == XmppStatus.needsLogin) {
      store.setConnection(XmppConnectionState.idle);
    }
    if (wanted) start();
  }

  /// Retries at once after a failure (the "Thử lại" button).
  Future<void> retryNow() => reconnect(force: true);

  /// Pull-to-refresh: re-reads the roster when connected, otherwise
  /// connects and waits for the outcome.
  Future<void> refresh() async {
    final client = _client;
    if (client != null && client.isOpen) {
      try {
        await _loadRoster(client);
      } on Object {
        // A failing roster query on a live socket: reconnect below.
        await reconnect(force: true);
      }
      return;
    }
    await reconnect(force: true);
    await waitUntilConnected().catchError((Object _) {});
  }

  /// The account needs to sign in again: disconnect and stay down.
  Future<void> markNeedsLogin() async {
    await stop();
    store.setConnection(
      XmppConnectionState(
        XmppStatus.needsLogin,
        error: NeedsLoginException(puuid: puuid, reason: 'xmpp'),
      ),
    );
  }

  /// Completes once connected. Otherwise waits for the outcome of the
  /// current / next attempt and throws its [RiotException] (a new failure,
  /// [XmppStatus.failed], [XmppStatus.needsLogin]), or a timeout
  /// [TransientException] after [timeout]. Call [start] first.
  Future<void> waitUntilConnected({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final now = connection;
    if (now.status == XmppStatus.connected) return;
    if (now.status == XmppStatus.needsLogin) {
      throw now.error ?? const NeedsLoginException(reason: 'xmpp');
    }
    final state = await connectionStates
        .skip(1) // only changes: a pending retry's old error does not count
        .firstWhere(
          (s) =>
              s.status == XmppStatus.connected ||
              s.status == XmppStatus.failed ||
              s.status == XmppStatus.needsLogin ||
              (s.status == XmppStatus.reconnecting && s.error != null) ||
              (s.status == XmppStatus.idle && !_wanted),
        )
        .timeout(
          timeout,
          onTimeout: () => const XmppConnectionState(
            XmppStatus.failed,
            error: TransientException(reason: 'timeout'),
          ),
        );
    if (state.status == XmppStatus.connected) return;
    throw state.error ?? const TransientException(reason: 'xmpp_offline');
  }

  Future<void> dispose() async {
    if (_disposed) return;
    await stop();
    _disposed = true;
    store.dispose();
  }

  // ---------------------------------------------------------------- chat

  /// Fetches the archive with [friendPuuid] and merges it (waits for the
  /// connection first). Failures land in `Conversation.historyError`.
  Future<void> loadHistory(String friendPuuid) async {
    final id = friendPuuid.toLowerCase();
    store.updateConversation(
      id,
      (c) => c.copyWith(loadingHistory: true, clearError: true),
    );
    try {
      if (!isConnected) {
        start();
        await waitUntilConnected();
      }
      final client = _client;
      if (client == null || !client.isOpen) {
        throw const TransientException(reason: 'xmpp_offline');
      }
      final result = await client.sendIq(
        (iqId) => XmppStanzas.archiveQuery(iqId, _jidOf(id)),
        prefix: 'arc',
        timeout: stepTimeout * 2,
      );
      store.addHistory(
        id,
        parseArchive(result, ownPuuid: puuid, receivedAt: _clock.now()),
      );
    } on Object catch (e) {
      store.updateConversation(
        id,
        (c) => c.copyWith(loadingHistory: false, historyError: xmppError(e)),
      );
    }
  }

  /// Sends [text] to [friendPuuid] (user action). Throws
  /// [TransientException] when not connected.
  Future<ChatMessage> sendMessage(String friendPuuid, String text) async {
    final body = text.trim();
    if (body.isEmpty) throw ArgumentError.value(text, 'text', 'empty');
    final id = friendPuuid.toLowerCase();
    final client = _client;
    if (client == null || !client.isOpen) {
      throw const TransientException(reason: 'xmpp_offline');
    }
    final now = _clock.now().toUtc();
    final message = ChatMessage(
      id: '$localMessagePrefix${now.millisecondsSinceEpoch}-${++_sent}',
      friendPuuid: id,
      outgoing: true,
      body: body,
      at: now,
      status: ChatMessageStatus.sent,
    );
    client.send(
      XmppStanzas.message(id: message.id, to: _jidOf(id), body: body),
    );
    store.addLiveMessage(message);
    return message;
  }

  void setActiveConversation(String? friendPuuid) =>
      store.setActiveConversation(friendPuuid);

  void markRead(String friendPuuid) => store.markRead(friendPuuid);

  // ----------------------------------------------------------- internals

  String _jidOf(String friendPuuid) {
    final fromRoster = store.snapshot.roster[friendPuuid]?.jid;
    if (fromRoster != null && fromRoster.contains('@')) return fromRoster;
    final domain =
        _endpoint?.serverDomain ?? _client?.boundJid?.domain ?? 'pvp.net';
    return '$friendPuuid@$domain';
  }

  Future<void> _connect() {
    final gen = ++_generation;
    store.setConnection(
      XmppConnectionState(
        _attempt == 0 ? XmppStatus.connecting : XmppStatus.reconnecting,
        attempt: _attempt,
        error: connection.error,
      ),
    );
    final future = _run(gen);
    _connecting = future;
    return future.whenComplete(() {
      if (identical(_connecting, future)) _connecting = null;
    });
  }

  Future<void> _run(int gen) async {
    var reauthed = false;
    while (true) {
      XmppCredentials? creds;
      XmppClient? client;
      try {
        creds = await _credentials.credentials(puuid);
        if (gen != _generation) return;
        _endpoint = creds.endpoint;
        onLog?.call('xmpp.connect', creds.endpoint.host);
        client = XmppClient(
          connector: _connector,
          keepAliveInterval: keepAliveInterval,
          stepTimeout: stepTimeout,
          onLog: onLog,
        );
        _client = client;
        final jid = await client.connect(creds);
        if (gen != _generation) {
          await client.close();
          return;
        }
        store
          ..ownResource = jid.resource
          ..clearPresences();
        await _loadRoster(client);
        if (gen != _generation) return;
        // From here on the socket's own `done` drives reconnects; stanzas
        // that arrived during the roster query are buffered by the client.
        _listen(client, gen);
        client.send(XmppStanzas.presence);
        _attempt = 0;
        store.setConnection(const XmppConnectionState(XmppStatus.connected));
        final active = store.activeConversation;
        if (active != null) unawaited(loadHistory(active));
        return;
      } on NeedsLoginException catch (e) {
        await client?.close();
        if (gen != _generation) return;
        _client = null;
        _wanted = false;
        store.setConnection(
          XmppConnectionState(XmppStatus.needsLogin, error: e),
        );
        return;
      } on XmppAuthException catch (e) {
        await client?.close();
        if (gen != _generation) return;
        _client = null;
        if (!reauthed && creds != null) {
          reauthed = true;
          try {
            await _credentials.invalidate(
              puuid,
              failedAccessToken: creds.accessToken,
            );
          } on NeedsLoginException catch (e) {
            if (gen != _generation) return;
            _wanted = false;
            store.setConnection(
              XmppConnectionState(XmppStatus.needsLogin, error: e),
            );
            return;
          } on Object catch (e) {
            if (gen != _generation) return;
            _scheduleRetry(gen, xmppError(e));
            return;
          }
          if (gen != _generation) return;
          continue;
        }
        store.setConnection(
          XmppConnectionState(
            XmppStatus.failed,
            error: xmppError(e),
            attempt: _attempt + 1,
          ),
        );
        return;
      } on Object catch (e) {
        await client?.close();
        if (gen != _generation) return;
        _client = null;
        _scheduleRetry(gen, xmppError(e));
        return;
      }
    }
  }

  void _listen(XmppClient client, int gen) {
    unawaited(_stanzaSub?.cancel());
    _stanzaSub = client.stanzas.listen(_onStanza);
    unawaited(
      client.done.then<void>(
        (_) {},
        onError: (Object e) {
          if (gen != _generation || _disposed || !identical(_client, client)) {
            return;
          }
          _client = null;
          if (_wanted) _scheduleRetry(gen, xmppError(e));
        },
      ),
    );
  }

  void _scheduleRetry(int gen, RiotException error) {
    if (gen != _generation || _disposed) return;
    _attempt++;
    if (!_wanted || _attempt > backoff.length) {
      store.setConnection(
        XmppConnectionState(XmppStatus.failed, error: error, attempt: _attempt),
      );
      return;
    }
    store.setConnection(
      XmppConnectionState(
        XmppStatus.reconnecting,
        error: error,
        attempt: _attempt,
      ),
    );
    _retry?.cancel();
    _retry = Timer(backoff[_attempt - 1], () {
      _retry = null;
      if (_wanted && !_disposed && gen == _generation) unawaited(_connect());
    });
  }

  Future<void> _loadRoster(XmppClient client) async {
    final result = await client.sendIq(
      XmppStanzas.rosterQuery,
      prefix: 'roster',
    );
    store.setRoster(parseRosterItems(result));
  }

  void _onStanza(XmlElement el) {
    switch (el.name.local) {
      case 'presence':
        final p = parsePresence(el, receivedAt: _clock.now());
        if (p != null) store.applyPresence(p);
      case 'message':
        final m = parseChatMessage(
          el,
          ownPuuid: puuid,
          receivedAt: _clock.now().toUtc(),
        );
        if (m != null) store.addLiveMessage(m);
      case 'iq':
        final query = xmlChild(el, 'query');
        if (el.getAttribute('type') == 'set' &&
            query?.getAttribute('xmlns') == XmppStanzas.rosterNs) {
          store.applyRosterPush(parseRosterItems(el));
        }
    }
  }
}
