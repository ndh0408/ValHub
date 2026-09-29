import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/competitive_strings.dart';
import '../../../core/storage/ui_memory.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/async_value_view.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/filter_bar.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/clock.dart';
import '../../../core/xmpp/friends.dart';
import '../../../core/xmpp/xmpp_providers.dart';
import '../data/friend_sections.dart';
import '../data/friend_status.dart';
import '../social_routes.dart';
import '../social_strings.dart';
import 'widgets/friend_tile.dart';
import 'widgets/social_widgets.dart';

/// S60 "Bạn bè & trò chuyện". Route `/profile/friends`.
///
/// Riot friends (XMPP roster + presence) in "Đang chơi (n)" /
/// "Trực tuyến (n)" / "Ngoại tuyến (n)" cards, searchable by Riot ID
/// (without diacritics), with a remembered quick filter (Tất cả / Trực
/// tuyến / Chưa đọc) and unread badges.
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  static const _filterKey = 'social.friends.filter';

  final _search = TextEditingController();
  String _query = '';
  late FriendsFilter _filter = ref
      .read(uiMemoryProvider)
      .readEnum(_filterKey, FriendsFilter.values, FriendsFilter.all);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.read(xmppServiceProvider)?.refresh();
  }

  void _retry() {
    final service = ref.read(xmppServiceProvider);
    if (service != null) unawaited(service.retryNow());
  }

  void _setFilter(FriendsFilter f) {
    setState(() => _filter = f);
    ref.read(uiMemoryProvider).writeEnum(_filterKey, f);
  }

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendsProvider);
    final puuid = ref.watch(activePuuidProvider);
    final unread = friends.value?.totalUnread ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text(SocialStrings.friendsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: GlassSearchField(
              controller: _search,
              hintText: SocialStrings.searchHint,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 52,
            child: FilterChipBar(
              children: [
                for (final f in FriendsFilter.values)
                  ValFilterChip(
                    label: switch (f) {
                      FriendsFilter.all => SocialStrings.filterAll,
                      FriendsFilter.online => SocialStrings.filterOnline,
                      FriendsFilter.unread =>
                        unread > 0
                            ? '${SocialStrings.filterUnread} '
                                  '(${SocialStrings.unreadBadge(unread)})'
                            : SocialStrings.filterUnread,
                    },
                    // Compact: the three chips fit a 360 dp phone.
                    dotColor: f == FriendsFilter.online
                        ? valColorsOf(context).win
                        : null,
                    selected: _filter == f,
                    onSelected: (_) => _setFilter(f),
                  ),
              ],
            ),
          ),
          if (friends.value case final view?)
            ConnectionBanner(state: view.connection, onRetry: _retry),
          Expanded(
            child: AsyncValueView<FriendsView>(
              value: friends,
              puuid: puuid,
              onRetry: _retry,
              loading: const _FriendsSkeleton(),
              isEmpty: (v) => v.isEmpty,
              empty: AdaptiveRefresh(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    EmptyView(
                      title: SocialStrings.noFriendsTitle,
                      message: SocialStrings.noFriends,
                      icon: Icons.group_outlined,
                    ),
                  ],
                ),
              ),
              data: (view) => AdaptiveRefresh(
                onRefresh: _refresh,
                child: _FriendsList(
                  view: view.filter(_query),
                  filter: _filter,
                  searching: _query.trim().isNotEmpty,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendsList extends ConsumerWidget {
  const _FriendsList({
    required this.view,
    required this.filter,
    required this.searching,
  });

  final FriendsView view;
  final FriendsFilter filter;
  final bool searching;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final now = ref.watch(clockProvider).now();
    final sections = friendSections(view, filter: filter);
    if (sections.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyView(
            message: searching || view.isEmpty
                ? SocialStrings.noSearchResults
                : SocialStrings.noFilterResults,
            icon: searching
                ? Icons.search_off_outlined
                : Icons.filter_alt_off_outlined,
          ),
        ],
      );
    }

    Widget tile(Friend f) => FriendTile(
      key: ValueKey(f.puuid),
      friend: f,
      status: friendStatus(f, db: db, now: now),
      unknownName: CompetitiveStrings.unknownPlayer,
      onTap: () => unawaited(context.push(SocialRoutes.chat(f.puuid))),
    );

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        for (final section in sections) ...[
          SliverToBoxAdapter(
            child: SectionLabel(switch (section.kind) {
              FriendSectionKind.playing => SocialStrings.playingSection(
                section.friends.length,
              ),
              FriendSectionKind.online => SocialStrings.onlineSection(
                section.friends.length,
              ),
              FriendSectionKind.offline => SocialStrings.offlineSection(
                section.friends.length,
              ),
            }, padding: const EdgeInsets.fromLTRB(20, 16, 20, 8)),
          ),
          SliverToBoxAdapter(
            child: GroupedSection(
              children: [for (final f in section.friends) tile(f)],
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _FriendsSkeleton extends StatelessWidget {
  const _FriendsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          const Skeleton(width: 120, height: 18, shimmer: false),
          const SizedBox(height: 12),
          for (var i = 0; i < 8; i++)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Skeleton(width: 44, height: 44, radius: 10, shimmer: false),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(width: 150, height: 14, shimmer: false),
                        SizedBox(height: 8),
                        Skeleton(width: 110, height: 12, shimmer: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
