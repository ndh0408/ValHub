import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../auth/auth_routes.dart';
import '../l10n/common_strings.dart';
import '../network/error_classifier.dart';
import '../network/riot_exception.dart';
import '../theme/app_theme.dart';
import '../util/format.dart';
import 'empty_view.dart';

import 'package:valvn/core/l10n/l10n.dart';

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
    UnsupportedRegionException() => const ErrorDescription(
      message: CommonStrings.errorUnsupportedRegion,
      canRetry: false,
      icon: Icons.public_off_outlined,
    ),
    NeedsLoginException(:final puuid) => ErrorDescription(
      title: CommonStrings.errorNeedsLoginTitle,
      message: CommonStrings.errorNeedsLogin,
      needsLogin: true,
      puuid: puuid,
      canRetry: false,
      icon: Icons.lock_clock_outlined,
    ),
    // Riot's own message is English: it stays in the exception (debug
    // only); the UI always shows the Vietnamese copy.
    MaintenanceException() => ErrorDescription(
      title: CommonStrings.maintenanceTitle,
      message: CommonStrings.errorMaintenance,
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
    final button = error is UnsupportedRegionException
        ? FilledButton(
            onPressed: () => context.push('/settings'),
            child: Text(context.l10n.commonTabSettings),
          )
        : d.needsLogin
        ? FilledButton(
            onPressed: () => context.push(
              AuthRoutes.loginPath(reauthPuuid: d.puuid ?? puuid),
            ),
            child: Text(context.l10n.commonSignInAgain),
          )
        : (onRetry != null && d.canRetry)
        ? OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.commonRetry),
          )
        : null;

    if (compact) {
      final error = theme.colorScheme.error;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          decoration: BoxDecoration(
            color: error.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(ValRadius.small),
            border: Border.all(color: error.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(d.icon, color: error, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      d.title ?? d.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (d.title != null)
                      Text(
                        d.message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (d.needsLogin)
                TextButton(
                  onPressed: () => context.push(
                    AuthRoutes.loginPath(reauthPuuid: d.puuid ?? puuid),
                  ),
                  child: Text(context.l10n.commonSignInAgain),
                )
              else if (onRetry != null && d.canRetry)
                TextButton(
                  onPressed: onRetry,
                  child: Text(context.l10n.commonRetry),
                ),
            ],
          ),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StateIcon(icon: d.icon, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              if (d.title != null) ...[
                Text(
                  d.title!,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
              ],
              Text(
                d.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              if (button != null) ...[const SizedBox(height: 20), button],
            ],
          ),
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
