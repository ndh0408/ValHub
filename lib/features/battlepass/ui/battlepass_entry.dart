import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/util/clock.dart';
import '../../../core/util/format.dart';
import '../providers/battlepass_providers.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Subtitle of the "Battle Pass" row of the Profile tab (Battle Pass is not
/// a tab any more): "Cấp 46 / 55 · Còn 15 ngày". Renders nothing while the
/// data loads or when it fails, so the row is just its title then.
class BattlePassProgressSubtitle extends ConsumerWidget {
  const BattlePassProgressSubtitle({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(battlePassOverviewProvider(puuid)).value;
    final pass = overview?.battlePass;
    if (overview == null || pass == null) return const SizedBox.shrink();
    final now = ref.watch(clockProvider).now();
    final ends = overview.actEndsAt;
    final days = ends != null && ends.isAfter(now)
        ? (ends.difference(now).inMinutes / Duration.minutesPerDay).ceil()
        : null;
    final text = [
      context.l10n.battlePassLevelOf(
        formatNumber(pass.level),
        formatNumber(pass.levelCount),
      ),
      if (days != null && !pass.isComplete)
        context.l10n.battlePassDaysLeft(days < 1 ? 1 : days),
    ].join(context.l10n.battlePassDot);
    return Text(text, maxLines: 2, overflow: TextOverflow.ellipsis);
  }
}
