import 'dart:async';

import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, FilteringTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/async_value_view.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/xmpp/friends.dart';
import '../../../core/xmpp/xmpp_providers.dart';
import '../data/party_models.dart';
import '../providers/party_providers.dart';
import '../social_strings.dart';
import 'widgets/party_widgets.dart';
import 'widgets/social_widgets.dart';

/// S55 "Tổ đội & hàng chờ". Route `/profile/party`.
///
/// Remote party control while VALORANT runs on PC / console (GLZ
/// G-12…G-24): queue picker, start / cancel matchmaking with a timer,
/// ready, members (rank, ready, leader crown, remove), one-tap invites of
/// online friends, party code, join by code, incoming invites. Polls every
/// [pollInterval] (ring in the app bar). Every change is a user action;
/// removing / leaving / switching party asks first.
class PartyScreen extends ConsumerStatefulWidget {
  const PartyScreen({
    super.key,
    this.pollInterval = const Duration(seconds: 5),
  });

  final Duration pollInterval;

  @override
  ConsumerState<PartyScreen> createState() => _PartyScreenState();
}

class _PartyScreenState extends ConsumerState<PartyScreen> {
  final _code = TextEditingController();
  final Set<String> _busy = {};
  final Set<String> _invited = {};

  static final _codePattern = RegExp(r'^[A-Za-z0-9]{3,16}$');

  @override
  void dispose() {
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
    if (_busy.contains(key)) return;
    setState(() => _busy.add(key));
    try {
      await action();
      if (success != null && mounted) showAppSnackBar(context, success);
    } on Object catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          SocialStrings.actionFailed(describeError(e).message),
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
      return Scaffold(
        appBar: AppBar(title: const Text(SocialStrings.partyTitle)),
        body: const EmptyView(message: CommonStrings.errorNoAccount),
      );
    }
    final puuid = account.puuid;
    final provider = partyProvider(puuid);
    final value = ref.watch(provider);
    final view = value.value;
    final party = view?.party;
    return Scaffold(
      appBar: AppBar(
        title: const Text(SocialStrings.partyTitle),
        actions: [
          RefreshRing(
            period: widget.pollInterval,
            tooltip: SocialStrings.autoRefresh,
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
      ),
      body: RefreshIndicator(
        onRefresh: () => _notifier(puuid).refresh(),
        child: AsyncValueView<PartyView>(
          value: value,
          puuid: puuid,
          onRetry: () => ref.invalidate(provider),
          loading: const _PartySkeleton(),
          data: (v) => v.gameRunning
              ? _body(v, puuid)
              : _GameNotRunning(onRetry: () => _notifier(puuid).refresh()),
        ),
      ),
    );
  }

  Widget _body(PartyView v, String me) {
    final p = v.party;
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        if (v.inMatch)
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: PartyNotice(
                icon: Icons.sports_esports_outlined,
                text: SocialStrings.inMatchBanner,
                color: valColorsOf(context).warning,
              ),
            ),
          ),
        if (v.invites.isNotEmpty)
          PartySection(
            title: SocialStrings.invitesSection,
            child: Column(
              children: [
                for (final invite in v.invites)
                  _InviteRow(
                    invite: invite,
                    busy: _isBusy('accept-${invite.partyId}'),
                    onAccept: () => _accept(me, invite),
                    onDecline: () => _notifier(me).dismissInvite(invite),
                  ),
              ],
            ),
          ),
        if (p != null) ...[
          _matchmakingCard(v, p, me),
          _queueSection(v, p, me),
          PartySection(
            title: SocialStrings.membersSection(p.size, 5),
            child: Column(
              children: [
                for (final (i, m) in _ordered(p.members, me).indexed) ...[
                  if (i > 0) const Divider(height: 1, indent: 72),
                  PartyMemberTile(
                    key: ValueKey(m.puuid),
                    member: m,
                    isSelf: m.puuid == me,
                    onRemove: p.isOwner(me) && m.puuid != me && !v.inMatch
                        ? () => _kick(me, m)
                        : null,
                  ),
                ],
              ],
            ),
          ),
          if (p.isOwner(me) && p.requests.isNotEmpty)
            PartySection(
              title: SocialStrings.requestsSection,
              child: Column(
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
            ),
          _inviteSection(v, p, me),
          _codeSection(p, me),
        ] else
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              CommonStrings.errorNotFound,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        _joinSection(p, me),
      ],
    );
  }

  /// Leader first, then the viewer, then everyone else in Riot's order.
  static List<PartyMember> _ordered(List<PartyMember> members, String me) => [
    ...members.where((m) => m.isOwner),
    ...members.where((m) => !m.isOwner && m.puuid == me),
    ...members.where((m) => !m.isOwner && m.puuid != me),
  ];

  // ---------------------------------------------------------- matchmaking

  Widget _matchmakingCard(PartyView v, Party p, String me) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final isOwner = p.isOwner(me);
    final choice = queueChoices(p)
        .where((c) => c.queueId == p.queueId)
        .firstOrNull;
    final blocked = choice != null && !choice.eligible;
    final canStart =
        isOwner &&
        !v.inMatch &&
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
        style: FilledButton.styleFrom(backgroundColor: ValColors.red),
        onPressed: _isBusy('mm')
            ? null
            : () => _run('mm', () => _notifier(me).cancelMatchmaking()),
        icon: const Icon(Icons.close),
        label: since == null
            ? const Text(SocialStrings.cancelQueueShort)
            : ElapsedText(since: since, builder: SocialStrings.cancelQueue),
      );
    } else {
      primary = FilledButton.icon(
        onPressed: canStart && !_isBusy('mm')
            ? () => _run('mm', () => _notifier(me).startMatchmaking())
            : null,
        icon: _isBusy('mm')
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.play_arrow_rounded),
        label: const Text(SocialStrings.startQueue),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.sports_esports, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      p.queueId == null
                          ? SocialStrings.queueSection
                          : db.queueName(p.queueId),
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (p.isMatchmaking && since != null) ...[
                const SizedBox(height: 6),
                DefaultTextStyle.merge(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.warning,
                  ),
                  child: ElapsedText(
                    since: since,
                    builder: SocialStrings.searching,
                  ),
                ),
              ],
              if (p.isMatchFound) ...[
                const SizedBox(height: 6),
                Text(
                  SocialStrings.matchFound,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.win,
                  ),
                ),
              ],
              if (p.isCustomGame)
                const PartyNotice(
                  icon: Icons.tune,
                  text: SocialStrings.customGameLobby,
                ),
              const SizedBox(height: 12),
              primary,
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: self == null || _isBusy('ready') || p.isMatchmaking
                    ? null
                    : () => _run('ready', () => _notifier(me).setReady(!ready)),
                icon: Icon(ready ? Icons.remove_done : Icons.done_all),
                label: Text(
                  ready ? SocialStrings.unready : SocialStrings.ready,
                ),
              ),
              if (!isOwner && !p.isMatchmaking)
                const PartyNotice(
                  icon: Icons.info_outline,
                  text: SocialStrings.onlyLeaderQueue,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _queueSection(PartyView v, Party p, String me) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final isOwner = p.isOwner(me);
    final canChange =
        isOwner && !v.inMatch && !p.isMatchmaking && !p.isCustomGame;
    final choice = queueChoices(p)
        .where((c) => c.queueId == p.queueId)
        .firstOrNull;
    return PartySection(
      title: SocialStrings.queueSection,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QueuePicker(
              party: p,
              canChange: canChange && !_isBusy('queue'),
              onSelect: (q) =>
                  _run('queue', () => _notifier(me).changeQueue(q)),
              onBlocked: (msg) => showAppSnackBar(context, msg),
            ),
            if (choice != null && !choice.eligible) ...[
              const SizedBox(height: 8),
              PartyNotice(
                icon: Icons.block,
                color: Theme.of(context).colorScheme.error,
                text: SocialStrings.cantQueue(
                  db.queueName(choice.queueId),
                  queueBlockReason(choice, p),
                ),
              ),
            ],
            if (v.inMatch)
              const PartyNotice(
                icon: Icons.lock_outline,
                text: SocialStrings.queueLocked,
              )
            else if (!isOwner)
              const PartyNotice(
                icon: Icons.info_outline,
                text: SocialStrings.onlyLeaderChangeQueue,
              ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------- invites

  Widget _inviteSection(PartyView v, Party p, String me) {
    final friends = ref.watch(friendsProvider);
    final online = (friends.value?.online ?? const <Friend>[])
        .where((f) => f.valorant != null)
        .toList();
    final Widget child;
    if (friends.hasValue && online.isNotEmpty) {
      child = InviteStrip(
        friends: online,
        enabled: !v.inMatch,
        isTicked: (f) =>
            p.member(f.puuid) != null ||
            p.invitedPuuids.contains(f.puuid) ||
            _invited.contains('${p.id}/${f.puuid}'),
        onInvite: (f) => _invite(me, p, f),
      );
    } else if (friends.hasValue) {
      child = const Padding(
        padding: EdgeInsets.all(12),
        child: PartyNotice(
          icon: Icons.person_search_outlined,
          text: SocialStrings.noOnlineFriends,
        ),
      );
    } else if (friends.hasError) {
      child = const Padding(
        padding: EdgeInsets.all(12),
        child: PartyNotice(
          icon: Icons.cloud_off_outlined,
          text: SocialStrings.chatUnavailable,
        ),
      );
    } else {
      child = const Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Skeleton(width: 48, height: 48, radius: 10),
            SizedBox(width: 12),
            Skeleton(width: 48, height: 48, radius: 10),
            SizedBox(width: 12),
            Skeleton(width: 48, height: 48, radius: 10),
          ],
        ),
      );
    }
    return PartySection(title: SocialStrings.inviteFriends, child: child);
  }

  void _invite(String me, Party p, Friend f) {
    final name = f.name;
    if (name == null || name.tagLine.isEmpty) {
      showAppSnackBar(context, SocialStrings.inviteNeedsName);
      return;
    }
    unawaited(
      _run('invite-${f.puuid}', () async {
        await _notifier(me)
            .invite(gameName: name.gameName, tagLine: name.tagLine);
        if (mounted) setState(() => _invited.add('${p.id}/${f.puuid}'));
      }, success: SocialStrings.inviteSent(name.riotId)),
    );
  }

  Future<void> _accept(String me, PartyInvite invite) async {
    final notifier = _notifier(me);
    if (!notifier.canAcceptInvites) {
      showAppSnackBar(context, SocialStrings.acceptInGame);
      return;
    }
    await _run(
      'accept-${invite.partyId}',
      () => notifier.acceptInvite(invite),
      success: SocialStrings.joined,
    );
  }

  // ------------------------------------------------------------ code / join

  Widget _codeSection(Party p, String me) {
    final theme = Theme.of(context);
    final code = p.inviteCode;
    final isOwner = p.isOwner(me);
    return PartySection(
      title: SocialStrings.partyCode,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (code != null)
              SelectableText(
                SocialStrings.partyCodeValue(code),
                style: theme.textTheme.titleMedium?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              )
            else
              Text(SocialStrings.noCode, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (code != null) ...[
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: code));
                      if (mounted) {
                        showAppSnackBar(context, SocialStrings.codeCopied);
                      }
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text(SocialStrings.copyCode),
                  ),
                  if (isOwner)
                    OutlinedButton(
                      onPressed: _isBusy('code')
                          ? null
                          : () =>
                                _run('code', () => _notifier(me).disableCode()),
                      child: const Text(SocialStrings.disableCode),
                    ),
                ] else if (isOwner)
                  FilledButton.tonalIcon(
                    onPressed: _isBusy('code')
                        ? null
                        : () =>
                              _run('code', () => _notifier(me).generateCode()),
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text(SocialStrings.generateCode),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _joinSection(Party? p, String me) {
    return PartySection(
      title: SocialStrings.joinWithCode,
      child: Padding(
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
                decoration: const InputDecoration(
                  hintText: SocialStrings.joinWithCode,
                  counterText: '',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _isBusy('join') ? null : () => unawaited(_join(me, p)),
              child: const Text(SocialStrings.join),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _join(String me, Party? p) async {
    final code = _code.text.trim();
    if (!_codePattern.hasMatch(code)) {
      showAppSnackBar(context, SocialStrings.codeInvalid);
      return;
    }
    if (p != null && p.size > 1) {
      final ok = await confirmAction(
        context,
        title: SocialStrings.joinConfirmTitle,
        body: SocialStrings.joinConfirmBody,
        confirmLabel: SocialStrings.join,
        destructive: false,
      );
      if (!ok || !mounted) return;
    }
    await _run('join', () async {
      await _notifier(me).joinByCode(code);
      _code.clear();
    }, success: SocialStrings.joined);
  }

  // ------------------------------------------------------ remove / leave

  Future<bool> _kick(String me, PartyMember m) async {
    final name =
        ref.read(playerNameProvider(m.puuid)).value?.riotId ??
        CompetitiveStrings.unknownPlayer;
    final ok = await confirmAction(
      context,
      title: SocialStrings.removeConfirmTitle,
      body: SocialStrings.removeConfirmBody(name),
      confirmLabel: SocialStrings.removeMember,
    );
    if (ok && mounted) {
      unawaited(_run('kick-${m.puuid}', () => _notifier(me).kick(m.puuid)));
    }
    // The row disappears with the next party refresh, not by the swipe.
    return false;
  }

  Future<void> _leave(String me, Party p) async {
    final ok = await confirmAction(
      context,
      title: SocialStrings.leaveConfirmTitle,
      body: SocialStrings.leaveConfirmBody,
      confirmLabel: SocialStrings.leaveParty,
    );
    if (ok && mounted) await _run('leave', () => _notifier(me).leave());
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
    return PopupMenuButton<String>(
      tooltip: SocialStrings.moreActions,
      onSelected: (v) {
        if (v == 'leave') unawaited(onLeave());
        if (v == 'open') unawaited(onToggleOpen());
      },
      itemBuilder: (context) => [
        if (isOwner)
          PopupMenuItem(
            value: 'open',
            child: Text(
              party.isOpen ? SocialStrings.closeParty : SocialStrings.openParty,
            ),
          ),
        if (canLeave)
          const PopupMenuItem(
            value: 'leave',
            child: Text(SocialStrings.leaveParty),
          ),
      ],
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
    final from = invite.invitedBy;
    final name = from == null
        ? null
        : ref.watch(playerNameProvider(from)).value;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mail_outline),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name == null
                      ? SocialStrings.partyInvite
                      : SocialStrings.inviteFrom(name.riotId),
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: busy ? null : onDecline,
                  child: const Text(SocialStrings.decline),
                ),
                FilledButton(
                  onPressed: busy ? null : onAccept,
                  child: const Text(SocialStrings.accept),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              SocialStrings.requestFrom(
                name?.riotId ?? CompetitiveStrings.unknownPlayer,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: busy ? null : onDecline,
            child: const Text(SocialStrings.decline),
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
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(32, 64, 32, 32),
      children: [
        Icon(
          Icons.desktop_windows_outlined,
          size: 56,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        Text(
          SocialStrings.gameNotRunningTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          SocialStrings.gameNotRunningBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: OutlinedButton.icon(
            onPressed: () => unawaited(onRetry()),
            icon: const Icon(Icons.refresh),
            label: const Text(CommonStrings.retry),
          ),
        ),
      ],
    );
  }
}

class _PartySkeleton extends StatelessWidget {
  const _PartySkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const Skeleton(height: 150, radius: 12, shimmer: false),
          const SizedBox(height: 24),
          const Skeleton(width: 90, height: 14, shimmer: false),
          const SizedBox(height: 10),
          const Skeleton(height: 84, radius: 12, shimmer: false),
          const SizedBox(height: 24),
          const Skeleton(width: 120, height: 14, shimmer: false),
          const SizedBox(height: 10),
          for (var i = 0; i < 3; i++) ...[
            const Skeleton(height: 64, radius: 12, shimmer: false),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
