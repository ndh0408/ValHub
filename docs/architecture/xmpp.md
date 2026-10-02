# XMPP chat: `lib/core/xmpp/`

Riot chat (friends, presence, direct messages) for the **social** feature
(S55 invite strip, S60 friends, S61 chat) and the **live game** (own presence →
live score G7). UI-free except for the Riverpod providers.

```dart
import 'package:valvn/core/xmpp/xmpp.dart';   // everything below
```

References: SUMMARY §6.5, §8.7, §9.9, §10, U9, U10, U11; EP §16; VF §6.7.

| File | Contents |
|---|---|
| `xmpp_transport.dart` | `XmppEndpoint`, `XmppSocket` (interface), `XmppConnector` typedef, `SecureSocketConnector` (dart:io TLS `:5223`) |
| `xmpp_stream_parser.dart` | `XmppStreamParser`: incremental package:xml event parser → `XmppStreamOpened` / `XmppStanza` / `XmppStreamClosed` |
| `xmpp_stanzas.dart` | `XmppStanzas`: stream header, SASL, bind, session, entitlements, roster, archive, message, iq result; `escape()` |
| `xmpp_models.dart` | `Jid`, `RosterEntry`, `LoopState`, `PresenceSnapshot`, `PresenceShow`, `FriendPresence`, `ChatMessage`, `Conversation`, `XmppStatus`, `XmppConnectionState` |
| `xmpp_parsers.dart` | pure parsers: `parseRosterItems`, `parsePresence`, `bestPresence`, `presenceSnapshotFromJson`, `decodeValorantPresence`, `parseChatMessage`, `parseArchive`, `parseRiotTimestamp`, `parseQueueEntryTime`, `resolveXmppEndpoint`, `xmlChild*` |
| `xmpp_client.dart` | `XmppClient`: one connection (handshake, iq correlation, keep-alive, ping/roster-push acks); `XmppCredentials`, `XmppAuthException`, `XmppProtocolException`, `xmppError()` |
| `xmpp_store.dart` | `XmppStore` (state + coalesced streams), `XmppSnapshot`, `localMessagePrefix` |
| `xmpp_service.dart` | `XmppService` (lifecycle, reconnect, chat API), `XmppCredentialSource`, `RiotXmppCredentialSource` |
| `friends.dart` | `Friend`, `FriendsView`, `FriendActivity`, `friendActivity()`, `buildFriendsView()`, `foldVietnamese()` |
| `xmpp_providers.dart` | Riverpod providers (below) |

## 1. Connection sequence

`RiotXmppCredentialSource.credentials(puuid)`:
`SessionManager.session(puuid)` (access + entitlements token, refreshed when < 5 min
left) → `PvpApi.chatPasToken` (A-7) → `PvpApi.chatClientConfig` (A-8, cached per
account; a failure falls back to the region table) → `resolveXmppEndpoint`:

- `affinity` claim of the PAS JWT (e.g. `jp1`);
- host `chat.affinities[affinity]`, domain `chat.affinity_domains[affinity]`, port
  `chat.port` (flat `"chat.affinities"` keys or nested `chat.affinities`);
- fallback `ap→jp1, eu→euw1, na→na2, kr→kr1, br→br, latam→la1`
  (`{x}.chat.si.riotgames.com`); hosts are validated (`[a-z0-9.-]`).

`XmppClient.connect(credentials)`:

1. TLS socket (`SecureSocket.connect`, direct TLS, no STARTTLS).
2. `<stream:stream to="{domain}.pvp.net" …>` → wait for `<stream:features>`.
3. `<auth mechanism="X-Riot-RSO-PAS"><rso_token/><pas_token/></auth>` →
   `<success/>` (or `<failure>` → `XmppAuthException`).
4. Stream restart → features → bind (bound JID `{puuid}@{domain}/{resource}`) →
   session → entitlements (`<token xmlns="">`). Session / entitlements errors are
   tolerated.
5. Keep-alive: one space every 120 s.

`XmppService` then queries the roster (`last_state="true"`), attaches the stanza
listener and sends `<presence/>`. Every step has a 15 s timeout.

The parser feeds package:xml only up to the last `>` received, so tags, attribute
values and entities split across TCP chunks are reassembled; the transport decodes
UTF-8 with a chunked decoder. Children of the never-closed `<stream:stream>` root are
emitted one by one; a second `<stream:stream>` (restart) is recognised anywhere;
> 2 M chars without progress is a `FormatException` (→ reconnect).

## 2. Lifecycle and errors

| Situation | Behaviour |
|---|---|
| `start()` | connects unless connected / connecting / a retry is pending |
| socket drop, `<stream:error>`, timeout, network error | `XmppStatus.reconnecting` with the error; retries after 2 s, 5 s, 15 s, 30 s, 60 s, each time with **fresh credentials**; then `failed` until `retryNow()` / `refresh()` / `start()` |
| SASL `<failure>` | `credentials.invalidate(puuid, failedAccessToken:)` → `SessionManager.refreshAfterAuthFailure` (single-flight re-auth) → one more attempt with the new tokens; a second refusal → `failed` with `RiotApiException(401, 'xmpp_not-authorized')` |
| `NeedsLoginException` from the session | `needsLogin`; never retried automatically |
| account `needsLogin` flips to true / back to false | `markNeedsLogin()` / `reconnect()` (via `xmppServiceProvider`) |
| app backgrounded | `stop()`: `</stream:stream>`, socket closed, state `idle`; roster and conversations stay in memory |
| app foregrounded | `start()` (presences are cleared on each new connection; the server resends them) |

Errors are always `RiotException`s (`xmppError()`), so `describeError` /
`ErrorView` / `AsyncValueView` show Vietnamese copy and "Đăng nhập lại" when needed.

**Privacy:** only `xmpp.connect {host}`, `xmpp.connected {host}` and
`xmpp.closed {error kind}` reach `SessionLog`. Tokens, JIDs (they contain PUUIDs)
and message bodies are never logged. Nothing is persisted: roster, presences and
messages live in memory only.

## 3. State: `XmppStore` / `XmppSnapshot`

- `roster`: accepted friends (`subscription` `both`/`to`/`from`/absent) by PUUID;
  roster pushes (`iq set`) upsert / remove (`subscription="remove"` or no longer a
  friend) and are acknowledged.
- `presences`: best available presence per user (Valorant first, then another game,
  then newest), resources tracked separately; `unavailable` removes a resource; when
  the last one goes the roster entry's `lastOnline` becomes "now".
- `ownPresence`: presences of **our own** bare JID from another resource (the game
  client). Our own echo (bound resource) is ignored.
- `unread`: incoming live messages whose conversation is not open
  (`setActiveConversation`); `markRead`.
- conversations (`conversation(puuid)`, `watchConversation`): messages sorted by
  time, merged by id; a message sent from the app (`valvn-…` id) is replaced by its
  archived copy (same body within 5 min).

Streams (`XmppService` delegates to the store): `snapshots`, `connectionStates`,
`rosterChanges`, `presenceChanges`, `ownPresenceChanges` start with the current
value; `messages` emits every new live / sent message. Changes are coalesced per
microtask (one snapshot per socket chunk), and unchanged parts keep their identity
(`select` on `roster` does not fire on presence changes).

## 4. Presence

`<presence from='{puuid}@{domain}/{resource}'><games><valorant><st/><s.t/><s.r/><p>{base64}</p></valorant></games><show/><status/></presence>`

`decodeValorantPresence` accepts padded / unpadded / URL-safe base64 and plain JSON.
`presenceSnapshotFromJson` reads the nested 2024+ format and falls back to the old
flat keys **field by field**:

| `PresenceSnapshot` | nested | flat fallback |
|---|---|---|
| `loopState` | `matchPresenceData.sessionLoopState` | `sessionLoopState`, `partyOwnerSessionLoopState` |
| `matchMap` | `matchPresenceData.matchMap` | `matchMap`, `partyOwnerMatchMap` |
| `queueId`, `provisioningFlow` | `matchPresenceData.*` | top level |
| `partyId`, `partyState`, `partySize`, `maxPartySize`, `queueEntryTime` (`2026.04.23-22.40.57` UTC), `isPartyOwner`, `partyAccessibility`, `customGameName` | `partyPresenceData.*` | top level |
| `allyScore` / `enemyScore` | `partyPresenceData.partyOwnerMatchScore{Ally,Enemy}Team` | top level (U9) |
| `playerCardId`, `playerTitleId`, `accountLevel`, `competitiveTier`, `leaderboardPosition` | `playerPresenceData.*` | top level |

`hasScore` is false outside a match and for `0 – 0` (U9). Consumers of the live score
should also hide it when the presence is older than 2 min
(`FriendPresence.timestamp ?? receivedAt`) and honour the `live_score` flag.

`friendActivity(presence)` (SUMMARY §9.9): INGAME → `inMatch` (shooting range
separately), PREGAME → `agentSelect`, then `<show>away` / `isIdle` → `away`,
`partyState == MATCHMAKING` → `inQueue`, MENUS → `inLobby`; non-Valorant games →
`otherGame`; Riot Client only → `online`; no presence → `offline`. Status data
remains in `lib/features/social/data/friend_status.dart`; rendered copy receives
`AppLocalizations` and `AppFormats` in `lib/features/social/ui/friend_status_labels.dart`.

`PartyScreen` keys its internal action state by the active account. Switching
accounts disposes the previous code field, busy actions and invite ticks; an old
join completion cannot clear the next account's input or show its success there.
`PartyNotifier.refresh` and response application check `ref.mounted` before
accessing disposed provider state. Account-specific Riot requests and server
ownership checks retain their existing behavior.

## 5. Roster and chat stanzas

- Roster item: `<item jid puuid subscription><state/><last_online>2025-03-11
  22:00:04.505</last_online><id name tagline/><platforms><riot name tagline/></platforms></item>`.
  Names come from `<id>`, then `<platforms><riot>`, then item attributes; missing
  names are resolved by `friendNamesProvider` through the batched name-service and
  roster names are fed to `NameResolver.remember`.
- Timestamps (`parseRiotTimestamp`): Riot `yyyy-MM-dd HH:mm:ss.SSS` and offset-less
  ISO are UTC; epoch s / ms accepted.
- Message: `<message id to="{puuid}@{domain}.pvp.net" type="chat"><body/></message>`.
  Incoming: `stamp` attribute, else `<delay stamp>`, else receive time. Group chat,
  errors and empty bodies are ignored.
- Archive: `<iq type="get"><query xmlns="jabber:iq:riotgames:archive"><with>{bare
  jid}</with></query></iq>` → every `<message>` in the result.

## 6. Providers (`xmpp_providers.dart`)

| Provider | Type | Notes |
|---|---|---|
| `xmppServiceProvider` | `Provider.autoDispose<XmppService?>` | active account (`null` without one); connects while the app is in the foreground **and** something watches it; lingers `kXmppLinger` (3 min) after the last listener; follows `needsLogin` |
| `xmppSnapshotProvider` | `StreamProvider.autoDispose<XmppSnapshot>` | error `NeedsLoginException('no_account')` without an account |
| `xmppConnectionProvider` | `Provider.autoDispose<XmppConnectionState>` | banners / disabling the chat input |
| `friendsProvider` | `Provider.autoDispose<AsyncValue<FriendsView>>` | loading until the roster arrives; the connection error (or needs-login) when the first connection fails; then data with `FriendsView.connection` |
| `friendNamesProvider` | `NotifierProvider.autoDispose<…, Map<String, RiotName>>` | name-service fallback for roster entries without names |
| `onlineFriendsProvider` | `Provider.autoDispose<List<Friend>>` | party invite strip |
| `unreadTotalProvider` | `Provider.autoDispose<int>` | badges |
| `ownPresenceProvider` | `StreamProvider.autoDispose<FriendPresence?>` | own game-client presence (`.valorant`: live score, party id, loop state) |
| `conversationProvider(friendPuuid)` | `StreamProvider.autoDispose.family<Conversation, String>` | marks the conversation open (read) while watched; loads the archive once per connection |
| `appForegroundProvider` | `NotifierProvider<AppForegroundNotifier, bool>` | `AppLifecycleListener`; resumed / inactive = foreground |
| `xmppConnectorProvider`, `xmppCredentialSourceProvider` | `Provider` | test seams |

```dart
// Friends list
AsyncValueView(
  value: ref.watch(friendsProvider),
  onRetry: () => ref.read(xmppServiceProvider)?.retryNow(),
  data: (view) => …view.online / view.offline…,
);
// pull-to-refresh
onRefresh: () async => ref.read(xmppServiceProvider)?.refresh();

// Chat
final conv = ref.watch(conversationProvider(friendPuuid));
await ref.read(xmppServiceProvider)!.sendMessage(friendPuuid, text); // user action

// Live score (live_game)
final own = ref.watch(ownPresenceProvider).value?.valorant;
if (own != null && own.hasScore) Text('${own.allyScore} – ${own.enemyScore}');
```

## 7. Tests

`test/core/xmpp/`: `fake_xmpp_server.dart` (scripted server behind a fake socket,
optional random chunking, `FakeCredentials`), parser tests (every split position,
one character at a time, restart, garbage), parsers, store, service (handshake,
SASL retry, needs-login, drops, backoff, keep-alive, roster push, stream error) and
providers (foreground / background, needs-login, names, conversation, own presence).
Widget tests override `xmppServiceProvider` with an `XmppService` subclass whose
`start` / `stop` / `sendMessage` / `loadHistory` touch only the store
(`test/features/social/social_test_env.dart`).
