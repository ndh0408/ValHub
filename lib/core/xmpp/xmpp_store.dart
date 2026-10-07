import 'dart:async';

import 'package:flutter/foundation.dart';

import 'xmpp_models.dart';
import 'xmpp_parsers.dart';

/// Immutable view of everything the chat connection knows.
@immutable
class XmppSnapshot {
  const XmppSnapshot({
    this.connection = XmppConnectionState.idle,
    this.rosterLoaded = false,
    this.roster = const {},
    this.presences = const {},
    this.ownPresence,
    this.unread = const {},
  });

  final XmppConnectionState connection;

  /// The roster answered at least once (the friend list is meaningful).
  final bool rosterLoaded;

  /// Accepted friends by lowercase PUUID.
  final Map<String, RosterEntry> roster;

  /// Best available presence of every online user (friends or not) by PUUID.
  final Map<String, FriendPresence> presences;

  /// The signed-in player's own game-client presence (live score G7, own
  /// party id, loop state); `null` when the game is not running.
  final FriendPresence? ownPresence;

  /// Unread incoming messages by friend PUUID (only non-zero entries).
  final Map<String, int> unread;

  int get totalUnread => unread.values.fold(0, (a, b) => a + b);
}

/// In-memory state of one account's chat (roster, presences, conversations,
/// unread counts). Pure Dart, no sockets: [XmppService] feeds it parsed
/// stanzas and tests can seed it directly.
///
/// Change notifications are coalesced per microtask, so a burst of
/// presences arriving in one socket chunk yields one snapshot.
class XmppStore {
  XmppStore({required String ownPuuid, DateTime Function()? now})
    : ownPuuid = ownPuuid.toLowerCase(),
      _now = now ?? DateTime.now;

  final String ownPuuid;
  final DateTime Function() _now;

  /// Resource bound by this app (our own presence echo is ignored).
  String? ownResource;

  XmppConnectionState _connection = XmppConnectionState.idle;
  final Map<String, RosterEntry> _roster = {};
  bool _rosterLoaded = false;
  final Map<String, Map<String, FriendPresence>> _presences = {};
  final Map<String, FriendPresence> _ownPresences = {};
  final Map<String, Conversation> _conversations = {};
  final Map<String, int> _unread = {};
  String? _active;

  XmppSnapshot? _snapshot;
  Map<String, RosterEntry>? _rosterView;
  Map<String, FriendPresence>? _presenceView;
  FriendPresence? _ownView;
  bool _ownViewValid = false;
  Map<String, int>? _unreadView;
  bool _emitScheduled = false;
  bool _dirtyConnection = false;
  bool _dirtyRoster = false;
  bool _dirtyPresence = false;
  bool _dirtyOwn = false;
  final Set<String> _dirtyConversations = {};
  bool _disposed = false;

  final _snapshotCtrl = StreamController<XmppSnapshot>.broadcast(sync: true);
  final _connectionCtrl = StreamController<XmppConnectionState>.broadcast(
    sync: true,
  );
  final _rosterCtrl = StreamController<Map<String, RosterEntry>>.broadcast(
    sync: true,
  );
  final _presenceCtrl = StreamController<Map<String, FriendPresence>>.broadcast(
    sync: true,
  );
  final _ownCtrl = StreamController<FriendPresence?>.broadcast(sync: true);
  final _messageCtrl = StreamController<ChatMessage>.broadcast(sync: true);
  final _conversationCtrl = StreamController<Conversation>.broadcast(
    sync: true,
  );

  // ------------------------------------------------------------ reading

  /// Parts are rebuilt only when they changed, so `select`ing e.g. the
  /// roster does not fire on every presence.
  XmppSnapshot get snapshot {
    final cached = _snapshot;
    if (cached != null) return cached;
    if (!_ownViewValid) {
      _ownView = bestPresence(_ownPresences.values);
      _ownViewValid = true;
    }
    return _snapshot = XmppSnapshot(
      connection: _connection,
      rosterLoaded: _rosterLoaded,
      roster: _rosterView ??= Map.unmodifiable(_roster),
      presences: _presenceView ??= Map.unmodifiable({
        for (final MapEntry(:key, :value) in _presences.entries)
          key: ?bestPresence(value.values),
      }),
      ownPresence: _ownView,
      unread: _unreadView ??= Map.unmodifiable(_unread),
    );
  }

  XmppConnectionState get connection => _connection;

  /// Current snapshot first, then one per coalesced change.
  Stream<XmppSnapshot> get snapshots =>
      _withCurrent(_snapshotCtrl, () => snapshot);

  Stream<XmppConnectionState> get connectionStates =>
      _withCurrent(_connectionCtrl, () => _connection);

  Stream<Map<String, RosterEntry>> get rosterChanges =>
      _withCurrent(_rosterCtrl, () => snapshot.roster);

  Stream<Map<String, FriendPresence>> get presenceChanges =>
      _withCurrent(_presenceCtrl, () => snapshot.presences);

  Stream<FriendPresence?> get ownPresenceChanges =>
      _withCurrent(_ownCtrl, () => snapshot.ownPresence);

  /// Every new message (live incoming and sent), not archive history.
  Stream<ChatMessage> get messages => _messageCtrl.stream;

  Conversation conversation(String friendPuuid) {
    final id = friendPuuid.toLowerCase();
    return _conversations[id] ?? Conversation(friendPuuid: id);
  }

  /// One conversation: current state first, then every change.
  Stream<Conversation> watchConversation(String friendPuuid) {
    final id = friendPuuid.toLowerCase();
    return Stream.multi((c) {
      c.add(conversation(id));
      final sub = _conversationCtrl.stream
          .where((conv) => conv.friendPuuid == id)
          .listen(c.add, onError: c.addError, onDone: c.close);
      c.onCancel = sub.cancel;
    });
  }

  String? get activeConversation => _active;

  // ------------------------------------------------------------ writing

  void setConnection(XmppConnectionState state) {
    if (state == _connection) return;
    _connection = state;
    _dirtyConnection = true;
    _changed();
  }

  /// Replaces the roster with a full query result.
  void setRoster(Iterable<RosterEntry> entries) {
    _roster
      ..clear()
      ..addEntries(
        entries.where((e) => e.isFriend).map((e) => MapEntry(e.puuid, e)),
      );
    _rosterLoaded = true;
    _rosterView = null;
    _dirtyRoster = true;
    _changed();
  }

  /// Applies a roster push (`iq set`): upserts friends, drops removals and
  /// entries that are no longer friends.
  void applyRosterPush(Iterable<RosterEntry> entries) {
    var changed = false;
    for (final e in entries) {
      if (e.isFriend) {
        if (_roster[e.puuid] != e) {
          _roster[e.puuid] = e;
          changed = true;
        }
      } else if (_roster.remove(e.puuid) != null) {
        changed = true;
      }
    }
    if (!changed) return;
    _rosterView = null;
    _dirtyRoster = true;
    _changed();
  }

  /// Applies one parsed `<presence>` (a friend's, or our own game client's).
  void applyPresence(FriendPresence p) {
    final id = p.puuid;
    final resource = p.resource ?? '';
    if (id == ownPuuid) {
      if (p.resource != null && p.resource == ownResource) return;
      final changed = p.available
          ? _ownPresences[resource] != p
          : _ownPresences.containsKey(resource);
      if (!changed) return;
      if (p.available) {
        _ownPresences[resource] = p;
      } else {
        _ownPresences.remove(resource);
      }
      _ownViewValid = false;
      _dirtyOwn = true;
      _changed();
      return;
    }
    final byResource = _presences[id];
    if (!p.available) {
      if (byResource == null) return;
      if (p.resource == null) {
        _presences.remove(id);
      } else {
        if (byResource.remove(resource) == null) return;
        if (byResource.isEmpty) _presences.remove(id);
      }
      _stampLastOnline(id);
    } else {
      final map = _presences.putIfAbsent(id, () => {});
      if (map[resource] == p) return;
      map[resource] = p;
    }
    _presenceView = null;
    _dirtyPresence = true;
    _changed();
  }

  /// Someone just went offline: "Hoạt động vừa xong" instead of an old
  /// roster `last_online`.
  void _stampLastOnline(String id) {
    final entry = _roster[id];
    if (entry == null || _presences.containsKey(id)) return;
    _roster[id] = entry.copyWith(lastOnline: _now().toUtc());
    _rosterView = null;
    _dirtyRoster = true;
  }

  /// Forgets every presence (reconnect: the server resends them).
  void clearPresences() {
    if (_presences.isEmpty && _ownPresences.isEmpty) return;
    _presences.clear();
    _ownPresences.clear();
    _presenceView = null;
    _dirtyPresence = true;
    _ownViewValid = false;
    _dirtyOwn = true;
    _changed();
  }

  /// A live message (incoming or just sent). Incoming messages count as
  /// unread unless their conversation is open.
  void addLiveMessage(ChatMessage m) {
    _merge(m.friendPuuid, [m]);
    if (!m.outgoing && _active != m.friendPuuid) {
      _unread[m.friendPuuid] = (_unread[m.friendPuuid] ?? 0) + 1;
      _unreadView = null;
    }
    if (!_messageCtrl.isClosed) _messageCtrl.add(m);
    _changed();
  }

  /// Archive result for one friend (never counts as unread).
  void addHistory(String friendPuuid, List<ChatMessage> history) {
    final id = friendPuuid.toLowerCase();
    _merge(id, history);
    _conversations[id] = conversation(id)
        .copyWith(historyLoaded: true, loadingHistory: false, clearError: true);
    _dirtyConversations.add(id);
    _changed();
  }

  /// Replaces one message (delivery status change).
  void updateMessage(ChatMessage m) {
    final conv = conversation(m.friendPuuid);
    final i = conv.messages.indexWhere((x) => x.id == m.id);
    if (i < 0) return;
    final list = List<ChatMessage>.of(conv.messages)..[i] = m;
    _conversations[m.friendPuuid] = conv.copyWith(messages: list);
    _dirtyConversations.add(m.friendPuuid);
    _changed();
  }

  /// Drops one message (a failed send the user sent again).
  void removeMessage(String friendPuuid, String messageId) {
    final id = friendPuuid.toLowerCase();
    final conv = conversation(id);
    final list = conv.messages.where((m) => m.id != messageId).toList();
    if (list.length == conv.messages.length) return;
    _conversations[id] = conv.copyWith(messages: List.unmodifiable(list));
    _dirtyConversations.add(id);
    _changed();
  }

  void updateConversation(
    String friendPuuid,
    Conversation Function(Conversation) update,
  ) {
    final id = friendPuuid.toLowerCase();
    _conversations[id] = update(conversation(id));
    _dirtyConversations.add(id);
    _changed();
  }

  /// The chat screen of [friendPuuid] is visible (`null` = none): its
  /// messages are read as they arrive.
  void setActiveConversation(String? friendPuuid) {
    _active = friendPuuid?.toLowerCase();
    if (_active != null) markRead(_active!);
  }

  void markRead(String friendPuuid) {
    if (_unread.remove(friendPuuid.toLowerCase()) == null) return;
    _unreadView = null;
    _changed();
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final c in [
      _snapshotCtrl,
      _connectionCtrl,
      _rosterCtrl,
      _presenceCtrl,
      _ownCtrl,
      _messageCtrl,
      _conversationCtrl,
    ]) {
      unawaited(c.close());
    }
  }

  // ------------------------------------------------------------ internals

  void _merge(String friendPuuid, List<ChatMessage> incoming) {
    final id = friendPuuid.toLowerCase();
    final conv = conversation(id);
    final byId = <String, ChatMessage>{for (final m in conv.messages) m.id: m};
    for (final m in incoming) {
      if (byId.containsKey(m.id)) {
        byId[m.id] = _preferServer(byId[m.id]!, m);
        continue;
      }
      // An archived copy of a message sent from this app has a server id:
      // replace the local copy (same body, within 5 minutes).
      if (m.outgoing) {
        final local = byId.values
            .where(
              (x) =>
                  x.outgoing &&
                  x.id.startsWith(localMessagePrefix) &&
                  x.body == m.body &&
                  x.at.difference(m.at).abs() < const Duration(minutes: 5),
            )
            .firstOrNull;
        if (local != null && !m.id.startsWith(localMessagePrefix)) {
          byId.remove(local.id);
        }
      }
      byId[m.id] = m;
    }
    final list = byId.values.toList()
      ..sort((a, b) {
        final c = a.at.compareTo(b.at);
        return c != 0 ? c : a.id.compareTo(b.id);
      });
    _conversations[id] = conv.copyWith(messages: List.unmodifiable(list));
    _dirtyConversations.add(id);
  }

  static ChatMessage _preferServer(ChatMessage existing, ChatMessage next) =>
      existing.status == ChatMessageStatus.failed ? existing : next;

  void _changed() {
    _snapshot = null;
    if (_emitScheduled || _disposed) return;
    _emitScheduled = true;
    scheduleMicrotask(_flush);
  }

  void _flush() {
    _emitScheduled = false;
    if (_disposed) return;
    final snap = snapshot;
    if (_dirtyConnection) _connectionCtrl.add(snap.connection);
    if (_dirtyRoster) _rosterCtrl.add(snap.roster);
    if (_dirtyPresence) _presenceCtrl.add(snap.presences);
    if (_dirtyOwn) _ownCtrl.add(snap.ownPresence);
    for (final id in _dirtyConversations) {
      _conversationCtrl.add(conversation(id));
    }
    _dirtyConnection = false;
    _dirtyRoster = false;
    _dirtyPresence = false;
    _dirtyOwn = false;
    _dirtyConversations.clear();
    _snapshotCtrl.add(snap);
  }

  static Stream<T> _withCurrent<T>(
    StreamController<T> ctrl,
    T Function() current,
  ) => Stream.multi((c) {
    c.add(current());
    final sub = ctrl.stream.listen(c.add, onError: c.addError, onDone: c.close);
    c.onCancel = sub.cancel;
  });
}

/// Id prefix of messages sent from this app (before the archive returns
/// the server copy).
const localMessagePrefix = 'valvn-';
