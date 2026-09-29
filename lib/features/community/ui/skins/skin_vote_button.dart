import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../community_strings.dart';
import '../../data/community_models.dart';
import '../../providers/community_providers.dart';
import '../../providers/skin_vote_providers.dart';
import '../widgets/community_widgets.dart';

/// Toggles the active account's vote on [vote] (optimistic) and reports a
/// failure in a snackbar.
Future<void> toggleSkinVote(
  BuildContext context,
  WidgetRef ref, {
  required String puuid,
  required SkinVote vote,
  String? weaponUuid,
}) async {
  try {
    await ref
        .read(skinVoteOverridesProvider(puuid).notifier)
        .toggle(vote, weaponUuid: weaponUuid);
  } on Object catch (e) {
    if (context.mounted) showCommunityError(context, e);
  }
}

/// "Cộng đồng yêu thích" row of the skin sheet: heart + vote count. Hidden
/// when the community is unavailable or the count cannot be loaded.
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
    final fetched = ref.watch(skinVoteProvider((puuid: puuid, skinUuid: id)));
    final override = puuid == null
        ? null
        : ref.watch(skinVoteOverridesProvider(puuid).select((m) => m[id]));
    final vote = override ?? fetched.value;
    if (vote == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 2, 14, 2),
        decoration: BoxDecoration(
          color: ValColors.red.withValues(alpha: vote.voted ? 0.14 : 0.06),
          borderRadius: BorderRadius.circular(ValRadius.pill),
          border: Border.all(
            color: ValColors.red.withValues(alpha: vote.voted ? 0.45 : 0.18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HeartButton(
              active: vote.voted,
              count: vote.votes,
              dense: true,
              semanticsOff: CommunityStrings.vote,
              semanticsOn: CommunityStrings.unvote,
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
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                CommunityStrings.communityVotes,
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
    );
  }
}
