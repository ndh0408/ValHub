import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/accounts/account_actions.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/account_labels.dart';
import '../../../../core/accounts/sign_out_dialog.dart';
import '../../../../core/accounts/account_providers.dart';
import '../../../../core/accounts/account_status.dart';
import '../../../../core/accounts/account_widgets.dart';
import '../../../../core/auth/auth_routes.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/ui/error_view.dart';
import '../widgets/settings_widgets.dart';

/// "TÀI KHOẢN (n/10) · 2 ĐANG TRỰC TUYẾN" (S70, A4/A11): rows with the
/// active marker and each account's live status, tap to switch (or re-login
/// when the session expired), one ⋮ menu per row (saved login, remove with
/// confirmation), "+ Thêm tài khoản" and the red "Đăng xuất tất cả tài
/// khoản" row (with confirmation). Data clean-up lives in "Dữ liệu trên
/// máy", the Riot connection in "Tùy chọn".
class SettingsAccountsSection extends ConsumerWidget {
  const SettingsAccountsSection({super.key});

  Future<void> _open(BuildContext context, WidgetRef ref, Account a) async {
    final l10n = context.l10n;
    if (a.needsLogin) {
      await context.push(AuthRoutes.loginPath(reauthPuuid: a.puuid));
      return;
    }
    if (a.puuid == ref.read(activePuuidProvider)) return;
    ref.read(activePuuidProvider.notifier).select(a.puuid);
    showAppSnackBar(context, l10n.settingsSwitchedTo(a.displayRiotId(l10n)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    final active = ref.watch(activePuuidProvider);
    const max = AppConstants.maxAccounts;
    final full = accounts.length >= max;
    final scheme = Theme.of(context).colorScheme;
    final online = ref.watch(onlineAccountCountProvider);
    final header = context.l10n.accountAccountsHeader(accounts.length, max);
    return AccountActivityPoller(
      child: SettingsGroup(
        title: online > 0
            ? '$header · ${context.l10n.accountOnlineCount(online).toUpperCase()}'
            : header,
        children: [
          if (accounts.isEmpty)
            ListTile(
              leading: SettingsIcon(
                Icons.person_off_outlined,
                color: scheme.onSurfaceVariant,
              ),
              title: Text(context.l10n.commonErrorNoAccount),
            ),
          for (final a in accounts)
            AccountTile(
              key: ValueKey(a.puuid),
              account: a,
              selected: a.puuid == active,
              onTap: () => unawaited(_open(context, ref, a)),
              onReauth: () => unawaited(
                context.push(AuthRoutes.loginPath(reauthPuuid: a.puuid)),
              ),
              onMore: () => unawaited(showAccountActions(context, ref, a)),
            ),
          ListTile(
            minTileHeight: 56,
            leading: SizedBox(
              width: 44,
              child: Icon(
                Icons.add_circle_outline,
                color: full ? scheme.onSurfaceVariant : scheme.primary,
              ),
            ),
            title: Text(
              context.l10n.accountAddAccount(accounts.length, max),
              style: TextStyle(
                color: full ? scheme.onSurfaceVariant : scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: full ? Text(context.l10n.accountMaxAccounts(max)) : null,
            onTap: full
                ? () => showAppSnackBar(
                    context,
                    context.l10n.accountMaxAccounts(max),
                  )
                : () => unawaited(context.push(AuthRoutes.login)),
          ),
          if (accounts.isNotEmpty) const SettingsSignOutAllRow(),
        ],
      ),
    );
  }
}

/// Destructive "Đăng xuất tất cả tài khoản" row (red, iOS-settings style)
/// at the end of the accounts card; asks for confirmation first.
class SettingsSignOutAllRow extends ConsumerWidget {
  const SettingsSignOutAllRow({super.key});

  Future<void> _signOutAll(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final keep = await chooseSignOutRetention(
      context,
      title: l10n.accountSignOutAll,
      message: l10n.accountSignOutAllConfirm,
      confirmLabel: l10n.accountSignOutAll,
    );
    if (keep == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    await ref.read(accountsProvider.notifier).signOutAll(keepLocalData: keep);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.settingsSignedOutAll)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = Theme.of(context).colorScheme.error;
    return ListTile(
      minTileHeight: 56,
      leading: SizedBox(width: 44, child: Icon(Icons.logout, color: error)),
      title: Text(
        context.l10n.accountSignOutAll,
        style: TextStyle(color: error, fontWeight: FontWeight.w600),
      ),
      onTap: () => unawaited(_signOutAll(context, ref)),
    );
  }
}
