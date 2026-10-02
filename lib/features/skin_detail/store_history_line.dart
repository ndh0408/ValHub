import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/content/content_db.dart';
import '../../core/domain/economy/store_history.dart';
import '../../core/l10n/common_strings.dart';
import '../../core/ui/adaptive.dart';
import '../../core/util/format.dart';
import 'skin_detail_strings.dart';

import 'package:valvn/core/l10n/l10n.dart';

class StoreHistoryLine extends ConsumerWidget {
  const StoreHistoryLine({super.key, required this.puuid, required this.skin});
  final String puuid;
  final WeaponSkin skin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(storeHistoryProvider(puuid)).value;
    final summary = history?.forSkin(skin.levels.map((l) => l.uuid));
    final since = summary?.recordingSince;
    if (summary == null || since == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.skinDetailHistory(
            summary.dailyDays,
            summary.nightMarketRuns,
            formatDate(since.toLocal()),
          ),
        ),
        TextButton.icon(
          icon: const Icon(Icons.delete_outline),
          label: Text(context.l10n.skinDetailHistoryDelete),
          onPressed: () => unawaited(_delete(context, ref)),
        ),
      ],
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final store = ref.read(storeHistoryStoreProvider);
    final confirmed = await showConfirmDialog(
      context,
      title: SkinDetailStrings.historyDelete,
      message: SkinDetailStrings.historyDeleteBody,
      confirmLabel: CommonStrings.delete,
      destructive: true,
    );
    if (confirmed) await store.delete(puuid);
  }
}
