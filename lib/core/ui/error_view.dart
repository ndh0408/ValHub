import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../auth/auth_routes.dart';
import '../network/error_classifier.dart';
import '../network/riot_exception.dart';
import '../theme/app_theme.dart';
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

/// Maps any error (preferably a [RiotException]) to the supplied UI language
/// (VF §8.13, riot-auth §3.5).
ErrorDescription describeError(AppLocalizations l10n, Object error) {
  final e = error is RiotException ? error : classifyError(error);
  return switch (e) {
    UnsupportedRegionException() => ErrorDescription(
      message: l10n.commonErrorUnsupportedRegion,
      canRetry: false,
      icon: Icons.public_off_outlined,
    ),
    NeedsLoginException(:final puuid) => ErrorDescription(
      title: l10n.commonErrorNeedsLoginTitle,
      message: l10n.commonErrorNeedsLogin,
      needsLogin: true,
      puuid: puuid,
      canRetry: false,
      icon: Icons.lock_clock_outlined,
    ),
    // Riot's own message is English: it stays in the exception (debug
    // only); the UI always shows its own localized copy.
    MaintenanceException() => ErrorDescription(
      title: l10n.commonMaintenanceTitle,
      message: l10n.commonErrorMaintenance,
      icon: Icons.construction_outlined,
    ),
    TransientException(:final retryAfter, :final reason) => ErrorDescription(
      message: switch (reason) {
        'timeout' => l10n.commonErrorTimeout,
        'network' => l10n.commonErrorNetwork,
        'content_unavailable' => l10n.commonErrorContentUnavailable,
        _ when retryAfter != null && retryAfter > const Duration(seconds: 5) =>
          l10n.commonErrorTransientRetryIn(
            describeRetryDelay(l10n, retryAfter),
          ),
        _ => l10n.commonErrorTransient,
      },
      icon: reason == 'network' || reason == 'timeout'
          ? Icons.wifi_off_outlined
          : Icons.cloud_off_outlined,
    ),
    NotFoundException() => ErrorDescription(
      message: l10n.commonErrorNotFound,
      icon: Icons.search_off_outlined,
    ),
    RiotApiException() => ErrorDescription(message: l10n.commonErrorApi),
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
    final d = describeError(context.l10n, error);
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
          padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 8, 10),
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
                flex: 3,
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
              // Long labels ("Erneut versuchen") wrap instead of pushing
              // the row past the card edge.
              if (d.needsLogin)
                Flexible(
                  flex: 2,
                  child: TextButton(
                    onPressed: () => context.push(
                      AuthRoutes.loginPath(reauthPuuid: d.puuid ?? puuid),
                    ),
                    child: Text(
                      context.l10n.commonSignInAgain,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (onRetry != null && d.canRetry)
                Flexible(
                  flex: 2,
                  child: TextButton(
                    onPressed: onRetry,
                    child: Text(
                      context.l10n.commonRetry,
                      textAlign: TextAlign.center,
                    ),
                  ),
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

/// Coarse retry delay from the same resources as the error message.
String describeRetryDelay(AppLocalizations l10n, Duration duration) {
  if (duration.isNegative) duration = Duration.zero;
  if (duration.inDays >= 1) return l10n.commonDays(duration.inDays);
  if (duration.inHours >= 1) return l10n.commonHours(duration.inHours);
  if (duration.inMinutes >= 1) return l10n.commonMinutes(duration.inMinutes);
  return l10n.commonSeconds(duration.inSeconds);
}
