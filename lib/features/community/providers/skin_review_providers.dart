import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accounts/account_providers.dart';
import '../data/community_api.dart';
import '../data/community_models.dart';
import 'community_providers.dart';

/// Key of [skinSummaryProvider] (`puuid` = viewer, `null` when signed out).
typedef SkinKey = ({String? puuid, String skinUuid});

/// Rating summary + the viewer's own review of one skin.
final skinSummaryProvider = AsyncNotifierProvider.autoDispose
    .family<SkinSummaryNotifier, SkinSummary, SkinKey>(SkinSummaryNotifier.new);

class SkinSummaryNotifier extends AsyncNotifier<SkinSummary> {
  SkinSummaryNotifier(this.key);

  final SkinKey key;

  @override
  Future<SkinSummary> build() {
    final puuid = key.puuid;
    if (puuid != null) {
      ref.watch(accountProvider(puuid).select((a) => a?.needsLogin));
    }
    return ref
        .watch(communityApiProvider)
        .skinSummary(key.skinUuid, puuid: puuid);
  }

  /// Refetches, keeping the current summary on screen.
  Future<void> refresh() async {
    ref.invalidateSelf();
    try {
      await future;
    } on Object {
      // Shown through `state`.
    }
  }

  /// Shows [review] as the viewer's review right away.
  void setMyReview(SkinReview? review) {
    final s = state.value;
    if (s != null) state = AsyncData(s.withMyReview(review));
  }
}

/// Key of [skinReviewsProvider].
typedef ReviewsKey = ({String? puuid, String skinUuid, ReviewSort sort});

/// Reviews of one skin (paged; newest or most helpful first).
final skinReviewsProvider = AsyncNotifierProvider.autoDispose
    .family<SkinReviewsNotifier, PagedState<SkinReview>, ReviewsKey>(
      SkinReviewsNotifier.new,
    );

class SkinReviewsNotifier extends AsyncNotifier<PagedState<SkinReview>>
    with PagedLoader<SkinReview> {
  SkinReviewsNotifier(this.key);

  final ReviewsKey key;

  final Set<String> _liking = {};

  CommunityApi get _api => ref.read(communityApiProvider);

  @override
  Future<PagedState<SkinReview>> build() async => PagedState.fromPage(
    await ref
        .watch(communityApiProvider)
        .skinReviews(key.skinUuid, puuid: key.puuid, sort: key.sort),
  );

  @override
  Future<CommunityPage<SkinReview>> fetchPage(String? cursor) =>
      _api.skinReviews(
        key.skinUuid,
        puuid: key.puuid,
        sort: key.sort,
        cursor: cursor,
      );

  @override
  String idOf(SkinReview item) => item.id;

  /// Optimistic "Hữu ích" toggle; reverts and rethrows on failure.
  Future<void> toggleLike(String reviewId) async {
    final puuid = key.puuid;
    final review = state.value?.items
        .where((r) => r.id == reviewId)
        .firstOrNull;
    if (puuid == null || review == null || !_liking.add(reviewId)) return;
    final optimistic = review.toggledLike();
    replace(optimistic);
    try {
      final r = await _api.setReviewLiked(
        puuid,
        reviewId,
        liked: optimistic.liked,
      );
      if (ref.mounted) {
        replace(optimistic.copyWith(likes: r.likes, liked: r.liked));
      }
    } on Object {
      if (ref.mounted) replace(review);
      rethrow;
    } finally {
      _liking.remove(reviewId);
    }
  }
}

/// Why a review cannot be sent yet.
enum ReviewProblem { noRating, tooLong }

/// Validation of the review editor (pure, unit-tested).
ReviewProblem? validateReview({required int rating, required String body}) {
  if (rating < 1 || rating > 5) return ReviewProblem.noRating;
  if (body.trim().runes.length > kMaxReviewLength) {
    return ReviewProblem.tooLong;
  }
  return null;
}

void _refreshLists(WidgetRef ref, String? puuid, String skinUuid) {
  for (final sort in ReviewSort.values) {
    final p = skinReviewsProvider((
      puuid: puuid,
      skinUuid: skinUuid,
      sort: sort,
    ));
    if (ref.exists(p)) ref.invalidate(p);
  }
  final summary = skinSummaryProvider((puuid: puuid, skinUuid: skinUuid));
  if (ref.exists(summary)) ref.invalidate(summary);
}

/// Creates or replaces the viewer's review, then refreshes the page.
Future<SkinReview> submitSkinReview(
  WidgetRef ref, {
  required String puuid,
  required String skinUuid,
  required int rating,
  String body = '',
  String? weaponUuid,
}) async {
  final review = await ref
      .read(communityApiProvider)
      .putReview(
        puuid,
        skinUuid,
        rating: rating,
        body: body,
        weaponUuid: weaponUuid,
      );
  final id = skinUuid.toLowerCase();
  final summary = skinSummaryProvider((puuid: puuid, skinUuid: id));
  if (ref.exists(summary)) ref.read(summary.notifier).setMyReview(review);
  _refreshLists(ref, puuid, id);
  return review;
}

/// Deletes the viewer's review of [skinUuid], then refreshes the page.
Future<void> deleteOwnSkinReview(
  WidgetRef ref, {
  required String puuid,
  required String skinUuid,
}) async {
  await ref.read(communityApiProvider).deleteMyReview(puuid, skinUuid);
  final id = skinUuid.toLowerCase();
  final summary = skinSummaryProvider((puuid: puuid, skinUuid: id));
  if (ref.exists(summary)) ref.read(summary.notifier).setMyReview(null);
  _refreshLists(ref, puuid, id);
}
