import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../util/clock.dart';
import '../util/countdown.dart';
import '../l10n/l10n.dart';

/// Formats the remaining time of a countdown.
typedef CountdownFormatter = String Function(Duration remaining);

/// Live-ticking countdown to [expiresAt] (SUMMARY §9.1). Default format:
/// `11:54:37` / `2 ngày 15:09:24`.
///
/// ```dart
/// CountdownText(
///   expiresAt: offers.expiresAt,
///   builder: (t) => StoreStrings.resetsIn(t),   // "Làm mới sau 11:54:37"
///   onExpired: () => ref.invalidate(storefrontProvider(puuid)),
/// )
/// ```
class CountdownText extends ConsumerStatefulWidget {
  const CountdownText({
    super.key,
    required this.expiresAt,
    this.format,
    this.builder,
    this.style,
    this.onExpired,
    this.textAlign,
  });

  final DateTime expiresAt;
  final CountdownFormatter? format;

  /// Wraps the formatted time in a sentence.
  final String Function(String formatted)? builder;
  final TextStyle? style;

  /// Called once when the countdown reaches zero (e.g. to refetch).
  final VoidCallback? onExpired;
  final TextAlign? textAlign;

  @override
  ConsumerState<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends ConsumerState<CountdownText> {
  Timer? _timer;
  bool _firedExpired = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didUpdateWidget(CountdownText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expiresAt != widget.expiresAt) _firedExpired = false;
  }

  void _tick() {
    if (!mounted) return;
    final now = ref.read(clockProvider).now();
    if (!_firedExpired && !now.isBefore(widget.expiresAt)) {
      _firedExpired = true;
      widget.onExpired?.call();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(clockProvider).now();
    final formatted = (widget.format ?? context.fmt.countdown)(
      remainingUntil(widget.expiresAt, now),
    );
    return Text(
      widget.builder?.call(formatted) ?? formatted,
      style:
          widget.style ??
          const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      textAlign: widget.textAlign,
    );
  }
}
