import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/util/format.dart';
import '../../battlepass_strings.dart';
import '../../data/battlepass_models.dart';
import 'bp_ui_bits.dart';

/// "Phần kết thúc sau 16 ngày" while a day or more is left, then the
/// ticking "Phần kết thúc sau 11:54:37".
String formatActEnd(Duration remaining) => remaining.inDays >= 1
    ? BattlePassStrings.actEndsInDays(remaining.inDays)
    : BattlePassStrings.actEndsIn(formatCountdown(remaining));

/// P1 pass card (S20): name, Premium/Miễn phí badge, "Cấp 46 / 55", level
/// bar, level XP and total XP, and the act-end countdown.
class PassCard extends StatelessWidget {
  const PassCard({
    super.key,
    required this.progress,
    this.isPremium,
    this.endsAt,
    this.endsAtFormatter = formatActEnd,
    this.kicker,
    this.onTap,
    this.onExpired,
  });

  final PassProgress progress;

  /// `null` hides the badge (ownership unknown).
  final bool? isPremium;
  final DateTime? endsAt;

  /// Builds the whole end-of-pass sentence from the remaining time.
  final String Function(Duration remaining) endsAtFormatter;

  /// Small caption above the name ("Vé sự kiện").
  final String? kicker;
  final VoidCallback? onTap;
  final VoidCallback? onExpired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurfaceVariant;
    final p = progress;
    final name = p.contract.displayName.isEmpty
        ? BattlePassStrings.title
        : p.contract.displayName;
    final premium = isPremium;
    final end = endsAt;
    final numberStyle = theme.textTheme.bodySmall?.copyWith(
      color: muted,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    // Figma: wine-red gradient into s1 with a 35% red border.
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(ValRadius.card),
      border: Border.all(color: ValColors.red.withValues(alpha: 0.35)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          ValColors.red.withValues(alpha: 0.22),
          scheme.surfaceContainer,
        ],
        stops: const [0, 0.75],
      ),
    );
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (kicker != null)
                      Text(
                        kicker!.toUpperCase(),
                        style: ValText.label.copyWith(color: ValColors.red),
                      ),
                    // Main pass: small uppercase season caption (Figma);
                    // event passes keep their name readable under the
                    // red kicker.
                    Text(
                      kicker == null ? name.toUpperCase() : name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: kicker == null
                          ? ValText.label.copyWith(color: muted)
                          : theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              if (premium != null) ...[
                const SizedBox(width: 8),
                BpBadge(
                  premium ? BattlePassStrings.premium : BattlePassStrings.free,
                  color: premium ? valColorsOf(context).gold : muted,
                  filled: premium,
                  uppercase: true,
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              BattlePassStrings.levelOf(
                formatNumber(p.level),
                formatNumber(p.levelCount),
              ),
              style: ValText.display(44, color: scheme.onSurface),
            ),
          ),
          const SizedBox(height: 10),
          BpProgressBar(value: p.levelFraction),
          const SizedBox(height: 8),
          if (p.isComplete)
            Row(
              children: [
                Icon(Icons.verified, size: 16, color: valColorsOf(context).win),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    BattlePassStrings.passComplete,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: valColorsOf(context).win,
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: p.xpForNextLevel == null
                      ? const SizedBox.shrink()
                      : _XpColumn(
                          caption: BattlePassStrings.nextLevelCaption(
                            formatNumber(p.level + 1),
                          ),
                          value: BattlePassStrings.xpOf(
                            formatNumber(p.xpInLevel),
                            formatNumber(p.xpForNextLevel!),
                          ),
                          style: numberStyle,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _XpColumn(
                    caption: BattlePassStrings.totalXpCaption,
                    value: BattlePassStrings.xpOf(
                      formatNumber(p.totalXpEarned),
                      formatNumber(p.totalXp),
                    ),
                    style: numberStyle,
                    end: true,
                  ),
                ),
              ],
            ),
          if (!p.isComplete) ...[
            const SizedBox(height: 6),
            BpProgressBar(
              value: p.totalFraction,
              height: 3,
              color: ValColors.red.withValues(alpha: 0.55),
            ),
          ],
          if (end != null) ...[
            const SizedBox(height: 12),
            BpCountdownLine(
              expiresAt: end,
              builder: (s) => s,
              format: endsAtFormatter,
              icon: Icons.hourglass_bottom,
              onExpired: onExpired,
            ),
          ],
        ],
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(ValRadius.card),
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: decoration,
          child: InkWell(onTap: onTap, child: content),
        ),
      ),
    );
  }
}

class _XpColumn extends StatelessWidget {
  const _XpColumn({
    required this.caption,
    required this.value,
    required this.style,
    this.end = false,
  });

  final String caption;
  final String? value;
  final TextStyle? style;
  final bool end;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final v = value;
    return Column(
      crossAxisAlignment: end
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
        if (v != null)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: end ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(v, maxLines: 1, style: style),
          ),
      ],
    );
  }
}
