import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/countdown_text.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/format.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Thin design-system progress bar (theme accent fill on the track color);
/// the fill animates to new values.
class BpProgressBar extends StatelessWidget {
  const BpProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.color,
    this.background,
    this.semanticsLabel,
  });

  /// Fill, 0–1 (clamped).
  final double value;
  final double height;
  final Color? color;
  final Color? background;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => ValProgressBar(
    value: value,
    height: height,
    color: color ?? Theme.of(context).colorScheme.primary,
    trackColor: background,
    semanticsLabel: semanticsLabel,
  );
}

/// Small label badge ("Premium", "Miễn phí", "Hiện tại").
class BpBadge extends StatelessWidget {
  const BpBadge(
    this.text, {
    super.key,
    required this.color,
    this.filled = false,
    this.icon,
    this.uppercase = false,
  });

  final String text;
  final Color color;

  /// "PREMIUM" style (letter-spaced capitals).
  final bool uppercase;

  /// Solid background with readable text instead of a tinted one.
  final bool filled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = filled
        ? readableOn(color)
        : legibleAccent(context, color, min: 3.5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
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
              uppercase ? text.toUpperCase() : text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w800,
                letterSpacing: uppercase ? 0.8 : 0.4,
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
    this.format,
    this.onExpired,
    this.icon = Icons.schedule,
    this.color,
    this.style,
  });

  final DateTime expiresAt;
  final String Function(String formatted) builder;
  final CountdownFormatter? format;
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

/// The local wall-clock moment of [at] in the device time zone with a
/// sentence around it ("Làm mới lúc 07:00 ngày mai"), read against the app
/// clock so it changes from "ngày mai" to "hôm nay" at midnight.
class BpWallTimeText extends ConsumerWidget {
  const BpWallTimeText({
    super.key,
    required this.at,
    required this.builder,
    this.style,
    this.color,
  });

  final DateTime at;

  /// Wraps the formatted moment, e.g. `BattlePassStrings.resetsAtWall`.
  final String Function(String wall) builder;
  final TextStyle? style;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider).now();
    return Text(
      builder(context.fmt.wallTime(at, now)),
      style: (style ?? theme.textTheme.bodySmall)?.copyWith(
        color: color ?? theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Compact countdown for section headers ("🕑 2 ngày 15:09:24").
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
        Icon(Icons.schedule, size: 15, color: muted),
        const SizedBox(width: 5),
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
        borderRadius: BorderRadius.circular(ValRadius.small),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 16, color: warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.commonOfflineCached(formatTime(receivedAt)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: legibleAccent(context, warning),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header used on S20: bold title on the left, the countdown (or
/// any [trailing]) on the right, and a muted [subtitle] under the title.
/// The trailing widget drops under the title when space runs out.
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
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              ?end,
            ],
          ),
          if (sub != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                sub,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ),
        ],
      ),
    );
  }
}
