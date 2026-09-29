import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/theme/app_theme.dart';
import '../../community_strings.dart';
import 'consent_sheet.dart';

/// "Bạn đang xem ẩn danh — tham gia để đăng bài, vote và tìm đồng đội"
/// with the "Xem lại và tham gia" button. Shown while the account has not
/// joined; browsing keeps working (public reads need no session).
class AnonymousBanner extends StatelessWidget {
  const AnonymousBanner({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('anonymous-banner'),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: ValColors.red.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(ValRadius.card),
        border: Border.all(color: ValColors.red.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.visibility_off_outlined,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text(CommunityStrings.anonymousBanner)),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton(
              key: const ValueKey('consent-gate-action'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () => unawaited(
                ensureCommunityConsent(context, account, askAgain: true),
              ),
              child: const Text(CommunityStrings.consentGateAction),
            ),
          ),
        ],
      ),
    );
  }
}
