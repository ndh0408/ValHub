import '../providers/hidden_authors.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/format.dart';
import '../community_strings.dart';
import '../data/community_api.dart';
import '../data/community_exception.dart';
import '../data/community_models.dart';
import '../providers/community_providers.dart';
import '../providers/feed_providers.dart';
import 'consent/consent_sheet.dart';
import 'feed/feed_section.dart';
import 'feed/post_card.dart';
import 'feed/report_sheet.dart';
import 'widgets/community_widgets.dart';
import 'widgets/translatable_text.dart';

/// Post detail: the full post, its comments (paged, oldest first) and a
/// comment composer that stays above the keyboard.
class PostDetailScreen extends ConsumerStatefulWidget {
  const PostDetailScreen({super.key, required this.postId, this.initial});

  final String postId;

  /// The post as shown in the feed (rendered while the detail loads).
  final CommunityPost? initial;

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _comment = TextEditingController();
  final _focus = FocusNode();
  bool _sending = false;

  static const _maxComment = 500;

  @override
  void initState() {
    super.initState();
    _comment.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _comment.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(activeAccountProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(CommunityStrings.postTitle)),
      body: account == null
          ? const EmptyView(
              message: CommonStrings.errorNoAccount,
              icon: Icons.person_off_outlined,
            )
          : _body(account.puuid),
    );
  }

  Widget _body(String puuid) {
    final key = (puuid: puuid, postId: widget.postId);
    final postAsync = ref.watch(postDetailProvider(key));
    final post = postAsync.value ?? widget.initial;
    final meId = ref.watch(communityMeProvider(puuid)).value?.id;

    if (post == null) {
      if (postAsync.hasError && !postAsync.isLoading) {
        final e = postAsync.error!;
        final gone =
            e is CommunityException && e.code == CommunityException.notFound;
        return gone
            ? const CommunityEmptyState(
                icon: Icons.delete_sweep_outlined,
                title: CommunityStrings.errorTitle,
                message: CommunityStrings.postNotFound,
              )
            : Center(
                child: CommunityErrorState(
                  error: e,
                  puuid: puuid,
                  onRetry: () => ref.invalidate(postDetailProvider(key)),
                ),
              );
      }
      return SkeletonColumn(item: (_) => const PostCardSkeleton(), count: 1);
    }

    if (ref.watch(hiddenAuthorsProvider(puuid)).containsKey(post.author.id)) {
      return const Center(child: Text(CommunityStrings.hiddenAuthorsHint));
    }
    final comments = ref.watch(commentsProvider(key));
    final notifier = ref.read(postDetailProvider(key).notifier);
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref
                ..invalidate(postDetailProvider(key))
                ..invalidate(commentsProvider(key));
              try {
                await ref.read(commentsProvider(key).future);
              } on Object {
                // Rendered below.
              }
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: PostCard(
                      post: post,
                      expanded: true,
                      isMine: meId != null && post.author.id == meId,
                      onLike: () => unawaited(_like(notifier, post)),
                      onAction: (a) => unawaited(_postAction(puuid, post, a)),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SectionLabel(
                    CommunityStrings.commentsHeader(
                      formatNumber(post.comments),
                    ),
                  ),
                ),
                ..._commentSlivers(puuid, key, comments, meId, post),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
        _composer(puuid, key, post),
      ],
    );
  }

  List<Widget> _commentSlivers(
    String puuid,
    PostKey key,
    AsyncValue<PagedState<CommunityComment>> async,
    String? meId,
    CommunityPost post,
  ) {
    if (!async.hasValue) {
      if (async.hasError && !async.isLoading) {
        return [
          SliverToBoxAdapter(
            child: CommunityErrorState(
              error: async.error!,
              puuid: puuid,
              compact: true,
              onRetry: () => ref.invalidate(commentsProvider(key)),
            ),
          ),
        ];
      }
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ];
    }
    final state = async.requireValue;
    if (state.items.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: Text(
              CommunityStrings.noComments,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ];
    }
    final notifier = ref.read(commentsProvider(key).notifier);
    final hidden = ref.watch(hiddenAuthorsProvider(puuid));
    final comments = state.items
        .where((c) => !hidden.containsKey(c.author.id))
        .toList();
    return [
      SliverList.builder(
        itemCount: comments.length + 1,
        itemBuilder: (context, i) {
          if (i == comments.length) {
            return PagedFooter(
              hasMore: state.hasMore,
              loading: state.loadingMore,
              error: state.loadMoreError,
              onLoadMore: () => unawaited(notifier.loadMore()),
            );
          }
          final c = comments[i];
          final mine = meId != null && c.author.id == meId;
          return _CommentTile(
            key: ValueKey(c.id),
            comment: c,
            isMine: mine,
            onAction: (a) => unawaited(_commentAction(puuid, key, c, a, post)),
          );
        },
      ),
    ];
  }

  Widget _composer(String puuid, PostKey key, CommunityPost post) {
    final theme = Theme.of(context);
    final text = _comment.text.trim();
    final tooLong = _comment.text.characters.length > _maxComment;
    final canSend = text.isNotEmpty && !tooLong && !_sending;
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _comment,
                  focusNode: _focus,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: CommunityStrings.commentHint,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: ValColors.red),
                    ),
                    errorText: tooLong
                        ? CommunityStrings.tooLong(_maxComment)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                tooltip: CommunityStrings.sendComment,
                onPressed: canSend ? () => unawaited(_send(key, post)) : null,
                style: IconButton.styleFrom(
                  backgroundColor: ValColors.red,
                  foregroundColor: Colors.white,
                ),
                icon: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _send(PostKey key, CommunityPost post) async {
    // Commenting needs a session: ask to join first, then continue.
    if (!await promptConsentFromContext(context) || !mounted) return;
    setState(() => _sending = true);
    try {
      await ref.read(commentsProvider(key).notifier).add(_comment.text);
      if (!mounted) return;
      _comment.clear();
      ref.read(postDetailProvider(key).notifier).bumpComments(post, 1);
    } on Object catch (e) {
      if (mounted) showCommunityError(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _like(PostDetailNotifier notifier, CommunityPost post) async {
    if (!await promptConsentFromContext(context) || !mounted) return;
    try {
      await notifier.toggleLike(post);
    } on Object catch (e) {
      if (mounted) showCommunityError(context, e);
    }
  }

  Future<void> _postAction(
    String puuid,
    CommunityPost post,
    ContentAction action,
  ) async {
    final key = (puuid: puuid, postId: widget.postId);
    final deleted = await handlePostAction(
      context,
      ref,
      action,
      puuid: puuid,
      post: post,
      delete: () => ref.read(postDetailProvider(key).notifier).delete(),
    );
    if (deleted && mounted) Navigator.of(context).maybePop();
  }

  Future<void> _commentAction(
    String puuid,
    PostKey key,
    CommunityComment c,
    ContentAction action,
    CommunityPost post,
  ) async {
    switch (action) {
      case ContentAction.delete:
        final ok = await confirmCommunityAction(
          context,
          title: CommunityStrings.deleteCommentTitle,
          body: CommunityStrings.deleteCommentBody,
          confirmLabel: CommunityStrings.delete,
        );
        if (!ok || !mounted) return;
        try {
          await ref.read(commentsProvider(key).notifier).delete(c.id);
          if (mounted) {
            ref.read(postDetailProvider(key).notifier).bumpComments(post, -1);
          }
        } on Object catch (e) {
          if (mounted) showCommunityError(context, e);
        }
      case ContentAction.report:
        await reportContent(
          context,
          ref,
          puuid: puuid,
          targetType: ReportTarget.comment,
          targetId: c.id,
        );
    }
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    super.key,
    required this.comment,
    required this.isMine,
    required this.onAction,
  });

  final CommunityComment comment;
  final bool isMine;
  final ValueChanged<ContentAction> onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthorRow(
            author: comment.author,
            createdAt: comment.createdAt,
            isMe: isMine,
            avatarSize: 32,
            trailing: ContentMenuButton(
              author: comment.author,
              isMine: isMine,
              deleteLabel: CommunityStrings.deleteComment,
              onSelected: onAction,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 44, right: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                  topLeft: Radius.circular(4),
                ),
              ),
              child: TranslatableText(
                comment.body,
                language: comment.language ?? comment.author.language,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
