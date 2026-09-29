import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/skeleton.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/format.dart';
import '../../profile_strings.dart';
import '../../providers/profile_providers.dart';
import 'profile_widgets.dart';

/// Player-card banner with name, Riot ID copy, title, level and an optional
/// account-XP bar (S40.1, S44).
class IdentityBanner extends ConsumerWidget {
  const IdentityBanner({
    super.key,
    required this.name,
    this.tagLine,
    this.cardId,
    this.titleId,
    this.level,
    this.levelHidden = false,
    this.xp,
    this.xpLoading = false,
    this.copyText,
  });

  /// Game name, or "Người chơi ẩn danh".
  final String name;

  /// Shown as "#TAG" after the name.
  final String? tagLine;
  final String? cardId;
  final String? titleId;
  final int? level;

  /// Show "Cấp ẩn" instead of a number.
  final bool levelHidden;
  final AccountXp? xp;

  /// Skeleton in place of the XP bar.
  final bool xpLoading;

  /// Riot ID copied on tap (`null` = not copyable).
  final String? copyText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value;
    final card = cardId == null ? null : db?.card(cardId!);
    final t = titleId == null ? null : db?.title(titleId!);
    final title = t == null || t.isNoTitle ? null : t.text;
    final lvl = xp?.level ?? level;
    final tag = tagLine?.trim() ?? '';
    final copy = copyText;

    const onBanner = Colors.white;
    final onBannerMuted = Colors.white.withValues(alpha: 0.78);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Figma: red player banner (red → deep red), the player card
            // art faintly on the right.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE8404F), Color(0xFF5C1A26)],
                  ),
                ),
              ),
            ),
            if (card?.wideArt != null)
              Positioned.fill(
                child: ShaderMask(
                  shaderCallback: (rect) => const LinearGradient(
                    colors: [Colors.transparent, Colors.white],
                    stops: [0.25, 1],
                  ).createShader(rect),
                  blendMode: BlendMode.dstIn,
                  child: Opacity(
                    opacity: 0.35,
                    child: NetImage(
                      card!.wideArt,
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                      showSkeleton: false,
                      error: const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: copy == null
                        ? null
                        : () => copyWithSnack(
                            context,
                            copy,
                            ProfileStrings.riotIdCopied,
                          ),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: name),
                                if (tag.isNotEmpty)
                                  TextSpan(
                                    text: ProfileStrings.tagSuffix(tag),
                                    style: TextStyle(color: onBannerMuted),
                                  ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: ValText.display(28, color: onBanner),
                          ),
                        ),
                        if (copy != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.copy_rounded,
                            size: 16,
                            semanticLabel: ProfileStrings.copyRiotId,
                            color: onBannerMuted,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (title != null && title.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: onBannerMuted,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  _LevelLine(
                    level: levelHidden ? null : lvl,
                    hidden: levelHidden,
                    xp: levelHidden ? null : xp,
                    loading: xpLoading && !levelHidden,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelLine extends StatelessWidget {
  const _LevelLine({
    required this.level,
    required this.hidden,
    required this.xp,
    required this.loading,
  });

  final int? level;
  final bool hidden;
  final AccountXp? xp;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lvl = level;
    final muted = Colors.white.withValues(alpha: 0.8);
    final chip = Text(
      hidden ? ProfileStrings.levelHidden : ProfileStrings.level(lvl ?? 0),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: muted,
        fontWeight: FontWeight.w600,
      ),
    );
    final x = xp;
    if (loading && x == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lvl != null) ...[chip, const SizedBox(height: 10)],
          const Skeleton(height: 6),
        ],
      );
    }
    if (x == null) {
      return hidden || lvl != null ? chip : const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        chip,
        const SizedBox(height: 10),
        ValProgressBar(
          value: x.progress,
          color: Colors.white,
          trackColor: Colors.white.withValues(alpha: 0.25),
        ),
        const SizedBox(height: 8),
        Text(
          ProfileStrings.xpProgress(
            formatNumber(x.xp),
            formatNumber(x.xpPerLevel),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(color: muted),
        ),
      ],
    );
  }
}

/// Header of the signed-in account's profile tab: P-8 card (cached card as
/// fallback), Riot ID copy, P-9 level and XP.
class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identity = ref.watch(playerIdentityProvider(account.puuid)).value;
    final xp = ref.watch(accountXpProvider(account.puuid));
    final name = RiotName.of(account.gameName, account.tagLine);
    return IdentityBanner(
      name: playerDisplayName(name, withTag: false),
      tagLine: account.tagLine,
      cardId: identity?.cardId ?? account.cardId,
      titleId: identity?.titleId,
      level: account.level,
      xp: xp.value,
      xpLoading: xp.isLoading,
      copyText: name?.riotId,
    );
  }
}
