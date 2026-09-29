import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/local_price.dart';
import '../config/vp_prices.dart';
import '../l10n/common_strings.dart';
import '../settings/app_settings.dart';
import '../theme/app_theme.dart';
import '../util/format.dart';
import 'adaptive.dart';
import 'currency_amount.dart';
import 'sub_page.dart';
import 'val_widgets.dart';

/// `≈ 268.000 ₫` for [vp] in the user's currency, or `null` when estimates
/// are hidden (turned off, or no verified / user-entered price).
String? priceEstimateText(WidgetRef ref, num vp) =>
    ref.watch(localPriceProvider)?.format(vp);

/// Small muted "≈ 268.000 ₫" next to a VP price. Tapping it explains the
/// estimate (source, date, packs, the user's own price). Renders nothing
/// when estimates are hidden.
class PriceEstimate extends ConsumerWidget {
  const PriceEstimate(
    this.vp, {
    super.key,
    this.style,
    this.color,
    this.interactive = true,
  });

  final num vp;
  final TextStyle? style;
  final Color? color;

  /// Tap for the explanation sheet (off inside other tap targets, e.g.
  /// cards).
  final bool interactive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = priceEstimateText(ref, vp);
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
      message: CommonStrings.priceEstimateTooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => unawaited(showPriceEstimateInfoSheet(context)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: label,
        ),
      ),
    );
  }
}

/// Explains the estimate: how it is computed, the packs, the source (URL +
/// date, or "do bạn nhập"); lets the user enter their own price or hide the
/// estimates.
Future<void> showPriceEstimateInfoSheet(BuildContext context) =>
    showValSheet<void>(
      context,
      title: CommonStrings.priceEstimateTitle,
      builder: (context, _) => const _InfoBody(),
    );

class _InfoBody extends ConsumerWidget {
  const _InfoBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final price = ref.watch(localPriceSourceProvider);
    final muted = theme.colorScheme.onSurfaceVariant;
    final smallMuted = theme.textTheme.bodySmall?.copyWith(color: muted);
    final table = price?.table;
    final best = table?.bestValue;
    final url = table?.source;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            price == null
                ? CommonStrings.priceUnavailable
                : CommonStrings.priceEstimateBody,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ),
        if (price != null && table != null && best != null) ...[
          SectionLabel(
            CommonStrings.pricePacksTitle,
            padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
          ),
          GroupedSection(
            margin: EdgeInsets.zero,
            children: [
              for (final p in table.packs)
                GroupedRow(
                  dense: true,
                  title: price.formatPrice(p.price),
                  titleColor: p == best
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
                  CommonStrings.priceBestPack(
                    formatVp(best.vp),
                    price.formatPrice(best.price),
                  ),
                  style: smallMuted,
                ),
                Text(
                  price.isUserProvided
                      ? CommonStrings.priceSourceUser
                      : CommonStrings.priceSourceOfficial(price.country ?? ''),
                  style: smallMuted,
                ),
                if (url != null)
                  Text(
                    CommonStrings.priceSource(Uri.tryParse(url)?.host ?? url),
                    style: smallMuted,
                  ),
                if (table.updated != null)
                  Text(
                    CommonStrings.priceUpdated(formatDate(table.updated!)),
                    style: smallMuted,
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
            label: const Text(CommonStrings.priceOpenSource),
          ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: () {
            Navigator.of(context).maybePop();
            unawaited(showVpPriceOverrideSheet(context));
          },
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(
            price?.isUserProvided ?? false
                ? CommonStrings.priceEditOwn
                : CommonStrings.priceEnterOwn,
          ),
        ),
        if (price != null) ...[
          const SizedBox(height: 4),
          TextButton(
            onPressed: () {
              unawaited(
                ref
                    .read(appSettingsProvider.notifier)
                    .update((s) => s.copyWith(showPriceEstimate: false)),
              );
              final messenger = ScaffoldMessenger.maybeOf(context);
              Navigator.of(context).maybePop();
              messenger?.showSnackBar(
                const SnackBar(content: Text(CommonStrings.priceHidden)),
              );
            },
            child: const Text(CommonStrings.priceHide),
          ),
        ],
      ],
    );
  }
}

/// Currency of the device's primary locale ("VND" for vi_VN, "USD" for
/// en_US), used to pre-fill the editor.
String? deviceCurrencyCode() {
  try {
    final locale = PlatformDispatcher.instance.locale.toString();
    return normalizeCurrencyCode(
      NumberFormat.simpleCurrency(locale: locale).currencyName,
    );
  } on Object {
    return null;
  }
}

/// "Giá gói VP của bạn": currency + one pack (VP and price). Saved on this
/// device only; used for the estimates instead of any official table.
Future<void> showVpPriceOverrideSheet(BuildContext context) =>
    showValSheet<void>(
      context,
      title: CommonStrings.priceOverrideTitle,
      builder: (context, _) => const _OverrideEditor(),
    );

class _OverrideEditor extends ConsumerStatefulWidget {
  const _OverrideEditor();

  @override
  ConsumerState<_OverrideEditor> createState() => _OverrideEditorState();
}

class _OverrideEditorState extends ConsumerState<_OverrideEditor> {
  late final VpPriceOverride? _initial = ref.read(vpPriceOverrideProvider);
  late final _currency = TextEditingController(
    text:
        _initial?.currency ??
        ref.read(localPriceSourceProvider)?.currency ??
        deviceCurrencyCode() ??
        '',
  );
  late final _vp = TextEditingController(
    text: _initial == null ? '' : '${_initial.vp}',
  );
  late final _price = TextEditingController(
    text: _initial == null ? '' : _plain(_initial.price),
  );
  bool _submitted = false;

  static String _plain(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  void dispose() {
    _currency.dispose();
    _vp.dispose();
    _price.dispose();
    super.dispose();
  }

  String? get _currencyCode => normalizeCurrencyCode(_currency.text);
  int? get _vpValue {
    final v = int.tryParse(_vp.text.replaceAll(RegExp(r'[\s.,]'), ''));
    return v != null && v > 0 ? v : null;
  }

  double? get _priceValue => parseLocalizedAmount(
    _price.text,
    minorDigits: currencyDecimalDigits(_currencyCode ?? 'USD'),
  );

  VpPriceOverride? get _value {
    final currency = _currencyCode;
    final vp = _vpValue;
    final price = _priceValue;
    if (currency == null || vp == null || price == null) return null;
    return VpPriceOverride(currency: currency, vp: vp, price: price);
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    final value = _value;
    if (value == null) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    await ref.read(vpPriceOverrideProvider.notifier).set(value);
    await ref
        .read(appSettingsProvider.notifier)
        .update((s) => s.copyWith(showPriceEstimate: true));
    Haptics.light();
    navigator.pop();
    messenger?.showSnackBar(
      const SnackBar(content: Text(CommonStrings.priceOverrideSaved)),
    );
  }

  Future<void> _remove() async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    await ref.read(vpPriceOverrideProvider.notifier).clear();
    navigator.pop();
    messenger?.showSnackBar(
      const SnackBar(content: Text(CommonStrings.priceOverrideRemoved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final value = _value;
    final example = value == null
        ? null
        : LocalPrice(table: value.toTable(), source: LocalPriceSource.user);
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      children: [
        Text(
          CommonStrings.priceOverrideBody,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: muted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _currency,
          textCapitalization: TextCapitalization.characters,
          maxLength: 3,
          decoration: InputDecoration(
            labelText: CommonStrings.priceOverrideCurrency,
            hintText: CommonStrings.priceOverrideCurrencyHint,
            counterText: '',
            errorText: _submitted && _currencyCode == null
                ? CommonStrings.priceOverrideInvalidCurrency
                : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _vp,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: CommonStrings.priceOverrideVp,
                  hintText: '1000',
                  errorText: _submitted && _vpValue == null
                      ? CommonStrings.priceOverrideInvalidNumber
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: CommonStrings.priceOverridePrice,
                  suffixText: _currencyCode,
                  errorText: _submitted && _priceValue == null
                      ? CommonStrings.priceOverrideInvalidNumber
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (example != null) ...[
          const SizedBox(height: 12),
          Text(
            CommonStrings.priceOverrideExample(
              formatVp(1775),
              example
                      .format(1775)
                      ?.replaceFirst('${CommonStrings.estimatePrefix} ', '') ??
                  '',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: legibleAccent(context, ValColors.green),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => unawaited(_save()),
          child: const Text(CommonStrings.priceOverrideSave),
        ),
        if (_initial != null) ...[
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: () => unawaited(_remove()),
            child: const Text(CommonStrings.priceOverrideRemove),
          ),
        ],
      ],
    );
  }
}
