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
      builder: (_) => const AccountSwitcherSheet(),
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
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              AccountStrings.switcherTitle,
              style: theme.textTheme.titleLarge,
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

/// One account row (A4): avatar, Riot ID, "AP · Cấp 222", rank, markers.
/// Also usable in the settings account list.
class AccountTile extends StatelessWidget {
  const AccountTile({
    super.key,
    required this.account,
    this.selected = false,
    this.onTap,
    this.trailing,
  });

  final Account account;
  final bool selected;
  final VoidCallback? onTap;

  /// Replaces the default check mark (e.g. a delete button in settings).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = [
      account.region.toUpperCase(),
      if (account.level != null) AccountStrings.levelShort(account.level!),
    ].join(' · ');
    return ListTile(
      onTap: onTap,
      selected: selected,
      leading: AccountAvatar(account: account, size: 40, circle: true),
      title: Text(
        account.riotId,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: account.needsLogin
          ? Text(
              AccountStrings.needsLogin,
              style: theme.textTheme.bodySmall?.copyWith(
                color: valColorsOf(context).warning,
              ),
            )
          : Text(
              meta,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
      trailing:
          trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (account.rankTier != null && account.rankTier! > 2)
                RankBadge(
                  tier: account.rankTier!,
                  seasonId: account.rankSeasonId,
                  size: 28,
                  showName: false,
                ),
              if (selected) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  semanticLabel: AccountStrings.active,
                ),
              ],
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
