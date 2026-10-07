import 'package:valvn/core/l10n/labels/competitive_labels.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account.dart';
import '../../../core/accounts/account_providers.dart';
import '../../../core/accounts/account_widgets.dart';
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
import '../providers/profile_providers.dart';
import 'widgets/play_session_card.dart';
import 'widgets/identity_banner.dart';
import 'widgets/match_history_sliver.dart';
import 'widgets/profile_widgets.dart';
import 'widgets/rank_card.dart';
import 'widgets/recent_form_card.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// TAB 4 "Hồ sơ" (S40). Route `/profile`. Hosts one match/party entry using
/// [CurrentGameCard] (owned by the live_game feature). Battle Pass and Cài
/// đặt are not tabs: this screen has a "Battle Pass" row and a ⚙ button in
/// the header that push their pages on top of it.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.currentGameCard});

  /// Slot for the combined match/party entry; defaults to [CurrentGameCard]
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
    final roomy = MediaQuery.sizeOf(context).width >= 360;
    return TabPageScaffold(
      title: context.l10n.profileTitle,
      showAccountChip: false,
      // Same header as Trang chủ: whose profile this is, and ⚙.
      actions: [
        AccountChip(showName: roomy),
        const SettingsGearButton(),
      ],
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
              PlaySessionCard(puuid: puuid),
              // The form card leads to the full analysis.
              RecentFormCard(
                puuid: puuid,
                onTap: () => unawaited(context.push(ProfileRoutes.performance)),
              ),
              currentGameCard ??
                  CurrentGameCard(
                    title: context.l10n.profilePlayHubTitle,
                    includeRecentResult: true,
                    onOpen: () => unawaited(context.push(SocialRoutes.party)),
                  ),
              const SizedBox(height: 12),
              // Every way out of the profile in one group, not four cards.
              ValCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _DailyRrRow(puuid: puuid),
                    const Divider(indent: 66, height: 1),
                    ProfileNavRow(
                      icon: Icons.insights_outlined,
                      title: context.l10n.profilePerformanceTitle,
                      onTap: () =>
                          unawaited(context.push(ProfileRoutes.performance)),
                    ),
                    const Divider(indent: 66, height: 1),
                    ProfileNavRow(
                      icon: Icons.military_tech_outlined,
                      title: context.l10n.commonTabBattlePass,
                      subtitle: BattlePassProgressSubtitle(puuid: puuid),
                      onTap: () =>
                          unawaited(context.push(BattlePassRoutes.root)),
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
    // "No ranked match today" is only true once Riot answered just now; with
    // an expired sign-in or no network the local history may simply be
    // behind, so the row then stays without a claim.
    final updates = ref.watch(competitiveUpdatesProvider(puuid));
    final checkedToday = updates.hasValue && !updates.hasError;
    return ProfileNavRow(
      icon: Icons.calendar_month_rounded,
      title: context.l10n.profileDailyRrTitle,
      subtitle: days == null || (today == null && !checkedToday)
          ? null
          : Text(
              today == null
                  ? context.l10n.profileTodayNone
                  : context.l10n.profileToday(
                      context.l10n.winLossSummary(
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
    );
  }
}
