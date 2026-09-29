import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/network/riot_exception.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/error_view.dart' show describeError;
import '../../../../core/util/clock.dart';
import '../../community_strings.dart';
import '../../data/community_api.dart';
import '../../data/community_models.dart';
import '../../providers/community_providers.dart';
import '../../providers/lfg_providers.dart';
import '../feed/report_sheet.dart';
import '../widgets/community_widgets.dart';
import 'create_lfg_sheet.dart';
import 'lfg_bits.dart';
import 'lfg_card.dart';

/// "Tìm đồng đội": filters ("Phù hợp rank của bạn" on by default, region,
/// mic, mode, role), the user's own post pinned on top with its live party,
/// then open posts. The list refreshes every 20 s while visible.
class LfgSliver extends ConsumerStatefulWidget {
  const LfgSliver({super.key, required this.account});

  final Account account;

  @override
  ConsumerState<LfgSliver> createState() => _LfgSliverState();
}

class _LfgSliverState extends ConsumerState<LfgSliver> {
  Timer? _timer;
  String? _joining;

  /// False while this tab is in the background (tickers muted).
  var _visible = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(kLfgRefreshInterval, (_) => _tick());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visible = TickerMode.valuesOf(context).enabled;
  }

  void _tick() {
    if (!mounted || !_visible) return;
    final q = lfgQueryFor(widget.account, ref.read(lfgFilterProvider));
    if (ref.exists(lfgProvider(q))) {
      unawaited(ref.read(lfgProvider(q).notifier).silentRefresh());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.account;
    final filter = ref.watch(lfgFilterProvider);
    final query = lfgQueryFor(account, filter);
    final async = ref.watch(lfgProvider(query));
    final meId = ref.watch(communityMeProvider(account.puuid)).value?.id;
    final now = ref.watch(clockProvider).now();
    final remembered = ref.watch(myLfgProvider(account.puuid)).value;
    final live = ref.watch(lfgLivePartyProvider(account.puuid));
    final viewerRank = lfgViewerRank(account);

    // The shard the server really listed (`appliedScope`), else the asked one.
    final appliedRegion = async.value?.applied?.region;
    final header = _Filters(
      filter: filter,
      region: appliedRegion ?? query.region,
      myRegion: communityRegion(account.region),
      hasRank: viewerRank != null,
    );

    if (!async.hasValue) {
      final body = async.hasError && !async.isLoading
          ? CommunityErrorState(
              error: async.error!,
              puuid: account.puuid,
              onRetry: () => ref.invalidate(lfgProvider(query)),
            )
          : SkeletonColumn(item: (_) => const LfgCardSkeleton(), count: 3);
      return SliverToBoxAdapter(child: Column(children: [header, body]));
    }

    final state = async.requireValue;
    final live0 = state.items.where((p) => !p.isExpired(now)).toList();
    LfgPost? mine;
    if (remembered != null && !remembered.isExpired(now)) mine = remembered;
    if (mine == null && meId != null) {
      mine = live0.where((p) => p.author.id == meId).firstOrNull;
    }
    final others = [
      for (final p in live0)
        if (p.id != mine?.id && (meId == null || p.author.id != meId)) p,
    ];
    final staleError = async.hasError && !async.isLoading ? async.error : null;

    final children = <Widget>[
      header,
      if (staleError != null)
        CommunityErrorState(
          error: staleError,
          compact: true,
          onRetry: () => ref.invalidate(lfgProvider(query)),
        ),
      if (mine != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: LfgCard(
            key: ValueKey('mine-${mine.id}'),
            post: mine,
            isMine: true,
            live: live,
            onJoin: () {},
            onReport: () {},
            onExtend: () => unawaited(_extend()),
            onRemove: () => unawaited(_remove(mine!, query)),
            onExpired: () => setState(() {}),
          ),
        ),
      if (others.isEmpty && mine == null)
        const CommunityEmptyState(
          icon: Icons.groups_2_outlined,
          title: CommunityStrings.lfgEmptyTitle,
          message: CommunityStrings.lfgEmptyBody,
        ),
    ];

    final notifier = ref.read(lfgProvider(query).notifier);
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
        if (others.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            sliver: SliverList.builder(
              itemCount: others.length + 1,
              itemBuilder: (context, i) {
                if (i == others.length) {
                  return PagedFooter(
                    hasMore: state.hasMore,
                    loading: state.loadingMore,
                    error: state.loadMoreError,
                    onLoadMore: () => unawaited(notifier.loadMore()),
                  );
                }
                final p = others[i];
                return Padding(
                  key: ValueKey(p.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LfgCard(
                    post: p,
                    isMine: false,
                    joining: _joining == p.id,
                    outOfRange:
                        !filter.matchRank &&
                        viewerRank != null &&
                        !p.acceptsRank(viewerRank),
                    onJoin: () => unawaited(_join(p, query)),
                    onRemove: () {},
                    onExpired: () {
                      if (mounted) setState(() {});
                    },
                    onReport: () => unawaited(
                      reportContent(
                        context,
                        ref,
                        puuid: account.puuid,
                        targetType: ReportTarget.lfg,
                        targetId: p.id,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _join(LfgPost post, LfgQuery query) async {
    final name = post.author.riotId ?? CommunityStrings.unknownPlayer;
    final ok = await showConfirmDialog(
      context,
      title: CommunityStrings.joinConfirmTitle,
      message: CommunityStrings.joinConfirmBody(name),
      confirmLabel: CommunityStrings.join,
    );
    if (!ok || !mounted) return;
    setState(() => _joining = post.id);
    try {
      await joinLfgPost(ref, widget.account.puuid, post);
      if (!mounted) return;
      Haptics.medium();
      _snack(CommunityStrings.joinedHint);
    } on Object catch (e) {
      if (!mounted) return;
      _snack(
        joinErrorMessage(e),
        action: SnackBarAction(
          label: CommunityStrings.refreshList,
          onPressed: () {
            if (ref.exists(lfgProvider(query))) {
              unawaited(ref.read(lfgProvider(query).notifier).silentRefresh());
            }
          },
        ),
      );
    } finally {
      if (mounted) setState(() => _joining = null);
    }
  }

  Future<void> _extend() async {
    try {
      await ref
          .read(myLfgProvider(widget.account.puuid).notifier)
          .extend(ref.read(clockProvider).now());
      if (mounted) _snack(CommunityStrings.extended);
    } on LfgPostExpired {
      if (mounted) _snack(CommunityStrings.lfgExpiredRepost);
    } on Object catch (e) {
      if (mounted) showCommunityError(context, e);
    }
  }

  Future<void> _remove(LfgPost post, LfgQuery query) async {
    final ok = await showConfirmDialog(
      context,
      title: CommunityStrings.removeLfgTitle,
      message: CommunityStrings.removeLfgBody,
      confirmLabel: CommunityStrings.removeLfg,
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await removeLfgPost(
        ref,
        puuid: widget.account.puuid,
        post: post,
        shownIn: query,
      );
      if (mounted) _snack(CommunityStrings.lfgRemoved);
    } on Object catch (e) {
      if (mounted) showCommunityError(context, e);
    }
  }

  void _snack(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }
}

/// Vietnamese message for a failed join-by-code (G-19).
String joinErrorMessage(Object error) {
  bool has(String? code, List<String> parts) {
    final c = code?.toUpperCase() ?? '';
    return parts.any(c.contains);
  }

  return switch (error) {
    RiotApiException(:final errorCode) when has(errorCode, ['FULL']) =>
      CommunityStrings.joinPartyFull,
    RiotApiException(:final status) when status == 409 =>
      CommunityStrings.joinPartyFull,
    NotFoundException(:final errorCode)
        when has(errorCode, ['PARTY', 'CODE', 'INVITE']) =>
      CommunityStrings.joinCodeExpired,
    NotFoundException() => CommunityStrings.joinGameNotRunning,
    RiotApiException(:final status)
        when status == 400 || status == 403 || status == 404 =>
      CommunityStrings.joinCodeExpired,
    _ => describeError(error).message,
  };
}

/// Opens the create sheet and shows a confirmation.
Future<void> openCreateLfg(
  BuildContext context,
  Account account,
  LfgQuery query,
) async {
  final post = await showCreateLfgSheet(
    context,
    account: account,
    region: query.region,
    shownIn: query,
  );
  if (post != null && context.mounted) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(CommunityStrings.lfgPosted)));
  }
}

class _Filters extends ConsumerWidget {
  const _Filters({
    required this.filter,
    required this.region,
    required this.myRegion,
    required this.hasRank,
  });

  final LfgFilter filter;
  final String region;
  final String myRegion;
  final bool hasRank;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final n = ref.read(lfgFilterProvider.notifier);
    final muted = theme.colorScheme.onSurfaceVariant;
    Widget menuChip<T>({
      required IconData icon,
      required String label,
      required List<(T, String)> items,
      required ValueChanged<T> onSelected,
      required String tooltip,
      Key? key,
    }) => PopupMenuButton<T>(
      key: key,
      tooltip: tooltip,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final (v, l) in items) PopupMenuItem(value: v, child: Text(l)),
      ],
      child: Chip(
        avatar: Icon(icon, size: 16),
        shape: const StadiumBorder(),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 2),
            Icon(Icons.expand_more_rounded, size: 16, color: muted),
          ],
        ),
      ),
    );

    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            key: const ValueKey('lfg-filters'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            children: [
              menuChip<String>(
                key: const ValueKey('lfg-region'),
                icon: Icons.public_rounded,
                label: CommunityStrings.regionLabel(region),
                tooltip: CommunityStrings.region,
                items: [
                  for (final r in kCommunityRegions)
                    (r, CommunityStrings.regionLabel(r)),
                ],
                onSelected: n.setRegion,
              ),
              const SizedBox(width: 8),
              if (hasRank) ...[
                CommunityChip(
                  key: const ValueKey('lfg-match-rank'),
                  icon: Icons.verified_rounded,
                  label: CommunityStrings.matchMyRank,
                  selected: filter.matchRank,
                  onSelected: () => n.setMatchRank(!filter.matchRank),
                ),
                const SizedBox(width: 8),
              ],
              menuChip<String>(
                key: const ValueKey('lfg-role'),
                icon: Icons.shield_outlined,
                label: filter.role == null
                    ? CommunityStrings.anyRole
                    : lfgRoleLabel(filter.role!),
                tooltip: CommunityStrings.roles,
                items: [
                  ('', CommunityStrings.anyRole),
                  for (final r in kLfgRoles) (r, lfgRoleLabel(r)),
                ],
                onSelected: (r) => n.setRole(r.isEmpty ? null : r),
              ),
              const SizedBox(width: 8),
              CommunityChip(
                icon: Icons.mic_rounded,
                label: CommunityStrings.micOn,
                selected: filter.micOnly,
                onSelected: () => n.setMicOnly(!filter.micOnly),
              ),
              const SizedBox(width: 8),
              menuChip<String>(
                key: const ValueKey('lfg-language-filter'),
                icon: Icons.translate_rounded,
                label: CommunityStrings.languageLabel(
                  filter.language ?? kLfgAnyLanguage,
                ),
                tooltip: CommunityStrings.language,
                items: [
                  (kLfgAnyLanguage, CommunityStrings.anyLanguage),
                  for (final l in kLfgLanguages)
                    (l, CommunityStrings.languageLabel(l)),
                ],
                onSelected: (l) =>
                    n.setLanguage(l == kLfgAnyLanguage ? null : l),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            key: const ValueKey('lfg-modes'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            children: [
              CommunityChip(
                label: CommunityStrings.allModes,
                selected: filter.mode == null,
                onSelected: () => n.setMode(null),
              ),
              for (final m in kLfgModes) ...[
                const SizedBox(width: 8),
                CommunityChip(
                  label: CommunityStrings.modeLabel(m),
                  selected: filter.mode == m,
                  onSelected: () => n.setMode(m),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  region == myRegion
                      ? CommunityStrings.lfgSameShardNote
                      : CommunityStrings.lfgOtherShardNote(
                          CommunityStrings.regionLabel(region),
                        ),
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
