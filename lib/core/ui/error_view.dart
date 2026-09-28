import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../auth/auth_routes.dart';
import '../l10n/common_strings.dart';
import '../network/error_classifier.dart';
import '../network/riot_exception.dart';
import '../util/format.dart';

/// User-facing description of an error.
@immutable
class ErrorDescription {
  const ErrorDescription({
    required this.message,
    this.title,
    this.needsLogin = false,
    this.puuid,
    this.canRetry = true,
    this.icon = Icons.error_outline,
  });

  final String? title;
  final String message;

  /// Show "Đăng nhập lại" (→ `/login?reauth=<puuid>`) instead of retry.
  final bool needsLogin;
  final String? puuid;
  final bool canRetry;
  final IconData icon;
}

/// Maps any error (preferably a [RiotException]) to Vietnamese copy
/// (VF §8.13, riot-auth §3.5).
ErrorDescription describeError(Object error) {
  final e = error is RiotException ? error : classifyError(error);
  return switch (e) {
    NeedsLoginException(:final puuid) => ErrorDescription(
      title: CommonStrings.errorNeedsLoginTitle,
      message: CommonStrings.errorNeedsLogin,
      needsLogin: true,
      puuid: puuid,
      canRetry: false,
      icon: Icons.lock_clock_outlined,
    ),
    MaintenanceException(:final message) => ErrorDescription(
      title: CommonStrings.maintenanceTitle,
      message: message ?? CommonStrings.errorMaintenance,
      icon: Icons.construction_outlined,
    ),
    TransientException(:final retryAfter, :final reason) => ErrorDescription(
      message: switch (reason) {
        'timeout' => CommonStrings.errorTimeout,
        'network' => CommonStrings.errorNetwork,
        'content_unavailable' => CommonStrings.errorContentUnavailable,
        _ when retryAfter != null && retryAfter > const Duration(seconds: 5) =>
          CommonStrings.errorTransientRetryIn(formatDurationCoarse(retryAfter)),
        _ => CommonStrings.errorTransient,
      },
      icon: reason == 'network' || reason == 'timeout'
          ? Icons.wifi_off_outlined
          : Icons.cloud_off_outlined,
    ),
    NotFoundException() => const ErrorDescription(
      message: CommonStrings.errorNotFound,
      icon: Icons.search_off_outlined,
    ),
    RiotApiException(:final status) => ErrorDescription(
      message: CommonStrings.errorApi(status),
    ),
  };
}

/// Full-area error state with "Thử lại" (or "Đăng nhập lại" for
/// [NeedsLoginException]).
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.puuid,
    this.compact = false,
  });

  final Object error;
  final VoidCallback? onRetry;

  /// Account to re-login when the error does not carry one.
  final String? puuid;

  /// Inline (row) variant for use inside lists.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final d = describeError(error);
    final theme = Theme.of(context);
    final button = d.needsLogin
        ? FilledButton(
            onPressed: () => context.push(
              AuthRoutes.loginPath(reauthPuuid: d.puuid ?? puuid),
            ),
            child: const Text(CommonStrings.signInAgain),
          )
        : (onRetry != null && d.canRetry)
        ? OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text(CommonStrings.retry),
          )
        : null;

    if (compact) {
      return ListTile(
        leading: Icon(d.icon, color: theme.colorScheme.error),
        title: Text(d.title ?? d.message),
        subtitle: d.title == null ? null : Text(d.message),
        trailing: button,
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(d.icon, size: 40, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            if (d.title != null) ...[
              Text(
                d.title!,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
            ],
            Text(
              d.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (button != null) ...[const SizedBox(height: 16), button],
          ],
        ),
      ),
    );
  }
}

/// Shows a floating snackbar with [message].
void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
