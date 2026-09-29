import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/network/riot_exception.dart';
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
import 'lfg_card.dart';

/// The LFG query shown for [account] with [filter].
LfgQuery lfgQueryFor(Account account, LfgFilter filter) => (
  puuid: account.puuid,
  region: filter.region ?? communityRegion(account.region),
  mode: filter.mode,
);

/// "Tìm đồng đội": region / mode filters, the user's own post pinned on
/// top, then active posts. Refreshes every 20 s while visible.
class LfgSliver extends ConsumerStatefulWidget {
  const LfgSliver({super.key, required this.account});

  final Account account;

  @override
  ConsumerState<LfgSliver> createState() => _LfgSliverState();
}

class _LfgSliverState extends ConsumerState<LfgSliver> {
  Timer? _timer;
  String? _joining;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(kLfgRefreshInterval, (_) => _tick());
  }

  /// False while this tab is in the background (tickers muted).
  var _visible = true;

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
    final remembered = ref.watch(myLfgPostProvider(account.puuid));

    final header = _Filters(
      region: query.region,
      mode: filter.mode,
      onRegion: ref.read(lfgFilterProvider.notifier).setRegion,
      onMode: ref.read(lfgFilterProvider.notifier).setMode,
    );

    Widget body;
    if (!async.hasValue) {
      body = async.hasError && !async.isLoading
          ? CommunityErrorState(
              error: async.error!,
              puuid: account.puuid,
              onRetry: () => ref.invalidate(lfgProvider(query)),
            )
          : SkeletonColumn(item: (_) => const LfgCardSkeleton(), count: 3);
      return SliverToBoxAdapter(child: Column(children: [header, body]));
    }

    final state = async.requireValue;
    final live = state.items.where((p) => !p.isExpired(now)).toList();
    LfgPost? mine;
    if (meId != null) {
      mine = live.where((p) => p.author.id == meId).firstOrNull;
    }
    if (mine == null &&
        remembered != null &&
        !remembered.isExpired(now) &&
        remembered.region == query.region) {
      mine = remembered;
    }
    final others = [
      for (final p in live)
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
      if (mine != null) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: LfgCard(
            key: ValueKey('mine-${mine.id}'),
            post: mine,
            isMine: true,
            onJoin: () {},
            onReport: () {},
            onRemove: () => unawaited(_remove(mine!, query)),
            onExpired: () =>
                ref.read(myLfgPostProvider(account.puuid).notifier).set(null),
          ),
        ),
      ],
      if (others.isEmpty && mine == null)
        CommunityEmptyState(
          icon: Icons.groups_2_outlined,
          title: CommunityStrings.lfgEmptyTitle,
          message: CommunityStrings.lfgEmptyBody,
          action: FilledButton.icon(
            onPressed: () => unawaited(openCreateLfg(context, account, query)),
            icon: const Icon(Icons.add_rounded),
            label: const Text(CommunityStrings.createLfg),
          ),
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
                    // Drops the card from the list when its time is up.
                    onExpired: () {
                      if (mounted) setState(() {});
                    },
                    onJoin: () => unawaited(_join(p)),
                    onRemove: () {},
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

  Future<void> _join(LfgPost post) async {
    final name = post.author.riotId ?? CommunityStrings.unknownPlayer;
    final ok = await confirmCommunityAction(
      context,
      title: CommunityStrings.joinConfirmTitle,
      body: CommunityStrings.joinConfirmBody(name),
      confirmLabel: CommunityStrings.join,
      destructive: false,
    );
    if (!ok || !mounted) return;
    setState(() => _joining = post.id);
    try {
      await joinLfgParty(ref, widget.account.puuid, post.partyCode);
      if (!mounted) return;
      unawaited(HapticFeedback.mediumImpact());
      _snack(CommunityStrings.joined);
    } on Object catch (e) {
      if (mounted) _snack(joinErrorMessage(e));
    } finally {
      if (mounted) setState(() => _joining = null);
    }
  }

  Future<void> _remove(LfgPost post, LfgQuery query) async {
    final ok = await confirmCommunityAction(
      context,
      title: CommunityStrings.removeLfgTitle,
      body: CommunityStrings.removeLfgBody,
      confirmLabel: CommunityStrings.removeLfg,
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

  void _snack(String message) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Vietnamese message for a failed join-by-code (G-19).
String joinErrorMessage(Object error) {
  return switch (error) {
    NotFoundException(:final errorCode)
        when errorCode != null &&
            (errorCode.toUpperCase().contains('PARTY') ||
                errorCode.toUpperCase().contains('CODE')) =>
      CommunityStrings.joinInvalidCode,
    NotFoundException() => CommunityStrings.joinGameNotRunning,
    RiotApiException(:final status)
        when status == 400 || status == 403 || status == 409 =>
      CommunityStrings.joinInvalidCode,
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

class _Filters extends StatelessWidget {
  const _Filters({
    required this.region,
    required this.mode,
    required this.onRegion,
    required this.onMode,
  });

  final String region;
  final String? mode;
  final ValueChanged<String> onRegion;
  final ValueChanged<String?> onMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 52,
      child: ListView(
        key: const ValueKey('lfg-filters'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        children: [
          PopupMenuButton<String>(
            tooltip: CommunityStrings.region,
            initialValue: region,
            onSelected: onRegion,
            itemBuilder: (context) => [
              for (final r in kCommunityRegions)
                PopupMenuItem(
                  value: r,
                  child: Text(CommunityStrings.regionLabel(r)),
                ),
            ],
            child: Chip(
              avatar: const Icon(Icons.public_rounded, size: 16),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(CommunityStrings.regionLabel(region)),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.expand_more_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          CommunityChip(
            label: CommunityStrings.allModes,
            selected: mode == null,
            onSelected: () => onMode(null),
          ),
          for (final m in kLfgModes) ...[
            const SizedBox(width: 8),
            CommunityChip(
              label: CommunityStrings.modeLabel(m),
              selected: mode == m,
              onSelected: () => onMode(m),
            ),
          ],
        ],
      ),
    );
  }
}
