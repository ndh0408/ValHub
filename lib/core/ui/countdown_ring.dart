import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import '../util/clock.dart';
import '../util/countdown.dart';
import '../util/format.dart';
import 'countdown_text.dart';

/// Small circular ring showing the fraction of [period] still left before
/// [expiresAt] (store reset, Night Market end, act end). Repaints only
/// itself, once per [tick].
class CountdownRing extends ConsumerStatefulWidget {
  const CountdownRing({
    super.key,
    required this.expiresAt,
    required this.period,
    this.size = 18,
    this.strokeWidth = 2.5,
    this.color,
    this.tick = const Duration(seconds: 1),
  });

  final DateTime expiresAt;

  /// Full length of the cycle (a day for the daily shop).
  final Duration period;
  final double size;
  final double strokeWidth;

  /// Defaults to the theme accent (red).
  final Color? color;
  final Duration tick;

  @override
  ConsumerState<CountdownRing> createState() => _CountdownRingState();
}

class _CountdownRingState extends ConsumerState<CountdownRing> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.tick, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(clockProvider).now();
    final left = remainingUntil(widget.expiresAt, now);
    final total = widget.period.inSeconds;
    final fraction = total <= 0
        ? 0.0
        : (left.inSeconds / total).clamp(0.0, 1.0).toDouble();
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: widget.size,
        child: CustomPaint(
          painter: _RingPainter(
            fraction: fraction,
            color: widget.color ?? Theme.of(context).colorScheme.primary,
            track: valColorsOf(context).track,
            stroke: widget.strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.color,
    required this.track,
    required this.stroke,
  });

  final double fraction;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    if (fraction <= 0) return;
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * fraction, false, fg);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction ||
      old.color != color ||
      old.track != track ||
      old.stroke != stroke;
}

/// Pill with a [CountdownRing] and a live [CountdownText]
/// ("◔ Làm mới sau 11:54:37"). Only the ring and the text rebuild each
/// second.
class CountdownPill extends StatelessWidget {
  const CountdownPill({
    super.key,
    required this.expiresAt,
    required this.period,
    this.builder,
    this.format = formatCountdown,
    this.onExpired,
    this.color,
    this.dense = false,
  });

  final DateTime expiresAt;
  final Duration period;
  final String Function(String formatted)? builder;
  final CountdownFormatter format;
  final VoidCallback? onExpired;

  /// Ring color (theme accent by default).
  final Color? color;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 10 : 12,
        vertical: dense ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(ValRadius.pill),
        border: Border.all(color: valColorsOf(context).hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CountdownRing(
            expiresAt: expiresAt,
            period: period,
            size: dense ? 14 : 16,
            strokeWidth: 2.2,
            color: color,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: CountdownText(
              expiresAt: expiresAt,
              format: format,
              builder: builder,
              onExpired: onExpired,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
