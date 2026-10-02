import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account.dart';
import '../../../core/accounts/account_providers.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/tab_page_scaffold.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/clock.dart';
import '../../battlepass/battlepass_routes.dart';
import '../../battlepass/ui/battlepass_entry.dart';
import '../../live_game/current_game_card.dart';
import '../../settings/ui/settings_gear_button.dart';
import '../../social/social_routes.dart';
import '../profile_routes.dart';
import '../profile_strings.dart';
import '../providers/profile_providers.dart';
import 'widgets/identity_banner.dart';
import 'widgets/match_history_sliver.dart';
import 'widgets/profile_widgets.dart';
import 'widgets/rank_card.dart';
import 'widgets/recent_form_card.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// TAB 4 "Hồ sơ" (S40). Route `/profile`. Hosts the live-game
/// [CurrentGameCard] (owned by the live_game feature). Battle Pass and Cài
/// đặt are not tabs: this screen has a "Battle Pass" row and a ⚙ button in
/// the header that push their pages on top of it.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.currentGameCard});

  /// Slot for the "Trận hiện tại" card; defaults to [CurrentGameCard]
  /// (tests pass a placeholder).
  final Widget? currentGameCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return TabPageScaffold(
        title: context.l10n.profileTitle,
        body: EmptyView(
          icon: Icons.person_off_outlined,
          message: context.l10n.commonErrorNoAccount,
        ),
      );
    }
    final puuid = account.puuid;
    return TabPageScaffold(
      title: context.l10n.profileTitle,
      actions: const [SettingsGearButton()],
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
              RecentFormCard(puuid: puuid),
              _DailyRrRow(puuid: puuid),
              ValCard(
                padding: EdgeInsets.zero,
                child: ProfileNavRow(
                  icon: Icons.insights_outlined,
                  title: context.l10n.profilePerformanceTitle,
                  onTap: () =>
                      unawaited(context.push(ProfileRoutes.performance)),
                ),
              ),
              const SizedBox(height: 12),
              currentGameCard ?? const CurrentGameCard(),
              const SizedBox(height: 12),
              ValCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ProfileNavRow(
                      icon: Icons.military_tech_outlined,
                      title: context.l10n.commonTabBattlePass,
                      subtitle: BattlePassProgressSubtitle(puuid: puuid),
                      onTap: () =>
                          unawaited(context.push(BattlePassRoutes.root)),
                    ),
                    const Divider(indent: 66, height: 1),
                    ProfileNavRow(
                      icon: Icons.groups_outlined,
                      title: context.l10n.profilePartyRow,
                      onTap: () => unawaited(context.push(SocialRoutes.party)),
                    ),
                    const Divider(indent: 66, height: 1),
                    ProfileNavRow(
                      icon: Icons.forum_outlined,
                      title: context.l10n.profileFriendsRow,
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
    return ValCard(
      padding: EdgeInsets.zero,
      child: ProfileNavRow(
        icon: Icons.calendar_month_rounded,
        title: context.l10n.profileDailyRrTitle,
        subtitle: days == null
            ? null
            : Text(
                today == null
                    ? context.l10n.profileTodayNone
                    : context.l10n.profileToday(
                        ProfileStrings.winsLosses(
                          today.wins,
                          today.losses,
                          today.draws,
                          today.unknown,
                        ),
                      ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: today == null ? null : RrPill(today.netRr),
        onTap: () => unawaited(context.push(ProfileRoutes.dailyRr)),
      ),
    );
  }
}
