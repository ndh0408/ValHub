/// "Cộng đồng" (docs/design/HOME.md §5.6): LFG posts that fit the viewer's
/// rank (only once the account agreed to the community) and this week's hot
/// skins. Read-only: Home never signs in to the community server and cannot
/// join a party; joining lives in the Community tab behind a confirmation.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_fallbacks.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tier_colors.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/rank_badge.dart';
import '../../../../core/util/clock.dart';
import '../../../community/community_routes.dart';
import '../../../community/providers/hidden_authors.dart';
import '../../../community/community_strings.dart';
import '../../../community/data/community_models.dart';
import '../../../community/ui/community_screen.dart' show CommunitySection;
import '../../../community/ui/lfg/lfg_bits.dart' show RankRangeBadge;
import '../../../skin_detail/skin_detail_sheet.dart';
import '../../data/home_card.dart';
import '../../home_strings.dart';
import '../../providers/home_card_providers.dart';
import '../home_card_frame.dart';

import 'package:valvn/core/l10n/l10n.dart';

class CommunityHomeCard extends ConsumerWidget {
  const CommunityHomeCard({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(homeCommunitySnapshotProvider(puuid)).value;
    if (snap == null) return const SizedBox.shrink();
    final hidden = ref.watch(hiddenAuthorsProvider(puuid));
    final lfg = snap.lfg
        .where((p) => !hidden.containsKey(p.author.id))
        .toList();
    final theme = Theme.of(context);
    return HomeCardFrame(
      card: HomeCardId.community,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (lfg.isNotEmpty) ...[
            _SectionTitle(context.l10n.homeLfgTitle),
            for (final p in lfg) _LfgRow(post: p),
            _LinkButton(
              label: context.l10n.homeOpenLfg,
              onPressed: () =>
                  context.go(CommunityRoutes.section(CommunitySection.lfg)),
            ),
          ],
          if (lfg.isNotEmpty && snap.trending.isNotEmpty)
            const SizedBox(height: 8),
          if (snap.trending.isNotEmpty) ...[
            _SectionTitle(context.l10n.homeTrendingTitle),
            const SizedBox(height: 8),
            _TrendingStrip(skins: snap.trending, wishlist: snap.wishlist),
            _LinkButton(
              label: context.l10n.homeOpenRanking,
              onPressed: () =>
                  context.go(CommunityRoutes.section(CommunitySection.skins)),
            ),
          ],
          if (snap.isEmpty)
            Text(
              context.l10n.homeCardCommunityDesc,
              style: theme.textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelLarge
          ?.copyWith(fontWeight: FontWeight.w700),
    ),
  );
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.chevron_right),
      iconAlignment: IconAlignment.end,
      label: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
    ),
  );
}

/// One LFG post: who, mode, spots needed, time left, and the rank range.
/// Tap → the LFG section (joining a party happens there).
class _LfgRow extends ConsumerWidget {
  const _LfgRow({required this.post});

  final LfgPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider).now();
    final left = post.expiresAt?.difference(now);
    final author = post.author.riotId ?? context.l10n.communityUnknownPlayer;
    final details = [
      CommunityStrings.modeLabel(post.mode),
      context.l10n.homeLfgNeeds(post.slots),
      if (left != null && !left.isNegative)
        context.l10n.homeLfgExpiresIn(context.fmt.durationCoarse(left)),
    ].join(context.l10n.homeDot);
    final tier = post.rankTier ?? post.author.rankTier;
    return InkWell(
      onTap: () => context.go(CommunityRoutes.section(CommunitySection.lfg)),
      borderRadius: BorderRadius.circular(ValRadius.small),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Semantics(
          button: true,
          label: context.l10n.homeLfgRowSemantics(author, details),
          excludeSemantics: true,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      details,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (post.mic ?? false)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 6),
                  child: Icon(
                    Icons.mic_none_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (post.hasRankRange)
                RankRangeBadge(min: post.rankMin, max: post.rankMax)
              else if (tier != null && tier > 2)
                RankBadge(tier: tier, size: 24, showName: false),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three hot skins with their votes and a ♥ for wishlisted ones; a 2-column
/// grid at large text or on a narrow card.
class _TrendingStrip extends ConsumerWidget {
  const _TrendingStrip({required this.skins, required this.wishlist});

  final List<TopSkin> skins;
  final Set<String> wishlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final grid = scale >= 1.3 || constraints.maxWidth < 300;
        Widget tile(TopSkin s) => _TrendingTile(
          skin: s,
          db: db,
          wished: wishlistContains(wishlist, s.skinUuid, db),
        );
        if (!grid) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < skins.length; i++) ...[
                if (i > 0) const SizedBox(width: gap),
                Expanded(child: tile(skins[i])),
              ],
            ],
          );
        }
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final s in skins) SizedBox(width: width, child: tile(s)),
          ],
        );
      },
    );
  }
}

class _TrendingTile extends StatelessWidget {
  const _TrendingTile({
    required this.skin,
    required this.db,
    required this.wished,
  });

  final TopSkin skin;
  final ContentDb db;
  final bool wished;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = db.skinByAnyUuid(skin.skinUuid);
    final tierId = data?.contentTierUuid;
    final tier = tierId == null
        ? null
        : db.contentTier(tierId) ?? ContentFallbacks.contentTier(tierId);
    final tint = opaqueRgba(
      tier?.highlightColor,
      fallback: valColorsOf(context).muted,
    );
    final name = data?.displayName ?? '';
    final votes = context.l10n.homeTrendingVotes(skin.vote.votes);
    return Semantics(
      button: true,
      label: HomeStrings.trendingSkinSemantics(name, votes, wished),
      excludeSemantics: true,
      child: Material(
        color: tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(ValRadius.small),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => unawaited(
            showSkinDetailSheet(
              context,
              skinOrLevelUuid: skin.skinUuid,
              mode: SkinDetailMode.catalog,
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 1.6,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        NetImage(data?.image, showSkeleton: false),
                        if (wished)
                          PositionedDirectional(
                            top: 0,
                            end: 0,
                            child: Icon(
                              Icons.favorite_rounded,
                              size: 14,
                              color: legibleAccent(
                                context,
                                theme.colorScheme.primary,
                                min: 3,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    votes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
