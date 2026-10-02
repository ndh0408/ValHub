import 'package:valvn/features/social/ui/friend_status_labels.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/storage/ui_memory.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/filter_bar.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/search_text.dart';
import '../../../core/xmpp/friends.dart';
import '../../../core/xmpp/xmpp_providers.dart';
import '../data/friend_sections.dart';
import '../data/friend_status.dart';
import '../social_routes.dart';
import '../social_strings.dart';
import 'widgets/friend_tile.dart';
import 'widgets/social_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// S60 "Bạn bè & trò chuyện". Route `/profile/friends`.
///
/// Riot friends (XMPP roster + presence) in "Đang chơi (n)" /
/// "Trực tuyến (n)" / "Ngoại tuyến (n)" groups under a large title, with a
/// pinned search field (Riot ID, case- and diacritic-insensitive: "duc"
/// finds "Đức"), a remembered quick filter (Tất cả / Trực tuyến / Chưa
/// đọc), unread badges and pull-to-refresh (re-requests presences).
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

  void _clearQuery() {
    _search.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendsProvider);
    final puuid = ref.watch(activePuuidProvider);
    final view = friends.value;
    final unread = view?.totalUnread ?? 0;

    final List<Widget> body;
    if (view != null) {
      body = [
        SliverToBoxAdapter(
          child: ConnectionBanner(state: view.connection, onRetry: _retry),
        ),
        if (friends.hasError && !friends.isLoading)
          SliverToBoxAdapter(
            child: ErrorView(
              error: friends.error!,
              onRetry: _retry,
              puuid: puuid,
              compact: true,
            ),
          ),
        if (view.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyView(
              title: context.l10n.socialNoFriendsTitle,
              message: context.l10n.socialNoFriends,
              icon: Icons.group_outlined,
            ),
          )
        else
          ..._FriendsSlivers.build(
            context: context,
            ref: ref,
            view: searchFriends(view, _query),
            filter: _filter,
            searching: searchTokens(_query).isNotEmpty,
            onClearSearch: _clearQuery,
            onShowAll: () => _setFilter(FriendsFilter.all),
          ),
      ];
    } else if (friends.hasError && !friends.isLoading) {
      body = [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorView(
            error: friends.error!,
            onRetry: _retry,
            puuid: puuid,
          ),
        ),
      ];
    } else {
      body = const [SliverToBoxAdapter(child: _FriendsSkeleton())];
    }

    return SubPageScaffold(
      title: context.l10n.socialFriendsTitle,
      subtitle: view == null || view.isEmpty
          ? null
          : context.l10n.socialFriendsSummary(
              view.all.length,
              view.online.length,
            ),
      onRefresh: _refresh,
      slivers: [
        PinnedHeaderSliver(
          child: _SearchStrip(
            child: GlassSearchField(
              controller: _search,
              hintText: context.l10n.socialSearchHint,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: FilterChipBar(
              children: [
                for (final f in FriendsFilter.values)
                  ValFilterChip(
                    label: switch (f) {
                      FriendsFilter.all => context.l10n.socialFilterAll,
                      FriendsFilter.online => context.l10n.socialFilterOnline,
                      FriendsFilter.unread =>
                        unread > 0
                            ? '${context.l10n.socialFilterUnread} '
                                  '(${SocialStrings.unreadBadge(unread)})'
                            : context.l10n.socialFilterUnread,
                    },
                    dotColor: f == FriendsFilter.online
                        ? valColorsOf(context).win
                        : null,
                    selected: _filter == f,
                    onSelected: (_) => _setFilter(f),
                  ),
              ],
            ),
          ),
        ),
        ...body,
      ],
    );
  }
}

/// Opaque strip behind the pinned search field (no blur: it sits over a
/// scrolling list), with a hairline once content scrolls under it.
class _SearchStrip extends StatelessWidget {
  const _SearchStrip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: child,
    ),
  );
}

/// The grouped friend sections (or the empty state of a search / filter).
abstract final class _FriendsSlivers {
  static List<Widget> build({
    required BuildContext context,
    required WidgetRef ref,
    required FriendsView view,
    required FriendsFilter filter,
    required bool searching,
    required VoidCallback onClearSearch,
    required VoidCallback onShowAll,
  }) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final now = ref.watch(clockProvider).now();
    final sections = friendSections(view, filter: filter);
    if (sections.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyView(
            title: searching ? context.l10n.socialNoSearchResultsTitle : null,
            message: searching
                ? context.l10n.socialNoSearchResults
                : context.l10n.socialNoFilterResults,
            icon: searching
                ? Icons.search_off_outlined
                : Icons.filter_alt_off_outlined,
            action: OutlinedButton(
              onPressed: searching ? onClearSearch : onShowAll,
              child: Text(
                searching
                    ? context.l10n.socialShowEveryone
                    : context.l10n.socialFilterAll,
              ),
            ),
          ),
        ),
      ];
    }

    Widget tile(Friend f) => FriendTile(
      key: ValueKey(f.puuid),
      friend: f,
      status: friendStatus(context.l10n, context.fmt, f, db: db, now: now),
      detail: friendDetail(context.l10n, context.fmt, f, db: db),
      rankTier: friendRankTier(f),
      unknownName: context.l10n.competitiveUnknownPlayer,
      heroTag: friendAvatarHeroTag(f.puuid),
      onTap: () => unawaited(context.push(SocialRoutes.chat(f.puuid))),
    );

    return [
      for (final section in sections) ...[
        SliverToBoxAdapter(
          child: SectionLabel(switch (section.kind) {
            FriendSectionKind.playing => context.l10n.socialPlayingSection(
              section.friends.length,
            ),
            FriendSectionKind.online => context.l10n.socialOnlineSection(
              section.friends.length,
            ),
            FriendSectionKind.offline => context.l10n.socialOfflineSection(
              section.friends.length,
            ),
          }, padding: const EdgeInsets.fromLTRB(20, 16, 20, 8)),
        ),
        // Lazy: long offline lists only build the visible rows.
        GroupedSliverList(
          itemCount: section.friends.length,
          itemBuilder: (context, i) => tile(section.friends[i]),
        ),
      ],
      const SliverToBoxAdapter(child: _PrivacyNote()),
    ];
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, size: 16, color: muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.socialFriendsPrivacyNote,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mirrors the loaded layout: a section label and a grouped card of rows.
class _FriendsSkeleton extends StatelessWidget {
  const _FriendsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 4, 0, 10),
              child: Skeleton(width: 110, height: 12, shimmer: false),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(ValRadius.card),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < 7; i++)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Row(
                        children: [
                          Skeleton(
                            width: 46,
                            height: 46,
                            radius: 23,
                            shimmer: false,
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Skeleton(
                                  width: 150,
                                  height: 14,
                                  shimmer: false,
                                ),
                                SizedBox(height: 8),
                                Skeleton(
                                  width: 110,
                                  height: 12,
                                  shimmer: false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
