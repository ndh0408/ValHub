import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/skeleton.dart';
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
    final scheme = theme.colorScheme;
    final lvl = xp?.level ?? level;
    final tag = tagLine?.trim() ?? '';
    final copy = copyText;

    return Stack(
      children: [
        Positioned.fill(
          child: card?.wideArt == null
              ? ColoredBox(color: scheme.surfaceContainerLow)
              : NetImage(
                  card!.wideArt,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
                  showSkeleton: false,
                ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.surface.withValues(alpha: 0.25),
                  scheme.surface.withValues(alpha: 0.85),
                  scheme.surface,
                ],
                stops: const [0, 0.65, 1],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 64,
                  height: 64,
                  color: scheme.surfaceContainerHigh,
                  child: card?.smallArt == null
                      ? Icon(Icons.person, color: scheme.onSurfaceVariant)
                      : NetImage(card!.smallArt, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
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
                                      style: TextStyle(
                                        color: scheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                          if (copy != null) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.copy_rounded,
                              size: 16,
                              semanticLabel: ProfileStrings.copyRiotId,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (title != null && title.isNotEmpty)
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 6),
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
      ],
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
    final scheme = theme.colorScheme;
    final lvl = level;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        hidden ? ProfileStrings.levelHidden : ProfileStrings.level(lvl ?? 0),
        style: theme.textTheme.labelMedium,
      ),
    );
    final x = xp;
    if (loading && x == null) {
      return Row(
        children: [
          if (lvl != null) ...[chip, const SizedBox(width: 10)],
          const Expanded(child: Skeleton(height: 8)),
        ],
      );
    }
    if (x == null) {
      return hidden || lvl != null ? chip : const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            chip,
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                ProfileStrings.xpProgress(
                  formatNumber(x.xp),
                  formatNumber(x.xpPerLevel),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: x.progress,
            minHeight: 4,
            backgroundColor: scheme.surfaceContainerHighest,
          ),
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
