import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/accounts/account_providers.dart';
import '../../../../core/accounts/account_widgets.dart';
import '../../../../core/auth/auth_routes.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/l10n/account_strings.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/error_view.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../settings_strings.dart';
import '../widgets/settings_widgets.dart';

/// "TÀI KHOẢN (n/10)" (S70, A4/A11): rows with the active marker, tap to
/// switch (or re-login when the session expired), trash with confirmation,
/// "+ Thêm tài khoản".
class SettingsAccountsSection extends ConsumerWidget {
  const SettingsAccountsSection({super.key});

  Future<void> _open(BuildContext context, WidgetRef ref, Account a) async {
    if (a.needsLogin) {
      await context.push(AuthRoutes.loginPath(reauthPuuid: a.puuid));
      return;
    }
    if (a.puuid == ref.read(activePuuidProvider)) return;
    ref.read(activePuuidProvider.notifier).select(a.puuid);
    showAppSnackBar(context, SettingsStrings.switchedTo(a.riotId));
  }

  Future<void> _remove(BuildContext context, WidgetRef ref, Account a) async {
    final ok = await confirmSettingsAction(
      context,
      title: AccountStrings.removeAccount,
      message: AccountStrings.removeAccountConfirm(a.riotId),
      confirmLabel: CommonStrings.delete,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    // Capture before the await: removing the last account redirects to
    // /welcome and unmounts this screen.
    final messenger = ScaffoldMessenger.maybeOf(context);
    await ref.read(accountsProvider.notifier).remove(a.puuid);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(SettingsStrings.removedAccount(a.riotId))),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    final active = ref.watch(activePuuidProvider);
    const max = AppConstants.maxAccounts;
    final full = accounts.length >= max;
    final scheme = Theme.of(context).colorScheme;
    return SettingsGroup(
      title: AccountStrings.accountsHeader(accounts.length, max),
      children: [
        if (accounts.isEmpty)
          ListTile(
            leading: SettingsIcon(
              Icons.person_off_outlined,
              color: scheme.onSurfaceVariant,
            ),
            title: const Text(CommonStrings.errorNoAccount),
          ),
        for (final a in accounts)
          _AccountRow(
            key: ValueKey(a.puuid),
            account: a,
            active: a.puuid == active,
            onTap: () => unawaited(_open(context, ref, a)),
            onReauth: () => unawaited(
              context.push(AuthRoutes.loginPath(reauthPuuid: a.puuid)),
            ),
            onRemove: () => unawaited(_remove(context, ref, a)),
          ),
        ListTile(
          leading: Icon(
            Icons.add,
            color: full ? scheme.onSurfaceVariant : scheme.primary,
          ),
          title: Text(
            AccountStrings.addAccount(accounts.length, max),
            style: TextStyle(
              color: full ? scheme.onSurfaceVariant : scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: full ? Text(AccountStrings.maxAccounts(max)) : null,
          onTap: full
              ? () => showAppSnackBar(context, AccountStrings.maxAccounts(max))
              : () => unawaited(context.push(AuthRoutes.login)),
        ),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    super.key,
    required this.account,
    required this.active,
    required this.onTap,
    required this.onReauth,
    required this.onRemove,
  });

  final Account account;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onReauth;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Active marker: a red accent bar (always) plus a check mark when there
    // is room. The tile is not `selected`: a red title would read like the
    // "Cần đăng nhập lại" error of another row.
    final tile = AccountTile(
      account: account,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (account.needsLogin)
            Tooltip(
              message: CommonStrings.signInAgain,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: onReauth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ValBadge(
                    CommonStrings.signInAgain,
                    color: valColorsOf(context).warning,
                    soft: true,
                  ),
                ),
              ),
            )
          else if (active)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.check,
                color: scheme.primary,
                semanticLabel: AccountStrings.active,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: scheme.onSurfaceVariant,
            tooltip: AccountStrings.removeAccount,
            onPressed: onRemove,
          ),
        ],
      ),
    );
    return Semantics(
      selected: active,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: active ? scheme.primary : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: tile,
      ),
    );
  }
}

/// Destructive "Đăng xuất tất cả tài khoản" button with confirmation.
class SettingsSignOutAllButton extends ConsumerWidget {
  const SettingsSignOutAllButton({super.key});

  Future<void> _signOutAll(BuildContext context, WidgetRef ref) async {
    final ok = await confirmSettingsAction(
      context,
      title: AccountStrings.signOutAll,
      message: AccountStrings.signOutAllConfirm,
      confirmLabel: AccountStrings.signOutAll,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    await ref.read(accountsProvider.notifier).signOutAll();
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text(SettingsStrings.signedOutAll)),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(hasAccountsProvider)) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.error,
          side: BorderSide(color: scheme.error.withValues(alpha: 0.6)),
          minimumSize: const Size.fromHeight(48),
        ),
        icon: const Icon(Icons.logout),
        label: const Text(
          AccountStrings.signOutAll,
          textAlign: TextAlign.center,
        ),
        onPressed: () => unawaited(_signOutAll(context, ref)),
      ),
    );
  }
}
