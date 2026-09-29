import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/config/remote_config.dart';
import '../../../core/network/riot_exception.dart';
import '../../../core/riot/pvp_api.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/json.dart';
import '../../../core/xmpp/xmpp_models.dart' show LoopState;
import '../data/party_models.dart';

/// Opens the OS share sheet with [text] (party code). Overridden in tests.
final partyShareProvider = Provider<Future<void> Function(String text)>(
  (ref) => (text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  },
);

/// Party & remote queue of one signed-in account (S55, SUMMARY §6.4):
/// G-12 → G-13 (+ G-1 for the in-match lock). `404` on G-12 means the game
/// is not running ([PartyView.notRunning]).
///
/// Every mutation is a method called from a button (never automated); each
/// applies the party object Riot returns, or refetches.
final partyProvider = AsyncNotifierProvider.autoDispose
    .family<PartyNotifier, PartyView, String>(PartyNotifier.new);

class PartyNotifier extends AsyncNotifier<PartyView> {
  PartyNotifier(this.puuid);

  final String puuid;

  final Set<String> _dismissedInvites = {};

  PvpApi get _api => ref.read(pvpApiProvider);

  @override
  Future<PartyView> build() async {
    ref.watch(accountProvider(puuid).select((a) => a?.needsLogin));
    final api = ref.watch(pvpApiProvider);
    final now = ref.read(clockProvider).now();
    final player = await api.partyPlayer(puuid).orNullIfNotFound();
    if (player == null) return PartyView.notRunning(fetchedAt: now);
    final partyId = lowerUuid(player['CurrentPartyID']);
    final invites = [
      for (final i in asList(player['Invites'])) ?PartyInvite.fromJson(i),
    ].where((i) => !_dismissedInvites.contains(i.partyId)).toList();
    final results = await Future.wait<Object?>([
      if (partyId != null)
        api.party(puuid, partyId).orNullIfNotFound()
      else
        Future<Object?>.value(),
      _loopState(api),
    ]);
    return PartyView(
      gameRunning: true,
      fetchedAt: now,
      party: Party.fromJson(results[0]),
      invites: invites.where((i) => i.partyId != partyId).toList(),
      loopState: results[1] as LoopState? ?? LoopState.unknown,
    );
  }

  /// G-1 loop state; any failure means "unknown" (not an error).
  Future<LoopState> _loopState(PvpApi api) async {
    try {
      final session = await api.gameSession(puuid).orNullIfNotFound();
      return LoopState.parse(asString(session?['loopState']));
    } on RiotException {
      return LoopState.unknown;
    }
  }

  /// Background refresh (polling / pull-to-refresh): keeps the data on
  /// screen while loading.
  Future<void> refresh() async {
    ref.invalidateSelf();
    try {
      await future;
    } on Object {
      // Shown through `state` (the previous data stays visible).
    }
  }

  String _partyId() {
    final id = state.value?.party?.id;
    if (id == null) throw const NotFoundException(errorCode: 'no_party');
    return id;
  }

  Future<void> _apply(Future<JsonMap> call) async {
    final json = await call;
    final party = Party.fromJson(json);
    final current = state.value;
    if (party != null && current != null && ref.mounted) {
      state = AsyncData(current.copyWith(party: party));
    } else if (ref.mounted) {
      await refresh();
    }
  }

  /// G-14 (owner only).
  Future<void> changeQueue(String queueId) =>
      _apply(_api.partyChangeQueue(puuid, _partyId(), queueId));

  /// G-15 join.
  Future<void> startMatchmaking() =>
      _apply(_api.partyJoinMatchmaking(puuid, _partyId()));

  /// G-15 leave.
  Future<void> cancelMatchmaking() =>
      _apply(_api.partyLeaveMatchmaking(puuid, _partyId()));

  /// G-16.
  Future<void> setReady(bool ready) =>
      _apply(_api.partySetReady(puuid, _partyId(), ready: ready));

  /// G-17 by Riot ID.
  Future<void> invite({required String gameName, required String tagLine}) =>
      _apply(
        _api.partyInviteByRiotId(
          puuid,
          _partyId(),
          gameName: gameName,
          tagLine: tagLine,
        ),
      );

  /// G-18 POST.
  Future<void> generateCode() =>
      _apply(_api.partyGenerateInviteCode(puuid, _partyId()));

  /// G-18 DELETE.
  Future<void> disableCode() =>
      _apply(_api.partyDisableInviteCode(puuid, _partyId()));

  /// G-19: joins (and leaves the current party).
  Future<void> joinByCode(String code) async {
    await _api.partyJoinByCode(puuid, code.trim().toUpperCase());
    await refresh();
  }

  /// Whether G-20 may be called (remote flag `party_accept_invite`, U11).
  bool get canAcceptInvites =>
      ref.read(remoteConfigProvider).flag(RemoteFlags.partyAcceptInvite);

  /// G-20 (UNVERIFIED endpoint, behind the flag).
  Future<void> acceptInvite(PartyInvite invite) async {
    await _api.partyAcceptInvite(puuid, invite.partyId);
    await refresh();
  }

  /// Hides an invite on this device (Riot has no decline-invite call; the
  /// invite simply expires).
  void dismissInvite(PartyInvite invite) {
    _dismissedInvites.add(invite.partyId);
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        invites: current.invites
            .where((i) => i.partyId != invite.partyId)
            .toList(),
      ),
    );
  }

  /// G-21: declines a request to join this party.
  Future<void> declineRequest(PartyRequest request) =>
      _apply(_api.partyDeclineRequest(puuid, _partyId(), request.id));

  /// G-22 with another member (owner only).
  Future<void> kick(String memberPuuid) async {
    await _api.partyRemovePlayer(puuid, subject: memberPuuid);
    await refresh();
  }

  /// G-22 with the own PUUID.
  Future<void> leave() async {
    await _api.partyRemovePlayer(puuid);
    await refresh();
  }

  /// G-23.
  Future<void> setOpen(bool open) =>
      _apply(_api.partySetAccessibility(puuid, _partyId(), open: open));
}
