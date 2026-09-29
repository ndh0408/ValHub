import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/rank_badge.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/format.dart';
import '../../../../core/xmpp/friends.dart';
import '../../data/party_models.dart';
import '../../social_strings.dart';
import 'friend_tile.dart';
import 'social_widgets.dart';

/// Countdown ring in the app bar: completes every [period], then calls
/// [onCycle] and starts over (VF S4 "a countdown ring shows the next
/// refresh"). Ticker-driven, so it pauses while the app is backgrounded.
class RefreshRing extends StatefulWidget {
  const RefreshRing({
    super.key,
    required this.onCycle,
    this.period = const Duration(seconds: 5),
    this.tooltip,
  });

  final Future<void> Function() onCycle;
  final Duration period;
  final String? tooltip;

  @override
  State<RefreshRing> createState() => _RefreshRingState();
}

class _RefreshRingState extends State<RefreshRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  )..addStatusListener(_onStatus);
  bool _running = false;

  @override
  void initState() {
    super.initState();
    unawaited(_c.forward());
  }

  Future<void> _onStatus(AnimationStatus s) async {
    if (s != AnimationStatus.completed || _running) return;
    _running = true;
    try {
      await widget.onCycle();
    } finally {
      _running = false;
      if (mounted) unawaited(_c.forward(from: 0));
    }
  }

  Future<void> _now() async {
    _c.stop();
    _running = true;
    try {
      await widget.onCycle();
    } finally {
      _running = false;
      if (mounted) unawaited(_c.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: widget.tooltip,
      onPressed: () => unawaited(_now()),
      icon: SizedBox.square(
        dimension: 22,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CircularProgressIndicator(
            value: 1 - _c.value,
            strokeWidth: 2.5,
            backgroundColor: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.12),
          ),
        ),
      ),
    );
  }
}

/// "01:32" since [since], ticking every second.
class ElapsedText extends ConsumerStatefulWidget {
  const ElapsedText({super.key, required this.since, required this.builder});

  final DateTime since;
  final String Function(String elapsed) builder;

  @override
  ConsumerState<ElapsedText> createState() => _ElapsedTextState();
}

class _ElapsedTextState extends ConsumerState<ElapsedText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.read(clockProvider).now();
    return Text(
      widget.builder(formatMinutesSeconds(now.difference(widget.since))),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Card section with a title.
class PartySection extends StatelessWidget {
  const PartySection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      letterSpacing: 1.1,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Inline notice (icon + text) inside the party screen.
class PartyNotice extends StatelessWidget {
  const PartyNotice({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: c),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(color: c),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vietnamese reason of a blocked queue (lowercase first letter).
String queueBlockReason(QueueChoice c, Party party) => switch (c.block) {
  QueueBlock.partyTooLarge => SocialStrings.reasonPartyTooLarge(
    c.maxPartySize ?? 5,
  ),
  QueueBlock.accountLevel => SocialStrings.reasonAccountLevel,
  QueueBlock.rankDisparity => SocialStrings.reasonRankDisparity,
  QueueBlock.restricted => SocialStrings.reasonRestricted(
    formatDurationCoarse(Duration(seconds: party.restrictedSeconds)),
  ),
  QueueBlock.other || null => SocialStrings.reasonGeneric,
};

/// Queue chips (VF S55): vi names, current queue selected, blocked queues
/// greyed (tap → reason), competitive always selectable.
class QueuePicker extends ConsumerWidget {
  const QueuePicker({
    super.key,
    required this.party,
    required this.canChange,
    required this.onSelect,
    required this.onBlocked,
  });

  final Party party;
  final bool canChange;
  final void Function(String queueId) onSelect;
  final void Function(String message) onBlocked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final choices = queueChoices(party);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in choices)
          ChoiceChip(
            label: Text(
              db.queueName(c.queueId),
              overflow: TextOverflow.ellipsis,
            ),
            selected: c.queueId == party.queueId,
            avatar: c.eligible
                ? null
                : const Icon(Icons.lock_outline, size: 16),
            onSelected: !canChange || c.queueId == party.queueId
                ? null
                : (_) {
                    if (c.selectable) {
                      Haptics.selection();
                      onSelect(c.queueId);
                    } else {
                      onBlocked(
                        SocialStrings.sentence(queueBlockReason(c, party)),
                      );
                    }
                  },
          ),
      ],
    );
  }
}

/// One party member (VF S55): card, Riot ID, rank + RR, level, ready,
/// leader crown. Owners can remove others (swipe left or the button).
class PartyMemberTile extends ConsumerWidget {
  const PartyMemberTile({
    super.key,
    required this.member,
    required this.isSelf,
    this.onRemove,
  });

  final PartyMember member;
  final bool isSelf;

  /// Non-null when the viewer may remove this member (asks first).
  final Future<bool> Function()? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final name = ref.watch(playerNameProvider(member.puuid)).value;
    final rank = ref.watch(rankSummaryProvider(member.puuid)).value?.current;
    final tier = rank?.tier ?? member.competitiveTier;
    final level = visibleAccountLevel(
      member.accountLevel,
      hideAccountLevel: member.hideAccountLevel,
      isSelf: isSelf,
      isPartyMember: true,
    );
    final row = Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          FriendAvatar(
            playerCardId: member.playerCardId,
            name: name?.gameName,
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (member.isOwner) ...[
                      Tooltip(
                        message: SocialStrings.leader,
                        child: Icon(
                          Icons.workspace_premium,
                          size: 18,
                          color: colors.warning,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: RiotIdText(
                        name,
                        fallback: CompetitiveStrings.unknownPlayer,
                      ),
                    ),
                    if (isSelf) ...[
                      const SizedBox(width: 6),
                      Text(
                        SocialStrings.youTag,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    RankBadge(
                      tier: tier,
                      seasonId: rank?.actUuid,
                      rr: (rank != null && !rank.isUnranked) ? rank.rr : null,
                      size: 20,
                      style: theme.textTheme.bodySmall,
                    ),
                    if (level != null)
                      Text(
                        SocialStrings.level(level),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (member.isOwner)
                      Text(
                        SocialStrings.leader,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.warning,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _ReadyChip(ready: member.isReady || member.isOwner),
          if (onRemove != null)
            IconButton(
              tooltip: SocialStrings.removeMember,
              icon: const Icon(Icons.person_remove_outlined),
              onPressed: () => unawaited(onRemove!()),
            ),
        ],
      ),
    );
    final remove = onRemove;
    if (remove == null) return row;
    return Dismissible(
      key: ValueKey('member-${member.puuid}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => remove(),
      background: Container(
        color: theme.colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_remove_outlined,
              color: theme.colorScheme.onError,
            ),
            const SizedBox(width: 8),
            Text(
              SocialStrings.removeMember,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
      child: row,
    );
  }
}

class _ReadyChip extends StatelessWidget {
  const _ReadyChip({required this.ready});

  final bool ready;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final c = ready ? colors.win : theme.colorScheme.onSurfaceVariant;
    return Tooltip(
      message: ready ? SocialStrings.ready : SocialStrings.notReady,
      child: Icon(
        ready ? Icons.check_circle : Icons.radio_button_unchecked,
        color: c,
        size: 22,
        semanticLabel: ready ? SocialStrings.ready : SocialStrings.notReady,
      ),
    );
  }
}

/// Horizontal strip of online friends in VALORANT (S3): tap = invite;
/// members and invited friends are ticked.
class InviteStrip extends StatelessWidget {
  const InviteStrip({
    super.key,
    required this.friends,
    required this.isTicked,
    required this.onInvite,
    this.enabled = true,
  });

  final List<Friend> friends;
  final bool Function(Friend) isTicked;
  final void Function(Friend) onInvite;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        itemCount: friends.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = friends[i];
          final ticked = isTicked(f);
          final label = f.name?.gameName ?? CompetitiveStrings.unknownPlayer;
          return Semantics(
            button: true,
            label: ticked
                ? SocialStrings.invitedLabel(label)
                : SocialStrings.inviteLabel(label),
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: ticked || !enabled ? null : () => onInvite(f),
              child: SizedBox(
                width: 68,
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        FriendAvatar(
                          playerCardId: f.playerCardId,
                          name: f.name?.gameName,
                          size: 48,
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: ticked
                                  ? valColorsOf(context).win
                                  : theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.surface,
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              ticked ? Icons.check : Icons.add,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
