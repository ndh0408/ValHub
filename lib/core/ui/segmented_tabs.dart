import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'adaptive.dart';

/// One segment of [SegmentedTabs].
class SegmentedTab<T> {
  const SegmentedTab({
    required this.value,
    required this.label,
    this.showDot = false,
    this.icon,
  });

  final T value;
  final String label;

  /// Red dot (e.g. unseen Night Market).
  final bool showDot;

  /// Optional leading icon.
  final IconData? icon;
}

/// Valorant-style "glass capsule" segmented control: a translucent pill
/// track with a red highlight that slides between segments
/// ("Hằng ngày · Chợ Đêm · Phụ kiện · Bundle").
///
/// - [expand] `true`: segments share the width equally (labels scale down
///   instead of scrolling off a 320–360 dp screen).
/// - [expand] `false` (default): segments take their natural width and the
///   track scrolls horizontally; the selected one is scrolled into view.
///
/// Every change plays a selection haptic.
class SegmentedTabs<T> extends StatefulWidget {
  const SegmentedTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    this.expand = false,
  });

  final List<SegmentedTab<T>> tabs;
  final T selected;
  final ValueChanged<T> onChanged;
  final EdgeInsets padding;
  final bool expand;

  @override
  State<SegmentedTabs<T>> createState() => _SegmentedTabsState<T>();
}

class _SegmentedTabsState<T> extends State<SegmentedTabs<T>> {
  final _stackKey = GlobalKey();
  List<GlobalKey> _keys = const [];

  /// Selected segment's rect inside the track (scroll mode), measured after
  /// layout; `null` until the first measurement.
  Rect? _rect;

  int get _index {
    final i = widget.tabs.indexWhere((t) => t.value == widget.selected);
    return i < 0 ? 0 : i;
  }

  void _syncKeys() {
    if (_keys.length != widget.tabs.length) {
      _keys = [for (final _ in widget.tabs) GlobalKey()];
      _rect = null;
    }
  }

  @override
  void didUpdateWidget(SegmentedTabs<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected && !widget.expand) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
    }
  }

  void _reveal() {
    if (!mounted || _keys.isEmpty) return;
    final ctx = _keys[_index].currentContext;
    if (ctx == null) return;
    unawaited(
      Scrollable.ensureVisible(
        ctx,
        duration: ValMotion.medium,
        curve: ValMotion.curve,
        alignment: 0.5,
      ),
    );
  }

  void _measure(Duration _) {
    if (!mounted || _keys.isEmpty) return;
    final stack = _stackKey.currentContext?.findRenderObject();
    final seg = _keys[_index].currentContext?.findRenderObject();
    if (stack is! RenderBox || seg is! RenderBox) return;
    if (!stack.hasSize || !seg.hasSize) return;
    final offset = seg.localToGlobal(Offset.zero, ancestor: stack);
    final rect = offset & seg.size;
    if (rect != _rect) setState(() => _rect = rect);
  }

  void _tap(T value) {
    if (value == widget.selected) return;
    Haptics.selection();
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    _syncKeys();
    final n = widget.tabs.length;
    final index = _index;
    if (!widget.expand) {
      WidgetsBinding.instance.addPostFrameCallback(_measure);
    }
    final rect = _rect;
    // Before the first measurement the selected segment paints its own
    // highlight, so the very first frame is already correct.
    final ownHighlight = !widget.expand && rect == null;

    final segments = <Widget>[
      for (var i = 0; i < n; i++)
        _Segment(
          key: _keys[i],
          tab: widget.tabs[i],
          selected: i == index,
          paintHighlight: ownHighlight && i == index,
          compact: widget.expand,
          onTap: () => _tap(widget.tabs[i].value),
        ),
    ];

    final Widget highlight;
    if (widget.expand) {
      highlight = Positioned.fill(
        child: AnimatedAlign(
          duration: ValMotion.medium,
          curve: ValMotion.curve,
          alignment: Alignment(n <= 1 ? 0 : -1 + 2 * index / (n - 1), 0),
          child: FractionallySizedBox(
            widthFactor: n == 0 ? 1 : 1 / n,
            heightFactor: 1,
            child: const _Highlight(),
          ),
        ),
      );
    } else if (rect != null) {
      highlight = AnimatedPositioned.fromRect(
        duration: ValMotion.medium,
        curve: ValMotion.curve,
        rect: rect,
        child: const _Highlight(),
      );
    } else {
      highlight = const SizedBox.shrink();
    }

    // Segment labels cap their text scale (like iOS segmented controls) so
    // the pinned bar keeps a fixed height at 200 % text size.
    final track = MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.25,
      child: GlassCapsule(
        child: Stack(
          key: _stackKey,
          children: [
            highlight,
            Row(
              mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                for (final s in segments)
                  widget.expand ? Expanded(child: s) : s,
              ],
            ),
          ],
        ),
      ),
    );
    if (widget.expand) {
      return Padding(padding: widget.padding, child: track);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: widget.padding,
      child: track,
    );
  }
}

/// Translucent pill track of [SegmentedTabs] (and other small chrome):
/// `s1` at 72% with a hairline edge.
class GlassCapsule extends StatelessWidget {
  const GlassCapsule({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(4),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withValues(
          alpha: dark ? 0.72 : 0.9,
        ),
        borderRadius: BorderRadius.circular(ValRadius.pill),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: child,
    );
  }
}

class _Highlight extends StatelessWidget {
  const _Highlight();

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ValRadius.pill),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(accent, Colors.white, 0.12)!, accent],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    super.key,
    required this.tab,
    required this.selected,
    required this.paintHighlight,
    required this.compact,
    required this.onTap,
  });

  final SegmentedTab<Object?> tab;
  final bool selected;
  final bool paintHighlight;

  /// Equal-width mode: tighter padding, labels scale down to fit.
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;
    final dotColor = selected ? scheme.onPrimary : scheme.primary;
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tab.icon != null) ...[
          Icon(tab.icon, size: 16, color: fg),
          const SizedBox(width: 6),
        ],
        AnimatedDefaultTextStyle(
          duration: ValMotion.fast,
          style: (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
            color: fg,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
          child: Text(tab.label, maxLines: 1),
        ),
        if (tab.showDot) ...[
          const SizedBox(width: 6),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
        ],
      ],
    );
    if (compact) {
      content = FittedBox(fit: BoxFit.scaleDown, child: content);
    }
    return Semantics(
      container: true,
      selected: selected,
      button: true,
      label: tab.label,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Ink(
            decoration: paintHighlight
                ? BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(ValRadius.pill),
                  )
                : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 8 : 16,
                  vertical: 8,
                ),
                child: Center(widthFactor: 1, child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted strip for small pinned chrome (segment bars, filter rows): blurs
/// the content scrolling underneath. Only use it on fixed, small areas —
/// never over a whole scrolling list.
class GlassBar extends StatelessWidget {
  const GlassBar({super.key, required this.child, this.opacity = 0.82});

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: ColoredBox(
          color: bg.withValues(alpha: opacity),
          child: child,
        ),
      ),
    );
  }
}

/// Pinned [SliverPersistentHeader] delegate with a [GlassBar] background.
class GlassHeaderDelegate extends SliverPersistentHeaderDelegate {
  GlassHeaderDelegate({required this.child, this.height = 56});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => GlassBar(
    child: SizedBox(
      height: height,
      child: Align(alignment: Alignment.centerLeft, child: child),
    ),
  );

  @override
  bool shouldRebuild(GlassHeaderDelegate oldDelegate) =>
      oldDelegate.child != child || oldDelegate.height != height;
}
