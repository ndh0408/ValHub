import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accounts/account_providers.dart';
import '../data/community_api.dart';
import '../data/community_models.dart';
import 'community_providers.dart';

/// The feed of the signed-in account ([puuid] = whose session is used).
final feedProvider = AsyncNotifierProvider.autoDispose
    .family<FeedNotifier, PagedState<CommunityPost>, String>(FeedNotifier.new);

class FeedNotifier extends AsyncNotifier<PagedState<CommunityPost>>
    with PagedLoader<CommunityPost> {
  FeedNotifier(this.puuid);

  final String puuid;

  CommunityApi get _api => ref.read(communityApiProvider);

  final Set<String> _liking = {};

  @override
  Future<PagedState<CommunityPost>> build() async {
    ref.watch(accountProvider(puuid).select((a) => a?.needsLogin));
    final api = ref.watch(communityApiProvider);
    return PagedState.fromPage(await api.posts(puuid));
  }

  @override
  Future<CommunityPage<CommunityPost>> fetchPage(String? cursor) =>
      _api.posts(puuid, cursor: cursor);

  @override
  String idOf(CommunityPost item) => item.id;

  /// Optimistic like / unlike. Reverts and rethrows on failure. Taps while
  /// the previous toggle of the same post is in flight are ignored.
  Future<void> toggleLike(String postId) async {
    final post = state.value?.items.where((p) => p.id == postId).firstOrNull;
    if (post == null || !_liking.add(postId)) return;
    final optimistic = post.toggledLike();
    replace(optimistic);
    try {
      final r = await _api.setLiked(puuid, postId, liked: optimistic.liked);
      if (ref.mounted) {
        replace(optimistic.copyWith(likes: r.likes, liked: r.liked));
      }
    } on Object {
      if (ref.mounted) replace(post);
      rethrow;
    } finally {
      _liking.remove(postId);
    }
  }

  /// Deletes an own post.
  Future<void> delete(String postId) async {
    await _api.deletePost(puuid, postId);
    if (ref.mounted) removeLocal(postId);
  }
}

/// Key of the post-detail providers.
typedef PostKey = ({String puuid, String postId});

/// One post (detail screen), refreshed from the server.
final postDetailProvider = AsyncNotifierProvider.autoDispose
    .family<PostDetailNotifier, CommunityPost, PostKey>(PostDetailNotifier.new);

class PostDetailNotifier extends AsyncNotifier<CommunityPost> {
  PostDetailNotifier(this.key);

  final PostKey key;

  bool _liking = false;

  CommunityApi get _api => ref.read(communityApiProvider);

  @override
  Future<CommunityPost> build() =>
      ref.watch(communityApiProvider).post(key.puuid, key.postId);

  /// Pushes [post] to this screen and to the feed (when it is alive).
  void apply(CommunityPost post) {
    if (ref.mounted) state = AsyncData(post);
    syncFeed(ref, key.puuid, post);
  }

  /// Optimistic like / unlike; [fallback] is the post shown while the
  /// detail is still loading.
  Future<void> toggleLike(CommunityPost fallback) async {
    final post = state.value ?? fallback;
    if (_liking) return;
    _liking = true;
    final optimistic = post.toggledLike();
    apply(optimistic);
    try {
      final r = await _api.setLiked(
        key.puuid,
        post.id,
        liked: optimistic.liked,
      );
      apply(optimistic.copyWith(likes: r.likes, liked: r.liked));
    } on Object {
      apply(post);
      rethrow;
    } finally {
      _liking = false;
    }
  }

  /// Comment count changed by [delta] (after add / delete).
  void bumpComments(CommunityPost fallback, int delta) {
    final post = state.value ?? fallback;
    final n = post.comments + delta;
    apply(post.copyWith(comments: n < 0 ? 0 : n));
  }

  /// Deletes this (own) post and drops it from the feed.
  Future<void> delete() async {
    await _api.deletePost(key.puuid, key.postId);
    final feed = feedProvider(key.puuid);
    if (ref.exists(feed)) ref.read(feed.notifier).removeLocal(key.postId);
  }
}

/// Updates [post] in the feed of [puuid] if the feed is alive.
void syncFeed(Ref ref, String puuid, CommunityPost post) {
  final feed = feedProvider(puuid);
  if (ref.exists(feed)) ref.read(feed.notifier).replace(post);
}

/// Comments of one post (oldest first).
final commentsProvider = AsyncNotifierProvider.autoDispose
    .family<CommentsNotifier, PagedState<CommunityComment>, PostKey>(
      CommentsNotifier.new,
    );

class CommentsNotifier extends AsyncNotifier<PagedState<CommunityComment>>
    with PagedLoader<CommunityComment> {
  CommentsNotifier(this.key);

  final PostKey key;

  CommunityApi get _api => ref.read(communityApiProvider);

  @override
  Future<PagedState<CommunityComment>> build() async => PagedState.fromPage(
    await ref.watch(communityApiProvider).comments(key.puuid, key.postId),
  );

  @override
  Future<CommunityPage<CommunityComment>> fetchPage(String? cursor) =>
      _api.comments(key.puuid, key.postId, cursor: cursor);

  @override
  String idOf(CommunityComment item) => item.id;

  /// Posts a comment and appends it.
  Future<CommunityComment> add(String body) async {
    final comment = await _api.addComment(key.puuid, key.postId, body);
    final s = state.value;
    if (ref.mounted && s != null) {
      state = AsyncData(
        s.copyWith(
          items: [...s.items.where((c) => c.id != comment.id), comment],
        ),
      );
    }
    return comment;
  }

  /// Deletes an own comment.
  Future<void> delete(String commentId) async {
    await _api.deleteComment(key.puuid, commentId);
    if (ref.mounted) removeLocal(commentId);
  }
}

/// Creates a post: uploads the images first (in order), then the post.
Future<CommunityPost> publishPost(
  CommunityApi api,
  String puuid, {
  required PostKind kind,
  required String body,
  List<Future<PostMedia> Function()> uploads = const [],
  PostPayload? payload,
}) async {
  final media = <String>[];
  for (final upload in uploads) {
    media.add((await upload()).key);
  }
  return api.createPost(
    puuid,
    kind: kind,
    body: body,
    media: media,
    payload: payload,
  );
}

/// Adds a freshly created [post] to the top of the feed (when alive).
void prependToFeed(WidgetRef ref, String puuid, CommunityPost post) {
  final feed = feedProvider(puuid);
  if (ref.exists(feed)) ref.read(feed.notifier).prepend(post);
}
