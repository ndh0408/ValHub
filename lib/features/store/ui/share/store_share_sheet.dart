import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account_providers.dart';
import '../../../../core/config/local_price.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/error_view.dart';
import '../../../../core/ui/sub_page.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../providers/store_share.dart';
import 'store_share_card.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// "Chia sẻ ảnh": preview of the branded picture with the "Hiện Riot ID"
/// (off by default) and "Hiện giá quy đổi" switches, then the platform's
/// native share sheet with the PNG.
Future<void> showStoreShareSheet(
  BuildContext context, {
  required StoreShareData data,
}) {
  Haptics.light();
  return showValSheet<void>(
    context,
    title: data.isNightMarket
        ? context.l10n.storeShareNightMarketTitle
        : context.l10n.storeShareDailyTitle,
    subtitle: context.l10n.storeShareSubtitle,
    scrollable: true,
    initialSize: 0.92,
    minSize: 0.5,
    maxSize: 0.95,
    useRootNavigator: true,
    builder: (context, controller) =>
        StoreShareSheetBody(data: data, controller: controller),
  );
}

/// Body of [showStoreShareSheet].
class StoreShareSheetBody extends ConsumerStatefulWidget {
  const StoreShareSheetBody({super.key, required this.data, this.controller});

  final StoreShareData data;
  final ScrollController? controller;

  @override
  ConsumerState<StoreShareSheetBody> createState() =>
      _StoreShareSheetBodyState();
}

class _StoreShareSheetBodyState extends ConsumerState<StoreShareSheetBody> {
  final _boundary = GlobalKey();
  final _shareButton = GlobalKey();
  bool _showRiotId = false;
  bool _showPrice = true;
  bool _ready = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_preload()));
  }

  /// Loads every render before the capture, so the PNG never has holes.
  /// A render that fails to load is drawn as a placeholder.
  Future<void> _preload() async {
    final factory = ref.read(shareImageProviderFactoryProvider);
    final loads = <Future<void>>[
      for (final item in widget.data.items)
        if (item.imageUrl case final url?)
          if (factory(url) case final provider?)
            precacheImage(provider, context, onError: (_, _) {}),
    ];
    try {
      await Future.wait(loads).timeout(const Duration(seconds: 15));
    } on Object {
      // Timeout / failure: share with placeholders rather than never.
    }
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _share() async {
    final messages = context.l10n;
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _boundary.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('no boundary');
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) throw StateError('no png');
      final stamp = _stamp(widget.data.createdAt);
      final nm = widget.data.isNightMarket;
      final box = _shareButton.currentContext?.findRenderObject() as RenderBox?;
      final origin = box == null || !box.hasSize
          ? null
          : box.localToGlobal(Offset.zero) & box.size;
      await ref.read(storeImageSharerProvider)(
        bytes.buffer.asUint8List(),
        fileName: nm
            ? messages.storeShareFileNightMarket(stamp)
            : messages.storeShareFileDaily(stamp),
        subject: nm
            ? messages.storeShareSubjectNightMarket
            : messages.storeShareSubjectDaily,
        origin: origin,
      );
    } on Object {
      if (mounted) showAppSnackBar(context, messages.storeShareFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// `2026-09-29` (ASCII file-name stamp, local date).
  static String _stamp(DateTime d) {
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rawRiotId = ref.watch(activeAccountProvider.select((a) => a?.riotId));
    final riotId = rawRiotId == null || rawRiotId.isEmpty ? null : rawRiotId;
    final price = ref.watch(localPriceProvider);
    final factory = ref.watch(shareImageProviderFactoryProvider);
    final busy = _busy || !_ready;
    final switches = [
      if (riotId != null)
        _SwitchRow(
          title: context.l10n.storeShareShowRiotId,
          subtitle: context.l10n.storeShareShowRiotIdHint,
          icon: Icons.badge_outlined,
          value: _showRiotId,
          onChanged: (v) => setState(() => _showRiotId = v),
        ),
      if (price != null)
        _SwitchRow(
          title: context.l10n.storeShareShowPrice,
          subtitle: context.l10n.storeShareShowPriceHint,
          icon: Icons.payments_outlined,
          value: _showPrice,
          onChanged: (v) => setState(() => _showPrice = v),
        ),
    ];
    return ListView(
      controller: widget.controller,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        // The preview is the picture itself, scaled to the sheet width.
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ValRadius.card),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: RepaintBoundary(
                key: _boundary,
                child: StoreShareCard(
                  data: widget.data,
                  riotId: _showRiotId ? riotId : null,
                  price: _showPrice ? price : null,
                  imageFor: factory,
                ),
              ),
            ),
          ),
        ),
        if (switches.isNotEmpty) ...[
          const SizedBox(height: 16),
          GroupedSection(margin: EdgeInsets.zero, children: switches),
        ],
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            key: _shareButton,
            onPressed: busy ? null : () => unawaited(_share()),
            icon: busy
                ? SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                : Icon(isCupertino(context) ? Icons.ios_share : Icons.share),
            label: Text(
              _ready
                  ? context.l10n.storeShareButton
                  : context.l10n.storeSharePreparing,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
    value: value,
    onChanged: (v) {
      Haptics.selection();
      onChanged(v);
    },
    secondary: Icon(icon, color: legibleAccent(context, ValColors.red, min: 3)),
    title: Text(title),
    subtitle: Text(subtitle),
  );
}
