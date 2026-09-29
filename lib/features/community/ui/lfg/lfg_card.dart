import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/countdown_text.dart';
import '../../../../core/ui/rank_badge.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/format.dart';
import '../../community_strings.dart';
import '../../data/community_models.dart';
import '../feed/report_sheet.dart';
import '../widgets/community_widgets.dart';

/// One "Tìm đồng đội" post: author + rank, time left, mode, open slots,
/// note, and a big "Vào tổ đội" button (or "Gỡ tin" on the user's own).
class LfgCard extends ConsumerWidget {
  const LfgCard({
    super.key,
    required this.post,
    required this.isMine,
    required this.onJoin,
    required this.onRemove,
    required this.onReport,
    this.joining = false,
    this.onExpired,
  });

  final LfgPost post;
  final bool isMine;
  final VoidCallback onJoin;
  final VoidCallback onRemove;
  final VoidCallback onReport;
  final bool joining;
  final VoidCallback? onExpired;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final now = ref.watch(clockProvider).now();
    final expiresAt = post.expiresAt;
    final expired = post.isExpired(now);
    final soon =
        expiresAt != null &&
        expiresAt.difference(now) < const Duration(minutes: 5);
    final tier = post.rankTier ?? post.author.rankTier;
    return ValCard(
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
            subtitle: CommunityStrings.regionLabel(post.region),
            trailing: isMine
                ? const SizedBox(width: 8)
                : ContentMenuButton(
                    isMine: false,
                    onSelected: (_) => onReport(),
                  ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (expiresAt != null)
                  _TimeLeftPill(
                    expiresAt: expiresAt,
                    color: expired
                        ? muted
                        : (soon ? colors.warning : colors.win),
                    onExpired: onExpired,
                  ),
                ValBadge(
                  CommunityStrings.modeLabel(post.mode),
                  color: ValColors.red,
                  soft: true,
                ),
                ValBadge(
                  CommunityStrings.slotsWanted(post.slots),
                  color: colors.win,
                  soft: true,
                ),
                if (tier != null && tier > 2)
                  RankBadge(
                    tier: tier,
                    size: 22,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SlotDots(wanted: post.slots),
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
                child: Text(
                  post.note,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              height: 50,
              child: isMine
                  ? OutlinedButton.icon(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text(CommunityStrings.removeLfg),
                    )
                  : FilledButton.icon(
                      onPressed: expired || joining || !post.hasValidCode
                          ? null
                          : onJoin,
                      style: FilledButton.styleFrom(
                        textStyle: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
                            ? CommunityStrings.expired
                            : CommunityStrings.joinParty,
                      ),
                    ),
            ),
          ),
          if (isMine) ...[
            const SizedBox(height: 8),
            Text(
              CommunityStrings.partyCodeValue(post.partyCode),
              style: theme.textTheme.labelMedium?.copyWith(
                color: muted,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ],
      ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(ValRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 14, color: color),
          const SizedBox(width: 4),
          CountdownText(
            expiresAt: expiresAt,
            format: (d) => formatMinutesSeconds(d),
            builder: CommunityStrings.expiresIn,
            onExpired: onExpired,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Five party slots: filled for current members, red outlined for the
/// players wanted.
class _SlotDots extends StatelessWidget {
  const _SlotDots({required this.wanted});

  final int wanted;

  @override
  Widget build(BuildContext context) {
    final track = valColorsOf(context).track;
    final have = (5 - wanted).clamp(1, 4);
    return Row(
      children: [
        for (var i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: i < have
                ? Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: track,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  )
                : Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ValColors.red.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: ValColors.red,
                    ),
                  ),
          ),
      ],
    );
  }
}
