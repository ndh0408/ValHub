import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/sub_page.dart';
import '../profile_routes.dart';
import '../profile_strings.dart';
import '../providers/profile_providers.dart';
import 'widgets/identity_banner.dart';
import 'widgets/match_history_sliver.dart';
import 'widgets/rank_card.dart';
import 'widgets/recent_form_card.dart';

/// S44 "Hồ sơ người chơi" (any player). Top-level route `/player/:puuid`
/// (`?hidden=1` keeps an incognito player's name hidden, SUMMARY U16).
///
/// Shows the card and level of the player's latest match, the Riot ID (or
/// "Người chơi ẩn danh"), current and peak rank, RR trend and recent
/// matches.
class PlayerProfileScreen extends ConsumerWidget {
  const PlayerProfileScreen({
    super.key,
    required this.puuid,
    this.hideName = false,
  });

  final String puuid;

  /// Show "Người chơi ẩn danh" instead of the name, title and card.
  final bool hideName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = puuid.trim().toLowerCase();
    if (id.isEmpty) {
      return const SubPageScaffold(
        title: ProfileStrings.playerProfileTitle,
        body: EmptyView(
          icon: Icons.person_search_outlined,
          message: CommonStrings.errorNotFound,
        ),
      );
    }
    return SubPageScaffold(
      title: ProfileStrings.playerProfileTitle,
      onRefresh: () => _refresh(ref, id),
      slivers: [
        SliverToBoxAdapter(
          child: _Header(puuid: id, hideName: hideName),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          sliver: SliverList.list(
            children: [
              RankCard(puuid: id),
              const SizedBox(height: 12),
              RecentFormCard(puuid: id),
            ],
          ),
        ),
        MatchHistorySliver(
          puuid: id,
          title: ProfileStrings.recentMatches,
          onOpenMatch: (m) => unawaited(
            context.push(ProfileRoutes.matchFullScreen(m, player: id)),
          ),
        ),
      ],
    );
  }

  Future<void> _refresh(WidgetRef ref, String id) async {
    ref.invalidate(competitiveUpdatesProvider(id));
    await Future.wait<Object?>([
      ref.refresh(mmrProvider(id).future),
      MatchHistorySliver.refresh(ref, id),
    ]).catchError((Object _) => const <Object?>[]);
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.puuid, required this.hideName});

  final String puuid;
  final bool hideName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final own = ref.watch(accountProvider(puuid));
    if (own != null) {
      final xp = ref.watch(accountXpProvider(puuid));
      final identity = ref.watch(playerIdentityProvider(puuid)).value;
      final name = RiotName.of(own.gameName, own.tagLine);
      return IdentityBanner(
        name: playerDisplayName(name, withTag: false),
        tagLine: own.tagLine,
        cardId: identity?.cardId ?? own.cardId,
        titleId: identity?.titleId,
        level: own.level,
        xp: xp.value,
        xpLoading: xp.isLoading,
        copyText: name?.riotId,
      );
    }
    final name = hideName ? null : ref.watch(playerNameProvider(puuid)).value;
    final snapshot = ref.watch(playerSnapshotProvider(puuid)).value;
    return IdentityBanner(
      name: playerDisplayName(name, hidden: hideName, withTag: false),
      tagLine: hideName ? null : name?.tagLine,
      cardId: hideName ? null : snapshot?.cardId,
      titleId: hideName ? null : snapshot?.titleId,
      level: snapshot?.accountLevel,
      copyText: hideName ? null : name?.riotId,
    );
  }
}
