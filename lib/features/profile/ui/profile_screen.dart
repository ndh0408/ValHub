import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account.dart';
import '../../../core/accounts/account_providers.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/tab_page_scaffold.dart';
import '../../../core/util/clock.dart';
import '../../live_game/current_game_card.dart';
import '../../social/social_routes.dart';
import '../data/rr_trend.dart';
import '../profile_routes.dart';
import '../profile_strings.dart';
import '../providers/profile_providers.dart';
import 'widgets/identity_banner.dart';
import 'widgets/match_history_sliver.dart';
import 'widgets/profile_widgets.dart';
import 'widgets/rank_card.dart';

/// TAB 4 "Hồ sơ" (S40). Route `/profile`. Hosts the live-game
/// [CurrentGameCard] (owned by the live_game feature).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.currentGameCard});

  /// Slot for the "Trận hiện tại" card; defaults to [CurrentGameCard]
  /// (tests pass a placeholder).
  final Widget? currentGameCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return const TabPageScaffold(
        title: ProfileStrings.title,
        body: EmptyView(message: CommonStrings.errorNoAccount),
      );
    }
    final puuid = account.puuid;
    return TabPageScaffold(
      title: ProfileStrings.title,
      onRefresh: () => _refresh(ref, account),
      slivers: [
        SliverToBoxAdapter(child: ProfileHeader(account: account)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          sliver: SliverList.list(
            children: [
              RankCard(
                puuid: puuid,
                onOpenRankUp: () =>
                    unawaited(context.push(ProfileRoutes.rankUp)),
              ),
              const SizedBox(height: 12),
              _DailyRrRow(puuid: puuid),
              const SizedBox(height: 12),
              currentGameCard ?? const CurrentGameCard(),
              const SizedBox(height: 12),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ProfileNavRow(
                      icon: Icons.groups_outlined,
                      title: ProfileStrings.partyRow,
                      onTap: () => unawaited(context.push(SocialRoutes.party)),
                    ),
                    const Divider(indent: 56),
                    ProfileNavRow(
                      icon: Icons.forum_outlined,
                      title: ProfileStrings.friendsRow,
                      onTap: () =>
                          unawaited(context.push(SocialRoutes.friends)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        MatchHistorySliver(
          puuid: puuid,
          onOpenMatch: (id) => unawaited(context.push(ProfileRoutes.match(id))),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Future<void> _refresh(WidgetRef ref, Account account) async {
    final puuid = account.puuid;
    ref
      ..invalidate(accountXpProvider(puuid))
      ..invalidate(playerIdentityProvider(puuid))
      ..invalidate(competitiveUpdatesProvider(puuid));
    await Future.wait<Object?>([
      ref.refresh(mmrProvider(puuid).future),
      MatchHistorySliver.refresh(ref, puuid),
    ]).catchError((Object _) => const <Object?>[]);
  }
}

/// "RR theo ngày ›" with today's net RR (S40.3).
class _DailyRrRow extends ConsumerWidget {
  const _DailyRrRow({required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(dailyRrProvider(puuid)).value;
    final now = ref.watch(clockProvider).now();
    final today = days == null ? null : dailyRrOn(days, now);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ProfileNavRow(
        icon: Icons.calendar_month_outlined,
        title: ProfileStrings.dailyRrTitle,
        subtitle: days == null
            ? null
            : Text(
                today == null
                    ? ProfileStrings.todayNone
                    : ProfileStrings.today(
                        ProfileStrings.winsLosses(
                          today.wins,
                          today.losses,
                          today.draws,
                        ),
                      ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: today == null ? null : SignedRrText(today.netRr),
        onTap: () => unawaited(context.push(ProfileRoutes.dailyRr)),
      ),
    );
  }
}
