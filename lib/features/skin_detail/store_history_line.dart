import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/content/content_db.dart';
import '../../core/domain/economy/store_history.dart';
import '../store/store_routes.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// "Lên cửa hàng của bạn 3 lần · Chợ Đêm 1 lần ›" in the skin sheet: only
/// when this device saw [skin] in the account's own shops. It opens "Lịch
/// sử cửa hàng" (which also holds the clean-up).
class StoreHistoryLine extends ConsumerWidget {
  const StoreHistoryLine({super.key, required this.puuid, required this.skin});
  final String puuid;
  final WeaponSkin skin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(storeHistoryProvider(puuid)).value;
    final summary = history?.forSkin(skin.levels.map((l) => l.uuid));
    final daily = summary?.dailyDays ?? 0;
    final night = summary?.nightMarketRuns ?? 0;
    if (daily == 0 && night == 0) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        unawaited(router.push(StoreRoutes.history));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.history_rounded, size: 16, color: muted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                context.fmt.inlineFacts([
                  if (daily > 0) context.l10n.skinDetailSeenDaily(daily),
                  if (night > 0) context.l10n.skinDetailSeenNight(night),
                ]),
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: muted),
          ],
        ),
      ),
    );
  }
}
