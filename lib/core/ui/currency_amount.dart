import 'package:valvn/core/l10n/labels/content_labels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../content/content_db.dart';
import '../content/content_fallbacks.dart';
import '../content/content_repository.dart';
import '../riot/riot_ids.dart';
import '../util/format.dart';
import 'net_image.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Amount with the currency icon from valorant-api (VP / KC / RP), e.g.
/// `[VP] 2.175`. Falls back to the bundled icon URL and a text label.
class CurrencyAmount extends ConsumerWidget {
  const CurrencyAmount({
    super.key,
    required this.currencyId,
    required this.amount,
    this.iconSize = 16,
    this.style,
    this.estimate = false,
    this.strikethrough = false,
    this.showLabel = false,
  });

  /// VALORANT Points.
  const CurrencyAmount.vp(
    this.amount, {
    super.key,
    this.iconSize = 16,
    this.style,
    this.estimate = false,
    this.strikethrough = false,
    this.showLabel = false,
  }) : currencyId = CurrencyIds.vp;

  /// Kingdom Credits.
  const CurrencyAmount.kc(
    this.amount, {
    super.key,
    this.iconSize = 16,
    this.style,
    this.estimate = false,
    this.strikethrough = false,
    this.showLabel = false,
  }) : currencyId = CurrencyIds.kc;

  /// Radianite Points.
  const CurrencyAmount.rp(
    this.amount, {
    super.key,
    this.iconSize = 16,
    this.style,
    this.estimate = false,
    this.strikethrough = false,
    this.showLabel = false,
  }) : currencyId = CurrencyIds.rp;

  final String currencyId;
  final num amount;
  final double iconSize;
  final TextStyle? style;

  /// Prefix with "≈" (fallback prices, B9).
  final bool estimate;

  /// Struck-through original price (Night Market, discounted bundle items).
  final bool strikethrough;

  /// Append the short label ("VP") after the number.
  final bool showLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value;
    final currency =
        db?.currency(currencyId) ?? ContentFallbacks.currency(currencyId);
    final base = style ?? DefaultTextStyle.of(context).style;
    final textStyle = strikethrough
        ? base.copyWith(
            decoration: TextDecoration.lineThrough,
            color: base.color?.withValues(alpha: 0.6),
          )
        : base;
    final text = [
      if (estimate) context.l10n.commonEstimatePrefix,
      formatNumber(amount),
      if (showLabel || currency?.displayIcon == null)
        if (currency != null) currency.label(context.l10n),
    ].join(' ');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (currency?.displayIcon != null) ...[
          NetImage(
            currency!.displayIcon,
            width: iconSize,
            height: iconSize,
            showSkeleton: false,
            color: textStyle.color,
            error: SizedBox(width: iconSize, height: iconSize),
          ),
          SizedBox(width: iconSize / 4),
        ],
        Text(text, style: textStyle),
      ],
    );
  }
}

/// Resolves a currency for widgets that need more than the amount.
Currency? currencyOf(WidgetRef ref, String currencyId) =>
    ref.watch(contentProvider).value?.currency(currencyId) ??
    ContentFallbacks.currency(currencyId);
