import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/ui/empty_view.dart';
import '../../../../core/ui/error_view.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/section_header.dart';
import '../../../../core/ui/segmented_tabs.dart';
import '../../data/match_filter.dart';
import '../../profile_strings.dart';
import '../../providers/profile_providers.dart';
import 'match_card.dart';
import 'profile_widgets.dart';

/// "Lịch sử đấu" (R8/R9, S40.6) as one sliver: title, queue chips, map
/// filter and an infinitely scrolled list of [MatchCard]s (pages of 20).
///
/// Without a map filter the next page loads when the end of the list comes
/// into view; with one (resolved client-side from cached details) the user
/// taps "Tải thêm" so a rare map cannot trigger dozens of requests.
class MatchHistorySliver extends ConsumerWidget {
  const MatchHistorySliver({
    super.key,
    required this.puuid,
    required this.onOpenMatch,
    this.title = ProfileStrings.matchHistory,
  });

  final String puuid;
  final String title;
  final void Function(String matchId) onOpenMatch;

  /// Refreshes the list shown for [puuid] (pull-to-refresh).
  static Future<void> refresh(WidgetRef ref, String puuid) {
    final filter = ref.read(matchFilterProvider(puuid));
    return ref.refresh(
      matchHistoryProvider((puuid: puuid, queue: filter.queue)).future,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(matchFilterProvider(puuid));
    final query = (puuid: puuid, queue: filter.queue);
    final history = ref.watch(matchHistoryProvider(query));
    final value = history.value;

    final Widget body;
    if (value == null) {
      body = history.hasError && !history.isLoading
          ? SliverToBoxAdapter(
              child: ErrorView(
                error: history.error!,
                puuid: puuid,
                onRetry: () => ref.invalidate(matchHistoryProvider(query)),
              ),
            )
          : SliverList.list(
              children: [for (var i = 0; i < 4; i++) const MatchCardSkeleton()],
            );
    } else if (value.isEmpty) {
      body = SliverToBoxAdapter(
        child: EmptyView(
          icon: Icons.sports_esports_outlined,
          message: filter.queue == null
              ? ProfileStrings.noMatches
              : ProfileStrings.noMatchesQueue,
        ),
      );
    } else {
      body = SliverMainAxisGroup(
        slivers: [
          if (history.hasError && !history.isLoading)
            SliverToBoxAdapter(
              child: ErrorView(
                error: history.error!,
                puuid: puuid,
                compact: true,
                onRetry: () => ref.invalidate(matchHistoryProvider(query)),
              ),
            ),
          if (filter.hasMap)
            SliverToBoxAdapter(
              child: _NoMapMatches(puuid: puuid, state: value, filter: filter),
            ),
          SliverList.builder(
            itemCount: value.items.length + 1,
            itemBuilder: (context, i) {
              if (i == value.items.length) {
                return _Footer(
                  state: value,
                  autoLoad: !filter.hasMap,
                  onLoadMore: () => unawaited(
                    ref.read(matchHistoryProvider(query).notifier).loadMore(),
                  ),
                );
              }
              final entry = value.items[i];
              return MatchCard(
                key: ValueKey(entry.matchId),
                entry: entry,
                puuid: puuid,
                filter: filter,
                onTap: () => onOpenMatch(entry.matchId),
              );
            },
          ),
        ],
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: SectionHeader(title)),
        SliverToBoxAdapter(
          child: _Filters(puuid: puuid, filter: filter),
        ),
        body,
      ],
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.puuid, required this.filter});

  final String puuid;
  final MatchFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final notifier = ref.read(matchFilterProvider(puuid).notifier);
    final mapName = filter.mapUrl == null
        ? ProfileStrings.filterAll
        : db.mapByUrl(filter.mapUrl)?.displayName ?? ProfileStrings.filterAll;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedTabs<String?>(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          tabs: [
            const SegmentedTab(value: null, label: ProfileStrings.filterAll),
            for (final q in kProfileQueueFilters)
              SegmentedTab(value: q, label: db.queueShortName(q)),
          ],
          selected: filter.queue,
          onChanged: notifier.setQueue,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: ActionChip(
            avatar: Icon(
              Icons.map_outlined,
              size: 18,
              color: filter.hasMap
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    ProfileStrings.mapFilter(mapName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 18),
              ],
            ),
            onPressed: () => unawaited(
              _pickMap(context, db, filter.mapUrl, notifier.setMap),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _pickMap(
  BuildContext context,
  ContentDb db,
  String? selected,
  void Function(String?) onPicked,
) async {
  final maps = filterableMaps(db);
  final picked = await showModalBottomSheet<({String? url})>(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, controller) => ListView(
        controller: controller,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              ProfileStrings.chooseMap,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _MapTile(
            label: ProfileStrings.filterAll,
            selected: selected == null,
            onTap: () => Navigator.pop(context, (url: null)),
          ),
          for (final m in maps)
            _MapTile(
              label: m.displayName,
              image: m.listViewIcon,
              selected:
                  selected?.toLowerCase() == m.mapUrl.trim().toLowerCase(),
              onTap: () => Navigator.pop(context, (url: m.mapUrl)),
            ),
        ],
      ),
    ),
  );
  if (picked != null) onPicked(picked.url);
}

class _MapTile extends StatelessWidget {
  const _MapTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.image,
  });

  final String label;
  final String? image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      selected: selected,
      onTap: onTap,
      title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: selected ? Icon(Icons.check, color: scheme.primary) : null,
      leading: image == null
          ? const Icon(Icons.public)
          : ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                width: 72,
                height: 28,
                child: NetImage(image, fit: BoxFit.cover, showSkeleton: false),
              ),
            ),
    );
  }
}

/// Empty message when a map filter hides every loaded match.
class _NoMapMatches extends ConsumerWidget {
  const _NoMapMatches({
    required this.puuid,
    required this.state,
    required this.filter,
  });

  final String puuid;
  final PagedState<MatchHistoryEntry> state;
  final MatchFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var pending = false;
    var visible = 0;
    for (final e in state.items) {
      final s = ref.watch(
        matchSummaryProvider((matchId: e.matchId, puuid: puuid)),
      );
      final v = s.value;
      if (v == null) {
        if (!s.hasError) pending = true;
      } else if (filter.acceptsMap(v.info.mapId)) {
        visible++;
      }
    }
    if (pending || visible > 0) return const SizedBox.shrink();
    return const EmptyView(
      icon: Icons.map_outlined,
      message: ProfileStrings.noMatchesMap,
      padding: EdgeInsets.fromLTRB(32, 16, 32, 8),
    );
  }
}

class _Footer extends StatefulWidget {
  const _Footer({
    required this.state,
    required this.autoLoad,
    required this.onLoadMore,
  });

  final PagedState<MatchHistoryEntry> state;
  final bool autoLoad;
  final VoidCallback onLoadMore;

  @override
  State<_Footer> createState() => _FooterState();
}

class _FooterState extends State<_Footer> {
  @override
  void initState() {
    super.initState();
    _maybeAutoLoad();
  }

  @override
  void didUpdateWidget(_Footer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final finishedLoading =
        oldWidget.state.isLoadingMore && !widget.state.isLoadingMore;
    if ((widget.autoLoad && !oldWidget.autoLoad) || finishedLoading) {
      _maybeAutoLoad();
    }
  }

  void _maybeAutoLoad() {
    final s = widget.state;
    if (!widget.autoLoad ||
        !s.hasMore ||
        s.isLoadingMore ||
        s.loadMoreError != null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onLoadMore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final theme = Theme.of(context);
    final error = s.loadMoreError;
    if (error != null) {
      return ErrorView(error: error, compact: true, onRetry: widget.onLoadMore);
    }
    if (s.isLoadingMore || (s.hasMore && widget.autoLoad)) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }
    if (s.hasMore) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: OutlinedButton(
          onPressed: widget.onLoadMore,
          child: const Text(CommonStrings.loadMore),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Text(
        ProfileStrings.endOfHistory,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
