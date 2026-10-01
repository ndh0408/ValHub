import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/geo/region_picker.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/accounts/sign_out_dialog.dart';
import '../../../../core/accounts/account_providers.dart';
import '../../../../core/accounts/account_status.dart';
import '../../../../core/accounts/login_note.dart';
import '../../../../core/accounts/login_note_sheet.dart';
import '../../../../core/accounts/account_widgets.dart';
import '../../../../core/auth/auth_routes.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/domain/competitive/rank.dart';
import '../../../../core/l10n/account_strings.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/error_view.dart';
import '../../settings_strings.dart';
import '../widgets/settings_widgets.dart';

/// "TÀI KHOẢN (n/10) · 2 ĐANG TRỰC TUYẾN" (S70, A4/A11): rows with the
/// active marker and each account's live status, tap to switch (or re-login
/// when the session expired), trash with confirmation, "+ Thêm tài khoản"
/// and the red "Đăng xuất tất cả tài khoản" row (with confirmation).
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
    final keep = await chooseSignOutRetention(
      context,
      title: AccountStrings.removeAccount,
      message: AccountStrings.removeAccountConfirm(a.riotId),
      confirmLabel: CommonStrings.delete,
    );
    if (keep == null || !context.mounted) return;
    // Capture before the await: removing the last account redirects to
    // /welcome and unmounts this screen.
    final messenger = ScaffoldMessenger.maybeOf(context);
    await ref
        .read(accountsProvider.notifier)
        .remove(a.puuid, keepLocalData: keep);
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
    final online = ref.watch(onlineAccountCountProvider);
    final header = AccountStrings.accountsHeader(accounts.length, max);
    return AccountActivityPoller(
      child: SettingsGroup(
        title: online > 0
            ? '$header · ${AccountStrings.onlineCount(online).toUpperCase()}'
            : header,
        children: [
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: const Text(AccountStrings.clearLocalData),
            onTap: () async {
              final ok = await confirmSettingsAction(
                context,
                title: AccountStrings.clearLocalData,
                message: AccountStrings.clearLocalDataConfirm,
                confirmLabel: CommonStrings.delete,
                destructive: true,
              );
              if (!ok || !context.mounted) return;
              await ref.read(accountsProvider.notifier).clearLocalData();
              if (context.mounted) {
                showAppSnackBar(context, AccountStrings.localDataCleared);
              }
            },
          ),
          if (active != null)
            ListTile(
              leading: const Icon(Icons.public_outlined),
              title: Text(context.l10n.settingsGeoConnection),
              subtitle: Text(
                ref.watch(accountProvider(active))!.needsRegionSelection
                    ? context.l10n.settingsGeoNoRegion
                    : AccountStrings.regionName(
                        ref.watch(accountProvider(active))!.region,
                      ),
              ),
              onTap: () =>
                  showRegionPicker(context, ref.read(accountProvider(active))!),
            ),
          if (active != null)
            ListTile(
              leading: const Icon(Icons.history_outlined),
              title: const Text(AccountStrings.clearRrHistory),
              onTap: () async {
                final ok = await confirmSettingsAction(
                  context,
                  title: AccountStrings.clearRrHistory,
                  message: AccountStrings.clearRrHistoryConfirm,
                  confirmLabel: CommonStrings.delete,
                  destructive: true,
                );
                if (!ok || !context.mounted) return;
                await ref.read(deleteRrHistoryProvider(active))();
                if (context.mounted) {
                  showAppSnackBar(context, AccountStrings.rrHistoryCleared);
                }
              },
            ),
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
              onNote: () => unawaited(showLoginNoteSheet(context, a)),
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
              AccountStrings.addAccount(accounts.length, max),
              style: TextStyle(
                color: full ? scheme.onSurfaceVariant : scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: full ? Text(AccountStrings.maxAccounts(max)) : null,
            onTap: full
                ? () =>
                      showAppSnackBar(context, AccountStrings.maxAccounts(max))
                : () => unawaited(context.push(AuthRoutes.login)),
          ),
          if (accounts.isNotEmpty) const SettingsSignOutAllRow(),
        ],
      ),
    );
  }
}

class _AccountRow extends ConsumerWidget {
  const _AccountRow({
    super.key,
    required this.account,
    required this.active,
    required this.onTap,
    required this.onReauth,
    required this.onRemove,
    required this.onNote,
  });

  final Account account;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onReauth;
  final VoidCallback onRemove;

  /// Opens the login note (saved username / password).
  final VoidCallback onNote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final hasNote =
        ref
            .watch(savedLoginNotesProvider(null))
            .value
            ?.any((entry) => entry.$1.puuid == account.puuid) ??
        false;
    // Active marker: a red accent bar (always) plus a check mark when there
    // is room. The tile is not `selected`: a red title would read like the
    // "Cần đăng nhập lại" error of another row.
    final tile = AccountTile(
      account: account,
      onTap: onTap,
      circleAvatar: false,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (account.needsLogin)
            IconButton(
              tooltip: CommonStrings.signInAgain,
              icon: const Icon(Icons.login),
              color: valColorsOf(context).warning,
              onPressed: onReauth,
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
            icon: Icon(hasNote ? Icons.key : Icons.key_outlined),
            color: hasNote ? scheme.primary : scheme.onSurfaceVariant,
            tooltip: hasNote
                ? AccountStrings.loginNote
                : AccountStrings.loginNoteEmpty,
            visualDensity: VisualDensity.compact,
            onPressed: onNote,
          ),
          // Red trash in a round red-tinted disc (48 dp target).
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: scheme.error,
            style: IconButton.styleFrom(
              backgroundColor: scheme.error.withValues(alpha: 0.14),
              side: BorderSide(color: scheme.error.withValues(alpha: 0.25)),
              fixedSize: const Size.square(38),
              minimumSize: const Size.square(38),
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
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
          border: BorderDirectional(
            start: BorderSide(
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

/// Destructive "Đăng xuất tất cả tài khoản" row (red, iOS-settings style)
/// at the end of the accounts card; asks for confirmation first.
class SettingsSignOutAllRow extends ConsumerWidget {
  const SettingsSignOutAllRow({super.key});

  Future<void> _signOutAll(BuildContext context, WidgetRef ref) async {
    final keep = await chooseSignOutRetention(
      context,
      title: AccountStrings.signOutAll,
      message: AccountStrings.signOutAllConfirm,
      confirmLabel: AccountStrings.signOutAll,
    );
    if (keep == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    await ref.read(accountsProvider.notifier).signOutAll(keepLocalData: keep);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text(SettingsStrings.signedOutAll)),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = Theme.of(context).colorScheme.error;
    return ListTile(
      minTileHeight: 56,
      leading: SizedBox(width: 44, child: Icon(Icons.logout, color: error)),
      title: Text(
        AccountStrings.signOutAll,
        style: TextStyle(color: error, fontWeight: FontWeight.w600),
      ),
      onTap: () => unawaited(_signOutAll(context, ref)),
    );
  }
}
