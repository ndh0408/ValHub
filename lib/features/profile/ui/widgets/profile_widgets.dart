import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/l10n/labels/competitive_labels.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/error_view.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/skeleton.dart';
import '../../../../core/ui/val_widgets.dart';
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

/// Glyph of a match outcome, so a result never depends on colour alone
/// (PR-16): check for a win, cross for a loss, dash for a draw / unknown.
IconData outcomeGlyph(MatchOutcome outcome) => switch (outcome) {
  MatchOutcome.win => Icons.check_rounded,
  MatchOutcome.loss => Icons.close_rounded,
  MatchOutcome.draw || MatchOutcome.unknown => Icons.remove_rounded,
};

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
        context.l10n.matchOutcome(outcome),
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
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
  );
}

/// "+24 RR" in a tinted pill (match cards, form card).
class RrPill extends StatelessWidget {
  const RrPill(this.rr, {super.key});

  final int rr;

  @override
  Widget build(BuildContext context) {
    final color = rrColor(context, rr);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(ValRadius.pill),
      ),
      child: SignedRrText(rr, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

/// Label + value tile of a stats grid ("ACS" / "245").
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.tooltip,
    this.tag,
    this.tagColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final String? tooltip;
  final String? tag;
  final Color? tagColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final showTag = tag != null && scale < 1.35;
    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(ValRadius.small),
        border: tagColor != null
            ? Border(
                bottom: BorderSide(
                  color: tagColor!.withValues(alpha: 0.65),
                  width: 2.5,
                ),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ValText.label.copyWith(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (showTag)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    tag!,
                    maxLines: 1,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: tagColor ?? theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
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
      final scale = MediaQuery.textScalerOf(context).scale(1);
      final cols = (constraints.maxWidth < 320 || scale >= 1.35)
          ? (columns > 2 ? 2 : columns)
          : columns;
      final width = (constraints.maxWidth - gap * (cols - 1)) / cols;
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
              IconTile(icon: icon!, color: theme.colorScheme.primary),
              const SizedBox(width: 14),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(ValRadius.card),
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: const SkeletonShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Skeleton(height: 118, radius: 0, shimmer: false),
              Padding(
                padding: EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Skeleton(width: 150, height: 16, shimmer: false),
                          SizedBox(height: 6),
                          Skeleton(width: 120, height: 10, shimmer: false),
                        ],
                      ),
                    ),
                    Skeleton(width: 56, height: 10, shimmer: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Hero tag shared by a match card's map art and the match-detail hero, so
/// the map image flies from the history list into the detail.
String matchMapHeroTag(String matchId) =>
    'profile.match-map.${matchId.trim().toLowerCase()}';

/// Map artwork of a match: the splash, then the list-view banner when the
/// splash cannot be loaded, with a tinted, named placeholder while loading
/// and when neither loads. Some splashes are 4K PNGs (Skirmish maps, ~5 MB):
/// the card must never be a blank box while they download.
class MapArtImage extends StatelessWidget {
  const MapArtImage({
    super.key,
    required this.map,
    this.tint,
    this.alignment = Alignment.center,
  });

  final GameMap? map;

  /// Accent of the placeholder gradient (result color).
  final Color? tint;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final placeholder = MapArtPlaceholder(name: map?.displayName, tint: tint);
    final splash = map?.splash;
    final banner = map?.listViewIcon;
    final Widget fallback = banner == null || banner == splash
        ? placeholder
        : NetImage(
            banner,
            fit: BoxFit.cover,
            alignment: alignment,
            placeholder: placeholder,
            error: placeholder,
          );
    if (splash == null) return fallback;
    return NetImage(
      splash,
      fit: BoxFit.cover,
      alignment: alignment,
      placeholder: placeholder,
      error: fallback,
    );
  }
}

/// Dark gradient tinted by the match result with the map name as a faint
/// Anton watermark (loading / missing map art).
class MapArtPlaceholder extends StatelessWidget {
  const MapArtPlaceholder({super.key, this.name, this.tint});

  final String? name;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final accent = tint ?? ValColors.muted;
    final label = name?.trim();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              accent.withValues(alpha: 0.28),
              ValColors.surfaceHigh,
            ),
            ValColors.nearBlack,
          ],
        ),
      ),
      child: label == null || label.isEmpty
          ? const SizedBox.expand()
          : Align(
              alignment: const Alignment(0.9, 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ExcludeSemantics(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label.toUpperCase(),
                      maxLines: 1,
                      style: ValText.display(
                        44,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

/// Copies [text] and confirms with [message] in a snackbar.
void copyWithSnack(BuildContext context, String text, String message) {
  unawaited(Clipboard.setData(ClipboardData(text: text)));
  showAppSnackBar(context, message);
}

/// Circular win-rate gauge with the percentage in Anton.
class WinRateRing extends StatelessWidget {
  const WinRateRing({super.key, required this.rate, this.size = 72});

  final double? rate;

  /// Outer diameter; the percentage scales with it.
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = valColorsOf(context);
    final r = rate;
    final color = r == null
        ? colors.draw
        : r >= 0.5
        ? colors.win
        : colors.loss;
    return Semantics(
      container: true,
      label: context.l10n.profileWinRate,
      value: r == null ? context.l10n.competitiveNoValue : formatPercent(r),
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: r ?? 0),
          duration: ValMotion.slow,
          curve: ValMotion.curve,
          builder: (context, t, child) => CustomPaint(
            painter: _RingPainter(value: t, color: color, track: colors.track),
            child: child,
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  r == null
                      ? context.l10n.competitiveNoValue
                      : formatPercent(r),
                  maxLines: 1,
                  style: ValText.display(size * 0.28, color: color),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color, required this.track});

  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );
    final v = value.clamp(0.0, 1.0);
    if (v <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * v,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}
