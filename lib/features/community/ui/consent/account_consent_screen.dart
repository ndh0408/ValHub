import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account_providers.dart';
import '../../../../core/l10n/l10n.dart';
import '../../providers/consent_providers.dart';
import 'consent_sheet.dart';

/// Explicit, account-specific onboarding. The router resumes the pending route
/// only after persistence succeeds; no Community authentication happens here.
class AccountConsentScreen extends ConsumerStatefulWidget {
  const AccountConsentScreen({super.key});
  @override
  ConsumerState<AccountConsentScreen> createState() =>
      _AccountConsentScreenState();
}

class _AccountConsentScreenState extends ConsumerState<AccountConsentScreen> {
  bool _busy = false;

  Future<void> _decide(String puuid, {required bool agree}) async {
    if (_busy || ref.read(activeAccountProvider)?.puuid != puuid) return;
    setState(() => _busy = true);
    try {
      if (agree) {
        await ref.read(communityConsentProvider(puuid).notifier).grant();
      } else {
        // A visible alternative to acceptance, chosen explicitly by the user.
        await ref
            .read(accountsProvider.notifier)
            .remove(puuid, keepLocalData: true);
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.commonRetry)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(activeAccountProvider);
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(context.l10n.commonAppName),
        ),
        body: SafeArea(
          child: account == null
              ? const SizedBox.shrink()
              : CommunityConsentSheet(
                  key: ValueKey(account.puuid),
                  account: account,
                  onOpenDocument: openSettingsLegalDocument,
                  busy: _busy,
                  declineLabel: context.l10n.communityConsentExitAccount,
                  onAgree: () => unawaited(_decide(account.puuid, agree: true)),
                  onDecline: () =>
                      unawaited(_decide(account.puuid, agree: false)),
                ),
        ),
      ),
    );
  }
}
