import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/accounts/account_widgets.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/ui/async_value_view.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/tab_page_scaffold.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/format.dart';
import '../battlepass_routes.dart';
import '../battlepass_strings.dart';
import '../data/battlepass_models.dart';
import '../data/xp_pace.dart';
import '../providers/battlepass_providers.dart';
import 'widgets/bp_ui_bits.dart';
import 'widgets/daily_checkpoints.dart';
import 'widgets/overview_bits.dart';
import 'widgets/pass_card.dart';
import 'widgets/weekly_missions.dart';

/// Riot queue id of Unrated ("Đấu thường"), used by the XP estimate.
const kUnratedQueueId = 'unrated';

/// "Battle Pass" (S20), hosted by the Hồ sơ tab. Route `/battlepass`.
///
/// Pass card (P1), "Xem tất cả phần thưởng" (P2), the XP estimate, active
/// event passes, daily checkpoints (P4) and weekly missions (P3/P5).
/// Pull-to-refresh refetches contracts, premium ownership and the daily
/// ticket.
class BattlePassScreen extends ConsumerWidget {
  const BattlePassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    // On narrow phones the chip shows only the avatar so the title fits.
    // ("BATTLE PASS" is long, so the name needs a wider screen than Store.)
    final roomy = MediaQuery.sizeOf(context).width >= 400;
    if (account == null) {
      return const TabPageScaffold(
        title: BattlePassStrings.title,
        body: EmptyView(
          message: CommonStrings.errorNoAccount,
          icon: Icons.person_off_outlined,
        ),
      );
    }
    final puuid = account.puuid;
    final overview = ref.watch(battlePassOverviewProvider(puuid));
    return TabPageScaffold(
      title: BattlePassStrings.title,
      showAccountChip: false,
      actions: [AccountChip(showName: roomy)],
      onRefresh: () => refreshBattlePass(ref, puuid),
      slivers: [
        SliverToBoxAdapter(
          child: AsyncValueView<BattlePassOverview>(
            value: overview,
            puuid: puuid,
            onRetry: () => retryBattlePass(ref, puuid),
            loading: const BattlePassSkeleton(),
            data: (o) => BattlePassOverviewView(overview: o, puuid: puuid),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

/// The S20 body once the contracts and content are known.
class BattlePassOverviewView extends ConsumerWidget {
  const BattlePassOverviewView({
    super.key,
    required this.overview,
    required this.puuid,
  });

  final BattlePassOverview overview;
  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final ticket = ref.watch(dailyTicketProvider(puuid)).value;
    final now = ref.watch(clockProvider).now();
    final dailyDone =
        ticket != null && !ticket.isExpired(now) && ticket.isAllComplete;
    final bp = overview.battlePass;
    final unrated = db.queueName(kUnratedQueueId);
    final queueName = unrated.isEmpty || unrated == kUnratedQueueId
        ? BattlePassStrings.unratedFallback
        : unrated;
    void refetchContracts() => ref.invalidate(playerContractsProvider(puuid));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (overview.contracts.isFromCache)
          BpOfflineNotice(receivedAt: overview.contracts.receivedAt),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: bp == null
              ? const ValCard(
                  padding: EdgeInsets.zero,
                  child: EmptyView(
                    message: BattlePassStrings.noBattlePass,
                    icon: Icons.military_tech_outlined,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PassCard(
                      progress: bp,
                      isPremium: overview.isPremium,
                      endsAt: overview.actEndsAt,
                      onTap: () => context.push(BattlePassRoutes.rewards),
                    ),
                    const SizedBox(height: 10),
                    ViewRewardsRow(
                      progress: bp,
                      onTap: () => context.push(BattlePassRoutes.rewards),
                    ),
                    if (!bp.isComplete && bp.xpRemaining > 0) ...[
                      const SizedBox(height: 10),
                      XpEstimateCard(
                        progress: bp,
                        queueName: queueName,
                        pace: xpPaceOf(bp, overview.actEndsAt, now),
                        weeklyXpLeft: overview.weekly.xpAvailable,
                      ),
                    ],
                  ],
                ),
        ),
        for (final e in overview.eventPasses)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: PassCard(
              progress: e.progress,
              kicker: BattlePassStrings.eventPass,
              isPremium: overview.isPremiumFor(e.progress.contract.uuid),
              endsAt: e.endsAt,
              endsAtFormatter: (d) =>
                  BattlePassStrings.eventEndsIn(formatCountdown(d)),
              endsAtWall: BattlePassStrings.endsAtWall,
              onTap: () => context.push(
                BattlePassRoutes.rewardsFor(e.progress.contract.uuid),
              ),
            ),
          ),
        DailyCheckpointsSection(puuid: puuid),
        WeeklyMissionsSection(
          weekly: overview.weekly,
          dailyAllComplete: dailyDone,
          onRefill: refetchContracts,
        ),
      ],
    );
  }
}
