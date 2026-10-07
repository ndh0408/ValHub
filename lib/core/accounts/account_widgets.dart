import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../auth/auth_routes.dart';
import '../config/app_constants.dart';
import '../content/content_repository.dart';
import '../geo/region_picker.dart';
import '../l10n/l10n.dart';
import '../l10n/account_labels.dart';
import '../theme/app_theme.dart';
import '../ui/adaptive.dart';
import '../ui/error_view.dart';
import '../ui/net_image.dart';
import '../ui/rank_badge.dart';
import '../ui/sub_page.dart';
import '../ui/val_widgets.dart';
import 'account_actions.dart';
import 'account.dart';
import 'account_providers.dart';
import 'account_status.dart';

/// Square avatar: the account's cached player-card small art, or initials.
class AccountAvatar extends ConsumerWidget {
  const AccountAvatar({
    super.key,
    required this.account,
    this.size = 32,
    this.circle = false,
  });

  final Account account;
  final double size;

  /// Round avatar with the red gradient fallback (Figma account chip).
  final bool circle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardId = account.cardId;
    final art = cardId == null
        ? null
        : ref.watch(contentProvider).value?.card(cardId)?.smallArt;
    final scheme = Theme.of(context).colorScheme;
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: circle
          ? redAvatarGradient()
          : BoxDecoration(color: scheme.surfaceContainerHighest),
      child: Text(
        account.gameName.isEmpty
            ? '?'
            : account.gameName.characters.first.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: size * 0.45,
          color: circle ? Colors.white : null,
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(circle ? size / 2 : size * 0.22),
      child: art == null
          ? fallback
          : NetImage(
              art,
              width: size,
              height: size,
              fit: BoxFit.cover,
              error: fallback,
            ),
    );
  }
}

/// Header chip for any tab: active account avatar + Riot ID; tap opens the
/// account switcher (S05).
class AccountChip extends ConsumerWidget {
  const AccountChip({super.key, this.showName = true});

  final bool showName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final name = account.gameName.isEmpty
        ? account.displayRiotId(context.l10n)
        : account.gameName;
    // The pill is 38 dp tall; the tap target (and its semantics node) is
    // 48 dp: a 5 dp band above and below belongs to the button.
    return Semantics(
      button: true,
      label: context.l10n.accountSwitcherTitle,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => unawaited(showAccountSwitcherSheet(context)),
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Ink(
              decoration: ShapeDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                shape: const StadiumBorder(),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  4,
                  4,
                  showName ? 12 : 4,
                  4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Badge(
                      isLabelVisible: account.needsLogin,
                      smallSize: 8,
                      child: AccountAvatar(
                        account: account,
                        size: 30,
                        circle: true,
                      ),
                    ),
                    if (showName) ...[
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the account switcher sheet (S05).
Future<void> showAccountSwitcherSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          const AccountActivityPoller(child: AccountSwitcherSheet()),
    );

/// Account list in the shared sheet chrome: "Tài khoản (n/10)" with a close
/// button and the online count, one grouped card of [AccountTile]s (tap to
/// switch, "Đăng nhập lại" when the session ended, ⋮ for the account's
/// actions) ending with "Thêm tài khoản". Scrolls when there are many
/// accounts.
class AccountSwitcherSheet extends ConsumerWidget {
  const AccountSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    final active = ref.watch(activePuuidProvider);
    final max = AppConstants.maxAccounts;
    final full = accounts.length >= max;
    final online = ref.watch(onlineAccountCountProvider);
    final theme = Theme.of(context);
    final hairline = valColorsOf(context).hairline;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeader(
            title: context.l10n.accountSwitcherTitleCount(accounts.length, max),
            subtitle: context.l10n.accountSwitcherSubtitle,
            actions: [
              if (online > 0)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: StatusPill(
                      label: context.l10n.accountOnlineCount(online),
                      color: valColorsOf(context).win,
                    ),
                  ),
                ),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Material(
                    color: theme.colorScheme.surfaceContainer,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ValRadius.card),
                      side: theme.brightness == Brightness.light
                          ? BorderSide(color: hairline)
                          : BorderSide.none,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final a in accounts) ...[
                          AccountTile(
                            key: ValueKey(a.puuid),
                            account: a,
                            selected: a.puuid == active,
                            onTap: () {
                              final router = GoRouter.of(context);
                              Navigator.of(context).pop();
                              if (a.needsLogin) {
                                unawaited(
                                  router.push(
                                    AuthRoutes.loginPath(reauthPuuid: a.puuid),
                                  ),
                                );
                              } else {
                                if (a.puuid != active) Haptics.selection();
                                ref
                                    .read(activePuuidProvider.notifier)
                                    .select(a.puuid);
                              }
                            },
                            onReauth: () {
                              final router = GoRouter.of(context);
                              Navigator.of(context).pop();
                              unawaited(
                                router.push(
                                  AuthRoutes.loginPath(reauthPuuid: a.puuid),
                                ),
                              );
                            },
                            onMore: () => unawaited(
                              showAccountActions(
                                context,
                                ref,
                                a,
                                onLeave: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ),
                          Divider(height: 1, thickness: 1, color: hairline),
                        ],
                        _AddAccountRow(
                          count: accounts.length,
                          max: max,
                          full: full,
                          onAdd: () {
                            final router = GoRouter.of(context);
                            Navigator.of(context).pop();
                            unawaited(router.push(AuthRoutes.login));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "+ Thêm tài khoản (n/10)": accent when there is room; at the limit it is
/// dimmed, explains why and tapping it shows the same message.
class _AddAccountRow extends StatelessWidget {
  const _AddAccountRow({
    required this.count,
    required this.max,
    required this.full,
    required this.onAdd,
  });

  final int count;
  final int max;
  final bool full;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final color = full ? muted : theme.colorScheme.primary;
    return Semantics(
      button: true,
      enabled: !full,
      child: InkWell(
        onTap: full
            ? () =>
                  showAppSnackBar(context, context.l10n.accountMaxAccounts(max))
            : onAdd,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    Icons.person_add_alt_1_outlined,
                    size: 22,
                    color: legibleAccent(context, color, min: 3),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.accountAddAccount(count, max),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: legibleAccent(context, color),
                        ),
                      ),
                      if (full)
                        Text(
                          context.l10n.accountMaxAccounts(max),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One account row (A4), the same in the account switcher and in Settings:
/// avatar with the live status dot, the Riot ID, the current rank and level,
/// then what the account is doing and its server (or "Cần đăng nhập lại").
/// On the right, on the same line: the active check or a "Đăng nhập lại"
/// chip, and the ⋮ menu ([onMore]). The active account has an accent wash
/// and a 4 px accent bar.
class AccountTile extends ConsumerWidget {
  const AccountTile({
    super.key,
    required this.account,
    this.selected = false,
    this.onTap,
    this.onReauth,
    this.onMore,
    this.showActivity = true,
  });

  final Account account;
  final bool selected;
  final VoidCallback? onTap;

  /// The "Đăng nhập lại" chip of an account whose session ended.
  final VoidCallback? onReauth;

  /// The ⋮ button (account actions); hidden when `null`.
  final VoidCallback? onMore;

  /// Checks and shows what the account is doing right now.
  final bool showActivity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final accent = theme.colorScheme.primary;
    final live = showActivity && !account.needsLogin;
    final activity = live
        ? ref.watch(accountActivityProvider(account.puuid)).value
        : null;
    // Loads (and caches on the account) the current rank of every listed
    // account, not only the ones already opened in the Profile tab.
    if (live) ref.watch(accountRankRefreshProvider(account.puuid));
    final tier = account.rankTier;
    final level = account.level;
    final small = theme.textTheme.bodySmall;
    final region = context.l10n.riotRegionName(account.region);

    // Rank and level: what players look at first after the name.
    final rankLine = Row(
      children: [
        if (tier != null)
          Flexible(
            child: RankBadge(
              tier: tier,
              seasonId: account.rankSeasonId,
              size: 18,
              singleLine: true,
              style: small?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (level != null)
          Flexible(
            child: Text(
              tier == null
                  ? context.l10n.accountLevelShort(level)
                  : ' · ${context.l10n.accountLevelShort(level)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: small?.copyWith(color: muted),
            ),
          ),
      ],
    );

    final Widget statusLine;
    if (account.needsLogin) {
      statusLine = Text(
        context.l10n.accountNeedsLogin,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: small?.copyWith(
          color: legibleAccent(context, colors.warning),
          fontWeight: FontWeight.w600,
        ),
      );
    } else if (activity == null || activity == AccountActivity.unknown) {
      statusLine = Text(
        region,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: small?.copyWith(color: muted),
      );
    } else {
      statusLine = Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: context.l10n.accountActivityName(activity),
              style: TextStyle(
                color: activity.color(context),
                fontWeight: activity.isOnline ? FontWeight.w700 : null,
              ),
            ),
            TextSpan(text: ' · $region'),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: small?.copyWith(color: muted),
      );
    }

    final reauth = onReauth;
    final more = onMore;
    final trailing = <Widget>[
      if (account.needsLogin && reauth != null)
        _ReauthChip(onPressed: reauth)
      else if (selected)
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4),
          child: Icon(
            Icons.check_circle,
            color: accent,
            semanticLabel: context.l10n.accountActive,
          ),
        ),
      if (more != null)
        IconButton(
          icon: Icon(Icons.adaptive.more),
          color: muted,
          tooltip: context.l10n.accountMoreActions(
            account.displayRiotId(context.l10n),
          ),
          onPressed: more,
        ),
    ];

    return Semantics(
      selected: selected,
      // A Material (not a coloured box) so the ink stays visible.
      child: Material(
        color: selected ? accent.withValues(alpha: 0.08) : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: BorderDirectional(
                start: BorderSide(
                  color: selected ? accent : Colors.transparent,
                  width: 4,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                12,
                12,
                more == null ? 16 : 4,
                12,
              ),
              child: Row(
                children: [
                  _StatusDot(
                    activity: activity,
                    child: AccountAvatar(
                      account: account,
                      size: 48,
                      circle: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          account.displayRiotId(context.l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                        if (tier != null || level != null) ...[
                          const SizedBox(height: 3),
                          rankLine,
                        ],
                        const SizedBox(height: 3),
                        statusLine,
                        if (account.showRegionMismatch && !account.needsLogin)
                          TextButton.icon(
                            onPressed: () => showRegionPicker(context, account),
                            icon: const Icon(Icons.sync_problem, size: 18),
                            label: Text(
                              context.l10n.settingsGeoReviewConnection,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (trailing.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    ...trailing,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Đăng nhập lại" on an account row whose session ended: a compact
/// warning-tinted icon (the status line already says why), so the Riot ID
/// keeps its room.
class _ReauthChip extends StatelessWidget {
  const _ReauthChip({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final warning = valColorsOf(context).warning;
    return IconButton(
      onPressed: onPressed,
      tooltip: context.l10n.commonSignInAgain,
      icon: const Icon(Icons.login_rounded, size: 20),
      color: legibleAccent(context, warning),
      style: IconButton.styleFrom(
        backgroundColor: warning.withValues(alpha: 0.16),
        fixedSize: const Size.square(36),
        minimumSize: const Size.square(36),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }
}

/// Green / amber / red dot on the avatar while the account's game runs.
class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.activity, required this.child});

  final AccountActivity? activity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final a = activity;
    if (a == null || !a.isOnline) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        PositionedDirectional(
          end: -1,
          bottom: -1,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: a.color(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
