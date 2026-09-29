import 'package:material_ui/material_ui.dart';

import '../l10n/common_strings.dart';
import '../theme/app_theme.dart';
import 'adaptive.dart';
import 'net_image.dart';
import 'segmented_tabs.dart';

/// Shared chrome for every screen pushed from a tab (bundle, match detail,
/// pickers, friends, legal documents…), so sub-pages match the tab roots:
///
/// - iOS-style **large title** under a slim bar; the small title fades into
///   the bar once the large one scrolls away (only the text animates, never
///   an image or a blur over the list);
/// - optional **hero** (map splash, bundle art, card art) that collapses
///   under the bar, with a scrim so the back button stays legible;
/// - optional pinned [header] strip (segments / search / filters) on the
///   frosted [GlassBar];
/// - adaptive pull-to-refresh.
///
/// ```dart
/// SubPageScaffold(
///   title: ProfileStrings.matchDetailTitle,
///   heroImage: map.splash,
///   onRefresh: () => ref.refresh(matchDetailProvider(id).future),
///   slivers: [...],
/// )
/// ```
class SubPageScaffold extends StatefulWidget {
  const SubPageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.onRefresh,
    this.hero,
    this.heroImage,
    this.heroHeight = 220,
    this.showLargeTitle = true,
    this.header,
    this.headerHeight = 60,
    this.slivers,
    this.body,
    this.floatingActionButton,
    this.bottomBar,
    this.controller,
  }) : assert(slivers != null || body != null, 'Provide slivers or body');

  final String title;

  /// Muted line under the large title ("Thi đấu xếp hạng · 29 phút").
  final String? subtitle;
  final List<Widget> actions;
  final Future<void> Function()? onRefresh;

  /// Custom hero content (drawn edge to edge under the bar). Takes
  /// precedence over [heroImage].
  final Widget? hero;

  /// Convenience: a cover image hero.
  final String? heroImage;
  final double heroHeight;

  /// Show the large title block (hide it when the hero already shows the
  /// name in big type).
  final bool showLargeTitle;

  /// Pinned strip under the bar (segments, search field).
  final Widget? header;
  final double headerHeight;
  final List<Widget>? slivers;
  final Widget? body;
  final Widget? floatingActionButton;

  /// Fixed bar at the bottom (primary action), above the safe area.
  final Widget? bottomBar;
  final ScrollController? controller;

  @override
  State<SubPageScaffold> createState() => _SubPageScaffoldState();
}

class _SubPageScaffoldState extends State<SubPageScaffold> {
  final _collapsed = ValueNotifier<bool>(false);

  bool get _hasHero => widget.hero != null || widget.heroImage != null;

  @override
  void dispose() {
    _collapsed.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    final threshold = _hasHero ? widget.heroHeight - kToolbarHeight - 8 : 44.0;
    final collapsed = n.metrics.pixels > threshold;
    if (collapsed != _collapsed.value) _collapsed.value = collapsed;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasHero = _hasHero;
    final smallTitle = ValueListenableBuilder<bool>(
      valueListenable: _collapsed,
      builder: (context, collapsed, child) => AnimatedSwitcher(
        duration: ValMotion.fast,
        child: collapsed || !widget.showLargeTitle && !hasHero
            ? child
            : const SizedBox.shrink(),
      ),
      child: Text(
        widget.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: 17),
      ),
    );

    final Widget appBar;
    if (hasHero) {
      appBar = ValueListenableBuilder<bool>(
        valueListenable: _collapsed,
        builder: (context, collapsed, _) => SliverAppBar(
          pinned: true,
          stretch: true,
          expandedHeight: widget.heroHeight,
          leading: _BarButton.back(onImage: !collapsed),
          automaticallyImplyLeading: false,
          title: smallTitle,
          actions: [
            for (final a in widget.actions) collapsed ? a : _OnImage(child: a),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            stretchModes: const [StretchMode.zoomBackground],
            background: widget.hero ?? HeroBackdrop(imageUrl: widget.heroImage),
          ),
        ),
      );
    } else {
      appBar = SliverAppBar(
        pinned: true,
        leading: Navigator.of(context).canPop() ? _BarButton.back() : null,
        automaticallyImplyLeading: false,
        title: smallTitle,
        actions: [...widget.actions, const SizedBox(width: 8)],
      );
    }

    final header = widget.header;
    final scroll = NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: CustomScrollView(
        controller: widget.controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          appBar,
          if (widget.showLargeTitle)
            SliverToBoxAdapter(
              child: LargeTitle(title: widget.title, subtitle: widget.subtitle),
            ),
          if (header != null)
            SliverPersistentHeader(
              pinned: true,
              delegate: GlassHeaderDelegate(
                child: header,
                height: widget.headerHeight,
              ),
            ),
          ...?widget.slivers,
          if (widget.slivers == null)
            SliverFillRemaining(hasScrollBody: false, child: widget.body),
          if (widget.bottomBar == null)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 24 + MediaQuery.paddingOf(context).bottom,
              ),
            ),
        ],
      ),
    );
    final refresh = widget.onRefresh;
    final bottom = widget.bottomBar;
    return Scaffold(
      floatingActionButton: widget.floatingActionButton,
      body: refresh == null
          ? scroll
          : AdaptiveRefresh(
              onRefresh: refresh,
              edgeOffset: hasHero ? 0 : kToolbarHeight,
              child: scroll,
            ),
      bottomNavigationBar: bottom == null
          ? null
          : SubPageBottomBar(child: bottom),
    );
  }
}

/// The big left-aligned title of a sub-page (tab-title look, one step
/// smaller), optionally with a muted subtitle.
class LargeTitle extends StatelessWidget {
  const LargeTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 12),
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: ValText.screenTitle.copyWith(
            fontSize: 28,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
    return Padding(
      padding: padding,
      child: trailing == null
          ? text
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: text),
                const SizedBox(width: 12),
                trailing!,
              ],
            ),
    );
  }
}

/// Cover image that fades into the page background at the bottom (and is
/// darkened at the top so the status bar and back button stay legible).
/// The scrim is a gradient on top of the image — no `Opacity` layer.
class HeroBackdrop extends StatelessWidget {
  const HeroBackdrop({
    super.key,
    this.imageUrl,
    this.child,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.tint,
    this.fadeToBackground = true,
  });

  final String? imageUrl;

  /// Drawn above the scrim (title, score, badges).
  final Widget? child;
  final BoxFit fit;
  final Alignment alignment;

  /// Base color behind the image (rarity / team tint) while it loads.
  final Color? tint;
  final bool fadeToBackground;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final base = tint ?? Theme.of(context).colorScheme.surfaceContainerHigh;
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: base),
        if (imageUrl != null)
          NetImage(
            imageUrl,
            fit: fit,
            alignment: alignment,
            error: const SizedBox.shrink(),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.28, 0.6, 1],
              colors: [
                Colors.black.withValues(alpha: 0.45),
                Colors.black.withValues(alpha: 0),
                Colors.black.withValues(alpha: 0),
                fadeToBackground ? bg : Colors.black.withValues(alpha: 0.55),
              ],
            ),
          ),
        ),
        ?child,
      ],
    );
  }
}

/// Round translucent button for bars drawn over images (back, share…).
class _BarButton extends StatelessWidget {
  const _BarButton.back({this.onImage = false});

  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      tooltip: CommonStrings.back,
      icon: Icon(
        isCupertino(context) ? Icons.arrow_back_ios_new : Icons.arrow_back,
        size: isCupertino(context) ? 20 : 24,
        color: onImage ? Colors.white : null,
      ),
      onPressed: () => Navigator.of(context).maybePop(),
    );
    return onImage ? _OnImage(child: button) : button;
  }
}

/// Wraps an app-bar action shown over a hero image in a dark circle so it
/// stays readable on bright art.
class _OnImage extends StatelessWidget {
  const _OnImage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.38),
        ),
        child: IconTheme.merge(
          data: const IconThemeData(color: Colors.white),
          child: SizedBox(width: 40, height: 40, child: Center(child: child)),
        ),
      ),
    ),
  );
}

/// Bottom action area of a sub-page or sheet: hairline on top, safe-area
/// padding, full-width content (usually one [FilledButton]).
class SubPageBottomBar extends StatelessWidget {
  const SubPageBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: valColorsOf(context).hairline)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sheets
// ---------------------------------------------------------------------------

/// Opens a ValBuddy-style modal sheet: rounded top, drag handle, a
/// [SheetHeader] with a close button, then [builder]'s content.
///
/// - `scrollable: false` (default): the sheet fits its content (up to 90 %
///   of the screen) — pickers, confirmations, info.
/// - `scrollable: true`: a draggable sheet ([initialSize]…[maxSize]); the
///   builder receives the [ScrollController] to hand to its list.
Future<T?> showValSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  Widget? leading,
  List<Widget> actions = const [],
  required Widget Function(BuildContext context, ScrollController? controller)
  builder,
  bool scrollable = false,
  double initialSize = 0.7,
  double minSize = 0.4,
  double maxSize = 0.95,
  bool useRootNavigator = false,
}) {
  Widget header(BuildContext context) => SheetHeader(
    title: title,
    subtitle: subtitle,
    leading: leading,
    actions: actions,
  );
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: useRootNavigator,
    builder: (sheetContext) {
      if (!scrollable) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header(sheetContext),
              Flexible(child: builder(sheetContext, null)),
            ],
          ),
        );
      }
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: initialSize,
        minChildSize: minSize,
        maxChildSize: maxSize,
        builder: (innerContext, controller) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header(innerContext),
            Expanded(child: builder(innerContext, controller)),
          ],
        ),
      );
    },
  );
}

/// Header of a modal sheet (ValBuddy "Game Details" look): bold title and
/// optional muted subtitle on the left, actions and a round close button on
/// the right.
class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.showClose = true,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 12, 12),
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final bool showClose;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ValText.sectionTitle.copyWith(
                      fontSize: 20,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          ...actions,
          if (showClose) const SheetCloseButton(),
        ],
      ),
    );
  }
}

/// Round `s2` close button (×) of sheets and full-screen modals.
class SheetCloseButton extends StatelessWidget {
  const SheetCloseButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      tooltip: CommonStrings.close,
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      style: IconButton.styleFrom(
        backgroundColor: valColorsOf(context).surface2,
        foregroundColor: theme.colorScheme.onSurface,
        minimumSize: const Size(36, 36),
        fixedSize: const Size(36, 36),
        padding: EdgeInsets.zero,
      ),
      icon: const Icon(Icons.close, size: 20),
    );
  }
}
