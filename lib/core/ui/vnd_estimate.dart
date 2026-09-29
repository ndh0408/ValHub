import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/remote_config.dart';
import '../config/vp_prices.dart';
import '../l10n/common_strings.dart';
import '../settings/app_settings.dart';
import '../theme/app_theme.dart';
import '../util/format.dart';
import 'currency_amount.dart';
import 'sub_page.dart';
import 'val_widgets.dart';

/// The VP → VND table when estimates should be shown: remote config has a
/// verified table and the user has not hidden them in Settings.
final vndPriceTableProvider = Provider<VpPriceTable?>((ref) {
  final enabled = ref.watch(
    appSettingsProvider.select((s) => s.showVndEstimate),
  );
  if (!enabled) return null;
  return ref.watch(remoteConfigProvider.select((c) => c.vpPrices));
});

/// `≈ 268.000 ₫` for [vp], or `null` when estimates are hidden.
String? vndEstimateText(WidgetRef ref, num vp) {
  final vnd = ref.watch(vndPriceTableProvider)?.estimateVnd(vp);
  return vnd == null ? null : formatEstimatedVnd(vnd);
}

/// Small muted "≈ 268.000 ₫" next to a VP price. Tapping it explains the
/// estimate (source, date, packages). Renders nothing when hidden.
class VndEstimate extends ConsumerWidget {
  const VndEstimate(
    this.vp, {
    super.key,
    this.style,
    this.color,
    this.interactive = true,
  });

  final num vp;
  final TextStyle? style;
  final Color? color;

  /// Tap for the source sheet (off inside other tap targets, e.g. cards).
  final bool interactive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = vndEstimateText(ref, vp);
    if (text == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final label = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: (style ?? theme.textTheme.bodySmall)?.copyWith(
        color: color ?? theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    if (!interactive) return label;
    return Tooltip(
      message: CommonStrings.vndEstimateTooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => unawaited(showVndInfoSheet(context)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: label,
        ),
      ),
    );
  }
}

/// Explains the VND estimate: how it is computed, the official packages,
/// the source and its date; lets the user hide the estimates.
Future<void> showVndInfoSheet(BuildContext context) => showValSheet<void>(
  context,
  title: CommonStrings.vndEstimateTitle,
  builder: (context, _) => const _VndInfoBody(),
);

class _VndInfoBody extends ConsumerWidget {
  const _VndInfoBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final table = ref.watch(remoteConfigProvider.select((c) => c.vpPrices));
    final muted = theme.colorScheme.onSurfaceVariant;
    final best = table?.bestValue;
    final url = table?.sourceUrl;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            CommonStrings.vndEstimateBody,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ),
        if (table != null && best != null) ...[
          SectionLabel(
            CommonStrings.vndPackagesTitle,
            padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
          ),
          GroupedSection(
            margin: EdgeInsets.zero,
            children: [
              for (final p in table.packages)
                GroupedRow(
                  dense: true,
                  title: formatVnd(p.vnd),
                  titleColor: identical(p, best)
                      ? legibleAccent(context, ValColors.green)
                      : null,
                  trailing: CurrencyAmount.vp(
                    p.vp,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CommonStrings.vndRate(formatVp(best.vp), formatVnd(best.vnd)),
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                if (table.sourceName != null)
                  Text(
                    CommonStrings.vndSource(table.sourceName!),
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                if (table.updatedAt != null)
                  Text(
                    CommonStrings.vndUpdated(formatDate(table.updatedAt!)),
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (url != null)
          OutlinedButton.icon(
            onPressed: () => unawaited(
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
            ),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text(CommonStrings.vndOpenSource),
          ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            unawaited(
              ref
                  .read(appSettingsProvider.notifier)
                  .update((s) => s.copyWith(showVndEstimate: false)),
            );
            final messenger = ScaffoldMessenger.maybeOf(context);
            Navigator.of(context).maybePop();
            messenger?.showSnackBar(
              const SnackBar(content: Text(CommonStrings.vndHidden)),
            );
          },
          child: const Text(CommonStrings.vndHide),
        ),
      ],
    );
  }
}
