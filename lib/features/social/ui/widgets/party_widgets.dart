import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/rank_badge.dart';
import '../../../../core/ui/sub_page.dart';
import '../../../../core/ui/val_widgets.dart';
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
    final theme = Theme.of(context);
    return IconButton(
      tooltip: widget.tooltip,
      onPressed: () => unawaited(_now()),
      icon: SizedBox.square(
        dimension: 24,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _c,
              builder: (context, _) => CircularProgressIndicator(
                value: 1 - _c.value,
                strokeWidth: 2.2,
                color: theme.colorScheme.primary,
                backgroundColor: valColorsOf(context).track,
              ),
            ),
            Icon(
              Icons.refresh,
              size: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// "01:32" since [since], ticking every second.
class ElapsedText extends ConsumerStatefulWidget {
  const ElapsedText({
    super.key,
    required this.since,
    required this.builder,
    this.style,
  });

  final DateTime since;
  final String Function(String elapsed) builder;
  final TextStyle? style;

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
      style: widget.style?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
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
    final c = color == null
        ? theme.colorScheme.onSurfaceVariant
        : legibleAccent(context, color!, min: 4.5);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 17, color: c),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: c,
                height: 1.35,
              ),
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

/// "Chọn hàng chờ" sheet (VF S55): every queue with its vi name, the
/// current one ticked, blocked ones greyed with the reason; competitive
/// stays selectable (Riot lets the party pick it and explains why it cannot
/// start). Resolves to the picked queue id, `null` when dismissed.
Future<String?> showQueuePickerSheet(BuildContext context, Party party) =>
    showValSheet<String>(
      context,
      title: SocialStrings.pickQueueTitle,
      subtitle: SocialStrings.pickQueueSubtitle(party.size),
      builder: (context, _) => _QueuePickerBody(party: party),
    );

class _QueuePickerBody extends ConsumerWidget {
  const _QueuePickerBody({required this.party});

  final Party party;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final colors = valColorsOf(context);
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        GroupedSection(
          children: [
            for (final c in queueChoices(party))
              Builder(
                builder: (context) {
                  final current = c.queueId == party.queueId;
                  final max =
                      kQueuePartyLimits[c.queueId.replaceFirst('console_', '')];
                  final String? subtitle = !c.eligible
                      ? SocialStrings.sentence(queueBlockReason(c, party))
                      : max != null
                      ? SocialStrings.queueMaxParty(max)
                      : null;
                  final enabled = !current && c.selectable;
                  return GroupedRow(
                    key: ValueKey('queue-${c.queueId}'),
                    title: db.queueName(c.queueId),
                    subtitle: subtitle,
                    titleColor: enabled || current
                        ? null
                        : theme.colorScheme.onSurfaceVariant,
                    leading: _QueueIcon(
                      icon: current
                          ? Icons.check_rounded
                          : c.eligible
                          ? Icons.sports_esports_outlined
                          : Icons.lock_outline,
                      color: current
                          ? theme.colorScheme.primary
                          : c.eligible
                          ? colors.muted
                          : theme.colorScheme.error,
                    ),
                    trailing: current
                        ? ValBadge(
                            SocialStrings.currentQueue,
                            color: theme.colorScheme.primary,
                            soft: true,
                          )
                        : null,
                    showChevron: enabled,
                    onTap: enabled
                        ? () {
                            Haptics.selection();
                            Navigator.of(context).pop(c.queueId);
                          }
                        : null,
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _QueueIcon extends StatelessWidget {
  const _QueueIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, size: 19, color: legibleAccent(context, color, min: 3)),
  );
}

/// One party member (VF S55): card art, Riot ID, leader badge, rank + RR,
/// level, console platform, best ping and the ready state. Owners can
/// remove others (swipe left or the button; both ask first).
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
    final muted = theme.colorScheme.onSurfaceVariant;
    final name = ref.watch(playerNameProvider(member.puuid)).value;
    final rank = ref.watch(rankSummaryProvider(member.puuid)).value?.current;
    final tier = rank?.tier ?? member.competitiveTier;
    final level = visibleAccountLevel(
      member.accountLevel,
      hideAccountLevel: member.hideAccountLevel,
      isSelf: isSelf,
      isPartyMember: true,
    );
    final ready = member.isReady || member.isOwner;
    final console = SocialStrings.consolePlatform(member.platformType);
    final ping = member.ping;
    final small = theme.textTheme.bodySmall?.copyWith(color: muted);

    final row = Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      child: Row(
        children: [
          // Green ring = ready (the leader is always ready).
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ready ? colors.win : Colors.transparent,
                width: 2,
              ),
            ),
            child: FriendAvatar(
              playerCardId: member.playerCardId,
              name: name?.gameName,
              size: 44,
            ),
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
                          color: colors.gold,
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
                      ValBadge(
                        SocialStrings.you,
                        color: theme.colorScheme.primary,
                        soft: true,
                        uppercase: true,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (level != null)
                      Text(SocialStrings.level(level), style: small),
                    if (member.isOwner)
                      Text(
                        SocialStrings.leader,
                        style: small?.copyWith(
                          color: colors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (console != null) Text(console, style: small),
                    if (ping != null) _PingLabel(ms: ping),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _ReadyIcon(ready: ready),
          if (onRemove != null)
            IconButton(
              tooltip: SocialStrings.removeMember,
              icon: const Icon(Icons.person_remove_outlined),
              onPressed: () => unawaited(onRemove!()),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
    final remove = onRemove;
    if (remove == null) return row;
    return Dismissible(
      key: ValueKey('member-${member.puuid}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => remove(),
      background: ColoredBox(
        color: theme.colorScheme.error,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
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
        ),
      ),
      child: row,
    );
  }
}

/// "24 ms" with a signal icon colored by quality (players in Vietnam
/// usually see 30–60 ms to the Singapore / Hong Kong servers).
class _PingLabel extends StatelessWidget {
  const _PingLabel({required this.ms});

  final int ms;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final color = ms < 60
        ? colors.win
        : ms < 100
        ? colors.warning
        : colors.loss;
    final c = legibleAccent(context, color, min: 4.5);
    return Tooltip(
      message: SocialStrings.pingTooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.network_check_rounded, size: 14, color: c),
          const SizedBox(width: 3),
          Text(
            SocialStrings.ping(ms),
            style: theme.textTheme.bodySmall?.copyWith(
              color: c,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyIcon extends StatelessWidget {
  const _ReadyIcon({required this.ready});

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
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    return SizedBox(
      height: 90 + 18 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
        itemCount: friends.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
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
              borderRadius: BorderRadius.circular(ValRadius.small),
              onTap: ticked || !enabled ? null : () => onInvite(f),
              child: SizedBox(
                width: 72,
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        FriendAvatar(
                          playerCardId: f.playerCardId,
                          name: f.name?.gameName,
                          size: 50,
                        ),
                        Positioned(
                          right: -3,
                          bottom: -3,
                          child: AnimatedContainer(
                            duration: ValMotion.medium,
                            curve: ValMotion.curve,
                            decoration: BoxDecoration(
                              color: ticked
                                  ? valColorsOf(context).win
                                  : theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.surfaceContainer,
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
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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
