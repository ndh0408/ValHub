import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/riot/pvp_api.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/json.dart';
import '../../community_routes.dart';
import '../../community_strings.dart';
import '../../data/lfg_sync.dart';
import '../../providers/community_providers.dart';
import '../../providers/lfg_providers.dart';
import '../community_screen.dart' show CommunitySection;

/// Keeps the poster's LFG post in sync with their Riot party while [child]
/// is on screen: every [kLfgRefreshInterval] it reads the party (G-12 /
/// G-13 / G-1), PATCHes party size / slots / status (and a heartbeat), and
/// notifies "Tên#TAG đã vào tổ đội" for new members. The timer belongs to
/// this widget (cancelled on dispose) and skips ticks while its tab is in
/// the background. It never changes anything on the Riot account.
class LfgPosterSync extends ConsumerStatefulWidget {
  const LfgPosterSync({super.key, required this.account, required this.child});

  final Account account;
  final Widget child;

  @override
  ConsumerState<LfgPosterSync> createState() => _LfgPosterSyncState();
}

class _LfgPosterSyncState extends ConsumerState<LfgPosterSync> {
  Timer? _timer;
  var _visible = true;
  bool _busy = false;
  Set<String>? _known;
  String? _knownFor;

  String get _puuid => widget.account.puuid;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(kLfgRefreshInterval, (_) => unawaited(_tick()));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visible = TickerMode.valuesOf(context).enabled;
  }

  @override
  void didUpdateWidget(LfgPosterSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.account.puuid != widget.account.puuid) {
      _known = null;
      _knownFor = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _tick() async {
    if (!mounted || !_visible || _busy) return;
    final puuid = _puuid;
    final post = ref.read(myLfgProvider(puuid)).value;
    final now = ref.read(clockProvider).now();
    if (post == null || post.isExpired(now)) return;
    _busy = true;
    try {
      final party = await readLfgParty(ref.read(pvpApiProvider), puuid);
      if (!mounted) return;
      ref.read(lfgLivePartyProvider(puuid).notifier).set(party);
      final notifier = ref.read(myLfgProvider(puuid).notifier);
      if (_knownFor != post.id) {
        _known = null;
        _knownFor = post.id;
      }
      final decision = decideLfgSync(
        post: post,
        party: party,
        selfPuuid: puuid,
        now: now,
        knownMembers: _known,
        lastPatchAt: notifier.lastPatchAt,
      );
      if (party != null) _known = party.memberIds;
      if (decision.newMembers.isNotEmpty) {
        unawaited(_notifyJoins(decision.newMembers));
      }
      if (decision.shouldPatch) {
        final updated = await ref
            .read(communityApiProvider)
            .updateLfg(
              puuid,
              post.id,
              partySize: decision.partySize,
              slots: decision.slots,
              status: decision.status ?? post.status,
            );
        if (mounted) notifier.set(updated, patchedAt: now);
      }
    } on Object {
      // Offline / game closed / server hiccup: try again next tick.
    } finally {
      _busy = false;
    }
  }

  Future<void> _notifyJoins(List<String> members) async {
    final puuid = _puuid;
    List<JsonMap> names = const [];
    try {
      names = await ref.read(pvpApiProvider).names(puuid, members);
    } on Object {
      // Fall back to a generic name.
    }
    final service = ref.read(notificationServiceProvider);
    for (final id in members) {
      final entry = names
          .where((n) => lowerUuid(n['Subject']) == id)
          .firstOrNull;
      final game = asNonEmptyString(entry?['GameName']);
      final tag = asNonEmptyString(entry?['TagLine']);
      final name = game == null
          ? CommunityStrings.unknownPlayer
          : (tag == null ? game : CommunityStrings.riotId(game, tag));
      try {
        await service.showNow(
          id: NotificationIds.forKey('lfg-join:$puuid:$id'),
          title: CommunityStrings.memberJoined(name),
          body: CommunityStrings.memberJoinedBody,
          channel: NotificationChannel.account,
          payload:
              '${CommunityRoutes.section(CommunitySection.lfg)}'
              '&account=$puuid',
          accountPuuid: puuid,
        );
      } on Object {
        // Notifications are best effort.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loads the own post (GET /v1/lfg/mine) while the tab is alive.
    ref.watch(myLfgProvider(_puuid));
    return widget.child;
  }
}
