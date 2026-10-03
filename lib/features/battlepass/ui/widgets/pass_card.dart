import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/util/format.dart';
import '../../data/battlepass_models.dart';
import 'bp_ui_bits.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// P1 pass card (S20), compact ValBuddy layout: pass name (bold) with
/// "Cấp 46 / 55" on the right, one thin red level bar, the level XP under
/// its left end and the whole-pass XP under its right end, then the
/// Premium badge and the act-end countdown.
class PassCard extends StatelessWidget {
  const PassCard({
    super.key,
    required this.progress,
    this.isPremium,
    this.endsAt,
    this.endsAtFormatter,
    this.endsAtWall,
    this.kicker,
    this.onTap,
    this.onExpired,
  });

  final PassProgress progress;

  /// `null` hides the badge (ownership unknown).
  final bool? isPremium;
  final DateTime? endsAt;

  /// Builds the whole end-of-pass sentence from the remaining time.
  final String Function(Duration remaining)? endsAtFormatter;

  /// Wraps the local wall-clock time of the end ("Kết thúc lúc 23:59 thứ
  /// Hai 06/10") shown under the countdown.
  final String Function(String wall)? endsAtWall;

  /// Small caption above the name ("Vé sự kiện").
  final String? kicker;
  final VoidCallback? onTap;
  final VoidCallback? onExpired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = valColorsOf(context);
    final muted = scheme.onSurfaceVariant;
    final p = progress;
    final name = p.contract.displayName.isEmpty
        ? context.l10n.battlePassTitle
        : p.contract.displayName;
    final premium = isPremium;
    final end = endsAt;
    final numberStyle = theme.textTheme.bodySmall?.copyWith(
      color: muted,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final levelText = context.l10n.battlePassLevelOf(
      formatNumber(p.level),
      formatNumber(p.levelCount),
    );
    final levelXp = p.xpForNextLevel == null
        ? null
        : context.l10n.battlePassXpOf(
            formatNumber(p.xpInLevel),
            formatNumber(p.xpForNextLevel!),
          );
    final totalXp = context.l10n.battlePassXpOf(
      formatNumber(p.totalXpEarned),
      formatNumber(p.totalXp),
    );

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (kicker != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                kicker!.toUpperCase(),
                style: ValText.label.copyWith(
                  color: legibleAccent(context, scheme.primary),
                ),
              ),
            ),
          // Name left, "Cấp 46 / 55" right; wraps under the name when the
          // text is large.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 2,
            children: [
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                levelText,
                maxLines: 1,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BpProgressBar(
            value: p.levelFraction,
            color: p.isComplete ? colors.win : null,
          ),
          const SizedBox(height: 8),
          if (p.isComplete)
            Row(
              children: [
                Icon(Icons.verified, size: 16, color: colors.win),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context.l10n.battlePassPassComplete,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: legibleAccent(context, colors.win),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          else
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 2,
              children: [
                if (levelXp != null)
                  Tooltip(
                    message: context.l10n.battlePassNextLevelCaption(
                      formatNumber(p.level + 1),
                    ),
                    child: Text(levelXp, maxLines: 1, style: numberStyle),
                  ),
                Tooltip(
                  message: context.l10n.battlePassTotalXpCaption,
                  child: Text(totalXp, maxLines: 1, style: numberStyle),
                ),
              ],
            ),
          if (premium != null || end != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (premium != null) ...[
                  BpBadge(
                    premium
                        ? context.l10n.battlePassPremium
                        : context.l10n.battlePassFree,
                    color: premium ? colors.gold : muted,
                    filled: premium,
                    uppercase: true,
                  ),
                  const SizedBox(width: 10),
                ],
                if (end != null)
                  Expanded(
                    child: BpCountdownLine(
                      expiresAt: end,
                      builder: (s) => s,
                      format:
                          endsAtFormatter ??
                          (remaining) => remaining.inDays >= 1
                              ? context.l10n.battlePassActEndsInDays(
                                  remaining.inDays,
                                )
                              : context.l10n.battlePassActEndsIn(
                                  context.fmt.countdown(remaining),
                                ),
                      icon: Icons.schedule,
                      onExpired: onExpired,
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
            if (end != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 21),
                child: BpWallTimeText(
                  at: end,
                  builder: endsAtWall ?? context.l10n.battlePassEndsAtWall,
                ),
              ),
          ],
        ],
      ),
    );
    return Material(
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ValRadius.card),
        side: theme.brightness == Brightness.light
            ? BorderSide(color: colors.hairline)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}
