import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/error_view.dart';
import '../../../../core/ui/skeleton.dart';
import '../../../../core/util/format.dart';

/// Color of a match outcome (teal win, red loss, grey draw / unknown).
Color outcomeColor(BuildContext context, MatchOutcome outcome) {
  final c = valColorsOf(context);
  return switch (outcome) {
    MatchOutcome.win => c.win,
    MatchOutcome.loss => c.loss,
    MatchOutcome.draw || MatchOutcome.unknown => c.draw,
  };
}

/// Color of an RR change.
Color rrColor(BuildContext context, int rr) {
  final c = valColorsOf(context);
  return rr > 0
      ? c.win
      : rr < 0
      ? c.loss
      : c.draw;
}

/// "Thắng" / "Thua" / "Hòa" tag.
class OutcomeTag extends StatelessWidget {
  const OutcomeTag(this.outcome, {super.key, this.dense = false});

  final MatchOutcome outcome;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = outcomeColor(context, outcome);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 8,
        vertical: dense ? 1 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        outcome.label,
        maxLines: 1,
        style:
            (dense
                    ? Theme.of(context).textTheme.labelSmall
                    : Theme.of(context).textTheme.labelMedium)
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// "+24 RR" / "−17 RR" colored by sign.
class SignedRrText extends StatelessWidget {
  const SignedRrText(this.rr, {super.key, this.style});

  final int rr;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Text(
    formatSignedRr(rr),
    maxLines: 1,
    style: (style ?? Theme.of(context).textTheme.labelLarge)?.copyWith(
      color: rrColor(context, rr),
      fontWeight: FontWeight.w700,
    ),
  );
}

/// Label + value tile of a stats grid ("ACS" / "245").
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.tooltip,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(ValRadius.small),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ValText.label.copyWith(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: theme.textTheme.titleMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    final t = tooltip;
    return t == null ? tile : Tooltip(message: t, child: tile);
  }
}

/// Grid of [StatTile]s, [columns] per row, sized to the available width.
class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.tiles, this.columns = 3});

  final List<Widget> tiles;
  final int columns;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = 8.0;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [for (final t in tiles) SizedBox(width: width, child: t)],
      );
    },
  );
}

/// Navigation row inside a card ("RR theo ngày ›").
class ProfileNavRow extends StatelessWidget {
  const ProfileNavRow({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  /// Red leading icon; `null` for the Figma text-only rows.
  final IconData? icon;
  final String title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    DefaultTextStyle.merge(
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      child: subtitle!,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton of a match card.
class MatchCardSkeleton extends StatelessWidget {
  const MatchCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
    child: Skeleton(height: 72, radius: ValRadius.card),
  );
}

/// Copies [text] and confirms with [message] in a snackbar.
void copyWithSnack(BuildContext context, String text, String message) {
  unawaited(Clipboard.setData(ClipboardData(text: text)));
  showAppSnackBar(context, message);
}
