import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/auth/auth_routes.dart';
import '../../../../core/domain/loadout/loadout.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/ui/error_view.dart';
import '../../collection_strings.dart';

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
    showLoadoutSaveError(messenger, router, e, puuid: puuid);
    return false;
  }
}

/// Snackbar for a failed save.
void showLoadoutSaveError(
  ScaffoldMessengerState? messenger,
  GoRouter? router,
  LoadoutSaveException e, {
  required String puuid,
}) {
  final cause = e.cause;
  final detail =
      e.detail ??
      (cause == null || cause is LoadoutEditException
          ? null
          : describeError(cause).message);
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          detail == null
              ? CollectionStrings.saveFailed
              : CollectionStrings.saveFailedWith(detail),
        ),
        action: e.needsLogin && router != null
            ? SnackBarAction(
                label: CommonStrings.signInAgain,
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
