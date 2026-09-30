/// "Bạn bè đang chơi" (docs/design/HOME.md §5.5): friends in a match, in
/// agent select or in a queue right now. Privacy first: the card connects to
/// Riot chat (which makes the user look online to friends) only after the
/// user opted in, and otherwise asks once.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/l10n/account_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/xmpp/friends.dart';
import '../../../social/data/friend_status.dart';
import '../../../social/social_routes.dart';
import '../../data/home_card.dart';
import '../../data/home_friends.dart';
import '../../home_strings.dart';
import '../../providers/home_card_providers.dart';
import '../../providers/home_layout_provider.dart';
import '../home_card_frame.dart';

class FriendsHomeCard extends ConsumerWidget {
  const FriendsHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consent = ref.watch(homeFriendsConsentProvider);
    final live = ref.watch(homeFriendsLiveProvider);
    if (consent == false) return const SizedBox.shrink();
    if (consent == null && !live) return const _ConsentPrompt();
    final snap = ref.watch(homeFriendsSnapshotProvider).value;
    if (snap == null) return const SizedBox.shrink();
    return _FriendsBody(snap: snap);
  }
}

/// The one-time question. "Bật" allows the chat connection; "Không, ẩn
/// thẻ" declines (undo brings the question back).
class _ConsentPrompt extends ConsumerWidget {
  const _ConsentPrompt();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.read(homeFriendsConsentProvider.notifier);
    return HomeCardFrame(
      card: HomeCardId.friends,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            HomeStrings.friendsConsentTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            HomeStrings.friendsConsentBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              FilledButton(
                onPressed: () => unawaited(notifier.set(allowed: true)),
                child: const Text(HomeStrings.friendsConsentAllow),
              ),
              TextButton(
                onPressed: () {
                  final messenger = ScaffoldMessenger.maybeOf(context);
                  unawaited(notifier.set(allowed: false));
                  messenger
                    ?..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          HomeStrings.cardHidden(HomeCardId.friends.title),
                        ),
                        action: SnackBarAction(
                          label: HomeStrings.undo,
                          onPressed: () => unawaited(notifier.clear()),
                        ),
                      ),
                    );
                },
                child: const Text(HomeStrings.friendsConsentDecline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FriendsBody extends ConsumerWidget {
  const _FriendsBody({required this.snap});

  final HomeFriendsSnapshot snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final now = ref.watch(clockProvider).now();
    return HomeCardFrame(
      card: HomeCardId.friends,
      title: HomeStrings.friendsPlaying(snap.total),
      onTap: () => unawaited(context.push<Object?>(SocialRoutes.friends)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Scrolls sideways when the friends do not fit; starts at the
          // leading edge (also in right-to-left languages).
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final f in snap.playing) ...[
                  _FriendAvatar(friend: f, db: db, now: now),
                  const SizedBox(width: 8),
                ],
                if (snap.hidden > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Text(
                      HomeStrings.friendsMore(snap.hidden),
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: () =>
                  unawaited(context.push<Object?>(SocialRoutes.friends)),
              icon: const Icon(Icons.chevron_right),
              iconAlignment: IconAlignment.end,
              label: const Text(HomeStrings.friendsSeeAll),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar({
    required this.friend,
    required this.db,
    required this.now,
  });

  final Friend friend;
  final ContentDb db;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final status = presenceStatus(
      friend.presence,
      lastOnline: friend.lastOnline,
      db: db,
      now: now,
    );
    final ring = switch (friend.activity) {
      FriendActivity.inMatch => colors.win,
      _ => colors.warning,
    };
    final name = friend.name?.riotId ?? AccountStrings.unknownPlayer;
    final art = friend.playerCardId == null
        ? null
        : db.card(friend.playerCardId!)?.smallArt;
    final oneLine = MediaQuery.textScalerOf(context).scale(1) >= 1.3;
    return Semantics(
      button: true,
      label: HomeStrings.friendSemantics(name, status.text),
      excludeSemantics: true,
      child: InkWell(
        onTap: () =>
            unawaited(context.push<Object?>(SocialRoutes.chat(friend.puuid))),
        borderRadius: BorderRadius.circular(ValRadius.small),
        child: SizedBox(
          width: 84,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ring, width: 2),
                  ),
                  child: ClipOval(
                    child: art == null
                        ? ColoredBox(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Text(
                                name.characters.first.toUpperCase(),
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          )
                        : NetImage(art, fit: BoxFit.cover, showSkeleton: false),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  friend.name?.gameName ?? name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _short(friend, status.text),
                  maxLines: oneLine ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// "Đang đấu · Ascent · 8 – 4" → "Ascent · 8 – 4"; the other states keep
  /// their (already short) line.
  static String _short(Friend f, String text) {
    if (f.activity != FriendActivity.inMatch) return text;
    final at = text.indexOf(' · ');
    return at < 0 ? text : text.substring(at + 3);
  }
}
