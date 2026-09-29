import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/countdown_text.dart';
import '../../../../core/util/format.dart';

/// Thin, square-cornered Valorant-style progress bar.
class BpProgressBar extends StatelessWidget {
  const BpProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.color,
    this.background,
  });

  /// Fill, 0–1 (clamped).
  final double value;
  final double height;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final v = value.isFinite ? value.clamp(0.0, 1.0) : 0.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(1),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: background ?? scheme.surfaceContainerHighest),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: v,
              child: ColoredBox(color: color ?? ValColors.red),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small label badge ("Premium", "Miễn phí", "Hiện tại").
class BpBadge extends StatelessWidget {
  const BpBadge(
    this.text, {
    super.key,
    required this.color,
    this.filled = false,
    this.icon,
  });

  final String text;
  final Color color;

  /// Solid background with white text instead of a tinted one.
  final bool filled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(2),
        border: filled ? null : Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Clock icon + live countdown sentence.
class BpCountdownLine extends StatelessWidget {
  const BpCountdownLine({
    super.key,
    required this.expiresAt,
    required this.builder,
    this.format = formatCountdown,
    this.onExpired,
    this.icon = Icons.schedule,
    this.color,
    this.style,
  });

  final DateTime expiresAt;
  final String Function(String formatted) builder;
  final CountdownFormatter format;
  final VoidCallback? onExpired;
  final IconData icon;
  final Color? color;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 15, color: c),
        const SizedBox(width: 6),
        Expanded(
          child: CountdownText(
            expiresAt: expiresAt,
            builder: builder,
            format: format,
            onExpired: onExpired,
            style: (style ?? theme.textTheme.bodySmall)?.copyWith(
              color: c,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact countdown for section headers ("2 ngày 15:09:24").
class BpHeaderCountdown extends StatelessWidget {
  const BpHeaderCountdown({
    super.key,
    required this.expiresAt,
    this.builder,
    this.onExpired,
  });

  final DateTime expiresAt;
  final String Function(String formatted)? builder;
  final VoidCallback? onExpired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule, size: 14, color: muted),
        const SizedBox(width: 4),
        Flexible(
          child: CountdownText(
            expiresAt: expiresAt,
            builder: builder,
            onExpired: onExpired,
            textAlign: TextAlign.end,
            style: theme.textTheme.labelMedium?.copyWith(
              color: muted,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

/// "Đang ngoại tuyến — hiển thị dữ liệu đã lưu (14:05)." (X4).
class BpOfflineNotice extends StatelessWidget {
  const BpOfflineNotice({super.key, required this.receivedAt});

  final DateTime receivedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warning = valColorsOf(context).warning;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 16, color: warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              CommonStrings.offlineCached(formatTime(receivedAt)),
              style: theme.textTheme.bodySmall?.copyWith(color: warning),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section title row used on S20 ("Nhiệm vụ hằng tuần" + countdown).
class BpSectionTitle extends StatelessWidget {
  const BpSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sub = subtitle;
    final end = trailing;
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          // Subtitle left, countdown right, on their own line so the title
          // never wraps on narrow phones.
          if (sub != null || end != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 2,
                children: [
                  if (sub != null)
                    Text(
                      sub,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ?end,
                ],
              ),
            ),
        ],
      ),
    );
  }
}
