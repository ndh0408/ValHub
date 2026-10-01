import '../../providers/hidden_authors.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account_providers.dart';
import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/storage/ui_memory.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tier_colors.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/segmented_tabs.dart';
import '../../../../core/ui/skeleton.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/format.dart';
import '../../../skin_detail/skin_detail_sheet.dart' show skinMedia;
import '../../../skin_detail/skin_video_view.dart';
import '../../community_strings.dart';
import '../../data/community_api.dart';
import '../../data/community_models.dart';
import '../../providers/community_providers.dart';
import '../../providers/skin_review_providers.dart';
import '../../providers/skin_vote_providers.dart';
import '../feed/report_sheet.dart';
import '../widgets/community_widgets.dart';
import '../consent/consent_sheet.dart';
import 'review_editor_sheet.dart';
import 'skin_vote_button.dart';
import '../widgets/translatable_text.dart';
import 'star_rating.dart';

/// `UiMemory` key of the review list order.
const kReviewSortMemoryKey = 'community.reviews.sort';

/// Daily Val-style skin page: hero render (+ video), price / source, the
/// community score (average, 5-bar distribution, hearts), "Đánh giá của
/// bạn" and the paged reviews (Mới nhất / Hữu ích nhất).
class SkinReviewScreen extends ConsumerStatefulWidget {
  const SkinReviewScreen({super.key, required this.skinUuid});

  /// Skin (or level / chroma) uuid.
  final String skinUuid;

  @override
  ConsumerState<SkinReviewScreen> createState() => _SkinReviewScreenState();
}

class _SkinReviewScreenState extends ConsumerState<SkinReviewScreen> {
  late ReviewSort _sort = ref
      .read(uiMemoryProvider)
      .readEnum(kReviewSortMemoryKey, ReviewSort.values, ReviewSort.newest);

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final skin = db.skinByAnyUuid(widget.skinUuid);
    final skinId = skin?.uuid ?? widget.skinUuid.toLowerCase();
    final puuid = ref.watch(activeAccountProvider)?.puuid;
    final key = (puuid: puuid, skinUuid: skinId);
    final reviewsKey = (puuid: puuid, skinUuid: skinId, sort: _sort);
    final summary = ref.watch(skinSummaryProvider(key));
    final reviews = ref.watch(skinReviewsProvider(reviewsKey));
    final meId = puuid == null
        ? null
        : ref.watch(communityMeProvider(puuid)).value?.id;
    final tier = db.contentTier(skin?.contentTierUuid);
    final tint = opaqueRgba(
      tier?.highlightColor,
      fallback: valColorsOf(context).muted,
    );
    final weaponUuid = skin?.weaponUuid ?? summary.value?.weaponUuid;

    return Scaffold(
      body: AdaptiveRefresh(
        onRefresh: () async {
          ref.invalidate(skinReviewsProvider(reviewsKey));
          await ref.read(skinSummaryProvider(key).notifier).refresh();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverAppBar(
              pinned: true,
              title: Text(CommunityStrings.reviewTitle),
            ),
            SliverToBoxAdapter(
              child: _Hero(skinUuid: skinId, db: db, tint: tint),
            ),
            SliverToBoxAdapter(
              child: _Header(skinUuid: skinId, db: db, tint: tint),
            ),
            SliverToBoxAdapter(
              child: _ScoreCard(
                summary: summary,
                puuid: puuid,
                skinUuid: skinId,
                weaponUuid: weaponUuid,
                onRetry: () => ref.invalidate(skinSummaryProvider(key)),
              ),
            ),
            SliverToBoxAdapter(
              child: _MyReviewCard(
                summary: summary.value,
                loading: !summary.hasValue && summary.isLoading,
                puuid: puuid,
                skinUuid: skinId,
                weaponUuid: weaponUuid,
              ),
            ),
            SliverToBoxAdapter(
              child: SectionLabel(
                CommunityStrings.reviewsHeader(
                  formatNumber(summary.value?.rating.reviewCount ?? 0),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SegmentedTabs<ReviewSort>(
                expand: true,
                tabs: const [
                  SegmentedTab(
                    value: ReviewSort.newest,
                    label: CommunityStrings.sortNewest,
                  ),
                  SegmentedTab(
                    value: ReviewSort.top,
                    label: CommunityStrings.sortHelpful,
                  ),
                ],
                selected: _sort,
                onChanged: (s) {
                  setState(() => _sort = s);
                  ref.read(uiMemoryProvider).writeEnum(kReviewSortMemoryKey, s);
                },
              ),
            ),
            ..._reviewSlivers(reviews, reviewsKey, meId),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }

  List<Widget> _reviewSlivers(
    AsyncValue<PagedState<SkinReview>> async,
    ReviewsKey key,
    String? meId,
  ) {
    if (!async.hasValue) {
      if (async.hasError && !async.isLoading) {
        return [
          SliverToBoxAdapter(
            child: CommunityErrorState(
              error: async.error!,
              puuid: key.puuid,
              onRetry: () => ref.invalidate(skinReviewsProvider(key)),
            ),
          ),
        ];
      }
      return [
        SliverToBoxAdapter(
          child: SkeletonColumn(item: (_) => const ReviewTileSkeleton()),
        ),
      ];
    }
    final state = async.requireValue;
    if (state.items.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: CommunityEmptyState(
            icon: Icons.rate_review_outlined,
            title: CommunityStrings.reviewsEmptyTitle,
            message: CommunityStrings.reviewsEmptyBody,
          ),
        ),
      ];
    }
    final hidden = key.puuid == null
        ? <String, HiddenAuthor>{}
        : ref.watch(hiddenAuthorsProvider(key.puuid!));
    final reviews = state.items
        .where((r) => !hidden.containsKey(r.author.id))
        .toList();
    final notifier = ref.read(skinReviewsProvider(key).notifier);
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        sliver: SliverList.builder(
          itemCount: reviews.length + 1,
          itemBuilder: (context, i) {
            if (i == reviews.length) {
              return PagedFooter(
                hasMore: state.hasMore,
                loading: state.loadingMore,
                error: state.loadMoreError,
                onLoadMore: () => unawaited(notifier.loadMore()),
              );
            }
            final r = reviews[i];
            final mine = r.mine || (meId != null && r.author.id == meId);
            return Padding(
              key: ValueKey(r.id),
              padding: const EdgeInsets.only(bottom: 10),
              child: ReviewTile(
                review: r,
                isMine: mine,
                onHelpful: key.puuid == null || mine
                    ? null
                    : () => unawaited(_like(notifier, r.id)),
                onAction: (a) => unawaited(_action(key, r, a)),
              ),
            );
          },
        ),
      ),
    ];
  }

  Future<void> _like(SkinReviewsNotifier notifier, String id) async {
    if (!await promptConsentFromContext(context) || !mounted) return;
    try {
      await notifier.toggleLike(id);
    } on Object catch (e) {
      if (mounted) showCommunityError(context, e);
    }
  }

  Future<void> _action(
    ReviewsKey key,
    SkinReview review,
    ContentAction action,
  ) async {
    final puuid = key.puuid;
    if (puuid == null) return;
    switch (action) {
      case ContentAction.delete:
        await confirmDeleteReview(context, ref, puuid, key.skinUuid);
      case ContentAction.report:
        await reportContent(
          context,
          ref,
          puuid: puuid,
          targetType: ReportTarget.review,
          targetId: review.id,
        );
    }
  }
}

/// Confirms, then deletes the viewer's review of [skinUuid].
Future<void> confirmDeleteReview(
  BuildContext context,
  WidgetRef ref,
  String puuid,
  String skinUuid,
) async {
  final ok = await showConfirmDialog(
    context,
    title: CommunityStrings.deleteReviewTitle,
    message: CommunityStrings.deleteReviewBody,
    confirmLabel: CommunityStrings.delete,
    destructive: true,
  );
  if (!ok || !context.mounted) return;
  try {
    await deleteOwnSkinReview(ref, puuid: puuid, skinUuid: skinUuid);
    if (context.mounted) _snack(context, CommunityStrings.reviewDeleted);
  } on Object catch (e) {
    if (context.mounted) showCommunityError(context, e);
  }
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class _Hero extends StatelessWidget {
  const _Hero({required this.skinUuid, required this.db, required this.tint});

  final String skinUuid;
  final ContentDb db;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final skin = db.skinByAnyUuid(skinUuid);
    final media = skin == null
        ? (render: null, video: null)
        : skinMedia(skin, skin.chromas.firstOrNull);
    final video = media.video;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(ValRadius.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: video == null
              ? null
              : () => unawaited(openSkinVideo(context, videoUrl: video)),
          child: Ink(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.1,
                colors: [
                  tint.withValues(alpha: 0.5),
                  tint.withValues(alpha: 0.04),
                ],
              ),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: skin == null && db.isEmpty
                        ? const Skeleton(height: null, radius: 12)
                        : NetImage(media.render ?? skin?.image),
                  ),
                  if (video != null)
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(ValRadius.pill),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                CommunityStrings.playVideo,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
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

class _Header extends ConsumerWidget {
  const _Header({required this.skinUuid, required this.db, required this.tint});

  final String skinUuid;
  final ContentDb db;
  final Color tint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final skin = db.skinByAnyUuid(skinUuid);
    if (skin == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: db.isEmpty
            ? const Skeleton(width: 200, height: 22)
            : Text(
                CommunityStrings.skinNotFound,
                style: theme.textTheme.titleMedium?.copyWith(color: muted),
              ),
      );
    }
    final weapon = db.weaponBySkin(skin.uuid);
    final tier = db.contentTier(skin.contentTierUuid);
    final quote = ref.watch(priceServiceProvider).priceForSkin(skin.uuid);
    final vp = quote.vp;
    final price =
        quote.caption ??
        (vp == null
            ? null
            : (quote.isEstimate ? formatEstimatedVp(vp) : formatVp(vp)));
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            skin.displayName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (weapon != null)
                Text(
                  weapon.displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
              if (tier != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DiamondPip(size: 12, color: tint),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        tier.displayName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: legibleAccent(context, tint),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              if (price != null)
                Text(
                  price,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends ConsumerWidget {
  const _ScoreCard({
    required this.summary,
    required this.puuid,
    required this.skinUuid,
    required this.weaponUuid,
    required this.onRetry,
  });

  final AsyncValue<SkinSummary> summary;
  final String? puuid;
  final String skinUuid;
  final String? weaponUuid;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final s = summary.value;
    Widget child;
    if (s == null) {
      child = summary.hasError && !summary.isLoading
          ? CommunityErrorState(
              error: summary.error!,
              onRetry: onRetry,
              compact: true,
            )
          : const SkeletonShimmer(
              child: Row(
                children: [
                  Skeleton(width: 90, height: 70, shimmer: false),
                  SizedBox(width: 16),
                  Expanded(child: Skeleton(height: 70, shimmer: false)),
                ],
              ),
            );
    } else {
      final p = puuid;
      final override = p == null
          ? null
          : ref.watch(skinVoteOverridesProvider(p).select((m) => m[skinUuid]));
      final vote = override ?? s.vote ?? SkinVote(skinUuid: skinUuid);
      final avg = s.rating.average;
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        avg == null ? CommonStrings.dash : formatRating(avg),
                        style: ValText.display(52),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: StarRow(value: avg ?? 0, size: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CommunityStrings.ratingCount(
                        formatNumber(s.rating.count),
                      ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: RatingDistribution(summary: s)),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: HeartButton(
              active: vote.voted,
              count: vote.votes,
              semanticsOff: CommunityStrings.vote,
              semanticsOn: CommunityStrings.unvote,
              onTap: p == null
                  ? null
                  : () => unawaited(
                      toggleSkinVote(
                        context,
                        ref,
                        puuid: p,
                        vote: vote,
                        weaponUuid: weaponUuid,
                      ),
                    ),
            ),
          ),
        ],
      );
    }
    return ValCard(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: child,
    );
  }
}

class _MyReviewCard extends ConsumerWidget {
  const _MyReviewCard({
    required this.summary,
    required this.loading,
    required this.puuid,
    required this.skinUuid,
    required this.weaponUuid,
  });

  final SkinSummary? summary;
  final bool loading;
  final String? puuid;
  final String skinUuid;
  final String? weaponUuid;

  Future<void> _edit(BuildContext context, {int rating = 0}) async {
    final p = puuid;
    if (p == null) return;
    final account = ProviderScope.containerOf(context).read(accountProvider(p));
    if (account != null &&
        !await ensureCommunityConsent(context, account, askAgain: true)) {
      return;
    }
    if (!context.mounted) return;
    final mine = summary?.myReview;
    final saved = await showReviewEditor(
      context,
      puuid: p,
      skinUuid: skinUuid,
      weaponUuid: weaponUuid,
      initialRating: rating > 0 ? rating : (mine?.rating ?? 0),
      initialBody: mine?.body ?? '',
    );
    if (saved && context.mounted) _snack(context, CommunityStrings.reviewSaved);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final p = puuid;
    final mine = summary?.myReview;
    Widget body;
    if (p == null) {
      body = Text(
        CommunityStrings.signInToReview,
        style: theme.textTheme.bodyMedium?.copyWith(color: muted),
      );
    } else if (loading) {
      body = const Skeleton(height: 44);
    } else if (mine == null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CommunityStrings.tapToRate,
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: StarRatingInput(
              value: 0,
              onChanged: (v) => unawaited(_edit(context, rating: v)),
            ),
          ),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StarRow(value: mine.rating.toDouble(), size: 20),
              Text(
                CommunityStrings.ratingWords[mine.rating - 1],
                style: theme.textTheme.labelLarge?.copyWith(
                  color: starColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (mine.body.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(mine.body, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: () => unawaited(_edit(context)),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text(CommunityStrings.editReview),
              ),
              TextButton.icon(
                onPressed: () =>
                    unawaited(confirmDeleteReview(context, ref, p, skinUuid)),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text(CommunityStrings.deleteReview),
              ),
            ],
          ),
        ],
      );
    }
    return ValCard(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      borderColor: mine != null ? ValColors.red.withValues(alpha: 0.4) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CommunityStrings.yourReview.toUpperCase(),
            style: ValText.label.copyWith(color: muted),
          ),
          const SizedBox(height: 10),
          body,
        ],
      ),
    );
  }
}

/// One review: author row, stars, text and "Hữu ích".
class ReviewTile extends ConsumerWidget {
  const ReviewTile({
    super.key,
    required this.review,
    required this.isMine,
    required this.onHelpful,
    required this.onAction,
  });

  final SkinReview review;
  final bool isMine;

  /// `null` hides the action (own review / signed out).
  final VoidCallback? onHelpful;
  final ValueChanged<ContentAction> onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final accent = review.liked ? ValColors.red : muted;
    return ValCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthorRow(
            author: review.author,
            createdAt: review.updatedAt ?? review.createdAt,
            isMe: isMine,
            avatarSize: 36,
            trailing: ContentMenuButton(
              author: review.author,
              isMine: isMine,
              deleteLabel: CommunityStrings.deleteReview,
              onSelected: onAction,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StarRow(value: review.rating.toDouble(), size: 16),
              if (review.edited)
                Text(
                  CommunityStrings.edited,
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
            ],
          ),
          if (review.body.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 10),
              child: TranslatableText(
                review.body,
                language: review.language ?? review.author.language,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
          if (onHelpful != null || review.likes > 0)
            TextButton.icon(
              onPressed: onHelpful == null
                  ? null
                  : () {
                      Haptics.light();
                      onHelpful!();
                    },
              style: TextButton.styleFrom(
                foregroundColor: accent,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: Icon(
                review.liked
                    ? Icons.thumb_up_alt_rounded
                    : Icons.thumb_up_alt_outlined,
                size: 18,
              ),
              label: Text(
                review.likes > 0
                    ? CommunityStrings.helpfulCount(formatNumber(review.likes))
                    : CommunityStrings.helpful,
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Skeleton matching [ReviewTile].
class ReviewTileSkeleton extends StatelessWidget {
  const ReviewTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(ValRadius.card),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Skeleton(width: 36, height: 36, radius: 18, shimmer: false),
              SizedBox(width: 12),
              Skeleton(width: 140, height: 14, shimmer: false),
            ],
          ),
          SizedBox(height: 10),
          Skeleton(width: 90, height: 14, shimmer: false),
          SizedBox(height: 8),
          Skeleton(height: 12, shimmer: false),
        ],
      ),
    );
  }
}
