import 'dart:async';

import 'package:flutter/widgets.dart'
    show AppLifecycleListener, AppLifecycleState, WidgetsBinding;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../accounts/account_providers.dart';
import '../auth/auth_providers.dart';
import '../domain/competitive/names.dart';
import '../logging/session_log.dart';
import '../network/riot_exception.dart';
import '../riot/pvp_api.dart';
import '../util/clock.dart';
import 'friends.dart';
import 'xmpp_models.dart';
import 'xmpp_service.dart';
import 'xmpp_store.dart';
import 'xmpp_transport.dart';

/// How long the chat stays connected after the last screen using it closed
/// (switching between Friends, Chat and Party does not reconnect).
const kXmppLinger = Duration(minutes: 3);

/// Whether a lifecycle state counts as "in the foreground".
bool isForegroundState(AppLifecycleState? state) =>
    state == null ||
    state == AppLifecycleState.resumed ||
    state == AppLifecycleState.inactive;

/// True while the app is visible. The chat socket only lives then
/// (SUMMARY §10: "Live socket while the app is in the foreground").
final appForegroundProvider = NotifierProvider<AppForegroundNotifier, bool>(
  AppForegroundNotifier.new,
);

class AppForegroundNotifier extends Notifier<bool> {
  @override
  bool build() {
    final listener = AppLifecycleListener(
      onStateChange: (s) => state = isForegroundState(s),
    );
    ref.onDispose(listener.dispose);
    return isForegroundState(WidgetsBinding.instance.lifecycleState);
  }
}

/// Opens chat sockets (fake in tests).
final xmppConnectorProvider = Provider<XmppConnector>(
  (ref) => const SecureSocketConnector().call,
);

/// Tokens + endpoint for the chat (session manager, A-7, A-8).
final xmppCredentialSourceProvider = Provider<XmppCredentialSource>((ref) {
  final log = ref.watch(sessionLogProvider);
  return RiotXmppCredentialSource(
    sessions: ref.watch(sessionManagerProvider),
    api: ref.watch(pvpApiProvider),
    onLog: (event, detail) => log.add(event, detail: detail),
  );
});

/// Riot chat of the **active** account; `null` when nobody is signed in.
///
/// - connects while the app is in the foreground and something watches it
///   (directly or through the providers below), disconnects when the app
///   is backgrounded and [kXmppLinger] after the last listener left;
/// - marks itself "needs login" when the account does, and reconnects with
///   fresh tokens once the account is signed in again;
/// - switching accounts creates a new service (the old one is disposed).
final xmppServiceProvider = Provider.autoDispose<XmppService?>((ref) {
  final puuid = ref.watch(activePuuidProvider);
  if (puuid == null) return null;
  final log = ref.watch(sessionLogProvider);
  final service = XmppService(
    puuid: puuid,
    credentials: ref.watch(xmppCredentialSourceProvider),
    connector: ref.watch(xmppConnectorProvider),
    clock: ref.watch(clockProvider),
    onLog: (event, detail) => log.add(event, detail: detail),
  );
  ref.onDispose(() => unawaited(service.dispose()));

  final link = ref.keepAlive();
  Timer? linger;
  ref
    ..onCancel(() {
      linger?.cancel();
      linger = Timer(kXmppLinger, link.close);
    })
    ..onResume(() {
      linger?.cancel();
      linger = null;
    })
    ..onDispose(() => linger?.cancel());

  ref
    ..listen<bool>(
      accountProvider(puuid).select((a) => a?.needsLogin ?? false),
      (previous, needsLogin) {
        if (needsLogin) {
          unawaited(service.markNeedsLogin());
        } else if (previous ?? false) {
          unawaited(service.reconnect(force: ref.read(appForegroundProvider)));
        }
      },
      fireImmediately: true,
    )
    ..listen<bool>(appForegroundProvider, (_, foreground) {
      if (foreground) {
        service.start();
      } else {
        unawaited(service.stop());
      }
    }, fireImmediately: true);
  return service;
});

/// Everything the chat knows (current value first, then every change).
/// Errors with `NeedsLoginException(reason: 'no_account')` when nobody is
/// signed in.
final xmppSnapshotProvider = StreamProvider.autoDispose<XmppSnapshot>((ref) {
  final service = ref.watch(xmppServiceProvider);
  if (service == null) {
    throw const NeedsLoginException(reason: 'no_account');
  }
  return service.snapshots;
});

/// Connection state of the active account's chat.
final xmppConnectionProvider = Provider.autoDispose<XmppConnectionState>(
  (ref) =>
      ref.watch(xmppSnapshotProvider.select((s) => s.value?.connection)) ??
      XmppConnectionState.idle,
);

/// Names of roster entries that came without a Riot ID (SUMMARY U10),
/// resolved through the batched name-service. Roster names are also
/// remembered by the app-wide [NameResolver].
final friendNamesProvider =
    NotifierProvider.autoDispose<FriendNamesNotifier, Map<String, RiotName>>(
      FriendNamesNotifier.new,
    );

class FriendNamesNotifier extends Notifier<Map<String, RiotName>> {
  final Set<String> _requested = {};

  @override
  Map<String, RiotName> build() {
    ref.listen<Map<String, RosterEntry>?>(
      xmppSnapshotProvider.select((s) => s.value?.roster),
      (_, roster) {
        if (roster != null) unawaited(_resolve(roster));
      },
      fireImmediately: true,
    );
    return const {};
  }

  Future<void> _resolve(Map<String, RosterEntry> roster) async {
    final resolver = ref.read(nameResolverProvider);
    final found = <String, RiotName>{};
    final missing = <String>[];
    for (final e in roster.values) {
      final name = e.name;
      if (name != null) {
        resolver.remember(e.puuid, name);
        continue;
      }
      if (state.containsKey(e.puuid) || _requested.contains(e.puuid)) {
        continue;
      }
      final cached = resolver.peek(e.puuid);
      if (cached != null) {
        found[e.puuid] = cached;
      } else {
        missing.add(e.puuid);
      }
    }
    if (found.isNotEmpty) state = {...state, ...found};
    final viewer = ref.read(activePuuidProvider);
    if (missing.isEmpty || viewer == null) return;
    _requested.addAll(missing);
    try {
      final resolved = await resolver.resolve(viewer, missing);
      if (!ref.mounted || resolved.isEmpty) return;
      state = {...state, ...resolved};
    } on Object {
      // Names stay unknown; rows show "Người chơi" until the next roster.
      _requested.removeAll(missing);
    }
  }
}

/// The friends list (S60): loading until the roster arrives, the
/// connection error when the first connection fails, then data (with the
/// live connection state inside [FriendsView.connection]).
final friendsProvider = Provider.autoDispose<AsyncValue<FriendsView>>((ref) {
  final snapshot = ref.watch(xmppSnapshotProvider);
  final names = ref.watch(friendNamesProvider);
  switch (snapshot) {
    case AsyncData(:final value):
      if (value.rosterLoaded) {
        return AsyncData(buildFriendsView(value, names: names));
      }
      final error = value.connection.error;
      final status = value.connection.status;
      if (status == XmppStatus.needsLogin ||
          (error != null && status != XmppStatus.connecting)) {
        return AsyncError(
          error ?? const NeedsLoginException(reason: 'xmpp'),
          StackTrace.empty,
        );
      }
      return const AsyncLoading();
    case AsyncError(:final error, :final stackTrace):
      return AsyncError(error, stackTrace);
    default:
      return const AsyncLoading();
  }
});

/// Online friends (party invite strip, S3).
final onlineFriendsProvider = Provider.autoDispose<List<Friend>>(
  (ref) => ref.watch(friendsProvider).value?.online ?? const [],
);

/// Total unread messages (badges).
final unreadTotalProvider = Provider.autoDispose<int>(
  (ref) =>
      ref.watch(xmppSnapshotProvider.select((s) => s.value?.totalUnread)) ?? 0,
);

/// The signed-in player's own game-client presence: `.valorant` holds the
/// live score (G7, show only when `hasScore` and fresh, U9), party id and
/// loop state. `null` while the game is not running.
final ownPresenceProvider = StreamProvider.autoDispose<FriendPresence?>((ref) {
  final service = ref.watch(xmppServiceProvider);
  if (service == null) return Stream.value(null);
  return service.ownPresenceChanges;
});

/// Messages with one friend (S61). Watching it marks the conversation as
/// open (incoming messages are read at once) and loads the archive once
/// per connection.
final conversationProvider = StreamProvider.autoDispose
    .family<Conversation, String>((ref, friendPuuid) {
      final service = ref.watch(xmppServiceProvider);
      if (service == null) {
        throw const NeedsLoginException(reason: 'no_account');
      }
      final id = friendPuuid.trim().toLowerCase();
      service.setActiveConversation(id);
      ref.onDispose(() {
        if (service.store.activeConversation == id) {
          service.setActiveConversation(null);
        }
      });
      final conversation = service.store.conversation(id);
      if (!conversation.historyLoaded && !conversation.loadingHistory) {
        unawaited(service.loadHistory(id));
      }
      return service.watchConversation(id);
    });
