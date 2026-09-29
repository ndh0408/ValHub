/// Public entry points for other screens (e.g. the future "Trang chủ"
/// dashboard): small providers + compact cards for "tin tìm đồng đội phù
/// hợp rank" and "skin hot trong tuần". Routes stay branch-index
/// independent (`/community?section=…`, `/community/skin/:uuid`).
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/accounts/account_providers.dart';
import '../../core/content/content_db.dart';
import '../../core/content/content_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tier_colors.dart';
import '../../core/ui/net_image.dart';
import '../../core/ui/val_widgets.dart';
import '../../core/util/clock.dart';
import '../../core/util/format.dart';
import 'community_routes.dart';
import 'community_strings.dart';
import 'data/community_models.dart';
import 'providers/community_providers.dart';
import 'providers/consent_providers.dart';
import 'providers/lfg_providers.dart';
import 'ui/community_screen.dart' show CommunitySection;
import 'ui/lfg/lfg_bits.dart';
import 'ui/skins/star_rating.dart';
import 'ui/widgets/community_widgets.dart';

/// The 2 newest open LFG posts that fit [puuid]'s rank and region.
final matchingLfgPreviewProvider = FutureProvider.autoDispose
    .family<List<LfgPost>, String>((ref, puuid) async {
      if (!ref.watch(communityEnabledProvider)) return const [];
      // The LFG list needs a session: hidden (and no sign-in, no consent
      // prompt) until the account agreed to join the community.
      if (ref.watch(communityConsentProvider(puuid)) !=
          CommunityConsent.granted) {
        return const [];
      }
      final account = ref.watch(accountProvider(puuid));
      if (account == null) return const [];
      final rank = lfgViewerRank(account);
      final page = await ref
          .watch(communityApiProvider)
          .lfg(
            puuid,
            region: communityRegion(account.region),
            rank: rank,
            limit: 6,
          );
      final now = ref.read(clockProvider).now();
      return [
        for (final p in page.items)
          if (p.status == LfgStatus.open &&
              !p.isExpired(now) &&
              p.acceptsRank(rank))
            p,
      ].take(2).toList();
    });

/// The top skins of [period] (by hearts), read-only (never signs in).
final trendingSkinsProvider = FutureProvider.autoDispose
    .family<List<TopSkin>, TopPeriod>((ref, period) async {
      if (!ref.watch(communityEnabledProvider)) return const [];
      final puuid = ref.watch(activeAccountProvider)?.puuid;
      final rows = await ref
          .watch(communityApiProvider)
          .topSkins(puuid: puuid, period: period, limit: 6, signIn: false);
      return rows.take(6).toList();
    });

/// Compact "Tìm đồng đội hợp rank" card; tap → the LFG section.
class LfgPreviewCard extends ConsumerWidget {
  const LfgPreviewCard({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final posts = ref.watch(matchingLfgPreviewProvider(puuid)).value;
    if (posts == null || posts.isEmpty) return const SizedBox.shrink();
    return ValCard(
      onTap: () => context.go(CommunityRoutes.section(CommunitySection.lfg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            CommunityStrings.lfgPreviewTitle,
            style: theme.textTheme.titleSmall,
          ),
          for (final p in posts)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  CommunityAvatar(author: p.author, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.author.riotId ?? CommunityStrings.unknownPlayer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          CommunityStrings.dotJoin([
                            CommunityStrings.modeLabel(p.mode),
                            CommunityStrings.slotsWanted(p.slots),
                          ]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RankRangeBadge(min: p.rankMin, max: p.rankMax),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact "Skin hot trong tuần" strip; tap a skin → its review page.
class TrendingSkinsCard extends ConsumerWidget {
  const TrendingSkinsCard({super.key, this.period = TopPeriod.week});

  final TopPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rows = ref.watch(trendingSkinsProvider(period)).value;
    if (rows == null || rows.isEmpty) return const SizedBox.shrink();
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    return ValCard(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              CommunityStrings.trendingTitle,
              style: theme.textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 122,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: rows.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final r = rows[i];
                final skin = db.skinByAnyUuid(r.skinUuid);
                final tint = opaqueRgba(
                  db.contentTier(skin?.contentTierUuid)?.highlightColor,
                  fallback: valColorsOf(context).muted,
                );
                return SizedBox(
                  key: ValueKey(r.skinUuid),
                  width: 132,
                  child: Material(
                    color: tint.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(ValRadius.small),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(ValRadius.small),
                      onTap: () =>
                          unawaited(openSkinReview(context, r.skinUuid)),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: NetImage(skin?.image, showSkeleton: false),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              skin?.displayName ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.favorite_rounded,
                                  size: 12,
                                  color: ValColors.red,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  formatNumber(r.vote.votes),
                                  style: theme.textTheme.labelSmall,
                                ),
                                if (r.rating.average != null) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.star_rounded,
                                    size: 12,
                                    color: starColor(context),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    formatRating(r.rating.average!),
                                    style: theme.textTheme.labelSmall,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
