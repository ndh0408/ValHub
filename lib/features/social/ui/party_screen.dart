import 'package:valvn/core/l10n/labels/content_labels.dart';

import 'dart:async';

import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, FilteringTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/xmpp/friends.dart';
import '../../../core/xmpp/xmpp_models.dart' show LoopState;
import '../../../core/xmpp/xmpp_providers.dart';
import '../../live_game/current_game_card.dart';
import '../../live_game/live_game_sheet.dart';
import '../../live_game/data/live_game_models.dart';
import '../../live_game/providers/live_game_providers.dart';
import '../../profile/profile_routes.dart';
import '../../profile/ui/widgets/profile_widgets.dart' show outcomeColor;
import '../data/party_models.dart';
import '../data/riot_id_input.dart';
import '../providers/party_providers.dart';
import 'widgets/party_widgets.dart';
import 'widgets/social_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/l10n/labels/competitive_labels.dart';

/// S55 "Tổ đội & hàng chờ". Route `/profile/party`.
///
/// Remote party control while VALORANT runs on PC / console (GLZ
/// G-12…G-24): a status card (queue, matchmaking timer, why the party cannot
/// queue), the queue picker sheet, members (rank, RR, level, ping, ready,
/// leader, remove), invites (online friends in one tap, any Riot ID), the
/// party code, joining by code and incoming invites; start / cancel
/// matchmaking and ready sit in the bottom bar. Polls every [pollInterval]
/// (ring in the bar). Every change is a user action; removing / leaving /
/// switching party asks first.
class PartyScreen extends ConsumerWidget {
  const PartyScreen({
    super.key,
    this.pollInterval = const Duration(seconds: 5),
    this.includeCurrentGame = false,
  });

  final Duration pollInterval;

  /// Combined entry at the existing party route. Standalone party consumers
  /// retain their presentation and mutation behavior.
  final bool includeCurrentGame;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puuid = ref.watch(activePuuidProvider);
    if (includeCurrentGame && puuid != null) {
      final live = ref.watch(liveGameProvider(puuid)).value;
      // A match takes priority over party reads, including when the party
      // endpoint fails. Back in the lobby the party comes first again (ready,
      // queue, invites); the match just played is one row on top of it.
      if (live?.phase.inMatch ?? false) {
        return LiveGamePage(
          key: ValueKey(puuid),
          onOpenParty: () => unawaited(
            Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => PartyScreen(pollInterval: pollInterval),
              ),
            ),
          ),
        );
      }
    }
    return _PartyAccountScreen(
      key: ValueKey(puuid),
      pollInterval: pollInterval,
      includeCurrentGame: includeCurrentGame,
    );
  }
}

/// Pending actions, invite ticks and the code field belong to one account.
/// Switching accounts disposes that state before displaying the next party.
class _PartyAccountScreen extends ConsumerStatefulWidget {
  const _PartyAccountScreen({
    super.key,
    required this.pollInterval,
    required this.includeCurrentGame,
  });

  final Duration pollInterval;
  final bool includeCurrentGame;

  @override
  ConsumerState<_PartyAccountScreen> createState() => _PartyScreenState();
}

class _PartyScreenState extends ConsumerState<_PartyAccountScreen> {
  final _code = TextEditingController();
  final Set<String> _busy = {};
  final Set<String> _invited = {};
  LivePartyPollCoverNotifier? _cover;

  static final _codePattern = RegExp(r'^[A-Za-z0-9]{3,16}$');

  @override
  void initState() {
    super.initState();
    // This screen polls the session and party every few seconds: the live
    // game slows its own copy of those calls down meanwhile.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cover = ref.read(livePartyPollCoverProvider.notifier);
      cover.open();
      _cover = cover;
    });
  }

  @override
  void dispose() {
    final cover = _cover;
    if (cover != null) {
      // Avoid a provider mutation while the route is being torn down.
      scheduleMicrotask(() {
        try {
          cover.close();
        } on StateError {
          /* Provider scope disposed. */
        }
      });
    }
    _code.dispose();
    super.dispose();
  }

  PartyNotifier _notifier(String puuid) =>
      ref.read(partyProvider(puuid).notifier);

  /// Runs a user-initiated action once at a time per [key], with a
  /// snackbar for the outcome.
  Future<void> _run(
    String key,
    Future<void> Function() action, {
    String? success,
  }) async {
    if (!mounted) return;
    final l10n = context.l10n;
    if (_busy.contains(key)) return;
    setState(() => _busy.add(key));
    try {
      await action();
      if (success != null && mounted) showAppSnackBar(context, success);
    } on Object catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          l10n.socialActionFailed(describeError(l10n, e).message),
        );
      }
    } finally {
      if (mounted) setState(() => _busy.remove(key));
    }
  }

  bool _isBusy(String key) => _busy.contains(key);

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return SubPageScaffold(
        title: widget.includeCurrentGame
            ? context.l10n.profilePlayHubTitle
            : context.l10n.socialPartyTitle,
        body: EmptyView(message: context.l10n.commonErrorNoAccount),
      );
    }
    final puuid = account.puuid;
    final provider = partyProvider(puuid);
    // A match starting is seen here first: hand it to the live game, which
    // switches the combined page to the match.
    ref.listen(provider.select((v) => v.value?.inMatch), (was, inMatch) {
      if (inMatch == true && was != true && widget.includeCurrentGame) {
        unawaited(ref.read(liveGameProvider(puuid).notifier).refresh());
      }
    });
    final value = ref.watch(provider);
    final view = value.value;
    final party = view?.party;

    final List<Widget> slivers;
    if (view != null) {
      slivers = [
        if (value.hasError && !value.isLoading)
          SliverToBoxAdapter(
            child: ErrorView(
              error: value.error!,
              puuid: puuid,
              compact: true,
              onRetry: () => unawaited(_notifier(puuid).refresh()),
            ),
          ),
        if (view.gameRunning)
          SliverList.list(children: _content(view, puuid))
        else
          SliverFillRemaining(
            hasScrollBody: false,
            child: _GameNotRunning(onRetry: () => _notifier(puuid).refresh()),
          ),
      ];
    } else if (value.hasError && !value.isLoading) {
      slivers = [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorView(
            error: value.error!,
            puuid: puuid,
            onRetry: () => ref.invalidate(provider),
          ),
        ),
      ];
    } else {
      slivers = const [SliverToBoxAdapter(child: _PartySkeleton())];
    }

    return SubPageScaffold(
      title: widget.includeCurrentGame
          ? context.l10n.profilePlayHubTitle
          : context.l10n.socialPartyTitle,
      subtitle: party == null || !(view?.gameRunning ?? false)
          ? null
          : context.l10n.socialPartySummary(
              party.size,
              5,
              party.isOpen ? 'open' : 'closed',
            ),
      actions: [
        RefreshRing(
          period: widget.pollInterval,
          tooltip: context.l10n.socialAutoRefresh,
          onCycle: () => _notifier(puuid).refresh(),
        ),
        if (party != null && view!.gameRunning)
          _MoreMenu(
            party: party,
            isOwner: party.isOwner(puuid),
            onLeave: () => _leave(puuid, party),
            onToggleOpen: () =>
                _run('open', () => _notifier(puuid).setOpen(!party.isOpen)),
          ),
      ],
      onRefresh: () async {
        await Future.wait([
          _notifier(puuid).refresh(),
          if (widget.includeCurrentGame)
            ref.read(liveGameProvider(puuid).notifier).refresh(),
        ]);
      },
      slivers: [
        if (widget.includeCurrentGame)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: _LastMatchOrStatus(puuid: puuid),
            ),
          ),
        ...slivers,
      ],
      bottomBar:
          party != null &&
              view!.gameRunning &&
              !view.inMatch &&
              !party.isMatchFound
          ? _queueActions(view, party, puuid)
          : null,
    );
  }

  List<Widget> _content(PartyView v, String me) {
    final p = v.party;
    return [
      if (v.gameRunning && !v.inMatch && v.loopState == LoopState.unknown)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: _Banner(
            icon: Icons.sync_problem_outlined,
            text: context.l10n.socialQueueStatusUnavailable,
            color: valColorsOf(context).warning,
          ),
        ),
      if (v.inMatch)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: _Banner(
            icon: Icons.sports_esports_outlined,
            text: context.l10n.socialInMatchBanner,
            color: valColorsOf(context).warning,
          ),
        ),
      if (v.invites.isNotEmpty) ...[
        SectionLabel(context.l10n.socialInvitesSection),
        GroupedSection(
          children: [
            for (final invite in v.invites)
              _InviteRow(
                invite: invite,
                busy: _isBusy('accept-${invite.partyId}'),
                onAccept: () => _accept(me, invite, p),
                onDecline: () => _notifier(me).dismissInvite(invite),
              ),
          ],
        ),
      ],
      if (p != null) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: _statusCard(v, p, me),
        ),
        SectionLabel(context.l10n.socialMembersSection(p.size, 5)),
        GroupedSection(
          children: [
            for (final m in _ordered(p.members, me))
              PartyMemberTile(
                key: ValueKey(m.puuid),
                member: m,
                isSelf: m.puuid == me,
                onRemove: p.isOwner(me) && m.puuid != me && !v.inMatch
                    ? () => _kick(me, m)
                    : null,
              ),
          ],
        ),
        if (p.isOwner(me) && p.requests.isNotEmpty) ...[
          SectionLabel(context.l10n.socialRequestsSection),
          GroupedSection(
            children: [
              for (final r in p.requests)
                _RequestRow(
                  request: r,
                  busy: _isBusy('decline-${r.id}'),
                  onDecline: () => _run(
                    'decline-${r.id}',
                    () => _notifier(me).declineRequest(r),
                  ),
                ),
            ],
          ),
        ],
        SectionLabel(context.l10n.socialInviteFriends),
        _inviteSection(v, p, me),
        SectionLabel(context.l10n.socialPartyCode),
        _codeSection(p, me),
      ] else ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: _Banner(
            icon: Icons.group_off_outlined,
            text: context.l10n.socialPartyUnavailable,
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => unawaited(_notifier(me).refresh()),
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.commonRetry),
          ),
        ),
      ],
      SectionLabel(context.l10n.socialJoinSection),
      _joinSection(p, me),
      const _RemoteNote(),
    ];
  }

  /// Leader first, then the viewer, then everyone else in Riot's order.
  static List<PartyMember> _ordered(List<PartyMember> members, String me) => [
    ...members.where((m) => m.isOwner),
    ...members.where((m) => !m.isOwner && m.puuid == me),
    ...members.where((m) => !m.isOwner && m.puuid != me),
  ];

  // ---------------------------------------------------------- status card

  Widget _statusCard(PartyView v, Party p, String me) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final isOwner = p.isOwner(me);
    final canChange =
        isOwner &&
        v.canManageQueue &&
        !p.isMatchmaking &&
        !p.isCustomGame &&
        !_isBusy('queue');
    final choice = queueChoices(p)
        .where((c) => c.queueId == p.queueId)
        .firstOrNull;
    final accent = p.isMatchFound
        ? colors.win
        : p.isMatchmaking
        ? colors.warning
        : theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;

    final queueRow = Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(ValRadius.small),
          ),
          child: Icon(
            p.isMatchmaking ? Icons.radar : Icons.sports_esports_outlined,
            color: legibleAccent(context, accent, min: 3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.socialQueueLabel.toUpperCase(),
                style: ValText.label.copyWith(color: muted, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                p.queueId == null
                    ? context.l10n.socialQueueLabel
                    : db.queueName(context.l10n, p.queueId),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ValText.sectionTitle.copyWith(
                  fontSize: 20,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (canChange) ...[
          const SizedBox(width: 8),
          Icon(Icons.unfold_more_rounded, color: muted),
        ],
      ],
    );

    return ValCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      gradient: LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: [
          accent.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.20 : 0.10,
          ),
          accent.withValues(alpha: 0),
        ],
      ),
      borderColor: accent.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(
                label: p.isMatchFound
                    ? context.l10n.socialMatchFound
                    : p.isMatchmaking
                    ? context.l10n.socialPresenceQueue
                    : context.l10n.socialIdleQueue,
                color: accent,
              ),
              Text(
                context.l10n.socialReadyCount(
                  p.members.where((m) => m.isReady || m.isOwner).length,
                  p.size,
                ),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (canChange)
            Tooltip(
              message: context.l10n.socialChangeQueue,
              child: InkWell(
                borderRadius: BorderRadius.circular(ValRadius.small),
                onTap: () => unawaited(_pickQueue(me, p)),
                child: queueRow,
              ),
            )
          else
            queueRow,
          // The pill says searching / found; the cancel button carries the
          // timer. No third copy of the same state here.
          if (p.isCustomGame || choice != null && !choice.eligible)
            const SizedBox(height: 8),
          if (p.isCustomGame)
            PartyNotice(
              icon: Icons.tune,
              text: context.l10n.socialCustomGameLobby,
            ),
          if (choice != null && !choice.eligible)
            PartyNotice(
              icon: Icons.block,
              color: theme.colorScheme.error,
              text: context.l10n.socialCantQueue(
                db.queueName(context.l10n, choice.queueId),
                queueBlockReason(context.l10n, choice, p),
              ),
            ),
          if (v.inMatch)
            PartyNotice(
              icon: Icons.lock_outline,
              text: context.l10n.socialQueueLocked,
            )
          else if (!isOwner)
            PartyNotice(
              icon: Icons.info_outline,
              text: context.l10n.socialOnlyLeader,
            ),
        ],
      ),
    );
  }

  Future<void> _pickQueue(String me, Party p) async {
    final picked = await showQueuePickerSheet(context, p);
    if (picked == null || picked == p.queueId || !mounted) return;
    await _run('queue', () => _notifier(me).changeQueue(picked));
  }

  /// Bottom bar: ready toggle + start / cancel matchmaking.
  Widget _queueActions(PartyView v, Party p, String me) {
    final isOwner = p.isOwner(me);
    final choice = queueChoices(p)
        .where((c) => c.queueId == p.queueId)
        .firstOrNull;
    final blocked = choice != null && !choice.eligible;
    final canStart =
        isOwner &&
        v.canManageQueue &&
        !p.isMatchFound &&
        !p.isCustomGame &&
        !blocked &&
        p.queueId != null;
    final self = p.member(me);
    final ready = self?.isReady ?? false;
    final since = p.queueEntryTime;

    final Widget primary;
    if (p.isMatchmaking) {
      primary = FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: valColorsOf(context).warning,
          foregroundColor: readableOn(valColorsOf(context).warning),
        ),
        onPressed: !v.canManageQueue || _isBusy('mm')
            ? null
            : () {
                Haptics.medium();
                unawaited(_run('mm', () => _notifier(me).cancelMatchmaking()));
              },
        icon: const Icon(Icons.close_rounded),
        label: since == null
            ? Text(context.l10n.socialCancelQueueShort)
            : ElapsedText(
                since: since,
                builder: context.l10n.socialCancelQueue,
              ),
      );
    } else {
      primary = FilledButton.icon(
        onPressed: canStart && !_isBusy('mm')
            ? () {
                Haptics.medium();
                unawaited(_run('mm', () => _notifier(me).startMatchmaking()));
              }
            : null,
        icon: _isBusy('mm')
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              )
            : const Icon(Icons.play_arrow_rounded),
        label: Text(context.l10n.socialStartQueue),
      );
    }
    final readyButton = OutlinedButton.icon(
      onPressed:
          !v.canManageQueue ||
              self == null ||
              _isBusy('ready') ||
              p.isMatchmaking
          ? null
          : () {
              Haptics.light();
              unawaited(_run('ready', () => _notifier(me).setReady(!ready)));
            },
      icon: Icon(ready ? Icons.remove_done : Icons.done_all),
      label: Text(
        ready ? context.l10n.socialUnready : context.l10n.socialReady,
      ),
    );
    // The leader counts as ready (Riot ignores their flag): only the
    // others get the button.
    if (isOwner) return primary;
    return Row(
      children: [
        Expanded(flex: 2, child: readyButton),
        const SizedBox(width: 10),
        Expanded(flex: 3, child: primary),
      ],
    );
  }

  // --------------------------------------------------------------- invites

  Widget _inviteSection(PartyView v, Party p, String me) {
    final friends = ref.watch(friendsProvider);
    final online = (friends.value?.online ?? const <Friend>[])
        .where((f) => f.valorant != null)
        .toList();
    final Widget strip;
    if (friends.hasValue && online.isNotEmpty) {
      strip = InviteStrip(
        friends: online,
        enabled: !v.inMatch,
        isTicked: (f) =>
            p.member(f.puuid) != null ||
            p.invitedPuuids.contains(f.puuid) ||
            _invited.contains('${p.id}/${f.puuid}'),
        onInvite: (f) => _invite(me, p, f),
      );
    } else if (friends.hasValue) {
      strip = Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: PartyNotice(
          icon: Icons.person_search_outlined,
          text: context.l10n.socialNoOnlineFriends,
        ),
      );
    } else if (friends.hasError) {
      strip = Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: PartyNotice(
          icon: Icons.cloud_off_outlined,
          text: context.l10n.socialChatUnavailable,
        ),
      );
    } else {
      strip = const SkeletonShimmer(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            children: [
              Skeleton(width: 50, height: 50, radius: 25, shimmer: false),
              SizedBox(width: 18),
              Skeleton(width: 50, height: 50, radius: 25, shimmer: false),
              SizedBox(width: 18),
              Skeleton(width: 50, height: 50, radius: 25, shimmer: false),
            ],
          ),
        ),
      );
    }
    return GroupedSection(
      children: [
        strip,
        GroupedRow(
          icon: Icons.person_add_alt_1_outlined,
          title: context.l10n.socialInviteByRiotId,
          subtitle: context.l10n.socialInviteByRiotIdHint,
          onTap: v.inMatch ? null : () => unawaited(_inviteByRiotId(me, p)),
        ),
      ],
    );
  }

  void _invite(String me, Party p, Friend f) {
    final name = f.name;
    if (name == null || name.tagLine.isEmpty) {
      showAppSnackBar(context, context.l10n.socialInviteNeedsName);
      return;
    }
    unawaited(
      _run('invite-${f.puuid}', () async {
        await _notifier(me)
            .invite(gameName: name.gameName, tagLine: name.tagLine);
        if (mounted) setState(() => _invited.add('${p.id}/${f.puuid}'));
      }, success: context.l10n.socialInviteSent(name.riotId)),
    );
  }

  Future<void> _inviteByRiotId(String me, Party p) async {
    if (!mounted) return;
    final l10n = context.l10n;
    final name = await showValSheet<RiotName>(
      context,
      title: l10n.socialInviteByRiotId,
      subtitle: l10n.socialInviteByRiotIdHint,
      builder: (context, _) => const _RiotIdForm(),
    );
    if (name == null || !mounted) return;
    await _run(
      'invite-id',
      () =>
          _notifier(me).invite(gameName: name.gameName, tagLine: name.tagLine),
      success: l10n.socialInviteSent(name.riotId),
    );
  }

  Future<void> _accept(String me, PartyInvite invite, Party? current) async {
    if (!mounted) return;
    final l10n = context.l10n;
    final notifier = _notifier(me);
    if (!notifier.canAcceptInvites) {
      showAppSnackBar(context, l10n.socialAcceptInGame);
      return;
    }
    // Like joining by code: accepting leaves a party with other people.
    if (current != null && current.size > 1) {
      final ok = await confirmAction(
        context,
        title: l10n.socialJoinConfirmTitle,
        body: l10n.socialAcceptConfirmBody,
        confirmLabel: l10n.socialAccept,
        destructive: false,
      );
      if (!ok || !mounted) return;
    }
    await _run(
      'accept-${invite.partyId}',
      () => notifier.acceptInvite(invite),
      success: l10n.socialJoined,
    );
  }

  // ------------------------------------------------------------ code / join

  Widget _codeSection(Party p, String me) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final code = p.inviteCode;
    final isOwner = p.isOwner(me);
    final muted = theme.colorScheme.onSurfaceVariant;
    final Widget content;
    if (code != null) {
      content = Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              label: l10n.socialPartyCodeValue(code),
              excludeSemantics: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: valColorsOf(context).surface2,
                  borderRadius: BorderRadius.circular(ValRadius.small),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: SelectableText(
                      code,
                      style: ValText.display(
                        30,
                        color: theme.colorScheme.onSurface,
                      ).copyWith(letterSpacing: 6),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.tonalIcon(
                  style: tonalButtonStyle(context),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    Haptics.light();
                    if (mounted) {
                      showAppSnackBar(context, l10n.commonCopied);
                    }
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(l10n.socialCopyCode),
                ),
                FilledButton.tonalIcon(
                  style: tonalButtonStyle(context),
                  onPressed: () => unawaited(
                    ref.read(partyShareProvider)(
                      l10n.socialShareCodeText(code),
                    ),
                  ),
                  icon: Icon(Icons.adaptive.share, size: 18),
                  label: Text(l10n.socialShareCode),
                ),
                if (isOwner)
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    onPressed: _isBusy('code')
                        ? null
                        : () => _run('code', () => _notifier(me).disableCode()),
                    child: Text(l10n.socialDisableCode),
                  ),
              ],
            ),
          ],
        ),
      );
    } else {
      content = Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
        child: Row(
          children: [
            Icon(Icons.qr_code_2_rounded, color: muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isOwner ? l10n.socialNoCode : l10n.socialNoCodeMember,
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
            ),
            if (isOwner) ...[
              const SizedBox(width: 8),
              FilledButton.tonal(
                style: tonalButtonStyle(context),
                onPressed: _isBusy('code')
                    ? null
                    : () => _run('code', () => _notifier(me).generateCode()),
                child: Text(l10n.socialGenerateCode),
              ),
            ],
          ],
        ),
      );
    }
    return GroupedSection(children: [content]);
  }

  Widget _joinSection(Party? p, String me) {
    final l10n = context.l10n;
    return GroupedSection(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _code,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 16,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  ],
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => unawaited(_join(me, p)),
                  decoration: InputDecoration(
                    hintText: l10n.socialJoinWithCode,
                    counterText: '',
                    isDense: true,
                    prefixIcon: const Icon(Icons.tag_rounded, size: 20),
                    fillColor: valColorsOf(context).surface2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _isBusy('join')
                    ? null
                    : () => unawaited(_join(me, p)),
                child: Text(l10n.socialJoin),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _join(String me, Party? p) async {
    if (!mounted) return;
    final l10n = context.l10n;
    final code = _code.text.trim();
    if (!_codePattern.hasMatch(code)) {
      showAppSnackBar(context, l10n.socialCodeInvalid);
      return;
    }
    if (p != null && p.size > 1) {
      final ok = await confirmAction(
        context,
        title: l10n.socialJoinConfirmTitle,
        body: l10n.socialJoinConfirmBody,
        confirmLabel: l10n.socialJoin,
        destructive: false,
      );
      if (!ok || !mounted) return;
    }
    await _run('join', () async {
      await _notifier(me).joinByCode(code);
      if (mounted) _code.clear();
    }, success: l10n.socialJoined);
  }

  // ------------------------------------------------------ remove / leave

  Future<bool> _kick(String me, PartyMember m) async {
    if (!mounted) return false;
    final l10n = context.l10n;
    final name =
        ref.read(playerNameProvider(m.puuid)).value?.riotId ??
        l10n.competitiveUnknownPlayer;
    final ok = await confirmAction(
      context,
      title: l10n.socialRemoveConfirmTitle,
      body: l10n.socialRemoveConfirmBody(name),
      confirmLabel: l10n.socialRemoveMember,
    );
    if (ok && mounted) {
      unawaited(_run('kick-${m.puuid}', () => _notifier(me).kick(m.puuid)));
    }
    // The row disappears with the next party refresh, not by the swipe.
    return false;
  }

  Future<void> _leave(String me, Party p) async {
    if (!mounted) return;
    final l10n = context.l10n;
    final ok = await confirmAction(
      context,
      title: l10n.socialLeaveConfirmTitle,
      body: l10n.socialLeaveConfirmBody,
      confirmLabel: l10n.socialLeaveParty,
    );
    if (ok && mounted) await _run('leave', () => _notifier(me).leave());
  }
}

/// Riot ID field of the "Mời bằng Riot ID" sheet; pops the parsed name.
class _RiotIdForm extends StatefulWidget {
  const _RiotIdForm();

  @override
  State<_RiotIdForm> createState() => _RiotIdFormState();
}

class _RiotIdFormState extends State<_RiotIdForm> {
  final _field = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _submit() {
    final name = parseRiotIdInput(_field.text);
    if (name == null) {
      setState(() => _error = context.l10n.socialRiotIdInvalid);
      return;
    }
    Haptics.light();
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _field,
            autofocus: true,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _submit(),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            decoration: InputDecoration(
              hintText: context.l10n.socialRiotIdFieldHint,
              prefixIcon: const Icon(Icons.person_search_outlined),
              errorText: _error,
              errorMaxLines: 3,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.send_rounded, size: 18),
            label: Text(context.l10n.socialSendInvite),
          ),
        ],
      ),
    );
  }
}

class _MoreMenu extends StatelessWidget {
  const _MoreMenu({
    required this.party,
    required this.isOwner,
    required this.onLeave,
    required this.onToggleOpen,
  });

  final Party party;
  final bool isOwner;
  final Future<void> Function() onLeave;
  final Future<void> Function() onToggleOpen;

  @override
  Widget build(BuildContext context) {
    final canLeave = party.size > 1;
    if (!canLeave && !isOwner) return const SizedBox.shrink();
    final l10n = context.l10n;
    return IconButton(
      tooltip: l10n.socialMoreActions,
      icon: Icon(Icons.adaptive.more),
      onPressed: () async {
        final v = await showActionSheet<String>(
          context,
          actions: [
            if (isOwner)
              SheetAction(
                value: 'open',
                label: party.isOpen
                    ? l10n.socialCloseParty
                    : l10n.socialOpenParty,
                icon: party.isOpen
                    ? Icons.lock_outline
                    : Icons.lock_open_outlined,
              ),
            if (canLeave)
              SheetAction(
                value: 'leave',
                label: l10n.socialLeaveParty,
                icon: Icons.logout,
                destructive: true,
              ),
          ],
        );
        if (v == 'leave') unawaited(onLeave());
        if (v == 'open') unawaited(onToggleOpen());
      },
    );
  }
}

/// Tinted rounded notice (in a match, no party).
class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = color ?? theme.colorScheme.onSurfaceVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ValRadius.small),
        border: Border.all(color: tint.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: PartyNotice(icon: icon, text: text, color: color),
      ),
    );
  }
}

class _InviteRow extends ConsumerWidget {
  const _InviteRow({
    required this.invite,
    required this.busy,
    required this.onAccept,
    required this.onDecline,
  });

  final PartyInvite invite;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final from = invite.invitedBy;
    final name = from == null
        ? null
        : ref.watch(playerNameProvider(from)).value;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mail_outline_rounded,
                  size: 20,
                  color: legibleAccent(context, theme.colorScheme.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name == null
                      ? context.l10n.socialPartyInvite
                      : context.l10n.socialInviteFrom(name.riotId),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: busy ? null : onDecline,
                  child: Text(context.l10n.socialDecline),
                ),
                FilledButton(
                  onPressed: busy ? null : onAccept,
                  child: Text(context.l10n.socialAccept),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestRow extends ConsumerWidget {
  const _RequestRow({
    required this.request,
    required this.busy,
    required this.onDecline,
  });

  final PartyRequest request;
  final bool busy;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final by = request.requestedBy;
    final name = by == null ? null : ref.watch(playerNameProvider(by)).value;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 8),
      child: Row(
        children: [
          Icon(
            Icons.person_add_alt_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.socialRequestFrom(
                name?.riotId ?? context.l10n.competitiveUnknownPlayer,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: busy ? null : onDecline,
            child: Text(context.l10n.socialDecline),
          ),
        ],
      ),
    );
  }
}

/// Top of the combined page in the lobby: the match just played ("Trận vừa
/// rồi · Thắng · 13 – 9 · Ascent ›", opens its details) while Riot still
/// reports it, else the live status card.
class _LastMatchOrStatus extends ConsumerWidget {
  const _LastMatchOrStatus({required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(liveGameProvider(puuid)).value;
    final ended = live?.ended;
    if (ended == null || live?.phase == LivePhase.queueing) {
      return const CurrentGameCard(matchOnly: true);
    }
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final summary = ref
        .watch(matchSummaryProvider((matchId: ended.matchId, puuid: puuid)))
        .value;
    final result = summary?.result;
    final map = db.mapByUrl(summary?.info.mapId ?? ended.mapId)?.displayName;
    final facts = context.fmt.inlineFacts([
      if (result != null && result.outcome != MatchOutcome.unknown)
        context.l10n.matchOutcome(result.outcome),
      if (result != null && result.hasScore)
        context.l10n.profileScore(result.myScore!, result.otherScore!),
      ?map,
    ]);
    return ValCard(
      padding: EdgeInsets.zero,
      onTap: () => unawaited(context.push(ProfileRoutes.match(ended.matchId))),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 12),
        child: Row(
          children: [
            Icon(
              Icons.flag_outlined,
              color: result == null
                  ? muted
                  : legibleAccent(
                      context,
                      outcomeColor(context, result.outcome),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.liveGameLastMatchTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (facts.isNotEmpty)
                    Text(
                      facts,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: muted),
          ],
        ),
      ),
    );
  }
}

class _RemoteNote extends StatelessWidget {
  const _RemoteNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, size: 16, color: muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.socialRemoteNote,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameNotRunning extends StatelessWidget {
  const _GameNotRunning({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyView(
      icon: Icons.desktop_windows_outlined,
      title: context.l10n.socialGameNotRunningTitle,
      message: context.l10n.socialGameNotRunningBody,
      action: OutlinedButton.icon(
        onPressed: () => unawaited(onRetry()),
        icon: const Icon(Icons.refresh),
        label: Text(context.l10n.commonRetry),
      ),
    );
  }
}

/// Mirrors the loaded layout: status card, members card, invite strip.
class _PartySkeleton extends StatelessWidget {
  const _PartySkeleton();

  @override
  Widget build(BuildContext context) {
    final card = BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(ValRadius.card),
    );
    Widget member() => const Padding(
      padding: EdgeInsets.all(14),
      child: Row(
        children: [
          Skeleton(width: 48, height: 48, radius: 24, shimmer: false),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: 150, height: 14, shimmer: false),
                SizedBox(height: 8),
                Skeleton(width: 110, height: 12, shimmer: false),
              ],
            ),
          ),
        ],
      ),
    );
    return SkeletonShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Skeleton(height: 150, radius: ValRadius.card, shimmer: false),
            const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(4, 24, 0, 10),
              child: Skeleton(width: 120, height: 12, shimmer: false),
            ),
            DecoratedBox(
              decoration: card,
              child: Column(children: [member(), member()]),
            ),
            const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(4, 24, 0, 10),
              child: Skeleton(width: 90, height: 12, shimmer: false),
            ),
            const Skeleton(height: 104, radius: ValRadius.card, shimmer: false),
          ],
        ),
      ),
    );
  }
}
