import 'package:go_router/go_router.dart';

import 'data/community_models.dart';
import 'data/compose_draft.dart';
import 'ui/community_screen.dart';
import 'ui/compose_screen.dart';
import 'ui/post_detail_screen.dart';

/// Locations of the "Cộng đồng" feature.
abstract final class CommunityRoutes {
  /// Tab root: `/community[?section=feed|lfg|skins]`.
  static const root = '/community';

  /// Full-screen composer (above the tab bar); `extra`: [ComposeDraft].
  static const compose = '/compose';

  /// Full-screen post detail; `extra`: the [CommunityPost] already shown.
  static String post(String id) => '/post/${Uri.encodeComponent(id)}';

  static String section(CommunitySection s) => '$root?section=${s.query}';
}

/// Branch routes of the community tab.
List<RouteBase> get communityBranchRoutes => [
  GoRoute(
    path: CommunityRoutes.root,
    builder: (context, state) => CommunityScreen(
      initialSection: CommunitySection.parse(
        state.uri.queryParameters['section'],
      ),
    ),
  ),
];

/// Top-level (full-screen) routes: composer and post detail.
List<RouteBase> get communityTopLevelRoutes => [
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
