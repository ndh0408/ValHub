import 'package:material_ui/material_ui.dart' hide ErrorDescription;

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/labels/community_labels.dart';
import '../../../core/ui/error_view.dart';
import '../data/community_exception.dart';

/// Localized copy for any error of the community feature: community
/// errors get their own messages, Riot errors (e.g. `NeedsLoginException`
/// while signing in) keep the app-wide ones.
ErrorDescription describeCommunityError(AppLocalizations l10n, Object error) {
  if (error is! CommunityException) return describeError(l10n, error);
  final e = error;
  // A known reason explains the refusal whatever the HTTP code carries it
  // (`skin_not_owned` arrives as `forbidden`, a full image quota as
  // `invalid_input`); only local copy is shown, never the server's text.
  final reasonMessage = e.reason == 'quota_exceeded'
      ? l10n.communityErrorImageQuota
      : l10n.communityModerationReason(e.reason);
  if (reasonMessage != null) {
    return ErrorDescription(
      message: reasonMessage,
      icon: switch (e.reason) {
        'skin_not_owned' ||
        'ownership_unavailable' => Icons.verified_user_outlined,
        'quota_exceeded' => Icons.photo_library_outlined,
        _ when e.code == 'suspended' => Icons.block_outlined,
        _ => Icons.edit_note_outlined,
      },
      canRetry: false,
    );
  }
  return switch (e.code) {
    CommunityException.network => ErrorDescription(
      message: l10n.communityErrorNetwork,
      icon: Icons.wifi_off_outlined,
    ),
    CommunityException.timeout => ErrorDescription(
      message: l10n.communityErrorTimeout,
      icon: Icons.wifi_off_outlined,
    ),
    CommunityException.rateLimited => ErrorDescription(
      title: l10n.communityRateLimitedTitle,
      message: e.retryAfter == null
          ? l10n.communityErrorRateLimited
          : l10n.communityErrorRateLimitedIn(
              describeRetryDelay(l10n, e.retryAfter!),
            ),
      icon: Icons.hourglass_top_rounded,
    ),
    CommunityException.riotUnavailable => ErrorDescription(
      title: l10n.communityRiotUnavailableTitle,
      message: e.retryAfter == null
          ? l10n.communityErrorRiotUnavailable
          : l10n.communityErrorRiotUnavailableIn(
              describeRetryDelay(l10n, e.retryAfter!),
            ),
      icon: Icons.cloud_off_outlined,
    ),
    CommunityException.storageFull => ErrorDescription(
      message: l10n.communityErrorStorageFull,
      icon: Icons.cloud_off_outlined,
      canRetry: false,
    ),
    CommunityException.riotRejected => ErrorDescription(
      message: l10n.communityErrorRiotRejected,
      icon: Icons.verified_user_outlined,
    ),
    CommunityException.unauthorized => ErrorDescription(
      message: l10n.communityErrorUnauthorized,
      icon: Icons.lock_clock_outlined,
    ),
    CommunityException.forbidden => ErrorDescription(
      message: l10n.communityErrorForbidden,
      icon: Icons.block_outlined,
      canRetry: false,
    ),
    CommunityException.notFound => ErrorDescription(
      message: l10n.communityErrorNotFound,
      icon: Icons.search_off_outlined,
      canRetry: false,
    ),
    CommunityException.invalidInput => ErrorDescription(
      message: l10n.communityErrorInvalid,
      icon: Icons.edit_note_outlined,
      canRetry: false,
    ),
    CommunityException.imageTooLarge => ErrorDescription(
      message: l10n.communityErrorImageTooLarge,
      icon: Icons.photo_size_select_large_outlined,
      canRetry: false,
    ),
    CommunityException.imageType => ErrorDescription(
      message: l10n.communityErrorImageType,
      icon: Icons.image_not_supported_outlined,
      canRetry: false,
    ),
    CommunityException.consentRequired => ErrorDescription(
      message: l10n.communityErrorConsent,
      icon: Icons.verified_user_outlined,
      canRetry: false,
    ),
    CommunityException.disabled => ErrorDescription(
      message: l10n.communityUnavailableBody,
      icon: Icons.cloud_off_outlined,
      canRetry: false,
    ),
    'suspended' => ErrorDescription(
      message: l10n.communityErrorForbidden,
      icon: Icons.block_outlined,
      canRetry: false,
    ),
    'server_busy' => ErrorDescription(
      message: e.retryAfter == null
          ? l10n.communityErrorServer
          : l10n.communityErrorRateLimitedIn(
              describeRetryDelay(l10n, e.retryAfter!),
            ),
      icon: Icons.cloud_off_outlined,
    ),
    _ => ErrorDescription(
      message: l10n.communityErrorServer,
      icon: Icons.cloud_off_outlined,
    ),
  };
}
