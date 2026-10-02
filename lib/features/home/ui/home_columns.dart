/// Adaptive column layout of the Home cards (docs/design/HOME.md §9.1): one
/// column on phones, two on wide phones / small tablets, three on large
/// screens, fewer at large text sizes, and two panes around a vertical
/// hinge on foldables.
library;

import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureType;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart' show OrdinalSortKey;

import '../data/home_card.dart';

/// Gap between cards (and between columns).
const kHomeCardGap = 16.0;

/// Columns for a content area [contentWidth] dp wide at [textScale]:
/// `≥ 1000` gives 3, `≥ 568` gives 2, otherwise 1; large text means fewer
/// columns (each column keeps at least `300 × textScale` dp).
int homeColumnCount({required double contentWidth, required double textScale}) {
  final base = contentWidth >= 1000
      ? 3
      : contentWidth >= 568
      ? 2
      : 1;
  final scale = textScale.clamp(1.0, 2.0);
  final fit = math.max(1, (contentWidth / (300 * scale)).floor());
  return math.min(base, fit);
}

/// The vertical hinge or fold of a foldable that splits the screen, if any.
DisplayFeature? verticalHinge(List<DisplayFeature> features) {
  for (final f in features) {
    final isSplit =
        f.type == DisplayFeatureType.hinge || f.type == DisplayFeatureType.fold;
    if (isSplit && f.bounds.height > f.bounds.width) return f;
  }
  return null;
}

/// Lays [cards] out in columns. Cards go round-robin (`i % columns`), so the
/// user's order reads across the columns; screen readers and keyboard focus
/// follow the user's order, not the visual columns.
class HomeColumns extends StatelessWidget {
  const HomeColumns({
    super.key,
    required this.cards,
    required this.builder,
    this.sidePadding = 0,
  });

  final List<HomeCardId> cards;

  /// Builds the card widget of the card at position [index] of [cards].
  final Widget Function(BuildContext context, HomeCardId card, int index)
  builder;

  /// Horizontal padding around this widget, to place a hinge gap correctly.
  final double sidePadding;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final hinge = verticalHinge(MediaQuery.displayFeaturesOf(context));
    return LayoutBuilder(
      builder: (context, constraints) {
        var columns = homeColumnCount(
          contentWidth: constraints.maxWidth,
          textScale: scale,
        );
        double? leftPane;
        double gap = kHomeCardGap;
        if (hinge != null && columns >= 2) {
          // Two panes: one column on each side of the hinge.
          columns = 2;
          gap = hinge.bounds.width;
          leftPane = (hinge.bounds.left - sidePadding).clamp(
            120.0,
            math.max(120.0, constraints.maxWidth - 120 - gap),
          );
        }
        if (columns <= 1) {
          return _order(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(height: kHomeCardGap),
                  _slot(context, i),
                ],
              ],
            ),
          );
        }
        final cols = [
          for (var c = 0; c < columns; c++)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = c; i < cards.length; i += columns) ...[
                  if (i >= columns) const SizedBox(height: kHomeCardGap),
                  _slot(context, i),
                ],
              ],
            ),
        ];
        return _order(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var c = 0; c < cols.length; c++) ...[
                if (c > 0) SizedBox(width: gap),
                if (c == 0 && leftPane != null)
                  SizedBox(width: leftPane, child: cols[c])
                else
                  Expanded(child: cols[c]),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _order(Widget child) =>
      FocusTraversalGroup(policy: OrderedTraversalPolicy(), child: child);

  Widget _slot(BuildContext context, int i) => Semantics(
    // A node per card, so the sort key orders the cards themselves.
    container: true,
    sortKey: OrdinalSortKey(i.toDouble()),
    child: FocusTraversalOrder(
      order: NumericFocusOrder(i.toDouble()),
      child: builder(context, cards[i], i),
    ),
  );
}
