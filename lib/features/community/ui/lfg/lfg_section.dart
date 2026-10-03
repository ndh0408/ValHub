import 'package:valvn/core/l10n/labels/community_labels.dart';

import '../../providers/hidden_authors.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/network/riot_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/error_view.dart' show describeError;
import '../../../../core/util/clock.dart';
import '../../data/community_api.dart';
import '../../data/community_models.dart';
import '../../providers/community_providers.dart';
import '../../providers/lfg_providers.dart';
import '../feed/report_sheet.dart';
import '../widgets/community_widgets.dart';
import 'create_lfg_sheet.dart';
import 'lfg_bits.dart';
import 'lfg_card.dart';

import 'package:valvn/core/l10n/l10n.dart';

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
      myRegion: communityAccountRegion(account),
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
    final hidden = ref.watch(hiddenAuthorsProvider(query.puuid));
    final live0 = state.items
        .where((p) => !p.isExpired(now) && !hidden.containsKey(p.author.id))
        .toList();
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
        CommunityEmptyState(
          icon: Icons.groups_2_outlined,
          title: context.l10n.communityLfgEmptyTitle,
          message: context.l10n.communityLfgEmptyBody,
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
    if (!mounted) return;
    final l10n = context.l10n;
    final name = post.author.riotId ?? l10n.communityUnknownPlayer;
    final ok = await showConfirmDialog(
      context,
      title: l10n.communityJoinConfirmTitle,
      message: l10n.communityJoinConfirmBody(name),
      confirmLabel: l10n.communityJoin,
    );
    if (!ok || !mounted) return;
    setState(() => _joining = post.id);
    try {
      await joinLfgPost(ref, widget.account.puuid, post);
      if (!mounted) return;
      Haptics.medium();
      _snack(l10n.communityJoinedHint);
    } on Object catch (e) {
      if (!mounted) return;
      _snack(
        joinErrorMessage(l10n, e),
        action: SnackBarAction(
          label: l10n.communityRefreshList,
          onPressed: () {
            if (!mounted) return;
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
    if (!mounted) return;
    final l10n = context.l10n;
    try {
      await ref
          .read(myLfgProvider(widget.account.puuid).notifier)
          .extend(ref.read(clockProvider).now());
      if (mounted) _snack(l10n.communityExtended);
    } on LfgPostExpired {
      if (mounted) _snack(l10n.communityLfgExpiredRepost);
    } on Object catch (e) {
      if (mounted) showCommunityError(context, e);
    }
  }

  Future<void> _remove(LfgPost post, LfgQuery query) async {
    if (!mounted) return;
    final l10n = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l10n.communityRemoveLfgTitle,
      message: l10n.communityRemoveLfgBody,
      confirmLabel: l10n.communityRemoveLfg,
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
      if (mounted) _snack(l10n.communityLfgRemoved);
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
String joinErrorMessage(AppLocalizations l10n, Object error) {
  bool has(String? code, List<String> parts) {
    final c = code?.toUpperCase() ?? '';
    return parts.any(c.contains);
  }

  return switch (error) {
    RiotApiException(:final errorCode) when has(errorCode, ['FULL']) =>
      l10n.communityJoinPartyFull,
    RiotApiException(:final status) when status == 409 =>
      l10n.communityJoinPartyFull,
    NotFoundException(:final errorCode)
        when has(errorCode, ['PARTY', 'CODE', 'INVITE']) =>
      l10n.communityJoinCodeExpired,
    NotFoundException() => l10n.communityJoinGameNotRunning,
    RiotApiException(:final status)
        when status == 400 || status == 403 || status == 404 =>
      l10n.communityJoinCodeExpired,
    _ => describeError(l10n, error).message,
  };
}

/// Opens the create sheet and shows a confirmation.
Future<void> openCreateLfg(
  BuildContext context,
  Account account,
  LfgQuery query,
) async {
  final l10nBeforeAwait = context.l10n;

  final post = await showCreateLfgSheet(
    context,
    account: account,
    region: query.region,
    shownIn: query,
  );
  if (post != null && context.mounted) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(l10nBeforeAwait.communityLfgPosted)),
      );
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
    final filterHeight = (MediaQuery.textScalerOf(context).scale(14) * 1.5 + 28)
        .clamp(52.0, double.infinity);
    Widget menuChip<T>({
      required IconData icon,
      required String label,
      required List<(T, String)> items,
      required ValueChanged<T> onSelected,
      required String tooltip,
      bool active = false,
      Key? key,
    }) {
      final scheme = theme.colorScheme;
      final accent = scheme.primary;
      return PopupMenuButton<T>(
        key: key,
        tooltip: tooltip,
        onSelected: onSelected,
        itemBuilder: (context) => [
          for (final (v, l) in items) PopupMenuItem(value: v, child: Text(l)),
        ],
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: active
                ? accent.withValues(alpha: 0.14)
                : scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(ValRadius.pill),
            border: Border.all(
              color: active
                  ? accent.withValues(alpha: 0.7)
                  : valColorsOf(context).hairline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: active ? accent : muted),
              const SizedBox(width: 5),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: active
                      ? legibleAccent(context, accent)
                      : scheme.onSurface,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(width: 3),
              Icon(
                Icons.expand_more_rounded,
                size: 15,
                color: active ? accent : muted,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: filterHeight,
          child: ListView(
            key: const ValueKey('lfg-filters'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            children: [
              menuChip<String>(
                key: const ValueKey('lfg-region'),
                icon: Icons.public_rounded,
                label: context.l10n.communityRegionName(region),
                tooltip: context.l10n.communityRegion,
                active: region != myRegion,
                items: [
                  for (final r in kCommunityRegions)
                    (r, context.l10n.communityRegionName(r)),
                ],
                onSelected: n.setRegion,
              ),
              const SizedBox(width: 8),
              if (hasRank) ...[
                CommunityChip(
                  key: const ValueKey('lfg-match-rank'),
                  icon: Icons.verified_rounded,
                  label: context.l10n.communityMatchMyRank,
                  selected: filter.matchRank,
                  onSelected: () => n.setMatchRank(!filter.matchRank),
                ),
                const SizedBox(width: 8),
              ],
              menuChip<String>(
                key: const ValueKey('lfg-role'),
                icon: Icons.shield_outlined,
                label: filter.role == null
                    ? context.l10n.communityAnyRole
                    : lfgRoleLabel(context.l10n, filter.role!),
                tooltip: context.l10n.communityRoles,
                active: filter.role != null,
                items: [
                  ('', context.l10n.communityAnyRole),
                  for (final r in kLfgRoles) (r, lfgRoleLabel(context.l10n, r)),
                ],
                onSelected: (r) => n.setRole(r.isEmpty ? null : r),
              ),
              const SizedBox(width: 8),
              CommunityChip(
                icon: Icons.mic_rounded,
                label: context.l10n.communityMicOn,
                selected: filter.micOnly,
                onSelected: () => n.setMicOnly(!filter.micOnly),
              ),
              const SizedBox(width: 8),
              menuChip<String>(
                key: const ValueKey('lfg-language-filter'),
                icon: Icons.translate_rounded,
                label: context.l10n.communityLanguageName(
                  filter.language ?? kLfgAnyLanguage,
                ),
                tooltip: context.l10n.communityLanguage,
                active: filter.language != null,
                items: [
                  (kLfgAnyLanguage, context.l10n.communityAnyLanguage),
                  for (final l in kLfgLanguages)
                    (l, context.l10n.communityLanguageName(l)),
                ],
                onSelected: (l) =>
                    n.setLanguage(l == kLfgAnyLanguage ? null : l),
              ),
            ],
          ),
        ),
        SizedBox(
          height: filterHeight,
          child: ListView(
            key: const ValueKey('lfg-modes'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            children: [
              CommunityChip(
                label: context.l10n.communityAllModes,
                selected: filter.mode == null,
                onSelected: () => n.setMode(null),
              ),
              for (final m in kLfgModes) ...[
                const SizedBox(width: 8),
                CommunityChip(
                  label: context.l10n.communityModeName(m),
                  selected: filter.mode == m,
                  onSelected: () => n.setMode(m),
                ),
              ],
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: region == myRegion
                ? theme.colorScheme.surfaceContainer.withValues(alpha: 0.5)
                : theme.colorScheme.errorContainer.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: region == myRegion
                  ? theme.colorScheme.outlineVariant.withValues(alpha: 0.35)
                  : theme.colorScheme.error.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                region == myRegion
                    ? Icons.info_outline_rounded
                    : Icons.warning_amber_rounded,
                size: 14,
                color: region == myRegion ? muted : theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  region == myRegion
                      ? context.l10n.communityLfgSameShardNote
                      : context.l10n.communityLfgOtherShardNote(
                          context.l10n.communityRegionName(region),
                        ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: region == myRegion ? muted : theme.colorScheme.error,
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
