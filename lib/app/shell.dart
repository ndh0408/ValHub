import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/l10n/common_strings.dart';
import '../core/ui/floating_nav_bar.dart';
import '../features/collection/collection_routes.dart';
import '../features/community/community_routes.dart';
import '../features/home/home_routes.dart';
import '../features/live_game/live_game_overlay_host.dart';
import '../features/profile/profile_routes.dart';
import '../features/store/store_reset_reminder_host.dart';
import '../features/store/store_routes.dart';

/// The five tabs, in bar order (docs/design/IA.md): Trang chủ · Cửa hàng ·
/// Cộng đồng (middle, emphasized) · Bộ sưu tập · Hồ sơ. Battle Pass and Cài
/// đặt are not tabs: their routes live under the Hồ sơ branch. Use
/// [AppTab.index] instead of a hard-coded branch number.
enum AppTab {
  home(HomeRoutes.root),
  store(StoreRoutes.root),
  community(CommunityRoutes.root),
  collection(CollectionRoutes.root),
  profile(ProfileRoutes.root);

  const AppTab(this.root);

  /// The branch's root location.
  final String root;

  String get label => switch (this) {
    home => CommonStrings.tabHome,
    store => CommonStrings.tabStore,
    community => CommonStrings.tabCommunity,
    collection => CommonStrings.tabCollection,
    profile => CommonStrings.tabProfile,
  };

  NavigationDestination get destination => switch (this) {
    home => const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: CommonStrings.tabHome,
    ),
    store => const NavigationDestination(
      icon: Icon(Icons.storefront_outlined),
      selectedIcon: Icon(Icons.storefront),
      label: CommonStrings.tabStore,
    ),
    community => const NavigationDestination(
      icon: Icon(Icons.forum_outlined),
      selectedIcon: Icon(Icons.forum),
      label: CommonStrings.tabCommunity,
    ),
    collection => const NavigationDestination(
      icon: Icon(Icons.inventory_2_outlined),
      selectedIcon: Icon(Icons.inventory_2),
      label: CommonStrings.tabCollection,
    ),
    profile => const NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: CommonStrings.tabProfile,
    ),
  };
}

/// Tab shell: the five tabs, the live-game overlay hook and the always
/// mounted store-reset reminder host (Home is the landing tab, so the Store
/// tab may never be built).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static final _destinations = [
    for (final tab in AppTab.values) tab.destination,
  ];

  /// Below this width only the selected tab shows its label (the others
  /// keep their semantics label). Five tabs fit from 360 dp up.
  static const compactWidth = 360.0;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < compactWidth;
    return Scaffold(
      body: LiveGameOverlayHost(
        child: StoreResetReminderHost(child: navigationShell),
      ),
      // Floating frosted capsule; styling lives in FloatingNavBar.
      bottomNavigationBar: FloatingNavBar(
        selectedIndex: navigationShell.currentIndex,
        compact: compact,
        emphasizedIndex: AppTab.community.index,
        // Tapping the active tab pops that branch to its root.
        onDestinationSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        destinations: _destinations,
      ),
    );
  }
}
