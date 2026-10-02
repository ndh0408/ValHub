import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/util/format.dart';
import '../../community_routes.dart';
import '../../data/community_models.dart';
import '../../providers/community_providers.dart';
import '../../providers/skin_vote_providers.dart';
import '../consent/consent_sheet.dart';
import '../widgets/community_widgets.dart';
import 'star_rating.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Toggles the active account's vote on [vote] (optimistic) and reports a
/// failure in a snackbar.
Future<void> toggleSkinVote(
  BuildContext context,
  WidgetRef ref, {
  required String puuid,
  required SkinVote vote,
  String? weaponUuid,
}) async {
  // Voting needs a community session: ask (once) before any network call.
  final account = ref.read(accountProvider(puuid));
  if (account != null &&
      !await ensureCommunityConsent(context, account, askAgain: true)) {
    return;
  }
  if (!context.mounted) return;
  try {
    await ref
        .read(skinVoteOverridesProvider(puuid).notifier)
        .toggle(vote, weaponUuid: weaponUuid);
  } on Object catch (e) {
    if (context.mounted) showCommunityError(context, e);
  }
}

/// Community row of the skin sheet: heart + vote count and "★ 4,6 · 128
/// đánh giá" (opens the review page). Hidden when the community is
/// unavailable or the stats cannot be loaded (offline).
class SkinVoteButton extends ConsumerWidget {
  const SkinVoteButton({
    super.key,
    required this.skinUuid,
    this.weaponUuid,
    this.padding = const EdgeInsets.only(top: 10),
  });

  final String skinUuid;
  final String? weaponUuid;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(communityEnabledProvider)) return const SizedBox.shrink();
    final puuid = ref.watch(activeAccountProvider)?.puuid;
    final id = skinUuid.toLowerCase();
    final fetched = ref
        .watch(skinVoteProvider((puuid: puuid, skinUuid: id)))
        .value;
    if (fetched == null) return const SizedBox.shrink();
    final override = puuid == null
        ? null
        : ref.watch(skinVoteOverridesProvider(puuid).select((m) => m[id]));
    final vote = override ?? fetched.vote;
    final rating = fetched.rating;
    final theme = Theme.of(context);
    final avg = rating.average;
    return Padding(
      padding: padding,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(4, 2, 12, 2),
            decoration: BoxDecoration(
              color: ValColors.red.withValues(alpha: vote.voted ? 0.14 : 0.06),
              borderRadius: BorderRadius.circular(ValRadius.pill),
              border: Border.all(
                color: ValColors.red.withValues(
                  alpha: vote.voted ? 0.45 : 0.18,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HeartButton(
                  active: vote.voted,
                  count: vote.votes,
                  dense: true,
                  semanticsOff: context.l10n.communityVote,
                  semanticsOn: context.l10n.communityUnvote,
                  onTap: puuid == null
                      ? null
                      : () => unawaited(
                          toggleSkinVote(
                            context,
                            ref,
                            puuid: puuid,
                            vote: vote,
                            weaponUuid: weaponUuid,
                          ),
                        ),
                ),
                Flexible(
                  child: Text(
                    context.l10n.communityCommunityVotes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: context.l10n.communityOpenReviews,
            child: Material(
              color: starColor(context).withValues(alpha: 0.12),
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: const ValueKey('skin-rating-link'),
                onTap: () => unawaited(openSkinReview(context, id)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        avg == null
                            ? Icons.rate_review_outlined
                            : Icons.star_rounded,
                        size: 16,
                        color: starColor(context),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          avg == null
                              ? context.l10n.communityWriteFirstReview
                              : context.l10n.communityRatingSummary(
                                  formatRating(avg),
                                  formatNumber(rating.count),
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
