import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../auth/auth_routes.dart';
import '../config/app_constants.dart';
import '../content/content_repository.dart';
import '../l10n/account_strings.dart';
import '../l10n/common_strings.dart';
import '../theme/app_theme.dart';
import '../ui/error_view.dart';
import '../ui/net_image.dart';
import '../ui/rank_badge.dart';
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
      borderRadius: BorderRadius.circular(circle ? size / 2 : 6),
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
    return Semantics(
      button: true,
      label: AccountStrings.switcherTitle,
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => unawaited(showAccountSwitcherSheet(context)),
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
    );
  }
}

/// Opens the account switcher sheet (S05).
Future<void> showAccountSwitcherSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          const AccountActivityPoller(child: AccountSwitcherSheet()),
    );

/// Account list with the active marker, rank, "Cần đăng nhập lại" and
/// "Thêm tài khoản (n/10)".
class AccountSwitcherSheet extends ConsumerWidget {
  const AccountSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    final active = ref.watch(activePuuidProvider);
    final full = accounts.length >= AppConstants.maxAccounts;
    final online = ref.watch(onlineAccountCountProvider);
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  AccountStrings.switcherTitle,
                  style: theme.textTheme.titleLarge,
                ),
                if (online > 0) ...[
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      AccountStrings.onlineCount(online),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: valColorsOf(context).win,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final a in accounts)
                  AccountTile(
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
                        ref.read(activePuuidProvider.notifier).select(a.puuid);
                      }
                    },
                  ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            enabled: !full,
            leading: const Icon(Icons.person_add_alt_1_outlined),
            title: Text(
              AccountStrings.addAccount(
                accounts.length,
                AppConstants.maxAccounts,
              ),
            ),
            subtitle: full
                ? Text(AccountStrings.maxAccounts(AppConstants.maxAccounts))
                : null,
            onTap: full
                ? () => showAppSnackBar(
                    context,
                    AccountStrings.maxAccounts(AppConstants.maxAccounts),
                  )
                : () {
                    final router = GoRouter.of(context);
                    Navigator.of(context).pop();
                    unawaited(router.push(AuthRoutes.login));
                  },
          ),
          const SizedBox(height: 8),
        ],
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
  });

  final Account account;
  final bool selected;
  final VoidCallback? onTap;

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
      account.region.toUpperCase(),
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
            TextSpan(text: ' · $meta'),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: small?.copyWith(color: muted),
      );
    }
    return ListTile(
      onTap: onTap,
      selected: selected,
      isThreeLine: tier != null,
      leading: _StatusDot(
        activity: activity,
        child: AccountAvatar(account: account, size: 40, circle: true),
      ),
      title: Text(
        account.riotId,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: tier == null
          ? subtitle
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                subtitle,
                const SizedBox(height: 4),
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
            ),
      trailing:
          trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  semanticLabel: AccountStrings.active,
                ),
              if (account.needsLogin) ...[
                const SizedBox(width: 8),
                const Tooltip(
                  message: CommonStrings.signInAgain,
                  child: Icon(Icons.login),
                ),
              ],
            ],
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
