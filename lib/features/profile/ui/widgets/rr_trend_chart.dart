import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/util/format.dart';
import '../../data/rr_trend.dart';

/// RR trend line (fl_chart): the running total of [changes] (oldest first),
/// starting at 0, with a dashed zero line. Dots are teal for gains and red
/// for losses.
///
/// fl_chart still uses legacy `flutter/material` lookups; the app wraps the
/// router in `MaterialUiCompatibilityBridge` (FS §2), and this widget passes
/// every color explicitly so it renders the same without it.
class RrTrendChart extends StatelessWidget {
  const RrTrendChart({
    super.key,
    required this.changes,
    this.height = 72,
    this.showDots = true,
  });

  final List<int> changes;
  final double height;
  final bool showDots;

  @override
  Widget build(BuildContext context) {
    final colors = valColorsOf(context);
    final scheme = Theme.of(context).colorScheme;
    final points = cumulativeRr(changes);
    final minY = points.reduce(math.min).toDouble();
    final maxY = points.reduce(math.max).toDouble();
    final pad = math.max(8.0, (maxY - minY) * 0.15);
    final net = points.last;
    final line = net >= 0 ? colors.win : colors.loss;
    return Semantics(
      label: formatSignedRr(net),
      child: SizedBox(
        height: height,
        child: LineChart(
          duration: Duration.zero,
          LineChartData(
            minX: 0,
            maxX: math.max(1, points.length - 1).toDouble(),
            minY: minY - pad,
            maxY: maxY + pad,
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: const LineTouchData(enabled: false),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: 0,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
                  strokeWidth: 1,
                  dashArray: const [4, 4],
                ),
              ],
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (var i = 0; i < points.length; i++)
                    FlSpot(i.toDouble(), points[i].toDouble()),
                ],
                isCurved: true,
                preventCurveOverShooting: true,
                color: line,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: showDots,
                  checkToShowDot: (spot, _) => spot.x > 0,
                  getDotPainter: (spot, _, _, _) {
                    final i = spot.x.toInt();
                    final change = i > 0 && i <= changes.length
                        ? changes[i - 1]
                        : 0;
                    return FlDotCirclePainter(
                      radius: 2.5,
                      color: change > 0
                          ? colors.win
                          : change < 0
                          ? colors.loss
                          : colors.draw,
                      strokeWidth: 0,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: line.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
