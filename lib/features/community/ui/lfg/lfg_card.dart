import 'package:valvn/core/l10n/labels/community_labels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/countdown_text.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/format.dart';
import '../../data/community_models.dart';
import '../../data/lfg_sync.dart';
import '../feed/report_sheet.dart';
import '../widgets/community_widgets.dart';
import '../widgets/translatable_text.dart';
import 'lfg_bits.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// One "Tìm đồng đội" post: author, time left, mode, rank range, roles,
/// mic / language, party size dots, picked agents, note and "Vào tổ đội"
/// (or, on the user's own post, live members + "Gia hạn" / "Gỡ tin").
class LfgCard extends ConsumerWidget {
  const LfgCard({
    super.key,
    required this.post,
    required this.isMine,
    required this.onJoin,
    required this.onRemove,
    required this.onReport,
    this.onExtend,
    this.joining = false,
    this.joinDisabled = false,
    this.onExpired,
    this.outOfRange = false,
    this.live,
  });

  final LfgPost post;
  final bool isMine;
  final VoidCallback onJoin;
  final VoidCallback onRemove;
  final VoidCallback onReport;
  final VoidCallback? onExtend;
  final bool joining;
  final bool joinDisabled;
  final VoidCallback? onExpired;

  /// Dimmed with "Ngoài khoảng rank" (the viewer's rank is outside).
  final bool outOfRange;

  /// Live party of the poster (own post only).
  final LfgPartySnapshot? live;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final now = ref.watch(clockProvider).now();
    final expiresAt = post.expiresAt;
    final expired = post.isExpired(now);
    final soon =
        expiresAt != null &&
        expiresAt.difference(now) < const Duration(minutes: 5);
    final partySize = live?.size ?? post.currentPartySize;
    final langTag = kLfgLanguages.contains(post.language)
        ? post.language.toUpperCase()
        : '';

    final card = ValCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
      borderColor: isMine ? ValColors.red.withValues(alpha: 0.55) : null,
      gradient: isMine
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ValColors.red.withValues(alpha: 0.14),
                ValColors.red.withValues(alpha: 0),
              ],
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthorRow(
            author: post.author,
            isMe: isMine,
            avatarSize: 44,
            subtitle: context.fmt.inlineFacts([
              context.l10n.communityRegionName(post.region),
              context.l10n.communityLanguageName(post.language),
            ]),
            trailing: isMine
                ? const SizedBox(width: 8)
                : ContentMenuButton(
                    author: post.author,
                    isMine: false,
                    onSelected: (_) => onReport(),
                  ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (expiresAt != null && post.status == LfgStatus.open)
                  _TimeLeftPill(
                    expiresAt: expiresAt,
                    color: expired
                        ? muted
                        : (soon ? colors.warning : colors.win),
                    onExpired: onExpired,
                  ),
                if (isMine || post.status != LfgStatus.open)
                  LfgStatusChip(status: post.status),
                ValBadge(
                  context.l10n.communityModeName(post.mode ?? ''),
                  color: ValColors.red,
                  soft: true,
                ),
                RankRangeBadge(min: post.rankMin, max: post.rankMax),
                if (post.mic == true)
                  Tooltip(
                    message: context.l10n.communityMic,
                    child: Icon(Icons.mic_rounded, size: 18, color: muted),
                  ),
                if (langTag.isNotEmpty)
                  Tooltip(
                    message: context.l10n.communityLanguageName(post.language),
                    child: ValBadge(langTag, color: colors.draw, soft: true),
                  ),
                if (outOfRange)
                  ValBadge(
                    context.l10n.communityOutOfRange,
                    color: colors.warning,
                    soft: true,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PartyDots(size: partySize),
              Text(
                context.l10n.communitySlotsWanted(post.slots),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: legibleAccent(context, colors.win),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (isMine && (live?.members.isNotEmpty ?? false)) ...[
            const SizedBox(height: 10),
            _LiveMembers(live: live!, db: db),
          ],
          if (post.roles.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final r in post.roles) RoleTag(role: r)],
            ),
          ],
          if (post.agents.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                for (final a in post.agents)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Tooltip(
                      message: db.agent(a)?.displayName ?? '',
                      child: NetImage(
                        db.agent(a)?.displayIcon,
                        width: 28,
                        height: 28,
                        borderRadius: BorderRadius.circular(8),
                        showSkeleton: false,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (post.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: colors.surface2.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(ValRadius.small),
                  border: const Border(
                    left: BorderSide(color: ValColors.red, width: 3),
                  ),
                ),
                child: TranslatableText(
                  post.note,
                  language: post.language,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: isMine
                ? _MineActions(
                    post: post,
                    onExtend: onExtend,
                    onRemove: onRemove,
                  )
                : SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      onPressed:
                          expired ||
                              joining ||
                              joinDisabled ||
                              post.status != LfgStatus.open
                          ? null
                          : onJoin,
                      icon: joining
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.group_add_rounded),
                      label: Text(
                        expired
                            ? context.l10n.communityExpired
                            : context.l10n.communityJoinParty,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
    if (!outOfRange) return card;
    // Dim with a translucent veil painted on top (no Opacity layer).
    return Stack(
      children: [
        card,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(ValRadius.card),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MineActions extends StatelessWidget {
  const _MineActions({
    required this.post,
    required this.onExtend,
    required this.onRemove,
  });

  final LfgPost post;
  final VoidCallback? onExtend;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: onExtend,
                  icon: const Icon(Icons.update_rounded),
                  label: Text(context.l10n.communityExtend),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(context.l10n.communityRemoveLfg),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          context.fmt.inlineFacts([
            context.l10n.communityPartyCodeValue(post.partyCode),
            context.l10n.communityJoinsCount(post.joins),
          ]),
          style: theme.textTheme.labelMedium?.copyWith(
            color: muted,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

/// Avatars (player cards) of the poster's live party.
class _LiveMembers extends StatelessWidget {
  const _LiveMembers({required this.live, required this.db});

  final LfgPartySnapshot live;
  final ContentDb db;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          context.l10n.communityLiveMembers.toUpperCase(),
          style: ValText.label.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 10),
        for (final m in live.members.take(5))
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.surfaceContainerHigh,
              child: ClipOval(
                child: NetImage(
                  m.playerCardId == null
                      ? null
                      : db.card(m.playerCardId!)?.smallArt,
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                  showSkeleton: false,
                  error: Icon(
                    Icons.person_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TimeLeftPill extends StatelessWidget {
  const _TimeLeftPill({
    required this.expiresAt,
    required this.color,
    this.onExpired,
  });

  final DateTime expiresAt;
  final Color color;
  final VoidCallback? onExpired;

  @override
  Widget build(BuildContext context) {
    final fg = legibleAccent(context, color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(ValRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 14, color: fg),
          const SizedBox(width: 4),
          CountdownText(
            expiresAt: expiresAt,
            format: (d) => formatMinutesSeconds(d),
            builder: context.l10n.communityExpiresIn,
            onExpired: onExpired,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
