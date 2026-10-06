import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/l10n.dart';

import '../accounts/account_providers.dart';
import '../auth/auth_routes.dart';
import '../theme/app_theme.dart';
import '../util/clock.dart';
import '../util/format.dart';

/// "Showing the saved copy" strip above data served from the offline cache
/// (store, bundle, Battle Pass). It names the actual cause: an expired
/// sign-in gets "Đăng nhập lại", anything else (no network, Riot down) the
/// offline line; the save time carries the day when it is not today, since
/// a saved copy can be days old.
class SavedCopyNotice extends ConsumerWidget {
  const SavedCopyNotice({
    super.key,
    required this.puuid,
    required this.receivedAt,
  });

  final String puuid;
  final DateTime receivedAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final warning = valColorsOf(context).warning;
    final text = legibleAccent(context, warning);
    final now = ref.watch(clockProvider).now();
    final needsLogin = ref.watch(
      accountProvider(puuid).select((a) => a?.needsLogin ?? false),
    );
    final at = receivedAt.toLocal();
    final when = calendarDayDifference(at, now.toLocal()) == 0
        ? context.fmt.time(at)
        : '${context.fmt.time(at)}, ${context.fmt.dayMonth(at)}';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: EdgeInsetsDirectional.fromSTEB(12, 8, needsLogin ? 4 : 12, 8),
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ValRadius.small),
      ),
      child: Row(
        children: [
          Icon(
            needsLogin ? Icons.lock_clock_outlined : Icons.cloud_off,
            size: 16,
            color: text,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              needsLogin
                  ? context.l10n.commonSavedCopyNeedsLogin(when)
                  : context.l10n.commonOfflineCached(when),
              style: theme.textTheme.bodySmall?.copyWith(color: text),
            ),
          ),
          if (needsLogin)
            TextButton(
              onPressed: () => unawaited(
                context.push(AuthRoutes.loginPath(reauthPuuid: puuid)),
              ),
              child: Text(context.l10n.commonSignInAgain),
            ),
        ],
      ),
    );
  }
}
