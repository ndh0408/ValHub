import '../providers/hidden_authors.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/format.dart';
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
import 'widgets/comment_tile.dart';

import 'package:valvn/core/l10n/l10n.dart';

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
  late final String? _initialOwner = ref.read(activePuuidProvider);

  @override
  Widget build(BuildContext context) {
    final puuid = ref.watch(activePuuidProvider);
    return _PostAccountScreen(
      key: ValueKey((puuid, widget.postId)),
      postId: widget.postId,
      initial: puuid == _initialOwner ? widget.initial : null,
    );
  }
}

class _PostAccountScreen extends ConsumerStatefulWidget {
  const _PostAccountScreen({super.key, required this.postId, this.initial});

  final String postId;
  final CommunityPost? initial;

  @override
  ConsumerState<_PostAccountScreen> createState() => _PostAccountScreenState();
}

class _PostAccountScreenState extends ConsumerState<_PostAccountScreen> {
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
      appBar: AppBar(title: Text(context.l10n.communityPostTitle)),
      body: account == null
          ? EmptyView(
              message: context.l10n.commonErrorNoAccount,
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
            ? CommunityEmptyState(
                icon: Icons.delete_sweep_outlined,
                title: context.l10n.communityPostGoneTitle,
                message: context.l10n.communityPostNotFound,
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
      return Center(child: Text(context.l10n.communityHiddenAuthorsHint));
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
                    context.l10n.communityCommentsHeader(
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
              context.l10n.communityNoComments,
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
          return CommunityCommentTile(
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
          padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 8, 8),
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
                    hintText: context.l10n.communityCommentHint,
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
                        ? context.l10n.communityTooLong(_maxComment)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                tooltip: context.l10n.communitySendComment,
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
    if (!mounted || _sending) return;
    // Commenting needs a session: ask to join first, then continue.
    if (!await promptConsentFromContext(context) || !mounted) return;
    if (ref.read(activePuuidProvider) != key.puuid) return;
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
    final messages = context.l10n;
    switch (action) {
      case ContentAction.delete:
        final ok = await confirmCommunityAction(
          context,
          title: messages.communityDeleteCommentTitle,
          body: messages.communityDeleteCommentBody,
          confirmLabel: messages.communityDelete,
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
