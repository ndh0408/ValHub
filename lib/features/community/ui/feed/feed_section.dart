import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../community_routes.dart';
import '../../community_strings.dart';
import '../../data/community_api.dart';
import '../../data/community_models.dart';
import '../../providers/community_providers.dart';
import '../../providers/feed_providers.dart';
import '../widgets/community_widgets.dart';
import 'post_card.dart';
import 'report_sheet.dart';

/// "Bảng tin": infinite list of posts (a sliver for the tab scroll view).
class FeedSliver extends ConsumerWidget {
  const FeedSliver({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = feedProvider(puuid);
    final async = ref.watch(provider);
    final meId = ref.watch(communityMeProvider(puuid)).value?.id;

    if (!async.hasValue) {
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
    final items = state.items;
    final staleError = async.hasError && !async.isLoading ? async.error : null;
    if (items.isEmpty) {
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
              title: CommunityStrings.feedEmptyTitle,
              message: CommunityStrings.feedEmptyBody,
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
    try {
      await notifier.toggleLike(postId);
    } on Object catch (e) {
      if (context.mounted) showCommunityError(context, e);
    }
  }
}

/// Opens the composer (optionally prefilled) above the tab bar.
Future<void> openComposer(BuildContext context, {Object? draft}) =>
    context.push(CommunityRoutes.compose, extra: draft);

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
  switch (action) {
    case ContentAction.delete:
      final ok = await confirmCommunityAction(
        context,
        title: CommunityStrings.deletePostTitle,
        body: CommunityStrings.deletePostBody,
        confirmLabel: CommunityStrings.delete,
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
              const SnackBar(content: Text(CommunityStrings.deleted)),
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
