import '../../../../core/l10n/labels/loadout_labels.dart';

import 'package:valvn/core/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/auth/auth_routes.dart';
import '../../../../core/domain/loadout/loadout.dart';
import '../../../../core/ui/error_view.dart';

/// Saves [change] for [puuid] after an explicit user action and reports the
/// outcome in a snackbar: [successMessage] on success, "Không thể lưu trang
/// bị" + the reason on failure (with "Đăng nhập lại" when the session died).
/// Returns whether it was saved.
Future<bool> applyLoadoutChange(
  BuildContext context,
  WidgetRef ref, {
  required String puuid,
  required LoadoutChange change,
  String? successMessage,
}) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.maybeOf(context);
  final router = GoRouter.maybeOf(context);
  try {
    await ref.read(loadoutProvider(puuid).notifier).apply(change);
    if (successMessage != null) {
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(successMessage)));
    }
    return true;
  } on LoadoutSaveException catch (e) {
    showLoadoutSaveError(l10n, messenger, router, e, puuid: puuid);
    return false;
  }
}

/// Snackbar for a failed save.
void showLoadoutSaveError(
  AppLocalizations l10n,
  ScaffoldMessengerState? messenger,
  GoRouter? router,
  LoadoutSaveException e, {
  required String puuid,
}) {
  final cause = e.cause;
  final detail =
      e.detail(l10n) ??
      (cause == null || cause is LoadoutEditException
          ? null
          : describeError(l10n, cause).message);
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          detail == null
              ? l10n.collectionSaveFailed
              : l10n.collectionSaveFailedWith(detail),
        ),
        action: e.needsLogin && router != null
            ? SnackBarAction(
                label: l10n.commonSignInAgain,
                onPressed: () =>
                    router.push(AuthRoutes.loginPath(reauthPuuid: puuid)),
              )
            : null,
      ),
    );
}

/// Shows a plain snackbar through [messenger].
void showCollectionSnack(
  ScaffoldMessengerState? messenger,
  String message, {
  SnackBarAction? action,
}) {
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), action: action));
}
