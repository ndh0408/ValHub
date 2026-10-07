import 'package:valvn/core/l10n/labels/content_labels.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account_providers.dart';
import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/empty_view.dart';
import '../../../../core/ui/error_view.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/section_header.dart';
import '../../../../core/ui/filter_bar.dart';
import '../../../../core/ui/sub_page.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/clock.dart';
import '../../data/match_filter.dart';
import '../../providers/profile_providers.dart';
import 'match_card.dart';
import 'profile_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

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
    this.title,
  });

  final String puuid;
  final String? title;
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
    final now = ref.watch(clockProvider).now();
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
              ? context.l10n.profileNoMatches
              : context.l10n.profileNoMatchesQueue,
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
              final card = MatchCard(
                key: ValueKey(entry.matchId),
                entry: entry,
                puuid: puuid,
                filter: filter,
                onTap: () => onOpenMatch(entry.matchId),
              );
              // Day headers ("Hôm nay", "Hôm qua", "Thứ Hai, 22/09") while
              // every card is shown (a map filter hides some of them).
              final day = _dayOf(entry.startTime);
              final prev = i == 0 ? null : _dayOf(value.items[i - 1].startTime);
              if (filter.hasMap || day == null || day == prev) return card;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [_DayHeader(context.fmt.dayHeader(day, now)), card],
              );
            },
          ),
        ],
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SectionHeader(title ?? context.l10n.profileMatchHistory),
        ),
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
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final notifier = ref.read(matchFilterProvider(puuid).notifier);
    final map = filter.mapUrl == null ? null : db.mapByUrl(filter.mapUrl);
    final mapName = map?.displayName ?? context.l10n.profileFilterAll;
    final accent = theme.colorScheme.primary;
    final thumb = map?.listViewIcon;
    final queue = filter.queue;
    // The modes recently played (unfiltered page) decide which event modes
    // the sheet offers; the chip replaces a 15-pill bar.
    final played = [
      for (final e
          in ref
                  .watch(matchHistoryProvider((puuid: puuid, queue: null)))
                  .value
                  ?.items ??
              const <MatchHistoryEntry>[])
        e.queueId,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FilterChipBar(
            onClear: filter.hasMap || queue != null
                ? () {
                    notifier
                      ..setQueue(null)
                      ..setMap(null);
                  }
                : null,
            children: [
              ActionChip(
                avatar: Icon(
                  Icons.sports_esports_outlined,
                  size: 18,
                  color: queue == null ? null : accent,
                ),
                shape: const StadiumBorder(),
                visualDensity: VisualDensity.compact,
                backgroundColor: queue == null
                    ? theme.colorScheme.surfaceContainer
                    : accent.withValues(alpha: 0.14),
                side: BorderSide(
                  color: queue == null
                      ? valColorsOf(context).hairline
                      : accent.withValues(alpha: 0.7),
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        context.l10n.profilePerformanceQueueChip(
                          queue == null
                              ? context.l10n.profileFilterAll
                              : db.queueName(context.l10n, queue),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
                onPressed: () => unawaited(
                  _pickQueue(
                    context,
                    db,
                    filterQueuesFor(played),
                    queue,
                    notifier.setQueue,
                  ),
                ),
              ),
              ActionChip(
                avatar: thumb == null
                    ? Icon(
                        Icons.map_outlined,
                        size: 18,
                        color: filter.hasMap ? accent : null,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: NetImage(
                          thumb,
                          width: 28,
                          height: 18,
                          fit: BoxFit.cover,
                          showSkeleton: false,
                        ),
                      ),
                shape: const StadiumBorder(),
                visualDensity: VisualDensity.compact,
                backgroundColor: filter.hasMap
                    ? accent.withValues(alpha: 0.14)
                    : theme.colorScheme.surfaceContainer,
                side: BorderSide(
                  color: filter.hasMap
                      ? accent.withValues(alpha: 0.7)
                      : valColorsOf(context).hairline,
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        context.l10n.profileMapFilter(mapName),
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
            ],
          ),
        ),
      ],
    );
  }
}

/// "Lọc theo chế độ": every offered mode in one sheet (like Hiệu suất).
Future<void> _pickQueue(
  BuildContext context,
  ContentDb db,
  List<String> queues,
  String? selected,
  void Function(String?) onPicked,
) async {
  final l10n = context.l10n;
  final picked = await showValSheet<({String? queue})>(
    context,
    title: l10n.profilePerformanceChooseQueue,
    scrollable: true,
    initialSize: 0.6,
    maxSize: 0.92,
    builder: (context, controller) => ListView(
      controller: controller,
      padding: EdgeInsets.fromLTRB(
        0,
        0,
        0,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        GroupedSection(
          children: [
            for (final q in <String?>[null, ...queues])
              GroupedRow(
                title: q == null
                    ? context.l10n.profileFilterAll
                    : db.queueName(context.l10n, q),
                trailing: q == selected
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop((queue: q)),
              ),
          ],
        ),
      ],
    ),
  );
  if (picked != null) onPicked(picked.queue);
}

DateTime? _dayOf(DateTime? t) {
  if (t == null) return null;
  final l = t.toLocal();
  return DateTime(l.year, l.month, l.day);
}

/// "HÔM NAY" day separator of the match list.
class _DayHeader extends StatelessWidget {
  const _DayHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: SectionLabel(
      text,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
    ),
  );
}

Future<void> _pickMap(
  BuildContext context,
  ContentDb db,
  String? selected,
  void Function(String?) onPicked,
) async {
  final l10nBeforeAwait = context.l10n;

  final maps = filterableMaps(db);
  final picked = await showValSheet<({String? url})>(
    context,
    title: l10nBeforeAwait.profileChooseMap,
    scrollable: true,
    initialSize: 0.65,
    maxSize: 0.92,
    builder: (context, controller) => ListView(
      controller: controller,
      padding: EdgeInsets.fromLTRB(
        0,
        4,
        0,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        _MapTile(
          label: context.l10n.profileFilterAll,
          selected: selected == null,
          onTap: () => Navigator.pop(context, (url: null)),
        ),
        for (final m in maps)
          _MapTile(
            label: m.displayName,
            image: m.listViewIcon,
            selected: selected?.toLowerCase() == m.mapUrl.trim().toLowerCase(),
            onTap: () => Navigator.pop(context, (url: m.mapUrl)),
          ),
      ],
    ),
  );
  if (picked != null) onPicked(picked.url);
}

/// Map banner row of the map picker: map art under a scrim, Anton name.
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
    final img = image;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: scheme.surfaceContainer,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ValRadius.small),
            side: selected
                ? BorderSide(color: scheme.primary, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Stack(
                children: [
                  if (img != null)
                    Positioned.fill(
                      child: NetImage(
                        img,
                        fit: BoxFit.cover,
                        // Where the map art is focused (not text).
                        alignment: Alignment.centerRight,
                        showSkeleton: false,
                        opacity: 0.85,
                        error: const SizedBox.shrink(),
                      ),
                    ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            scheme.surfaceContainer,
                            scheme.surfaceContainer.withValues(alpha: 0.85),
                            scheme.surfaceContainer.withValues(alpha: 0.1),
                          ],
                          stops: const [0, 0.45, 1],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        if (img == null) ...[
                          Icon(Icons.public, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ValText.display(20, color: scheme.onSurface),
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_circle, color: scheme.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
    // Never watches match details: that made one request per listed match
    // (PR-26). The on-device ledger of your own account knows the map of
    // every match it saw; on other players' profiles the list itself just
    // resolves the visible cards.
    final own = ref.watch(accountProvider(puuid).select((a) => a != null));
    final ledger = own ? ref.watch(matchLedgerProvider(puuid)).value : null;
    if (ledger == null) return const SizedBox.shrink();
    final counts = countMapFilter(
      [for (final e in state.items) e.matchId],
      filter: filter,
      mapOf: (id) {
        final line = ledger.byMatch(id);
        return line == null ? null : (map: line.mapId);
      },
    );
    if (counts.unknown > 0 || counts.visible > 0) {
      return const SizedBox.shrink();
    }
    return EmptyView(
      icon: Icons.map_outlined,
      message: context.l10n.profileNoMatchesMap,
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
            child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
          ),
        ),
      );
    }
    if (s.hasMore) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: OutlinedButton(
          onPressed: widget.onLoadMore,
          child: Text(context.l10n.commonLoadMore),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Text(
        context.l10n.profileEndOfHistory,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
