/// The shared chrome of a Home card: icon + title + "⋯" menu, an optional
/// background, the skeleton and the compact error state (docs/design/HOME.md
/// §4).
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/auth/auth_routes.dart';
import '../../../core/network/reachability.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/xmpp/xmpp_providers.dart' show appForegroundProvider;
import '../data/home_card.dart';
import '../providers/home_layout_provider.dart';
import 'customize_home_sheet.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Title, description and icon of each card (the catalogue shown in
/// "Tùy chỉnh Trang chủ").
extension HomeCardMeta on HomeCardId {
  String title(AppLocalizations l10n) => switch (this) {
    HomeCardId.live => l10n.homeCardLive,
    HomeCardId.store => l10n.homeCardStore,
    HomeCardId.rank => l10n.homeCardRank,
    HomeCardId.battlePass => l10n.homeCardBattlePass,
    HomeCardId.friends => l10n.homeCardFriends,
    HomeCardId.community => l10n.homeCardCommunity,
    HomeCardId.otherAccounts => l10n.homeCardOtherAccounts,
    HomeCardId.serverStatus => l10n.homeCardServerStatus,
  };

  String description(AppLocalizations l10n) => switch (this) {
    HomeCardId.live => l10n.homeCardLiveDesc,
    HomeCardId.store => l10n.homeCardStoreDesc,
    HomeCardId.rank => l10n.homeCardRankDesc,
    HomeCardId.battlePass => l10n.homeCardBattlePassDesc,
    HomeCardId.friends => l10n.homeCardFriendsDesc,
    HomeCardId.community => l10n.homeCardCommunityDesc,
    HomeCardId.otherAccounts => l10n.homeCardOtherAccountsDesc,
    HomeCardId.serverStatus => l10n.homeCardServerStatusDesc,
  };

  IconData get icon => switch (this) {
    HomeCardId.live => Icons.sensors_rounded,
    HomeCardId.store => Icons.storefront_outlined,
    HomeCardId.rank => Icons.leaderboard_outlined,
    HomeCardId.battlePass => Icons.military_tech_outlined,
    HomeCardId.friends => Icons.group_outlined,
    HomeCardId.community => Icons.forum_outlined,
    HomeCardId.otherAccounts => Icons.switch_account_outlined,
    HomeCardId.serverStatus => Icons.dns_outlined,
  };
}

/// Whether the user asked the system to reduce motion.
bool homeReducedMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

enum _CardAction { hide, customize }

/// Hides [card] and offers "Hoàn tác" in a snack bar.
Future<void> hideHomeCard(
  BuildContext context,
  WidgetRef ref,
  HomeCardId card,
) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.maybeOf(context);
  final notifier = ref.read(homeLayoutProvider.notifier);
  await notifier.setHidden(card, hidden: true);
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.homeCardHidden(card.title(l10n))),
        action: SnackBarAction(
          label: l10n.homeUndo,
          onPressed: () => unawaited(notifier.setHidden(card, hidden: false)),
        ),
      ),
    );
}

/// A Home card: `ValCard` (radius 16) with a header row (24 dp outline icon,
/// the title as a heading, an optional compact [trailing] widget and the
/// "⋯" menu with "Ẩn thẻ này" / "Tùy chỉnh Trang chủ…") above the [child].
/// [onTap] is the card's primary destination; buttons inside the child are
/// the secondary ones.
class HomeCardFrame extends ConsumerWidget {
  const HomeCardFrame({
    super.key,
    required this.card,
    required this.child,
    this.onTap,
    this.trailing,
    this.background,
    this.title,
    this.icon,
    this.iconColor,
    this.childPadding = const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 16),
    this.showMenu = true,
    this.semanticsLabel,
  });

  final HomeCardId card;
  final Widget child;
  final VoidCallback? onTap;

  /// A small widget before the menu (refresh ring, pill, chevron).
  final Widget? trailing;

  /// Painted behind everything (a map splash with its scrim).
  final Widget? background;

  /// Overrides the catalogue title / icon (the status card).
  final String? title;
  final IconData? icon;
  final Color? iconColor;
  final EdgeInsetsGeometry childPadding;
  final bool showMenu;

  /// A one-sentence summary for screen readers.
  final String? semanticsLabel;

  Future<void> _openMenu(
    BuildContext context,
    WidgetRef ref,
    String name,
  ) async {
    final l10n = context.l10n;
    final choice = await showActionSheet<_CardAction>(
      context,
      actions: [
        SheetAction(
          value: _CardAction.hide,
          label: l10n.homeHideCard,
          icon: Icons.visibility_off_outlined,
        ),
        SheetAction(
          value: _CardAction.customize,
          label: '${l10n.homeCustomize}…',
          icon: Icons.tune_rounded,
        ),
      ],
    );
    if (choice == null || !context.mounted) return;
    switch (choice) {
      case _CardAction.hide:
        await hideHomeCard(context, ref, card);
      case _CardAction.customize:
        await showCustomizeHomeSheet(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final name = title ?? card.title(context.l10n);
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 16, end: 4, top: 4),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  icon ?? card.icon,
                  size: 24,
                  color:
                      iconColor ??
                      legibleAccent(context, theme.colorScheme.primary, min: 3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              if (showMenu)
                IconButton(
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  icon: const Icon(Icons.more_horiz_rounded),
                  color: theme.colorScheme.onSurfaceVariant,
                  tooltip: context.l10n.homeMoreActions(name),
                  onPressed: () => unawaited(_openMenu(context, ref, name)),
                )
              else
                const SizedBox(width: 12),
            ],
          ),
        ),
        Padding(padding: childPadding, child: child),
      ],
    );
    return Semantics(
      container: true,
      label: semanticsLabel,
      child: ValCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: background == null
            ? body
            : Stack(
                children: [
                  Positioned.fill(child: background!),
                  body,
                ],
              ),
      ),
    );
  }
}

/// The three skeleton shapes of the core cards.
enum HomeSkeletonKind { store, rank, battlePass }

/// Skeleton with the same structure as the real card (title line + body), so
/// the page does not jump when the data arrives.
class HomeCardSkeleton extends StatelessWidget {
  const HomeCardSkeleton({super.key, required this.kind});

  final HomeSkeletonKind kind;

  @override
  Widget build(BuildContext context) {
    final body = switch (kind) {
      HomeSkeletonKind.store => Row(
        children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            const Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Skeleton(height: null, radius: 12, shimmer: false),
              ),
            ),
          ],
        ],
      ),
      HomeSkeletonKind.rank => const Row(
        children: [
          Skeleton(width: 56, height: 56, radius: 28, shimmer: false),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: 140, height: 16, shimmer: false),
                SizedBox(height: 10),
                Skeleton(height: 6, radius: 3, shimmer: false),
              ],
            ),
          ),
        ],
      ),
      HomeSkeletonKind.battlePass => const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Skeleton(height: 8, radius: 4, shimmer: false),
          SizedBox(height: 14),
          Skeleton(height: 14, shimmer: false),
          SizedBox(height: 10),
          Skeleton(height: 14, shimmer: false),
        ],
      ),
    };
    return ValCard(
      child: SkeletonShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Skeleton(width: 24, height: 24, radius: 12, shimmer: false),
                SizedBox(width: 10),
                Skeleton(width: 150, height: 16, shimmer: false),
              ],
            ),
            const SizedBox(height: 16),
            body,
          ],
        ),
      ),
    );
  }
}

/// Compact error inside a card: the message and "Thử lại" (or "Đăng nhập
/// lại" when the session died). Without a network the Home banner already
/// says so (and retries): the card only says it fills in once online.
class HomeCardError extends ConsumerWidget {
  const HomeCardError({
    super.key,
    required this.error,
    required this.puuid,
    this.onRetry,
  });

  final Object error;
  final String puuid;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final d = describeError(context.l10n, error);
    final retry = onRetry;
    if (!ref.watch(networkOnlineProvider) && isNetworkError(error)) {
      final muted = theme.colorScheme.onSurfaceVariant;
      return Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 20, color: muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.homeCardOffline,
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Icon(d.icon, size: 22, color: theme.colorScheme.error),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(
            d.needsLogin ? context.l10n.commonErrorNeedsLoginTitle : d.message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        // Long labels ("Erneut versuchen") wrap instead of overflowing.
        if (d.needsLogin)
          Flexible(
            flex: 2,
            child: TextButton(
              onPressed: () => unawaited(
                context.push<Object?>(AuthRoutes.loginPath(reauthPuuid: puuid)),
              ),
              child: Text(
                context.l10n.commonSignInAgain,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else if (retry != null && d.canRetry)
          Flexible(
            flex: 2,
            child: TextButton(
              onPressed: retry,
              child: Text(
                context.l10n.commonRetry,
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// A muted one-line note under a card body ("Cập nhật lúc 14:05").
class HomeCardFootnote extends StatelessWidget {
  const HomeCardFootnote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Runs [onTick] every [every] while the card is on screen, Home's tab is
/// visible (tickers enabled) and the app is in the foreground. The timer is
/// owned by this [State], so it dies with the card: a hidden card, a left
/// tab and an account switch all stop it.
class HomeCardPoller extends ConsumerStatefulWidget {
  const HomeCardPoller({
    super.key,
    required this.every,
    required this.onTick,
    required this.child,
  });

  final Duration every;
  final VoidCallback onTick;
  final Widget child;

  @override
  ConsumerState<HomeCardPoller> createState() => _HomeCardPollerState();
}

class _HomeCardPollerState extends ConsumerState<HomeCardPoller> {
  Timer? _timer;
  bool _visible = true;

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.every, (_) {
      if (mounted && _visible && ref.read(appForegroundProvider)) {
        widget.onTick();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visible = TickerMode.valuesOf(context).enabled;
  }

  @override
  void didUpdateWidget(HomeCardPoller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.every != widget.every) _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
