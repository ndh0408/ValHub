import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../auth/auth_routes.dart';
import '../config/app_constants.dart';
import '../content/content_repository.dart';
import '../geo/region_picker.dart';
import '../l10n/account_strings.dart';
import '../l10n/common_strings.dart';
import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../ui/adaptive.dart';
import '../ui/error_view.dart';
import '../ui/net_image.dart';
import '../ui/rank_badge.dart';
import '../ui/sub_page.dart';
import '../ui/val_widgets.dart';
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
    final name = account.gameName.isEmpty ? account.riotId : account.gameName;
    // The pill is 38 dp tall; the tap target (and its semantics node) is
    // 48 dp: a 5 dp band above and below belongs to the button.
    return Semantics(
      button: true,
      label: AccountStrings.switcherTitle,
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
                padding: EdgeInsets.fromLTRB(4, 4, showName ? 12 : 4, 4),
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
/// button and the online count, one grouped card of rows (active account =
/// 4 px red bar + check, "Đăng nhập lại" badge when the session died) ending
/// with "Thêm tài khoản". Scrolls when there are many accounts.
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
            title: AccountStrings.switcherTitleCount(accounts.length, max),
            subtitle: AccountStrings.switcherSubtitle,
            actions: [
              if (online > 0)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: StatusPill(
                      label: AccountStrings.onlineCount(online),
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
                          _ActiveHighlight(
                            key: ValueKey(a.puuid),
                            active: a.puuid == active,
                            child: AccountTile(
                              account: a,
                              selected: a.puuid == active,
                              onTap: () {
                                final router = GoRouter.of(context);
                                Navigator.of(context).pop();
                                if (a.needsLogin) {
                                  unawaited(
                                    router.push(
                                      AuthRoutes.loginPath(
                                        reauthPuuid: a.puuid,
                                      ),
                                    ),
                                  );
                                } else {
                                  if (a.puuid != active) Haptics.selection();
                                  ref
                                      .read(activePuuidProvider.notifier)
                                      .select(a.puuid);
                                }
                              },
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                    child: Text(
                      AccountStrings.manageHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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
            ? () => showAppSnackBar(context, AccountStrings.maxAccounts(max))
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
                        AccountStrings.addAccount(count, max),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: legibleAccent(context, color),
                        ),
                      ),
                      if (full)
                        Text(
                          AccountStrings.maxAccounts(max),
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

/// Active account marker in the switcher: 4 px accent strip and a faint
/// accent wash behind the row.
class _ActiveHighlight extends StatelessWidget {
  const _ActiveHighlight({
    super.key,
    required this.active,
    required this.child,
  });

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    // A Material (not a colored box) so the ListTile ink stays visible.
    return Material(
      color: active ? accent.withValues(alpha: 0.08) : Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: BorderDirectional(
            start: BorderSide(
              color: active ? accent : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// One account row (A4): avatar with a live status dot, Riot ID,
/// "Đang đấu · AP · Cấp 222", current rank (icon + name), markers. Also usable in the settings
/// account list.
class AccountTile extends ConsumerWidget {
  const AccountTile({
    super.key,
    required this.account,
    this.selected = false,
    this.onTap,
    this.trailing,
    this.showActivity = true,
    this.circleAvatar = true,
  });

  final Account account;
  final bool selected;
  final VoidCallback? onTap;

  /// Round avatar (switcher) or the rounded-square player card (settings).
  final bool circleAvatar;

  /// Replaces the default check mark (e.g. a delete button in settings).
  final Widget? trailing;

  /// Checks and shows what the account is doing right now.
  final bool showActivity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final live = showActivity && !account.needsLogin;
    final activity = live
        ? ref.watch(accountActivityProvider(account.puuid)).value
        : null;
    // Loads (and caches on the account) the current rank of every listed
    // account, not only the ones already opened in the Profile tab.
    if (live) ref.watch(accountRankRefreshProvider(account.puuid));
    final tier = account.rankTier;
    final meta = [
      if (account.level != null) AccountStrings.levelShort(account.level!),
    ].join(' · ');
    final small = theme.textTheme.bodySmall;
    final Widget subtitle;
    if (account.needsLogin) {
      subtitle = Text(
        AccountStrings.needsLogin,
        style: small?.copyWith(color: valColorsOf(context).warning),
      );
    } else if (activity == null || activity == AccountActivity.unknown) {
      subtitle = Text(meta, style: small?.copyWith(color: muted));
    } else {
      subtitle = Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: activity.label,
              style: TextStyle(
                color: activity.color(context),
                fontWeight: activity.isOnline ? FontWeight.w700 : null,
              ),
            ),
            if (meta.isNotEmpty) TextSpan(text: ' · $meta'),
          ],
        ),
        style: small?.copyWith(color: muted),
      );
    }
    final end =
        trailing ??
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 132),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  semanticLabel: AccountStrings.active,
                ),
              if (account.needsLogin) ...[
                if (selected) const SizedBox(width: 8),
                Flexible(
                  child: Tooltip(
                    message: CommonStrings.signInAgain,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ValBadge(
                        CommonStrings.signInAgain,
                        color: valColorsOf(context).warning,
                        soft: true,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
    return Semantics(
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusDot(
                activity: activity,
                child: AccountAvatar(
                  account: account,
                  size: 44,
                  circle: circleAvatar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      account.riotId,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    subtitle,
                    Text(
                      AccountStrings.regionName(account.region),
                      style: small?.copyWith(color: muted),
                    ),
                    if (tier != null) ...[
                      const SizedBox(height: 6),
                      RankBadge(
                        tier: tier,
                        seasonId: account.rankSeasonId,
                        size: 20,
                        style: small?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (trailing != null) ...[const SizedBox(height: 8), end],
                    if (account.showRegionMismatch && !account.needsLogin)
                      TextButton.icon(
                        onPressed: () => showRegionPicker(context, account),
                        icon: const Icon(Icons.sync_problem, size: 18),
                        label: Text(context.l10n.settingsGeoReviewConnection),
                      ),
                  ],
                ),
              ),
              if (trailing == null) ...[const SizedBox(width: 8), end],
            ],
          ),
        ),
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
        Positioned(
          right: -1,
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
