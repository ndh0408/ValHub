import 'package:material_ui/material_ui.dart';

import '../accounts/account_widgets.dart';
import '../theme/app_theme.dart';
import 'adaptive.dart';
import 'maintenance_banner.dart';
import 'segmented_tabs.dart';

/// Standard scaffold for the five tab roots: Anton 34 title (Figma), the account
/// chip, optional actions, an optional pinned header (e.g. [SegmentedTabs]),
/// the maintenance banner and pull-to-refresh.
///
/// Give it either [slivers] (preferred for long lists) or a [body] box.
///
/// ```dart
/// TabPageScaffold(
///   title: CommonStrings.tabStore,
///   onRefresh: () => ref.refresh(storefrontProvider(puuid).future),
///   header: SegmentedTabs(...),
///   slivers: [SliverList.list(children: [...])],
/// )
/// ```
class TabPageScaffold extends StatelessWidget {
  const TabPageScaffold({
    super.key,
    required this.title,
    this.actions = const [],
    this.onRefresh,
    this.header,
    this.slivers,
    this.body,
    this.showAccountChip = true,
    this.showMaintenanceBanner = true,
    this.floatingActionButton,
    this.headerHeight = 60,
    this.controller,
  }) : assert(slivers != null || body != null, 'Provide slivers or body');

  final String title;
  final List<Widget> actions;

  /// Pull-to-refresh callback (typically `ref.refresh(p.future)`).
  final Future<void> Function()? onRefresh;

  /// Pinned widget under the title (segmented tabs, filters…).
  final Widget? header;
  final List<Widget>? slivers;
  final Widget? body;
  final bool showAccountChip;
  final bool showMaintenanceBanner;
  final Widget? floatingActionButton;

  /// Height of the pinned [header] strip (frosted glass background).
  final double headerHeight;

  /// Scroll controller of the page (a screen that scrolls or measures its
  /// own content, e.g. Home). Installed as the primary scroll controller of
  /// the subtree, so the iOS status-bar tap still scrolls to the top.
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final headerWidget = header;
    final scroll = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          toolbarHeight: 72,
          titleSpacing: 20,
          title: Text(
            title,
            style: ValText.screenTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            ...actions,
            if (showAccountChip) const AccountChip(),
            const SizedBox(width: 16),
          ],
        ),
        if (showMaintenanceBanner)
          const SliverToBoxAdapter(child: MaintenanceBanner()),
        if (headerWidget != null)
          SliverPersistentHeader(
            pinned: true,
            delegate: GlassHeaderDelegate(
              child: headerWidget,
              height: headerHeight,
            ),
          ),
        ...?slivers,
        if (slivers == null)
          SliverFillRemaining(hasScrollBody: false, child: body),
      ],
    );
    final refresh = onRefresh;
    final controller = this.controller;
    final page = controller == null
        ? scroll
        : PrimaryScrollController(controller: controller, child: scroll);
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: refresh == null
          ? page
          : AdaptiveRefresh(onRefresh: refresh, child: page),
    );
  }
}
