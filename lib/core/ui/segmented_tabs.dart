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

/// Pill segmented control (ValBuddy-style): each segment is a grey pill and
/// a solid red pill with white text slides to the selected one
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
    this.secondary = false,
  });

  final List<SegmentedTab<T>> tabs;
  final T selected;
  final ValueChanged<T> onChanged;
  final EdgeInsets padding;
  final bool expand;
  final bool secondary;

  @override
  State<SegmentedTabs<T>> createState() => _SegmentedTabsState<T>();
}

class _SegmentedTabsState<T> extends State<SegmentedTabs<T>> {
  final _stackKey = GlobalKey();
  List<GlobalKey> _keys = const [];

  /// Every segment's rect inside the track (scroll mode), measured after
  /// layout; `null` until the first measurement.
  List<Rect>? _rects;

  bool get _expand =>
      widget.expand && MediaQuery.textScalerOf(context).scale(14) <= 20;

  int get _index {
    final i = widget.tabs.indexWhere((t) => t.value == widget.selected);
    return i < 0 ? 0 : i;
  }

  void _syncKeys() {
    if (_keys.length != widget.tabs.length) {
      _keys = [for (final _ in widget.tabs) GlobalKey()];
      _rects = null;
    }
  }

  @override
  void didUpdateWidget(SegmentedTabs<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected && !_expand) {
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
    if (stack is! RenderBox || !stack.hasSize) return;
    final rects = <Rect>[];
    for (final key in _keys) {
      final seg = key.currentContext?.findRenderObject();
      if (seg is! RenderBox || !seg.hasSize) return;
      rects.add(seg.localToGlobal(Offset.zero, ancestor: stack) & seg.size);
    }
    final old = _rects;
    final same =
        old != null &&
        old.length == rects.length &&
        Iterable<int>.generate(rects.length).every((i) => old[i] == rects[i]);
    if (!same) setState(() => _rects = rects);
  }

  void _tap(T value) {
    if (value == widget.selected) return;
    Haptics.selection();
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.secondary) {
      final scheme = Theme.of(context).colorScheme;
      return Padding(
        padding: widget.padding,
        child: Row(
          children: [
            for (final tab in widget.tabs)
              Expanded(
                child: Semantics(
                  selected: tab.value == widget.selected,
                  child: TextButton(
                    onPressed: () => _tap(tab.value),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      foregroundColor: scheme.onSurface,
                      backgroundColor: tab.value == widget.selected
                          ? scheme.primary.withValues(alpha: 0.12)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(
                            fontWeight: tab.value == widget.selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                    ),
                    child: Text(tab.label, textAlign: TextAlign.center),
                  ),
                ),
              ),
          ],
        ),
      );
    }
    _syncKeys();
    final n = widget.tabs.length;
    final index = _index;
    if (!_expand) {
      WidgetsBinding.instance.addPostFrameCallback(_measure);
    }
    final rects = _rects;
    // Before the first measurement (scroll mode) each segment paints its
    // own pill, so the very first frame is already correct.
    final ownPill = !_expand && rects == null;

    const gap = 8.0;
    final segments = <Widget>[
      for (var i = 0; i < n; i++)
        _Segment(
          key: _keys[i],
          tab: widget.tabs[i],
          selected: i == index,
          paintPill: ownPill,
          compact: _expand,
          onTap: () => _tap(widget.tabs[i].value),
        ),
    ];
    // Layers: grey pills, the sliding red pill, then the labels on top.
    final row = Row(
      mainAxisSize: _expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        for (var i = 0; i < n; i++) ...[
          if (i > 0) const SizedBox(width: gap),
          _expand ? Expanded(child: segments[i]) : segments[i],
        ],
      ],
    );

    List<Widget> layers(List<Rect> boxes) => [
      for (final r in boxes) Positioned.fromRect(rect: r, child: const _Pill()),
      if (index < boxes.length)
        AnimatedPositioned.fromRect(
          duration: ValMotion.medium,
          curve: ValMotion.curve,
          rect: boxes[index],
          child: const IgnorePointer(child: _Highlight()),
        ),
      row,
    ];

    final Widget track;
    if (_expand) {
      track = LayoutBuilder(
        builder: (context, box) {
          final w = n == 0 ? 0.0 : (box.maxWidth - gap * (n - 1)) / n;
          // Height follows the row: fill vertically via top/bottom.
          return Stack(
            key: _stackKey,
            children: [
              for (var i = 0; i < n; i++)
                PositionedDirectional(
                  start: i * (w + gap),
                  top: 0,
                  bottom: 0,
                  width: w,
                  child: const _Pill(),
                ),
              AnimatedPositionedDirectional(
                duration: ValMotion.medium,
                curve: ValMotion.curve,
                start: index * (w + gap),
                top: 0,
                bottom: 0,
                width: w,
                child: const IgnorePointer(child: _Highlight()),
              ),
              row,
            ],
          );
        },
      );
    } else {
      track = Stack(
        key: _stackKey,
        children: rects == null ? [row] : layers(rects),
      );
    }
    // Segment labels cap their text scale (like iOS segmented controls) so
    // the pinned bar keeps a fixed height at 200 % text size.
    final clamped = MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.25,
      child: track,
    );
    if (_expand) {
      return Padding(padding: widget.padding, child: clamped);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: widget.padding,
      child: clamped,
    );
  }
}

/// Inactive grey pill behind a segment.
class _Pill extends StatelessWidget {
  const _Pill();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(ValRadius.pill),
    ),
  );
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
          colors: [Color.lerp(accent, Colors.white, 0.08)!, accent],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
    required this.paintPill,
    required this.compact,
    required this.onTap,
  });

  final SegmentedTab<Object?> tab;

  final bool selected;

  /// Paint its own pill (grey, or red when selected) — first frame of the
  /// scroll mode, before the sliding layers are measured.
  final bool paintPill;

  /// Equal-width mode: tighter padding, labels scale down to fit.
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = selected ? scheme.onPrimary : scheme.onSurfaceVariant;
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
    final padded = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 18,
          vertical: 8,
        ),
        child: Center(widthFactor: 1, child: content),
      ),
    );
    return Semantics(
      container: true,
      selected: selected,
      button: true,
      label: tab.label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Ink(
            decoration: paintPill
                ? BoxDecoration(
                    color: selected
                        ? scheme.primary
                        : scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(ValRadius.pill),
                  )
                : null,
            child: padded,
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
  const GlassBar({
    super.key,
    required this.child,
    this.opacity = 0.90,
    this.border,
  });

  final Widget child;
  final double opacity;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg.withValues(alpha: opacity),
            border: border,
          ),
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
    opacity: overlapsContent ? 0.94 : 0.88,
    border: overlapsContent
        ? Border(bottom: BorderSide(color: valColorsOf(context).hairline))
        : null,
    child: SizedBox(
      height: height,
      child: Align(alignment: AlignmentDirectional.centerStart, child: child),
    ),
  );

  @override
  bool shouldRebuild(GlassHeaderDelegate oldDelegate) =>
      oldDelegate.child != child || oldDelegate.height != height;
}
