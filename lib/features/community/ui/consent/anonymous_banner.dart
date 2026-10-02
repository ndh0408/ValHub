import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import 'consent_sheet.dart';

/// Compact browsing status with an explicit join action. The consent sheet
/// explains data sharing before the account joins; public reads stay available.
class AnonymousBanner extends StatelessWidget {
  const AnonymousBanner({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('anonymous-banner'),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(ValRadius.card),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final message = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.visibility_off_outlined,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.communityAnonymousBanner,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          );
          final action = OutlinedButton(
            key: const ValueKey('consent-gate-action'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: () => unawaited(
              ensureCommunityConsent(context, account, askAgain: true),
            ),
            child: Text(context.l10n.communityConsentGateAction),
          );
          final inline =
              constraints.maxWidth >= 260 &&
              MediaQuery.textScalerOf(context).scale(14) <= 20;
          return inline
              ? Row(
                  children: [
                    Expanded(child: message),
                    const SizedBox(width: 12),
                    action,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    message,
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: action,
                    ),
                  ],
                );
        },
      ),
    );
  }
}
