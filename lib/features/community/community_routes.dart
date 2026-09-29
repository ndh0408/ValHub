import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'data/community_models.dart';
import 'data/compose_draft.dart';
import 'ui/community_screen.dart';
import 'ui/compose_screen.dart';
import 'ui/post_detail_screen.dart';
import 'ui/skins/skin_review_screen.dart';

/// Locations of the "Cộng đồng" feature.
abstract final class CommunityRoutes {
  /// Tab root: `/community[?section=feed|lfg|skins]`.
  static const root = '/community';

  /// Full-screen composer (above the tab bar); `extra`: [ComposeDraft].
  static const compose = '/compose';

  /// Full-screen post detail; `extra`: the [CommunityPost] already shown.
  static String post(String id) => '/post/${Uri.encodeComponent(id)}';

  static String section(CommunitySection s) => '$root?section=${s.query}';

  /// Full-screen skin review page (openable from anywhere).
  static String skin(String skinUuid) =>
      '$root/skin/${Uri.encodeComponent(skinUuid.toLowerCase())}';
}

/// Branch routes of the community tab.
List<RouteBase> get communityBranchRoutes => [
  GoRoute(
    path: CommunityRoutes.root,
    builder: (context, state) => CommunityScreen(
      initialSection: CommunitySection.tryParse(
        state.uri.queryParameters['section'],
      ),
    ),
  ),
];

/// Top-level (full-screen) routes: composer, post detail, skin reviews.
List<RouteBase> get communityTopLevelRoutes => [
  GoRoute(
    path: '/community/skin/:uuid',
    builder: (context, state) =>
        SkinReviewScreen(skinUuid: state.pathParameters['uuid'] ?? ''),
  ),
  GoRoute(
    path: CommunityRoutes.compose,
    builder: (context, state) {
      final extra = state.extra;
      return ComposeScreen(draft: extra is ComposeDraft ? extra : null);
    },
  ),
  GoRoute(
    path: '/post/:id',
    builder: (context, state) {
      final extra = state.extra;
      return PostDetailScreen(
        postId: state.pathParameters['id'] ?? '',
        initial: extra is CommunityPost ? extra : null,
      );
    },
  ),
];

/// Opens the review page of [skinUuid] (no-op without a router).
Future<void> openSkinReview(BuildContext context, String skinUuid) async {
  final router = GoRouter.maybeOf(context);
  if (router == null) return;
  await router.push<void>(CommunityRoutes.skin(skinUuid));
}
