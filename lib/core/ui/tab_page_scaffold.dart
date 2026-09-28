import 'package:material_ui/material_ui.dart';

import '../accounts/account_widgets.dart';
import 'maintenance_banner.dart';

/// Standard scaffold for the five tab roots: large Anton title, the account
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerWidget = header;
    final scroll = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          toolbarHeight: 64,
          titleSpacing: 16,
          title: Text(
            title.toUpperCase(),
            style: theme.textTheme.headlineMedium,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            ...actions,
            if (showAccountChip) const AccountChip(),
            const SizedBox(width: 8),
          ],
        ),
        if (showMaintenanceBanner)
          const SliverToBoxAdapter(child: MaintenanceBanner()),
        if (headerWidget != null)
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedHeader(headerWidget),
          ),
        ...?slivers,
        if (slivers == null)
          SliverFillRemaining(hasScrollBody: false, child: body),
      ],
    );
    final refresh = onRefresh;
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: refresh == null
          ? scroll
          : RefreshIndicator(onRefresh: refresh, child: scroll),
    );
  }
}

class _PinnedHeader extends SliverPersistentHeaderDelegate {
  _PinnedHeader(this.child);

  final Widget child;
  static const _height = 52.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ColoredBox(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: SizedBox(
      height: _height,
      child: Align(alignment: Alignment.centerLeft, child: child),
    ),
  );

  @override
  bool shouldRebuild(_PinnedHeader oldDelegate) => oldDelegate.child != child;
}
