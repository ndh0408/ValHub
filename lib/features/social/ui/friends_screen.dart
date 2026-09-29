import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/competitive_strings.dart';
import '../../../core/ui/async_value_view.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/section_header.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/util/clock.dart';
import '../../../core/xmpp/friends.dart';
import '../../../core/xmpp/xmpp_providers.dart';
import '../data/friend_status.dart';
import '../social_routes.dart';
import '../social_strings.dart';
import 'widgets/friend_tile.dart';
import 'widgets/social_widgets.dart';

/// S60 "Bạn bè & trò chuyện". Route `/profile/friends`.
///
/// Riot friends (XMPP roster + presence) split into "Trực tuyến (n)" /
/// "Ngoại tuyến (n)", searchable by Riot ID, with unread badges.
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _search = TextEditingController();
  String _query = '';

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

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendsProvider);
    final puuid = ref.watch(activePuuidProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(SocialStrings.friendsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: SocialStrings.searchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: SocialStrings.clearSearch,
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
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
              empty: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    EmptyView(
                      message: SocialStrings.noFriends,
                      icon: Icons.group_outlined,
                    ),
                  ],
                ),
              ),
              data: (view) => RefreshIndicator(
                onRefresh: _refresh,
                child: _FriendsList(view: view.filter(_query)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendsList extends ConsumerWidget {
  const _FriendsList({required this.view});

  final FriendsView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final now = ref.watch(clockProvider).now();
    if (view.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          EmptyView(
            message: SocialStrings.noSearchResults,
            icon: Icons.search_off_outlined,
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
      slivers: [
        if (view.online.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SectionHeader(
              SocialStrings.onlineSection(view.online.length),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            ),
          ),
          SliverList.builder(
            itemCount: view.online.length,
            itemBuilder: (_, i) => tile(view.online[i]),
          ),
        ],
        if (view.offline.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SectionHeader(
              SocialStrings.offlineSection(view.offline.length),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            ),
          ),
          SliverList.builder(
            itemCount: view.offline.length,
            itemBuilder: (_, i) => tile(view.offline[i]),
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
