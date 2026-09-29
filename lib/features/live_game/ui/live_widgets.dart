import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/util/clock.dart';
import '../live_game_strings.dart';
import '../providers/live_game_providers.dart';

/// Status pill of the sheet header (G3): amber agent select, green in
/// progress, grey ended.
enum LiveStatus {
  agentSelect,
  inProgress,
  ended;

  String get label => switch (this) {
    agentSelect => LiveGameStrings.statusAgentSelect,
    inProgress => LiveGameStrings.statusInProgress,
    ended => LiveGameStrings.statusEnded,
  };

  Color color(BuildContext context) {
    final c = valColorsOf(context);
    return switch (this) {
      agentSelect => c.warning,
      inProgress => c.win,
      ended => c.muted,
    };
  }
}

class LiveStatusPill extends StatelessWidget {
  const LiveStatusPill(this.status, {super.key});

  final LiveStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              status.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small tag ("BẠN", "Tổ đội", "Đã khóa").
class LiveTag extends StatelessWidget {
  const LiveTag(this.label, {super.key, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
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

/// Colors of party badges (group 0, 1, …).
const kPartyColors = <Color>[
  Color(0xFFF5A623),
  Color(0xFF7B8CFF),
  Color(0xFF17E5B3),
  Color(0xFFE86BD6),
  Color(0xFF5BC0EB),
];

Color partyColor(int group) => kPartyColors[group % kPartyColors.length];

/// Rebuilds every [period] with the app clock's "now" (queue timers).
class TickingBuilder extends ConsumerStatefulWidget {
  const TickingBuilder({
    super.key,
    required this.builder,
    this.period = const Duration(seconds: 1),
  });

  final Widget Function(BuildContext context, DateTime now) builder;
  final Duration period;

  @override
  ConsumerState<TickingBuilder> createState() => _TickingBuilderState();
}

class _TickingBuilderState extends ConsumerState<TickingBuilder> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.period, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, ref.watch(clockProvider).now());
}

/// Refresh button with a countdown ring to the next automatic poll (G9).
/// Tap = poll now.
class LiveRefreshRing extends ConsumerStatefulWidget {
  const LiveRefreshRing({super.key, required this.puuid, this.size = 40});

  final String puuid;
  final double size;

  @override
  ConsumerState<LiveRefreshRing> createState() => _LiveRefreshRingState();
}

class _LiveRefreshRingState extends ConsumerState<LiveRefreshRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ring = AnimationController(vsync: this);
  ValueNotifier<DateTime?>? _source;
  LiveGameController? _controller;
  bool _busy = false;

  @override
  void dispose() {
    _source?.removeListener(_sync);
    _ring.dispose();
    super.dispose();
  }

  void _attach(LiveGameController controller) {
    if (identical(controller, _controller)) return;
    _source?.removeListener(_sync);
    _controller = controller;
    _source = controller.nextPollAt..addListener(_sync);
    _sync();
  }

  /// Re-reads the schedule; deferred to after the frame when it changes
  /// while widgets are building (provider rebuilds).
  void _sync() {
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
      return;
    }
    setState(() {});
    final controller = _controller;
    final at = _source?.value;
    if (controller == null || at == null) {
      _ring.stop();
      _ring.value = 0;
      return;
    }
    final total = controller.interval.inMilliseconds;
    final left = at
        .difference(ref.read(clockProvider).now())
        .inMilliseconds
        .clamp(0, math.max(total, 1))
        .toInt();
    _ring.value = total <= 0 ? 0 : left / total;
    if (left > 0) {
      unawaited(
        _ring
            .animateTo(0, duration: Duration(milliseconds: left))
            .orCancel
            .catchError((Object _) {}),
      );
    }
  }

  Future<void> _refresh() async {
    final controller = _controller;
    if (controller == null || _busy) return;
    setState(() => _busy = true);
    try {
      await controller.refresh();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(liveGameProvider(widget.puuid).notifier);
    if (!identical(controller, _controller)) {
      // Attach after this frame: syncing the ring notifies listeners.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _attach(controller);
      });
    }
    final theme = Theme.of(context);
    final size = widget.size;
    final seconds = (_controller?.interval.inSeconds ?? 0);
    return Tooltip(
      message: _source?.value == null
          ? LiveGameStrings.refresh
          : LiveGameStrings.refreshIn(seconds),
      child: InkResponse(
        onTap: _busy ? null : () => unawaited(_refresh()),
        radius: size / 2 + 4,
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_busy)
                SizedBox.square(
                  dimension: size - 6,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                )
              else
                AnimatedBuilder(
                  animation: _ring,
                  builder: (context, _) => SizedBox.square(
                    dimension: size - 6,
                    child: CircularProgressIndicator(
                      value: _ring.value,
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ),
              Icon(
                Icons.refresh,
                size: size * 0.5,
                semanticLabel: LiveGameStrings.refresh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
