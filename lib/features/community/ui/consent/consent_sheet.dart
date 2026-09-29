import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/accounts/account_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../settings/legal/legal_documents.dart';
import '../../../settings/settings_routes.dart';
import '../../community_strings.dart';
import '../../providers/consent_providers.dart';

/// Opens a legal document of Settings ("Chính sách quyền riêng tư", "Tiêu
/// chuẩn cộng đồng") from the consent sheet.
typedef OpenLegalDocument = void Function(BuildContext context, String docId);

/// Default: the About → legal routes of Settings (no-op without a router).
void openSettingsLegalDocument(BuildContext context, String docId) {
  final router = GoRouter.maybeOf(context);
  if (router == null) return;
  final doc = LegalDocuments.all.where((d) => d.id == docId).firstOrNull;
  if (doc != null) unawaited(router.push<void>(SettingsRoutes.legal(doc)));
}

/// Makes sure [account] agreed to share their Riot ID with the community
/// server, asking once (before the first `POST /v1/auth/riot`). Resolves to
/// `true` when consent exists (already given, or given now). "Để sau" and
/// dismissing are remembered as declined, so the sheet is not shown again
/// by itself; pass [askAgain] to show it anyway (explicit "Xem lại và tham
/// gia").
Future<bool> ensureCommunityConsent(
  BuildContext context,
  Account account, {
  OpenLegalDocument onOpenDocument = openSettingsLegalDocument,
  bool askAgain = false,
}) async {
  final container = ProviderScope.containerOf(context);
  final state = container.read(communityConsentProvider(account.puuid));
  if (state == CommunityConsent.granted) return true;
  if (state == CommunityConsent.declined && !askAgain) return false;
  final agreed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) =>
        CommunityConsentSheet(account: account, onOpenDocument: onOpenDocument),
  );
  final notifier = container.read(
    communityConsentProvider(account.puuid).notifier,
  );
  if (agreed ?? false) {
    await notifier.grant();
    return true;
  }
  await notifier.decline();
  return false;
}

/// Asks the active account (used when an action failed because consent is
/// missing, or before an action that needs a community session).
Future<bool> promptConsentFromContext(BuildContext context) {
  final account = ProviderScope.containerOf(context)
      .read(activeAccountProvider);
  if (account == null) return Future.value(false);
  return ensureCommunityConsent(context, account, askAgain: true);
}

/// The one-time explanation: what is sent, what others see, what never
/// leaves the device.
class CommunityConsentSheet extends StatelessWidget {
  const CommunityConsentSheet({
    super.key,
    required this.account,
    required this.onOpenDocument,
  });

  final Account account;
  final OpenLegalDocument onOpenDocument;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ValColors.red.withValues(alpha: 0.14),
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                size: 34,
                color: ValColors.red,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            CommunityStrings.consentTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            CommunityStrings.consentAccount(account.riotId),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
          const SizedBox(height: 20),
          const _Point(
            icon: Icons.lock_outline_rounded,
            text: CommunityStrings.consentVerify,
          ),
          const _Point(
            icon: Icons.visibility_outlined,
            text: CommunityStrings.consentPublic,
          ),
          const _Point(
            icon: Icons.phonelink_lock_outlined,
            text: CommunityStrings.consentLocal,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            children: [
              TextButton(
                key: const ValueKey('consent-privacy'),
                onPressed: () =>
                    onOpenDocument(context, LegalDocuments.privacy.id),
                child: const Text(CommunityStrings.consentPrivacy),
              ),
              TextButton(
                key: const ValueKey('consent-guidelines'),
                onPressed: () =>
                    onOpenDocument(context, LegalDocuments.community.id),
                child: const Text(CommunityStrings.consentGuidelines),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: FilledButton(
              key: const ValueKey('consent-agree'),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(CommunityStrings.consentAgree),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            key: const ValueKey('consent-later'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(CommunityStrings.consentLater),
          ),
        ],
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
