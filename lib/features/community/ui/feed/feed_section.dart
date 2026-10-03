import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/accounts/account_providers.dart';
import '../../community_routes.dart';
import '../../data/community_api.dart';
import '../../data/community_models.dart';
import '../../providers/community_providers.dart';
import '../../providers/consent_providers.dart';
import '../../providers/feed_providers.dart';
import '../../providers/hidden_authors.dart';
import '../../providers/scope_providers.dart';
import '../consent/consent_sheet.dart';
import '../scope/scope_bar.dart';
import '../widgets/community_widgets.dart';
import 'post_card.dart';
import 'report_sheet.dart';

/// "Bảng tin": infinite list of posts (a sliver for the tab scroll view).
class FeedSliver extends ConsumerWidget {
  const FeedSliver({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The scope the server applied to the list on screen (not to stale
    // items of the scope just left).
    final scope = ref
        .watch(
          resolvedScopeProvider((puuid: puuid, section: ScopedSection.feed)),
        )
        .value;
    final loaded = ref.watch(feedProvider(puuid)).value;
    final applied = loaded != null && scope != null && loaded.tag == scope
        ? loaded.applied
        : null;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: ScopeBar(
            section: ScopedSection.feed,
            puuid: puuid,
            applied: applied,
          ),
        ),
        _content(context, ref),
      ],
    );
  }

  Widget _content(BuildContext context, WidgetRef ref) {
    final provider = feedProvider(puuid);
    final async = ref.watch(provider);
    final meId = ref.watch(communityMeProvider(puuid)).value?.id;
    final scope = ref
        .watch(
          resolvedScopeProvider((puuid: puuid, section: ScopedSection.feed)),
        )
        .value;
    // Items of another scope (right after switching) are never shown.
    final stale =
        async.hasValue && scope != null && async.requireValue.tag != scope;

    if (!async.hasValue || stale) {
      if (async.hasError && !async.isLoading) {
        return SliverToBoxAdapter(
          child: CommunityErrorState(
            error: async.error!,
            puuid: puuid,
            onRetry: () => ref.invalidate(provider),
          ),
        );
      }
      return SliverToBoxAdapter(
        child: SkeletonColumn(
          item: (i) => PostCardSkeleton(withMedia: i.isEven),
        ),
      );
    }

    final state = async.requireValue;
    final hidden = ref.watch(hiddenAuthorsProvider(puuid));
    final items = state.items
        .where((p) => !hidden.containsKey(p.author.id))
        .toList();
    final staleError = async.hasError && !async.isLoading ? async.error : null;
    if (items.isEmpty) {
      final isGlobal =
          (state.applied?.scope ?? scope?.scope) == CommunityScope.global;
      final joined =
          ref.watch(communityConsentProvider(puuid)) ==
          CommunityConsent.granted;
      final hasLanguageFilter =
          isGlobal &&
          scope?.scope == CommunityScope.global &&
          (scope?.languages.isNotEmpty ?? false);
      final l10n = context.l10n;
      return SliverToBoxAdapter(
        child: Column(
          children: [
            if (staleError != null)
              CommunityErrorState(
                error: staleError,
                compact: true,
                onRetry: () => ref.invalidate(provider),
              ),
            CommunityEmptyState(
              icon: Icons.forum_outlined,
              title: isGlobal
                  ? l10n.communityFeedEmptyTitle
                  : l10n.communityFeedEmptyScopeTitle,
              message: hasLanguageFilter
                  ? l10n.communityFeedEmptyFilteredBody
                  : !isGlobal
                  ? l10n.communityFeedEmptyScopeBody
                  : joined
                  ? l10n.communityFeedEmptyBody
                  : l10n.communityFeedEmptyGuestBody,
              action: isGlobal
                  ? null
                  : OutlinedButton.icon(
                      key: const ValueKey('feed-empty-global'),
                      icon: const Icon(Icons.public_rounded),
                      label: Text(context.l10n.communityScopeGlobal),
                      onPressed: () {
                        final filters = ref.read(
                          communityScopeProvider(ScopedSection.feed),
                        );
                        ref
                            .read(
                              communityScopeProvider(ScopedSection.feed)
                                  .notifier,
                            )
                            .set(
                              filters.copyWith(scope: CommunityScope.global),
                            );
                      },
                    ),
            ),
          ],
        ),
      );
    }

    final notifier = ref.read(provider.notifier);
    final lead = staleError == null ? 0 : 1;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      sliver: SliverList.builder(
        itemCount: lead + items.length + 1,
        itemBuilder: (context, index) {
          if (index < lead) {
            return CommunityErrorState(
              error: staleError!,
              compact: true,
              onRetry: () => unawaited(notifier.refresh()),
            );
          }
          final i = index - lead;
          if (i == items.length) {
            return PagedFooter(
              hasMore: state.hasMore,
              loading: state.loadingMore,
              error: state.loadMoreError,
              onLoadMore: () => unawaited(notifier.loadMore()),
            );
          }
          final post = items[i];
          return Padding(
            key: ValueKey(post.id),
            padding: const EdgeInsets.only(bottom: 12),
            child: PostCard(
              post: post,
              isMine: meId != null && post.author.id == meId,
              onOpen: () => unawaited(
                context.push(CommunityRoutes.post(post.id), extra: post),
              ),
              onLike: () => unawaited(_like(context, notifier, post.id)),
              onAction: (a) => unawaited(
                handlePostAction(context, ref, puuid: puuid, post: post, a),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _like(
    BuildContext context,
    FeedNotifier notifier,
    String postId,
  ) async {
    // Liking needs a session: ask to join first, then continue.
    if (!await promptConsentFromContext(context) || !context.mounted) return;
    try {
      await notifier.toggleLike(postId);
    } on Object catch (e) {
      if (context.mounted) showCommunityError(context, e);
    }
  }
}

/// Opens the composer (optionally prefilled) above the tab bar.
/// Opens the composer; writing needs a session, so the consent sheet comes
/// first for a reader who has not joined (declined = nothing opens).
Future<void> openComposer(BuildContext context, {Object? draft}) async {
  final container = ProviderScope.containerOf(context);
  final puuid = container.read(activePuuidProvider);
  if (!await promptConsentFromContext(context) || !context.mounted) return;
  if (container.read(activePuuidProvider) != puuid) return;
  await context.push<void>(CommunityRoutes.compose, extra: draft);
}

/// Delete (own, after a confirmation) or report a post. Returns whether the
/// post was deleted.
Future<bool> handlePostAction(
  BuildContext context,
  WidgetRef ref,
  ContentAction action, {
  required String puuid,
  required CommunityPost post,
  Future<void> Function()? delete,
}) async {
  final l10nBeforeAwait = context.l10n;

  switch (action) {
    case ContentAction.delete:
      final ok = await confirmCommunityAction(
        context,
        title: l10nBeforeAwait.communityDeletePostTitle,
        body: l10nBeforeAwait.communityDeletePostBody,
        confirmLabel: l10nBeforeAwait.communityDelete,
      );
      if (!ok || !context.mounted) return false;
      try {
        if (delete != null) {
          await delete();
        } else {
          await ref.read(feedProvider(puuid).notifier).delete(post.id);
        }
        if (context.mounted) {
          ScaffoldMessenger.maybeOf(context)
            ?..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(l10nBeforeAwait.communityDeleted)),
            );
        }
        return true;
      } on Object catch (e) {
        if (context.mounted) showCommunityError(context, e);
        return false;
      }
    case ContentAction.report:
      await reportContent(
        context,
        ref,
        puuid: puuid,
        targetType: ReportTarget.post,
        targetId: post.id,
      );
      return false;
  }
}
