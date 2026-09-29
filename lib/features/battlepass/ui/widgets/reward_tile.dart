import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/net_image.dart';
import '../../battlepass_strings.dart';
import '../../data/battlepass_models.dart';
import 'bp_ui_bits.dart';

/// A reward of the track resolved against the content.
@immutable
class ResolvedReward {
  const ResolvedReward({
    required this.tier,
    required this.name,
    required this.typeLabel,
    this.image,
    this.isKnown = true,
  });

  /// Resolves [tier] with [db] (unknown items get a placeholder name).
  factory ResolvedReward.resolve(RewardTier tier, ContentDb db) {
    final reward = tier.reward;
    if (reward == null) {
      return ResolvedReward(
        tier: tier,
        name: CommonStrings.unknownItem,
        typeLabel: BattlePassStrings.unknownReward,
        isKnown: false,
      );
    }
    final type = reward.type;
    final typeLabel = type.label.isEmpty
        ? BattlePassStrings.unknownReward
        : type.label;
    final item = type == ContractRewardType.unknown
        ? null
        : db.item(type.itemTypeId, reward.uuid);
    if (item == null) {
      return ResolvedReward(
        tier: tier,
        name: CommonStrings.unknownItem,
        typeLabel: typeLabel,
        isKnown: false,
      );
    }
    final name = type == ContractRewardType.currency
        ? (db.currency(reward.uuid)?.fullLabel ?? item.name)
        : item.name;
    return ResolvedReward(
      tier: tier,
      name: name.isEmpty ? CommonStrings.unknownItem : name,
      typeLabel: typeLabel,
      image: item.image,
    );
  }

  final RewardTier tier;
  final String name;
  final String typeLabel;
  final String? image;

  /// `false` when the reward is missing from the content (report a miss).
  final bool isKnown;

  ContractRewardType get type =>
      tier.reward?.type ?? ContractRewardType.unknown;

  bool get isSkin => type == ContractRewardType.skinLevel && isKnown;
}

/// S21 tile: level, reward image, type, lock/✓ and the "Miễn phí" tag.
class RewardTile extends StatelessWidget {
  const RewardTile({super.key, required this.reward, this.onTap});

  static const imageHeight = 84.0;

  final ResolvedReward reward;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tier = reward.tier;
    final state = tier.state;
    final unlocked = state == RewardState.unlocked;
    final muted = scheme.onSurfaceVariant;
    final stateLabel = switch (state) {
      RewardState.unlocked => BattlePassStrings.rewardUnlocked,
      RewardState.locked => BattlePassStrings.rewardLocked,
      RewardState.needsPremium => BattlePassStrings.rewardNeedsPremium,
    };
    return Semantics(
      button: onTap != null,
      label: [
        BattlePassStrings.levelShort(tier.level),
        reward.typeLabel,
        reward.name,
        if (tier.isFree) BattlePassStrings.free,
        stateLabel,
      ].join(BattlePassStrings.dot),
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: unlocked ? scheme.surfaceContainerHigh : scheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: unlocked
                ? valColorsOf(context).win.withValues(alpha: 0.45)
                : scheme.outlineVariant,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: imageHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: unlocked ? 1 : 0.55,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 22, 8, 8),
                        child: _RewardArt(reward: reward),
                      ),
                    ),
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Text(
                        BattlePassStrings.levelShort(tier.level),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 5,
                      top: 5,
                      child: _StateIcon(state: state),
                    ),
                    if (tier.isFree)
                      const Positioned(
                        left: 6,
                        bottom: 6,
                        child: BpBadge(
                          BattlePassStrings.free,
                          color: ValColors.teal,
                          filled: true,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.typeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(color: muted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reward.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: unlocked ? scheme.onSurface : muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardArt extends StatelessWidget {
  const _RewardArt({required this.reward});

  final ResolvedReward reward;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    if (reward.type == ContractRewardType.title && reward.isKnown) {
      // Titles have no art: show the title itself on a plate.
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            reward.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
      );
    }
    final fallbackIcon = switch (reward.type) {
      ContractRewardType.skinLevel => Icons.style_outlined,
      ContractRewardType.buddyLevel => Icons.key_outlined,
      ContractRewardType.spray => Icons.format_paint_outlined,
      ContractRewardType.playerCard => Icons.badge_outlined,
      ContractRewardType.flex => Icons.star_outline,
      ContractRewardType.agent => Icons.person_outline,
      ContractRewardType.currency => Icons.toll_outlined,
      _ => Icons.card_giftcard,
    };
    return NetImage(
      reward.image,
      fit: BoxFit.contain,
      error: Icon(fallbackIcon, color: muted, size: 28),
    );
  }
}

class _StateIcon extends StatelessWidget {
  const _StateIcon({required this.state});

  final RewardState state;

  @override
  Widget build(BuildContext context) {
    final colors = valColorsOf(context);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return switch (state) {
      RewardState.unlocked => Icon(
        Icons.check_circle,
        size: 16,
        color: colors.win,
      ),
      RewardState.locked => Icon(Icons.lock_outline, size: 15, color: muted),
      RewardState.needsPremium => Icon(
        Icons.lock,
        size: 15,
        color: colors.warning,
      ),
    };
  }
}
