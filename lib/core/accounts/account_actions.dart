import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../auth/auth_routes.dart';
import '../geo/region_picker.dart';
import '../l10n/account_labels.dart';
import '../l10n/l10n.dart';
import '../ui/adaptive.dart';
import 'account.dart';
import 'account_providers.dart';
import 'login_note.dart';
import 'login_note_sheet.dart';
import 'sign_out_dialog.dart';

/// The ⋮ menu of an account row, the same in Settings and in the account
/// switcher: sign in again (when the session ended), the saved sign-in
/// info, the Riot connection, and remove (asks first). [onLeave] closes the
/// caller (the switcher sheet) before the app navigates away.
Future<void> showAccountActions(
  BuildContext context,
  WidgetRef ref,
  Account account, {
  VoidCallback? onLeave,
}) async {
  final l10n = context.l10n;
  final hasNote =
      ref
          .read(savedLoginNotesProvider(null))
          .value
          ?.any((entry) => entry.$1.puuid == account.puuid) ??
      false;
  final action = await showActionSheet<String>(
    context,
    title: account.displayRiotId(l10n),
    actions: [
      if (account.needsLogin)
        SheetAction(
          value: 'reauth',
          label: l10n.commonSignInAgain,
          icon: Icons.login,
        ),
      SheetAction(
        value: 'note',
        label: hasNote ? l10n.accountLoginNote : l10n.accountLoginNoteAdd,
        icon: hasNote ? Icons.key : Icons.key_outlined,
      ),
      SheetAction(
        value: 'region',
        label: l10n.settingsGeoConnection,
        icon: Icons.public_outlined,
      ),
      SheetAction(
        value: 'remove',
        label: l10n.accountRemoveAccount,
        icon: Icons.delete_outline,
        destructive: true,
      ),
    ],
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case 'reauth':
      final router = GoRouter.of(context);
      onLeave?.call();
      unawaited(router.push(AuthRoutes.loginPath(reauthPuuid: account.puuid)));
    case 'note':
      unawaited(showLoginNoteSheet(context, account));
    case 'region':
      unawaited(showRegionPicker(context, account));
    case 'remove':
      await removeAccountAfterConfirm(context, ref, account, onLeave: onLeave);
  }
}

/// "Xóa tài khoản": asks (and whether to keep this device's data), removes
/// the account, then confirms with a snackbar.
Future<void> removeAccountAfterConfirm(
  BuildContext context,
  WidgetRef ref,
  Account account, {
  VoidCallback? onLeave,
}) async {
  final l10n = context.l10n;
  final keep = await chooseSignOutRetention(
    context,
    title: l10n.accountRemoveAccount,
    message: l10n.accountRemoveAccountConfirm(account.displayRiotId(l10n)),
    confirmLabel: l10n.commonDelete,
  );
  if (keep == null || !context.mounted) return;
  // Captured before the await: removing the last account redirects to
  // /welcome and unmounts the caller.
  final messenger = ScaffoldMessenger.maybeOf(context);
  // The last account takes the app to /welcome: close the caller first.
  if (ref.read(accountsProvider).length <= 1) onLeave?.call();
  await ref
      .read(accountsProvider.notifier)
      .remove(account.puuid, keepLocalData: keep);
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.settingsRemovedAccount(account.displayRiotId(l10n))),
      ),
    );
}
