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
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: refresh == null
          ? scroll
          : AdaptiveRefresh(onRefresh: refresh, child: scroll),
    );
  }
}
